import express from "express";
import helmet from "helmet";
import cors from "cors";
import path from "path";
import { env } from "./utils/envValidator.js";
import { errorHandler, notFoundHandler } from "./middlewares/errorHandler.js";
import { applyRequestMiddleware } from "./middlewares/requestId.js";
import { logger, requestLogger } from "./utils/logger.js";
import { rateLimiters } from "./utils/rateLimiter.js";
import { cacheMiddleware, checkCacheHealth } from "./utils/cache.js";
import routes from "./routes/index.js";
import setupPassport from "./config/passport.js";
import passport from "passport";
import i18nMiddleware from "./middlewares/i18n.js";

const app = express();
setupPassport();
app.use(passport.initialize());

applyRequestMiddleware(app);

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "ws:", "wss:"],
    },
  },
}));

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'X-Request-ID', 'Accept-Language']
}));

app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ extended: true, limit: "50mb" }));

app.use(requestLogger);

// Add i18n middleware for multi-language support
app.use(i18nMiddleware);

app.use(rateLimiters.api);

app.use("/uploads", express.static(path.resolve("uploads")));
app.use("/uploads/avatar", express.static(path.resolve("uploads/avatar")));

app.use("/uploads", cacheMiddleware(3600000));

app.get("/health", (req, res) => {
  const cacheHealth = checkCacheHealth();
  res.json({
    ok: true,
    environment: env.NODE_ENV,
    timestamp: new Date().toISOString(),
    cache: cacheHealth,
    uptime: process.uptime(),
  });
});

app.get("/dbtest", async (req, res) => {
  try {
    const { query } = await import("./config/db.js");
    const result = await query("SELECT NOW() as now");
    res.json({
      db_time: result.rows[0].now,
      status: "connected"
    });
  } catch (err) {
    logger.error("Database connection failed", { error: err.message });
    res.status(500).json({
      error: "DB connection failed",
      status: "disconnected",
      requestId: req.id
    });
  }
});

app.use("/api/v1", routes);

app.get("/api/v1/cache/stats", (req, res) => {
  import("./utils/cache.js").then(({ cache }) => {
    const stats = {
      cache: cache.getStats(),
      memory: process.memoryUsage(),
      timestamp: new Date().toISOString(),
    };
    res.json(stats);
  }).catch(err => {
    res.status(500).json({ error: "Failed to get cache stats", message: err.message });
  });
});

app.use(notFoundHandler);

app.use(errorHandler);

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

export default app;

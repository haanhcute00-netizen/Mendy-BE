import "dotenv/config";
import http from "http";
import { Server } from "socket.io";
import { env } from "./utils/envValidator.js";
import { logger, handleUncaughtExceptions, handleUnhandledRejections } from "./utils/logger.js";
import { handleUnhandledRejections as errorHandlerUnhandledRejections } from "./middlewares/errorHandler.js";
import app from "./app.js";
import { initChatSocket } from "./sockets/chat.socket.js";
import { initRtcSocket } from "./sockets/rtc.socket.js";
import * as BookingsService from "./modules/bookings/bookings.service.js";

const validatedEnv = env;

handleUncaughtExceptions();
handleUnhandledRejections();
errorHandlerUnhandledRejections();

const PORT = validatedEnv.PORT || 4000;
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: true, credentials: true }
});

initChatSocket(io);
initRtcSocket(io);

server.listen(PORT, () => {
  logger.info(`✅ API running: http://localhost:${PORT}`, {
    environment: validatedEnv.NODE_ENV,
    port: PORT,
    nodeVersion: process.version,
  });
});

setInterval(async () => {
  try {
    const completedBookings = await BookingsService.autoCompleteExpiredBookings();
    if (completedBookings.length > 0) {
      logger.info(`Auto-completed ${completedBookings.length} expired bookings`);
    }
  } catch (error) {
    logger.error('Error in auto-complete job', { error: error.message, stack: error.stack });
  }
}, 5 * 60 * 1000);

server.on('error', (error) => {
  logger.error('Server error', { error: error.message, stack: error.stack });

  if (error.syscall !== 'listen') {
    throw error;
  }

  const bind = typeof PORT === 'string' ? `Pipe ${PORT}` : `Port ${PORT}`;

  switch (error.code) {
    case 'EACCES':
      logger.error(`${bind} requires elevated privileges`);
      process.exit(1);
      break;
    case 'EADDRINUSE':
      logger.error(`${bind} is already in use`);
      process.exit(1);
      break;
    default:
      throw error;
  }
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

// src/routes/index.js
import { Router } from "express";

// Import từng nhóm route
import authRouter from "./auth.routes.js";
import postsRouter from "./posts.routes.js";
import profileRouter from "./profile.routes.js";
import bookingsRouter from "./bookings.routes.js";
import chatRouter from "./chat.routes.js";
import commentsRouter from "./comments.routes.js";
import emailRouter from "./email.routes.js";
import followsRouter from "./follows.routes.js";
import paymentsRouter from "./payments.routes.js";
import adminRouter from "./admin.routes.js";
import reviewsRouter from "./reviews.routes.js";
import payoutAccountsRouter from "./payoutAccounts.routes.js";
import banksRouter from "./banks.routes.js";
import { router as expertsRouter, publicRouter as publicExpertsRouter } from "./experts.routes.js";



const router = Router();



// Nếu muốn yêu cầu đăng nhập cho mọi route trừ /auth, có thể thêm:
// router.use((req, res, next) => {
//   if (req.path.startsWith("/auth")) return next();
//   return verifyJwt(req, res, next);
// });

// ✅ Mount từng module con — KHÔNG có /api/v1 lặp lại
router.use("/auth", authRouter);
router.use("/posts", postsRouter);
router.use("/profile", profileRouter);
router.use("/bookings", bookingsRouter);
router.use("/chat", chatRouter);
router.use("/comments", commentsRouter);
router.use("/email", emailRouter);
router.use("/follows", followsRouter);
router.use("/payments", paymentsRouter);
router.use("/admin", adminRouter);
router.use("/reviews", reviewsRouter);
router.use("/payout-accounts", payoutAccountsRouter);
router.use("/banks", banksRouter);
router.use("/experts", expertsRouter);

// Public expert routes (no authentication required)
router.use("/public/experts", publicExpertsRouter);

// 🧾 Fallback cho route không tồn tại
router.use((req, res) => {
  res.status(404).json({
    error: "Not Found",
    message: `Route ${req.originalUrl} does not exist.`,
    requestId: req.id,
  });
});

export default router;

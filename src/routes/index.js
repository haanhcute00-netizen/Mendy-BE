// src/routes/index.js
import { Router } from "express";

// Import từng nhóm route
// Import từng nhóm route
import authRouter from "../modules/auth/auth.routes.js";
import postsRouter from "../modules/posts/posts.routes.js";
import profileRouter from "../modules/users/profile.routes.js";
import bookingsRouter from "../modules/bookings/bookings.routes.js";
import chatRouter from "../modules/chat/chat.routes.js";
import commentsRouter from "../modules/comments/comments.routes.js";
import emailRouter from "../modules/email/email.routes.js";
import followsRouter from "../modules/users/follows.routes.js";
import usersRouter from "../modules/users/users.routes.js";
import paymentsRouter from "../modules/payments/payments.routes.js";
import adminRouter from "../modules/admin/admin.routes.js";
import reviewsRouter from "../modules/reviews/reviews.routes.js";
import payoutAccountsRouter from "../modules/payouts/payoutAccounts.routes.js";
import banksRouter from "../modules/payouts/banks.routes.js";
import payoutsRouter from "../modules/payouts/payouts.routes.js";
import { router as expertsRouter, publicRouter as publicExpertsRouter } from "../modules/experts/experts.routes.js";
import expertSearchRouter from "../modules/filter-search-expert/routes.js";
import AI from "../AI/routes.js";
import { aiCompanionRouter } from "../AI/companion/index.js";
import refundsRouter from "../modules/refunds/refunds.routes.js";
import disputesRouter from "../modules/disputes/disputes.routes.js";
import recurringRouter from "../modules/recurring/recurring.routes.js";
import uploadRouter from "./upload.route.js";



const router = Router();



// Nếu muốn yêu cầu đăng nhập cho mọi route trừ /auth, có thể thêm:
// router.use((req, res, next) => {
//   if (req.path.startsWith("/auth")) return next();
//   return verifyJwt(req, res, next);
// });

// ✅ Mount từng module con — KHÔNG có /api/v1 lặp lại
router.use("/auth", authRouter);
router.use("/ai", AI);
router.use("/posts", postsRouter);
router.use("/profile", profileRouter);
router.use("/bookings", bookingsRouter);
router.use("/chat", chatRouter);
router.use("/comments", commentsRouter);
router.use("/email", emailRouter);
router.use("/follows", followsRouter);
router.use("/users", usersRouter);
router.use("/payments", paymentsRouter);
router.use("/admin", adminRouter);
router.use("/reviews", reviewsRouter);
router.use("/payout-accounts", payoutAccountsRouter);
router.use("/banks", banksRouter);
router.use("/payouts", payoutsRouter);
router.use("/experts", expertsRouter);
router.use("/uploads", uploadRouter);

// Public expert routes (no authentication required)
router.use("/public/experts", publicExpertsRouter);

// Expert Search module (public - no auth required)
// GET /api/v1/expert-search/advanced - Advanced search with 30+ filters
// GET /api/v1/expert-search/facets - Get filter options for UI
// GET /api/v1/expert-search/quick-filters - Preset filters
// GET /api/v1/expert-search/:expertId/full - Full expert details
// GET /api/v1/expert-search/:expertId/similar - Similar experts
router.use("/expert-search", expertSearchRouter);

// AI Companion module
// GET /api/v1/ai-companion/personas - List all personas
// GET /api/v1/ai-companion/settings - Get user AI settings
// POST /api/v1/ai-companion/settings - Update user AI settings
// POST /api/v1/ai-companion/persona/select - Select a persona
// GET /api/v1/ai-companion/notifications - Get user notifications
// POST /api/v1/ai-companion/notifications/schedule - Schedule notification
router.use("/ai-companion", aiCompanionRouter);

// Refunds module
// GET /api/v1/refunds/calculate/:booking_id - Calculate refund amount
// POST /api/v1/refunds/request - Request refund
// GET /api/v1/refunds/mine - List my refunds
// GET /api/v1/refunds/admin/list - Admin: List all refunds
// POST /api/v1/refunds/admin/:id/process - Admin: Process refund
router.use("/refunds", refundsRouter);

// Disputes module
// POST /api/v1/disputes/raise - Raise a dispute
// GET /api/v1/disputes/mine - List my disputes
// GET /api/v1/disputes/:id - Get dispute details
// POST /api/v1/disputes/:id/message - Add message to dispute
// GET /api/v1/disputes/admin/list - Admin: List all disputes
// POST /api/v1/disputes/admin/:id/assign - Admin: Assign dispute
// POST /api/v1/disputes/admin/:id/resolve - Admin: Resolve dispute
router.use("/disputes", disputesRouter);

// Recurring bookings module
// POST /api/v1/recurring - Create recurring template
// GET /api/v1/recurring/mine - List my templates
// GET /api/v1/recurring/:id - Get template details
// PATCH /api/v1/recurring/:id - Update template
// DELETE /api/v1/recurring/:id - Cancel template
// POST /api/v1/recurring/admin/process - Admin: Process recurring bookings
router.use("/recurring", recurringRouter);

// 🧾 Fallback cho route không tồn tại
router.use((req, res) => {
  res.status(404).json({
    error: "Not Found",
    message: `Route ${req.originalUrl} does not exist.`,
    requestId: req.id,
  });
});

export default router;

import { Router } from "express";
import { auth } from "../../middlewares/auth.js";
import { requireAdmin } from "./admin.controller.js";
import rateLimit from "express-rate-limit";

// Import admin controllers
import {
  getDashboard,
  getBookingAnalytics,
  getRevenueAnalytics,
  getUsers,
  getUserById,
  suspendUser,
  activateUser,
  banUser,
  getReportedContent,
  hideContent,
  deleteContent,
  getAuditLogs,
  getExperts,
  approveExpertKYC,
  rejectExpertKYC,
  getAllBookings,
  updateBookingStatus,
  getSystemSettings,
  updateSystemSettings,
  // Post moderation
  getPosts,
  getPostById,
  scanPost,
  scanAllPosts,
  hidePostByAdmin,
  deletePostByAdmin,
  getFlaggedPosts,
  bulkScanPosts,
  // NEW: Enhanced controllers with pagination total
  getUsersWithCount,
  getPostsWithCount,
  getEnhancedDashboard,
  // NEW: Report resolution
  getReportsWithCount,
  getReportById,
  resolveReport,
  dismissReport,
  getReportStats,
  // NEW: Payout management
  getPayoutsWithCount,
  getPayoutById,
  getPayoutStats,
  // NEW: Comment moderation
  getCommentsWithCount,
  getCommentById,
  scanComment,
  getFlaggedComments,
  hideCommentByAdmin,
  deleteCommentByAdmin,
  bulkScanComments,
  // NEW: Transaction history
  getTransactions
} from "./admin.controller.js";

const router = Router();

// Apply admin middleware to all routes
router.use(auth);
router.use(requireAdmin);

// Apply rate limiting
const adminLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // Limit each admin to 100 requests per minute
  message: "Too many requests from admin, please try again later."
});

router.use(adminLimiter);

// Dashboard analytics routes
router.get("/dashboard", getDashboard);
router.get("/dashboard/enhanced", getEnhancedDashboard);  // NEW: Enhanced dashboard with payout stats
router.get("/analytics/bookings", getBookingAnalytics);
router.get("/analytics/revenue", getRevenueAnalytics);

// User management routes
router.get("/users", getUsers);
router.get("/users/list", getUsersWithCount);  // NEW: With total count for pagination
router.get("/users/:userId", getUserById);
router.patch("/users/:userId/suspend", suspendUser);
router.patch("/users/:userId/activate", activateUser);
router.post("/users/:userId/ban", banUser);

// Expert management routes
router.get("/experts", getExperts);
router.patch("/experts/:expertId/kyc/approve", approveExpertKYC);
router.patch("/experts/:expertId/kyc/reject", rejectExpertKYC);

// Booking management routes
router.get("/bookings", getAllBookings);
router.patch("/bookings/:bookingId/status", updateBookingStatus);

// ============================================
// REPORT MANAGEMENT ROUTES (NEW)
// ============================================
router.get("/reports", getReportsWithCount);           // List reports with total count
router.get("/reports/stats", getReportStats);          // Report statistics
router.get("/reports/:reportId", getReportById);       // Get report details
router.patch("/reports/:reportId/resolve", resolveReport);   // Resolve report
router.patch("/reports/:reportId/dismiss", dismissReport);   // Dismiss report (false positive)

// Content moderation routes (legacy)
router.get("/content/reports", getReportedContent);
router.post("/content/:targetType/:targetId/hide", hideContent);
router.post("/content/:targetType/:targetId/delete", deleteContent);

// Post moderation routes
router.get("/posts", getPosts);
router.get("/posts/list", getPostsWithCount);  // NEW: With total count for pagination
router.get("/posts/flagged", getFlaggedPosts);
router.get("/posts/scan", scanAllPosts);
router.post("/posts/bulk-scan", bulkScanPosts);
router.get("/posts/:postId", getPostById);
router.get("/posts/:postId/scan", scanPost);
router.post("/posts/:postId/hide", hidePostByAdmin);
router.delete("/posts/:postId", deletePostByAdmin);

// ============================================
// COMMENT MODERATION ROUTES (NEW)
// ============================================
router.get("/comments", getCommentsWithCount);         // List comments with total count
router.get("/comments/flagged", getFlaggedComments);   // Flagged/reported comments
router.post("/comments/bulk-scan", bulkScanComments);  // Bulk scan comments
router.get("/comments/:commentId", getCommentById);    // Get comment details
router.get("/comments/:commentId/scan", scanComment);  // Scan single comment
router.post("/comments/:commentId/hide", hideCommentByAdmin);    // Hide comment
router.delete("/comments/:commentId", deleteCommentByAdmin);     // Delete comment

// ============================================
// PAYOUT MANAGEMENT ROUTES (NEW)
// ============================================
router.get("/payouts", getPayoutsWithCount);           // List payouts with total count
router.get("/payouts/stats", getPayoutStats);          // Payout statistics
router.get("/payouts/:payoutId", getPayoutById);       // Get payout details
// Note: Approve/Reject payouts are in /api/v1/payouts/admin/* routes

// ============================================
// TRANSACTION HISTORY ROUTES (NEW)
// ============================================
router.get("/transactions", getTransactions);          // List all transactions

// System settings routes
router.get("/settings", getSystemSettings);
router.put("/settings", updateSystemSettings);

// Audit logs routes
router.get("/audit/logs", getAuditLogs);

export default router;
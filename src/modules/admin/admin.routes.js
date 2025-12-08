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

// Import extended admin controllers
import {
  // Payout approval/rejection
  approvePayoutByAdmin,
  rejectPayoutByAdmin,
  // Refund management
  getRefundsWithCount,
  getRefundStats,
  getRefundByIdAdmin,
  approveRefundByAdmin,
  rejectRefundByAdmin,
  // Dispute management
  getDisputesWithCount,
  getDisputeStats,
  getDisputeByIdAdmin,
  getDisputeMessagesAdmin,
  assignDisputeAdmin,
  addDisputeMessageAdmin,
  resolveDisputeByAdmin,
  // Review management
  getReviewsWithCount,
  getReviewStats,
  getReviewByIdAdmin,
  hideReviewByAdmin,
  deleteReviewByAdmin,
  // Chat management
  getChatThreads,
  getChatThreadByIdAdmin,
  getChatMessagesAdmin,
  deleteChatMessageAdmin,
  getChatStats,
  // Call management
  getCallSessionsWithCount,
  getCallSessionByIdAdmin,
  getCallStats,
  // Wallet management
  getWalletsWithCount,
  getWalletByUserIdAdmin,
  adjustWalletByAdmin,
  getWalletStats,
  // Skills & Domains
  getSkillsAdmin,
  createSkillAdmin,
  updateSkillAdmin,
  deleteSkillAdmin,
  getDomainsAdmin,
  createDomainAdmin,
  updateDomainAdmin,
  deleteDomainAdmin,
  // Recurring bookings
  getRecurringBookingsAdmin,
  cancelRecurringBookingAdmin,
  // User management - update & delete
  updateUserByAdmin,
  deleteUserByAdmin
} from "./admin.extended.controller.js";

// Import analytics controllers
import {
  getComprehensiveDashboard,
  getTimeSeriesAnalytics,
  getTopPerformers,
  getRevenueBreakdown,
  getUserGrowthAnalytics,
  getBookingAnalyticsDetailed,
  getRealTimeMetrics,
  getComparisonAnalytics
} from "./admin.analytics.controller.js";

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
router.get("/dashboard/enhanced", getEnhancedDashboard);
router.get("/dashboard/comprehensive", getComprehensiveDashboard);  // NEW: Full dashboard with all metrics
router.get("/analytics/bookings", getBookingAnalytics);
router.get("/analytics/revenue", getRevenueAnalytics);

// ============================================
// ENHANCED ANALYTICS ROUTES (NEW)
// ============================================
router.get("/analytics/time-series", getTimeSeriesAnalytics);      // Time series data (users, bookings, revenue, posts, reports)
router.get("/analytics/top-performers", getTopPerformers);         // Top experts, seekers, content creators
router.get("/analytics/revenue-breakdown", getRevenueBreakdown);   // Revenue by method, specialty, channel
router.get("/analytics/user-growth", getUserGrowthAnalytics);      // User growth & retention
router.get("/analytics/bookings-detailed", getBookingAnalyticsDetailed);  // Detailed booking analytics
router.get("/analytics/realtime", getRealTimeMetrics);             // Real-time metrics (last 24h, 1h, 15m)
router.get("/analytics/comparison", getComparisonAnalytics);       // Period comparison (day/week/month)

// User management routes
router.get("/users", getUsers);
router.get("/users/list", getUsersWithCount);  // NEW: With total count for pagination
router.get("/users/:userId", getUserById);
router.put("/users/:userId", updateUserByAdmin);       // UPDATE user info
router.delete("/users/:userId", deleteUserByAdmin);    // DELETE user (soft/hard)
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
router.post("/payouts/:payoutId/approve", approvePayoutByAdmin);  // Approve payout
router.post("/payouts/:payoutId/reject", rejectPayoutByAdmin);    // Reject payout

// ============================================
// REFUND MANAGEMENT ROUTES (NEW - Priority 1)
// ============================================
router.get("/refunds", getRefundsWithCount);           // List refunds with total count
router.get("/refunds/stats", getRefundStats);          // Refund statistics
router.get("/refunds/:refundId", getRefundByIdAdmin);  // Get refund details
router.post("/refunds/:refundId/approve", approveRefundByAdmin);  // Approve refund
router.post("/refunds/:refundId/reject", rejectRefundByAdmin);    // Reject refund

// ============================================
// DISPUTE MANAGEMENT ROUTES (NEW - Priority 1)
// ============================================
router.get("/disputes", getDisputesWithCount);         // List disputes with total count
router.get("/disputes/stats", getDisputeStats);        // Dispute statistics
router.get("/disputes/:disputeId", getDisputeByIdAdmin);          // Get dispute details
router.get("/disputes/:disputeId/messages", getDisputeMessagesAdmin);  // Get dispute messages
router.patch("/disputes/:disputeId/assign", assignDisputeAdmin);  // Assign dispute to admin
router.post("/disputes/:disputeId/message", addDisputeMessageAdmin);  // Add admin message
router.patch("/disputes/:disputeId/resolve", resolveDisputeByAdmin);  // Resolve dispute

// ============================================
// REVIEW MANAGEMENT ROUTES (NEW - Priority 2)
// ============================================
router.get("/reviews", getReviewsWithCount);           // List reviews with total count
router.get("/reviews/stats", getReviewStats);          // Review statistics
router.get("/reviews/:reviewId", getReviewByIdAdmin);  // Get review details
router.post("/reviews/:reviewId/hide", hideReviewByAdmin);        // Hide review
router.delete("/reviews/:reviewId", deleteReviewByAdmin);         // Delete review

// ============================================
// CHAT MANAGEMENT ROUTES (NEW - Priority 2)
// ============================================
router.get("/chat/threads", getChatThreads);           // List chat threads
router.get("/chat/stats", getChatStats);               // Chat statistics
router.get("/chat/threads/:threadId", getChatThreadByIdAdmin);    // Get thread details
router.get("/chat/threads/:threadId/messages", getChatMessagesAdmin);  // Get thread messages
router.delete("/chat/messages/:messageId", deleteChatMessageAdmin);    // Delete message

// ============================================
// CALL MANAGEMENT ROUTES (NEW - Priority 2)
// ============================================
router.get("/calls", getCallSessionsWithCount);        // List call sessions
router.get("/calls/stats", getCallStats);              // Call statistics
router.get("/calls/:callId", getCallSessionByIdAdmin); // Get call details

// ============================================
// WALLET MANAGEMENT ROUTES (NEW - Priority 3)
// ============================================
router.get("/wallets", getWalletsWithCount);           // List all wallets
router.get("/wallets/stats", getWalletStats);          // Wallet statistics
router.get("/wallets/:userId", getWalletByUserIdAdmin);            // Get user wallet details
router.post("/wallets/:userId/adjust", adjustWalletByAdmin);       // Manual wallet adjustment

// ============================================
// SKILLS MANAGEMENT ROUTES (NEW - Priority 3)
// ============================================
router.get("/skills", getSkillsAdmin);                 // List all skills
router.post("/skills", createSkillAdmin);              // Create skill
router.put("/skills/:skillId", updateSkillAdmin);      // Update skill
router.delete("/skills/:skillId", deleteSkillAdmin);   // Delete skill

// ============================================
// DOMAINS MANAGEMENT ROUTES (NEW - Priority 3)
// ============================================
router.get("/domains", getDomainsAdmin);               // List all domains
router.post("/domains", createDomainAdmin);            // Create domain
router.put("/domains/:domainId", updateDomainAdmin);   // Update domain
router.delete("/domains/:domainId", deleteDomainAdmin);// Delete domain

// ============================================
// RECURRING BOOKING MANAGEMENT ROUTES (NEW - Priority 3)
// ============================================
router.get("/recurring", getRecurringBookingsAdmin);   // List recurring bookings
router.post("/recurring/:templateId/cancel", cancelRecurringBookingAdmin);  // Cancel recurring

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
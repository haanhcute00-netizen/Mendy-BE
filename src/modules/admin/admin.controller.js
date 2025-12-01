import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, failure, forbidden, paginated } from "../../utils/response.js";
import * as AdminService from "./admin.service.js";
import * as AuditService from "./audit.repo.js";

// Middleware to check if user is admin
export function requireAdmin(req, res, next) {
  if (req.user.role !== "ADMIN") {
    return forbidden(res, "Admin access required");
  }
  next();
}

// Dashboard analytics
export const getDashboard = asyncHandler(async (req, res) => {
  const dashboardData = await AdminService.getDashboardData();

  await AuditService.logAction({
    userId: req.user.id,
    action: "DASHBOARD_VIEWED",
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Dashboard data retrieved successfully", dashboardData);
});

export const getBookingAnalytics = asyncHandler(async (req, res) => {
  const { days = 30 } = req.query;
  const analytics = await AdminService.getBookingAnalytics({ days: parseInt(days) });

  return success(res, "Booking analytics retrieved successfully", analytics);
});

export const getRevenueAnalytics = asyncHandler(async (req, res) => {
  const { days = 30 } = req.query;
  const analytics = await AdminService.getRevenueAnalytics({ days: parseInt(days) });

  return success(res, "Revenue analytics retrieved successfully", analytics);
});

// User management
export const getUsers = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, status, role } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    status,
    role
  };

  const users = await AdminService.getUsersList(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "USERS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return paginated(res, "Users list retrieved successfully", users, {
    limit: parseInt(limit),
    offset: parseInt(offset)
  });
});

export const getUserById = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const user = await AdminService.getUserDetails(parseInt(userId));

  await AuditService.logAction({
    userId: req.user.id,
    action: "USER_VIEWED",
    resource: "USER",
    resourceId: parseInt(userId),
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "User details retrieved successfully", user);
});

export const suspendUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for suspension is required");
  }

  const updatedUser = await AdminService.suspendUser(parseInt(userId), reason, req.user.id);

  return success(res, "User suspended successfully", {
    user: {
      id: updatedUser.id,
      status: updatedUser.status,
      updated_at: updatedUser.updated_at
    }
  });
});

export const activateUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;

  const updatedUser = await AdminService.activateUser(parseInt(userId), req.user.id);

  return success(res, "User activated successfully", {
    user: {
      id: updatedUser.id,
      status: updatedUser.status,
      updated_at: updatedUser.updated_at
    }
  });
});

export const banUser = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for ban is required");
  }

  const action = await AdminService.banUser(parseInt(userId), reason, req.user.id);

  return success(res, "User banned successfully", {
    action: {
      id: action.id,
      action: action.action,
      created_at: action.created_at
    }
  });
});

// Content moderation
export const getReportedContent = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, status, targetType } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    status,
    targetType
  };

  const reports = await AdminService.getReportedContent(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "REPORTED_CONTENT_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return paginated(res, "Reported content retrieved successfully", reports, {
    limit: parseInt(limit),
    offset: parseInt(offset)
  });
});

export const hideContent = asyncHandler(async (req, res) => {
  const { targetType, targetId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for hiding content is required");
  }

  const action = await AdminService.hideContent(targetType, parseInt(targetId), reason, req.user.id);

  return success(res, "Content hidden successfully", {
    action: {
      id: action.id,
      action: action.action,
      created_at: action.created_at
    }
  });
});

export const deleteContent = asyncHandler(async (req, res) => {
  const { targetType, targetId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for deletion is required");
  }

  const action = await AdminService.deleteContent(targetType, parseInt(targetId), reason, req.user.id);

  return success(res, "Content deleted successfully", {
    action: {
      id: action.id,
      action: action.action,
      created_at: action.created_at
    }
  });
});

// Audit logs
export const getAuditLogs = asyncHandler(async (req, res) => {
  const { limit = 50, before, userId, action } = req.query;
  const filters = {
    limit: parseInt(limit),
    before,
    userId: userId ? parseInt(userId) : null,
    action
  };

  const logs = await AuditService.getAuditLogs(filters);

  return paginated(res, "Audit logs retrieved successfully", logs, {
    limit: parseInt(limit),
    nextCursor: before
  });
});

// Expert management
export const getExperts = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, status, kycStatus } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    status,
    kycStatus
  };

  const experts = await AdminService.getExpertsList(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "EXPERTS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return paginated(res, "Experts list retrieved successfully", experts, {
    limit: parseInt(limit),
    offset: parseInt(offset)
  });
});

export const approveExpertKYC = asyncHandler(async (req, res) => {
  const { expertId } = req.params;
  const { notes } = req.body;

  const updatedExpert = await AdminService.approveExpertKYC(parseInt(expertId), notes, req.user.id);

  await AuditService.logAction({
    userId: req.user.id,
    action: "EXPERT_KYC_APPROVED",
    resource: "EXPERT",
    resourceId: parseInt(expertId),
    meta: { notes },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Expert KYC approved successfully", {
    expert: {
      id: updatedExpert.id,
      kyc_status: updatedExpert.kyc_status,
      updated_at: updatedExpert.updated_at
    }
  });
});

export const rejectExpertKYC = asyncHandler(async (req, res) => {
  const { expertId } = req.params;
  const { reason, notes } = req.body;

  if (!reason) {
    return failure(res, "Reason for rejection is required");
  }

  const updatedExpert = await AdminService.rejectExpertKYC(parseInt(expertId), reason, notes, req.user.id);

  await AuditService.logAction({
    userId: req.user.id,
    action: "EXPERT_KYC_REJECTED",
    resource: "EXPERT",
    resourceId: parseInt(expertId),
    meta: { reason, notes },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Expert KYC rejected successfully", {
    expert: {
      id: updatedExpert.id,
      kyc_status: updatedExpert.kyc_status,
      updated_at: updatedExpert.updated_at
    }
  });
});

// Booking management
export const getAllBookings = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, status, expertId, userId, dateFrom, dateTo } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    status,
    expertId: expertId ? parseInt(expertId) : null,
    userId: userId ? parseInt(userId) : null,
    dateFrom,
    dateTo
  };

  const bookings = await AdminService.getAllBookingsList(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "BOOKINGS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return paginated(res, "Bookings list retrieved successfully", bookings, {
    limit: parseInt(limit),
    offset: parseInt(offset)
  });
});

export const updateBookingStatus = asyncHandler(async (req, res) => {
  const { bookingId } = req.params;
  const { status, reason } = req.body;

  if (!status) {
    return failure(res, "Status is required");
  }

  const updatedBooking = await AdminService.updateBookingStatus(parseInt(bookingId), status, reason, req.user.id);

  await AuditService.logAction({
    userId: req.user.id,
    action: "BOOKING_STATUS_UPDATED",
    resource: "BOOKING",
    resourceId: parseInt(bookingId),
    meta: { status, reason },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Booking status updated successfully", {
    booking: {
      id: updatedBooking.id,
      status: updatedBooking.status,
      updated_at: updatedBooking.updated_at
    }
  });
});

// System settings
export const getSystemSettings = asyncHandler(async (req, res) => {
  const settings = await AdminService.getSystemSettings();

  await AuditService.logAction({
    userId: req.user.id,
    action: "SYSTEM_SETTINGS_VIEWED",
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "System settings retrieved successfully", settings);
});

export const updateSystemSettings = asyncHandler(async (req, res) => {
  const { settings } = req.body;

  if (!settings) {
    return failure(res, "Settings object is required");
  }

  const updatedSettings = await AdminService.updateSystemSettings(settings, req.user.id);

  await AuditService.logAction({
    userId: req.user.id,
    action: "SYSTEM_SETTINGS_UPDATED",
    meta: { settings },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "System settings updated successfully", updatedSettings);
});

// Post moderation
export const getPosts = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, authorId, privacy } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    authorId: authorId ? parseInt(authorId) : null,
    privacy
  };

  const posts = await AdminService.getPostsList(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "POSTS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return paginated(res, "Posts list retrieved successfully", posts, {
    limit: parseInt(limit),
    offset: parseInt(offset)
  });
});

export const getPostById = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const post = await AdminService.getPostDetails(parseInt(postId));

  await AuditService.logAction({
    userId: req.user.id,
    action: "POST_VIEWED",
    resource: "POST",
    resourceId: parseInt(postId),
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Post details retrieved successfully", post);
});

export const scanPost = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const analysis = await AdminService.scanPostForViolations(parseInt(postId));

  await AuditService.logAction({
    userId: req.user.id,
    action: "POST_SCANNED",
    resource: "POST",
    resourceId: parseInt(postId),
    meta: { riskLevel: analysis.riskLevel, score: analysis.score },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Post scanned successfully", analysis);
});

export const scanAllPosts = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0 } = req.query;
  const results = await AdminService.scanAllPostsForViolations({
    limit: parseInt(limit),
    offset: parseInt(offset)
  });

  await AuditService.logAction({
    userId: req.user.id,
    action: "BULK_POSTS_SCANNED",
    meta: { ...results.summary },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Posts scanned successfully", results);
});

export const hidePostByAdmin = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for hiding is required");
  }

  const updated = await AdminService.hidePost(parseInt(postId), reason, req.user.id);

  await AuditService.logAction({
    userId: req.user.id,
    action: "POST_HIDDEN",
    resource: "POST",
    resourceId: parseInt(postId),
    meta: { reason },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Post hidden successfully", { post: updated });
});

export const deletePostByAdmin = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for deletion is required");
  }

  const deleted = await AdminService.deletePost(parseInt(postId), reason, req.user.id);

  await AuditService.logAction({
    userId: req.user.id,
    action: "POST_DELETED",
    resource: "POST",
    resourceId: parseInt(postId),
    meta: { reason, title: deleted.title },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Post deleted successfully", { post_id: postId });
});

export const getFlaggedPosts = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0 } = req.query;
  const posts = await AdminService.getFlaggedPosts({
    limit: parseInt(limit),
    offset: parseInt(offset)
  });

  await AuditService.logAction({
    userId: req.user.id,
    action: "FLAGGED_POSTS_VIEWED",
    meta: { count: posts.length },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return paginated(res, "Flagged posts retrieved successfully", posts, {
    limit: parseInt(limit),
    offset: parseInt(offset)
  });
});

export const bulkScanPosts = asyncHandler(async (req, res) => {
  const { postIds } = req.body;

  if (!postIds || !Array.isArray(postIds)) {
    return failure(res, "postIds array is required");
  }

  const results = await AdminService.bulkScanPosts(postIds);

  await AuditService.logAction({
    userId: req.user.id,
    action: "BULK_POSTS_SCANNED",
    meta: { count: postIds.length },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Posts scanned successfully", results);
});


// ============================================
// ENHANCED CONTROLLERS WITH PAGINATION TOTAL
// ============================================

// Enhanced Users with total count
export const getUsersWithCount = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, status, role, search } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    status,
    role,
    search
  };

  const result = await AdminService.getUsersListWithCount(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "USERS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Users list retrieved successfully", result);
});

// Enhanced Posts with total count
export const getPostsWithCount = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, authorId, privacy } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    authorId: authorId ? parseInt(authorId) : null,
    privacy
  };

  const result = await AdminService.getPostsListWithCount(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "POSTS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Posts list retrieved successfully", result);
});

// Enhanced Dashboard
export const getEnhancedDashboard = asyncHandler(async (req, res) => {
  const dashboardData = await AdminService.getEnhancedDashboardData();

  await AuditService.logAction({
    userId: req.user.id,
    action: "DASHBOARD_VIEWED",
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Dashboard data retrieved successfully", dashboardData);
});

// ============================================
// REPORT RESOLUTION CONTROLLERS
// ============================================

export const getReportsWithCount = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, status, targetType } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    status,
    targetType
  };

  const result = await AdminService.getReportsWithCount(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "REPORTS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Reports retrieved successfully", result);
});

export const getReportById = asyncHandler(async (req, res) => {
  const { reportId } = req.params;
  const report = await AdminService.getReportDetails(parseInt(reportId));

  await AuditService.logAction({
    userId: req.user.id,
    action: "REPORT_VIEWED",
    resource: "REPORT",
    resourceId: parseInt(reportId),
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Report details retrieved successfully", report);
});

export const resolveReport = asyncHandler(async (req, res) => {
  const { reportId } = req.params;
  const { status, actionTaken, resolutionNote } = req.body;

  if (!status) {
    return failure(res, "Status is required");
  }

  const resolved = await AdminService.resolveReport(
    parseInt(reportId),
    { status, actionTaken, resolutionNote },
    req.user.id
  );

  return success(res, "Report resolved successfully", resolved);
});

export const dismissReport = asyncHandler(async (req, res) => {
  const { reportId } = req.params;
  const { resolutionNote } = req.body;

  const dismissed = await AdminService.dismissReport(
    parseInt(reportId),
    resolutionNote,
    req.user.id
  );

  return success(res, "Report dismissed successfully", dismissed);
});

export const getReportStats = asyncHandler(async (req, res) => {
  const stats = await AdminService.getReportStats();
  return success(res, "Report stats retrieved successfully", stats);
});

// ============================================
// PAYOUT MANAGEMENT CONTROLLERS
// ============================================

export const getPayoutsWithCount = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, status, userId } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    status,
    userId: userId ? parseInt(userId) : null
  };

  const result = await AdminService.getPayoutsListWithCount(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "PAYOUTS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Payouts list retrieved successfully", result);
});

export const getPayoutById = asyncHandler(async (req, res) => {
  const { payoutId } = req.params;
  const payout = await AdminService.getPayoutDetails(parseInt(payoutId));

  await AuditService.logAction({
    userId: req.user.id,
    action: "PAYOUT_VIEWED",
    resource: "PAYOUT",
    resourceId: parseInt(payoutId),
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Payout details retrieved successfully", payout);
});

export const getPayoutStats = asyncHandler(async (req, res) => {
  const stats = await AdminService.getPayoutStats();
  return success(res, "Payout stats retrieved successfully", stats);
});

// ============================================
// COMMENT MODERATION CONTROLLERS
// ============================================

export const getCommentsWithCount = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, postId, authorId } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    postId: postId ? parseInt(postId) : null,
    authorId: authorId ? parseInt(authorId) : null
  };

  const result = await AdminService.getCommentsListWithCount(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "COMMENTS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Comments list retrieved successfully", result);
});

export const getCommentById = asyncHandler(async (req, res) => {
  const { commentId } = req.params;
  const comment = await AdminService.getCommentDetails(parseInt(commentId));

  await AuditService.logAction({
    userId: req.user.id,
    action: "COMMENT_VIEWED",
    resource: "COMMENT",
    resourceId: parseInt(commentId),
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Comment details retrieved successfully", comment);
});

export const scanComment = asyncHandler(async (req, res) => {
  const { commentId } = req.params;
  const analysis = await AdminService.scanCommentForViolations(parseInt(commentId));

  await AuditService.logAction({
    userId: req.user.id,
    action: "COMMENT_SCANNED",
    resource: "COMMENT",
    resourceId: parseInt(commentId),
    meta: { riskLevel: analysis.riskLevel, score: analysis.score },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Comment scanned successfully", analysis);
});

export const getFlaggedComments = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0 } = req.query;
  const result = await AdminService.getFlaggedCommentsWithCount({
    limit: parseInt(limit),
    offset: parseInt(offset)
  });

  await AuditService.logAction({
    userId: req.user.id,
    action: "FLAGGED_COMMENTS_VIEWED",
    meta: { count: result.total },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Flagged comments retrieved successfully", result);
});

export const hideCommentByAdmin = asyncHandler(async (req, res) => {
  const { commentId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for hiding is required");
  }

  const result = await AdminService.hideComment(parseInt(commentId), reason, req.user.id);

  return success(res, "Comment hidden successfully", result);
});

export const deleteCommentByAdmin = asyncHandler(async (req, res) => {
  const { commentId } = req.params;
  const { reason } = req.body;

  if (!reason) {
    return failure(res, "Reason for deletion is required");
  }

  const deleted = await AdminService.deleteComment(parseInt(commentId), reason, req.user.id);

  return success(res, "Comment deleted successfully", { comment_id: commentId });
});

export const bulkScanComments = asyncHandler(async (req, res) => {
  const { commentIds } = req.body;

  if (!commentIds || !Array.isArray(commentIds)) {
    return failure(res, "commentIds array is required");
  }

  const results = await AdminService.bulkScanComments(commentIds);

  await AuditService.logAction({
    userId: req.user.id,
    action: "BULK_COMMENTS_SCANNED",
    meta: { count: commentIds.length },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Comments scanned successfully", results);
});

// ============================================
// TRANSACTION HISTORY CONTROLLERS
// ============================================

export const getTransactions = asyncHandler(async (req, res) => {
  const { limit = 50, offset = 0, userId, type, status } = req.query;
  const filters = {
    limit: parseInt(limit),
    offset: parseInt(offset),
    userId: userId ? parseInt(userId) : null,
    type,
    status
  };

  const result = await AdminService.getTransactionsWithCount(filters);

  await AuditService.logAction({
    userId: req.user.id,
    action: "TRANSACTIONS_LIST_VIEWED",
    meta: { filters },
    ip: req.ip,
    agent: req.get("User-Agent")
  });

  return success(res, "Transactions retrieved successfully", result);
});

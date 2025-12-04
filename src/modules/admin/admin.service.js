import * as AdminRepo from "./admin.repo.js";
import * as AuditRepo from "./audit.repo.js";
import * as PostsRepo from "../posts/posts.repo.js";
import * as CommentsRepo from "../comments/comments.repo.js";

// User management
export async function getUsersList(filters = {}) {
  const { limit = 50, offset = 0, status, role } = filters;

  const users = await AdminRepo.getAllUsers({ limit, offset, status, role });

  // Format user data for response
  return users.map(user => ({
    id: user.id,
    handle: user.handle,
    email: user.email,
    phone: user.phone,
    role: user.role_primary,
    status: user.status,
    created_at: user.created_at,
    updated_at: user.updated_at,
    profile: {
      display_name: user.display_name,
      avatar_url: user.avatar_url
    },
    stats: {
      booking_count: parseInt(user.booking_count),
      post_count: parseInt(user.post_count)
    }
  }));
}

export async function getUserDetails(userId) {
  const user = await AdminRepo.getUserById(userId);

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  // Format user details
  return {
    id: user.id,
    handle: user.handle,
    email: user.email,
    phone: user.phone,
    role: user.role_primary,
    status: user.status,
    created_at: user.created_at,
    updated_at: user.updated_at,
    profile: {
      display_name: user.display_name,
      avatar_url: user.avatar_url,
      bio: user.bio,
      gender: user.gender,
      year_of_birth: user.year_of_birth
    },
    expert_profile: user.specialties ? {
      specialties: user.specialties,
      price_per_session: user.price_per_session,
      rating_avg: user.rating_avg,
      kyc_status: user.kyc_status
    } : null,
    listener_profile: user.listener_intro ? {
      intro: user.listener_intro,
      verified: user.listener_verified
    } : null,
    wallet_balance: user.wallet_balance ? parseFloat(user.wallet_balance) : 0
  };
}

export async function suspendUser(userId, reason, adminId) {
  // Check if user exists
  const user = await AdminRepo.getUserById(userId);
  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  // Update user status
  const updatedUser = await AdminRepo.updateUserStatus(userId, "SUSPENDED", adminId);

  // Log the suspension with reason
  await AuditRepo.logAction({
    userId: adminId,
    action: "USER_SUSPENDED",
    resource: "USER",
    resourceId: userId,
    meta: { reason, previous_status: user.status }
  });

  return updatedUser;
}

export async function activateUser(userId, adminId) {
  // Check if user exists
  const user = await AdminRepo.getUserById(userId);
  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  // Update user status
  const updatedUser = await AdminRepo.updateUserStatus(userId, "ACTIVE", adminId);

  // Log the activation
  await AuditRepo.logAction({
    userId: adminId,
    action: "USER_ACTIVATED",
    resource: "USER",
    resourceId: userId,
    meta: { previous_status: user.status }
  });

  return updatedUser;
}

// Content moderation
export async function getReportedContent(filters = {}) {
  const { limit = 50, offset = 0, status, targetType } = filters;

  const reports = await AdminRepo.getReportedContent({ limit, offset, status, targetType });

  // Format reports for response
  return reports.map(report => ({
    id: report.id,
    target_type: report.target_type,
    target_id: report.target_id,
    reason: report.reason,
    details: report.details,
    created_at: report.created_at,
    reporter: {
      id: report.reporter_id,
      handle: report.reporter_handle,
      display_name: report.reporter_name
    },
    content: report.target_type === 'POST' ? {
      title: report.post_title,
      content: report.post_content
    } : report.target_type === 'COMMENT' ? {
      content: report.comment_content
    } : report.target_type === 'USER' ? {
      handle: report.reported_user_handle
    } : null
  }));
}

export async function hideContent(targetType, targetId, reason, adminId) {
  // Create moderation action
  const action = await AdminRepo.createModerationAction({
    adminId,
    targetType,
    targetId,
    action: "HIDE",
    reason
  });

  // Actually hide the content based on type
  if (targetType === "POST") {
    await PostsRepo.updatePost(targetId, { privacy: "ONLY_ME" });
  } else if (targetType === "COMMENT") {
    await CommentsRepo.deleteComment(targetId);
  }

  return action;
}

export async function deleteContent(targetType, targetId, reason, adminId) {
  // Create moderation action
  const action = await AdminRepo.createModerationAction({
    adminId,
    targetType,
    targetId,
    action: "DELETE",
    reason
  });

  // Actually delete the content based on type
  if (targetType === "POST") {
    await PostsRepo.deletePost(targetId);
  } else if (targetType === "COMMENT") {
    await CommentsRepo.deleteComment(targetId);
  }

  return action;
}

export async function banUser(userId, reason, adminId) {
  // Create moderation action
  const action = await AdminRepo.createModerationAction({
    adminId,
    targetType: "USER",
    targetId: userId,
    action: "BAN",
    reason
  });

  // Update user status
  await AdminRepo.updateUserStatus(userId, "SUSPENDED", adminId);

  return action;
}

// Analytics
export async function getDashboardData() {
  const stats = await AdminRepo.getDashboardStats();

  return {
    users: {
      active_count: parseInt(stats.active_users),
      new_today: parseInt(stats.new_users_today)
    },
    bookings: {
      today: parseInt(stats.bookings_today),
      week: parseInt(stats.bookings_week)
    },
    content: {
      posts_today: parseInt(stats.posts_today)
    },
    moderation: {
      reports_today: parseInt(stats.reports_today)
    },
    revenue: {
      today: parseFloat(stats.revenue_today),
      transactions_today: parseInt(stats.payments_today)
    }
  };
}

export async function getBookingAnalytics({ days = 30 } = {}) {
  const stats = await AdminRepo.getBookingStats({ days });

  return stats.map(stat => ({
    date: stat.date,
    total_bookings: parseInt(stat.total_bookings),
    confirmed_bookings: parseInt(stat.confirmed_bookings),
    cancelled_bookings: parseInt(stat.cancelled_bookings),
    completed_bookings: parseInt(stat.completed_bookings)
  }));
}

export async function getRevenueAnalytics({ days = 30 } = {}) {
  const stats = await AdminRepo.getRevenueStats({ days });

  return stats.map(stat => ({
    date: stat.date,
    transaction_count: parseInt(stat.transaction_count),
    total_revenue: parseFloat(stat.total_revenue)
  }));
}

// Expert management services
export async function getExpertsList({ limit, offset, status, kycStatus }) {
  const { query } = await import("../../config/db.js");

  let whereClause = "WHERE u.role_primary = 'EXPERT'";
  const queryParams = [];
  let paramIndex = 1;

  if (status) {
    whereClause += ` AND u.status = $${paramIndex++}`;
    queryParams.push(status);
  }

  if (kycStatus) {
    whereClause += ` AND ep.kyc_status = $${paramIndex++}`;
    queryParams.push(kycStatus);
  }

  const { rows } = await query(
    `SELECT u.id, u.handle, u.status, u.created_at,
            up.display_name, up.avatar_url,
            ep.specialties, ep.price_per_session, ep.rating_avg, ep.kyc_status, ep.intro
     FROM app.users u
     LEFT JOIN app.user_profiles up ON up.user_id = u.id
     LEFT JOIN app.expert_profiles ep ON ep.user_id = u.id
     ${whereClause}
     ORDER BY u.created_at DESC
     LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...queryParams, limit, offset]
  );

  return rows;
}

export async function approveExpertKYC(expertId, notes, adminId) {
  const { query } = await import("../../config/db.js");

  const { rows } = await query(
    `UPDATE app.expert_profiles
       SET kyc_status = 'VERIFIED'
     WHERE user_id = $1
     RETURNING id, user_id, kyc_status`,
    [expertId]
  );

  // Log the action
  await AuditRepo.logAction({
    userId: adminId,
    action: "EXPERT_KYC_APPROVED",
    resource: "EXPERT",
    resourceId: expertId,
    meta: { notes }
  });

  return rows[0];
}

export async function rejectExpertKYC(expertId, reason, notes, adminId) {
  const { query } = await import("../../config/db.js");

  const { rows } = await query(
    `UPDATE app.expert_profiles
       SET kyc_status = 'REJECTED'
     WHERE user_id = $1
     RETURNING id, user_id, kyc_status`,
    [expertId]
  );

  // Log the action
  await AuditRepo.logAction({
    userId: adminId,
    action: "EXPERT_KYC_REJECTED",
    resource: "EXPERT",
    resourceId: expertId,
    meta: { reason, notes }
  });

  return rows[0];
}

// Booking management services
export async function getAllBookingsList({ limit, offset, status, expertId, userId, dateFrom, dateTo }) {
  const { query } = await import("../../config/db.js");

  let whereClause = "WHERE 1=1";
  const queryParams = [];
  let paramIndex = 1;

  if (status) {
    whereClause += ` AND b.status = $${paramIndex++}`;
    queryParams.push(status);
  }

  if (expertId) {
    whereClause += ` AND b.expert_id = $${paramIndex++}`;
    queryParams.push(expertId);
  }

  if (userId) {
    whereClause += ` AND b.user_id = $${paramIndex++}`;
    queryParams.push(userId);
  }

  if (dateFrom) {
    whereClause += ` AND b.start_at >= $${paramIndex++}`;
    queryParams.push(dateFrom);
  }

  if (dateTo) {
    whereClause += ` AND b.start_at <= $${paramIndex++}`;
    queryParams.push(dateTo);
  }

  const { rows } = await query(
    `SELECT b.*,
            seeker.display_name as seeker_name,
            expert_profile.display_name as expert_name,
            ep.price_per_session
     FROM app.bookings b
     LEFT JOIN app.user_profiles seeker ON seeker.user_id = b.user_id
     LEFT JOIN app.user_profiles expert_profile ON expert_profile.user_id = b.expert_id
     LEFT JOIN app.expert_profiles ep ON ep.user_id = b.expert_id
     ${whereClause}
     ORDER BY b.created_at DESC
     LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...queryParams, limit, offset]
  );

  return rows;
}

export async function updateBookingStatus(bookingId, status, reason, adminId) {
  const { query } = await import("../../config/db.js");

  const { rows } = await query(
    `UPDATE app.bookings
       SET status = $1
     WHERE id = $2
     RETURNING id, user_id, expert_id, status, start_at, end_at`,
    [status, bookingId]
  );

  // Log the action
  await AuditRepo.logAction({
    userId: adminId,
    action: "BOOKING_STATUS_UPDATED",
    resource: "BOOKING",
    resourceId: bookingId,
    meta: { status, reason }
  });

  return rows[0];
}

// System settings services
export async function getSystemSettings() {
  const { query } = await import("../../config/db.js");

  // For now, return some basic system info
  // In a real implementation, you might have a separate settings table
  const { rows: userStats } = await query(
    `SELECT
       COUNT(*) as total_users,
       COUNT(CASE WHEN role_primary = 'EXPERT' THEN 1 END) as total_experts,
       COUNT(CASE WHEN role_primary = 'LISTENER' THEN 1 END) as total_listeners,
       COUNT(CASE WHEN role_primary = 'SEEKER' THEN 1 END) as total_seekers,
       COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) as active_users,
       COUNT(CASE WHEN status = 'SUSPENDED' THEN 1 END) as suspended_users
     FROM app.users`
  );

  const { rows: bookingStats } = await query(
    `SELECT
       COUNT(*) as total_bookings,
       COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending_bookings,
       COUNT(CASE WHEN status = 'CONFIRMED' THEN 1 END) as confirmed_bookings,
       COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_bookings,
       COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled_bookings,
       COALESCE(SUM(price), 0) as total_revenue
     FROM app.bookings`
  );

  const { rows: expertStats } = await query(
    `SELECT
       COUNT(*) as total_experts,
       COUNT(CASE WHEN kyc_status = 'VERIFIED' THEN 1 END) as verified_experts,
       COUNT(CASE WHEN kyc_status = 'PENDING' THEN 1 END) as pending_experts,
       COUNT(CASE WHEN kyc_status = 'REJECTED' THEN 1 END) as rejected_experts,
       COALESCE(AVG(price_per_session), 0) as avg_price_per_session
     FROM app.expert_profiles`
  );

  return {
    users: userStats[0],
    bookings: bookingStats[0],
    experts: expertStats[0],
    system: {
      version: "1.0.0",
      environment: process.env.NODE_ENV || "development",
      uptime: process.uptime()
    }
  };
}

export async function updateSystemSettings(settings, adminId) {
  // For now, this is a placeholder
  // In a real implementation, you would update a settings table
  // For demonstration, we'll just log the action

  // Log the action
  await AuditRepo.logAction({
    userId: adminId,
    action: "SYSTEM_SETTINGS_UPDATED",
    meta: { settings }
  });

  return { updated: true, settings };
}


// Post moderation services
import * as ContentModeration from "./content-moderation.service.js";

export async function getPostsList(filters = {}) {
  const { limit = 50, offset = 0, authorId, privacy } = filters;
  const posts = await AdminRepo.getAllPosts({ limit, offset, authorId, privacy });

  return posts.map(post => ({
    ...post,
    reaction_count: parseInt(post.reaction_count),
    comment_count: parseInt(post.comment_count)
  }));
}

export async function getPostDetails(postId) {
  const post = await AdminRepo.getPostById(postId);

  if (!post) {
    const error = new Error("Post not found");
    error.statusCode = 404;
    throw error;
  }

  // Analyze content for violations
  const analysis = ContentModeration.analyzePost(post);

  return {
    ...post,
    reaction_count: parseInt(post.reaction_count),
    comment_count: parseInt(post.comment_count),
    report_count: parseInt(post.report_count),
    moderation_analysis: analysis
  };
}

export async function scanPostForViolations(postId) {
  const post = await AdminRepo.getPostById(postId);

  if (!post) {
    const error = new Error("Post not found");
    error.statusCode = 404;
    throw error;
  }

  return ContentModeration.analyzePost(post);
}

export async function scanAllPostsForViolations({ limit = 50, offset = 0 } = {}) {
  const posts = await AdminRepo.getPostsForModeration({ limit, offset });

  const results = posts.map(post => {
    const analysis = ContentModeration.analyzePost(post);
    return {
      post_id: post.id,
      title: post.title,
      author: post.author_name || post.author_handle,
      created_at: post.created_at,
      ...analysis
    };
  });

  // Sort by risk score (highest first)
  results.sort((a, b) => b.score - a.score);

  const summary = {
    total_scanned: results.length,
    high_risk: results.filter(r => r.riskLevel === 'HIGH').length,
    medium_risk: results.filter(r => r.riskLevel === 'MEDIUM').length,
    low_risk: results.filter(r => r.riskLevel === 'LOW').length,
    safe: results.filter(r => r.riskLevel === 'SAFE').length
  };

  return { summary, posts: results };
}

export async function hidePost(postId, reason, adminId) {
  const post = await AdminRepo.getPostById(postId);

  if (!post) {
    const error = new Error("Post not found");
    error.statusCode = 404;
    throw error;
  }

  // Change privacy to ONLY_ME (effectively hiding it)
  const updated = await AdminRepo.updatePostPrivacy(postId, 'ONLY_ME', adminId);

  // Create moderation action
  await AdminRepo.createModerationAction({
    adminId,
    targetType: 'POST',
    targetId: postId,
    action: 'HIDE',
    reason
  });

  return updated;
}

export async function deletePost(postId, reason, adminId) {
  const deleted = await AdminRepo.deletePostByAdmin(postId, adminId, reason);

  if (!deleted) {
    const error = new Error("Post not found");
    error.statusCode = 404;
    throw error;
  }

  // Create moderation action
  await AdminRepo.createModerationAction({
    adminId,
    targetType: 'POST',
    targetId: postId,
    action: 'DELETE',
    reason
  });

  return deleted;
}

export async function getFlaggedPosts(filters = {}) {
  const { limit = 50, offset = 0 } = filters;
  const posts = await AdminRepo.getFlaggedPosts({ limit, offset });

  return posts.map(post => {
    const analysis = ContentModeration.analyzePost(post);
    return {
      ...post,
      report_count: parseInt(post.report_count),
      moderation_analysis: analysis
    };
  });
}

export async function bulkScanPosts(postIds) {
  const results = [];

  for (const postId of postIds) {
    try {
      const post = await AdminRepo.getPostById(postId);
      if (post) {
        const analysis = ContentModeration.analyzePost(post);
        results.push({
          post_id: postId,
          title: post.title,
          ...analysis
        });
      }
    } catch (e) {
      results.push({
        post_id: postId,
        error: e.message
      });
    }
  }

  return results;
}


// ============================================
// ENHANCED SERVICES WITH PAGINATION TOTAL
// ============================================

export async function getUsersListWithCount(filters = {}) {
  const { limit = 50, offset = 0, status, role, search } = filters;
  const result = await AdminRepo.getUsersWithCount({ limit, offset, status, role, search });

  return {
    data: result.data.map(user => ({
      id: user.id,
      handle: user.handle,
      email: user.email,
      phone: user.phone,
      role: user.role_primary,
      status: user.status,
      created_at: user.created_at,
      updated_at: user.updated_at,
      profile: {
        display_name: user.display_name,
        avatar_url: user.avatar_url
      },
      stats: {
        booking_count: parseInt(user.booking_count || 0),
        post_count: parseInt(user.post_count || 0)
      }
    })),
    total: result.total,
    limit,
    offset
  };
}

export async function getPostsListWithCount(filters = {}) {
  const { limit = 50, offset = 0, authorId, privacy } = filters;
  const result = await AdminRepo.getPostsWithCount({ limit, offset, authorId, privacy });

  return {
    data: result.data.map(post => ({
      ...post,
      reaction_count: parseInt(post.reaction_count || 0),
      comment_count: parseInt(post.comment_count || 0),
      report_count: parseInt(post.report_count || 0)
    })),
    total: result.total,
    limit,
    offset
  };
}

export async function getReportsWithCount(filters = {}) {
  const { limit = 50, offset = 0, status, targetType } = filters;
  const result = await AdminRepo.getReportsWithCount({ limit, offset, status, targetType });

  return {
    data: result.data.map(report => ({
      id: report.id,
      target_type: report.target_type,
      target_id: report.target_id,
      reason: report.reason,
      details: report.details,
      status: report.status,
      created_at: report.created_at,
      resolved_at: report.resolved_at,
      reporter: {
        id: report.reporter_id,
        handle: report.reporter_handle,
        display_name: report.reporter_name
      },
      resolver: report.resolver_handle ? {
        handle: report.resolver_handle
      } : null,
      content: report.target_type === 'POST' ? {
        title: report.post_title,
        content: report.post_content
      } : report.target_type === 'COMMENT' ? {
        content: report.comment_content
      } : report.target_type === 'USER' ? {
        handle: report.reported_user_handle
      } : null
    })),
    total: result.total,
    limit,
    offset
  };
}

// ============================================
// REPORT RESOLUTION SERVICES
// ============================================

export async function getReportDetails(reportId) {
  const report = await AdminRepo.getReportById(reportId);

  if (!report) {
    const error = new Error("Report not found");
    error.statusCode = 404;
    throw error;
  }

  return report;
}

export async function resolveReport(reportId, { status, actionTaken, resolutionNote }, adminId) {
  const report = await AdminRepo.getReportById(reportId);

  if (!report) {
    const error = new Error("Report not found");
    error.statusCode = 404;
    throw error;
  }

  if (report.status === 'RESOLVED' || report.status === 'DISMISSED') {
    const error = new Error("Report already resolved");
    error.statusCode = 400;
    throw error;
  }

  const resolved = await AdminRepo.resolveReport({
    reportId,
    adminId,
    status,
    actionTaken,
    resolutionNote
  });

  await AuditRepo.logAction({
    userId: adminId,
    action: "REPORT_RESOLVED",
    resource: "REPORT",
    resourceId: reportId,
    meta: { status, actionTaken, resolutionNote }
  });

  return resolved;
}

export async function dismissReport(reportId, resolutionNote, adminId) {
  return resolveReport(reportId, {
    status: 'DISMISSED',
    actionTaken: 'NONE',
    resolutionNote
  }, adminId);
}

export async function getReportStats() {
  const stats = await AdminRepo.getReportStats();
  return {
    pending: parseInt(stats.pending_count || 0),
    in_review: parseInt(stats.in_review_count || 0),
    resolved: parseInt(stats.resolved_count || 0),
    dismissed: parseInt(stats.dismissed_count || 0),
    today: parseInt(stats.today_count || 0),
    this_week: parseInt(stats.week_count || 0)
  };
}

// ============================================
// PAYOUT MANAGEMENT SERVICES
// ============================================

export async function getPayoutsListWithCount(filters = {}) {
  const { limit = 50, offset = 0, status, userId } = filters;
  const result = await AdminRepo.getPayoutsWithCount({ limit, offset, status, userId });

  return {
    data: result.data.map(payout => ({
      id: payout.id,
      user_id: payout.user_id,
      amount: parseFloat(payout.amount),
      status: payout.status,
      created_at: payout.created_at,
      updated_at: payout.updated_at,
      admin_note: payout.admin_note,
      user: {
        handle: payout.user_handle,
        display_name: payout.user_name
      },
      bank_account: {
        bank_name: payout.bank_name,
        account_number: payout.account_number,
        account_holder: payout.account_holder
      },
      current_wallet_balance: parseFloat(payout.current_wallet_balance || 0)
    })),
    total: result.total,
    limit,
    offset
  };
}

export async function getPayoutDetails(payoutId) {
  const payout = await AdminRepo.getPayoutById(payoutId);

  if (!payout) {
    const error = new Error("Payout request not found");
    error.statusCode = 404;
    throw error;
  }

  return {
    id: payout.id,
    user_id: payout.user_id,
    amount: parseFloat(payout.amount),
    status: payout.status,
    created_at: payout.created_at,
    updated_at: payout.updated_at,
    admin_note: payout.admin_note,
    user: {
      handle: payout.user_handle,
      email: payout.user_email,
      display_name: payout.user_name
    },
    bank_account: {
      bank_name: payout.bank_name,
      account_number: payout.account_number,
      account_holder: payout.account_holder
    },
    current_wallet_balance: parseFloat(payout.current_wallet_balance || 0)
  };
}

export async function getPayoutStats() {
  const stats = await AdminRepo.getPayoutStats();
  return {
    pending: {
      count: parseInt(stats.pending_count || 0),
      amount: parseFloat(stats.pending_amount || 0)
    },
    approved: {
      count: parseInt(stats.approved_count || 0),
      amount: parseFloat(stats.approved_amount || 0)
    },
    rejected: {
      count: parseInt(stats.rejected_count || 0)
    },
    today: {
      count: parseInt(stats.today_count || 0),
      amount: parseFloat(stats.today_amount || 0)
    }
  };
}

// ============================================
// COMMENT MODERATION SERVICES
// ============================================

export async function getCommentsListWithCount(filters = {}) {
  const { limit = 50, offset = 0, postId, authorId } = filters;
  const result = await AdminRepo.getCommentsWithCount({ limit, offset, postId, authorId });

  return {
    data: result.data.map(comment => {
      const analysis = ContentModeration.analyzeContent(comment.content);
      return {
        ...comment,
        report_count: parseInt(comment.report_count || 0),
        moderation_analysis: analysis
      };
    }),
    total: result.total,
    limit,
    offset
  };
}

export async function getCommentDetails(commentId) {
  const comment = await AdminRepo.getCommentById(commentId);

  if (!comment) {
    const error = new Error("Comment not found");
    error.statusCode = 404;
    throw error;
  }

  const analysis = ContentModeration.analyzeContent(comment.content);

  return {
    ...comment,
    report_count: parseInt(comment.report_count || 0),
    moderation_analysis: analysis
  };
}

export async function scanCommentForViolations(commentId) {
  const comment = await AdminRepo.getCommentById(commentId);

  if (!comment) {
    const error = new Error("Comment not found");
    error.statusCode = 404;
    throw error;
  }

  return ContentModeration.analyzeContent(comment.content);
}

export async function getFlaggedCommentsWithCount(filters = {}) {
  const { limit = 50, offset = 0 } = filters;
  const result = await AdminRepo.getFlaggedComments({ limit, offset });

  return {
    data: result.data.map(comment => {
      const analysis = ContentModeration.analyzeContent(comment.content);
      return {
        ...comment,
        report_count: parseInt(comment.report_count || 0),
        moderation_analysis: analysis
      };
    }),
    total: result.total,
    limit,
    offset
  };
}

export async function hideComment(commentId, reason, adminId) {
  const comment = await AdminRepo.getCommentById(commentId);

  if (!comment) {
    const error = new Error("Comment not found");
    error.statusCode = 404;
    throw error;
  }

  // Create moderation action
  await AdminRepo.createModerationAction({
    adminId,
    targetType: 'COMMENT',
    targetId: commentId,
    action: 'HIDE',
    reason
  });

  await AuditRepo.logAction({
    userId: adminId,
    action: "COMMENT_HIDDEN",
    resource: "COMMENT",
    resourceId: commentId,
    meta: { reason }
  });

  return { hidden: true, comment_id: commentId };
}

export async function deleteComment(commentId, reason, adminId) {
  const comment = await AdminRepo.getCommentById(commentId);

  if (!comment) {
    const error = new Error("Comment not found");
    error.statusCode = 404;
    throw error;
  }

  const deleted = await AdminRepo.deleteCommentByAdmin(commentId);

  // Create moderation action
  await AdminRepo.createModerationAction({
    adminId,
    targetType: 'COMMENT',
    targetId: commentId,
    action: 'DELETE',
    reason
  });

  await AuditRepo.logAction({
    userId: adminId,
    action: "COMMENT_DELETED",
    resource: "COMMENT",
    resourceId: commentId,
    meta: { reason, content: comment.content?.substring(0, 100) }
  });

  return deleted;
}

export async function bulkScanComments(commentIds) {
  const results = [];

  for (const commentId of commentIds) {
    try {
      const comment = await AdminRepo.getCommentById(commentId);
      if (comment) {
        const analysis = ContentModeration.analyzeContent(comment.content);
        results.push({
          comment_id: commentId,
          content_preview: comment.content?.substring(0, 100),
          ...analysis
        });
      }
    } catch (e) {
      results.push({
        comment_id: commentId,
        error: e.message
      });
    }
  }

  return results;
}

// ============================================
// TRANSACTION HISTORY SERVICES
// ============================================

export async function getTransactionsWithCount(filters = {}) {
  const { limit = 50, offset = 0, userId, type, status } = filters;
  const result = await AdminRepo.getTransactionsWithCount({ limit, offset, userId, type, status });

  return {
    data: result.data.map(tx => ({
      ...tx,
      amount: parseFloat(tx.amount || 0)
    })),
    total: result.total,
    limit,
    offset
  };
}

// ============================================
// ENHANCED DASHBOARD
// ============================================

export async function getEnhancedDashboardData() {
  const [basicStats, reportStats, payoutStats] = await Promise.all([
    AdminRepo.getDashboardStats(),
    AdminRepo.getReportStats(),
    AdminRepo.getPayoutStats()
  ]);

  return {
    users: {
      active_count: parseInt(basicStats.active_users || 0),
      new_today: parseInt(basicStats.new_users_today || 0)
    },
    bookings: {
      today: parseInt(basicStats.bookings_today || 0),
      week: parseInt(basicStats.bookings_week || 0)
    },
    content: {
      posts_today: parseInt(basicStats.posts_today || 0)
    },
    moderation: {
      reports_today: parseInt(basicStats.reports_today || 0),
      pending_reports: parseInt(reportStats.pending_count || 0),
      in_review_reports: parseInt(reportStats.in_review_count || 0)
    },
    revenue: {
      today: parseFloat(basicStats.revenue_today || 0),
      transactions_today: parseInt(basicStats.payments_today || 0)
    },
    payouts: {
      pending_count: parseInt(payoutStats.pending_count || 0),
      pending_amount: parseFloat(payoutStats.pending_amount || 0),
      today_count: parseInt(payoutStats.today_count || 0),
      today_amount: parseFloat(payoutStats.today_amount || 0)
    }
  };
}

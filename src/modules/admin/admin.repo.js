import { query } from "../../config/db.js";

// User management
export async function getAllUsers({ limit = 50, offset = 0, status, role } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (status) {
    whereClause += ` AND u.status = $${paramIndex++}`;
    params.push(status);
  }

  if (role) {
    whereClause += ` AND u.role_primary = $${paramIndex++}`;
    params.push(role);
  }

  const { rows } = await query(
    `SELECT u.id, u.handle, u.email, u.phone, u.role_primary, u.status, 
            u.created_at, u.updated_at,
            up.display_name, up.avatar_url,
            COUNT(DISTINCT b.id) as booking_count,
            COUNT(DISTINCT p.id) as post_count
     FROM app.users u
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.bookings b ON u.id = b.user_id
     LEFT JOIN app.posts p ON u.id = p.author_id
     ${whereClause}
     GROUP BY u.id, up.display_name, up.avatar_url
     ORDER BY u.created_at DESC
     LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );

  return rows;
}

export async function getUserById(userId) {
  const { rows } = await query(
    `SELECT u.*, up.display_name, up.avatar_url, up.bio, up.gender, up.year_of_birth,
            ep.specialties, ep.price_per_session, ep.rating_avg, ep.kyc_status,
            lp.intro as listener_intro, lp.verified as listener_verified,
            w.balance as wallet_balance
     FROM app.users u
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.expert_profiles ep ON u.id = ep.user_id
     LEFT JOIN app.listener_profiles lp ON u.id = lp.user_id
     LEFT JOIN app.wallets w ON u.id = w.owner_user_id
     WHERE u.id = $1`,
    [userId]
  );
  return rows[0];
}

export async function updateUserStatus(userId, status, adminId) {
  const { rows } = await query(
    `UPDATE app.users SET status = $1, updated_at = now() WHERE id = $2 RETURNING id, status, updated_at`,
    [status, userId]
  );
  await query(
    `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
    [adminId, "USER_STATUS_UPDATE", "USER", userId, JSON.stringify({ new_status: status })]
  );
  return rows[0];
}

// Update user info by admin
export async function updateUserByAdmin(userId, updates, adminId) {
  const allowedFields = ['email', 'phone', 'handle', 'role_primary'];
  const setClauses = [];
  const params = [userId];
  let paramIndex = 2;

  for (const [key, value] of Object.entries(updates)) {
    if (allowedFields.includes(key) && value !== undefined) {
      setClauses.push(`${key} = $${paramIndex++}`);
      params.push(value);
    }
  }

  if (setClauses.length === 0) {
    return null;
  }

  setClauses.push('updated_at = now()');

  const { rows } = await query(
    `UPDATE app.users SET ${setClauses.join(', ')} WHERE id = $1 RETURNING *`,
    params
  );

  if (rows[0]) {
    await query(
      `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
      [adminId, "USER_UPDATED", "USER", userId, JSON.stringify({ updates })]
    );
  }

  return rows[0];
}

// Update user profile by admin
export async function updateUserProfileByAdmin(userId, updates, adminId) {
  const allowedFields = ['display_name', 'bio', 'gender', 'year_of_birth', 'avatar_url'];
  const setClauses = [];
  const params = [userId];
  let paramIndex = 2;

  for (const [key, value] of Object.entries(updates)) {
    if (allowedFields.includes(key) && value !== undefined) {
      setClauses.push(`${key} = $${paramIndex++}`);
      params.push(value);
    }
  }

  if (setClauses.length === 0) {
    return null;
  }

  const { rows } = await query(
    `UPDATE app.user_profiles SET ${setClauses.join(', ')} WHERE user_id = $1 RETURNING *`,
    params
  );

  if (rows[0]) {
    await query(
      `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
      [adminId, "USER_PROFILE_UPDATED", "USER", userId, JSON.stringify({ updates })]
    );
  }

  return rows[0];
}

// Delete user by admin (soft delete - change status to DELETED)
export async function deleteUserByAdmin(userId, adminId, reason) {
  // Get user info before delete
  const { rows: userRows } = await query(`SELECT * FROM app.users WHERE id = $1`, [userId]);
  if (userRows.length === 0) return null;

  // Soft delete - change status to DELETED
  const { rows } = await query(
    `UPDATE app.users SET status = 'DELETED', updated_at = now() WHERE id = $1 RETURNING id, status, updated_at`,
    [userId]
  );

  // Log the deletion
  await query(
    `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
    [adminId, "USER_DELETED", "USER", userId, JSON.stringify({ reason, user_email: userRows[0].email, user_handle: userRows[0].handle })]
  );

  return rows[0];
}

// Hard delete user (permanently remove - use with caution)
export async function hardDeleteUserByAdmin(userId, adminId, reason) {
  // Get user info before delete
  const { rows: userRows } = await query(`SELECT * FROM app.users WHERE id = $1`, [userId]);
  if (userRows.length === 0) return null;

  // Delete related data first (cascade)
  await query(`DELETE FROM app.user_profiles WHERE user_id = $1`, [userId]);
  await query(`DELETE FROM app.wallets WHERE owner_user_id = $1`, [userId]);
  await query(`DELETE FROM app.expert_profiles WHERE user_id = $1`, [userId]);
  await query(`DELETE FROM app.listener_profiles WHERE user_id = $1`, [userId]);

  // Delete user
  await query(`DELETE FROM app.users WHERE id = $1`, [userId]);

  // Log the deletion
  await query(
    `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
    [adminId, "USER_HARD_DELETED", "USER", userId, JSON.stringify({ reason, user_email: userRows[0].email, user_handle: userRows[0].handle })]
  );

  return userRows[0];
}


// Content moderation
export async function getReportedContent({ limit = 50, offset = 0, status, targetType } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (status) {
    whereClause += ` AND r.status = $${paramIndex++}`;
    params.push(status);
  }
  if (targetType) {
    whereClause += ` AND r.target_type = $${paramIndex++}`;
    params.push(targetType);
  }

  const { rows } = await query(
    `SELECT r.*, reporter.handle as reporter_handle, reporter_profile.display_name as reporter_name,
            target_post.title as post_title, target_post.content as post_content,
            target_comment.content as comment_content, target_user.handle as reported_user_handle
     FROM app.reports r
     LEFT JOIN app.users reporter ON r.reporter_id = reporter.id
     LEFT JOIN app.user_profiles reporter_profile ON reporter.id = reporter_profile.user_id
     LEFT JOIN app.posts target_post ON r.target_type = 'POST' AND r.target_id = target_post.id
     LEFT JOIN app.comments target_comment ON r.target_type = 'COMMENT' AND r.target_id = target_comment.id
     LEFT JOIN app.users target_user ON r.target_type = 'USER' AND r.target_id = target_user.id
     ${whereClause} ORDER BY r.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return rows;
}

export async function createModerationAction({ adminId, targetType, targetId, action, reason }) {
  const { rows } = await query(
    `INSERT INTO app.moderation_actions (admin_id, target_type, target_id, action, reason, created_at) VALUES ($1, $2, $3, $4, $5, now()) RETURNING *`,
    [adminId, targetType, targetId, action, reason]
  );
  await query(
    `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
    [adminId, "MODERATION_ACTION", targetType, targetId, JSON.stringify({ action, reason })]
  );
  return rows[0];
}

// Analytics
export async function getDashboardStats() {
  const { rows } = await query(
    `SELECT 
        (SELECT COUNT(*) FROM app.users WHERE status = 'ACTIVE') as active_users,
        (SELECT COUNT(*) FROM app.users WHERE created_at >= CURRENT_DATE) as new_users_today,
        (SELECT COUNT(*) FROM app.bookings WHERE status = 'CONFIRMED' AND start_at >= CURRENT_DATE) as bookings_today,
        (SELECT COUNT(*) FROM app.bookings WHERE status = 'CONFIRMED' AND start_at >= CURRENT_DATE - INTERVAL '7 days') as bookings_week,
        (SELECT COUNT(*) FROM app.posts WHERE created_at >= CURRENT_DATE) as posts_today,
        (SELECT COUNT(*) FROM app.reports WHERE created_at >= CURRENT_DATE) as reports_today,
        (SELECT COUNT(*) FROM app.payment_intents WHERE status = 'PAID' AND created_at >= CURRENT_DATE) as payments_today,
        (SELECT COALESCE(SUM(amount), 0) FROM app.payment_intents WHERE status = 'PAID' AND created_at >= CURRENT_DATE) as revenue_today`
  );
  return rows[0];
}

export async function getBookingStats({ days = 30 } = {}) {
  const { rows } = await query(
    `SELECT DATE(created_at) as date, COUNT(*) as total_bookings,
            COUNT(CASE WHEN status = 'CONFIRMED' THEN 1 END) as confirmed_bookings,
            COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled_bookings,
            COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_bookings
     FROM app.bookings WHERE created_at >= CURRENT_DATE - INTERVAL '${days} days'
     GROUP BY DATE(created_at) ORDER BY date DESC`
  );
  return rows;
}

export async function getRevenueStats({ days = 30 } = {}) {
  const { rows } = await query(
    `SELECT DATE(created_at) as date, COUNT(*) as transaction_count, COALESCE(SUM(amount), 0) as total_revenue
     FROM app.payment_intents WHERE status = 'PAID' AND created_at >= CURRENT_DATE - INTERVAL '${days} days'
     GROUP BY DATE(created_at) ORDER BY date DESC`
  );
  return rows;
}


// Post moderation
export async function getAllPosts({ limit = 50, offset = 0, authorId, privacy } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (authorId) {
    whereClause += ` AND p.author_id = $${paramIndex++}`;
    params.push(authorId);
  }
  if (privacy) {
    whereClause += ` AND p.privacy = $${paramIndex++}`;
    params.push(privacy);
  }

  const { rows } = await query(
    `SELECT p.id, p.author_id, p.title, p.content, p.tags, p.privacy, p.anonymous, p.created_at, p.updated_at,
            u.handle as author_handle, up.display_name as author_name,
            (SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id) as reaction_count,
            (SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id) as comment_count
     FROM app.posts p JOIN app.users u ON p.author_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     ${whereClause} ORDER BY p.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return rows;
}

export async function getPostById(postId) {
  const { rows } = await query(
    `SELECT p.*, u.handle as author_handle, u.email as author_email, up.display_name as author_name, up.avatar_url as author_avatar,
            (SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id) as reaction_count,
            (SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id) as comment_count,
            (SELECT COUNT(*) FROM app.reports r WHERE r.target_type = 'POST' AND r.target_id = p.id) as report_count
     FROM app.posts p JOIN app.users u ON p.author_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id WHERE p.id = $1`,
    [postId]
  );
  return rows[0];
}

export async function updatePostPrivacy(postId, privacy, adminId) {
  const { rows } = await query(
    `UPDATE app.posts SET privacy = $1, updated_at = now() WHERE id = $2 RETURNING id, privacy, updated_at`,
    [privacy, postId]
  );
  await query(
    `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
    [adminId, "POST_PRIVACY_UPDATE", "POST", postId, JSON.stringify({ new_privacy: privacy })]
  );
  return rows[0];
}

export async function deletePostByAdmin(postId, adminId, reason) {
  const { rows: postRows } = await query(`SELECT * FROM app.posts WHERE id = $1`, [postId]);
  if (postRows.length === 0) return null;
  await query(`DELETE FROM app.posts WHERE id = $1`, [postId]);
  await query(
    `INSERT INTO app.audit_logs (user_id, action, resource, resource_id, meta, created_at) VALUES ($1, $2, $3, $4, $5::jsonb, now())`,
    [adminId, "POST_DELETED", "POST", postId, JSON.stringify({ reason, post_title: postRows[0].title })]
  );
  return postRows[0];
}

export async function getFlaggedPosts({ limit = 50, offset = 0 } = {}) {
  const { rows } = await query(
    `SELECT p.id, p.author_id, p.title, p.content, p.tags, p.privacy, p.created_at, p.updated_at,
            u.handle as author_handle, up.display_name as author_name,
            COUNT(r.id) as report_count, array_agg(DISTINCT r.reason) as report_reasons
     FROM app.posts p JOIN app.users u ON p.author_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     JOIN app.reports r ON r.target_type = 'POST' AND r.target_id = p.id
     GROUP BY p.id, u.handle, up.display_name ORDER BY report_count DESC, p.created_at DESC LIMIT $1 OFFSET $2`,
    [limit, offset]
  );
  return rows;
}

export async function getPostsForModeration({ limit = 50, offset = 0 } = {}) {
  const { rows } = await query(
    `SELECT p.id, p.author_id, p.title, p.content, p.tags, p.privacy, p.created_at, p.updated_at,
            u.handle as author_handle, up.display_name as author_name,
            (SELECT COUNT(*) FROM app.reports r WHERE r.target_type = 'POST' AND r.target_id = p.id) as report_count
     FROM app.posts p JOIN app.users u ON p.author_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     WHERE p.privacy = 'PUBLIC' ORDER BY p.created_at DESC LIMIT $1 OFFSET $2`,
    [limit, offset]
  );
  return rows;
}


// ============================================
// PAGINATION WITH TOTAL COUNT
// ============================================

export async function getUsersWithCount({ limit = 50, offset = 0, status, role, search } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (status) {
    whereClause += ` AND u.status = $${paramIndex++}`;
    params.push(status);
  }
  if (role) {
    whereClause += ` AND u.role_primary = $${paramIndex++}`;
    params.push(role);
  }
  if (search) {
    whereClause += ` AND (u.handle ILIKE $${paramIndex} OR u.email ILIKE $${paramIndex} OR up.display_name ILIKE $${paramIndex++})`;
    params.push(`%${search}%`);
  }

  const countResult = await query(
    `SELECT COUNT(DISTINCT u.id) as total FROM app.users u LEFT JOIN app.user_profiles up ON u.id = up.user_id ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].total);

  const { rows } = await query(
    `SELECT u.id, u.handle, u.email, u.phone, u.role_primary, u.status, u.created_at, u.updated_at,
            up.display_name, up.avatar_url,
            COUNT(DISTINCT b.id) as booking_count, COUNT(DISTINCT p.id) as post_count
     FROM app.users u LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.bookings b ON u.id = b.user_id LEFT JOIN app.posts p ON u.id = p.author_id
     ${whereClause} GROUP BY u.id, up.display_name, up.avatar_url ORDER BY u.created_at DESC
     LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return { data: rows, total };
}

export async function getPostsWithCount({ limit = 50, offset = 0, authorId, privacy } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (authorId) {
    whereClause += ` AND p.author_id = $${paramIndex++}`;
    params.push(authorId);
  }
  if (privacy) {
    whereClause += ` AND p.privacy = $${paramIndex++}`;
    params.push(privacy);
  }

  const countResult = await query(`SELECT COUNT(*) as total FROM app.posts p ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].total);

  const { rows } = await query(
    `SELECT p.id, p.author_id, p.title, p.content, p.tags, p.privacy, p.anonymous, p.created_at, p.updated_at,
            u.handle as author_handle, up.display_name as author_name,
            (SELECT COUNT(*) FROM app.reports r WHERE r.target_type = 'POST' AND r.target_id = p.id) as report_count,
            (SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id) as reaction_count,
            (SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id) as comment_count
     FROM app.posts p JOIN app.users u ON p.author_id = u.id LEFT JOIN app.user_profiles up ON u.id = up.user_id
     ${whereClause} ORDER BY p.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return { data: rows, total };
}

export async function getReportsWithCount({ limit = 50, offset = 0, status, targetType } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (status) {
    whereClause += ` AND r.status = $${paramIndex++}`;
    params.push(status);
  }
  if (targetType) {
    whereClause += ` AND r.target_type = $${paramIndex++}`;
    params.push(targetType);
  }

  const countResult = await query(`SELECT COUNT(*) as total FROM app.reports r ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].total);

  const { rows } = await query(
    `SELECT r.*, reporter.handle as reporter_handle, reporter_profile.display_name as reporter_name,
            target_post.title as post_title, target_post.content as post_content,
            target_comment.content as comment_content, target_user.handle as reported_user_handle,
            resolver.handle as resolver_handle
     FROM app.reports r
     LEFT JOIN app.users reporter ON r.reporter_id = reporter.id
     LEFT JOIN app.user_profiles reporter_profile ON reporter.id = reporter_profile.user_id
     LEFT JOIN app.posts target_post ON r.target_type = 'POST' AND r.target_id = target_post.id
     LEFT JOIN app.comments target_comment ON r.target_type = 'COMMENT' AND r.target_id = target_comment.id
     LEFT JOIN app.users target_user ON r.target_type = 'USER' AND r.target_id = target_user.id
     LEFT JOIN app.users resolver ON r.resolved_by = resolver.id
     ${whereClause} ORDER BY r.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return { data: rows, total };
}


// ============================================
// REPORT RESOLUTION
// ============================================

export async function getReportById(reportId) {
  const { rows } = await query(
    `SELECT r.*, reporter.handle as reporter_handle, reporter_profile.display_name as reporter_name,
            target_post.title as post_title, target_post.content as post_content, target_post.author_id as post_author_id,
            target_comment.content as comment_content, target_comment.author_id as comment_author_id,
            target_user.handle as reported_user_handle
     FROM app.reports r
     LEFT JOIN app.users reporter ON r.reporter_id = reporter.id
     LEFT JOIN app.user_profiles reporter_profile ON reporter.id = reporter_profile.user_id
     LEFT JOIN app.posts target_post ON r.target_type = 'POST' AND r.target_id = target_post.id
     LEFT JOIN app.comments target_comment ON r.target_type = 'COMMENT' AND r.target_id = target_comment.id
     LEFT JOIN app.users target_user ON r.target_type = 'USER' AND r.target_id = target_user.id
     WHERE r.id = $1`,
    [reportId]
  );
  return rows[0];
}

export async function resolveReport({ reportId, adminId, status, actionTaken, resolutionNote }) {
  const { rows } = await query(
    `UPDATE app.reports SET status = $1, resolved_by = $2, resolved_at = now(), action_taken = $3, resolution_note = $4 WHERE id = $5 RETURNING *`,
    [status, adminId, actionTaken, resolutionNote, reportId]
  );
  return rows[0];
}

export async function getReportStats() {
  const { rows } = await query(
    `SELECT COUNT(*) FILTER (WHERE status = 'PENDING') as pending_count,
            COUNT(*) FILTER (WHERE status = 'IN_REVIEW') as in_review_count,
            COUNT(*) FILTER (WHERE status = 'RESOLVED') as resolved_count,
            COUNT(*) FILTER (WHERE status = 'DISMISSED') as dismissed_count,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_count,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as week_count
     FROM app.reports`
  );
  return rows[0];
}

// ============================================
// PAYOUT MANAGEMENT
// ============================================

export async function getPayoutsWithCount({ limit = 50, offset = 0, status, userId } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (status) {
    whereClause += ` AND pr.status = $${paramIndex++}`;
    params.push(status);
  }
  if (userId) {
    whereClause += ` AND pr.user_id = $${paramIndex++}`;
    params.push(userId);
  }

  const countResult = await query(`SELECT COUNT(*) as total FROM app.payout_requests pr ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].total);

  const { rows } = await query(
    `SELECT pr.*, u.handle as user_handle, up.display_name as user_name,
            pa.bank_name, pa.account_number, pa.account_holder,
            w.balance as current_wallet_balance
     FROM app.payout_requests pr JOIN app.users u ON pr.user_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.payout_accounts pa ON pr.payout_account_id = pa.id
     LEFT JOIN app.wallets w ON pr.user_id = w.owner_user_id
     ${whereClause} ORDER BY pr.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return { data: rows, total };
}

export async function getPayoutById(payoutId) {
  const { rows } = await query(
    `SELECT pr.*, u.handle as user_handle, u.email as user_email, up.display_name as user_name,
            pa.bank_name, pa.account_number, pa.account_holder,
            w.balance as current_wallet_balance
     FROM app.payout_requests pr JOIN app.users u ON pr.user_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.payout_accounts pa ON pr.payout_account_id = pa.id
     LEFT JOIN app.wallets w ON pr.user_id = w.owner_user_id WHERE pr.id = $1`,
    [payoutId]
  );
  return rows[0];
}

export async function getPayoutStats() {
  const { rows } = await query(
    `SELECT COUNT(*) FILTER (WHERE status = 'PENDING') as pending_count,
            COUNT(*) FILTER (WHERE status = 'APPROVED') as approved_count,
            COUNT(*) FILTER (WHERE status = 'REJECTED') as rejected_count,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PENDING'), 0) as pending_amount,
            COALESCE(SUM(amount) FILTER (WHERE status = 'APPROVED'), 0) as approved_amount,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_count,
            COALESCE(SUM(amount) FILTER (WHERE created_at >= CURRENT_DATE), 0) as today_amount
     FROM app.payout_requests`
  );
  return rows[0];
}


// ============================================
// COMMENT MODERATION
// ============================================

export async function getCommentsWithCount({ limit = 50, offset = 0, postId, authorId } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (postId) {
    whereClause += ` AND c.post_id = $${paramIndex++}`;
    params.push(postId);
  }
  if (authorId) {
    whereClause += ` AND c.author_id = $${paramIndex++}`;
    params.push(authorId);
  }

  const countResult = await query(`SELECT COUNT(*) as total FROM app.comments c ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].total);

  const { rows } = await query(
    `SELECT c.*, u.handle as author_handle, up.display_name as author_name, p.title as post_title,
            (SELECT COUNT(*) FROM app.reports r WHERE r.target_type = 'COMMENT' AND r.target_id = c.id) as report_count
     FROM app.comments c JOIN app.users u ON c.author_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id LEFT JOIN app.posts p ON c.post_id = p.id
     ${whereClause} ORDER BY c.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return { data: rows, total };
}

export async function getCommentById(commentId) {
  const { rows } = await query(
    `SELECT c.*, u.handle as author_handle, u.email as author_email, up.display_name as author_name,
            p.title as post_title, p.id as post_id,
            (SELECT COUNT(*) FROM app.reports r WHERE r.target_type = 'COMMENT' AND r.target_id = c.id) as report_count
     FROM app.comments c JOIN app.users u ON c.author_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id LEFT JOIN app.posts p ON c.post_id = p.id WHERE c.id = $1`,
    [commentId]
  );
  return rows[0];
}

export async function getFlaggedComments({ limit = 50, offset = 0 } = {}) {
  const countResult = await query(
    `SELECT COUNT(DISTINCT c.id) as total FROM app.comments c
     JOIN app.reports r ON r.target_type = 'COMMENT' AND r.target_id = c.id`
  );
  const total = parseInt(countResult.rows[0].total);

  const { rows } = await query(
    `SELECT c.*, u.handle as author_handle, up.display_name as author_name, p.title as post_title,
            COUNT(r.id) as report_count, array_agg(DISTINCT r.reason) as report_reasons
     FROM app.comments c JOIN app.users u ON c.author_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id LEFT JOIN app.posts p ON c.post_id = p.id
     JOIN app.reports r ON r.target_type = 'COMMENT' AND r.target_id = c.id
     GROUP BY c.id, u.handle, up.display_name, p.title ORDER BY COUNT(r.id) DESC, c.created_at DESC LIMIT $1 OFFSET $2`,
    [limit, offset]
  );
  return { data: rows, total };
}

export async function deleteCommentByAdmin(commentId) {
  const { rows } = await query(`DELETE FROM app.comments WHERE id = $1 RETURNING *`, [commentId]);
  return rows[0];
}

// ============================================
// TRANSACTION HISTORY
// ============================================

export async function getTransactionsWithCount({ limit = 50, offset = 0, userId, type } = {}) {
  let whereClause = "WHERE 1=1";
  const params = [];
  let paramIndex = 1;

  if (userId) {
    whereClause += ` AND wt.wallet_id IN (SELECT id FROM app.wallets WHERE owner_user_id = $${paramIndex++})`;
    params.push(userId);
  }
  if (type) {
    whereClause += ` AND wt.tx_type = $${paramIndex++}`;
    params.push(type);
  }

  const countResult = await query(`SELECT COUNT(*) as total FROM app.wallet_ledger wt ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].total);

  const { rows } = await query(
    `SELECT wt.*, w.owner_user_id, u.handle as user_handle, up.display_name as user_name
     FROM app.wallet_ledger wt JOIN app.wallets w ON wt.wallet_id = w.id
     JOIN app.users u ON w.owner_user_id = u.id LEFT JOIN app.user_profiles up ON u.id = up.user_id
     ${whereClause} ORDER BY wt.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
    [...params, limit, offset]
  );
  return { data: rows, total };
}

// =============================================
// ADMIN EXTENDED CONTROLLERS
// Refunds, Disputes, Reviews, Chat Management
// =============================================

import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, failure } from "../../utils/response.js";
import * as AuditService from "./audit.repo.js";
import * as RefundsRepo from "../refunds/refunds.repo.js";
import * as DisputesRepo from "../disputes/disputes.repo.js";
import * as PayoutsRepo from "../payouts/payouts.repo.js";
import { query } from "../../config/db.js";

// ============================================
// PAYOUT APPROVAL/REJECTION
// ============================================

export const approvePayoutByAdmin = asyncHandler(async (req, res) => {
    const { payoutId } = req.params;
    const { adminNote } = req.body;

    const payout = await PayoutsRepo.getRequestById(parseInt(payoutId));
    if (!payout) {
        return failure(res, "Payout request not found", 404);
    }

    if (payout.status !== 'PENDING') {
        return failure(res, `Cannot approve payout with status: ${payout.status}`, 400);
    }

    const updated = await PayoutsRepo.updateStatus({
        id: parseInt(payoutId),
        status: 'APPROVED',
        adminNote
    });

    await AuditService.logAction({
        userId: req.user.id,
        action: "PAYOUT_APPROVED",
        resource: "PAYOUT",
        resourceId: parseInt(payoutId),
        meta: { amount: payout.amount, adminNote },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Payout approved successfully", updated);
});

export const rejectPayoutByAdmin = asyncHandler(async (req, res) => {
    const { payoutId } = req.params;
    const { adminNote, reason } = req.body;

    if (!reason) {
        return failure(res, "Reason for rejection is required", 400);
    }

    const payout = await PayoutsRepo.getRequestById(parseInt(payoutId));
    if (!payout) {
        return failure(res, "Payout request not found", 404);
    }

    if (payout.status !== 'PENDING') {
        return failure(res, `Cannot reject payout with status: ${payout.status}`, 400);
    }

    const updated = await PayoutsRepo.updateStatus({
        id: parseInt(payoutId),
        status: 'REJECTED',
        adminNote: adminNote || reason
    });

    await AuditService.logAction({
        userId: req.user.id,
        action: "PAYOUT_REJECTED",
        resource: "PAYOUT",
        resourceId: parseInt(payoutId),
        meta: { amount: payout.amount, reason, adminNote },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Payout rejected successfully", updated);
});

// ============================================
// REFUND MANAGEMENT
// ============================================

export const getRefundsWithCount = asyncHandler(async (req, res) => {
    const { limit = 50, offset = 0, status } = req.query;

    const refunds = await RefundsRepo.listAllRefunds({
        status,
        limit: parseInt(limit),
        offset: parseInt(offset)
    });

    // Get total count
    const countResult = await query(
        `SELECT COUNT(*) as total FROM app.refunds ${status ? 'WHERE status = $1' : ''}`,
        status ? [status] : []
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "REFUNDS_LIST_VIEWED",
        meta: { status, limit, offset },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Refunds retrieved successfully", {
        data: refunds,
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit),
        offset: parseInt(offset)
    });
});

export const getRefundStats = asyncHandler(async (req, res) => {
    const { rows } = await query(`
        SELECT 
            COUNT(*) FILTER (WHERE status = 'PENDING') as pending_count,
            COUNT(*) FILTER (WHERE status = 'COMPLETED') as completed_count,
            COUNT(*) FILTER (WHERE status = 'REJECTED') as rejected_count,
            COUNT(*) FILTER (WHERE status = 'FAILED') as failed_count,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PENDING'), 0) as pending_amount,
            COALESCE(SUM(amount) FILTER (WHERE status = 'COMPLETED'), 0) as completed_amount,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_count,
            COALESCE(SUM(amount) FILTER (WHERE created_at >= CURRENT_DATE), 0) as today_amount
        FROM app.refunds
    `);

    return success(res, "Refund stats retrieved successfully", {
        pending: { count: parseInt(rows[0].pending_count), amount: parseFloat(rows[0].pending_amount) },
        completed: { count: parseInt(rows[0].completed_count), amount: parseFloat(rows[0].completed_amount) },
        rejected: { count: parseInt(rows[0].rejected_count) },
        failed: { count: parseInt(rows[0].failed_count) },
        today: { count: parseInt(rows[0].today_count), amount: parseFloat(rows[0].today_amount) }
    });
});

export const getRefundByIdAdmin = asyncHandler(async (req, res) => {
    const { refundId } = req.params;
    const refund = await RefundsRepo.getRefundById(parseInt(refundId));

    if (!refund) {
        return failure(res, "Refund not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "REFUND_VIEWED",
        resource: "REFUND",
        resourceId: parseInt(refundId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Refund details retrieved successfully", refund);
});

export const approveRefundByAdmin = asyncHandler(async (req, res) => {
    const { refundId } = req.params;
    const { adminNote } = req.body;

    const refund = await RefundsRepo.getRefundById(parseInt(refundId));
    if (!refund) {
        return failure(res, "Refund not found", 404);
    }

    if (refund.status !== 'PENDING') {
        return failure(res, `Cannot approve refund with status: ${refund.status}`, 400);
    }

    const updated = await RefundsRepo.updateRefundStatus({
        id: parseInt(refundId),
        status: 'COMPLETED',
        adminNote,
        processedBy: req.user.id
    });

    await AuditService.logAction({
        userId: req.user.id,
        action: "REFUND_APPROVED",
        resource: "REFUND",
        resourceId: parseInt(refundId),
        meta: { amount: refund.amount, adminNote },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Refund approved successfully", updated);
});

export const rejectRefundByAdmin = asyncHandler(async (req, res) => {
    const { refundId } = req.params;
    const { adminNote, reason } = req.body;

    if (!reason) {
        return failure(res, "Reason for rejection is required", 400);
    }

    const refund = await RefundsRepo.getRefundById(parseInt(refundId));
    if (!refund) {
        return failure(res, "Refund not found", 404);
    }

    if (refund.status !== 'PENDING') {
        return failure(res, `Cannot reject refund with status: ${refund.status}`, 400);
    }

    const updated = await RefundsRepo.updateRefundStatus({
        id: parseInt(refundId),
        status: 'REJECTED',
        adminNote: adminNote || reason,
        processedBy: req.user.id
    });

    await AuditService.logAction({
        userId: req.user.id,
        action: "REFUND_REJECTED",
        resource: "REFUND",
        resourceId: parseInt(refundId),
        meta: { amount: refund.amount, reason, adminNote },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Refund rejected successfully", updated);
});

// ============================================
// DISPUTE MANAGEMENT
// ============================================

export const getDisputesWithCount = asyncHandler(async (req, res) => {
    const { limit = 50, offset = 0, status } = req.query;

    const disputes = await DisputesRepo.listAllDisputes({
        status,
        limit: parseInt(limit),
        offset: parseInt(offset)
    });

    const countResult = await query(
        `SELECT COUNT(*) as total FROM app.disputes ${status ? 'WHERE status = $1' : ''}`,
        status ? [status] : []
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "DISPUTES_LIST_VIEWED",
        meta: { status, limit, offset },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Disputes retrieved successfully", {
        data: disputes,
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit),
        offset: parseInt(offset)
    });
});

export const getDisputeStats = asyncHandler(async (req, res) => {
    const { rows } = await query(`
        SELECT 
            COUNT(*) FILTER (WHERE status = 'OPEN') as open_count,
            COUNT(*) FILTER (WHERE status = 'UNDER_REVIEW') as under_review_count,
            COUNT(*) FILTER (WHERE status = 'ESCALATED') as escalated_count,
            COUNT(*) FILTER (WHERE status = 'RESOLVED') as resolved_count,
            COUNT(*) FILTER (WHERE status = 'CLOSED') as closed_count,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_count,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as week_count
        FROM app.disputes
    `);

    return success(res, "Dispute stats retrieved successfully", {
        open: parseInt(rows[0].open_count),
        under_review: parseInt(rows[0].under_review_count),
        escalated: parseInt(rows[0].escalated_count),
        resolved: parseInt(rows[0].resolved_count),
        closed: parseInt(rows[0].closed_count),
        today: parseInt(rows[0].today_count),
        this_week: parseInt(rows[0].week_count)
    });
});

export const getDisputeByIdAdmin = asyncHandler(async (req, res) => {
    const { disputeId } = req.params;
    const dispute = await DisputesRepo.getDisputeById(parseInt(disputeId));

    if (!dispute) {
        return failure(res, "Dispute not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "DISPUTE_VIEWED",
        resource: "DISPUTE",
        resourceId: parseInt(disputeId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Dispute details retrieved successfully", dispute);
});

export const getDisputeMessagesAdmin = asyncHandler(async (req, res) => {
    const { disputeId } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const messages = await DisputesRepo.getMessages(parseInt(disputeId), {
        limit: parseInt(limit),
        offset: parseInt(offset)
    });

    return success(res, "Dispute messages retrieved successfully", messages);
});

export const assignDisputeAdmin = asyncHandler(async (req, res) => {
    const { disputeId } = req.params;
    const { adminId } = req.body;

    const assignToAdmin = adminId || req.user.id;

    const dispute = await DisputesRepo.getDisputeById(parseInt(disputeId));
    if (!dispute) {
        return failure(res, "Dispute not found", 404);
    }

    const updated = await DisputesRepo.assignAdmin(parseInt(disputeId), assignToAdmin);

    await AuditService.logAction({
        userId: req.user.id,
        action: "DISPUTE_ASSIGNED",
        resource: "DISPUTE",
        resourceId: parseInt(disputeId),
        meta: { assignedTo: assignToAdmin },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Dispute assigned successfully", updated);
});

export const addDisputeMessageAdmin = asyncHandler(async (req, res) => {
    const { disputeId } = req.params;
    const { message, attachments } = req.body;

    if (!message) {
        return failure(res, "Message is required", 400);
    }

    const newMessage = await DisputesRepo.addMessage({
        disputeId: parseInt(disputeId),
        senderId: req.user.id,
        message,
        attachments: attachments || [],
        isAdmin: true
    });

    await AuditService.logAction({
        userId: req.user.id,
        action: "DISPUTE_MESSAGE_ADDED",
        resource: "DISPUTE",
        resourceId: parseInt(disputeId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Message added successfully", newMessage);
});

export const resolveDisputeByAdmin = asyncHandler(async (req, res) => {
    const { disputeId } = req.params;
    const { resolution, refundAmount, status = 'RESOLVED' } = req.body;

    if (!resolution) {
        return failure(res, "Resolution is required", 400);
    }

    const dispute = await DisputesRepo.getDisputeById(parseInt(disputeId));
    if (!dispute) {
        return failure(res, "Dispute not found", 404);
    }

    if (['RESOLVED', 'CLOSED'].includes(dispute.status)) {
        return failure(res, `Dispute already ${dispute.status.toLowerCase()}`, 400);
    }

    const updated = await DisputesRepo.updateDisputeStatus({
        id: parseInt(disputeId),
        status,
        resolution,
        refundAmount: refundAmount || null,
        resolvedAt: new Date()
    });

    await AuditService.logAction({
        userId: req.user.id,
        action: "DISPUTE_RESOLVED",
        resource: "DISPUTE",
        resourceId: parseInt(disputeId),
        meta: { resolution, refundAmount, status },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Dispute resolved successfully", updated);
});


// ============================================
// REVIEW MANAGEMENT
// ============================================

export const getReviewsWithCount = asyncHandler(async (req, res) => {
    const { limit = 50, offset = 0, expertId, rating } = req.query;

    let whereClause = "WHERE 1=1";
    const params = [];
    let paramIndex = 1;

    if (expertId) {
        whereClause += ` AND r.expert_id = $${paramIndex++}`;
        params.push(parseInt(expertId));
    }
    if (rating) {
        whereClause += ` AND r.rating = $${paramIndex++}`;
        params.push(parseInt(rating));
    }

    const countResult = await query(
        `SELECT COUNT(*) as total FROM app.reviews r ${whereClause}`,
        params
    );

    const { rows } = await query(
        `SELECT r.*, 
                b.start_at, b.end_at,
                reviewer.display_name as reviewer_name,
                expert.display_name as expert_name,
                (SELECT COUNT(*) FROM app.reports rep WHERE rep.target_type = 'REVIEW' AND rep.target_id = r.id) as report_count
         FROM app.reviews r
         JOIN app.bookings b ON r.booking_id = b.id
         LEFT JOIN app.user_profiles reviewer ON reviewer.user_id = r.reviewer_id
         LEFT JOIN app.user_profiles expert ON expert.user_id = r.expert_id
         ${whereClause}
         ORDER BY r.created_at DESC
         LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
        [...params, parseInt(limit), parseInt(offset)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "REVIEWS_LIST_VIEWED",
        meta: { expertId, rating, limit, offset },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Reviews retrieved successfully", {
        data: rows,
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit),
        offset: parseInt(offset)
    });
});

export const getReviewStats = asyncHandler(async (req, res) => {
    const { rows } = await query(`
        SELECT 
            COUNT(*) as total_reviews,
            ROUND(AVG(rating), 2) as avg_rating,
            COUNT(*) FILTER (WHERE rating = 5) as five_star,
            COUNT(*) FILTER (WHERE rating = 4) as four_star,
            COUNT(*) FILTER (WHERE rating = 3) as three_star,
            COUNT(*) FILTER (WHERE rating = 2) as two_star,
            COUNT(*) FILTER (WHERE rating = 1) as one_star,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_count,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as week_count
        FROM app.reviews
    `);

    return success(res, "Review stats retrieved successfully", {
        total: parseInt(rows[0].total_reviews),
        avg_rating: parseFloat(rows[0].avg_rating) || 0,
        distribution: {
            five_star: parseInt(rows[0].five_star),
            four_star: parseInt(rows[0].four_star),
            three_star: parseInt(rows[0].three_star),
            two_star: parseInt(rows[0].two_star),
            one_star: parseInt(rows[0].one_star)
        },
        today: parseInt(rows[0].today_count),
        this_week: parseInt(rows[0].week_count)
    });
});

export const getReviewByIdAdmin = asyncHandler(async (req, res) => {
    const { reviewId } = req.params;

    const { rows } = await query(
        `SELECT r.*, 
                b.start_at, b.end_at, b.channel,
                reviewer.display_name as reviewer_name, reviewer_user.handle as reviewer_handle,
                expert.display_name as expert_name, expert_user.handle as expert_handle,
                (SELECT COUNT(*) FROM app.reports rep WHERE rep.target_type = 'REVIEW' AND rep.target_id = r.id) as report_count
         FROM app.reviews r
         JOIN app.bookings b ON r.booking_id = b.id
         LEFT JOIN app.user_profiles reviewer ON reviewer.user_id = r.reviewer_id
         LEFT JOIN app.users reviewer_user ON reviewer_user.id = r.reviewer_id
         LEFT JOIN app.user_profiles expert ON expert.user_id = r.expert_id
         LEFT JOIN app.users expert_user ON expert_user.id = r.expert_id
         WHERE r.id = $1`,
        [parseInt(reviewId)]
    );

    if (rows.length === 0) {
        return failure(res, "Review not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "REVIEW_VIEWED",
        resource: "REVIEW",
        resourceId: parseInt(reviewId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Review details retrieved successfully", rows[0]);
});

export const hideReviewByAdmin = asyncHandler(async (req, res) => {
    const { reviewId } = req.params;
    const { reason } = req.body;

    if (!reason) {
        return failure(res, "Reason for hiding is required", 400);
    }

    // Check if review exists
    const { rows: existing } = await query(
        `SELECT * FROM app.reviews WHERE id = $1`,
        [parseInt(reviewId)]
    );

    if (existing.length === 0) {
        return failure(res, "Review not found", 404);
    }

    // Hide review by setting visibility flag (or you can add a hidden column)
    await query(
        `UPDATE app.reviews SET is_hidden = true, hidden_reason = $2, hidden_at = now(), hidden_by = $3 WHERE id = $1`,
        [parseInt(reviewId), reason, req.user.id]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "REVIEW_HIDDEN",
        resource: "REVIEW",
        resourceId: parseInt(reviewId),
        meta: { reason },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Review hidden successfully", { review_id: parseInt(reviewId) });
});

export const deleteReviewByAdmin = asyncHandler(async (req, res) => {
    const { reviewId } = req.params;
    const { reason } = req.body;

    if (!reason) {
        return failure(res, "Reason for deletion is required", 400);
    }

    const { rows: existing } = await query(
        `SELECT * FROM app.reviews WHERE id = $1`,
        [parseInt(reviewId)]
    );

    if (existing.length === 0) {
        return failure(res, "Review not found", 404);
    }

    await query(`DELETE FROM app.reviews WHERE id = $1`, [parseInt(reviewId)]);

    await AuditService.logAction({
        userId: req.user.id,
        action: "REVIEW_DELETED",
        resource: "REVIEW",
        resourceId: parseInt(reviewId),
        meta: { reason, review_content: existing[0].content?.substring(0, 100) },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Review deleted successfully", { review_id: parseInt(reviewId) });
});

// ============================================
// CHAT MANAGEMENT
// ============================================

export const getChatThreads = asyncHandler(async (req, res) => {
    const { limit = 50, offset = 0, type } = req.query;

    let whereClause = "WHERE 1=1";
    const params = [];
    let paramIndex = 1;

    if (type) {
        whereClause += ` AND t.type = $${paramIndex++}`;
        params.push(type);
    }

    const countResult = await query(
        `SELECT COUNT(*) as total FROM app.chat_threads t ${whereClause}`,
        params
    );

    const { rows } = await query(
        `SELECT t.*, 
                (SELECT COUNT(*) FROM app.chat_messages m WHERE m.thread_id = t.id) as message_count,
                (SELECT COUNT(*) FROM app.chat_members cm WHERE cm.thread_id = t.id) as member_count
         FROM app.chat_threads t
         ${whereClause}
         ORDER BY t.last_message_at DESC NULLS LAST
         LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
        [...params, parseInt(limit), parseInt(offset)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "CHAT_THREADS_VIEWED",
        meta: { type, limit, offset },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Chat threads retrieved successfully", {
        data: rows,
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit),
        offset: parseInt(offset)
    });
});

export const getChatThreadByIdAdmin = asyncHandler(async (req, res) => {
    const { threadId } = req.params;

    const { rows: thread } = await query(
        `SELECT t.*, 
                (SELECT COUNT(*) FROM app.chat_messages m WHERE m.thread_id = t.id) as message_count
         FROM app.chat_threads t
         WHERE t.id = $1`,
        [parseInt(threadId)]
    );

    if (thread.length === 0) {
        return failure(res, "Thread not found", 404);
    }

    // Get members
    const { rows: members } = await query(
        `SELECT cm.*, u.handle, up.display_name, up.avatar_url
         FROM app.chat_members cm
         JOIN app.users u ON u.id = cm.user_id
         LEFT JOIN app.user_profiles up ON up.user_id = cm.user_id
         WHERE cm.thread_id = $1`,
        [parseInt(threadId)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "CHAT_THREAD_VIEWED",
        resource: "CHAT_THREAD",
        resourceId: parseInt(threadId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Thread details retrieved successfully", {
        ...thread[0],
        members
    });
});

export const getChatMessagesAdmin = asyncHandler(async (req, res) => {
    const { threadId } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const { rows } = await query(
        `SELECT m.*, u.handle as sender_handle, up.display_name as sender_name
         FROM app.chat_messages m
         JOIN app.users u ON u.id = m.sender_id
         LEFT JOIN app.user_profiles up ON up.user_id = m.sender_id
         WHERE m.thread_id = $1 AND m.deleted_at IS NULL
         ORDER BY m.created_at DESC
         LIMIT $2 OFFSET $3`,
        [parseInt(threadId), parseInt(limit), parseInt(offset)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "CHAT_MESSAGES_VIEWED",
        resource: "CHAT_THREAD",
        resourceId: parseInt(threadId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Messages retrieved successfully", rows);
});

export const deleteChatMessageAdmin = asyncHandler(async (req, res) => {
    const { messageId } = req.params;
    const { reason } = req.body;

    if (!reason) {
        return failure(res, "Reason for deletion is required", 400);
    }

    const { rows: existing } = await query(
        `SELECT * FROM app.chat_messages WHERE id = $1`,
        [parseInt(messageId)]
    );

    if (existing.length === 0) {
        return failure(res, "Message not found", 404);
    }

    // Soft delete
    await query(
        `UPDATE app.chat_messages SET deleted_at = now(), content = '[Deleted by admin]' WHERE id = $1`,
        [parseInt(messageId)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "CHAT_MESSAGE_DELETED",
        resource: "CHAT_MESSAGE",
        resourceId: parseInt(messageId),
        meta: { reason, original_content: existing[0].content?.substring(0, 100) },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Message deleted successfully", { message_id: parseInt(messageId) });
});

export const getChatStats = asyncHandler(async (req, res) => {
    const { rows } = await query(`
        SELECT 
            (SELECT COUNT(*) FROM app.chat_threads) as total_threads,
            (SELECT COUNT(*) FROM app.chat_threads WHERE type = 'DM') as dm_threads,
            (SELECT COUNT(*) FROM app.chat_threads WHERE type = 'BOOKING') as booking_threads,
            (SELECT COUNT(*) FROM app.chat_messages) as total_messages,
            (SELECT COUNT(*) FROM app.chat_messages WHERE created_at >= CURRENT_DATE) as messages_today,
            (SELECT COUNT(*) FROM app.chat_messages WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as messages_week,
            (SELECT COUNT(DISTINCT sender_id) FROM app.chat_messages WHERE created_at >= CURRENT_DATE) as active_users_today
    `);

    return success(res, "Chat stats retrieved successfully", {
        threads: {
            total: parseInt(rows[0].total_threads),
            dm: parseInt(rows[0].dm_threads),
            booking: parseInt(rows[0].booking_threads)
        },
        messages: {
            total: parseInt(rows[0].total_messages),
            today: parseInt(rows[0].messages_today),
            this_week: parseInt(rows[0].messages_week)
        },
        active_users_today: parseInt(rows[0].active_users_today)
    });
});


// ============================================
// CALL SESSION MANAGEMENT
// ============================================

export const getCallSessionsWithCount = asyncHandler(async (req, res) => {
    const { limit = 50, offset = 0, status, kind } = req.query;

    let whereClause = "WHERE 1=1";
    const params = [];
    let paramIndex = 1;

    if (status) {
        whereClause += ` AND cs.status = $${paramIndex++}`;
        params.push(status);
    }
    if (kind) {
        whereClause += ` AND cs.kind = $${paramIndex++}`;
        params.push(kind);
    }

    const countResult = await query(
        `SELECT COUNT(*) as total FROM app.call_sessions cs ${whereClause}`,
        params
    );

    const { rows } = await query(
        `SELECT cs.*, 
                caller.handle as caller_handle, caller_profile.display_name as caller_name,
                callee.handle as callee_handle, callee_profile.display_name as callee_name,
                EXTRACT(EPOCH FROM (cs.ended_at - cs.connected_at)) as duration_seconds
         FROM app.call_sessions cs
         LEFT JOIN app.users caller ON caller.id = cs.caller_id
         LEFT JOIN app.user_profiles caller_profile ON caller_profile.user_id = cs.caller_id
         LEFT JOIN app.users callee ON callee.id = cs.callee_id
         LEFT JOIN app.user_profiles callee_profile ON callee_profile.user_id = cs.callee_id
         ${whereClause}
         ORDER BY cs.started_at DESC
         LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
        [...params, parseInt(limit), parseInt(offset)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "CALL_SESSIONS_VIEWED",
        meta: { status, kind, limit, offset },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Call sessions retrieved successfully", {
        data: rows,
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit),
        offset: parseInt(offset)
    });
});

export const getCallSessionByIdAdmin = asyncHandler(async (req, res) => {
    const { callId } = req.params;

    const { rows } = await query(
        `SELECT cs.*, 
                caller.handle as caller_handle, caller_profile.display_name as caller_name,
                callee.handle as callee_handle, callee_profile.display_name as callee_name,
                EXTRACT(EPOCH FROM (cs.ended_at - cs.connected_at)) as duration_seconds
         FROM app.call_sessions cs
         LEFT JOIN app.users caller ON caller.id = cs.caller_id
         LEFT JOIN app.user_profiles caller_profile ON caller_profile.user_id = cs.caller_id
         LEFT JOIN app.users callee ON callee.id = cs.callee_id
         LEFT JOIN app.user_profiles callee_profile ON callee_profile.user_id = cs.callee_id
         WHERE cs.id = $1`,
        [parseInt(callId)]
    );

    if (rows.length === 0) {
        return failure(res, "Call session not found", 404);
    }

    // Get call events
    const { rows: events } = await query(
        `SELECT * FROM app.call_events WHERE call_id = $1 ORDER BY at ASC`,
        [parseInt(callId)]
    );

    // Get call metrics
    const { rows: metrics } = await query(
        `SELECT * FROM app.call_metrics WHERE call_id = $1 ORDER BY timestamp DESC LIMIT 10`,
        [parseInt(callId)]
    );

    // Get recordings if any
    const { rows: recordings } = await query(
        `SELECT * FROM app.call_recordings WHERE call_id = $1`,
        [parseInt(callId)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "CALL_SESSION_VIEWED",
        resource: "CALL_SESSION",
        resourceId: parseInt(callId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Call session details retrieved successfully", {
        ...rows[0],
        events,
        metrics,
        recordings
    });
});

export const getCallStats = asyncHandler(async (req, res) => {
    const { rows } = await query(`
        SELECT 
            COUNT(*) as total_calls,
            COUNT(*) FILTER (WHERE status = 'CONNECTED' OR status = 'ENDED') as successful_calls,
            COUNT(*) FILTER (WHERE status = 'MISSED') as missed_calls,
            COUNT(*) FILTER (WHERE status = 'REJECTED') as rejected_calls,
            COUNT(*) FILTER (WHERE status = 'FAILED') as failed_calls,
            COUNT(*) FILTER (WHERE kind = 'VIDEO') as video_calls,
            COUNT(*) FILTER (WHERE kind = 'AUDIO') as audio_calls,
            COUNT(*) FILTER (WHERE started_at >= CURRENT_DATE) as today_calls,
            COUNT(*) FILTER (WHERE started_at >= CURRENT_DATE - INTERVAL '7 days') as week_calls,
            AVG(EXTRACT(EPOCH FROM (ended_at - connected_at))) FILTER (WHERE connected_at IS NOT NULL AND ended_at IS NOT NULL) as avg_duration_seconds
        FROM app.call_sessions
    `);

    return success(res, "Call stats retrieved successfully", {
        total: parseInt(rows[0].total_calls),
        successful: parseInt(rows[0].successful_calls),
        missed: parseInt(rows[0].missed_calls),
        rejected: parseInt(rows[0].rejected_calls),
        failed: parseInt(rows[0].failed_calls),
        by_type: {
            video: parseInt(rows[0].video_calls),
            audio: parseInt(rows[0].audio_calls)
        },
        today: parseInt(rows[0].today_calls),
        this_week: parseInt(rows[0].week_calls),
        avg_duration_seconds: parseFloat(rows[0].avg_duration_seconds) || 0
    });
});

// ============================================
// WALLET MANAGEMENT
// ============================================

export const getWalletsWithCount = asyncHandler(async (req, res) => {
    const { limit = 50, offset = 0, minBalance, maxBalance } = req.query;

    let whereClause = "WHERE 1=1";
    const params = [];
    let paramIndex = 1;

    if (minBalance) {
        whereClause += ` AND w.balance >= $${paramIndex++}`;
        params.push(parseFloat(minBalance));
    }
    if (maxBalance) {
        whereClause += ` AND w.balance <= $${paramIndex++}`;
        params.push(parseFloat(maxBalance));
    }

    const countResult = await query(
        `SELECT COUNT(*) as total FROM app.wallets w ${whereClause}`,
        params
    );

    const { rows } = await query(
        `SELECT w.*, u.handle, u.email, up.display_name
         FROM app.wallets w
         JOIN app.users u ON u.id = w.owner_user_id
         LEFT JOIN app.user_profiles up ON up.user_id = w.owner_user_id
         ${whereClause}
         ORDER BY w.balance DESC
         LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
        [...params, parseInt(limit), parseInt(offset)]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "WALLETS_LIST_VIEWED",
        meta: { minBalance, maxBalance, limit, offset },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Wallets retrieved successfully", {
        data: rows.map(w => ({
            ...w,
            balance: parseFloat(w.balance)
        })),
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit),
        offset: parseInt(offset)
    });
});

export const getWalletByUserIdAdmin = asyncHandler(async (req, res) => {
    const { userId } = req.params;

    const { rows: wallet } = await query(
        `SELECT w.*, u.handle, u.email, up.display_name
         FROM app.wallets w
         JOIN app.users u ON u.id = w.owner_user_id
         LEFT JOIN app.user_profiles up ON up.user_id = w.owner_user_id
         WHERE w.owner_user_id = $1`,
        [parseInt(userId)]
    );

    if (wallet.length === 0) {
        return failure(res, "Wallet not found", 404);
    }

    // Get recent transactions
    const { rows: transactions } = await query(
        `SELECT * FROM app.wallet_ledger WHERE wallet_id = $1 ORDER BY created_at DESC LIMIT 20`,
        [wallet[0].id]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "WALLET_VIEWED",
        resource: "WALLET",
        resourceId: parseInt(userId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Wallet details retrieved successfully", {
        ...wallet[0],
        balance: parseFloat(wallet[0].balance),
        recent_transactions: transactions
    });
});

export const adjustWalletByAdmin = asyncHandler(async (req, res) => {
    const { userId } = req.params;
    const { amount, reason, type = 'ADJUST' } = req.body;

    if (!amount || amount === 0) {
        return failure(res, "Amount is required and must not be zero", 400);
    }
    if (!reason) {
        return failure(res, "Reason for adjustment is required", 400);
    }

    // Get wallet
    const { rows: wallet } = await query(
        `SELECT * FROM app.wallets WHERE owner_user_id = $1`,
        [parseInt(userId)]
    );

    if (wallet.length === 0) {
        return failure(res, "Wallet not found", 404);
    }

    const newBalance = parseFloat(wallet[0].balance) + parseFloat(amount);
    if (newBalance < 0) {
        return failure(res, "Adjustment would result in negative balance", 400);
    }

    // Update balance
    const { rows: updated } = await query(
        `UPDATE app.wallets SET balance = balance + $2 WHERE owner_user_id = $1 RETURNING *`,
        [parseInt(userId), parseFloat(amount)]
    );

    // Insert ledger entry
    await query(
        `INSERT INTO app.wallet_ledger (wallet_id, tx_type, amount, ref_table, ref_id, created_at)
         VALUES ($1, $2, $3, 'ADMIN_ADJUSTMENT', $4, now())`,
        [wallet[0].id, type, parseFloat(amount), req.user.id]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "WALLET_ADJUSTED",
        resource: "WALLET",
        resourceId: parseInt(userId),
        meta: { amount, reason, type, previous_balance: wallet[0].balance, new_balance: updated[0].balance },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Wallet adjusted successfully", {
        user_id: parseInt(userId),
        previous_balance: parseFloat(wallet[0].balance),
        adjustment: parseFloat(amount),
        new_balance: parseFloat(updated[0].balance),
        reason
    });
});

export const getWalletStats = asyncHandler(async (req, res) => {
    const { rows } = await query(`
        SELECT 
            COUNT(*) as total_wallets,
            COALESCE(SUM(balance), 0) as total_balance,
            COALESCE(AVG(balance), 0) as avg_balance,
            COALESCE(MAX(balance), 0) as max_balance,
            COUNT(*) FILTER (WHERE balance > 0) as wallets_with_balance,
            COUNT(*) FILTER (WHERE balance = 0) as empty_wallets
        FROM app.wallets
    `);

    const { rows: txStats } = await query(`
        SELECT 
            COUNT(*) as total_transactions,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_transactions,
            COALESCE(SUM(ABS(amount)) FILTER (WHERE created_at >= CURRENT_DATE), 0) as today_volume
        FROM app.wallet_ledger
    `);

    return success(res, "Wallet stats retrieved successfully", {
        wallets: {
            total: parseInt(rows[0].total_wallets),
            with_balance: parseInt(rows[0].wallets_with_balance),
            empty: parseInt(rows[0].empty_wallets)
        },
        balance: {
            total: parseFloat(rows[0].total_balance),
            average: parseFloat(rows[0].avg_balance),
            max: parseFloat(rows[0].max_balance)
        },
        transactions: {
            total: parseInt(txStats[0].total_transactions),
            today: parseInt(txStats[0].today_transactions),
            today_volume: parseFloat(txStats[0].today_volume)
        }
    });
});

// ============================================
// SKILLS & DOMAINS MANAGEMENT
// ============================================

export const getSkillsAdmin = asyncHandler(async (req, res) => {
    const { rows } = await query(
        `SELECT s.*, 
                (SELECT COUNT(*) FROM app.expert_skills es WHERE es.skill_id = s.id) as expert_count
         FROM app.skills s
         ORDER BY s.name ASC`
    );

    return success(res, "Skills retrieved successfully", rows);
});

export const createSkillAdmin = asyncHandler(async (req, res) => {
    const { name, description } = req.body;

    if (!name) {
        return failure(res, "Skill name is required", 400);
    }

    const { rows } = await query(
        `INSERT INTO app.skills (name, description) VALUES ($1, $2) RETURNING *`,
        [name, description || null]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "SKILL_CREATED",
        resource: "SKILL",
        resourceId: rows[0].id,
        meta: { name },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Skill created successfully", rows[0]);
});

export const updateSkillAdmin = asyncHandler(async (req, res) => {
    const { skillId } = req.params;
    const { name, description } = req.body;

    const { rows } = await query(
        `UPDATE app.skills SET name = COALESCE($2, name), description = COALESCE($3, description) WHERE id = $1 RETURNING *`,
        [parseInt(skillId), name, description]
    );

    if (rows.length === 0) {
        return failure(res, "Skill not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "SKILL_UPDATED",
        resource: "SKILL",
        resourceId: parseInt(skillId),
        meta: { name, description },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Skill updated successfully", rows[0]);
});

export const deleteSkillAdmin = asyncHandler(async (req, res) => {
    const { skillId } = req.params;

    // Check if skill is in use
    const { rows: usage } = await query(
        `SELECT COUNT(*) as count FROM app.expert_skills WHERE skill_id = $1`,
        [parseInt(skillId)]
    );

    if (parseInt(usage[0].count) > 0) {
        return failure(res, `Cannot delete skill: ${usage[0].count} experts are using it`, 400);
    }

    const { rows } = await query(
        `DELETE FROM app.skills WHERE id = $1 RETURNING *`,
        [parseInt(skillId)]
    );

    if (rows.length === 0) {
        return failure(res, "Skill not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "SKILL_DELETED",
        resource: "SKILL",
        resourceId: parseInt(skillId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Skill deleted successfully", { skill_id: parseInt(skillId) });
});

export const getDomainsAdmin = asyncHandler(async (req, res) => {
    const { rows } = await query(
        `SELECT d.*, 
                (SELECT COUNT(*) FROM app.expert_domain ed WHERE ed.domain_id = d.id) as expert_count
         FROM app.domains d
         ORDER BY d.name ASC`
    );

    return success(res, "Domains retrieved successfully", rows);
});

export const createDomainAdmin = asyncHandler(async (req, res) => {
    const { name } = req.body;

    if (!name) {
        return failure(res, "Domain name is required", 400);
    }

    const { rows } = await query(
        `INSERT INTO app.domains (name) VALUES ($1) RETURNING *`,
        [name]
    );

    await AuditService.logAction({
        userId: req.user.id,
        action: "DOMAIN_CREATED",
        resource: "DOMAIN",
        resourceId: rows[0].id,
        meta: { name },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Domain created successfully", rows[0]);
});

export const updateDomainAdmin = asyncHandler(async (req, res) => {
    const { domainId } = req.params;
    const { name } = req.body;

    const { rows } = await query(
        `UPDATE app.domains SET name = COALESCE($2, name) WHERE id = $1 RETURNING *`,
        [parseInt(domainId), name]
    );

    if (rows.length === 0) {
        return failure(res, "Domain not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "DOMAIN_UPDATED",
        resource: "DOMAIN",
        resourceId: parseInt(domainId),
        meta: { name },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Domain updated successfully", rows[0]);
});

export const deleteDomainAdmin = asyncHandler(async (req, res) => {
    const { domainId } = req.params;

    const { rows: usage } = await query(
        `SELECT COUNT(*) as count FROM app.expert_domain WHERE domain_id = $1`,
        [parseInt(domainId)]
    );

    if (parseInt(usage[0].count) > 0) {
        return failure(res, `Cannot delete domain: ${usage[0].count} experts are using it`, 400);
    }

    const { rows } = await query(
        `DELETE FROM app.domains WHERE id = $1 RETURNING *`,
        [parseInt(domainId)]
    );

    if (rows.length === 0) {
        return failure(res, "Domain not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "DOMAIN_DELETED",
        resource: "DOMAIN",
        resourceId: parseInt(domainId),
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Domain deleted successfully", { domain_id: parseInt(domainId) });
});

// ============================================
// RECURRING BOOKING MANAGEMENT
// ============================================

export const getRecurringBookingsAdmin = asyncHandler(async (req, res) => {
    const { limit = 50, offset = 0, status } = req.query;

    let whereClause = "WHERE 1=1";
    const params = [];
    let paramIndex = 1;

    if (status) {
        whereClause += ` AND rt.status = $${paramIndex++}`;
        params.push(status);
    }

    const countResult = await query(
        `SELECT COUNT(*) as total FROM app.recurring_templates rt ${whereClause}`,
        params
    );

    const { rows } = await query(
        `SELECT rt.*, 
                seeker.display_name as seeker_name, seeker_user.handle as seeker_handle,
                expert.display_name as expert_name, expert_user.handle as expert_handle
         FROM app.recurring_templates rt
         LEFT JOIN app.user_profiles seeker ON seeker.user_id = rt.user_id
         LEFT JOIN app.users seeker_user ON seeker_user.id = rt.user_id
         LEFT JOIN app.user_profiles expert ON expert.user_id = rt.expert_id
         LEFT JOIN app.users expert_user ON expert_user.id = rt.expert_id
         ${whereClause}
         ORDER BY rt.created_at DESC
         LIMIT $${paramIndex++} OFFSET $${paramIndex++}`,
        [...params, parseInt(limit), parseInt(offset)]
    );

    return success(res, "Recurring bookings retrieved successfully", {
        data: rows,
        total: parseInt(countResult.rows[0].total),
        limit: parseInt(limit),
        offset: parseInt(offset)
    });
});

export const cancelRecurringBookingAdmin = asyncHandler(async (req, res) => {
    const { templateId } = req.params;
    const { reason } = req.body;

    if (!reason) {
        return failure(res, "Reason for cancellation is required", 400);
    }

    const { rows } = await query(
        `UPDATE app.recurring_templates SET status = 'CANCELLED', cancelled_at = now(), cancel_reason = $2 WHERE id = $1 RETURNING *`,
        [parseInt(templateId), reason]
    );

    if (rows.length === 0) {
        return failure(res, "Recurring template not found", 404);
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "RECURRING_BOOKING_CANCELLED",
        resource: "RECURRING_TEMPLATE",
        resourceId: parseInt(templateId),
        meta: { reason },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Recurring booking cancelled successfully", rows[0]);
});


// ============================================
// USER MANAGEMENT - UPDATE & DELETE
// ============================================

export const updateUserByAdmin = asyncHandler(async (req, res) => {
    const { userId } = req.params;
    const { email, phone, handle, role_primary, profile } = req.body;

    // Check if user exists
    const { rows: existing } = await query(
        `SELECT * FROM app.users WHERE id = $1`,
        [parseInt(userId)]
    );

    if (existing.length === 0) {
        return failure(res, "User not found", 404);
    }

    // Prevent modifying other admins (unless you're a super admin)
    if (existing[0].role_primary === 'ADMIN' && existing[0].id !== req.user.id) {
        return failure(res, "Cannot modify other admin accounts", 403);
    }

    let updatedUser = existing[0];
    let updatedProfile = null;

    // Update user basic info
    const userUpdates = {};
    if (email) userUpdates.email = email;
    if (phone) userUpdates.phone = phone;
    if (handle) userUpdates.handle = handle;
    if (role_primary && ['SEEKER', 'LISTENER', 'EXPERT'].includes(role_primary)) {
        userUpdates.role_primary = role_primary;
    }

    if (Object.keys(userUpdates).length > 0) {
        const setClauses = [];
        const params = [parseInt(userId)];
        let paramIndex = 2;

        for (const [key, value] of Object.entries(userUpdates)) {
            setClauses.push(`${key} = $${paramIndex++}`);
            params.push(value);
        }
        setClauses.push('updated_at = now()');

        const { rows } = await query(
            `UPDATE app.users SET ${setClauses.join(', ')} WHERE id = $1 RETURNING *`,
            params
        );
        updatedUser = rows[0];
    }

    // Update profile if provided
    if (profile && typeof profile === 'object') {
        const { display_name, bio, gender, year_of_birth, avatar_url } = profile;
        const profileUpdates = {};
        if (display_name !== undefined) profileUpdates.display_name = display_name;
        if (bio !== undefined) profileUpdates.bio = bio;
        if (gender !== undefined) profileUpdates.gender = gender;
        if (year_of_birth !== undefined) profileUpdates.year_of_birth = year_of_birth;
        if (avatar_url !== undefined) profileUpdates.avatar_url = avatar_url;

        if (Object.keys(profileUpdates).length > 0) {
            const setClauses = [];
            const params = [parseInt(userId)];
            let paramIndex = 2;

            for (const [key, value] of Object.entries(profileUpdates)) {
                setClauses.push(`${key} = $${paramIndex++}`);
                params.push(value);
            }

            const { rows } = await query(
                `UPDATE app.user_profiles SET ${setClauses.join(', ')} WHERE user_id = $1 RETURNING *`,
                params
            );
            updatedProfile = rows[0];
        }
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "USER_UPDATED",
        resource: "USER",
        resourceId: parseInt(userId),
        meta: { userUpdates, profileUpdates: profile },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "User updated successfully", {
        user: updatedUser,
        profile: updatedProfile
    });
});

export const deleteUserByAdmin = asyncHandler(async (req, res) => {
    const { userId } = req.params;
    const { reason, hardDelete = false } = req.body;

    if (!reason) {
        return failure(res, "Reason for deletion is required", 400);
    }

    // Check if user exists
    const { rows: existing } = await query(
        `SELECT * FROM app.users WHERE id = $1`,
        [parseInt(userId)]
    );

    if (existing.length === 0) {
        return failure(res, "User not found", 404);
    }

    // Prevent deleting admin accounts
    if (existing[0].role_primary === 'ADMIN') {
        return failure(res, "Cannot delete admin accounts", 403);
    }

    // Prevent self-deletion
    if (existing[0].id === req.user.id) {
        return failure(res, "Cannot delete your own account", 403);
    }

    if (hardDelete === true) {
        // Hard delete - permanently remove user and related data
        // Delete related data first
        await query(`DELETE FROM app.user_profiles WHERE user_id = $1`, [parseInt(userId)]);
        await query(`DELETE FROM app.wallets WHERE owner_user_id = $1`, [parseInt(userId)]);
        await query(`DELETE FROM app.expert_profiles WHERE user_id = $1`, [parseInt(userId)]);
        await query(`DELETE FROM app.listener_profiles WHERE user_id = $1`, [parseInt(userId)]);
        await query(`DELETE FROM app.users WHERE id = $1`, [parseInt(userId)]);

        await AuditService.logAction({
            userId: req.user.id,
            action: "USER_HARD_DELETED",
            resource: "USER",
            resourceId: parseInt(userId),
            meta: { reason, user_email: existing[0].email, user_handle: existing[0].handle },
            ip: req.ip,
            agent: req.get("User-Agent")
        });

        return success(res, "User permanently deleted", { user_id: parseInt(userId), deleted: true });
    } else {
        // Soft delete - change status to DELETED
        const { rows } = await query(
            `UPDATE app.users SET status = 'DELETED', updated_at = now() WHERE id = $1 RETURNING id, status, updated_at`,
            [parseInt(userId)]
        );

        await AuditService.logAction({
            userId: req.user.id,
            action: "USER_DELETED",
            resource: "USER",
            resourceId: parseInt(userId),
            meta: { reason, user_email: existing[0].email, user_handle: existing[0].handle },
            ip: req.ip,
            agent: req.get("User-Agent")
        });

        return success(res, "User deleted (soft delete)", rows[0]);
    }
});

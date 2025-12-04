// src/modules/disputes/disputes.repo.js
import { query } from "../../config/db.js";

// Create dispute
export async function createDispute({ bookingId, raisedBy, againstUser, reason, description, evidenceUrls = [] }) {
    const { rows } = await query(
        `INSERT INTO app.disputes (booking_id, raised_by, against_user, reason, description, evidence_urls, status)
         VALUES ($1, $2, $3, $4, $5, $6, 'OPEN')
         RETURNING *`,
        [bookingId, raisedBy, againstUser, reason, description, evidenceUrls]
    );
    return rows[0];
}

// Get dispute by ID
export async function getDisputeById(id) {
    const { rows } = await query(
        `SELECT d.*, 
                b.start_at, b.end_at, b.channel, b.price as booking_price, b.status as booking_status,
                raiser.display_name as raiser_name,
                against.display_name as against_name,
                admin.display_name as admin_name
         FROM app.disputes d
         JOIN app.bookings b ON d.booking_id = b.id
         LEFT JOIN app.user_profiles raiser ON raiser.user_id = d.raised_by
         LEFT JOIN app.user_profiles against ON against.user_id = d.against_user
         LEFT JOIN app.user_profiles admin ON admin.user_id = d.assigned_admin
         WHERE d.id = $1`,
        [id]
    );
    return rows[0];
}

// Get dispute by booking ID
export async function getDisputeByBookingId(bookingId) {
    const { rows } = await query(
        `SELECT * FROM app.disputes WHERE booking_id = $1 ORDER BY created_at DESC LIMIT 1`,
        [bookingId]
    );
    return rows[0];
}

// List disputes for user
export async function listUserDisputes(userId, { limit = 20, offset = 0 } = {}) {
    const { rows } = await query(
        `SELECT d.*, b.start_at, b.end_at, b.channel,
                against.display_name as against_name
         FROM app.disputes d
         JOIN app.bookings b ON d.booking_id = b.id
         LEFT JOIN app.user_profiles against ON against.user_id = d.against_user
         WHERE d.raised_by = $1 OR d.against_user = $1
         ORDER BY d.created_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
    );
    return rows;
}

// List all disputes (admin)
export async function listAllDisputes({ status, limit = 50, offset = 0 } = {}) {
    let sql = `
        SELECT d.*, b.start_at, b.end_at, b.channel, b.price as booking_price,
               raiser.display_name as raiser_name,
               against.display_name as against_name,
               admin.display_name as admin_name
        FROM app.disputes d
        JOIN app.bookings b ON d.booking_id = b.id
        LEFT JOIN app.user_profiles raiser ON raiser.user_id = d.raised_by
        LEFT JOIN app.user_profiles against ON against.user_id = d.against_user
        LEFT JOIN app.user_profiles admin ON admin.user_id = d.assigned_admin
    `;
    const params = [];

    if (status) {
        sql += ` WHERE d.status = $1`;
        params.push(status);
    }

    sql += ` ORDER BY d.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const { rows } = await query(sql, params);
    return rows;
}

// Update dispute status
export async function updateDisputeStatus({ id, status, resolution, refundAmount, assignedAdmin, resolvedAt }, client = null) {
    const sql = `
        UPDATE app.disputes
        SET status = COALESCE($2, status),
            resolution = COALESCE($3, resolution),
            refund_amount = COALESCE($4, refund_amount),
            assigned_admin = COALESCE($5, assigned_admin),
            resolved_at = COALESCE($6, resolved_at)
        WHERE id = $1
        RETURNING *
    `;
    const params = [id, status, resolution, refundAmount, assignedAdmin, resolvedAt];

    if (client) {
        const { rows } = await client.query(sql, params);
        return rows[0];
    }
    const { rows } = await query(sql, params);
    return rows[0];
}

// Assign admin to dispute
export async function assignAdmin(disputeId, adminId) {
    const { rows } = await query(
        `UPDATE app.disputes SET assigned_admin = $2, status = 'UNDER_REVIEW' WHERE id = $1 RETURNING *`,
        [disputeId, adminId]
    );
    return rows[0];
}

// Add dispute message
export async function addMessage({ disputeId, senderId, message, attachments = [], isAdmin = false }) {
    const { rows } = await query(
        `INSERT INTO app.dispute_messages (dispute_id, sender_id, message, attachments, is_admin)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [disputeId, senderId, message, attachments, isAdmin]
    );
    return rows[0];
}

// Get dispute messages
export async function getMessages(disputeId, { limit = 50, offset = 0 } = {}) {
    const { rows } = await query(
        `SELECT m.*, up.display_name as sender_name
         FROM app.dispute_messages m
         LEFT JOIN app.user_profiles up ON up.user_id = m.sender_id
         WHERE m.dispute_id = $1
         ORDER BY m.created_at ASC
         LIMIT $2 OFFSET $3`,
        [disputeId, limit, offset]
    );
    return rows;
}

// Get open disputes count
export async function getOpenDisputesCount() {
    const { rows } = await query(
        `SELECT COUNT(*) as count FROM app.disputes WHERE status IN ('OPEN', 'UNDER_REVIEW', 'ESCALATED')`
    );
    return parseInt(rows[0].count);
}

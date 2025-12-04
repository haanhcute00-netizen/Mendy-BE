// src/modules/refunds/refunds.repo.js
import { query } from "../../config/db.js";

// Create refund request
export async function createRefund({ bookingId, paymentIntentId, userId, amount, platformFeeRefunded, reason }, client = null) {
    const sql = `
        INSERT INTO app.refunds (booking_id, payment_intent_id, user_id, amount, platform_fee_refunded, reason, status)
        VALUES ($1, $2, $3, $4, $5, $6, 'PENDING')
        RETURNING *
    `;
    const params = [bookingId, paymentIntentId, userId, amount, platformFeeRefunded || 0, reason];

    if (client) {
        const { rows } = await client.query(sql, params);
        return rows[0];
    }
    const { rows } = await query(sql, params);
    return rows[0];
}

// Get refund by ID
export async function getRefundById(id) {
    const { rows } = await query(
        `SELECT r.*, b.user_id as booking_user_id, b.expert_id, b.price as booking_price
         FROM app.refunds r
         JOIN app.bookings b ON r.booking_id = b.id
         WHERE r.id = $1`,
        [id]
    );
    return rows[0];
}

// Get refund by booking ID
export async function getRefundByBookingId(bookingId) {
    const { rows } = await query(
        `SELECT * FROM app.refunds WHERE booking_id = $1 ORDER BY created_at DESC LIMIT 1`,
        [bookingId]
    );
    return rows[0];
}

// List refunds for user
export async function listUserRefunds(userId, { limit = 20, offset = 0 } = {}) {
    const { rows } = await query(
        `SELECT r.*, b.start_at, b.end_at, b.channel, up.display_name as expert_name
         FROM app.refunds r
         JOIN app.bookings b ON r.booking_id = b.id
         LEFT JOIN app.user_profiles up ON up.user_id = b.expert_id
         WHERE r.user_id = $1
         ORDER BY r.created_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
    );
    return rows;
}

// List all refunds (admin)
export async function listAllRefunds({ status, limit = 50, offset = 0 } = {}) {
    let sql = `
        SELECT r.*, b.start_at, b.end_at, b.channel, b.price as booking_price,
               seeker.display_name as seeker_name, expert.display_name as expert_name
        FROM app.refunds r
        JOIN app.bookings b ON r.booking_id = b.id
        LEFT JOIN app.user_profiles seeker ON seeker.user_id = r.user_id
        LEFT JOIN app.user_profiles expert ON expert.user_id = b.expert_id
    `;
    const params = [];

    if (status) {
        sql += ` WHERE r.status = $1`;
        params.push(status);
    }

    sql += ` ORDER BY r.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const { rows } = await query(sql, params);
    return rows;
}

// Update refund status
export async function updateRefundStatus({ id, status, adminNote, processedBy }, client = null) {
    const sql = `
        UPDATE app.refunds
        SET status = $2, admin_note = COALESCE($3, admin_note), 
            processed_by = $4, processed_at = CASE WHEN $2 IN ('COMPLETED', 'REJECTED', 'FAILED') THEN now() ELSE processed_at END
        WHERE id = $1
        RETURNING *
    `;
    const params = [id, status, adminNote, processedBy];

    if (client) {
        const { rows } = await client.query(sql, params);
        return rows[0];
    }
    const { rows } = await query(sql, params);
    return rows[0];
}

// Set provider refund ID
export async function setProviderRefundId(id, providerRefundId) {
    const { rows } = await query(
        `UPDATE app.refunds SET provider_refund_id = $2 WHERE id = $1 RETURNING *`,
        [id, providerRefundId]
    );
    return rows[0];
}

// Get pending refunds count
export async function getPendingRefundsCount() {
    const { rows } = await query(
        `SELECT COUNT(*) as count FROM app.refunds WHERE status = 'PENDING'`
    );
    return parseInt(rows[0].count);
}

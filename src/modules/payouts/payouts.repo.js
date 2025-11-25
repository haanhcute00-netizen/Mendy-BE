// src/repositories/payouts.repo.js
import { query } from "../../config/db.js";

export async function createRequest({ userId, amount, payoutAccountId }, client) {
    const q = `
    INSERT INTO app.payout_requests (user_id, amount, payout_account_id, status)
    VALUES ($1, $2, $3, 'PENDING')
    RETURNING *
  `;
    const params = [userId, amount, payoutAccountId];

    if (client) {
        const { rows } = await client.query(q, params);
        return rows[0];
    } else {
        const { rows } = await query(q, params);
        return rows[0];
    }
}

export async function getRequestById(id) {
    const { rows } = await query(
        `SELECT * FROM app.payout_requests WHERE id = $1`,
        [id]
    );
    return rows[0];
}

export async function listRequests({ userId, status, limit = 20, offset = 0 }) {
    let q = `SELECT * FROM app.payout_requests WHERE 1=1`;
    const params = [];
    let idx = 1;

    if (userId) {
        q += ` AND user_id = $${idx++}`;
        params.push(userId);
    }

    if (status) {
        q += ` AND status = $${idx++}`;
        params.push(status);
    }

    q += ` ORDER BY created_at DESC LIMIT $${idx++} OFFSET $${idx++}`;
    params.push(limit, offset);

    const { rows } = await query(q, params);
    return rows;
}

export async function updateStatus({ id, status, adminNote }, client) {
    const q = `
    UPDATE app.payout_requests
    SET status = $2, admin_note = COALESCE($3, admin_note), updated_at = now()
    WHERE id = $1
    RETURNING *
  `;
    const params = [id, status, adminNote];

    if (client) {
        const { rows } = await client.query(q, params);
        return rows[0];
    } else {
        const { rows } = await query(q, params);
        return rows[0];
    }
}

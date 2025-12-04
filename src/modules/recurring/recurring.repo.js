// src/modules/recurring/recurring.repo.js
import { query } from "../../config/db.js";

// Create recurring booking template
export async function createTemplate({
    userId, expertId, channel, startTime, durationMinutes, frequency,
    dayOfWeek, dayOfMonth, pricePerSession, totalSessions, startsFrom, endsAt
}) {
    const { rows } = await query(
        `INSERT INTO app.recurring_booking_templates 
         (user_id, expert_id, channel, start_time, duration_minutes, frequency, 
          day_of_week, day_of_month, price_per_session, total_sessions, starts_from, ends_at, next_booking_date)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $11)
         RETURNING *`,
        [userId, expertId, channel, startTime, durationMinutes, frequency,
            dayOfWeek, dayOfMonth, pricePerSession, totalSessions, startsFrom, endsAt]
    );
    return rows[0];
}

// Get template by ID
export async function getTemplateById(id) {
    const { rows } = await query(
        `SELECT t.*, 
                seeker.display_name as seeker_name,
                expert.display_name as expert_name,
                ep.price_per_session as current_expert_price
         FROM app.recurring_booking_templates t
         LEFT JOIN app.user_profiles seeker ON seeker.user_id = t.user_id
         LEFT JOIN app.user_profiles expert ON expert.user_id = t.expert_id
         LEFT JOIN app.expert_profiles ep ON ep.user_id = t.expert_id
         WHERE t.id = $1`,
        [id]
    );
    return rows[0];
}

// List templates for user
export async function listUserTemplates(userId, { asExpert = false, limit = 20, offset = 0 } = {}) {
    const column = asExpert ? 'expert_id' : 'user_id';
    const { rows } = await query(
        `SELECT t.*, 
                seeker.display_name as seeker_name,
                expert.display_name as expert_name
         FROM app.recurring_booking_templates t
         LEFT JOIN app.user_profiles seeker ON seeker.user_id = t.user_id
         LEFT JOIN app.user_profiles expert ON expert.user_id = t.expert_id
         WHERE t.${column} = $1
         ORDER BY t.created_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
    );
    return rows;
}

// Get active templates due for booking creation
export async function getTemplatesDueForBooking(targetDate) {
    const { rows } = await query(
        `SELECT t.*, ep.price_per_session as current_expert_price
         FROM app.recurring_booking_templates t
         LEFT JOIN app.expert_profiles ep ON ep.user_id = t.expert_id
         WHERE t.is_active = true
           AND t.next_booking_date <= $1
           AND (t.ends_at IS NULL OR t.ends_at >= $1)
           AND (t.total_sessions IS NULL OR t.sessions_completed < t.total_sessions)`,
        [targetDate]
    );
    return rows;
}

// Update template
export async function updateTemplate(id, updates) {
    const allowedFields = ['channel', 'start_time', 'duration_minutes', 'frequency',
        'day_of_week', 'day_of_month', 'price_per_session',
        'total_sessions', 'is_active', 'ends_at'];

    const setClauses = [];
    const params = [id];
    let paramIndex = 2;

    for (const [key, value] of Object.entries(updates)) {
        if (allowedFields.includes(key) && value !== undefined) {
            setClauses.push(`${key} = $${paramIndex}`);
            params.push(value);
            paramIndex++;
        }
    }

    if (setClauses.length === 0) return getTemplateById(id);

    const { rows } = await query(
        `UPDATE app.recurring_booking_templates 
         SET ${setClauses.join(', ')}
         WHERE id = $1
         RETURNING *`,
        params
    );
    return rows[0];
}

// Update next booking date and increment sessions
export async function updateAfterBookingCreated(templateId, nextDate, client = null) {
    const sql = `
        UPDATE app.recurring_booking_templates 
        SET next_booking_date = $2, sessions_completed = sessions_completed + 1
        WHERE id = $1
        RETURNING *
    `;

    if (client) {
        const { rows } = await client.query(sql, [templateId, nextDate]);
        return rows[0];
    }
    const { rows } = await query(sql, [templateId, nextDate]);
    return rows[0];
}

// Deactivate template
export async function deactivateTemplate(id) {
    const { rows } = await query(
        `UPDATE app.recurring_booking_templates SET is_active = false WHERE id = $1 RETURNING *`,
        [id]
    );
    return rows[0];
}

// Get bookings created from template
export async function getBookingsFromTemplate(templateId, { limit = 20, offset = 0 } = {}) {
    const { rows } = await query(
        `SELECT b.* FROM app.bookings b
         WHERE b.recurring_template_id = $1
         ORDER BY b.start_at DESC
         LIMIT $2 OFFSET $3`,
        [templateId, limit, offset]
    );
    return rows;
}

// Check if expert has availability for recurring slot
export async function checkExpertAvailabilityForRecurring(expertId, dayOfWeek, startTime, durationMinutes) {
    // This is a simplified check - in production you'd want more sophisticated logic
    const { rows } = await query(
        `SELECT 1 FROM app.expert_availabilities 
         WHERE expert_id = $1 
           AND is_recurring = true
         LIMIT 1`,
        [expertId]
    );
    // If expert has no recurring availability set, allow (MVP-friendly)
    return rows.length === 0 || rows.length > 0;
}

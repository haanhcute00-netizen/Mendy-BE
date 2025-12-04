// =============================================
// AI COMPANION - NOTIFICATION REPOSITORY
// =============================================

import { query } from '../../../config/db.js';

// ========== SCHEDULED NOTIFICATIONS ==========

export const createNotification = async (notification) => {
    const sql = `
        INSERT INTO app.ai_scheduled_notifications 
            (user_id, persona_id, type, content, scheduled_at, metadata)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
    `;
    const values = [
        notification.user_id,
        notification.persona_id || null,
        notification.type,
        notification.content,
        notification.scheduled_at,
        notification.metadata || {}
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getPendingNotifications = async (beforeTime = null) => {
    const time = beforeTime || new Date();
    const sql = `
        SELECT 
            n.id, n.user_id, n.persona_id, n.type, n.content, 
            n.scheduled_at, n.metadata,
            p.name as persona_name, p.display_name as persona_display_name,
            s.notification_enabled, s.quiet_hours_start, s.quiet_hours_end, s.timezone
        FROM app.ai_scheduled_notifications n
        LEFT JOIN app.ai_personas p ON n.persona_id = p.id
        LEFT JOIN app.user_ai_settings s ON n.user_id = s.user_id
        WHERE n.is_sent = FALSE 
          AND n.scheduled_at <= $1
          AND (s.notification_enabled IS NULL OR s.notification_enabled = TRUE)
        ORDER BY n.scheduled_at ASC
        LIMIT 100
    `;
    const result = await query(sql, [time]);
    return result.rows;
};

export const markAsSent = async (notificationId) => {
    const sql = `
        UPDATE app.ai_scheduled_notifications
        SET is_sent = TRUE, sent_at = NOW()
        WHERE id = $1
        RETURNING *
    `;
    const result = await query(sql, [notificationId]);
    return result.rows[0];
};

export const markMultipleAsSent = async (notificationIds) => {
    if (!notificationIds.length) return [];
    const sql = `
        UPDATE app.ai_scheduled_notifications
        SET is_sent = TRUE, sent_at = NOW()
        WHERE id = ANY($1)
        RETURNING id
    `;
    const result = await query(sql, [notificationIds]);
    return result.rows;
};

export const getUserNotifications = async (userId, limit = 20, includesSent = false) => {
    const sql = `
        SELECT id, type, content, scheduled_at, sent_at, is_sent, metadata
        FROM app.ai_scheduled_notifications
        WHERE user_id = $1 ${includesSent ? '' : 'AND is_sent = FALSE'}
        ORDER BY scheduled_at DESC
        LIMIT $2
    `;
    const result = await query(sql, [userId, limit]);
    return result.rows;
};

export const deleteNotification = async (notificationId, userId) => {
    const sql = `
        DELETE FROM app.ai_scheduled_notifications
        WHERE id = $1 AND user_id = $2
        RETURNING id
    `;
    const result = await query(sql, [notificationId, userId]);
    return result.rows[0];
};

export const deleteOldNotifications = async (daysOld = 30) => {
    const sql = `
        DELETE FROM app.ai_scheduled_notifications
        WHERE is_sent = TRUE AND sent_at < NOW() - INTERVAL '1 day' * $1
    `;
    const result = await query(sql, [daysOld]);
    return result.rowCount;
};

// ========== BULK SCHEDULING ==========

export const scheduleMultipleNotifications = async (notifications) => {
    if (!notifications.length) return [];

    const values = notifications.map((n, i) => {
        const base = i * 6;
        return `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 6})`;
    }).join(', ');

    const params = notifications.flatMap(n => [
        n.user_id,
        n.persona_id || null,
        n.type,
        n.content,
        n.scheduled_at,
        JSON.stringify(n.metadata || {})
    ]);

    const sql = `
        INSERT INTO app.ai_scheduled_notifications 
            (user_id, persona_id, type, content, scheduled_at, metadata)
        VALUES ${values}
        RETURNING *
    `;
    const result = await query(sql, params);
    return result.rows;
};

// ========== USER NOTIFICATION PREFERENCES ==========

export const getUsersForMorningCheckin = async () => {
    const sql = `
        SELECT 
            s.user_id, s.persona_id, s.custom_nickname, s.timezone,
            p.name as persona_name, p.signature_messages
        FROM app.user_ai_settings s
        LEFT JOIN app.ai_personas p ON s.persona_id = p.id
        WHERE s.notification_enabled = TRUE
          AND s.morning_checkin = TRUE
    `;
    const result = await query(sql);
    return result.rows;
};

export const getUsersForEveningCheckin = async () => {
    const sql = `
        SELECT 
            s.user_id, s.persona_id, s.custom_nickname, s.timezone,
            p.name as persona_name, p.signature_messages
        FROM app.user_ai_settings s
        LEFT JOIN app.ai_personas p ON s.persona_id = p.id
        WHERE s.notification_enabled = TRUE
          AND s.evening_checkin = TRUE
    `;
    const result = await query(sql);
    return result.rows;
};

export const getUsersForRandomMessages = async () => {
    const sql = `
        SELECT 
            s.user_id, s.persona_id, s.custom_nickname, s.timezone,
            s.quiet_hours_start, s.quiet_hours_end,
            p.name as persona_name, p.signature_messages
        FROM app.user_ai_settings s
        LEFT JOIN app.ai_personas p ON s.persona_id = p.id
        WHERE s.notification_enabled = TRUE
          AND s.random_messages = TRUE
    `;
    const result = await query(sql);
    return result.rows;
};

// Check if notification already scheduled for user today
export const hasScheduledToday = async (userId, type) => {
    const sql = `
        SELECT EXISTS(
            SELECT 1 FROM app.ai_scheduled_notifications
            WHERE user_id = $1 
              AND type = $2
              AND scheduled_at::date = CURRENT_DATE
        ) as exists
    `;
    const result = await query(sql, [userId, type]);
    return result.rows[0].exists;
};

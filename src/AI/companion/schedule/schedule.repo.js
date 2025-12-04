// =============================================
// AI COMPANION - SCHEDULE REPOSITORY
// =============================================

import { query } from '../../../config/db.js';

// ========== USER SCHEDULES ==========

export const createSchedule = async (userId, schedule) => {
    const sql = `
        INSERT INTO app.user_schedules (
            user_id, title, description, schedule_type, start_at, end_at,
            is_all_day, recurrence, remind_before, priority, ai_generated, metadata
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
        RETURNING *
    `;
    const values = [
        userId,
        schedule.title,
        schedule.description || null,
        schedule.schedule_type || 'custom',
        schedule.start_at,
        schedule.end_at || null,
        schedule.is_all_day || false,
        schedule.recurrence || null,
        schedule.remind_before ?? 15,
        schedule.priority ?? 2,
        schedule.ai_generated || false,
        schedule.metadata || {}
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getScheduleById = async (scheduleId, userId) => {
    const sql = `SELECT * FROM app.user_schedules WHERE id = $1 AND user_id = $2`;
    const result = await query(sql, [scheduleId, userId]);
    return result.rows[0] || null;
};

export const getUserSchedules = async (userId, options = {}) => {
    const { startDate, endDate, type, completed, limit = 50 } = options;
    let sql = `SELECT * FROM app.user_schedules WHERE user_id = $1`;
    const values = [userId];
    let idx = 2;

    if (startDate) {
        sql += ` AND start_at >= $${idx}`;
        values.push(startDate);
        idx++;
    }
    if (endDate) {
        sql += ` AND start_at <= $${idx}`;
        values.push(endDate);
        idx++;
    }
    if (type) {
        sql += ` AND schedule_type = $${idx}`;
        values.push(type);
        idx++;
    }
    if (completed !== undefined) {
        sql += ` AND completed = $${idx}`;
        values.push(completed);
        idx++;
    }

    sql += ` ORDER BY start_at ASC LIMIT $${idx}`;
    values.push(limit);

    const result = await query(sql, values);
    return result.rows;
};

export const getTodaySchedules = async (userId) => {
    const sql = `
        SELECT * FROM app.user_schedules
        WHERE user_id = $1 
          AND DATE(start_at) = CURRENT_DATE
          AND completed = FALSE
        ORDER BY start_at ASC
    `;
    const result = await query(sql, [userId]);
    return result.rows;
};

export const getUpcomingSchedules = async (userId, hours = 24) => {
    const sql = `
        SELECT * FROM app.user_schedules
        WHERE user_id = $1 
          AND start_at BETWEEN NOW() AND NOW() + INTERVAL '1 hour' * $2
          AND completed = FALSE
        ORDER BY start_at ASC
    `;
    const result = await query(sql, [userId, hours]);
    return result.rows;
};

export const updateSchedule = async (scheduleId, userId, updates) => {
    const fields = [];
    const values = [scheduleId, userId];
    let idx = 3;

    const allowedFields = ['title', 'description', 'schedule_type', 'start_at', 'end_at',
        'is_all_day', 'recurrence', 'remind_before', 'priority', 'completed', 'metadata'];

    for (const field of allowedFields) {
        if (updates[field] !== undefined) {
            fields.push(`${field} = $${idx}`);
            values.push(field === 'metadata' ? JSON.stringify(updates[field]) : updates[field]);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    const sql = `
        UPDATE app.user_schedules
        SET ${fields.join(', ')}, updated_at = NOW()
        WHERE id = $1 AND user_id = $2
        RETURNING *
    `;
    const result = await query(sql, values);
    return result.rows[0];
};

export const completeSchedule = async (scheduleId, userId) => {
    const sql = `
        UPDATE app.user_schedules
        SET completed = TRUE, completed_at = NOW(), updated_at = NOW()
        WHERE id = $1 AND user_id = $2
        RETURNING *
    `;
    const result = await query(sql, [scheduleId, userId]);
    return result.rows[0];
};

export const deleteSchedule = async (scheduleId, userId) => {
    const sql = `DELETE FROM app.user_schedules WHERE id = $1 AND user_id = $2 RETURNING id`;
    const result = await query(sql, [scheduleId, userId]);
    return result.rows[0];
};

// ========== SLEEP LOGS ==========

export const logSleep = async (userId, sleepData) => {
    const duration = sleepData.sleep_at && sleepData.wake_at
        ? Math.round((new Date(sleepData.wake_at) - new Date(sleepData.sleep_at)) / 60000)
        : sleepData.duration_minutes || null;

    const sql = `
        INSERT INTO app.sleep_logs (
            user_id, date, sleep_at, wake_at, duration_minutes, quality,
            deep_sleep_minutes, interruptions, notes, factors
        ) VALUES ($1, COALESCE($2, CURRENT_DATE), $3, $4, $5, $6, $7, $8, $9, $10)
        ON CONFLICT (user_id, date) DO UPDATE SET
            sleep_at = COALESCE(EXCLUDED.sleep_at, app.sleep_logs.sleep_at),
            wake_at = COALESCE(EXCLUDED.wake_at, app.sleep_logs.wake_at),
            duration_minutes = COALESCE(EXCLUDED.duration_minutes, app.sleep_logs.duration_minutes),
            quality = COALESCE(EXCLUDED.quality, app.sleep_logs.quality),
            deep_sleep_minutes = COALESCE(EXCLUDED.deep_sleep_minutes, app.sleep_logs.deep_sleep_minutes),
            interruptions = COALESCE(EXCLUDED.interruptions, app.sleep_logs.interruptions),
            notes = COALESCE(EXCLUDED.notes, app.sleep_logs.notes),
            factors = COALESCE(EXCLUDED.factors, app.sleep_logs.factors)
        RETURNING *
    `;
    const values = [
        userId,
        sleepData.date || null,
        sleepData.sleep_at || null,
        sleepData.wake_at || null,
        duration,
        sleepData.quality || null,
        sleepData.deep_sleep_minutes || null,
        sleepData.interruptions || 0,
        sleepData.notes || null,
        sleepData.factors || []
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getSleepHistory = async (userId, days = 30) => {
    const sql = `
        SELECT * FROM app.sleep_logs
        WHERE user_id = $1 AND date > CURRENT_DATE - $2
        ORDER BY date DESC
    `;
    const result = await query(sql, [userId, days]);
    return result.rows;
};

export const getSleepSummary = async (userId) => {
    const sql = `SELECT * FROM app.v_user_sleep_summary WHERE user_id = $1`;
    const result = await query(sql, [userId]);
    return result.rows[0] || null;
};

// ========== BEHAVIOR PATTERNS ==========

export const upsertBehaviorPattern = async (userId, patternType, patternName, patternData, confidence = 0.5) => {
    const sql = `
        INSERT INTO app.behavior_patterns (user_id, pattern_type, pattern_name, pattern_data, confidence)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (user_id, pattern_type, pattern_name) DO UPDATE SET
            pattern_data = EXCLUDED.pattern_data,
            confidence = EXCLUDED.confidence,
            occurrences = app.behavior_patterns.occurrences + 1,
            last_detected = NOW()
        RETURNING *
    `;
    const result = await query(sql, [userId, patternType, patternName, patternData, confidence]);
    return result.rows[0];
};

export const getUserPatterns = async (userId, patternType = null) => {
    let sql = `SELECT * FROM app.behavior_patterns WHERE user_id = $1 AND is_active = TRUE`;
    const values = [userId];

    if (patternType) {
        sql += ` AND pattern_type = $2`;
        values.push(patternType);
    }

    sql += ` ORDER BY occurrences DESC, confidence DESC`;
    const result = await query(sql, values);
    return result.rows;
};

// ========== PROACTIVE MESSAGES ==========

export const createProactiveMessage = async (message) => {
    const sql = `
        INSERT INTO app.proactive_messages (
            user_id, trigger_type, trigger_data, message_content,
            persona_id, priority, scheduled_at, expires_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING *
    `;
    const values = [
        message.user_id,
        message.trigger_type,
        message.trigger_data || {},
        message.message_content,
        message.persona_id || null,
        message.priority || 2,
        message.scheduled_at,
        message.expires_at || null
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getPendingProactiveMessages = async () => {
    const sql = `
        SELECT pm.*, p.name as persona_name, p.tone as persona_tone
        FROM app.proactive_messages pm
        LEFT JOIN app.ai_personas p ON pm.persona_id = p.id
        WHERE pm.is_sent = FALSE 
          AND pm.scheduled_at <= NOW()
          AND (pm.expires_at IS NULL OR pm.expires_at > NOW())
        ORDER BY pm.priority DESC, pm.scheduled_at ASC
        LIMIT 100
    `;
    const result = await query(sql);
    return result.rows;
};

export const markProactiveMessageSent = async (messageId) => {
    const sql = `
        UPDATE app.proactive_messages
        SET is_sent = TRUE, sent_at = NOW()
        WHERE id = $1
        RETURNING *
    `;
    const result = await query(sql, [messageId]);
    return result.rows[0];
};

// ========== USER ACTIVITY ==========

export const logActivity = async (userId, activityType, activityData = {}, sessionId = null) => {
    const sql = `
        INSERT INTO app.user_activity_logs (user_id, activity_type, activity_data, session_id)
        VALUES ($1, $2, $3, $4)
        RETURNING *
    `;
    const result = await query(sql, [userId, activityType, activityData, sessionId]);
    return result.rows[0];
};

export const getInactiveUsers = async () => {
    const sql = `SELECT * FROM app.v_inactive_users`;
    const result = await query(sql);
    return result.rows;
};

export const getLastActivity = async (userId) => {
    const sql = `
        SELECT * FROM app.user_activity_logs
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT 1
    `;
    const result = await query(sql, [userId]);
    return result.rows[0] || null;
};

// ========== AI SUGGESTIONS ==========

export const createSuggestion = async (userId, suggestion) => {
    const sql = `
        INSERT INTO app.ai_suggestions (user_id, suggestion_type, suggestion_content, reason)
        VALUES ($1, $2, $3, $4)
        RETURNING *
    `;
    const result = await query(sql, [
        userId,
        suggestion.suggestion_type,
        suggestion.suggestion_content,
        suggestion.reason || null
    ]);
    return result.rows[0];
};

export const respondToSuggestion = async (suggestionId, userId, accepted, feedback = null) => {
    const sql = `
        UPDATE app.ai_suggestions
        SET accepted = $3, 
            ${accepted ? 'accepted_at' : 'dismissed_at'} = NOW(),
            feedback = $4
        WHERE id = $1 AND user_id = $2
        RETURNING *
    `;
    const result = await query(sql, [suggestionId, userId, accepted, feedback]);
    return result.rows[0];
};

export const getPendingSuggestions = async (userId) => {
    const sql = `
        SELECT * FROM app.ai_suggestions
        WHERE user_id = $1 AND accepted IS NULL
        ORDER BY created_at DESC
    `;
    const result = await query(sql, [userId]);
    return result.rows;
};

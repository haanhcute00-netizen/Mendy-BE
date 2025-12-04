// =============================================
// AI COMPANION - PERSONA REPOSITORY
// =============================================

import { query } from '../../../config/db.js';

// ========== PERSONAS ==========

export const getAllPersonas = async () => {
    const sql = `
        SELECT id, name, display_name, tone, emotion_pattern, behavior_rules, 
               signature_messages, avatar_url, description, is_active
        FROM app.ai_personas
        WHERE is_active = TRUE
        ORDER BY id
    `;
    const result = await query(sql);
    return result.rows;
};

export const getPersonaById = async (personaId) => {
    const sql = `
        SELECT id, name, display_name, tone, emotion_pattern, behavior_rules,
               signature_messages, avatar_url, description
        FROM app.ai_personas
        WHERE id = $1 AND is_active = TRUE
    `;
    const result = await query(sql, [personaId]);
    return result.rows[0] || null;
};

export const getPersonaByName = async (name) => {
    const sql = `
        SELECT id, name, display_name, tone, emotion_pattern, behavior_rules,
               signature_messages, avatar_url, description
        FROM app.ai_personas
        WHERE name = $1 AND is_active = TRUE
    `;
    const result = await query(sql, [name]);
    return result.rows[0] || null;
};

// ========== USER AI SETTINGS ==========

export const getUserAISettings = async (userId) => {
    const sql = `
        SELECT 
            s.user_id, s.persona_id, s.relationship_level,
            s.custom_nickname, s.user_nickname,
            s.notification_enabled, s.morning_checkin, s.evening_checkin,
            s.random_messages, s.quiet_hours_start, s.quiet_hours_end,
            s.timezone, s.created_at, s.updated_at,
            p.name as persona_name, p.display_name as persona_display_name,
            p.tone as persona_tone, p.emotion_pattern, p.behavior_rules,
            p.signature_messages
        FROM app.user_ai_settings s
        LEFT JOIN app.ai_personas p ON s.persona_id = p.id
        WHERE s.user_id = $1
    `;
    const result = await query(sql, [userId]);
    return result.rows[0] || null;
};

export const createUserAISettings = async (userId, settings = {}) => {
    const sql = `
        INSERT INTO app.user_ai_settings (
            user_id, persona_id, custom_nickname, user_nickname,
            notification_enabled, morning_checkin, evening_checkin,
            random_messages, quiet_hours_start, quiet_hours_end, timezone
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        ON CONFLICT (user_id) DO UPDATE SET
            persona_id = COALESCE(EXCLUDED.persona_id, app.user_ai_settings.persona_id),
            custom_nickname = COALESCE(EXCLUDED.custom_nickname, app.user_ai_settings.custom_nickname),
            user_nickname = COALESCE(EXCLUDED.user_nickname, app.user_ai_settings.user_nickname),
            notification_enabled = COALESCE(EXCLUDED.notification_enabled, app.user_ai_settings.notification_enabled),
            morning_checkin = COALESCE(EXCLUDED.morning_checkin, app.user_ai_settings.morning_checkin),
            evening_checkin = COALESCE(EXCLUDED.evening_checkin, app.user_ai_settings.evening_checkin),
            random_messages = COALESCE(EXCLUDED.random_messages, app.user_ai_settings.random_messages),
            quiet_hours_start = COALESCE(EXCLUDED.quiet_hours_start, app.user_ai_settings.quiet_hours_start),
            quiet_hours_end = COALESCE(EXCLUDED.quiet_hours_end, app.user_ai_settings.quiet_hours_end),
            timezone = COALESCE(EXCLUDED.timezone, app.user_ai_settings.timezone),
            updated_at = NOW()
        RETURNING *
    `;
    const values = [
        userId,
        settings.persona_id || null,
        settings.custom_nickname || null,
        settings.user_nickname || null,
        settings.notification_enabled ?? true,
        settings.morning_checkin ?? true,
        settings.evening_checkin ?? true,
        settings.random_messages ?? true,
        settings.quiet_hours_start || '23:00',
        settings.quiet_hours_end || '07:00',
        settings.timezone || 'Asia/Ho_Chi_Minh'
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const updateUserAISettings = async (userId, updates) => {
    const fields = [];
    const values = [userId];
    let idx = 2;

    const allowedFields = [
        'persona_id', 'relationship_level', 'custom_nickname', 'user_nickname',
        'notification_enabled', 'morning_checkin', 'evening_checkin',
        'random_messages', 'quiet_hours_start', 'quiet_hours_end', 'timezone'
    ];

    for (const field of allowedFields) {
        if (updates[field] !== undefined) {
            fields.push(`${field} = $${idx}`);
            values.push(updates[field]);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    const sql = `
        UPDATE app.user_ai_settings
        SET ${fields.join(', ')}, updated_at = NOW()
        WHERE user_id = $1
        RETURNING *
    `;
    const result = await query(sql, values);
    return result.rows[0];
};

export const incrementRelationshipLevel = async (userId) => {
    const sql = `
        UPDATE app.user_ai_settings
        SET relationship_level = LEAST(relationship_level + 1, 4),
            updated_at = NOW()
        WHERE user_id = $1
        RETURNING relationship_level
    `;
    const result = await query(sql, [userId]);
    return result.rows[0]?.relationship_level;
};

// ========== CONVERSATION CONTEXT ==========

export const saveContext = async (userId, contextType, contextKey, contextValue, importance = 1, expiresAt = null) => {
    const sql = `
        INSERT INTO app.ai_conversation_context 
            (user_id, context_type, context_key, context_value, importance, expires_at)
        VALUES ($1, $2, $3, $4, $5, $6)
        ON CONFLICT (user_id, context_type, context_key) DO UPDATE SET
            context_value = EXCLUDED.context_value,
            importance = EXCLUDED.importance,
            expires_at = EXCLUDED.expires_at,
            updated_at = NOW()
        RETURNING *
    `;
    const result = await query(sql, [userId, contextType, contextKey, contextValue, importance, expiresAt]);
    return result.rows[0];
};

export const getContextByType = async (userId, contextType) => {
    const sql = `
        SELECT context_key, context_value, importance
        FROM app.ai_conversation_context
        WHERE user_id = $1 AND context_type = $2
          AND (expires_at IS NULL OR expires_at > NOW())
        ORDER BY importance DESC, updated_at DESC
    `;
    const result = await query(sql, [userId, contextType]);
    return result.rows;
};

export const getAllUserContext = async (userId, limit = 20) => {
    const sql = `
        SELECT context_type, context_key, context_value, importance
        FROM app.ai_conversation_context
        WHERE user_id = $1
          AND (expires_at IS NULL OR expires_at > NOW())
        ORDER BY importance DESC, updated_at DESC
        LIMIT $2
    `;
    const result = await query(sql, [userId, limit]);
    return result.rows;
};

export const deleteContext = async (userId, contextType, contextKey) => {
    const sql = `
        DELETE FROM app.ai_conversation_context
        WHERE user_id = $1 AND context_type = $2 AND context_key = $3
    `;
    await query(sql, [userId, contextType, contextKey]);
};

export const cleanExpiredContext = async () => {
    const sql = `
        DELETE FROM app.ai_conversation_context
        WHERE expires_at IS NOT NULL AND expires_at < NOW()
    `;
    const result = await query(sql);
    return result.rowCount;
};

// =============================================
// AI COMPANION - EMOTION REPOSITORY
// =============================================

import { query } from '../../../config/db.js';

// ========== EMOTION LOGS ==========

export const logEmotion = async (userId, emotion, intensity, source, options = {}) => {
    const sql = `
        INSERT INTO app.emotion_logs 
            (user_id, emotion, intensity, source, message_id, raw_text, confidence, metadata)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING *
    `;
    const values = [
        userId,
        emotion,
        intensity || 0.5,
        source || 'chat',
        options.message_id || null,
        options.raw_text || null,
        options.confidence || 0.5,
        options.metadata || {}
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getEmotionTimeline = async (userId, days = 7, limit = 100) => {
    const sql = `
        SELECT id, emotion, intensity, detected_at, source, confidence
        FROM app.emotion_logs
        WHERE user_id = $1 AND detected_at > NOW() - INTERVAL '1 day' * $2
        ORDER BY detected_at DESC
        LIMIT $3
    `;
    const result = await query(sql, [userId, days, limit]);
    return result.rows;
};

export const getEmotionStats = async (userId, days = 7) => {
    const sql = `
        SELECT 
            emotion,
            COUNT(*) as count,
            AVG(intensity) as avg_intensity,
            MAX(detected_at) as last_detected
        FROM app.emotion_logs
        WHERE user_id = $1 AND detected_at > NOW() - INTERVAL '1 day' * $2
        GROUP BY emotion
        ORDER BY count DESC
    `;
    const result = await query(sql, [userId, days]);
    return result.rows;
};

export const getDominantEmotion = async (userId, hours = 24) => {
    const sql = `
        SELECT emotion, COUNT(*) as count, AVG(intensity) as avg_intensity
        FROM app.emotion_logs
        WHERE user_id = $1 AND detected_at > NOW() - INTERVAL '1 hour' * $2
        GROUP BY emotion
        ORDER BY count DESC, avg_intensity DESC
        LIMIT 1
    `;
    const result = await query(sql, [userId, hours]);
    return result.rows[0] || null;
};

export const getRecentEmotions = async (userId, limit = 5) => {
    const sql = `
        SELECT emotion, intensity, detected_at, source
        FROM app.emotion_logs
        WHERE user_id = $1
        ORDER BY detected_at DESC
        LIMIT $2
    `;
    const result = await query(sql, [userId, limit]);
    return result.rows;
};

// ========== USER MENTAL STATE ==========

export const getMentalState = async (userId) => {
    const sql = `
        SELECT * FROM app.user_mental_state WHERE user_id = $1
    `;
    const result = await query(sql, [userId]);
    return result.rows[0] || null;
};

export const upsertMentalState = async (userId, state) => {
    const sql = `
        INSERT INTO app.user_mental_state (
            user_id, current_mood, mood_score, stress_level, anxiety_level,
            energy_level, vulnerability_score, consecutive_negative_days,
            last_positive_interaction, last_evaluated, evaluation_notes
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), $10)
        ON CONFLICT (user_id) DO UPDATE SET
            current_mood = COALESCE(EXCLUDED.current_mood, app.user_mental_state.current_mood),
            mood_score = COALESCE(EXCLUDED.mood_score, app.user_mental_state.mood_score),
            stress_level = COALESCE(EXCLUDED.stress_level, app.user_mental_state.stress_level),
            anxiety_level = COALESCE(EXCLUDED.anxiety_level, app.user_mental_state.anxiety_level),
            energy_level = COALESCE(EXCLUDED.energy_level, app.user_mental_state.energy_level),
            vulnerability_score = COALESCE(EXCLUDED.vulnerability_score, app.user_mental_state.vulnerability_score),
            consecutive_negative_days = COALESCE(EXCLUDED.consecutive_negative_days, app.user_mental_state.consecutive_negative_days),
            last_positive_interaction = COALESCE(EXCLUDED.last_positive_interaction, app.user_mental_state.last_positive_interaction),
            last_evaluated = NOW(),
            evaluation_notes = COALESCE(EXCLUDED.evaluation_notes, app.user_mental_state.evaluation_notes),
            updated_at = NOW()
        RETURNING *
    `;
    const values = [
        userId,
        state.current_mood || 'neutral',
        state.mood_score ?? 0.5,
        state.stress_level ?? 0,
        state.anxiety_level ?? 0,
        state.energy_level ?? 5,
        state.vulnerability_score ?? 0,
        state.consecutive_negative_days ?? 0,
        state.last_positive_interaction || null,
        state.evaluation_notes || null
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const incrementNegativeDays = async (userId) => {
    const sql = `
        UPDATE app.user_mental_state
        SET consecutive_negative_days = consecutive_negative_days + 1,
            updated_at = NOW()
        WHERE user_id = $1
        RETURNING consecutive_negative_days
    `;
    const result = await query(sql, [userId]);
    return result.rows[0]?.consecutive_negative_days;
};

export const resetNegativeDays = async (userId) => {
    const sql = `
        UPDATE app.user_mental_state
        SET consecutive_negative_days = 0,
            last_positive_interaction = NOW(),
            updated_at = NOW()
        WHERE user_id = $1
    `;
    await query(sql, [userId]);
};

export const getUsersNeedingAttention = async () => {
    const sql = `
        SELECT * FROM app.v_users_needing_attention
        ORDER BY vulnerability_score DESC, stress_level DESC
    `;
    const result = await query(sql);
    return result.rows;
};

// ========== MENTAL HEALTH ASSESSMENTS ==========

export const createAssessment = async (userId, assessment) => {
    const sql = `
        INSERT INTO app.mental_health_assessments (
            user_id, assessment_type, risk_level, burnout_score,
            depression_indicators, anxiety_indicators, sleep_quality_score,
            social_engagement_score, recommendations, triggers_detected, notes
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *
    `;
    const values = [
        userId,
        assessment.assessment_type || 'auto',
        assessment.risk_level || 'low',
        assessment.burnout_score || 0,
        assessment.depression_indicators || 0,
        assessment.anxiety_indicators || 0,
        assessment.sleep_quality_score || null,
        assessment.social_engagement_score || null,
        JSON.stringify(assessment.recommendations || []),
        assessment.triggers_detected || [],
        assessment.notes || null
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getLatestAssessment = async (userId) => {
    const sql = `
        SELECT * FROM app.mental_health_assessments
        WHERE user_id = $1
        ORDER BY assessed_at DESC
        LIMIT 1
    `;
    const result = await query(sql, [userId]);
    return result.rows[0] || null;
};

export const getAssessmentHistory = async (userId, limit = 10) => {
    const sql = `
        SELECT * FROM app.mental_health_assessments
        WHERE user_id = $1
        ORDER BY assessed_at DESC
        LIMIT $2
    `;
    const result = await query(sql, [userId, limit]);
    return result.rows;
};

// ========== WELLNESS ACTIVITIES ==========

export const logWellnessActivity = async (userId, activity) => {
    const sql = `
        INSERT INTO app.wellness_activities (
            user_id, activity_type, title, description, duration_minutes,
            mood_before, mood_after, effectiveness_rating, notes, suggested_by, metadata
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *
    `;
    const values = [
        userId,
        activity.activity_type,
        activity.title || null,
        activity.description || null,
        activity.duration_minutes || 0,
        activity.mood_before || null,
        activity.mood_after || null,
        activity.effectiveness_rating || null,
        activity.notes || null,
        activity.suggested_by || 'ai',
        activity.metadata || {}
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getWellnessHistory = async (userId, days = 30, limit = 50) => {
    const sql = `
        SELECT * FROM app.wellness_activities
        WHERE user_id = $1 AND completed_at > NOW() - INTERVAL '1 day' * $2
        ORDER BY completed_at DESC
        LIMIT $3
    `;
    const result = await query(sql, [userId, days, limit]);
    return result.rows;
};

export const getWellnessStats = async (userId, days = 30) => {
    const sql = `
        SELECT 
            activity_type,
            COUNT(*) as total_sessions,
            SUM(duration_minutes) as total_minutes,
            AVG(effectiveness_rating) as avg_effectiveness
        FROM app.wellness_activities
        WHERE user_id = $1 AND completed_at > NOW() - INTERVAL '1 day' * $2
        GROUP BY activity_type
        ORDER BY total_sessions DESC
    `;
    const result = await query(sql, [userId, days]);
    return result.rows;
};

// ========== DAILY MOOD CHECKINS ==========

export const createDailyCheckin = async (userId, checkin) => {
    const sql = `
        INSERT INTO app.daily_mood_checkins (
            user_id, checkin_date, mood, mood_score, energy_level,
            sleep_hours, sleep_quality, stress_level, gratitude_notes,
            concerns, goals_for_day
        ) VALUES ($1, COALESCE($2, CURRENT_DATE), $3, $4, $5, $6, $7, $8, $9, $10, $11)
        ON CONFLICT (user_id, checkin_date) DO UPDATE SET
            mood = EXCLUDED.mood,
            mood_score = EXCLUDED.mood_score,
            energy_level = EXCLUDED.energy_level,
            sleep_hours = EXCLUDED.sleep_hours,
            sleep_quality = EXCLUDED.sleep_quality,
            stress_level = EXCLUDED.stress_level,
            gratitude_notes = EXCLUDED.gratitude_notes,
            concerns = EXCLUDED.concerns,
            goals_for_day = EXCLUDED.goals_for_day,
            checkin_time = NOW()
        RETURNING *
    `;
    const values = [
        userId,
        checkin.checkin_date || null,
        checkin.mood,
        checkin.mood_score || null,
        checkin.energy_level || null,
        checkin.sleep_hours || null,
        checkin.sleep_quality || null,
        checkin.stress_level || null,
        checkin.gratitude_notes || [],
        checkin.concerns || null,
        checkin.goals_for_day || null
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

export const getTodayCheckin = async (userId) => {
    const sql = `
        SELECT * FROM app.daily_mood_checkins
        WHERE user_id = $1 AND checkin_date = CURRENT_DATE
    `;
    const result = await query(sql, [userId]);
    return result.rows[0] || null;
};

export const getCheckinHistory = async (userId, days = 30) => {
    const sql = `
        SELECT * FROM app.daily_mood_checkins
        WHERE user_id = $1 AND checkin_date > CURRENT_DATE - INTERVAL '1 day' * $2
        ORDER BY checkin_date DESC
    `;
    const result = await query(sql, [userId, days]);
    return result.rows;
};

// ========== EMOTION PATTERNS ==========

export const upsertPattern = async (userId, patternType, patternKey, patternData) => {
    const sql = `
        INSERT INTO app.emotion_patterns (user_id, pattern_type, pattern_key, pattern_data)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (user_id, pattern_type, pattern_key) DO UPDATE SET
            pattern_data = EXCLUDED.pattern_data,
            frequency = app.emotion_patterns.frequency + 1,
            last_detected = NOW()
        RETURNING *
    `;
    const result = await query(sql, [userId, patternType, patternKey, patternData]);
    return result.rows[0];
};

export const getUserPatterns = async (userId) => {
    const sql = `
        SELECT * FROM app.emotion_patterns
        WHERE user_id = $1 AND is_active = TRUE
        ORDER BY frequency DESC
    `;
    const result = await query(sql, [userId]);
    return result.rows;
};

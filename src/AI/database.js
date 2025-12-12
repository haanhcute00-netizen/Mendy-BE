
import { query } from '../config/db.js';

// ========== AI CHAT HISTORY ==========

export const saveAIChatMessage = async (userId, role, content, options = {}) => {
    const sql = `
        INSERT INTO app.ai_chat_history 
            (user_id, role, content, emotion_detected, keywords, persona_id, metadata)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *
    `;
    const values = [
        userId,
        role,
        content,
        options.emotion || null,
        options.keywords || [],
        options.persona_id || null,
        options.metadata || {}
    ];
    const result = await query(sql, values);
    return result.rows[0];
};

// Task 14: Add pagination support for chat history
export const getAIChatHistory = async (userId, limit = 50, offset = 0) => {
    // Get total count
    const countSql = `SELECT COUNT(*) as total FROM app.ai_chat_history WHERE user_id = $1`;
    const countResult = await query(countSql, [userId]);
    const total = parseInt(countResult.rows[0]?.total || 0);

    const sql = `
        SELECT id, role, content, emotion_detected, keywords, created_at
        FROM app.ai_chat_history
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT $2 OFFSET $3
    `;
    const result = await query(sql, [userId, limit, offset]);

    return {
        messages: result.rows.reverse(), // Oldest first
        total,
        limit,
        offset,
        hasMore: offset + result.rows.length < total
    };
};

export const getRecentAIChatForPrompt = async (userId, limit = 10) => {
    const sql = `
        SELECT role, content
        FROM app.ai_chat_history
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT $2
    `;
    const result = await query(sql, [userId, limit]);
    return result.rows.reverse();
};

export const clearAIChatHistory = async (userId) => {
    const sql = `DELETE FROM app.ai_chat_history WHERE user_id = $1`;
    const result = await query(sql, [userId]);
    return result.rowCount;
};

// ========== LEGACY CHAT HISTORY (from chat_messages) ==========

export const getRecentChatHistory = async (userId) => {
    const sql = `
        SELECT sender_id, content
        FROM app.chat_messages
        WHERE thread_id = (
            -- Subquery để tìm thread gần nhất của người dùng
            SELECT id FROM app.chat_threads
            WHERE id IN (
                -- Lấy tất cả thread mà user là thành viên
                SELECT thread_id FROM app.chat_members WHERE user_id = $1
            )
            ORDER BY last_message_at DESC NULLS LAST -- Sắp xếp theo tin nhắn cuối cùng, NULLS LAST để xử lý thread chưa có tin nhắn
            LIMIT 1
        )
        ORDER BY created_at DESC
        LIMIT 10;
    `;


    const values = [userId];

    const result = await query(sql, values);
    return result.rows.reverse();
};


export const findExpertsByKeywords = async (keywords) => {
    if (!keywords || keywords.length === 0) {
        return [];
    }

    const sql = `
        SELECT
            ep.id,
            ep.price_per_session,
            ep.rating_avg,
            up.display_name,
            up.avatar_url,
            ep.intro
        FROM
            app.expert_profiles ep
        JOIN
            app.user_profiles up ON ep.user_id = up.user_id
        JOIN
            app.expert_status es ON ep.id = es.expert_id
        WHERE
            ep.specialties && $1
        ORDER BY
            ep.rating_avg DESC,
            es.active_score DESC
        LIMIT 5;
    `;

    const values = [keywords];


    const result = await query(sql, values);
    return result.rows;
};
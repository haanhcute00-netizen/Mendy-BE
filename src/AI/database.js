
import { query } from '../config/db.js';


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
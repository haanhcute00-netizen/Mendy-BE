// Import hàm 'query' từ file cấu hình database mới của bạn
import { query } from '../config/db.js';

/**
 * Lấy lịch sử trò chuyện gần đây của một người dùng.
 * LƯU Ý: Subquery để lấy `thread_id` cần được điều chỉnh cho phù hợp với logic của bạn.
 * Ví dụ này giả định bạn có cách xác định thread gần nhất của user.
 * @param {number} userId - ID của người dùng.
 * @returns {Promise<Array>} - Mảng các tin nhắn gần đây.
 */
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
    
    // Truyền userId vào câu truy vấn như một tham số an toàn
    const values = [userId];
    
    const result = await query(sql, values);
    return result.rows.reverse(); // Trả về thứ tự đúng (cũ nhất -> mới nhất)
};

/**
 * Tìm chuyên gia phù hợp dựa trên danh sách từ khóa.
 * Sử dụng toán tử && (overlap) của PostgreSQL để tìm kiếm hiệu quả trên mảng (array).
 * @param {string[]} keywords - Mảng các từ khóa.
 * @returns {Promise<Array>} - Mảng các đối tượng chuyên gia phù hợp.
 */
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
    
    // Sử dụng hàm query() đã được import
    const result = await query(sql, values);
    return result.rows;
};
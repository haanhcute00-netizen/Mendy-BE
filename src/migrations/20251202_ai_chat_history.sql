-- =============================================
-- AI COMPANION - CHAT HISTORY
-- Lưu lịch sử trò chuyện với AI riêng biệt
-- =============================================

CREATE TABLE IF NOT EXISTS app.ai_chat_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'ai')),
    content TEXT NOT NULL,
    emotion_detected TEXT,
    keywords TEXT[],
    persona_id BIGINT REFERENCES app.ai_personas(id),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ai_chat_user_time ON app.ai_chat_history(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_chat_recent ON app.ai_chat_history(created_at DESC);

-- View: Recent conversations per user
CREATE OR REPLACE VIEW app.v_ai_chat_summary AS
SELECT 
    user_id,
    COUNT(*) as total_messages,
    COUNT(*) FILTER (WHERE role = 'user') as user_messages,
    COUNT(*) FILTER (WHERE role = 'ai') as ai_messages,
    MAX(created_at) as last_message_at
FROM app.ai_chat_history
GROUP BY user_id;

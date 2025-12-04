-- =============================================
-- AI COMPANION SYSTEM - PHASE 2 MIGRATION
-- Emotional Memory + Mental Health Engine
-- =============================================

-- 1. Emotion Logs - Lưu lịch sử cảm xúc
CREATE TABLE IF NOT EXISTS app.emotion_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    emotion TEXT NOT NULL,                    -- 'happy', 'sad', 'anxious', 'stressed', 'angry', 'neutral', 'excited', 'tired'
    intensity DECIMAL(3,2) DEFAULT 0.5,       -- 0.00 - 1.00 (mức độ mạnh của cảm xúc)
    detected_at TIMESTAMPTZ DEFAULT NOW(),
    source TEXT NOT NULL DEFAULT 'chat',      -- 'chat', 'checkin', 'manual', 'behavior', 'schedule'
    message_id BIGINT,                        -- Reference to chat message if from chat
    raw_text TEXT,                            -- Original text that triggered detection
    confidence DECIMAL(3,2) DEFAULT 0.5,      -- AI confidence in detection (0-1)
    metadata JSONB DEFAULT '{}'
);

-- 2. User Mental State - Trạng thái tinh thần hiện tại
CREATE TABLE IF NOT EXISTS app.user_mental_state (
    user_id BIGINT PRIMARY KEY REFERENCES app.users(id) ON DELETE CASCADE,
    current_mood TEXT DEFAULT 'neutral',      -- Tâm trạng hiện tại
    mood_score DECIMAL(3,2) DEFAULT 0.5,      -- 0 = rất tiêu cực, 1 = rất tích cực
    stress_level INT DEFAULT 0 CHECK (stress_level BETWEEN 0 AND 10),
    anxiety_level INT DEFAULT 0 CHECK (anxiety_level BETWEEN 0 AND 10),
    energy_level INT DEFAULT 5 CHECK (energy_level BETWEEN 0 AND 10),
    vulnerability_score DECIMAL(3,2) DEFAULT 0.0,  -- 0 = ổn định, 1 = rất dễ tổn thương
    consecutive_negative_days INT DEFAULT 0,
    last_positive_interaction TIMESTAMPTZ,
    last_evaluated TIMESTAMPTZ DEFAULT NOW(),
    evaluation_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Mental Health Assessments - Đánh giá sức khỏe tinh thần định kỳ
CREATE TABLE IF NOT EXISTS app.mental_health_assessments (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    assessment_type TEXT NOT NULL DEFAULT 'auto',  -- 'auto', 'checkin', 'weekly', 'crisis'
    risk_level TEXT NOT NULL DEFAULT 'low' CHECK (risk_level IN ('low', 'moderate', 'high', 'critical')),
    burnout_score INT DEFAULT 0 CHECK (burnout_score BETWEEN 0 AND 100),
    depression_indicators INT DEFAULT 0,      -- Số dấu hiệu trầm cảm phát hiện
    anxiety_indicators INT DEFAULT 0,         -- Số dấu hiệu lo âu phát hiện
    sleep_quality_score INT CHECK (sleep_quality_score BETWEEN 0 AND 10),
    social_engagement_score INT CHECK (social_engagement_score BETWEEN 0 AND 10),
    assessed_at TIMESTAMPTZ DEFAULT NOW(),
    recommendations JSONB DEFAULT '[]',       -- Mảng các gợi ý
    triggers_detected TEXT[],                 -- Các trigger đã phát hiện
    notes TEXT,
    reviewed_by BIGINT,                       -- Expert/Admin đã review (nếu có)
    reviewed_at TIMESTAMPTZ
);

-- 4. Wellness Activities - Hoạt động chăm sóc sức khỏe
CREATE TABLE IF NOT EXISTS app.wellness_activities (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,              -- 'breathing', 'meditation', 'journaling', 'exercise', 'gratitude', 'grounding', 'affirmation'
    title TEXT,
    description TEXT,
    duration_minutes INT DEFAULT 0,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    mood_before TEXT,
    mood_after TEXT,
    effectiveness_rating INT CHECK (effectiveness_rating BETWEEN 1 AND 5),
    notes TEXT,
    suggested_by TEXT DEFAULT 'ai',           -- 'ai', 'expert', 'self'
    metadata JSONB DEFAULT '{}'
);

-- 5. Daily Mood Checkins - Check-in tâm trạng hàng ngày
CREATE TABLE IF NOT EXISTS app.daily_mood_checkins (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    checkin_date DATE NOT NULL DEFAULT CURRENT_DATE,
    mood TEXT NOT NULL,                       -- 'great', 'good', 'okay', 'bad', 'terrible'
    mood_score INT CHECK (mood_score BETWEEN 1 AND 5),
    energy_level INT CHECK (energy_level BETWEEN 1 AND 5),
    sleep_hours DECIMAL(3,1),
    sleep_quality INT CHECK (sleep_quality BETWEEN 1 AND 5),
    stress_level INT CHECK (stress_level BETWEEN 1 AND 5),
    gratitude_notes TEXT[],                   -- 3 điều biết ơn
    concerns TEXT,                            -- Lo lắng chính
    goals_for_day TEXT,
    checkin_time TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, checkin_date)
);

-- 6. Emotion Patterns - Mẫu cảm xúc theo thời gian
CREATE TABLE IF NOT EXISTS app.emotion_patterns (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    pattern_type TEXT NOT NULL,               -- 'weekly', 'time_of_day', 'trigger', 'seasonal'
    pattern_key TEXT NOT NULL,                -- e.g., 'monday', 'morning', 'work_stress'
    pattern_data JSONB NOT NULL,              -- Chi tiết pattern
    frequency INT DEFAULT 1,                  -- Số lần xuất hiện
    first_detected TIMESTAMPTZ DEFAULT NOW(),
    last_detected TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(user_id, pattern_type, pattern_key)
);

-- ========== INDEXES ==========

-- Emotion logs indexes
CREATE INDEX IF NOT EXISTS idx_emotion_logs_user_time ON app.emotion_logs(user_id, detected_at DESC);
CREATE INDEX IF NOT EXISTS idx_emotion_logs_user_emotion ON app.emotion_logs(user_id, emotion);
CREATE INDEX IF NOT EXISTS idx_emotion_logs_source ON app.emotion_logs(source, detected_at DESC);
-- Partial index without NOW() - use regular index instead
CREATE INDEX IF NOT EXISTS idx_emotion_logs_detected ON app.emotion_logs(detected_at DESC);

-- Mental state indexes (partial indexes with constants are OK)
CREATE INDEX IF NOT EXISTS idx_mental_state_stress ON app.user_mental_state(stress_level DESC) WHERE stress_level >= 7;
CREATE INDEX IF NOT EXISTS idx_mental_state_vulnerability ON app.user_mental_state(vulnerability_score DESC) WHERE vulnerability_score >= 0.7;

-- Assessments indexes
CREATE INDEX IF NOT EXISTS idx_assessments_user_time ON app.mental_health_assessments(user_id, assessed_at DESC);
CREATE INDEX IF NOT EXISTS idx_assessments_risk ON app.mental_health_assessments(risk_level, assessed_at DESC) WHERE risk_level IN ('high', 'critical');

-- Wellness activities indexes
CREATE INDEX IF NOT EXISTS idx_wellness_user_time ON app.wellness_activities(user_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_wellness_type ON app.wellness_activities(activity_type);

-- Daily checkins indexes
CREATE INDEX IF NOT EXISTS idx_checkins_user_date ON app.daily_mood_checkins(user_id, checkin_date DESC);

-- Patterns indexes
CREATE INDEX IF NOT EXISTS idx_patterns_user_type ON app.emotion_patterns(user_id, pattern_type);

-- ========== TRIGGERS ==========

-- Auto update user_mental_state.updated_at
DROP TRIGGER IF EXISTS trg_mental_state_updated ON app.user_mental_state;
CREATE TRIGGER trg_mental_state_updated
    BEFORE UPDATE ON app.user_mental_state
    FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();

-- ========== VIEWS ==========

-- View: User emotion summary (last 7 days)
CREATE OR REPLACE VIEW app.v_user_emotion_summary AS
SELECT 
    user_id,
    COUNT(*) as total_logs,
    COUNT(*) FILTER (WHERE emotion IN ('happy', 'excited')) as positive_count,
    COUNT(*) FILTER (WHERE emotion IN ('sad', 'anxious', 'stressed', 'angry')) as negative_count,
    COUNT(*) FILTER (WHERE emotion = 'neutral') as neutral_count,
    AVG(intensity) as avg_intensity,
    MODE() WITHIN GROUP (ORDER BY emotion) as dominant_emotion
FROM app.emotion_logs
WHERE detected_at > NOW() - INTERVAL '7 days'
GROUP BY user_id;

-- View: Users needing attention (high risk)
CREATE OR REPLACE VIEW app.v_users_needing_attention AS
SELECT 
    ms.user_id,
    ms.current_mood,
    ms.stress_level,
    ms.vulnerability_score,
    ms.consecutive_negative_days,
    ms.last_evaluated,
    mha.risk_level as latest_risk_level,
    mha.assessed_at as latest_assessment
FROM app.user_mental_state ms
LEFT JOIN LATERAL (
    SELECT risk_level, assessed_at 
    FROM app.mental_health_assessments 
    WHERE user_id = ms.user_id 
    ORDER BY assessed_at DESC 
    LIMIT 1
) mha ON TRUE
WHERE ms.stress_level >= 7 
   OR ms.vulnerability_score >= 0.7 
   OR ms.consecutive_negative_days >= 3
   OR mha.risk_level IN ('high', 'critical');

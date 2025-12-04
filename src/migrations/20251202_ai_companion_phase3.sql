-- =============================================
-- AI COMPANION SYSTEM - PHASE 3 MIGRATION
-- Smart Schedule + Proactive AI
-- =============================================

-- 1. User Schedules - Lịch cá nhân
CREATE TABLE IF NOT EXISTS app.user_schedules (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    schedule_type TEXT NOT NULL CHECK (schedule_type IN ('study', 'work', 'health', 'medication', 'exercise', 'sleep', 'meal', 'appointment', 'deadline', 'reminder', 'custom')),
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ,
    is_all_day BOOLEAN DEFAULT FALSE,
    recurrence TEXT,                          -- RRULE format (e.g., 'FREQ=DAILY;INTERVAL=1')
    remind_before INT DEFAULT 15,             -- Minutes before to remind
    priority INT DEFAULT 2 CHECK (priority BETWEEN 1 AND 5),  -- 1=low, 5=critical
    ai_generated BOOLEAN DEFAULT FALSE,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Sleep Logs - Theo dõi giấc ngủ
CREATE TABLE IF NOT EXISTS app.sleep_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    sleep_at TIMESTAMPTZ,                     -- Giờ đi ngủ
    wake_at TIMESTAMPTZ,                      -- Giờ thức dậy
    duration_minutes INT,                     -- Tổng thời gian ngủ
    quality INT CHECK (quality BETWEEN 1 AND 5),
    deep_sleep_minutes INT,
    interruptions INT DEFAULT 0,              -- Số lần thức giấc
    notes TEXT,
    factors TEXT[],                           -- ['caffeine', 'stress', 'exercise', 'screen_time']
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- 3. Behavior Patterns - Mẫu hành vi
CREATE TABLE IF NOT EXISTS app.behavior_patterns (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    pattern_type TEXT NOT NULL,               -- 'sleep', 'activity', 'mood', 'stress', 'engagement'
    pattern_name TEXT NOT NULL,
    pattern_data JSONB NOT NULL,
    confidence DECIMAL(3,2) DEFAULT 0.5,
    occurrences INT DEFAULT 1,
    first_detected TIMESTAMPTZ DEFAULT NOW(),
    last_detected TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(user_id, pattern_type, pattern_name)
);

-- 4. Proactive Messages Queue - Hàng đợi tin nhắn chủ động
CREATE TABLE IF NOT EXISTS app.proactive_messages (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    trigger_type TEXT NOT NULL,               -- 'schedule', 'emotion', 'behavior', 'time', 'inactivity', 'milestone'
    trigger_data JSONB DEFAULT '{}',
    message_content TEXT NOT NULL,
    persona_id BIGINT REFERENCES app.ai_personas(id),
    priority INT DEFAULT 2,
    scheduled_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    is_sent BOOLEAN DEFAULT FALSE,
    user_response TEXT,
    effectiveness_score INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. AI Suggestions History - Lịch sử gợi ý AI
CREATE TABLE IF NOT EXISTS app.ai_suggestions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    suggestion_type TEXT NOT NULL,            -- 'schedule', 'wellness', 'expert', 'activity', 'sleep'
    suggestion_content JSONB NOT NULL,
    reason TEXT,
    accepted BOOLEAN,
    accepted_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,
    feedback TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. User Activity Tracking - Theo dõi hoạt động
CREATE TABLE IF NOT EXISTS app.user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,              -- 'app_open', 'chat', 'checkin', 'schedule_view', 'wellness'
    activity_data JSONB DEFAULT '{}',
    session_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========== INDEXES ==========

CREATE INDEX IF NOT EXISTS idx_schedules_user_time ON app.user_schedules(user_id, start_at);
CREATE INDEX IF NOT EXISTS idx_schedules_upcoming ON app.user_schedules(start_at) WHERE completed = FALSE;
CREATE INDEX IF NOT EXISTS idx_schedules_type ON app.user_schedules(user_id, schedule_type);

CREATE INDEX IF NOT EXISTS idx_sleep_user_date ON app.sleep_logs(user_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_behavior_user_type ON app.behavior_patterns(user_id, pattern_type);

CREATE INDEX IF NOT EXISTS idx_proactive_pending ON app.proactive_messages(scheduled_at) WHERE is_sent = FALSE;
CREATE INDEX IF NOT EXISTS idx_proactive_user ON app.proactive_messages(user_id, scheduled_at DESC);

CREATE INDEX IF NOT EXISTS idx_suggestions_user ON app.ai_suggestions(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_activity_user_time ON app.user_activity_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_type ON app.user_activity_logs(activity_type, created_at DESC);

-- ========== TRIGGERS ==========

DROP TRIGGER IF EXISTS trg_schedules_updated ON app.user_schedules;
CREATE TRIGGER trg_schedules_updated
    BEFORE UPDATE ON app.user_schedules
    FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();

-- ========== VIEWS ==========

-- View: Today's schedules
CREATE OR REPLACE VIEW app.v_today_schedules AS
SELECT 
    s.*,
    u.display_name as user_name
FROM app.user_schedules s
JOIN app.user_profiles u ON s.user_id = u.user_id
WHERE DATE(s.start_at) = CURRENT_DATE
  AND s.completed = FALSE
ORDER BY s.start_at;

-- View: User sleep summary (last 7 days)
CREATE OR REPLACE VIEW app.v_user_sleep_summary AS
SELECT 
    user_id,
    COUNT(*) as logged_days,
    AVG(duration_minutes) as avg_duration,
    AVG(quality) as avg_quality,
    MIN(sleep_at::time) as earliest_sleep,
    MAX(sleep_at::time) as latest_sleep,
    AVG(interruptions) as avg_interruptions
FROM app.sleep_logs
WHERE date > CURRENT_DATE - 7
GROUP BY user_id;

-- View: Inactive users (no activity in 24h)
CREATE OR REPLACE VIEW app.v_inactive_users AS
SELECT 
    s.user_id,
    s.persona_id,
    s.custom_nickname,
    MAX(a.created_at) as last_activity,
    EXTRACT(EPOCH FROM (NOW() - MAX(a.created_at)))/3600 as hours_inactive
FROM app.user_ai_settings s
LEFT JOIN app.user_activity_logs a ON s.user_id = a.user_id
WHERE s.notification_enabled = TRUE
GROUP BY s.user_id, s.persona_id, s.custom_nickname
HAVING MAX(a.created_at) < NOW() - INTERVAL '24 hours'
    OR MAX(a.created_at) IS NULL;

-- =============================================
-- AI COMPANION SYSTEM - PHASE 1 MIGRATION
-- Persona Engine + Notifications
-- =============================================

-- 1. AI Personas table
CREATE TABLE IF NOT EXISTS app.ai_personas (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    tone TEXT NOT NULL,                    -- 'warm', 'playful', 'mature', 'caring', 'friendly'
    emotion_pattern JSONB DEFAULT '{}',    -- How persona reacts to different emotions
    behavior_rules JSONB DEFAULT '{}',     -- Conversation rules, boundaries
    signature_messages TEXT[] DEFAULT '{}', -- Unique phrases for this persona
    avatar_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. User AI Settings table
CREATE TABLE IF NOT EXISTS app.user_ai_settings (
    user_id BIGINT PRIMARY KEY REFERENCES app.users(id) ON DELETE CASCADE,
    persona_id BIGINT REFERENCES app.ai_personas(id) ON DELETE SET NULL,
    relationship_level INT DEFAULT 1 CHECK (relationship_level BETWEEN 1 AND 4),
    custom_nickname TEXT,                  -- How AI calls the user
    user_nickname TEXT,                    -- How user calls the AI
    notification_enabled BOOLEAN DEFAULT TRUE,
    morning_checkin BOOLEAN DEFAULT TRUE,
    evening_checkin BOOLEAN DEFAULT TRUE,
    random_messages BOOLEAN DEFAULT TRUE,
    quiet_hours_start TIME DEFAULT '23:00',
    quiet_hours_end TIME DEFAULT '07:00',
    timezone TEXT DEFAULT 'Asia/Ho_Chi_Minh',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Scheduled Notifications table
CREATE TABLE IF NOT EXISTS app.ai_scheduled_notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    persona_id BIGINT REFERENCES app.ai_personas(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('morning', 'evening', 'checkin', 'reminder', 'random', 'emotion_based', 'schedule_based')),
    content TEXT NOT NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    is_sent BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. AI Conversation Context (for persona memory)
CREATE TABLE IF NOT EXISTS app.ai_conversation_context (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    context_type TEXT NOT NULL,            -- 'preference', 'memory', 'topic', 'emotion'
    context_key TEXT NOT NULL,
    context_value TEXT,
    importance INT DEFAULT 1,              -- 1-5, higher = more important to remember
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, context_type, context_key)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_ai_settings_persona ON app.user_ai_settings(persona_id);
CREATE INDEX IF NOT EXISTS idx_ai_notifications_user_scheduled ON app.ai_scheduled_notifications(user_id, scheduled_at) WHERE is_sent = FALSE;
CREATE INDEX IF NOT EXISTS idx_ai_notifications_pending ON app.ai_scheduled_notifications(scheduled_at) WHERE is_sent = FALSE;
CREATE INDEX IF NOT EXISTS idx_ai_context_user ON app.ai_conversation_context(user_id, context_type);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION app.fn_ai_touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ai_personas_updated ON app.ai_personas;
CREATE TRIGGER trg_ai_personas_updated
    BEFORE UPDATE ON app.ai_personas
    FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();

DROP TRIGGER IF EXISTS trg_user_ai_settings_updated ON app.user_ai_settings;
CREATE TRIGGER trg_user_ai_settings_updated
    BEFORE UPDATE ON app.user_ai_settings
    FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();

DROP TRIGGER IF EXISTS trg_ai_context_updated ON app.ai_conversation_context;
CREATE TRIGGER trg_ai_context_updated
    BEFORE UPDATE ON app.ai_conversation_context
    FOR EACH ROW EXECUTE FUNCTION app.fn_ai_touch_updated_at();

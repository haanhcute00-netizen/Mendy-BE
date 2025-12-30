-- =============================================
-- CHAT MODULE PHASE 1 MIGRATION
-- Date: 29/12/2024
-- Features: Reactions, Reply, Voice, Delete for all
-- =============================================

-- 1. Message Reactions (Healing-specific)
CREATE TABLE IF NOT EXISTS app.message_reactions (
  id SERIAL PRIMARY KEY,
  message_id INT NOT NULL REFERENCES app.chat_messages(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('HUG', 'STRONG', 'GRATEFUL', 'SUPPORT', 'UNDERSTOOD', 'GROWTH')),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(message_id, user_id, type)
);

CREATE INDEX IF NOT EXISTS idx_reactions_message ON app.message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_reactions_user ON app.message_reactions(user_id);

-- 2. Update chat_messages table for new features
ALTER TABLE app.chat_messages 
ADD COLUMN IF NOT EXISTS reply_to_id INT REFERENCES app.chat_messages(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS message_type VARCHAR(20) DEFAULT 'TEXT' CHECK (message_type IN ('TEXT', 'VOICE', 'IMAGE', 'FILE', 'SYSTEM')),
ADD COLUMN IF NOT EXISTS deleted_for_all BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS deleted_for_all_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS voice_url TEXT,
ADD COLUMN IF NOT EXISTS voice_duration_seconds INT,
ADD COLUMN IF NOT EXISTS file_url TEXT,
ADD COLUMN IF NOT EXISTS file_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS file_size INT,
ADD COLUMN IF NOT EXISTS file_mime_type VARCHAR(100);

CREATE INDEX IF NOT EXISTS idx_messages_reply ON app.chat_messages(reply_to_id) WHERE reply_to_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_messages_type ON app.chat_messages(message_type);

-- 3. Typing status tracking (optional, for persistence)
CREATE TABLE IF NOT EXISTS app.typing_status (
  thread_id INT NOT NULL REFERENCES app.chat_threads(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
  started_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (thread_id, user_id)
);

-- 4. Online status for users
ALTER TABLE app.users 
ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT FALSE;

-- 5. Create function to get message with reactions count
CREATE OR REPLACE FUNCTION app.get_message_reactions_summary(p_message_id INT)
RETURNS JSON AS $$
  SELECT COALESCE(
    json_object_agg(type, count),
    '{}'::json
  )
  FROM (
    SELECT type, COUNT(*) as count
    FROM app.message_reactions
    WHERE message_id = p_message_id
    GROUP BY type
  ) sub;
$$ LANGUAGE SQL STABLE;

-- 6. Add comment for documentation
COMMENT ON TABLE app.message_reactions IS 'Healing-specific reactions: HUG, STRONG, GRATEFUL, SUPPORT, UNDERSTOOD, GROWTH';
COMMENT ON COLUMN app.chat_messages.reply_to_id IS 'Reference to parent message for reply feature';
COMMENT ON COLUMN app.chat_messages.deleted_for_all IS 'Soft delete visible to all users';

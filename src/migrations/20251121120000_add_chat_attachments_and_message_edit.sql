-- Migration: add chat_attachments table and columns for message edit/delete
-- File: 20251121120000_add_chat_attachments_and_message_edit.sql

BEGIN;

-- 1. Table for attachments
CREATE TABLE IF NOT EXISTS app.chat_attachments (
  id SERIAL PRIMARY KEY,
  message_id INT REFERENCES app.chat_messages(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  url TEXT NOT NULL,
  size_bytes INT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_chat_attachments_message_id ON app.chat_attachments(message_id);

-- 2. Add edit/delete columns to messages
ALTER TABLE app.chat_messages
  ADD COLUMN IF NOT EXISTS edited_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_chat_messages_deleted ON app.chat_messages(deleted_at);

COMMIT;

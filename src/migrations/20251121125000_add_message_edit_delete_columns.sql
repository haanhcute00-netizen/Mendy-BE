-- Migration: add edited_at and deleted_at columns to chat_messages
-- File: 20251121125000_add_message_edit_delete_columns.sql

BEGIN;

ALTER TABLE IF EXISTS app.chat_messages
  ADD COLUMN IF NOT EXISTS edited_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_chat_messages_deleted ON app.chat_messages(deleted_at);

COMMIT;

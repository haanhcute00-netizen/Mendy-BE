-- Migration: add name column to chat_threads for group chats
-- File: 20251121124000_add_group_name_to_chat_threads.sql

BEGIN;

ALTER TABLE IF EXISTS app.chat_threads
  ADD COLUMN IF NOT EXISTS name TEXT;

CREATE INDEX IF NOT EXISTS idx_chat_threads_name ON app.chat_threads(name);

COMMIT;

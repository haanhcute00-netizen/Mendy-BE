-- Migration: add chat_thread_invitations table for group chat invitations
-- File: 20251121123000_add_chat_thread_invitations.sql

BEGIN;

CREATE TABLE IF NOT EXISTS app.chat_thread_invitations (
  id SERIAL PRIMARY KEY,
  thread_id INT REFERENCES app.chat_threads(id) ON DELETE CASCADE,
  inviter_id INT REFERENCES app.users(id),
  invitee_id INT REFERENCES app.users(id),
  status TEXT CHECK (status IN ('PENDING','ACCEPTED','REJECTED')) DEFAULT 'PENDING',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_thread_invitations_thread ON app.chat_thread_invitations(thread_id);
CREATE INDEX IF NOT EXISTS idx_chat_thread_invitations_invitee ON app.chat_thread_invitations(invitee_id);

COMMIT;

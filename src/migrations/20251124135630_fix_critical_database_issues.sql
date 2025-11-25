-- ===== UP =====

-- Add 'EXPIRED' value to payment_status enum
-- This is required by src/modules/bookings/bookingPayment.service.js
ALTER TYPE app.payment_status ADD VALUE IF NOT EXISTS 'EXPIRED';

-- Note: The following tables should already exist from previous migrations:
-- - app.chat_attachments (from 20251121120000_add_chat_attachments_and_message_edit.sql)
-- - app.chat_thread_invitations (from 20251121123000_add_chat_thread_invitations.sql)

-- Verify tables exist, if not create them
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

-- Ensure edited_at and deleted_at columns exist on chat_messages
ALTER TABLE app.chat_messages
  ADD COLUMN IF NOT EXISTS edited_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_chat_messages_deleted ON app.chat_messages(deleted_at);


-- ===== DOWN =====

-- Note: PostgreSQL does not support removing ENUM values directly
-- Rolling back 'EXPIRED' from payment_status would require recreating the entire enum
-- which could break existing data and constraints. 
-- This is not recommended for production databases.

-- DROP the tables and indexes if rolling back
DROP INDEX IF EXISTS app.idx_chat_messages_deleted;
DROP INDEX IF EXISTS app.idx_chat_thread_invitations_invitee;
DROP INDEX IF EXISTS app.idx_chat_thread_invitations_thread;
DROP INDEX IF EXISTS app.idx_chat_attachments_message_id;

-- Remove columns
ALTER TABLE app.chat_messages DROP COLUMN IF EXISTS deleted_at;
ALTER TABLE app.chat_messages DROP COLUMN IF EXISTS edited_at;

-- Drop tables
DROP TABLE IF EXISTS app.chat_thread_invitations;
DROP TABLE IF EXISTS app.chat_attachments;

-- CAUTION: Cannot remove 'EXPIRED' from payment_status enum without recreating the type
-- Manual intervention required if rollback is necessary

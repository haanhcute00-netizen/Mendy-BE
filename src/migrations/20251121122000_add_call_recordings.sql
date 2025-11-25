-- Migration: add call_recordings table
-- File: 20251121122000_add_call_recordings.sql

BEGIN;

CREATE TABLE IF NOT EXISTS app.call_recordings (
  id SERIAL PRIMARY KEY,
  call_id INT REFERENCES app.call_sessions(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  size_bytes INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_call_recordings_call_id ON app.call_recordings(call_id);

COMMIT;

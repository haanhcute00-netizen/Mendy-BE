-- Migration: add call_metrics table
-- File: 20251121121000_add_call_metrics.sql

BEGIN;

CREATE TABLE IF NOT EXISTS app.call_metrics (
  id SERIAL PRIMARY KEY,
  call_id INT REFERENCES app.call_sessions(id) ON DELETE CASCADE,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  rtt_ms INT,
  packet_loss FLOAT,
  jitter_ms INT
);

CREATE INDEX IF NOT EXISTS idx_call_metrics_call_id ON app.call_metrics(call_id);

COMMIT;

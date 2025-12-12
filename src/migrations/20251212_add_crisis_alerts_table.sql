-- Migration: Add crisis_alerts table for Task 3
-- Date: 2024-12-12

CREATE TABLE IF NOT EXISTS app.crisis_alerts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    alert_type VARCHAR(50) NOT NULL DEFAULT 'needs_support', -- 'crisis', 'needs_support', 'warning'
    severity VARCHAR(20) NOT NULL DEFAULT 'moderate', -- 'critical', 'high', 'moderate', 'low'
    trigger_text TEXT,
    emotion_data JSONB DEFAULT '{}',
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'acknowledged', 'in_progress', 'resolved', 'dismissed'
    resolved_by INTEGER REFERENCES app.users(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_crisis_alerts_user_id ON app.crisis_alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_crisis_alerts_status ON app.crisis_alerts(status);
CREATE INDEX IF NOT EXISTS idx_crisis_alerts_severity ON app.crisis_alerts(severity);
CREATE INDEX IF NOT EXISTS idx_crisis_alerts_created_at ON app.crisis_alerts(created_at DESC);

-- Composite index for admin dashboard queries
CREATE INDEX IF NOT EXISTS idx_crisis_alerts_pending_severity 
    ON app.crisis_alerts(status, severity, created_at) 
    WHERE status = 'pending';

COMMENT ON TABLE app.crisis_alerts IS 'Stores crisis detection alerts for user mental health monitoring';

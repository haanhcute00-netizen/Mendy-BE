-- Migration: Admin Extended Features
-- Date: 2025-12-05
-- Description: Add columns for admin management features (reviews hiding, recurring cancellation)

-- Add hidden columns to reviews table
ALTER TABLE app.reviews 
ADD COLUMN IF NOT EXISTS is_hidden BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS hidden_reason TEXT,
ADD COLUMN IF NOT EXISTS hidden_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS hidden_by BIGINT REFERENCES app.users(id);

-- Add cancel columns to recurring_templates if not exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'app' AND table_name = 'recurring_templates') THEN
        ALTER TABLE app.recurring_templates 
        ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP WITH TIME ZONE,
        ADD COLUMN IF NOT EXISTS cancel_reason TEXT;
    END IF;
END $$;

-- Add description column to skills table if not exists
ALTER TABLE app.skills 
ADD COLUMN IF NOT EXISTS description TEXT;

-- Create index for hidden reviews
CREATE INDEX IF NOT EXISTS idx_reviews_is_hidden ON app.reviews(is_hidden) WHERE is_hidden = true;

-- Create index for call sessions status
CREATE INDEX IF NOT EXISTS idx_call_sessions_status ON app.call_sessions(status);
CREATE INDEX IF NOT EXISTS idx_call_sessions_started_at ON app.call_sessions(started_at DESC);

-- Create index for disputes status
CREATE INDEX IF NOT EXISTS idx_disputes_status ON app.disputes(status);

-- Create index for refunds status
CREATE INDEX IF NOT EXISTS idx_refunds_status ON app.refunds(status);

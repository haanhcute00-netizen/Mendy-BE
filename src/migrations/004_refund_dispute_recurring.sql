-- Migration: Refund, Platform Fee, Dispute, Recurring Booking
-- Date: 2025-12-01

-- ===== UP =====

-- =====================================================
-- 1. ENUM TYPES
-- =====================================================

-- Refund status enum
CREATE TYPE app.refund_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);

-- Dispute status enum
CREATE TYPE app.dispute_status AS ENUM (
    'OPEN',
    'UNDER_REVIEW',
    'RESOLVED_SEEKER',
    'RESOLVED_EXPERT',
    'RESOLVED_PARTIAL',
    'CLOSED',
    'ESCALATED'
);

-- Dispute reason enum
CREATE TYPE app.dispute_reason AS ENUM (
    'NO_SHOW_EXPERT',
    'NO_SHOW_SEEKER',
    'POOR_QUALITY',
    'TECHNICAL_ISSUES',
    'INAPPROPRIATE_BEHAVIOR',
    'WRONG_EXPERTISE',
    'TIME_DISPUTE',
    'OTHER'
);

-- Recurring frequency enum
CREATE TYPE app.recurring_frequency AS ENUM (
    'DAILY',
    'WEEKLY',
    'BIWEEKLY',
    'MONTHLY'
);

-- =====================================================
-- 2. PLATFORM SETTINGS TABLE
-- =====================================================

CREATE TABLE app.platform_settings (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    key text UNIQUE NOT NULL,
    value jsonb NOT NULL,
    description text,
    updated_at timestamptz DEFAULT now(),
    updated_by bigint REFERENCES app.users(id)
);

-- Insert default platform fee settings
INSERT INTO app.platform_settings (key, value, description) VALUES
('platform_fee_percent', '15', 'Platform fee percentage (0-100)'),
('min_platform_fee', '5000', 'Minimum platform fee in VND'),
('refund_policy_hours', '24', 'Hours before booking start for full refund'),
('partial_refund_percent', '50', 'Partial refund percentage if cancelled within policy hours'),
('auto_complete_hours', '24', 'Hours after booking end to auto-complete');

-- =====================================================
-- 3. REFUNDS TABLE
-- =====================================================

CREATE TABLE app.refunds (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    booking_id bigint NOT NULL REFERENCES app.bookings(id),
    payment_intent_id bigint NOT NULL REFERENCES app.payment_intents(id),
    user_id bigint NOT NULL REFERENCES app.users(id),
    amount numeric(14,2) NOT NULL CHECK (amount > 0),
    platform_fee_refunded numeric(14,2) DEFAULT 0,
    reason text NOT NULL,
    status app.refund_status DEFAULT 'PENDING' NOT NULL,
    admin_note text,
    processed_by bigint REFERENCES app.users(id),
    processed_at timestamptz,
    provider_refund_id text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_refunds_booking ON app.refunds(booking_id);
CREATE INDEX idx_refunds_user ON app.refunds(user_id);
CREATE INDEX idx_refunds_status ON app.refunds(status);

-- =====================================================
-- 4. DISPUTES TABLE
-- =====================================================

CREATE TABLE app.disputes (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    booking_id bigint NOT NULL REFERENCES app.bookings(id),
    raised_by bigint NOT NULL REFERENCES app.users(id),
    against_user bigint NOT NULL REFERENCES app.users(id),
    reason app.dispute_reason NOT NULL,
    description text NOT NULL,
    evidence_urls text[],
    status app.dispute_status DEFAULT 'OPEN' NOT NULL,
    resolution text,
    refund_amount numeric(14,2),
    assigned_admin bigint REFERENCES app.users(id),
    resolved_at timestamptz,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT chk_different_users CHECK (raised_by <> against_user)
);

CREATE INDEX idx_disputes_booking ON app.disputes(booking_id);
CREATE INDEX idx_disputes_raised_by ON app.disputes(raised_by);
CREATE INDEX idx_disputes_status ON app.disputes(status);

-- Dispute messages for communication
CREATE TABLE app.dispute_messages (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    dispute_id bigint NOT NULL REFERENCES app.disputes(id) ON DELETE CASCADE,
    sender_id bigint NOT NULL REFERENCES app.users(id),
    message text NOT NULL,
    attachments text[],
    is_admin boolean DEFAULT false,
    created_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_dispute_messages_dispute ON app.dispute_messages(dispute_id);

-- =====================================================
-- 5. RECURRING BOOKINGS TABLE
-- =====================================================

CREATE TABLE app.recurring_booking_templates (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL REFERENCES app.users(id),
    expert_id bigint NOT NULL REFERENCES app.users(id),
    channel text NOT NULL CHECK (channel IN ('CHAT', 'VIDEO', 'AUDIO')),
    start_time time NOT NULL,
    duration_minutes integer NOT NULL CHECK (duration_minutes >= 60 AND duration_minutes <= 180),
    frequency app.recurring_frequency NOT NULL,
    day_of_week integer CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday
    day_of_month integer CHECK (day_of_month >= 1 AND day_of_month <= 31),
    price_per_session numeric(12,2) NOT NULL CHECK (price_per_session >= 0),
    total_sessions integer, -- NULL = unlimited
    sessions_completed integer DEFAULT 0,
    is_active boolean DEFAULT true,
    next_booking_date date,
    starts_from date NOT NULL,
    ends_at date, -- NULL = no end date
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT chk_expert_not_self CHECK (user_id <> expert_id)
);

CREATE INDEX idx_recurring_templates_user ON app.recurring_booking_templates(user_id);
CREATE INDEX idx_recurring_templates_expert ON app.recurring_booking_templates(expert_id);
CREATE INDEX idx_recurring_templates_active ON app.recurring_booking_templates(is_active) WHERE is_active = true;
CREATE INDEX idx_recurring_templates_next_date ON app.recurring_booking_templates(next_booking_date) WHERE is_active = true;

-- Link recurring template to generated bookings
ALTER TABLE app.bookings ADD COLUMN recurring_template_id bigint REFERENCES app.recurring_booking_templates(id);
ALTER TABLE app.bookings ADD COLUMN is_recurring boolean DEFAULT false;

-- =====================================================
-- 6. BOOKING FEE BREAKDOWN TABLE
-- =====================================================

CREATE TABLE app.booking_fees (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    booking_id bigint UNIQUE NOT NULL REFERENCES app.bookings(id),
    gross_amount numeric(14,2) NOT NULL,
    platform_fee numeric(14,2) NOT NULL,
    platform_fee_percent numeric(5,2) NOT NULL,
    expert_earning numeric(14,2) NOT NULL,
    tax_amount numeric(14,2) DEFAULT 0,
    created_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_booking_fees_booking ON app.booking_fees(booking_id);

-- =====================================================
-- 7. UPDATE WALLET LEDGER FOR REFUNDS
-- =====================================================

-- Add PLATFORM_FEE to wallet_tx_type if not exists
DO $$
BEGIN
    ALTER TYPE app.wallet_tx_type ADD VALUE IF NOT EXISTS 'PLATFORM_FEE';
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- =====================================================
-- 8. TRIGGERS
-- =====================================================

-- Auto-update updated_at for refunds
CREATE OR REPLACE FUNCTION app.fn_refunds_touch_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_refunds_updated_at
    BEFORE UPDATE ON app.refunds
    FOR EACH ROW EXECUTE FUNCTION app.fn_refunds_touch_updated_at();

-- Auto-update updated_at for disputes
CREATE OR REPLACE FUNCTION app.fn_disputes_touch_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_disputes_updated_at
    BEFORE UPDATE ON app.disputes
    FOR EACH ROW EXECUTE FUNCTION app.fn_disputes_touch_updated_at();

-- Auto-update updated_at for recurring templates
CREATE TRIGGER trg_recurring_templates_updated_at
    BEFORE UPDATE ON app.recurring_booking_templates
    FOR EACH ROW EXECUTE FUNCTION app.fn_disputes_touch_updated_at();


-- ===== DOWN =====

-- Drop triggers
DROP TRIGGER IF EXISTS trg_recurring_templates_updated_at ON app.recurring_booking_templates;
DROP TRIGGER IF EXISTS trg_disputes_updated_at ON app.disputes;
DROP TRIGGER IF EXISTS trg_refunds_updated_at ON app.refunds;

-- Drop functions
DROP FUNCTION IF EXISTS app.fn_disputes_touch_updated_at();
DROP FUNCTION IF EXISTS app.fn_refunds_touch_updated_at();

-- Drop columns from bookings
ALTER TABLE app.bookings DROP COLUMN IF EXISTS is_recurring;
ALTER TABLE app.bookings DROP COLUMN IF EXISTS recurring_template_id;

-- Drop tables
DROP TABLE IF EXISTS app.booking_fees;
DROP TABLE IF EXISTS app.recurring_booking_templates;
DROP TABLE IF EXISTS app.dispute_messages;
DROP TABLE IF EXISTS app.disputes;
DROP TABLE IF EXISTS app.refunds;
DROP TABLE IF EXISTS app.platform_settings;

-- Drop enum types
DROP TYPE IF EXISTS app.recurring_frequency;
DROP TYPE IF EXISTS app.dispute_reason;
DROP TYPE IF EXISTS app.dispute_status;
DROP TYPE IF EXISTS app.refund_status;

-- ===== UP =====
-- Migration: Add password reset functionality
-- Date: 2025-12-12
-- Description: Table to store password reset OTP codes

CREATE TABLE IF NOT EXISTS app.password_resets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    otp_code CHAR(6) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT
);

-- Index for fast lookup
CREATE INDEX idx_password_resets_email ON app.password_resets(email);
CREATE INDEX idx_password_resets_user_expires ON app.password_resets(user_id, expires_at DESC);

-- Cleanup old records (keep last 30 days)
CREATE INDEX idx_password_resets_created ON app.password_resets(created_at);

COMMENT ON TABLE app.password_resets IS 'Store OTP codes for password reset requests';

-- ===== DOWN =====
-- DROP INDEX IF EXISTS app.idx_password_resets_created;
-- DROP INDEX IF EXISTS app.idx_password_resets_user_expires;
-- DROP INDEX IF EXISTS app.idx_password_resets_email;
-- DROP TABLE IF EXISTS app.password_resets;

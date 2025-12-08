-- Migration: Add indexes for analytics performance
-- Created: 2025-12-08
-- Description: Add indexes to improve analytics query performance

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_created_at ON app.users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_status_created ON app.users(status, created_at);
CREATE INDEX IF NOT EXISTS idx_users_role_created ON app.users(role_primary, created_at);

-- Bookings indexes
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON app.bookings(created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_status_created ON app.bookings(status, created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_expert_created ON app.bookings(expert_id, created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_user_created ON app.bookings(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_start_at ON app.bookings(start_at);

-- Payment intents indexes
CREATE INDEX IF NOT EXISTS idx_payment_intents_status_created ON app.payment_intents(status, created_at);
CREATE INDEX IF NOT EXISTS idx_payment_intents_user_created ON app.payment_intents(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_payment_intents_provider ON app.payment_intents(provider);

-- Posts indexes
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON app.posts(created_at);
CREATE INDEX IF NOT EXISTS idx_posts_author_created ON app.posts(author_id, created_at);
CREATE INDEX IF NOT EXISTS idx_posts_privacy ON app.posts(privacy);

-- Reports indexes
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON app.reports(created_at);
CREATE INDEX IF NOT EXISTS idx_reports_status ON app.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_target ON app.reports(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_reports_status_created ON app.reports(status, created_at);

-- Comments indexes
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON app.comments(created_at);
CREATE INDEX IF NOT EXISTS idx_comments_post_created ON app.comments(post_id, created_at);

-- Chat messages indexes
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON app.chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_messages_thread_created ON app.chat_messages(thread_id, created_at);

-- Call sessions indexes
CREATE INDEX IF NOT EXISTS idx_call_sessions_started_at ON app.call_sessions(started_at);
CREATE INDEX IF NOT EXISTS idx_call_sessions_status ON app.call_sessions(status);

-- Wallet ledger indexes
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_created_at ON app.wallet_ledger(created_at);
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_wallet_created ON app.wallet_ledger(wallet_id, created_at);
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_tx_type ON app.wallet_ledger(tx_type);

-- Payout requests indexes
CREATE INDEX IF NOT EXISTS idx_payout_requests_status ON app.payout_requests(status);
CREATE INDEX IF NOT EXISTS idx_payout_requests_user_created ON app.payout_requests(user_id, created_at);

-- Reviews indexes
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON app.reviews(created_at);
CREATE INDEX IF NOT EXISTS idx_reviews_expert_created ON app.reviews(expert_id, created_at);

-- Refunds indexes
CREATE INDEX IF NOT EXISTS idx_refunds_status ON app.refunds(status);
CREATE INDEX IF NOT EXISTS idx_refunds_created_at ON app.refunds(created_at);

-- Disputes indexes
CREATE INDEX IF NOT EXISTS idx_disputes_status ON app.disputes(status);
CREATE INDEX IF NOT EXISTS idx_disputes_created_at ON app.disputes(created_at);

-- Expert profiles indexes
CREATE INDEX IF NOT EXISTS idx_expert_profiles_kyc_status ON app.expert_profiles(kyc_status);

-- Audit logs indexes (for active users tracking)
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_created ON app.audit_logs(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON app.audit_logs(created_at);

COMMENT ON INDEX app.idx_users_created_at IS 'For user growth analytics';
COMMENT ON INDEX app.idx_bookings_status_created IS 'For booking analytics by status and date';
COMMENT ON INDEX app.idx_payment_intents_status_created IS 'For revenue analytics';
COMMENT ON INDEX app.idx_reports_status_created IS 'For moderation analytics';

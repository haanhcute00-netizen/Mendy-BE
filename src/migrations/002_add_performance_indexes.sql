-- ===== UP =====

-- Performance indexes for common queries

-- =====================
-- User & Authentication
-- =====================
CREATE INDEX IF NOT EXISTS idx_users_handle ON app.users(handle);
CREATE INDEX IF NOT EXISTS idx_users_email ON app.users(email);
CREATE INDEX IF NOT EXISTS idx_users_status ON app.users(status);
CREATE INDEX IF NOT EXISTS idx_users_role_primary ON app.users(role_primary);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON app.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON app.user_sessions(token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON app.user_sessions(expires_at);

-- =====================
-- Expert System
-- =====================
CREATE INDEX IF NOT EXISTS idx_expert_profiles_user_id ON app.expert_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_expert_profiles_kyc_status ON app.expert_profiles(kyc_status);
CREATE INDEX IF NOT EXISTS idx_expert_profiles_rating_avg ON app.expert_profiles(rating_avg DESC);

CREATE INDEX IF NOT EXISTS idx_expert_availabilities_expert_id ON app.expert_availabilities(expert_id);
CREATE INDEX IF NOT EXISTS idx_expert_availabilities_start_at ON app.expert_availabilities(start_at);

-- =====================
-- Bookings
-- =====================
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON app.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_expert_id ON app.bookings(expert_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON app.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON app.bookings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bookings_start_at ON app.bookings(start_at);

-- =====================
-- Payments
-- =====================
CREATE INDEX IF NOT EXISTS idx_payment_intents_user_id ON app.payment_intents(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_booking_id ON app.payment_intents(booking_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_status ON app.payment_intents(status);
CREATE INDEX IF NOT EXISTS idx_payment_intents_tx_ref ON app.payment_intents(tx_ref);

CREATE INDEX IF NOT EXISTS idx_payments_intent_id ON app.payments(intent_id);

-- =====================
-- Wallet
-- =====================
CREATE INDEX IF NOT EXISTS idx_wallets_owner_user_id ON app.wallets(owner_user_id);

CREATE INDEX IF NOT EXISTS idx_wallet_ledger_wallet_id ON app.wallet_ledger(wallet_id);
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_tx_type ON app.wallet_ledger(tx_type);
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_created_at ON app.wallet_ledger(created_at DESC);

-- =====================
-- Posts & Comments
-- =====================
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON app.posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON app.posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_privacy ON app.posts(privacy);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON app.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author_id ON app.comments(author_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON app.comments(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON app.comments(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_post_reactions_post_id ON app.post_reactions(post_id);
CREATE INDEX IF NOT EXISTS idx_post_reactions_user_id ON app.post_reactions(user_id);

-- =====================
-- Chat
-- =====================
CREATE INDEX IF NOT EXISTS idx_chat_threads_booking_id ON app.chat_threads(booking_id) WHERE booking_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_chat_threads_last_message_at ON app.chat_threads(last_message_at DESC);

CREATE INDEX IF NOT EXISTS idx_chat_members_thread_id ON app.chat_members(thread_id);
CREATE INDEX IF NOT EXISTS idx_chat_members_user_id ON app.chat_members(user_id);

CREATE INDEX IF NOT EXISTS idx_chat_messages_thread_id ON app.chat_messages(thread_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON app.chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON app.chat_messages(created_at DESC);

-- =====================
-- Reviews
-- =====================
CREATE INDEX IF NOT EXISTS idx_reviews_expert_id ON app.reviews(expert_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON app.reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_booking_id ON app.reviews(booking_id);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON app.reviews(created_at DESC);

-- =====================
-- Audit & Admin
-- =====================
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON app.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON app.audit_logs(resource, resource_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON app.audit_logs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_reports_target ON app.reports(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter_id ON app.reports(reporter_id);


-- ===== DOWN =====

-- Drop indexes in reverse order

-- Audit & Admin
DROP INDEX IF EXISTS app.idx_reports_reporter_id;
DROP INDEX IF EXISTS app.idx_reports_target;
DROP INDEX IF EXISTS app.idx_audit_logs_created_at;
DROP INDEX IF EXISTS app.idx_audit_logs_resource;
DROP INDEX IF EXISTS app.idx_audit_logs_user_id;

-- Reviews
DROP INDEX IF EXISTS app.idx_reviews_created_at;
DROP INDEX IF EXISTS app.idx_reviews_booking_id;
DROP INDEX IF EXISTS app.idx_reviews_user_id;
DROP INDEX IF EXISTS app.idx_reviews_expert_id;

-- Chat
DROP INDEX IF EXISTS app.idx_chat_messages_created_at;
DROP INDEX IF EXISTS app.idx_chat_messages_sender_id;
DROP INDEX IF EXISTS app.idx_chat_messages_thread_id;
DROP INDEX IF EXISTS app.idx_chat_members_user_id;
DROP INDEX IF EXISTS app.idx_chat_members_thread_id;
DROP INDEX IF EXISTS app.idx_chat_threads_last_message_at;
DROP INDEX IF EXISTS app.idx_chat_threads_booking_id;

-- Posts & Comments
DROP INDEX IF EXISTS app.idx_post_reactions_user_id;
DROP INDEX IF EXISTS app.idx_post_reactions_post_id;
DROP INDEX IF EXISTS app.idx_comments_created_at;
DROP INDEX IF EXISTS app.idx_comments_parent_id;
DROP INDEX IF EXISTS app.idx_comments_author_id;
DROP INDEX IF EXISTS app.idx_comments_post_id;
DROP INDEX IF EXISTS app.idx_posts_privacy;
DROP INDEX IF EXISTS app.idx_posts_created_at;
DROP INDEX IF EXISTS app.idx_posts_author_id;

-- Wallet
DROP INDEX IF EXISTS app.idx_wallet_ledger_created_at;
DROP INDEX IF EXISTS app.idx_wallet_ledger_tx_type;
DROP INDEX IF EXISTS app.idx_wallet_ledger_wallet_id;
DROP INDEX IF EXISTS app.idx_wallets_owner_user_id;

-- Payments
DROP INDEX IF EXISTS app.idx_payments_intent_id;
DROP INDEX IF EXISTS app.idx_payment_intents_tx_ref;
DROP INDEX IF EXISTS app.idx_payment_intents_status;
DROP INDEX IF EXISTS app.idx_payment_intents_booking_id;
DROP INDEX IF EXISTS app.idx_payment_intents_user_id;

-- Bookings
DROP INDEX IF EXISTS app.idx_bookings_start_at;
DROP INDEX IF EXISTS app.idx_bookings_created_at;
DROP INDEX IF EXISTS app.idx_bookings_status;
DROP INDEX IF EXISTS app.idx_bookings_expert_id;
DROP INDEX IF EXISTS app.idx_bookings_user_id;

-- Expert System
DROP INDEX IF EXISTS app.idx_expert_availabilities_start_at;
DROP INDEX IF EXISTS app.idx_expert_availabilities_expert_id;
DROP INDEX IF EXISTS app.idx_expert_profiles_rating_avg;
DROP INDEX IF EXISTS app.idx_expert_profiles_kyc_status;
DROP INDEX IF EXISTS app.idx_expert_profiles_user_id;

-- User & Authentication
DROP INDEX IF EXISTS app.idx_user_sessions_expires_at;
DROP INDEX IF EXISTS app.idx_user_sessions_token;
DROP INDEX IF EXISTS app.idx_user_sessions_user_id;
DROP INDEX IF EXISTS app.idx_users_role_primary;
DROP INDEX IF EXISTS app.idx_users_status;
DROP INDEX IF EXISTS app.idx_users_email;
DROP INDEX IF EXISTS app.idx_users_handle;

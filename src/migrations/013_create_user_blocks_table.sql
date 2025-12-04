-- ===== UP =====
-- Create user_blocks table for blocking functionality
CREATE TABLE IF NOT EXISTS app.user_blocks (
    blocker_id bigint NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    blocked_id bigint NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (blocker_id, blocked_id),
    CONSTRAINT user_blocks_no_self_block CHECK (blocker_id != blocked_id)
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker ON app.user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked ON app.user_blocks(blocked_id);

-- ===== DOWN =====
-- DROP TABLE IF EXISTS app.user_blocks;

-- ===== UP =====

-- Add new transaction types if they don't exist
ALTER TYPE app.wallet_tx_type ADD VALUE IF NOT EXISTS 'PAYOUT';

-- Create payout_requests table
CREATE TABLE IF NOT EXISTS app.payout_requests (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL,
    amount numeric(14,2) NOT NULL,
    status text NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'PROCESSED')),
    payout_account_id bigint NOT NULL,
    admin_note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payout_requests_amount_check CHECK (amount > 0)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_payout_requests_user_id ON app.payout_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_payout_requests_status ON app.payout_requests(status);


-- ===== DOWN =====

-- Drop indexes
DROP INDEX IF EXISTS app.idx_payout_requests_status;
DROP INDEX IF EXISTS app.idx_payout_requests_user_id;

-- Drop table
DROP TABLE IF EXISTS app.payout_requests;

-- Note: Cannot remove ENUM value 'PAYOUT' from wallet_tx_type
-- PostgreSQL does not support removing ENUM values
-- This would require manual intervention or recreating the ENUM type

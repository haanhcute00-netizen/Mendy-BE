-- Migration: Create product_reviews table
-- File: 20251129100000_create_product_reviews.sql

-- ===== UP =====

BEGIN;

-- Create product_reviews table
CREATE TABLE IF NOT EXISTS app.product_reviews (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT uq_product_reviews_product_user UNIQUE (product_id, user_id)
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_product_reviews_product_id ON app.product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_user_id ON app.product_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_rating ON app.product_reviews(rating);
CREATE INDEX IF NOT EXISTS idx_product_reviews_created_at ON app.product_reviews(created_at DESC);

COMMIT;

-- ===== DOWN =====

-- Drop indexes
DROP INDEX IF EXISTS app.idx_product_reviews_created_at;
DROP INDEX IF EXISTS app.idx_product_reviews_rating;
DROP INDEX IF EXISTS app.idx_product_reviews_user_id;
DROP INDEX IF EXISTS app.idx_product_reviews_product_id;

-- Drop table
DROP TABLE IF EXISTS app.product_reviews;

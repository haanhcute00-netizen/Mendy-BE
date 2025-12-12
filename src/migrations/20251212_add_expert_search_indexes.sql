-- Migration: Add indexes for expert search optimization (Task 15)
-- Date: 2024-12-12

-- GIN index for specialties array search
CREATE INDEX IF NOT EXISTS idx_expert_profiles_specialties_gin 
    ON app.expert_profiles USING GIN (specialties);

-- Index for rating_avg sorting
CREATE INDEX IF NOT EXISTS idx_expert_profiles_rating_avg 
    ON app.expert_profiles (rating_avg DESC NULLS LAST);

-- Composite index for common expert search query
CREATE INDEX IF NOT EXISTS idx_expert_profiles_search 
    ON app.expert_profiles (rating_avg DESC NULLS LAST) 
    INCLUDE (price_per_session, intro);

-- Index for expert_status active_score
CREATE INDEX IF NOT EXISTS idx_expert_status_active_score 
    ON app.expert_status (active_score DESC);

-- Composite index for expert join queries
CREATE INDEX IF NOT EXISTS idx_expert_status_expert_id_score 
    ON app.expert_status (expert_id, active_score DESC);

COMMENT ON INDEX app.idx_expert_profiles_specialties_gin IS 'GIN index for fast array containment queries on specialties';
COMMENT ON INDEX app.idx_expert_profiles_rating_avg IS 'Index for sorting experts by rating';

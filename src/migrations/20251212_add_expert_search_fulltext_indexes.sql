-- Migration: Add trigram indexes for expert search full-text search
-- Task 3: Full-Text Search Index
-- Task 4: Add indexes for sorting columns
-- Date: 2025-12-12
-- Note: Removed CONCURRENTLY as it cannot run inside transaction block

-- Enable pg_trgm extension for trigram-based text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create GIN index for display_name (user profiles)
-- This enables fast ILIKE searches on expert names
CREATE INDEX IF NOT EXISTS idx_user_profiles_display_name_trgm 
ON app.user_profiles USING GIN (display_name gin_trgm_ops);

-- Create GIN index for intro (expert profiles)
-- This enables fast ILIKE searches on expert introductions
CREATE INDEX IF NOT EXISTS idx_expert_profiles_intro_trgm 
ON app.expert_profiles USING GIN (intro gin_trgm_ops);

-- Create GIN index for specialties array
-- This enables fast array overlap searches
CREATE INDEX IF NOT EXISTS idx_expert_profiles_specialties_gin
ON app.expert_profiles USING GIN (specialties);

-- Index for rating_avg (most common sort)
CREATE INDEX IF NOT EXISTS idx_expert_profiles_rating 
ON app.expert_profiles(rating_avg DESC NULLS LAST);

-- Index for price_per_session (price sorting)
CREATE INDEX IF NOT EXISTS idx_expert_profiles_price 
ON app.expert_profiles(price_per_session ASC);

-- Index for total_sessions (experience sorting)
CREATE INDEX IF NOT EXISTS idx_expert_performance_sessions 
ON app.expert_performance(total_sessions DESC);

-- Index for response_time_avg (fast responders)
CREATE INDEX IF NOT EXISTS idx_expert_performance_response 
ON app.expert_performance(response_time_avg ASC NULLS LAST);

-- Index for active_score (online/active sorting)
CREATE INDEX IF NOT EXISTS idx_expert_status_active 
ON app.expert_status(active_score DESC);

-- Index for total_reviews (reviews sorting)
CREATE INDEX IF NOT EXISTS idx_expert_performance_reviews
ON app.expert_performance(total_reviews DESC);

-- Index for completion_rate (reliability sorting)
CREATE INDEX IF NOT EXISTS idx_expert_performance_completion
ON app.expert_performance(completion_rate DESC);

-- Composite index for common filter combinations
CREATE INDEX IF NOT EXISTS idx_expert_profiles_kyc_rating
ON app.expert_profiles(kyc_status, rating_avg DESC NULLS LAST);

-- Index for online status filtering
CREATE INDEX IF NOT EXISTS idx_expert_status_online
ON app.expert_status(is_online, last_active_at DESC NULLS LAST);

-- Index for skills lookup
CREATE INDEX IF NOT EXISTS idx_expert_skills_expert_id
ON app.expert_skills(expert_id);

CREATE INDEX IF NOT EXISTS idx_expert_skills_skill_id
ON app.expert_skills(skill_id);

-- Index for certifications lookup
CREATE INDEX IF NOT EXISTS idx_expert_certifications_expert_id
ON app.expert_certifications(expert_id);

-- Index for education lookup
CREATE INDEX IF NOT EXISTS idx_expert_education_expert_id
ON app.expert_education(expert_id);

-- Index for experience lookup
CREATE INDEX IF NOT EXISTS idx_expert_experience_expert_id
ON app.expert_experience(expert_id);

-- Index for audience/domain lookups
CREATE INDEX IF NOT EXISTS idx_expert_audience_expert_id
ON app.expert_audience(expert_id);

CREATE INDEX IF NOT EXISTS idx_expert_domain_expert_id
ON app.expert_domain(expert_id);

-- Analyze tables to update statistics
ANALYZE app.user_profiles;
ANALYZE app.expert_profiles;
ANALYZE app.expert_performance;
ANALYZE app.expert_status;
ANALYZE app.expert_skills;

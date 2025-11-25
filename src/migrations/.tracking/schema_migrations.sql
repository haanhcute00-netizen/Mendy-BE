-- Migration tracking table
-- This table keeps track of which migrations have been executed

CREATE TABLE IF NOT EXISTS app.schema_migrations (
    id SERIAL PRIMARY KEY,
    version TEXT NOT NULL UNIQUE,
    name TEXT,
    executed_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_schema_migrations_version 
    ON app.schema_migrations(version);

-- Insert this tracking migration as executed
INSERT INTO app.schema_migrations (version, name) 
VALUES ('000_tracking', 'Initialize migration tracking')
ON CONFLICT (version) DO NOTHING;

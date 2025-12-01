-- Migration: Admin Enhancements
-- Description: Add report resolution, payout admin fields, and comment moderation support
-- Created: 2025-11-29

-- ===== UP =====

-- 1. Add status and resolution fields to reports table
ALTER TABLE app.reports 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'PENDING' 
    CHECK (status IN ('PENDING', 'RESOLVED', 'DISMISSED', 'IN_REVIEW'));

ALTER TABLE app.reports 
ADD COLUMN IF NOT EXISTS resolved_by BIGINT REFERENCES app.users(id);

ALTER TABLE app.reports 
ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ;

ALTER TABLE app.reports 
ADD COLUMN IF NOT EXISTS resolution_note TEXT;

ALTER TABLE app.reports 
ADD COLUMN IF NOT EXISTS action_taken TEXT 
    CHECK (action_taken IN ('NONE', 'WARNING', 'CONTENT_HIDDEN', 'CONTENT_DELETED', 'USER_SUSPENDED', 'USER_BANNED'));

-- 2. Add processed_by and processed_at to payout_requests for better tracking
ALTER TABLE app.payout_requests 
ADD COLUMN IF NOT EXISTS processed_by BIGINT REFERENCES app.users(id);

ALTER TABLE app.payout_requests 
ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;

-- 3. Create index for faster report queries
CREATE INDEX IF NOT EXISTS idx_reports_status ON app.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_target ON app.reports(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON app.reports(created_at DESC);

-- 4. Create index for payout queries
CREATE INDEX IF NOT EXISTS idx_payout_requests_status ON app.payout_requests(status);
CREATE INDEX IF NOT EXISTS idx_payout_requests_user ON app.payout_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_payout_requests_created ON app.payout_requests(created_at DESC);

-- 5. Add moderation_status to comments for content moderation
ALTER TABLE app.comments 
ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'APPROVED'
    CHECK (moderation_status IN ('PENDING', 'APPROVED', 'HIDDEN', 'DELETED'));

ALTER TABLE app.comments 
ADD COLUMN IF NOT EXISTS moderated_by BIGINT REFERENCES app.users(id);

ALTER TABLE app.comments 
ADD COLUMN IF NOT EXISTS moderated_at TIMESTAMPTZ;

ALTER TABLE app.comments 
ADD COLUMN IF NOT EXISTS moderation_reason TEXT;

-- 6. Create index for comment moderation
CREATE INDEX IF NOT EXISTS idx_comments_moderation_status ON app.comments(moderation_status);

-- 7. Add report_count cache to posts and comments for faster flagged content queries
ALTER TABLE app.posts 
ADD COLUMN IF NOT EXISTS report_count INTEGER DEFAULT 0;

ALTER TABLE app.comments 
ADD COLUMN IF NOT EXISTS report_count INTEGER DEFAULT 0;

-- 8. Create function to update report_count on posts
CREATE OR REPLACE FUNCTION app.update_post_report_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.target_type = 'POST' THEN
        UPDATE app.posts SET report_count = report_count + 1 WHERE id = NEW.target_id;
    ELSIF TG_OP = 'DELETE' AND OLD.target_type = 'POST' THEN
        UPDATE app.posts SET report_count = GREATEST(0, report_count - 1) WHERE id = OLD.target_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 9. Create function to update report_count on comments
CREATE OR REPLACE FUNCTION app.update_comment_report_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.target_type = 'COMMENT' THEN
        UPDATE app.comments SET report_count = report_count + 1 WHERE id = NEW.target_id;
    ELSIF TG_OP = 'DELETE' AND OLD.target_type = 'COMMENT' THEN
        UPDATE app.comments SET report_count = GREATEST(0, report_count - 1) WHERE id = OLD.target_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 10. Create triggers
DROP TRIGGER IF EXISTS trg_update_post_report_count ON app.reports;
CREATE TRIGGER trg_update_post_report_count
    AFTER INSERT OR DELETE ON app.reports
    FOR EACH ROW
    EXECUTE FUNCTION app.update_post_report_count();

DROP TRIGGER IF EXISTS trg_update_comment_report_count ON app.reports;
CREATE TRIGGER trg_update_comment_report_count
    AFTER INSERT OR DELETE ON app.reports
    FOR EACH ROW
    EXECUTE FUNCTION app.update_comment_report_count();

-- 11. Update existing report counts
UPDATE app.posts p SET report_count = (
    SELECT COUNT(*) FROM app.reports r WHERE r.target_type = 'POST' AND r.target_id = p.id
);

UPDATE app.comments c SET report_count = (
    SELECT COUNT(*) FROM app.reports r WHERE r.target_type = 'COMMENT' AND r.target_id = c.id
);

-- ===== DOWN =====
-- DROP TRIGGER IF EXISTS trg_update_comment_report_count ON app.reports;
-- DROP TRIGGER IF EXISTS trg_update_post_report_count ON app.reports;
-- DROP FUNCTION IF EXISTS app.update_comment_report_count();
-- DROP FUNCTION IF EXISTS app.update_post_report_count();
-- ALTER TABLE app.comments DROP COLUMN IF EXISTS report_count;
-- ALTER TABLE app.posts DROP COLUMN IF EXISTS report_count;
-- DROP INDEX IF EXISTS app.idx_comments_moderation_status;
-- ALTER TABLE app.comments DROP COLUMN IF EXISTS moderation_reason;
-- ALTER TABLE app.comments DROP COLUMN IF EXISTS moderated_at;
-- ALTER TABLE app.comments DROP COLUMN IF EXISTS moderated_by;
-- ALTER TABLE app.comments DROP COLUMN IF EXISTS moderation_status;
-- DROP INDEX IF EXISTS app.idx_payout_requests_created;
-- DROP INDEX IF EXISTS app.idx_payout_requests_user;
-- DROP INDEX IF EXISTS app.idx_payout_requests_status;
-- ALTER TABLE app.payout_requests DROP COLUMN IF EXISTS processed_at;
-- ALTER TABLE app.payout_requests DROP COLUMN IF EXISTS processed_by;
-- DROP INDEX IF EXISTS app.idx_reports_created_at;
-- DROP INDEX IF EXISTS app.idx_reports_target;
-- DROP INDEX IF EXISTS app.idx_reports_status;
-- ALTER TABLE app.reports DROP COLUMN IF EXISTS action_taken;
-- ALTER TABLE app.reports DROP COLUMN IF EXISTS resolution_note;
-- ALTER TABLE app.reports DROP COLUMN IF EXISTS resolved_at;
-- ALTER TABLE app.reports DROP COLUMN IF EXISTS resolved_by;
-- ALTER TABLE app.reports DROP COLUMN IF EXISTS status;

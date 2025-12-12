-- ===== UP =====
-- Migration: Add email unique constraint and indexes for email login support
-- Date: 2025-12-08
-- Description: Enable login by email while maintaining backward compatibility with handle

-- Bước 1: Thêm unique constraint cho email (cho phép NULL)
-- Chỉ emails không NULL mới phải unique
CREATE UNIQUE INDEX idx_users_email_unique 
ON app.users (email) 
WHERE email IS NOT NULL;

-- Bước 2: Thêm index cho email lookup (case-insensitive)
-- Sử dụng LOWER() để search không phân biệt hoa thường
CREATE INDEX idx_users_email_lower 
ON app.users (LOWER(email));

-- Bước 3: Thêm function để validate email format
CREATE OR REPLACE FUNCTION app.validate_email_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email IS NOT NULL AND NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bước 4: Thêm trigger để validate email khi insert/update
CREATE TRIGGER trg_validate_email
BEFORE INSERT OR UPDATE ON app.users
FOR EACH ROW
EXECUTE FUNCTION app.validate_email_format();

-- Comments for documentation
COMMENT ON INDEX app.idx_users_email_unique IS 'Ensure email uniqueness when provided (NULL allowed)';
COMMENT ON INDEX app.idx_users_email_lower IS 'Fast case-insensitive email lookup for login';
COMMENT ON FUNCTION app.validate_email_format() IS 'Validate email format before insert/update';

-- ===== DOWN =====
-- Rollback script

DROP TRIGGER IF EXISTS trg_validate_email ON app.users;
DROP FUNCTION IF EXISTS app.validate_email_format();
DROP INDEX IF EXISTS app.idx_users_email_lower;
DROP INDEX IF EXISTS app.idx_users_email_unique;

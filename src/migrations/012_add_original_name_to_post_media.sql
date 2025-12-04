-- ===== UP =====
-- Add original_name column to store the original filename uploaded by user
ALTER TABLE app.post_media 
ADD COLUMN IF NOT EXISTS original_name text,
ADD COLUMN IF NOT EXISTS public_id text;

-- Add comment for documentation
COMMENT ON COLUMN app.post_media.original_name IS 'Original filename from user upload';
COMMENT ON COLUMN app.post_media.public_id IS 'Cloudinary public_id for file management';

-- ===== DOWN =====
-- ALTER TABLE app.post_media DROP COLUMN IF EXISTS original_name;
-- ALTER TABLE app.post_media DROP COLUMN IF EXISTS public_id;

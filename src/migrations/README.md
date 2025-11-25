# Database Migrations

Migration system cho Healing_BE database schema changes.

## Cấu trúc

```
migrations/
├── .tracking/
│   └── schema_migrations.sql    # Tracking table
├── 001_*.sql                     # Migration files (numbered)
├── 002_*.sql
└── README.md
```

## Commands

### Chạy migrations
```bash
npm run migrate:up
```
Chạy tất cả pending migrations theo thứ tự.

### Rollback migration cuối
```bash
npm run migrate:down
```
Rollback migration cuối cùng đã chạy.

### Xem trạng thái
```bash
npm run migrate:status
```
Hiển thị danh sách migrations và trạng thái (executed/pending).

### Tạo migration mới
```bash
npm run migrate:create <tên_migration>
```
Ví dụ: `npm run migrate:create add_user_preferences`

## Format Migration File

Mỗi migration file phải có 2 sections:

```sql
-- ===== UP =====

-- SQL commands để apply changes
CREATE TABLE ...;


-- ===== DOWN =====

-- SQL commands để rollback changes
DROP TABLE ...;
```

## Best Practices

### 1. Naming Convention
- Sử dụng số thứ tự 3 chữ số: `001`, `002`, `003`...
- Tên mô tả rõ ràng: `create_users_table`, `add_email_index`
- Format: `{version}_{description}.sql`

### 2. Migration Content
✅ **Nên làm**:
- Sử dụng `IF NOT EXISTS` / `IF EXISTS` để tránh lỗi
- Viết DOWN section để có thể rollback
- Commit cùng lúc code changes và migration
- Test migration trên database local trước

❌ **Không nên**:
- Thay đổi migration đã chạy production
- Mix nhiều concerns trong 1 migration
- Quên viết DOWN section
- Hard-code values nhạy cảm

### 3. Transaction Safety
Migration runner tự động wrap mỗi migration trong transaction:
- Nếu lỗi → rollback toàn bộ migration
- Guarantee atomicity

### 4. Irreversible Changes
Một số thao tác không thể rollback:
- `ALTER TYPE ... ADD VALUE` (thêm ENUM value)
- `DROP COLUMN` chứa data quan trọng

Trong trường hợp này, ghi chú rõ ràng trong DOWN section:
```sql
-- ===== DOWN =====
-- Cannot remove ENUM value - requires manual intervention
```

## Workflow

### Development
1. Tạo migration: `npm run migrate:create my_change`
2. Viết UP và DOWN SQL
3. Test local: `npm run migrate:up`
4. Verify: Kiểm tra database schema
5. Test rollback: `npm run migrate:down` → `migrate:up`
6. Commit migration file

### Production
1. Pull code mới nhất
2. Review migrations chưa chạy: `npm run migrate:status`
3. Backup database
4. Chạy migrations: `npm run migrate:up`
5. Verify application hoạt động đúng

## Troubleshooting

### "No pending migrations"
→ Tất cả migrations đã chạy hoặc không có file migration nào.

### "No DOWN section found"
→ Migration file thiếu `-- ===== DOWN =====` section. Không thể rollback.

### Migration failed mid-way
→ Transaction tự động rollback. Database không bị ảnh hưởng.

### Manual intervention needed
Nếu cần sửa tracking table thủ công:
```sql
-- Xem migrations đã chạy
SELECT * FROM app.schema_migrations ORDER BY version;

-- Mark migration as executed (nếu chạy manual)
INSERT INTO app.schema_migrations (version, name) 
VALUES ('002_add_indexes', '002_add_performance_indexes.sql');

-- Unmark migration (nếu cần chạy lại)
DELETE FROM app.schema_migrations WHERE version = '002_add_indexes';
```

## Migration Dependencies

Migrations chạy theo thứ tự số. Nếu migration B phụ thuộc vào migration A:
- A phải có version number nhỏ hơn B
- Ví dụ: `002_create_table.sql` → `003_add_foreign_key.sql`

## Examples

### Create Table
```sql
-- ===== UP =====
CREATE TABLE IF NOT EXISTS app.notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES app.users(id),
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON app.notifications(user_id);

-- ===== DOWN =====
DROP TABLE IF EXISTS app.notifications;
```

### Add Column
```sql
-- ===== UP =====
ALTER TABLE app.users 
ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ;

-- ===== DOWN =====
ALTER TABLE app.users 
DROP COLUMN IF EXISTS last_login;
```

### Add Index
```sql
-- ===== UP =====
CREATE INDEX IF NOT EXISTS idx_posts_tags 
ON app.posts USING GIN(tags);

-- ===== DOWN =====
DROP INDEX IF EXISTS app.idx_posts_tags;
```

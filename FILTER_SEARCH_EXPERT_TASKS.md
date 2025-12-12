# 📋 FILTER-SEARCH-EXPERT MODULE - DANH SÁCH TASK

> **Ngày tạo:** 12/12/2025  
> **Module:** `src/modules/filter-search-expert/`  
> **Tổng số tasks:** 12 tasks

---

## 📊 TỔNG QUAN MODULE

### Chức năng chính
- Tìm kiếm expert nâng cao với 30+ tiêu chí lọc
- Quick filters (top_rated, online_now, budget_friendly...)
- Facets API cho filter UI
- Chi tiết expert đầy đủ + gợi ý expert tương tự

### Endpoints
| Endpoint | Mô tả |
|----------|-------|
| `GET /advanced` | Tìm kiếm nâng cao |
| `GET /facets` | Aggregations cho UI |
| `GET /quick-filters` | Bộ lọc nhanh định sẵn |
| `GET /:expertId/full` | Chi tiết đầy đủ expert |
| `GET /:expertId/similar` | Expert tương tự |

---

## 🔴 CRITICAL - CẦN SỬA NGAY

### Task 1: Fix SQL Injection trong lastActiveWithin
- **File:** `src/modules/filter-search-expert/repo.js`
- **Dòng:** ~95
- **Vấn đề:** `lastActiveWithin` được interpolate trực tiếp vào SQL string
- **Code lỗi:**
```javascript
conditions.push(`es.last_active_at >= NOW() - INTERVAL '${parseInt(lastActiveWithin)} minutes'`);
```
- **Công việc:**
  - [ ] Thay đổi thành parameterized query
  - [ ] Validate lastActiveWithin là số dương
  - [ ] Giới hạn giá trị tối đa (ví dụ: 10080 = 1 tuần)
- **Code fix:**
```javascript
const minutes = parseInt(lastActiveWithin);
if (!isNaN(minutes) && minutes > 0 && minutes <= 10080) {
    conditions.push(`es.last_active_at >= NOW() - INTERVAL '1 minute' * ${addParam(minutes)}`);
}
```
- **Estimate:** 30m

### Task 2: Implement Input Validation
- **File:** `src/modules/filter-search-expert/validation.js`
- **Vấn đề:** Validation middleware chỉ gọi `next()`, không validate gì
- **Công việc:**
  - [ ] Implement validateAdvancedSearch thực sự
  - [ ] Validate numeric fields (minPrice, maxPrice, minRating...)
  - [ ] Validate enum fields (sortBy, sortOrder, kycStatus, gender)
  - [ ] Validate pagination (page >= 1, limit 1-100)
  - [ ] Sanitize keyword input (trim, max length)
  - [ ] Return proper error messages
- **Code fix:**
```javascript
export const validateAdvancedSearch = (req, res, next) => {
    const errors = [];
    
    // Validate numeric fields
    const numericFields = ['minPrice', 'maxPrice', 'minRating', 'maxRating', 'page', 'limit'];
    numericFields.forEach(field => {
        const value = req.query[field] || req.query[field.replace(/([A-Z])/g, '_$1').toLowerCase()];
        if (value !== undefined && (isNaN(value) || parseFloat(value) < 0)) {
            errors.push(`${field} must be a positive number`);
        }
    });
    
    // Validate sortBy
    const validSortBy = ['rating', 'price', 'price_low', 'sessions', 'response_time', 'active_score', 'reviews', 'completion_rate', 'newest'];
    const sortBy = req.query.sortBy || req.query.sort_by;
    if (sortBy && !validSortBy.includes(sortBy)) {
        errors.push(`sortBy must be one of: ${validSortBy.join(', ')}`);
    }
    
    // Validate keyword length
    const keyword = req.query.keyword || req.query.q;
    if (keyword && keyword.length > 200) {
        errors.push('keyword must be less than 200 characters');
    }
    
    if (errors.length > 0) {
        return res.status(400).json({ success: false, errors });
    }
    next();
};
```
- **Estimate:** 2h

---

## 🟡 MEDIUM - CẦN SỬA SỚM

### Task 3: Thêm Full-Text Search Index
- **File:** Migration SQL mới
- **Vấn đề:** Query dùng `ILIKE '%keyword%'` không sử dụng được index, chậm với data lớn
- **Công việc:**
  - [ ] Cài đặt extension pg_trgm
  - [ ] Tạo GIN index cho display_name
  - [ ] Tạo GIN index cho intro
  - [ ] Tạo GIN index cho specialties
  - [ ] Test performance với EXPLAIN ANALYZE
- **Migration:**
```sql
-- Migration: Add trigram indexes for expert search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX CONCURRENTLY idx_user_profiles_display_name_trgm 
ON app.user_profiles USING GIN (display_name gin_trgm_ops);

CREATE INDEX CONCURRENTLY idx_expert_profiles_intro_trgm 
ON app.expert_profiles USING GIN (intro gin_trgm_ops);
```
- **Estimate:** 1h

### Task 4: Thêm Index Cho Sorting Columns
- **File:** Migration SQL mới
- **Vấn đề:** Các cột sort thường xuyên chưa có index
- **Công việc:**
  - [ ] Index cho rating_avg
  - [ ] Index cho total_sessions
  - [ ] Index cho response_time_avg
  - [ ] Index cho active_score
  - [ ] Index cho price_per_session
- **Migration:**
```sql
-- Migration: Add indexes for expert search sorting
CREATE INDEX CONCURRENTLY idx_expert_profiles_rating 
ON app.expert_profiles(rating_avg DESC NULLS LAST);

CREATE INDEX CONCURRENTLY idx_expert_profiles_price 
ON app.expert_profiles(price_per_session ASC);

CREATE INDEX CONCURRENTLY idx_expert_performance_sessions 
ON app.expert_performance(total_sessions DESC);

CREATE INDEX CONCURRENTLY idx_expert_performance_response 
ON app.expert_performance(response_time_avg ASC NULLS LAST);

CREATE INDEX CONCURRENTLY idx_expert_status_active 
ON app.expert_status(active_score DESC);
```
- **Estimate:** 1h

### Task 5: Optimize Skills Subquery (N+1 Prevention)
- **File:** `src/modules/filter-search-expert/repo.js`
- **Vấn đề:** Subquery cho skills chạy cho mỗi expert trong result
- **Công việc:**
  - [ ] Tách skills query ra riêng
  - [ ] Fetch skills cho tất cả expert_ids một lần
  - [ ] Map skills vào experts trong service layer
- **Code fix:**
```javascript
// Thay vì subquery trong main query, fetch riêng:
const expertIds = expertsResult.rows.map(e => e.expert_id);
const skillsQuery = `
    SELECT eks.expert_id, sk.id, sk.name, sk.category
    FROM app.expert_skills eks
    JOIN app.skills sk ON eks.skill_id = sk.id
    WHERE eks.expert_id = ANY($1)
`;
const skillsResult = await query(skillsQuery, [expertIds]);

// Group skills by expert_id
const skillsMap = skillsResult.rows.reduce((acc, row) => {
    if (!acc[row.expert_id]) acc[row.expert_id] = [];
    acc[row.expert_id].push({ id: row.id, name: row.name, category: row.category });
    return acc;
}, {});

// Merge vào experts
expertsResult.rows.forEach(expert => {
    expert.skills = skillsMap[expert.expert_id] || [];
});
```
- **Estimate:** 2h

### Task 6: Thêm Caching cho Facets
- **File:** `src/modules/filter-search-expert/service.js`
- **Vấn đề:** Facets query nặng nhưng data ít thay đổi
- **Công việc:**
  - [ ] Cache facets result (TTL 5-10 phút)
  - [ ] Invalidate cache khi expert data thay đổi
  - [ ] Support Redis hoặc in-memory cache
- **Code fix:**
```javascript
import { cacheGet, cacheSet } from '../../utils/cache.js';

const FACETS_CACHE_KEY = 'expert_search_facets';
const FACETS_CACHE_TTL = 300; // 5 minutes

export async function getSearchFacets() {
    // Try cache first
    const cached = await cacheGet(FACETS_CACHE_KEY);
    if (cached) return cached;
    
    // Fetch from DB
    const facets = await SearchRepo.getSearchFacets();
    
    // Cache result
    await cacheSet(FACETS_CACHE_KEY, facets, FACETS_CACHE_TTL);
    
    return facets;
}
```
- **Estimate:** 2h

### Task 7: Thêm Rate Limiting cho Search API
- **File:** `src/modules/filter-search-expert/routes.js`
- **Vấn đề:** Public API không có rate limit, dễ bị abuse
- **Công việc:**
  - [ ] Thêm rate limiter middleware
  - [ ] Limit: 60 requests/minute per IP
  - [ ] Stricter limit cho /advanced (30 req/min)
- **Code fix:**
```javascript
import rateLimit from 'express-rate-limit';

const searchLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 30,
    message: { success: false, error: 'Too many search requests, please try again later' }
});

router.get("/advanced", searchLimiter, validateAdvancedSearch, SearchController.advancedSearch);
```
- **Estimate:** 1h

---

## 🟢 LOW - CẢI THIỆN CODE QUALITY

### Task 8: Định nghĩa Error Codes
- **File:** Tạo mới `src/modules/filter-search-expert/errors.js`
- **Vấn đề:** Error codes generic, khó debug
- **Công việc:**
  - [ ] Định nghĩa error codes cụ thể
  - [ ] Map error codes với HTTP status
  - [ ] Update controller sử dụng error codes
- **Code:**
```javascript
export const SearchErrors = {
    INVALID_FILTER: { code: 'SEARCH_INVALID_FILTER', status: 400 },
    EXPERT_NOT_FOUND: { code: 'SEARCH_EXPERT_NOT_FOUND', status: 404 },
    DB_ERROR: { code: 'SEARCH_DB_ERROR', status: 500 },
    RATE_LIMITED: { code: 'SEARCH_RATE_LIMITED', status: 429 },
    INVALID_PAGINATION: { code: 'SEARCH_INVALID_PAGINATION', status: 400 }
};
```
- **Estimate:** 1h

### Task 9: Remove Hardcoded Vietnamese Strings
- **File:** `src/modules/filter-search-expert/service.js`
- **Vấn đề:** `formatPrice()` return "Liên hệ" hardcoded
- **Công việc:**
  - [ ] Return null thay vì hardcoded string
  - [ ] Để frontend handle formatting và i18n
  - [ ] Hoặc support locale parameter
- **Code fix:**
```javascript
function formatPrice(price, locale = 'vi-VN') {
    if (!price) return null;
    return new Intl.NumberFormat(locale, {
        style: 'currency',
        currency: 'VND'
    }).format(price);
}
```
- **Estimate:** 30m

### Task 10: Thêm JSDoc Comments
- **Files:** Tất cả files trong module
- **Công việc:**
  - [ ] Document tất cả exported functions
  - [ ] Document filter parameters
  - [ ] Document return types
- **Estimate:** 1h

### Task 11: Thêm Unit Tests
- **File:** Tạo mới `src/modules/filter-search-expert/tests/`
- **Công việc:**
  - [ ] Test normalizeFilters()
  - [ ] Test getAvailabilityStatus()
  - [ ] Test getExperienceLevel()
  - [ ] Test validation middleware
  - [ ] Mock database cho repo tests
- **Estimate:** 4h

### Task 12: Thêm Request Logging
- **File:** `src/modules/filter-search-expert/controller.js`
- **Công việc:**
  - [ ] Log search queries (sanitized)
  - [ ] Log response times
  - [ ] Log result counts
  - [ ] Useful cho analytics và debugging
- **Code:**
```javascript
export const advancedSearch = asyncHandler(async (req, res) => {
    const startTime = Date.now();
    
    // ... existing code ...
    
    const duration = Date.now() - startTime;
    logger.info('Expert search', {
        filters: { ...filters, keyword: filters.keyword ? '[REDACTED]' : undefined },
        resultCount: result.experts.length,
        totalCount: result.pagination.total,
        duration
    });
    
    return success(res, "experts.search.success", result);
});
```
- **Estimate:** 1h

---

## 📅 SUGGESTED PRIORITY ORDER

### Sprint 1 (Tuần 1): Security & Critical
1. Task 1: Fix SQL Injection ⚠️
2. Task 2: Implement Validation ⚠️
3. Task 7: Rate Limiting

### Sprint 2 (Tuần 2): Performance
4. Task 3: Full-Text Search Index
5. Task 4: Sorting Indexes
6. Task 5: Optimize N+1
7. Task 6: Caching

### Sprint 3 (Tuần 3): Code Quality
8. Task 8-12: Error codes, i18n, docs, tests, logging

---

## 📝 NOTES

1. **Database Schema:** Đã verify tất cả bảng và columns đều tồn tại và khớp với queries
2. **Dependencies cần thêm:**
   - `express-rate-limit` (Task 7)
   - Redis client nếu dùng distributed cache (Task 6)
3. **Testing:** Cần test với dataset lớn để verify performance improvements

---

**Cập nhật lần cuối:** 12/12/2025

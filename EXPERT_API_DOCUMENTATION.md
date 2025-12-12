# 📚 EXPERT API DOCUMENTATION

**Ngày tạo:** 2025-12-08  
**Base URL:** `http://localhost:4000/api/v1`  
**Version:** 1.0

---

## 📋 MỤC LỤC

1. [Tổng quan](#tổng-quan)
2. [Authentication](#authentication)
3. [Public APIs (Không cần đăng nhập)](#public-apis)
4. [Private APIs (Cần đăng nhập)](#private-apis)
5. [Response Format](#response-format)
6. [Error Codes](#error-codes)

---

## 🎯 TỔNG QUAN

Hệ thống Expert API được chia thành 2 nhóm chính:

| Nhóm | Base Path | Auth Required | Mô tả |
|------|-----------|---------------|-------|
| **Public** | `/expert-search/*` | ❌ Không | Tìm kiếm, filter expert cho user |
| **Public** | `/public/experts/*` | ❌ Không | Xem thông tin expert cơ bản |
| **Private** | `/experts/*` | ✅ Có | Quản lý profile expert (cho expert) |

---

## 🔐 AUTHENTICATION

Các API private yêu cầu JWT token trong header:

```
Authorization: Bearer <your_jwt_token>
```

---

## 🌐 PUBLIC APIs

### 1. TÌM KIẾM NÂNG CAO (Advanced Search)

```
GET /api/v1/expert-search/advanced
```

**Mô tả:** Tìm kiếm expert với 30+ tiêu chí filter

**Query Parameters:**

| Parameter | Type | Mô tả | Ví dụ |
|-----------|------|-------|-------|
| `keyword` hoặc `q` | string | Tìm theo tên, intro, specialties | `keyword=tâm lý` |
| `specialties` | string | Lọc theo chuyên môn (comma-separated) | `specialties=Tâm lý,Coaching` |
| `minPrice` | number | Giá tối thiểu (VND) | `minPrice=100000` |
| `maxPrice` | number | Giá tối đa (VND) | `maxPrice=500000` |
| `minRating` | number | Rating tối thiểu (0-5) | `minRating=4.0` |
| `maxRating` | number | Rating tối đa (0-5) | `maxRating=5` |
| `kycStatus` | string | Trạng thái xác minh | `kycStatus=VERIFIED` |
| `isOnline` | boolean | Chỉ expert đang online | `isOnline=true` |
| `lastActiveWithin` | number | Hoạt động trong X phút | `lastActiveWithin=30` |
| `minCompletionRate` | number | Tỷ lệ hoàn thành tối thiểu (%) | `minCompletionRate=90` |
| `minAcceptanceRate` | number | Tỷ lệ chấp nhận booking (%) | `minAcceptanceRate=80` |
| `maxResponseTime` | number | Thời gian phản hồi tối đa (phút) | `maxResponseTime=15` |
| `minTotalSessions` | number | Số session tối thiểu | `minTotalSessions=50` |
| `minTotalReviews` | number | Số review tối thiểu | `minTotalReviews=10` |
| `skillIds` | string | Filter theo skill IDs | `skillIds=1,2,3` |
| `skillCategories` | string | Filter theo skill categories | `skillCategories=Mental Health` |
| `minExperienceYears` | number | Số năm kinh nghiệm tối thiểu | `minExperienceYears=5` |
| `hasCertification` | boolean | Có chứng chỉ | `hasCertification=true` |
| `certificationKeyword` | string | Tìm trong tên chứng chỉ | `certificationKeyword=Psychology` |
| `educationKeyword` | string | Tìm trong học vấn | `educationKeyword=Harvard` |
| `audienceIds` | string | Filter theo đối tượng | `audienceIds=1,2` |
| `domainIds` | string | Filter theo lĩnh vực | `domainIds=1,3` |
| `gender` | string | Giới tính | `gender=FEMALE` |
| `availableFrom` | ISO datetime | Lịch trống từ | `availableFrom=2025-12-10T09:00:00Z` |
| `availableTo` | ISO datetime | Lịch trống đến | `availableTo=2025-12-10T17:00:00Z` |
| `sortBy` | string | Sắp xếp theo | `sortBy=rating` |
| `sortOrder` | string | Thứ tự sắp xếp | `sortOrder=DESC` |
| `page` | number | Trang (default: 1) | `page=1` |
| `limit` | number | Số item/trang (max: 100) | `limit=20` |

**Sort Options:**
- `rating` - Theo đánh giá
- `price` - Theo giá (cao → thấp)
- `price_low` - Theo giá (thấp → cao)
- `sessions` - Theo số session
- `response_time` - Theo thời gian phản hồi
- `active_score` - Theo độ hoạt động
- `reviews` - Theo số review
- `completion_rate` - Theo tỷ lệ hoàn thành
- `newest` - Mới nhất

**Ví dụ Request:**
```
GET /api/v1/expert-search/advanced?keyword=tâm lý&minRating=4.0&maxPrice=500000&isOnline=true&sortBy=rating&page=1&limit=10
```

**Response:**
```json
{
  "success": true,
  "message": "experts.search.success",
  "data": {
    "experts": [
      {
        "id": 1,
        "user_id": 5,
        "display_name": "Dr. Nguyễn Văn A",
        "avatar_url": "https://...",
        "specialties": ["Tâm lý", "Stress"],
        "price_per_session": 300000,
        "rating_avg": 4.8,
        "total_reviews": 45,
        "total_sessions": 120,
        "kyc_status": "VERIFIED",
        "is_online": true,
        "last_active_at": "2025-12-08T10:30:00Z",
        "intro": "Chuyên gia tâm lý với 10 năm kinh nghiệm...",
        "availability_status": "online",
        "price_formatted": "300.000 ₫",
        "experience_level": "top_rated"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 45,
      "total_pages": 5
    }
  }
}
```

---

### 2. QUICK FILTERS (Bộ lọc nhanh)

```
GET /api/v1/expert-search/quick-filters
```

**Mô tả:** Lấy danh sách expert theo các preset filter có sẵn

**Query Parameters:**

| Parameter | Type | Mô tả |
|-----------|------|-------|
| `filter` | string | Tên filter preset |
| `page` | number | Trang |
| `limit` | number | Số item/trang |

**Filter Options:**

| Filter | Mô tả |
|--------|-------|
| `top_rated` | Rating ≥ 4.5, có ≥ 5 reviews |
| `most_experienced` | ≥ 50 sessions |
| `online_now` | Đang online |
| `recently_active` | Hoạt động trong 30 phút |
| `fast_responders` | Phản hồi trong 15 phút |
| `budget_friendly` | Giá ≤ 200,000 VND |
| `premium` | Giá ≥ 500,000 VND, rating ≥ 4.0 |
| `verified` | Đã xác minh KYC |
| `new_experts` | Expert mới |
| `high_completion` | Tỷ lệ hoàn thành ≥ 90% |

**Ví dụ:**
```
GET /api/v1/expert-search/quick-filters?filter=top_rated&limit=10
```

---

### 3. LẤY FACETS (Cho UI Filter)

```
GET /api/v1/expert-search/facets
```

**Mô tả:** Lấy các options cho dropdown/checkbox filter trên UI

**Response:**
```json
{
  "success": true,
  "data": {
    "specialties": [
      { "value": "Tâm lý", "count": 25 },
      { "value": "Coaching", "count": 18 }
    ],
    "price_ranges": [
      { "min": 0, "max": 200000, "label": "Dưới 200k", "count": 30 },
      { "min": 200000, "max": 500000, "label": "200k - 500k", "count": 45 }
    ],
    "kyc_statuses": ["PENDING", "VERIFIED", "REJECTED"],
    "skill_categories": ["Mental Health", "Career", "Relationship"],
    "genders": ["MALE", "FEMALE", "OTHER"]
  }
}
```

---

### 4. CHI TIẾT EXPERT (Full Details)

```
GET /api/v1/expert-search/:expertId/full
```

**Mô tả:** Lấy toàn bộ thông tin chi tiết của expert

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": 5,
    "display_name": "Dr. Nguyễn Văn A",
    "avatar_url": "https://...",
    "specialties": ["Tâm lý", "Stress"],
    "price_per_session": 300000,
    "intro": "...",
    "rating_avg": 4.8,
    "total_reviews": 45,
    "total_sessions": 120,
    "kyc_status": "VERIFIED",
    "skills": [
      { "id": 1, "name": "Cognitive Therapy", "category": "Mental Health" }
    ],
    "experience": [
      { "position": "Psychologist", "organization": "Hospital A", "years": 5 }
    ],
    "education": [
      { "degree": "PhD Psychology", "institution": "University X", "year": 2015 }
    ],
    "certifications": [
      { "name": "Licensed Psychologist", "issuing_org": "VN Psychology Association" }
    ],
    "availability": [
      { "day": "Monday", "start": "09:00", "end": "17:00" }
    ],
    "similar_experts": [...],
    "availability_status": "online",
    "price_formatted": "300.000 ₫",
    "experience_level": "top_rated",
    "total_experience_years": 10
  }
}
```

---

### 5. EXPERT TƯƠNG TỰ

```
GET /api/v1/expert-search/:expertId/similar
```

**Query Parameters:**
- `limit` (number): Số lượng expert tương tự (default: 5)

---

### 6. XEM EXPERT THEO ID (Basic)

```
GET /api/v1/public/experts/:expertId
```

**Mô tả:** Lấy thông tin cơ bản của expert (legacy endpoint)

---

### 7. TÌM KIẾM CƠ BẢN (Legacy)

```
GET /api/v1/public/experts/search
```

**Mô tả:** Tìm kiếm cơ bản (khuyến nghị dùng `/expert-search/advanced`)

---

## 🔒 PRIVATE APIs (Cần Authentication)

> **Lưu ý:** Tất cả API dưới đây yêu cầu header `Authorization: Bearer <token>`

### 1. PROFILE MANAGEMENT

#### Lấy profile của tôi
```
GET /api/v1/experts/profile
```

#### Cập nhật profile
```
PUT /api/v1/experts/profile
```

**Body:**
```json
{
  "specialties": ["Tâm lý", "Coaching"],
  "price_per_session": 300000,
  "intro": "Giới thiệu về bản thân (10-2000 ký tự)"
}
```

---

### 2. SKILLS MANAGEMENT

#### Thêm skill
```
POST /api/v1/experts/skills
```
**Body:**
```json
{
  "name": "Cognitive Behavioral Therapy",
  "category": "Mental Health"
}
```

#### Cập nhật skill
```
PUT /api/v1/experts/skills/:skillId
```
**Body:**
```json
{
  "name": "Updated Skill Name",
  "category": "Updated Category"
}
```

#### Xóa skill
```
DELETE /api/v1/experts/skills/:skillId
```

---

### 3. EXPERIENCE MANAGEMENT

#### Thêm kinh nghiệm
```
POST /api/v1/experts/experience
```
**Body:**
```json
{
  "position": "Senior Psychologist",
  "organization": "Mental Health Center",
  "years": 5,
  "description": "Mô tả công việc",
  "start_year": 2018,
  "end_year": 2023
}
```

#### Cập nhật kinh nghiệm
```
PUT /api/v1/experts/experience/:experienceId
```

#### Xóa kinh nghiệm
```
DELETE /api/v1/experts/experience/:experienceId
```

---

### 4. EDUCATION MANAGEMENT

#### Thêm học vấn
```
POST /api/v1/experts/education
```
**Body:**
```json
{
  "degree": "PhD in Psychology",
  "institution": "University of Science",
  "year_completed": 2015,
  "description": "Chuyên ngành tâm lý lâm sàng"
}
```

#### Cập nhật học vấn
```
PUT /api/v1/experts/education/:educationId
```

#### Xóa học vấn
```
DELETE /api/v1/experts/education/:educationId
```

---

### 5. CERTIFICATIONS MANAGEMENT

#### Thêm chứng chỉ
```
POST /api/v1/experts/certifications
```
**Body:**
```json
{
  "certificate_name": "Licensed Clinical Psychologist",
  "issuing_org": "Vietnam Psychology Association",
  "issued_at": "2020-01-15T00:00:00Z",
  "expires_at": "2025-01-15T00:00:00Z",
  "credential_url": "https://verify.example.com/cert/123"
}
```

#### Cập nhật chứng chỉ
```
PUT /api/v1/experts/certifications/:certificationId
```

#### Xóa chứng chỉ
```
DELETE /api/v1/experts/certifications/:certificationId
```

---

### 6. AVAILABILITY MANAGEMENT

#### Lấy lịch trống
```
GET /api/v1/experts/availability
```
**Query:**
- `date_from`: ISO datetime
- `date_to`: ISO datetime

#### Thêm lịch trống
```
POST /api/v1/experts/availability
```
**Body:**
```json
{
  "start_at": "2025-12-10T09:00:00Z",
  "end_at": "2025-12-10T17:00:00Z",
  "is_recurring": true,
  "recurring_pattern": {
    "type": "WEEKLY",
    "days_of_week": [1, 2, 3, 4, 5]
  }
}
```

#### Cập nhật lịch trống
```
PUT /api/v1/experts/availability/:availabilityId
```

#### Xóa lịch trống
```
DELETE /api/v1/experts/availability/:availabilityId
```

---

### 7. TARGET AUDIENCE & DOMAINS

#### Cập nhật đối tượng mục tiêu
```
PUT /api/v1/experts/target-audience
```
**Body:**
```json
{
  "audience_ids": [1, 2, 3]
}
```

#### Cập nhật lĩnh vực
```
PUT /api/v1/experts/domains
```
**Body:**
```json
{
  "domain_ids": [1, 2]
}
```

---

### 8. MEDIA/PORTFOLIO

#### Lấy media
```
GET /api/v1/experts/media
```

#### Thêm media
```
POST /api/v1/experts/media
```
**Body:**
```json
{
  "media_type": "IMAGE",
  "url": "https://example.com/image.jpg",
  "title": "Certificate Image",
  "description": "My professional certificate"
}
```
**media_type options:** `IMAGE`, `VIDEO`, `DOCUMENT`, `AUDIO`

#### Cập nhật media
```
PUT /api/v1/experts/media/:mediaId
```

#### Xóa media
```
DELETE /api/v1/experts/media/:mediaId
```

---

### 9. STATUS MANAGEMENT

#### Cập nhật trạng thái
```
PUT /api/v1/experts/status
```
**Body:**
```json
{
  "is_available": true,
  "current_status": "ONLINE",
  "status_message": "Sẵn sàng tư vấn"
}
```
**current_status options:** `ONLINE`, `OFFLINE`, `BUSY`, `AWAY`

---

### 10. STATISTICS & ANALYTICS

#### Lấy thống kê
```
GET /api/v1/experts/stats
```

#### Validate profile
```
GET /api/v1/experts/validate
```

#### Cập nhật performance
```
PUT /api/v1/experts/performance
```
**Body:**
```json
{
  "response_time_avg": 10,
  "session_completion_rate": 95,
  "satisfaction_score": 4.8
}
```

---

## 📦 RESPONSE FORMAT

### Success Response
```json
{
  "success": true,
  "message": "experts.search.success",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE",
  "status": 400
}
```

---

## ❌ ERROR CODES

| Code | HTTP Status | Mô tả |
|------|-------------|-------|
| `PROFILE_RETRIEVAL_FAILED` | 500 | Không lấy được profile |
| `PROFILE_UPDATE_FAILED` | 500 | Cập nhật profile thất bại |
| `SKILL_ADD_FAILED` | 500 | Thêm skill thất bại |
| `EXPERIENCE_ADD_FAILED` | 500 | Thêm experience thất bại |
| `SEARCH_FAILED` | 500 | Tìm kiếm thất bại |
| `EXPERT_NOT_FOUND` | 404 | Không tìm thấy expert |
| `UNAUTHORIZED` | 401 | Chưa đăng nhập |
| `FORBIDDEN` | 403 | Không có quyền |

---

## 🧪 TEST EXAMPLES

### cURL - Tìm kiếm expert
```bash
curl -X GET "http://localhost:4000/api/v1/expert-search/advanced?keyword=tâm%20lý&minRating=4.0&limit=10" \
  -H "Content-Type: application/json"
```

### cURL - Lấy profile (cần auth)
```bash
curl -X GET "http://localhost:4000/api/v1/experts/profile" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### cURL - Cập nhật profile
```bash
curl -X PUT "http://localhost:4000/api/v1/experts/profile" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "specialties": ["Tâm lý", "Coaching"],
    "price_per_session": 350000,
    "intro": "Chuyên gia tâm lý với 10 năm kinh nghiệm..."
  }'
```

---

## 📞 LIÊN HỆ

Nếu có thắc mắc về API, liên hệ Backend Team.

**Cập nhật lần cuối:** 2025-12-08

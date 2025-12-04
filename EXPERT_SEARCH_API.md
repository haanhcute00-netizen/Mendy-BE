# 🔍 Expert Advanced Search API Documentation

## Overview

API tìm kiếm chuyên gia nâng cao với hơn 30+ tiêu chí lọc, hỗ trợ full-text search, faceted search, và các preset filter.

**Module:** `src/modules/filter-search-expert/`

---

## Endpoints

### 1. Advanced Search
```
GET /api/v1/expert-search/advanced
```

### 2. Search Facets (cho Filter UI)
```
GET /api/v1/expert-search/facets
```

### 3. Quick Filters (Preset)
```
GET /api/v1/expert-search/quick-filters?filter={preset}
```

### 4. Expert Full Details
```
GET /api/v1/expert-search/:expertId/full
```

### 5. Similar Experts
```
GET /api/v1/expert-search/:expertId/similar
```

---

## Advanced Search Parameters

### 🔤 Text Search
| Parameter | Type | Description |
|-----------|------|-------------|
| `keyword` / `q` | string | Tìm kiếm trong tên, giới thiệu, chuyên môn |

### 💰 Basic Filters
| Parameter | Type | Description |
|-----------|------|-------------|
| `specialties` | string | Comma-separated. VD: `anxiety,depression` |
| `minPrice` / `min_price` | number | Giá tối thiểu (VND) |
| `maxPrice` / `max_price` | number | Giá tối đa (VND) |
| `minRating` / `min_rating` | number | Rating tối thiểu (0-5) |
| `maxRating` / `max_rating` | number | Rating tối đa (0-5) |
| `kycStatus` / `kyc_status` | string | `PENDING`, `VERIFIED`, `REJECTED` (comma-separated) |

### 🟢 Status Filters
| Parameter | Type | Description |
|-----------|------|-------------|
| `isOnline` / `is_online` | boolean | Chỉ expert đang online |
| `lastActiveWithin` / `last_active_within` | number | Hoạt động trong X phút gần đây |

### 📊 Performance Filters
| Parameter | Type | Description |
|-----------|------|-------------|
| `minCompletionRate` / `min_completion_rate` | number | Tỷ lệ hoàn thành tối thiểu (0-100) |
| `minAcceptanceRate` / `min_acceptance_rate` | number | Tỷ lệ chấp nhận booking tối thiểu (0-100) |
| `maxResponseTime` / `max_response_time` | number | Thời gian phản hồi tối đa (phút) |
| `minTotalSessions` / `min_total_sessions` | number | Số session tối thiểu |
| `minTotalReviews` / `min_total_reviews` | number | Số review tối thiểu |

### 🎯 Skills & Experience
| Parameter | Type | Description |
|-----------|------|-------------|
| `skillIds` / `skill_ids` | string | Comma-separated skill IDs |
| `skillCategories` / `skill_categories` | string | Comma-separated categories |
| `minExperienceYears` / `min_experience_years` | number | Số năm kinh nghiệm tối thiểu |

### 🎓 Education & Certification
| Parameter | Type | Description |
|-----------|------|-------------|
| `hasCertification` / `has_certification` | boolean | Có chứng chỉ |
| `certificationKeyword` / `certification_keyword` | string | Tìm trong tên chứng chỉ |
| `educationKeyword` / `education_keyword` | string | Tìm trong học vấn |

### 👥 Audience & Domain
| Parameter | Type | Description |
|-----------|------|-------------|
| `audienceIds` / `audience_ids` | string | Comma-separated audience IDs |
| `domainIds` / `domain_ids` | string | Comma-separated domain IDs |

### 👤 Profile Filters
| Parameter | Type | Description |
|-----------|------|-------------|
| `gender` | string | `MALE`, `FEMALE`, `OTHER`, `UNSPECIFIED` |

### 📅 Availability
| Parameter | Type | Description |
|-----------|------|-------------|
| `availableFrom` / `available_from` | ISO datetime | Thời gian bắt đầu kiểm tra |
| `availableTo` / `available_to` | ISO datetime | Thời gian kết thúc kiểm tra |

### 📑 Sorting
| Parameter | Type | Options |
|-----------|------|---------|
| `sortBy` / `sort_by` | string | `rating`, `price`, `price_low`, `sessions`, `response_time`, `active_score`, `reviews`, `completion_rate`, `newest` |
| `sortOrder` / `sort_order` | string | `ASC`, `DESC` |

### 📄 Pagination
| Parameter | Type | Default |
|-----------|------|---------|
| `page` | number | 1 |
| `limit` | number | 20 (max: 100) |

---

## Quick Filter Presets

| Filter | Description |
|--------|-------------|
| `top_rated` | Rating ≥ 4.5, Reviews ≥ 5 |
| `most_experienced` | Sessions ≥ 50 |
| `online_now` | Đang online |
| `recently_active` | Hoạt động trong 30 phút |
| `fast_responders` | Response time ≤ 15 phút |
| `budget_friendly` | Giá ≤ 200,000 VND |
| `premium` | Giá ≥ 500,000 VND, Rating ≥ 4.0 |
| `verified` | KYC đã xác minh |
| `new_experts` | Expert mới nhất |
| `high_completion` | Completion rate ≥ 90% |

---

## Response Format

### Search Response
```json
{
  "success": true,
  "message": "experts.search.success",
  "data": {
    "experts": [
      {
        "expert_id": 1,
        "user_id": 7,
        "specialties": ["anxiety", "depression"],
        "price_per_session": 500000,
        "rating_avg": 4.8,
        "intro": "...",
        "kyc_status": "VERIFIED",
        "handle": "expert1",
        "display_name": "Dr. Nguyen Van A",
        "avatar_url": "/uploads/...",
        "is_online": true,
        "last_active_at": "2025-11-27T10:00:00Z",
        "active_score": 85.5,
        "response_time_avg": 10,
        "acceptance_rate": 95.0,
        "completion_rate": 98.0,
        "total_sessions": 150,
        "total_reviews": 45,
        "skills": [
          {"id": 1, "name": "CBT", "category": "Therapy"}
        ],
        "availability_status": "online",
        "price_formatted": "500.000 ₫",
        "experience_level": "top_rated"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

### Facets Response
```json
{
  "success": true,
  "data": {
    "price_range": {
      "min": 100000,
      "max": 1000000,
      "avg": 350000
    },
    "rating_distribution": [
      {"rating": 5, "count": 10},
      {"rating": 4, "count": 25}
    ],
    "top_specialties": [
      {"specialty": "anxiety", "count": 15},
      {"specialty": "depression", "count": 12}
    ],
    "skill_categories": [
      {"category": "Therapy", "count": 20}
    ],
    "kyc_status_counts": [
      {"status": "VERIFIED", "count": 30}
    ],
    "online_status": {
      "online": 5,
      "offline": 40
    },
    "audiences": [...],
    "domains": [...],
    "total_experts": 45
  }
}
```

---

## Example Requests

### 1. Tìm expert online, rating cao, giá hợp lý
```
GET /api/v1/expert-search/advanced?isOnline=true&minRating=4.5&maxPrice=500000&sortBy=rating
```

### 2. Tìm expert có chứng chỉ CBT, kinh nghiệm 5+ năm
```
GET /api/v1/expert-search/advanced?certificationKeyword=CBT&minExperienceYears=5
```

### 3. Tìm expert available trong khung giờ cụ thể
```
GET /api/v1/expert-search/advanced?availableFrom=2025-11-28T09:00:00Z&availableTo=2025-11-28T10:00:00Z
```

### 4. Quick filter - Top rated experts
```
GET /api/v1/expert-search/quick-filters?filter=top_rated&limit=10
```

### 5. Lấy facets cho filter UI
```
GET /api/v1/expert-search/facets
```

---

## Computed Fields

| Field | Description |
|-------|-------------|
| `availability_status` | `online`, `just_now`, `recently_active`, `active_hour_ago`, `active_today`, `offline` |
| `price_formatted` | Giá đã format theo VND |
| `experience_level` | `top_rated`, `experienced`, `established`, `growing`, `new` |
| `total_experience_years` | Tổng số năm kinh nghiệm (chỉ trong full details) |

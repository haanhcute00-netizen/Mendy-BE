# 📊 ADMIN ANALYTICS API - CẬP NHẬT MỚI

> **Ngày cập nhật:** 26/12/2025  
> **Version:** 2.0  
> **Yêu cầu:** Cập nhật giao diện Admin Dashboard

---

## 🆕 TỔNG QUAN CÁC API MỚI

Đã bổ sung **7 endpoints mới** cho module Admin Analytics:

| # | Endpoint | Mô tả | Priority |
|---|----------|-------|----------|
| 1 | `GET /api/v1/admin/analytics/cohort` | Phân tích Cohort - Retention | 🔴 High |
| 2 | `GET /api/v1/admin/analytics/session-quality` | Chất lượng Sessions | 🟡 Medium |
| 3 | `GET /api/v1/admin/analytics/expert-performance` | Hiệu suất Expert | 🔴 High |
| 4 | `GET /api/v1/admin/analytics/financial-health` | Sức khỏe Tài chính | 🔴 High |
| 5 | `GET /api/v1/admin/analytics/content-engagement` | Engagement Content | 🟡 Medium |
| 6 | `GET /api/v1/admin/analytics/export` | Xuất dữ liệu | 🟢 Low |
| 7 | `GET /api/v1/admin/analytics/alerts` | Cảnh báo bất thường | 🔴 High |

---

## 📋 CHI TIẾT TỪNG API

---

### 1️⃣ COHORT ANALYSIS

**Endpoint:** `GET /api/v1/admin/analytics/cohort`

**Mô tả:** Phân tích retention theo nhóm user đăng ký cùng tháng

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `months` | number | 6 | Số tháng phân tích |

**Request:**
```bash
GET /api/v1/admin/analytics/cohort?months=6
Authorization: Bearer <admin_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Cohort analysis retrieved",
  "data": {
    "cohorts": [
      {
        "month": "2025-12-01T00:00:00.000Z",
        "size": 150,
        "retention": {
          "month_0": 80,
          "month_1": 45,
          "month_2": 30,
          "month_3": 25
        },
        "retention_rates": {
          "month_0": "53.3%",
          "month_1": "30.0%",
          "month_2": "20.0%",
          "month_3": "16.7%"
        }
      },
      {
        "month": "2025-11-01T00:00:00.000Z",
        "size": 120,
        "retention": {
          "month_0": 65,
          "month_1": 40,
          "month_2": 28,
          "month_3": 20
        },
        "retention_rates": {
          "month_0": "54.2%",
          "month_1": "33.3%",
          "month_2": "23.3%",
          "month_3": "16.7%"
        }
      }
    ]
  }
}
```

**Gợi ý UI:**
- Hiển thị dạng **Cohort Table** (heatmap)
- Màu sắc theo retention rate (xanh = cao, đỏ = thấp)
- Có thể filter theo số tháng

---

### 2️⃣ SESSION QUALITY ANALYTICS

**Endpoint:** `GET /api/v1/admin/analytics/session-quality`

**Mô tả:** Phân tích chất lượng các buổi tư vấn và cuộc gọi

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `days` | number | 30 | Số ngày phân tích |

**Request:**
```bash
GET /api/v1/admin/analytics/session-quality?days=30
Authorization: Bearer <admin_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Session quality analytics retrieved",
  "data": {
    "period": { "days": 30 },
    "by_channel": [
      {
        "channel": "VIDEO",
        "total": 150,
        "completed": 130,
        "cancelled": 15,
        "noshow": 5,
        "completion_rate": "86.7%",
        "avg_duration_minutes": "45.5",
        "avg_rating": "4.52",
        "reviews": 95
      },
      {
        "channel": "AUDIO",
        "total": 80,
        "completed": 72,
        "cancelled": 6,
        "noshow": 2,
        "completion_rate": "90.0%",
        "avg_duration_minutes": "35.2",
        "avg_rating": "4.35",
        "reviews": 50
      },
      {
        "channel": "CHAT",
        "total": 200,
        "completed": 185,
        "cancelled": 10,
        "noshow": 5,
        "completion_rate": "92.5%",
        "avg_duration_minutes": "25.8",
        "avg_rating": "4.20",
        "reviews": 120
      }
    ],
    "call_quality": [
      {
        "type": "VIDEO",
        "total": 100,
        "completed": 85,
        "rejected": 10,
        "busy": 5,
        "avg_duration_seconds": "1820"
      },
      {
        "type": "AUDIO",
        "total": 60,
        "completed": 55,
        "rejected": 3,
        "busy": 2,
        "avg_duration_seconds": "1450"
      }
    ],
    "rating_distribution": [
      { "rating": 5, "count": 150 },
      { "rating": 4, "count": 80 },
      { "rating": 3, "count": 25 },
      { "rating": 2, "count": 8 },
      { "rating": 1, "count": 2 }
    ]
  }
}
```

**Gợi ý UI:**
- **Bar Chart** cho completion rate theo channel
- **Pie Chart** cho rating distribution
- **Cards** hiển thị avg duration, avg rating
- **Table** chi tiết call quality

---

### 3️⃣ EXPERT PERFORMANCE ANALYTICS

**Endpoint:** `GET /api/v1/admin/analytics/expert-performance`

**Mô tả:** Phân tích hiệu suất từng expert với điểm performance score

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `days` | number | 30 | Số ngày phân tích |
| `limit` | number | 20 | Số expert hiển thị |

**Request:**
```bash
GET /api/v1/admin/analytics/expert-performance?days=30&limit=20
Authorization: Bearer <admin_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Expert performance analytics retrieved",
  "data": {
    "period": { "days": 30 },
    "experts": [
      {
        "id": 15,
        "handle": "dr_nguyen",
        "display_name": "Dr. Nguyễn Văn A",
        "specialties": ["Tâm lý trị liệu", "Stress"],
        "price_per_session": 500000,
        "bookings": {
          "total": 45,
          "completed": 42,
          "cancelled": 2,
          "noshow": 1,
          "completion_rate": "93.3%"
        },
        "earnings": 21000000,
        "unique_clients": 28,
        "reviews": {
          "count": 35,
          "avg_rating": "4.75"
        },
        "avg_session_duration": "48",
        "performance_score": "89.5"
      },
      {
        "id": 22,
        "handle": "expert_tran",
        "display_name": "Chuyên gia Trần B",
        "specialties": ["Hôn nhân gia đình"],
        "price_per_session": 400000,
        "bookings": {
          "total": 38,
          "completed": 35,
          "cancelled": 2,
          "noshow": 1,
          "completion_rate": "92.1%"
        },
        "earnings": 14000000,
        "unique_clients": 22,
        "reviews": {
          "count": 28,
          "avg_rating": "4.60"
        },
        "avg_session_duration": "42",
        "performance_score": "85.2"
      }
    ],
    "summary": {
      "total_experts": 20,
      "avg_completion_rate": "87.5%",
      "total_earnings": 150000000,
      "avg_performance_score": "78.3"
    }
  }
}
```

**Performance Score Formula:**
```
Score = (Completion Rate × 40) + (Rating/5 × 40) + (Volume Score × 20)
Volume Score = min(completed_bookings / 10, 1)
```

**Gợi ý UI:**
- **Leaderboard Table** với sorting
- **Progress Bar** cho performance score
- **Badges** cho top performers
- **Filter** theo specialties, price range

---

### 4️⃣ FINANCIAL HEALTH DASHBOARD

**Endpoint:** `GET /api/v1/admin/analytics/financial-health`

**Mô tả:** Dashboard sức khỏe tài chính tổng quan

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `days` | number | 30 | Số ngày phân tích |

**Request:**
```bash
GET /api/v1/admin/analytics/financial-health?days=30
Authorization: Bearer <admin_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Financial health dashboard retrieved",
  "data": {
    "period": { "days": 30 },
    "revenue": {
      "gross": 500000000,
      "platform_share": 75000000,
      "expert_payable": 425000000,
      "refunds_deducted": 5000000,
      "net": 70000000,
      "transactions": {
        "successful": 850,
        "failed": 25,
        "avg_amount": 588235
      }
    },
    "liabilities": {
      "pending_payouts": 25000000,
      "pending_payouts_count": 15,
      "pending_refunds": 3000000,
      "pending_refunds_count": 8,
      "total_pending": 28000000
    },
    "wallets": {
      "total_balance": 180000000,
      "wallet_count": 120,
      "avg_balance": 1500000,
      "max_balance": 15000000
    },
    "daily_trend": [
      { "date": "2025-12-20", "revenue": 18000000, "transactions": 30 },
      { "date": "2025-12-21", "revenue": 22000000, "transactions": 35 },
      { "date": "2025-12-22", "revenue": 15000000, "transactions": 25 }
    ],
    "health_indicators": {
      "refund_rate": "1.0%",
      "payout_pending_ratio": "5.9%"
    }
  }
}
```

**Gợi ý UI:**
- **KPI Cards**: Gross Revenue, Net Revenue, Pending Liabilities
- **Line Chart**: Daily revenue trend
- **Gauge Chart**: Health indicators (refund rate, payout ratio)
- **Alert Badge**: Nếu refund_rate > 5% hoặc payout_pending_ratio > 20%

---

### 5️⃣ CONTENT ENGAGEMENT ANALYTICS

**Endpoint:** `GET /api/v1/admin/analytics/content-engagement`

**Mô tả:** Phân tích engagement của content (posts, comments, reactions)

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `days` | number | 30 | Số ngày phân tích |

**Request:**
```bash
GET /api/v1/admin/analytics/content-engagement?days=30
Authorization: Bearer <admin_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Content engagement analytics retrieved",
  "data": {
    "period": { "days": 30 },
    "overview": {
      "total_posts": 450,
      "total_reactions": 3500,
      "total_comments": 1200,
      "avg_reactions_per_post": "7.78",
      "avg_comments_per_post": "2.67",
      "engagement_rate": "10.44%"
    },
    "top_posts": [
      {
        "id": 125,
        "title": "Cách vượt qua stress công việc",
        "author": "Dr. Nguyễn Văn A",
        "created_at": "2025-12-15T10:30:00Z",
        "reactions": 85,
        "comments": 32,
        "engagement_score": 149
      },
      {
        "id": 118,
        "title": "5 bước để cải thiện giấc ngủ",
        "author": "Expert Trần B",
        "created_at": "2025-12-12T08:00:00Z",
        "reactions": 72,
        "comments": 28,
        "engagement_score": 128
      }
    ],
    "reaction_breakdown": [
      { "type": "LIKE", "count": 2000 },
      { "type": "LOVE", "count": 800 },
      { "type": "CARE", "count": 400 },
      { "type": "HAHA", "count": 150 },
      { "type": "WOW", "count": 100 },
      { "type": "SAD", "count": 30 },
      { "type": "ANGRY", "count": 20 }
    ],
    "daily_activity": [
      { "date": "2025-12-20", "posts": 15, "comments": 45, "reactions": 120 },
      { "date": "2025-12-21", "posts": 18, "comments": 52, "reactions": 145 },
      { "date": "2025-12-22", "posts": 12, "comments": 38, "reactions": 95 }
    ]
  }
}
```

**Gợi ý UI:**
- **Overview Cards**: Total posts, reactions, comments, engagement rate
- **Top Posts Table**: Với link đến chi tiết
- **Pie Chart**: Reaction breakdown
- **Area Chart**: Daily activity trend

---

### 6️⃣ EXPORT ANALYTICS DATA

**Endpoint:** `GET /api/v1/admin/analytics/export`

**Mô tả:** Xuất dữ liệu analytics ra CSV hoặc JSON

**Query Parameters:**
| Param | Type | Required | Options | Mô tả |
|-------|------|----------|---------|-------|
| `type` | string | ✅ | `users`, `bookings`, `revenue`, `experts`, `content` | Loại dữ liệu |
| `format` | string | ❌ | `json`, `csv` | Định dạng (default: json) |
| `days` | number | ❌ | - | Số ngày (default: 30) |

**Request:**
```bash
# Export JSON
GET /api/v1/admin/analytics/export?type=bookings&format=json&days=30

# Export CSV (download file)
GET /api/v1/admin/analytics/export?type=bookings&format=csv&days=30
```

**Response JSON:**
```json
{
  "success": true,
  "message": "Analytics data exported",
  "data": {
    "type": "bookings",
    "period": { "days": 30 },
    "total_records": 850,
    "data": [
      {
        "id": 1001,
        "user_id": 25,
        "expert_id": 15,
        "status": "COMPLETED",
        "channel": "VIDEO",
        "price": 500000,
        "start_at": "2025-12-20T10:00:00Z",
        "end_at": "2025-12-20T11:00:00Z",
        "created_at": "2025-12-18T15:30:00Z"
      }
    ]
  }
}
```

**Response CSV:**
```csv
id,user_id,expert_id,status,channel,price,start_at,end_at,created_at
1001,25,15,COMPLETED,VIDEO,500000,2025-12-20T10:00:00Z,2025-12-20T11:00:00Z,2025-12-18T15:30:00Z
```

**Gợi ý UI:**
- **Export Button** với dropdown chọn type và format
- **Date Range Picker** cho days
- **Download Progress** indicator

---

### 7️⃣ ANOMALY ALERTS

**Endpoint:** `GET /api/v1/admin/analytics/alerts`

**Mô tả:** Phát hiện và cảnh báo các bất thường trong hệ thống

**Request:**
```bash
GET /api/v1/admin/analytics/alerts
Authorization: Bearer <admin_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Anomaly alerts retrieved",
  "data": {
    "timestamp": "2025-12-26T10:30:00.000Z",
    "total_alerts": 3,
    "alerts": [
      {
        "type": "HIGH_REFUND_RATE",
        "severity": "warning",
        "message": "Refund rate is 12.5% (threshold: 10%)",
        "value": "12.5%"
      },
      {
        "type": "PAYOUT_BACKLOG",
        "severity": "warning",
        "message": "15 payouts pending for more than 3 days",
        "value": 15
      },
      {
        "type": "HIGH_OPEN_DISPUTES",
        "severity": "warning",
        "message": "25 open disputes need attention",
        "value": 25
      }
    ]
  }
}
```

**Alert Types:**
| Type | Severity | Threshold | Mô tả |
|------|----------|-----------|-------|
| `HIGH_REFUND_RATE` | warning | > 10% | Tỷ lệ refund cao |
| `PAYOUT_BACKLOG` | warning | > 10 pending > 3 days | Backlog payout |
| `HIGH_REPORT_VOLUME` | info | > 50/day | Nhiều report |
| `HIGH_OPEN_DISPUTES` | warning | > 20 open | Nhiều dispute chưa xử lý |

**Gợi ý UI:**
- **Alert Banner** ở đầu Dashboard
- **Badge Count** trên icon notification
- **Color Coding**: 
  - 🔴 `error` = đỏ
  - 🟡 `warning` = vàng
  - 🔵 `info` = xanh
- **Auto Refresh** mỗi 5 phút

---

## 🎨 GỢI Ý LAYOUT DASHBOARD MỚI

```
┌─────────────────────────────────────────────────────────────────┐
│  🔔 ALERTS BANNER (nếu có alerts)                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ │
│  │ Gross Rev   │ │ Net Revenue │ │ Pending     │ │ Alerts    │ │
│  │ 500M VND    │ │ 70M VND     │ │ 28M VND     │ │ 3 ⚠️      │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └───────────┘ │
│                                                                 │
│  ┌─────────────────────────────┐ ┌─────────────────────────────┐│
│  │ 📈 Revenue Trend (30 days)  │ │ 🏆 Top Experts              ││
│  │ [Line Chart]                │ │ [Leaderboard Table]         ││
│  └─────────────────────────────┘ └─────────────────────────────┘│
│                                                                 │
│  ┌─────────────────────────────┐ ┌─────────────────────────────┐│
│  │ 👥 Cohort Retention         │ │ 📊 Session Quality          ││
│  │ [Heatmap Table]             │ │ [Bar Chart by Channel]      ││
│  └─────────────────────────────┘ └─────────────────────────────┘│
│                                                                 │
│  ┌─────────────────────────────┐ ┌─────────────────────────────┐│
│  │ 💬 Content Engagement       │ │ 💰 Financial Health         ││
│  │ [Area Chart + Top Posts]    │ │ [Gauge + Indicators]        ││
│  └─────────────────────────────┘ └─────────────────────────────┘│
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ 📥 Export Data: [Users ▼] [JSON ▼] [30 days ▼] [Download]  ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 NOTES CHO DEVELOPER

### Authentication
Tất cả API yêu cầu:
- Header: `Authorization: Bearer <admin_token>`
- User phải có `role = "ADMIN"`

### Caching
- Một số API có cache 5 phút (cohort, financial-health)
- Có thể thêm `?nocache=1` để bypass (nếu cần implement)

### Error Handling
```json
{
  "success": false,
  "message": "Invalid type. Valid: users, bookings, revenue, experts, content",
  "data": null
}
```

### Rate Limiting
- 100 requests/phút cho admin APIs

---

## 📞 LIÊN HỆ

Nếu có thắc mắc về API, liên hệ Backend Team.

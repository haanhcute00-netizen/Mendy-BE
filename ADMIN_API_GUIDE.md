# 📊 ADMIN API - HƯỚNG DẪN CHI TIẾT

## Mục lục

1. [Kiến trúc hệ thống](#1-kiến-trúc-hệ-thống)
2. [Bảo mật & Middleware](#2-bảo-mật--middleware)
3. [Dashboard & Analytics](#3-dashboard--analytics)
4. [Quản lý người dùng](#4-quản-lý-người-dùng)
5. [Quản lý Expert](#5-quản-lý-expert)
6. [Quản lý Booking](#6-quản-lý-booking)
7. [Quản lý báo cáo (Reports)](#7-quản-lý-báo-cáo-reports)
8. [Kiểm duyệt nội dung](#8-kiểm-duyệt-nội-dung-content-moderation)
9. [Kiểm duyệt bình luận](#9-kiểm-duyệt-bình-luận)
10. [Quản lý Payout](#10-quản-lý-payout)
11. [Lịch sử giao dịch](#11-lịch-sử-giao-dịch)
12. [Cài đặt hệ thống](#12-cài-đặt-hệ-thống)
13. [Audit Logs](#13-audit-logs)

---

## 1. Kiến trúc hệ thống

```
┌─────────────────────────────────────────────────────────────┐
│                    ADMIN MODULE                              │
├─────────────────────────────────────────────────────────────┤
│  admin.routes.js    → Định nghĩa endpoints + middleware     │
│  admin.controller.js → Xử lý request/response               │
│  admin.service.js   → Business logic                        │
│  admin.repo.js      → Database queries                      │
│  audit.repo.js      → Ghi log hành động                     │
│  content-moderation.service.js → Phát hiện vi phạm          │
└─────────────────────────────────────────────────────────────┘
```

### Base URL
```
http://localhost:3000/api/v1/admin
```

### Files liên quan
| File | Mô tả |
|------|-------|
| `src/modules/admin/admin.routes.js` | Định nghĩa routes |
| `src/modules/admin/admin.controller.js` | Controllers |
| `src/modules/admin/admin.service.js` | Business logic |
| `src/modules/admin/admin.repo.js` | Database queries |
| `src/modules/admin/audit.repo.js` | Audit logging |
| `src/modules/admin/content-moderation.service.js` | Content scanning |

---

## 2. Bảo mật & Middleware

### Authentication Flow
```javascript
router.use(auth);           // Kiểm tra JWT token
router.use(requireAdmin);   // Kiểm tra role === 'ADMIN'
router.use(adminLimiter);   // Rate limit: 100 req/phút
```

### Rate Limiting
```javascript
const adminLimiter = rateLimit({
  windowMs: 60 * 1000,  // 1 phút
  max: 100,             // Tối đa 100 requests
  message: "Too many requests from admin, please try again later."
});
```

### Headers bắt buộc
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Middleware requireAdmin
```javascript
export function requireAdmin(req, res, next) {
  if (req.user.role !== "ADMIN") {
    return forbidden(res, "Admin access required");
  }
  next();
}
```

---

## 3. Dashboard & Analytics

### 3.1 Dashboard cơ bản

**Endpoint:** `GET /admin/dashboard`

**Response:**
```json
{
  "success": true,
  "message": "Dashboard data retrieved successfully",
  "data": {
    "users": {
      "active_count": 1500,
      "new_today": 25
    },
    "bookings": {
      "today": 45,
      "week": 280
    },
    "content": {
      "posts_today": 120
    },
    "moderation": {
      "reports_today": 8
    },
    "revenue": {
      "today": 5000000,
      "transactions_today": 45
    }
  }
}
```

### 3.2 Dashboard nâng cao

**Endpoint:** `GET /admin/dashboard/enhanced`

**Response bổ sung:**
```json
{
  "data": {
    "users": { ... },
    "bookings": { ... },
    "content": { ... },
    "moderation": {
      "pending": 15,
      "in_review": 5,
      "resolved": 200
    },
    "payouts": {
      "pending": {
        "count": 15,
        "amount": 7500000
      },
      "approved": {
        "count": 200,
        "amount": 100000000
      }
    }
  }
}
```

### 3.3 Booking Analytics

**Endpoint:** `GET /admin/analytics/bookings`

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `days` | number | 30 | Số ngày thống kê |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "date": "2025-12-05",
      "total_bookings": 50,
      "confirmed_bookings": 40,
      "cancelled_bookings": 5,
      "completed_bookings": 35
    },
    {
      "date": "2025-12-04",
      "total_bookings": 48,
      "confirmed_bookings": 38,
      "cancelled_bookings": 3,
      "completed_bookings": 42
    }
  ]
}
```

### 3.4 Revenue Analytics

**Endpoint:** `GET /admin/analytics/revenue`

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `days` | number | 30 | Số ngày thống kê |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "date": "2025-12-05",
      "transaction_count": 45,
      "total_revenue": 5000000
    }
  ]
}
```

---

## 4. Quản lý người dùng

### 4.1 Danh sách Users

**Endpoint:** `GET /admin/users/list`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `status` | string | Trạng thái | `ACTIVE`, `SUSPENDED` |
| `role` | string | Vai trò | `SEEKER`, `EXPERT`, `LISTENER`, `ADMIN` |
| `search` | string | Tìm kiếm | handle, email, display_name |

**Request Example:**
```
GET /admin/users/list?limit=20&offset=0&status=ACTIVE&role=SEEKER&search=john
```

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "handle": "john_doe",
        "email": "john@example.com",
        "phone": "0901234567",
        "role": "SEEKER",
        "status": "ACTIVE",
        "created_at": "2025-01-15T10:00:00Z",
        "updated_at": "2025-12-01T15:30:00Z",
        "profile": {
          "display_name": "John Doe",
          "avatar_url": "https://cloudinary.com/avatar.jpg"
        },
        "stats": {
          "booking_count": 5,
          "post_count": 12
        }
      }
    ],
    "total": 1500,
    "limit": 20,
    "offset": 0
  }
}
```

### 4.2 Chi tiết User

**Endpoint:** `GET /admin/users/:userId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "handle": "john_doe",
    "email": "john@example.com",
    "phone": "0901234567",
    "role": "SEEKER",
    "status": "ACTIVE",
    "created_at": "2025-01-15T10:00:00Z",
    "updated_at": "2025-12-01T15:30:00Z",
    "profile": {
      "display_name": "John Doe",
      "avatar_url": "https://cloudinary.com/avatar.jpg",
      "bio": "Hello, I'm John",
      "gender": "MALE",
      "year_of_birth": 1990
    },
    "expert_profile": null,
    "listener_profile": null,
    "wallet_balance": 500000
  }
}
```

**Nếu user là Expert:**
```json
{
  "expert_profile": {
    "specialties": ["anxiety", "depression", "stress"],
    "price_per_session": 300000,
    "rating_avg": 4.8,
    "kyc_status": "VERIFIED"
  }
}
```

### 4.3 Suspend User (Tạm khóa)

**Endpoint:** `PATCH /admin/users/:userId/suspend`

**Request Body:**
```json
{
  "reason": "Vi phạm quy định cộng đồng - spam quảng cáo"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User suspended successfully",
  "data": {
    "user": {
      "id": 123,
      "status": "SUSPENDED",
      "updated_at": "2025-12-05T10:30:00Z"
    }
  }
}
```

**Logic xử lý:**
1. Kiểm tra user tồn tại
2. Update status → `SUSPENDED`
3. Ghi audit log với reason
4. Trả về user đã update

### 4.4 Activate User (Kích hoạt lại)

**Endpoint:** `PATCH /admin/users/:userId/activate`

**Response:**
```json
{
  "success": true,
  "message": "User activated successfully",
  "data": {
    "user": {
      "id": 123,
      "status": "ACTIVE",
      "updated_at": "2025-12-05T10:30:00Z"
    }
  }
}
```

### 4.5 Ban User (Cấm vĩnh viễn)

**Endpoint:** `POST /admin/users/:userId/ban`

**Request Body:**
```json
{
  "reason": "Lừa đảo người dùng khác, vi phạm nghiêm trọng"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User banned successfully",
  "data": {
    "action": {
      "id": 456,
      "action": "BAN",
      "created_at": "2025-12-05T10:30:00Z"
    }
  }
}
```

**Logic xử lý:**
1. Tạo moderation action với action = `BAN`
2. Update status → `SUSPENDED`
3. Ghi audit log

---

## 5. Quản lý Expert

### 5.1 Danh sách Experts

**Endpoint:** `GET /admin/experts`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `status` | string | Trạng thái user | `ACTIVE`, `SUSPENDED` |
| `kycStatus` | string | Trạng thái KYC | `PENDING`, `VERIFIED`, `REJECTED` |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "handle": "dr_nguyen",
      "status": "ACTIVE",
      "created_at": "2025-01-10T08:00:00Z",
      "display_name": "Dr. Nguyễn Văn A",
      "avatar_url": "https://...",
      "specialties": ["anxiety", "depression"],
      "price_per_session": 300000,
      "rating_avg": 4.9,
      "kyc_status": "VERIFIED",
      "intro": "Chuyên gia tâm lý với 10 năm kinh nghiệm"
    }
  ]
}
```

### 5.2 Approve KYC (Duyệt xác minh)

**Endpoint:** `PATCH /admin/experts/:expertId/kyc/approve`

**Request Body:**
```json
{
  "notes": "Đã xác minh bằng cấp Thạc sĩ Tâm lý học và chứng chỉ hành nghề"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Expert KYC approved successfully",
  "data": {
    "expert": {
      "id": 5,
      "kyc_status": "VERIFIED",
      "updated_at": "2025-12-05T10:30:00Z"
    }
  }
}
```

### 5.3 Reject KYC (Từ chối xác minh)

**Endpoint:** `PATCH /admin/experts/:expertId/kyc/reject`

**Request Body:**
```json
{
  "reason": "Bằng cấp không hợp lệ",
  "notes": "Ảnh chụp bằng cấp bị mờ, không đọc được thông tin. Yêu cầu upload lại ảnh rõ nét hơn."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Expert KYC rejected successfully",
  "data": {
    "expert": {
      "id": 5,
      "kyc_status": "REJECTED",
      "updated_at": "2025-12-05T10:30:00Z"
    }
  }
}
```

---

## 6. Quản lý Booking

### 6.1 Danh sách Bookings

**Endpoint:** `GET /admin/bookings`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng/trang (default: 50) |
| `offset` | number | Vị trí bắt đầu |
| `status` | string | `PENDING`, `CONFIRMED`, `COMPLETED`, `CANCELLED` |
| `expertId` | number | Filter theo expert |
| `userId` | number | Filter theo seeker |
| `dateFrom` | string | Từ ngày (ISO format) |
| `dateTo` | string | Đến ngày (ISO format) |

**Request Example:**
```
GET /admin/bookings?status=CONFIRMED&expertId=5&dateFrom=2025-12-01&dateTo=2025-12-31
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "user_id": 10,
      "expert_id": 5,
      "status": "CONFIRMED",
      "start_at": "2025-12-06T09:00:00Z",
      "end_at": "2025-12-06T10:00:00Z",
      "price": 300000,
      "created_at": "2025-12-05T10:00:00Z",
      "seeker_name": "John Doe",
      "expert_name": "Dr. Nguyễn Văn A",
      "price_per_session": 300000
    }
  ]
}
```

### 6.2 Update Booking Status

**Endpoint:** `PATCH /admin/bookings/:bookingId/status`

**Request Body:**
```json
{
  "status": "CANCELLED",
  "reason": "Expert không phản hồi sau 48h, hủy booking và hoàn tiền cho seeker"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Booking status updated successfully",
  "data": {
    "booking": {
      "id": 123,
      "status": "CANCELLED",
      "updated_at": "2025-12-05T10:30:00Z"
    }
  }
}
```

---

## 7. Quản lý báo cáo (Reports)

### 7.1 Danh sách Reports

**Endpoint:** `GET /admin/reports`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `status` | string | Trạng thái | `PENDING`, `IN_REVIEW`, `RESOLVED`, `DISMISSED` |
| `targetType` | string | Loại đối tượng | `POST`, `COMMENT`, `USER` |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "target_type": "POST",
        "target_id": 123,
        "reason": "SPAM",
        "details": "Bài viết quảng cáo sản phẩm không liên quan",
        "status": "PENDING",
        "created_at": "2025-12-05T10:00:00Z",
        "resolved_at": null,
        "reporter": {
          "id": 5,
          "handle": "reporter_user",
          "display_name": "Reporter Name"
        },
        "resolver": null,
        "content": {
          "title": "Kiếm tiền nhanh với forex...",
          "content": "Click vào link để nhận 1 triệu..."
        }
      }
    ],
    "total": 25,
    "limit": 50,
    "offset": 0
  }
}
```

### 7.2 Chi tiết Report

**Endpoint:** `GET /admin/reports/:reportId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "target_type": "POST",
    "target_id": 123,
    "reason": "SPAM",
    "details": "Bài viết quảng cáo sản phẩm không liên quan",
    "status": "PENDING",
    "created_at": "2025-12-05T10:00:00Z",
    "reporter_id": 5,
    "reporter_handle": "reporter_user",
    "reporter_name": "Reporter Name",
    "post_title": "Kiếm tiền nhanh...",
    "post_content": "Click vào link...",
    "post_author_id": 10
  }
}
```

### 7.3 Report Statistics

**Endpoint:** `GET /admin/reports/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "pending": 15,
    "in_review": 5,
    "resolved": 200,
    "dismissed": 30,
    "today": 8,
    "this_week": 45
  }
}
```

### 7.4 Resolve Report (Xử lý báo cáo)

**Endpoint:** `PATCH /admin/reports/:reportId/resolve`

**Request Body:**
```json
{
  "status": "RESOLVED",
  "actionTaken": "POST_DELETED",
  "resolutionNote": "Bài viết vi phạm quy định về spam và quảng cáo. Đã xóa bài viết và cảnh cáo người dùng."
}
```

**Các giá trị actionTaken:**
| Value | Mô tả |
|-------|-------|
| `POST_DELETED` | Đã xóa bài viết |
| `POST_HIDDEN` | Đã ẩn bài viết |
| `COMMENT_DELETED` | Đã xóa bình luận |
| `USER_WARNED` | Đã cảnh cáo người dùng |
| `USER_SUSPENDED` | Đã tạm khóa người dùng |
| `USER_BANNED` | Đã cấm người dùng |
| `NONE` | Không có hành động |

**Response:**
```json
{
  "success": true,
  "message": "Report resolved successfully",
  "data": {
    "id": 1,
    "status": "RESOLVED",
    "action_taken": "POST_DELETED",
    "resolution_note": "...",
    "resolved_by": 1,
    "resolved_at": "2025-12-05T10:30:00Z"
  }
}
```

### 7.5 Dismiss Report (Bỏ qua báo cáo)

**Endpoint:** `PATCH /admin/reports/:reportId/dismiss`

**Request Body:**
```json
{
  "resolutionNote": "Không phát hiện vi phạm. Báo cáo không chính xác."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Report dismissed successfully",
  "data": {
    "id": 1,
    "status": "DISMISSED",
    "action_taken": "NONE",
    "resolution_note": "Không phát hiện vi phạm...",
    "resolved_by": 1,
    "resolved_at": "2025-12-05T10:30:00Z"
  }
}
```

---

## 8. Kiểm duyệt nội dung (Content Moderation)

### 8.1 Hệ thống phát hiện vi phạm

Hệ thống sử dụng `content-moderation.service.js` để tự động phát hiện nội dung vi phạm.

#### Từ khóa SCAM (Lừa đảo)

```javascript
const SCAM_KEYWORDS = [
  // Tiếng Việt
  'chuyển khoản ngay', 'gửi tiền trước', 'đầu tư siêu lợi nhuận', 'lãi suất cao',
  'kiếm tiền nhanh', 'làm giàu nhanh', 'thu nhập khủng', 'không cần vốn',
  'cam kết hoàn tiền', 'miễn phí 100%', 'trúng thưởng', 'bạn đã trúng',
  'click vào link', 'nhấn link ngay', 'đăng ký ngay hôm nay', 'cơ hội cuối',
  'số lượng có hạn', 'chỉ còn hôm nay', 'ưu đãi đặc biệt', 'giảm giá sốc',
  'forex', 'binary option', 'tiền ảo', 'bitcoin x100', 'crypto x1000',
  'đa cấp', 'mlm', 'hệ thống tự động', 'thu nhập thụ động',
  'zalo', 'telegram', 'liên hệ qua', 'inbox ngay', 'dm để biết thêm',
  // English
  'send money first', 'wire transfer', 'guaranteed profit', 'risk free',
  'make money fast', 'get rich quick', 'limited time offer', 'act now',
  'click here', 'free money', 'you have won', 'congratulations winner',
  'investment opportunity', 'double your money', 'passive income guaranteed'
];
```

#### Từ khóa VI PHẠM
```javascript
const VIOLATION_KEYWORDS = [
  // Bạo lực, đe dọa
  'giết', 'chết đi', 'tự tử', 'tự sát', 'kết liễu', 'đâm chém',
  // Quấy rối, xúc phạm
  'ngu', 'đần', 'khốn', 'chó', 'lừa đảo', 'bịp bợm',
  // Nội dung người lớn
  'khỏa thân', 'sex', 'xxx', 'porn',
  // Thông tin cá nhân
  'số cmnd', 'số cccd', 'mật khẩu', 'password', 'otp'
];
```

#### Pattern đáng ngờ
```javascript
const SUSPICIOUS_PATTERNS = [
  /bit\.ly\/\w+/gi,        // Link rút gọn bit.ly
  /tinyurl\.com\/\w+/gi,   // Link rút gọn tinyurl
  /t\.me\/\w+/gi,          // Link Telegram
  /wa\.me\/\w+/gi,         // Link WhatsApp
  /zalo\.me\/\w+/gi,       // Link Zalo
  /\d{10,11}/g,            // Số điện thoại
  /https?:\/\/[^\s]+\.(xyz|tk|ml|ga|cf|gq)/gi  // Domain đáng ngờ
];
```

#### Scoring System
| Loại vi phạm | Điểm/match |
|--------------|------------|
| SCAM keyword | +15 điểm |
| VIOLATION keyword | +20 điểm |
| Suspicious pattern | +10 điểm |
| ALL CAPS (>50%) | +10 điểm |
| Ký tự lặp (aaaa) | +5 điểm |

#### Risk Level
| Score | Level | Recommendation |
|-------|-------|----------------|
| ≥50 | HIGH | REJECT - Từ chối ngay |
| 30-49 | MEDIUM | REVIEW - Cần xem xét |
| 20-29 | LOW | APPROVE - Có thể chấp nhận |
| <20 | SAFE | APPROVE - An toàn |

### 8.2 Danh sách Posts

**Endpoint:** `GET /admin/posts/list`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng/trang (default: 50) |
| `offset` | number | Vị trí bắt đầu |
| `authorId` | number | Filter theo tác giả |
| `privacy` | string | `PUBLIC`, `FRIENDS`, `ONLY_ME` |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 123,
        "author_id": 10,
        "title": "Chia sẻ kinh nghiệm...",
        "content": "Nội dung bài viết...",
        "tags": ["mental-health", "tips"],
        "privacy": "PUBLIC",
        "anonymous": false,
        "created_at": "2025-12-05T10:00:00Z",
        "author_handle": "john_doe",
        "author_name": "John Doe",
        "reaction_count": 25,
        "comment_count": 10,
        "report_count": 0
      }
    ],
    "total": 500,
    "limit": 50,
    "offset": 0
  }
}
```

### 8.3 Chi tiết Post

**Endpoint:** `GET /admin/posts/:postId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "author_id": 10,
    "title": "Kiếm tiền nhanh với forex",
    "content": "Click vào link bit.ly/abc123 để nhận 1 triệu...",
    "tags": ["investment"],
    "privacy": "PUBLIC",
    "created_at": "2025-12-05T10:00:00Z",
    "author_handle": "scammer_user",
    "author_name": "Scammer",
    "author_email": "scammer@example.com",
    "reaction_count": 5,
    "comment_count": 2,
    "report_count": 3,
    "moderation_analysis": {
      "postId": 123,
      "title": "Kiếm tiền nhanh với forex",
      "isClean": false,
      "score": 65,
      "riskLevel": "HIGH",
      "recommendation": "REJECT",
      "flags": [
        {
          "type": "SCAM",
          "severity": "HIGH",
          "matches": ["kiếm tiền nhanh", "forex"],
          "message": "Phát hiện từ khóa liên quan đến scam/lừa đảo"
        },
        {
          "type": "SUSPICIOUS_LINK",
          "severity": "MEDIUM",
          "matches": ["bit.ly/abc123"],
          "message": "Phát hiện link đáng ngờ"
        }
      ]
    }
  }
}
```

### 8.4 Scan Post (Quét vi phạm)

**Endpoint:** `GET /admin/posts/:postId/scan`

**Response:**
```json
{
  "success": true,
  "message": "Post scanned successfully",
  "data": {
    "postId": 123,
    "title": "Kiếm tiền nhanh với forex",
    "isClean": false,
    "score": 65,
    "riskLevel": "HIGH",
    "recommendation": "REJECT",
    "flags": [
      {
        "type": "SCAM",
        "severity": "HIGH",
        "matches": ["kiếm tiền nhanh", "forex"],
        "message": "Phát hiện từ khóa liên quan đến scam/lừa đảo"
      }
    ],
    "details": {
      "title": {
        "isClean": false,
        "score": 30,
        "flags": [...]
      },
      "content": {
        "isClean": false,
        "score": 35,
        "flags": [...]
      }
    }
  }
}
```

### 8.5 Scan All Posts (Quét tất cả)

**Endpoint:** `GET /admin/posts/scan`

**Query Parameters:**
| Param | Type | Default | Mô tả |
|-------|------|---------|-------|
| `limit` | number | 50 | Số posts cần scan |
| `offset` | number | 0 | Vị trí bắt đầu |

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_scanned": 100,
      "high_risk": 5,
      "medium_risk": 12,
      "low_risk": 8,
      "safe": 75
    },
    "posts": [
      {
        "post_id": 123,
        "title": "Kiếm tiền nhanh...",
        "author": "scammer_user",
        "created_at": "2025-12-05T10:00:00Z",
        "score": 65,
        "riskLevel": "HIGH",
        "recommendation": "REJECT",
        "flags": [...]
      }
    ]
  }
}
```

### 8.6 Bulk Scan Posts

**Endpoint:** `POST /admin/posts/bulk-scan`

**Request Body:**
```json
{
  "postIds": [1, 2, 3, 4, 5, 10, 15, 20]
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "post_id": 1,
      "title": "Post title 1",
      "score": 0,
      "riskLevel": "SAFE",
      "recommendation": "APPROVE"
    },
    {
      "post_id": 2,
      "title": "Scam post",
      "score": 55,
      "riskLevel": "HIGH",
      "recommendation": "REJECT"
    }
  ]
}
```

### 8.7 Flagged Posts (Posts bị báo cáo)

**Endpoint:** `GET /admin/posts/flagged`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "title": "Suspicious post",
      "content": "...",
      "author_handle": "user123",
      "author_name": "User Name",
      "created_at": "2025-12-05T10:00:00Z",
      "report_count": 5,
      "report_reasons": ["SPAM", "SCAM", "INAPPROPRIATE"],
      "moderation_analysis": {
        "score": 45,
        "riskLevel": "MEDIUM",
        "flags": [...]
      }
    }
  ]
}
```

### 8.8 Hide Post (Ẩn bài viết)

**Endpoint:** `POST /admin/posts/:postId/hide`

**Request Body:**
```json
{
  "reason": "Vi phạm quy định về spam và quảng cáo"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Post hidden successfully",
  "data": {
    "post": {
      "id": 123,
      "privacy": "ONLY_ME",
      "updated_at": "2025-12-05T10:30:00Z"
    }
  }
}
```

**Logic:** Thay đổi privacy → `ONLY_ME` để ẩn khỏi public

### 8.9 Delete Post (Xóa bài viết)

**Endpoint:** `DELETE /admin/posts/:postId`

**Request Body:**
```json
{
  "reason": "Nội dung lừa đảo, vi phạm nghiêm trọng quy định cộng đồng"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Post deleted successfully",
  "data": {
    "post_id": 123
  }
}
```

---

## 9. Kiểm duyệt bình luận

### 9.1 Danh sách Comments

**Endpoint:** `GET /admin/comments`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng/trang |
| `offset` | number | Vị trí bắt đầu |
| `postId` | number | Filter theo bài viết |
| `authorId` | number | Filter theo tác giả |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 456,
        "post_id": 123,
        "author_id": 10,
        "content": "Nội dung bình luận...",
        "created_at": "2025-12-05T10:00:00Z",
        "author_handle": "user123",
        "author_name": "User Name",
        "post_title": "Tiêu đề bài viết",
        "report_count": 0,
        "moderation_analysis": {
          "isClean": true,
          "score": 0,
          "riskLevel": "SAFE"
        }
      }
    ],
    "total": 1000,
    "limit": 50,
    "offset": 0
  }
}
```

### 9.2 Chi tiết Comment

**Endpoint:** `GET /admin/comments/:commentId`

### 9.3 Scan Comment

**Endpoint:** `GET /admin/comments/:commentId/scan`

### 9.4 Flagged Comments

**Endpoint:** `GET /admin/comments/flagged`

### 9.5 Bulk Scan Comments

**Endpoint:** `POST /admin/comments/bulk-scan`

**Request Body:**
```json
{
  "commentIds": [1, 2, 3, 4, 5]
}
```

### 9.6 Hide Comment

**Endpoint:** `POST /admin/comments/:commentId/hide`

**Request Body:**
```json
{
  "reason": "Bình luận xúc phạm người khác"
}
```

### 9.7 Delete Comment

**Endpoint:** `DELETE /admin/comments/:commentId`

**Request Body:**
```json
{
  "reason": "Vi phạm quy định cộng đồng"
}
```

---

## 10. Quản lý Payout

### 10.1 Danh sách Payouts

**Endpoint:** `GET /admin/payouts`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `status` | string | Trạng thái | `PENDING`, `APPROVED`, `REJECTED` |
| `userId` | number | Filter theo user | |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 5,
        "amount": 500000,
        "status": "PENDING",
        "created_at": "2025-12-05T10:00:00Z",
        "updated_at": "2025-12-05T10:00:00Z",
        "admin_note": null,
        "user": {
          "handle": "expert_user",
          "display_name": "Expert Name"
        },
        "bank_account": {
          "bank_name": "Vietcombank",
          "account_number": "1234567890",
          "account_holder": "NGUYEN VAN A"
        },
        "current_wallet_balance": 1000000
      }
    ],
    "total": 15,
    "limit": 50,
    "offset": 0
  }
}
```

### 10.2 Chi tiết Payout

**Endpoint:** `GET /admin/payouts/:payoutId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": 5,
    "amount": 500000,
    "status": "PENDING",
    "created_at": "2025-12-05T10:00:00Z",
    "admin_note": null,
    "user": {
      "handle": "expert_user",
      "email": "expert@example.com",
      "display_name": "Expert Name"
    },
    "bank_account": {
      "bank_name": "Vietcombank",
      "account_number": "1234567890",
      "account_holder": "NGUYEN VAN A"
    },
    "current_wallet_balance": 1000000
  }
}
```

### 10.3 Payout Statistics

**Endpoint:** `GET /admin/payouts/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "pending": {
      "count": 15,
      "amount": 7500000
    },
    "approved": {
      "count": 200,
      "amount": 100000000
    },
    "rejected": {
      "count": 5
    },
    "today": {
      "count": 3,
      "amount": 1500000
    }
  }
}
```

---

## 11. Lịch sử giao dịch

### 11.1 Danh sách Transactions

**Endpoint:** `GET /admin/transactions`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng/trang |
| `offset` | number | Vị trí bắt đầu |
| `userId` | number | Filter theo user |
| `type` | string | `CREDIT`, `DEBIT` |
| `status` | string | Trạng thái giao dịch |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "wallet_id": 5,
        "type": "CREDIT",
        "amount": 255000,
        "description": "Booking #123 completed - Expert fee (85%)",
        "reference_type": "BOOKING",
        "reference_id": 123,
        "created_at": "2025-12-05T10:00:00Z",
        "owner_user_id": 5,
        "user_handle": "expert_user",
        "user_name": "Expert Name"
      }
    ],
    "total": 500,
    "limit": 50,
    "offset": 0
  }
}
```

---

## 12. Cài đặt hệ thống

### 12.1 Get System Settings

**Endpoint:** `GET /admin/settings`

**Response:**
```json
{
  "success": true,
  "data": {
    "users": {
      "total_users": "5000",
      "total_experts": "200",
      "total_listeners": "150",
      "total_seekers": "4650",
      "active_users": "4500",
      "suspended_users": "50"
    },
    "bookings": {
      "total_bookings": "10000",
      "pending_bookings": "50",
      "confirmed_bookings": "200",
      "completed_bookings": "9500",
      "cancelled_bookings": "250",
      "total_revenue": "500000000"
    },
    "experts": {
      "total_experts": "200",
      "verified_experts": "180",
      "pending_experts": "15",
      "rejected_experts": "5",
      "avg_price_per_session": "300000"
    },
    "system": {
      "version": "1.0.0",
      "environment": "production",
      "uptime": 86400
    }
  }
}
```

### 12.2 Update System Settings

**Endpoint:** `PUT /admin/settings`

**Request Body:**
```json
{
  "settings": {
    "platform_fee_percent": 15,
    "min_payout_amount": 100000,
    "max_booking_advance_days": 30
  }
}
```

---

## 13. Audit Logs

### 13.1 Cấu trúc Audit Log

Mỗi hành động của admin đều được ghi lại với cấu trúc:

```json
{
  "id": 1,
  "user_id": 1,
  "action": "USER_SUSPENDED",
  "resource": "USER",
  "resource_id": 123,
  "meta": {
    "reason": "Vi phạm quy định",
    "previous_status": "ACTIVE"
  },
  "ip_addr": "192.168.1.1",
  "user_agent": "Mozilla/5.0...",
  "created_at": "2025-12-05T10:00:00Z"
}
```

### 13.2 Danh sách Audit Logs

**Endpoint:** `GET /admin/audit/logs`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng (default: 50) |
| `before` | string | Cursor pagination (ISO date) |
| `userId` | number | Filter theo admin ID |
| `action` | string | Filter theo loại action |

**Request Example:**
```
GET /admin/audit/logs?limit=50&userId=1&action=USER_SUSPENDED
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 100,
      "user_id": 1,
      "action": "USER_SUSPENDED",
      "resource": "USER",
      "resource_id": 123,
      "meta": {
        "reason": "Vi phạm quy định cộng đồng",
        "previous_status": "ACTIVE"
      },
      "ip_addr": "192.168.1.1",
      "user_agent": "Mozilla/5.0...",
      "created_at": "2025-12-05T10:30:00Z"
    }
  ]
}
```

### 13.3 Các loại Action được log

| Action | Mô tả |
|--------|-------|
| `DASHBOARD_VIEWED` | Admin xem dashboard |
| `USERS_LIST_VIEWED` | Admin xem danh sách users |
| `USER_VIEWED` | Admin xem chi tiết user |
| `USER_SUSPENDED` | Admin suspend user |
| `USER_ACTIVATED` | Admin activate user |
| `USER_STATUS_UPDATE` | Admin cập nhật status user |
| `EXPERTS_LIST_VIEWED` | Admin xem danh sách experts |
| `EXPERT_KYC_APPROVED` | Admin duyệt KYC expert |
| `EXPERT_KYC_REJECTED` | Admin từ chối KYC expert |
| `BOOKINGS_LIST_VIEWED` | Admin xem danh sách bookings |
| `BOOKING_STATUS_UPDATED` | Admin cập nhật status booking |
| `REPORTS_LIST_VIEWED` | Admin xem danh sách reports |
| `REPORT_VIEWED` | Admin xem chi tiết report |
| `REPORT_RESOLVED` | Admin xử lý report |
| `POSTS_LIST_VIEWED` | Admin xem danh sách posts |
| `POST_VIEWED` | Admin xem chi tiết post |
| `POST_SCANNED` | Admin scan post |
| `BULK_POSTS_SCANNED` | Admin bulk scan posts |
| `POST_HIDDEN` | Admin ẩn post |
| `POST_DELETED` | Admin xóa post |
| `POST_PRIVACY_UPDATE` | Admin cập nhật privacy post |
| `FLAGGED_POSTS_VIEWED` | Admin xem flagged posts |
| `COMMENTS_LIST_VIEWED` | Admin xem danh sách comments |
| `COMMENT_VIEWED` | Admin xem chi tiết comment |
| `COMMENT_SCANNED` | Admin scan comment |
| `BULK_COMMENTS_SCANNED` | Admin bulk scan comments |
| `COMMENT_HIDDEN` | Admin ẩn comment |
| `COMMENT_DELETED` | Admin xóa comment |
| `FLAGGED_COMMENTS_VIEWED` | Admin xem flagged comments |
| `PAYOUTS_LIST_VIEWED` | Admin xem danh sách payouts |
| `PAYOUT_VIEWED` | Admin xem chi tiết payout |
| `TRANSACTIONS_LIST_VIEWED` | Admin xem transactions |
| `SYSTEM_SETTINGS_VIEWED` | Admin xem settings |
| `SYSTEM_SETTINGS_UPDATED` | Admin cập nhật settings |
| `MODERATION_ACTION` | Admin thực hiện moderation |
| `REPORTED_CONTENT_VIEWED` | Admin xem reported content |

---

## Tổng kết API Endpoints

| Module | Endpoints | Mô tả |
|--------|-----------|-------|
| Dashboard | 4 | Analytics, thống kê tổng quan |
| Users | 6 | Quản lý người dùng |
| Experts | 3 | Quản lý expert, KYC |
| Bookings | 2 | Quản lý booking |
| Reports | 5 | Xử lý báo cáo vi phạm |
| Posts | 8 | Kiểm duyệt bài viết |
| Comments | 7 | Kiểm duyệt bình luận |
| Payouts | 3 | Quản lý rút tiền |
| Transactions | 1 | Lịch sử giao dịch |
| Settings | 2 | Cài đặt hệ thống |
| Audit | 1 | Lịch sử hành động |

**Tổng cộng: ~42 endpoints**

---

## Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "Forbidden",
  "message": "Admin access required"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Not Found",
  "message": "User not found"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "error": "Too Many Requests",
  "message": "Too many requests from admin, please try again later."
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Internal Server Error",
  "message": "An unexpected error occurred",
  "requestId": "abc123"
}
```


---

## 14. Quản lý Refund (MỚI - Priority 1)

### 14.1 Danh sách Refunds

**Endpoint:** `GET /admin/refunds`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `status` | string | Trạng thái | `PENDING`, `COMPLETED`, `REJECTED`, `FAILED` |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "booking_id": 123,
        "payment_intent_id": 456,
        "user_id": 10,
        "amount": 300000,
        "platform_fee_refunded": 45000,
        "reason": "Expert không tham gia buổi tư vấn",
        "status": "PENDING",
        "created_at": "2025-12-05T10:00:00Z",
        "seeker_name": "John Doe",
        "expert_name": "Dr. Nguyen"
      }
    ],
    "total": 25,
    "limit": 50,
    "offset": 0
  }
}
```

### 14.2 Refund Statistics

**Endpoint:** `GET /admin/refunds/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "pending": { "count": 10, "amount": 3000000 },
    "completed": { "count": 150, "amount": 45000000 },
    "rejected": { "count": 5 },
    "failed": { "count": 2 },
    "today": { "count": 3, "amount": 900000 }
  }
}
```

### 14.3 Chi tiết Refund

**Endpoint:** `GET /admin/refunds/:refundId`

### 14.4 Approve Refund

**Endpoint:** `POST /admin/refunds/:refundId/approve`

**Request Body:**
```json
{
  "adminNote": "Đã xác minh expert không tham gia. Hoàn tiền cho seeker."
}
```

### 14.5 Reject Refund

**Endpoint:** `POST /admin/refunds/:refundId/reject`

**Request Body:**
```json
{
  "reason": "Seeker đã tham gia đầy đủ buổi tư vấn",
  "adminNote": "Không đủ điều kiện hoàn tiền theo chính sách"
}
```

---

## 15. Quản lý Dispute (MỚI - Priority 1)

### 15.1 Danh sách Disputes

**Endpoint:** `GET /admin/disputes`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `status` | string | Trạng thái | `OPEN`, `UNDER_REVIEW`, `ESCALATED`, `RESOLVED`, `CLOSED` |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "booking_id": 123,
        "raised_by": 10,
        "against_user": 5,
        "reason": "QUALITY",
        "description": "Expert không chuyên nghiệp...",
        "status": "OPEN",
        "created_at": "2025-12-05T10:00:00Z",
        "raiser_name": "John Doe",
        "against_name": "Dr. Nguyen",
        "admin_name": null
      }
    ],
    "total": 15,
    "limit": 50,
    "offset": 0
  }
}
```

### 15.2 Dispute Statistics

**Endpoint:** `GET /admin/disputes/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "open": 5,
    "under_review": 3,
    "escalated": 1,
    "resolved": 100,
    "closed": 50,
    "today": 2,
    "this_week": 8
  }
}
```

### 15.3 Chi tiết Dispute

**Endpoint:** `GET /admin/disputes/:disputeId`

### 15.4 Dispute Messages

**Endpoint:** `GET /admin/disputes/:disputeId/messages`

### 15.5 Assign Dispute to Admin

**Endpoint:** `PATCH /admin/disputes/:disputeId/assign`

**Request Body:**
```json
{
  "adminId": 1
}
```

### 15.6 Add Admin Message

**Endpoint:** `POST /admin/disputes/:disputeId/message`

**Request Body:**
```json
{
  "message": "Chúng tôi đã xem xét và cần thêm thông tin...",
  "attachments": []
}
```

### 15.7 Resolve Dispute

**Endpoint:** `PATCH /admin/disputes/:disputeId/resolve`

**Request Body:**
```json
{
  "resolution": "Hoàn tiền 50% cho seeker do expert không đáp ứng đủ thời gian",
  "refundAmount": 150000,
  "status": "RESOLVED"
}
```

---

## 16. Quản lý Review (MỚI - Priority 2)

### 16.1 Danh sách Reviews

**Endpoint:** `GET /admin/reviews`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng/trang |
| `offset` | number | Vị trí bắt đầu |
| `expertId` | number | Filter theo expert |
| `rating` | number | Filter theo rating (1-5) |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 10,
        "expert_id": 5,
        "booking_id": 123,
        "rating": 5,
        "comment": "Rất hài lòng với buổi tư vấn",
        "created_at": "2025-12-05T10:00:00Z",
        "reviewer_name": "John Doe",
        "expert_name": "Dr. Nguyen",
        "report_count": 0
      }
    ],
    "total": 500,
    "limit": 50,
    "offset": 0
  }
}
```

### 16.2 Review Statistics

**Endpoint:** `GET /admin/reviews/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "total": 500,
    "avg_rating": 4.5,
    "distribution": {
      "five_star": 300,
      "four_star": 120,
      "three_star": 50,
      "two_star": 20,
      "one_star": 10
    },
    "today": 5,
    "this_week": 35
  }
}
```

### 16.3 Chi tiết Review

**Endpoint:** `GET /admin/reviews/:reviewId`

### 16.4 Hide Review

**Endpoint:** `POST /admin/reviews/:reviewId/hide`

**Request Body:**
```json
{
  "reason": "Review chứa nội dung xúc phạm"
}
```

### 16.5 Delete Review

**Endpoint:** `DELETE /admin/reviews/:reviewId`

**Request Body:**
```json
{
  "reason": "Review giả mạo, không phải từ booking thực"
}
```

---

## 17. Quản lý Chat (MỚI - Priority 2)

### 17.1 Danh sách Chat Threads

**Endpoint:** `GET /admin/chat/threads`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `type` | string | Loại thread | `DM`, `BOOKING` |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "type": "DM",
        "booking_id": null,
        "last_message_at": "2025-12-05T10:00:00Z",
        "created_at": "2025-12-01T08:00:00Z",
        "message_count": 50,
        "member_count": 2
      }
    ],
    "total": 1000,
    "limit": 50,
    "offset": 0
  }
}
```

### 17.2 Chat Statistics

**Endpoint:** `GET /admin/chat/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "threads": {
      "total": 1000,
      "dm": 800,
      "booking": 200
    },
    "messages": {
      "total": 50000,
      "today": 500,
      "this_week": 3500
    },
    "active_users_today": 150
  }
}
```

### 17.3 Chi tiết Thread

**Endpoint:** `GET /admin/chat/threads/:threadId`

### 17.4 Thread Messages

**Endpoint:** `GET /admin/chat/threads/:threadId/messages`

### 17.5 Delete Message

**Endpoint:** `DELETE /admin/chat/messages/:messageId`

**Request Body:**
```json
{
  "reason": "Tin nhắn chứa nội dung quấy rối"
}
```

---

## 18. Quản lý Call Sessions (MỚI - Priority 2)

### 18.1 Danh sách Call Sessions

**Endpoint:** `GET /admin/calls`

**Query Parameters:**
| Param | Type | Mô tả | Giá trị |
|-------|------|-------|---------|
| `limit` | number | Số lượng/trang | Default: 50 |
| `offset` | number | Vị trí bắt đầu | Default: 0 |
| `status` | string | Trạng thái | `INIT`, `RINGING`, `CONNECTED`, `ENDED`, `MISSED`, `REJECTED`, `BUSY`, `FAILED` |
| `kind` | string | Loại cuộc gọi | `AUDIO`, `VIDEO` |

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "thread_id": 5,
        "caller_id": 10,
        "callee_id": 5,
        "kind": "VIDEO",
        "status": "ENDED",
        "started_at": "2025-12-05T10:00:00Z",
        "connected_at": "2025-12-05T10:00:30Z",
        "ended_at": "2025-12-05T11:00:00Z",
        "end_reason": "hangup",
        "caller_handle": "john_doe",
        "caller_name": "John Doe",
        "callee_handle": "dr_nguyen",
        "callee_name": "Dr. Nguyen",
        "duration_seconds": 3570
      }
    ],
    "total": 5000,
    "limit": 50,
    "offset": 0
  }
}
```

### 18.2 Call Statistics

**Endpoint:** `GET /admin/calls/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "total": 5000,
    "successful": 4500,
    "missed": 300,
    "rejected": 100,
    "failed": 100,
    "by_type": {
      "video": 3000,
      "audio": 2000
    },
    "today": 50,
    "this_week": 350,
    "avg_duration_seconds": 2400
  }
}
```

### 18.3 Chi tiết Call Session

**Endpoint:** `GET /admin/calls/:callId`

**Response bao gồm:** call details, events, metrics, recordings

---

## 19. Quản lý Wallet (MỚI - Priority 3)

### 19.1 Danh sách Wallets

**Endpoint:** `GET /admin/wallets`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng/trang |
| `offset` | number | Vị trí bắt đầu |
| `minBalance` | number | Số dư tối thiểu |
| `maxBalance` | number | Số dư tối đa |

### 19.2 Wallet Statistics

**Endpoint:** `GET /admin/wallets/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "wallets": {
      "total": 5000,
      "with_balance": 2000,
      "empty": 3000
    },
    "balance": {
      "total": 500000000,
      "average": 100000,
      "max": 10000000
    },
    "transactions": {
      "total": 50000,
      "today": 100,
      "today_volume": 5000000
    }
  }
}
```

### 19.3 Chi tiết Wallet

**Endpoint:** `GET /admin/wallets/:userId`

### 19.4 Manual Wallet Adjustment

**Endpoint:** `POST /admin/wallets/:userId/adjust`

**Request Body:**
```json
{
  "amount": 100000,
  "reason": "Bồi thường do lỗi hệ thống",
  "type": "ADJUST"
}
```

**Note:** `amount` có thể âm để trừ tiền

---

## 20. Quản lý Skills & Domains (MỚI - Priority 3)

### 20.1 Skills CRUD

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/admin/skills` | Danh sách skills |
| POST | `/admin/skills` | Tạo skill mới |
| PUT | `/admin/skills/:skillId` | Cập nhật skill |
| DELETE | `/admin/skills/:skillId` | Xóa skill |

### 20.2 Domains CRUD

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/admin/domains` | Danh sách domains |
| POST | `/admin/domains` | Tạo domain mới |
| PUT | `/admin/domains/:domainId` | Cập nhật domain |
| DELETE | `/admin/domains/:domainId` | Xóa domain |

---

## 21. Quản lý Recurring Bookings (MỚI - Priority 3)

### 21.1 Danh sách Recurring Bookings

**Endpoint:** `GET /admin/recurring`

**Query Parameters:**
| Param | Type | Mô tả |
|-------|------|-------|
| `limit` | number | Số lượng/trang |
| `offset` | number | Vị trí bắt đầu |
| `status` | string | Trạng thái |

### 21.2 Cancel Recurring Booking

**Endpoint:** `POST /admin/recurring/:templateId/cancel`

**Request Body:**
```json
{
  "reason": "Expert đã ngừng hoạt động trên platform"
}
```

---

## 22. Payout Approval (MỚI - Priority 1)

### 22.1 Approve Payout

**Endpoint:** `POST /admin/payouts/:payoutId/approve`

**Request Body:**
```json
{
  "adminNote": "Đã xác minh thông tin tài khoản ngân hàng"
}
```

### 22.2 Reject Payout

**Endpoint:** `POST /admin/payouts/:payoutId/reject`

**Request Body:**
```json
{
  "reason": "Thông tin tài khoản ngân hàng không khớp",
  "adminNote": "Yêu cầu user cập nhật lại thông tin"
}
```

---

## Tổng kết API Endpoints

### Priority 1 - Critical (Tài chính)
| Module | Endpoints |
|--------|-----------|
| Refunds | GET /refunds, GET /refunds/stats, GET /refunds/:id, POST /refunds/:id/approve, POST /refunds/:id/reject |
| Disputes | GET /disputes, GET /disputes/stats, GET /disputes/:id, GET /disputes/:id/messages, PATCH /disputes/:id/assign, POST /disputes/:id/message, PATCH /disputes/:id/resolve |
| Payouts | POST /payouts/:id/approve, POST /payouts/:id/reject |

### Priority 2 - High (An toàn người dùng)
| Module | Endpoints |
|--------|-----------|
| Reviews | GET /reviews, GET /reviews/stats, GET /reviews/:id, POST /reviews/:id/hide, DELETE /reviews/:id |
| Chat | GET /chat/threads, GET /chat/stats, GET /chat/threads/:id, GET /chat/threads/:id/messages, DELETE /chat/messages/:id |
| Calls | GET /calls, GET /calls/stats, GET /calls/:id |

### Priority 3 - Medium (Quản lý hệ thống)
| Module | Endpoints |
|--------|-----------|
| Wallets | GET /wallets, GET /wallets/stats, GET /wallets/:userId, POST /wallets/:userId/adjust |
| Skills | GET /skills, POST /skills, PUT /skills/:id, DELETE /skills/:id |
| Domains | GET /domains, POST /domains, PUT /domains/:id, DELETE /domains/:id |
| Recurring | GET /recurring, POST /recurring/:id/cancel |


---

## 23. Sửa & Xóa User (MỚI)

### 23.1 Update User

**Endpoint:** `PUT /admin/users/:userId`

**Request Body:**
```json
{
  "email": "newemail@example.com",
  "phone": "0909123456",
  "handle": "new_handle",
  "role_primary": "EXPERT",
  "profile": {
    "display_name": "New Display Name",
    "bio": "Updated bio",
    "gender": "MALE",
    "year_of_birth": 1990,
    "avatar_url": "https://example.com/avatar.jpg"
  }
}
```

**Các trường có thể update:**

| Field | Type | Mô tả |
|-------|------|-------|
| `email` | string | Email mới |
| `phone` | string | Số điện thoại mới |
| `handle` | string | Username mới |
| `role_primary` | string | Vai trò: `SEEKER`, `LISTENER`, `EXPERT` |
| `profile.display_name` | string | Tên hiển thị |
| `profile.bio` | string | Tiểu sử |
| `profile.gender` | string | Giới tính: `MALE`, `FEMALE`, `OTHER` |
| `profile.year_of_birth` | number | Năm sinh |
| `profile.avatar_url` | string | URL avatar |

**Response:**
```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "user": {
      "id": 123,
      "email": "newemail@example.com",
      "phone": "0909123456",
      "handle": "new_handle",
      "role_primary": "EXPERT",
      "status": "ACTIVE",
      "updated_at": "2025-12-05T10:30:00Z"
    },
    "profile": {
      "user_id": 123,
      "display_name": "New Display Name",
      "bio": "Updated bio",
      "gender": "MALE",
      "year_of_birth": 1990
    }
  }
}
```

**Lưu ý:**
- Không thể thay đổi role thành `ADMIN`
- Không thể sửa thông tin của admin khác
- Tất cả thay đổi được ghi vào audit log

### 23.2 Delete User

**Endpoint:** `DELETE /admin/users/:userId`

**Request Body:**
```json
{
  "reason": "Vi phạm nghiêm trọng quy định cộng đồng",
  "hardDelete": false
}
```

**Parameters:**

| Field | Type | Default | Mô tả |
|-------|------|---------|-------|
| `reason` | string | required | Lý do xóa (bắt buộc) |
| `hardDelete` | boolean | false | `false` = soft delete, `true` = xóa vĩnh viễn |

**Soft Delete Response (hardDelete = false):**
```json
{
  "success": true,
  "message": "User deleted (soft delete)",
  "data": {
    "id": 123,
    "status": "DELETED",
    "updated_at": "2025-12-05T10:30:00Z"
  }
}
```

**Hard Delete Response (hardDelete = true):**
```json
{
  "success": true,
  "message": "User permanently deleted",
  "data": {
    "user_id": 123,
    "deleted": true
  }
}
```

**Lưu ý:**
- Không thể xóa tài khoản admin
- Không thể tự xóa tài khoản của mình
- Soft delete: chỉ đổi status → `DELETED`, dữ liệu vẫn còn
- Hard delete: xóa vĩnh viễn user và tất cả dữ liệu liên quan (profiles, wallets...)
- Tất cả thao tác được ghi vào audit log

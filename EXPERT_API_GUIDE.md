# Hướng Dẫn Test API Expert - Postman

Guide đầy đủ để test các chức năng của Expert trên Healing_BE.

---

## 📋 Mục lục

1. [Setup ban đầu](#setup)
2. [Đăng ký & Login](#auth)
3. [Tạo Expert Profile](#profile)
4. [Quản lý Skills & Credentials](#skills)
5. [Quản lý Availability](#availability)
6. [Nhận & Xử lý Booking](#bookings)
7. [Rút tiền (Payout)](#payout)
8. [Reviews & Rating](#reviews)

---

## 1️⃣ Setup ban đầu {#setup}

### Base URL
```
http://localhost:3000
```

### Tạo Environment trong Postman

Tạo environment với các biến:
- `baseUrl`: `http://localhost:3000`
- `token`: (sẽ được set tự động sau login)
- `expertId`: (sẽ được set tự động)
- `bookingId`: (để test)

---

## 2️⃣ Đăng ký & Login {#auth}

### A. Đăng ký tài khoản mới

**Request:**
```
POST {{baseUrl}}/api/auth/register
Content-Type: application/json
```

**Body:**
```json
{
  "email": "expert1@healing.com",
  "password": "Expert@123456",
  "full_name": "Dr. Nguyễn Văn A",
  "handle": "expert_nguyen_a",
  "role_primary": "EXPERT"
}
```

**Response mẫu:**
```json
{
  "message": "User registered successfully",
  "data": {
    "id": 5,
    "email": "expert1@healing.com",
    "handle": "expert_nguyen_a",
    "role_primary": "EXPERT"
  }
}
```

### B. Login

**Request:**
```
POST {{baseUrl}}/api/auth/login
Content-Type: application/json
```

**Body:**
```json
{
  "email": "expert1@healing.com",
  "password": "Expert@123456"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 5,
      "email": "expert1@healing.com",
      "role": "EXPERT"
    }
  }
}
```

**⚡ Script tự động (Tab "Tests"):**
```javascript
if (pm.response.code === 200) {
    const data = pm.response.json().data;
    pm.environment.set("token", data.token);
    console.log("Token saved:", data.token);
}
```

---

## 3️⃣ Tạo Expert Profile {#profile}

**Từ giờ mọi request cần header:**
```
Authorization: Bearer {{token}}
```

### A. Tạo/Cập nhật Profile

**Request:**
```
PUT {{baseUrl}}/api/experts/profile
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:**
```json
{
  "bio": "Tâm lý học lâm sàng với 10 năm kinh nghiệm điều trị trầm cảm và lo âu",
  "specializations": ["ANXIETY", "DEPRESSION", "STRESS"],
  "price_per_session": 500000,
  "session_duration_min": 60,
  "languages": ["vi", "en"],
  "approach": "CBT (Cognitive Behavioral Therapy)",
  "target_audience": ["TEENS", "ADULTS"],
  "domains": ["MENTAL_HEALTH", "RELATIONSHIP"]
}
```

**Response:**
```json
{
  "message": "Expert profile updated successfully",
  "data": {
    "id": 3,
    "user_id": 5,
    "bio": "Tâm lý học lâm sàng...",
    "price_per_session": "500000.00",
    "rating_avg": "0.00",
    "kyc_status": "PENDING"
  }
}
```

### B. Xem Profile của mình

**Request:**
```
GET {{baseUrl}}/api/experts/profile
Authorization: Bearer {{token}}
```

---

## 4️⃣ Quản lý Skills & Credentials {#skills}

### A. Thêm Skill

**Request:**
```
POST {{baseUrl}}/api/experts/skills
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Cognitive Behavioral Therapy",
  "level": "EXPERT",
  "years": 10
}
```

### B. Thêm Experience

**Request:**
```
POST {{baseUrl}}/api/experts/experience
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:**
```json
{
  "title": "Senior Clinical Psychologist",
  "organization": "Bệnh viện Tâm thần TW1",
  "start_date": "2014-01-01",
  "end_date": null,
  "current": true,
  "description": "Điều trị các bệnh nhân rối loạn lo âu và trầm cảm"
}
```

### C. Thêm Education

**Request:**
```
POST {{baseUrl}}/api/experts/education
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:**
```json
{
  "degree": "Master of Psychology",
  "institution": "Đại học Quốc gia Hà Nội",
  "field": "Clinical Psychology",
  "start_year": 2008,
  "end_year": 2012
}
```

### D. Thêm Certification

**Request:**
```
POST {{baseUrl}}/api/experts/certifications
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Licensed Clinical Psychologist",
  "issuer": "Bộ Y tế Việt Nam",
  "issue_date": "2013-06-15",
  "expiry_date": null,
  "credential_id": "VN-PSY-2013-001234"
}
```

---

## 5️⃣ Quản lý Availability (Lịch rảnh) {#availability}

### A. Thêm khung giờ rảnh

**Request:**
```
POST {{baseUrl}}/api/experts/availability
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body (ví dụ: Thứ 2-6, 9h-17h):**
```json
{
  "day_of_week": 1,
  "start_time": "09:00:00",
  "end_time": "17:00:00"
}
```

**Lặp lại cho các ngày khác** (day_of_week: 0=CN, 1=T2, ..., 6=T7):

```json
// Thứ 3
{ "day_of_week": 2, "start_time": "09:00:00", "end_time": "17:00:00" }

// Thứ 4
{ "day_of_week": 3, "start_time": "09:00:00", "end_time": "17:00:00" }

// Thứ 5
{ "day_of_week": 4, "start_time": "09:00:00", "end_time": "17:00:00" }

// Thứ 6
{ "day_of_week": 5, "start_time": "09:00:00", "end_time": "17:00:00" }
```

### B. Xem lịch rảnh của mình

**Request:**
```
GET {{baseUrl}}/api/experts/availability
Authorization: Bearer {{token}}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "expert_id": 3,
      "day_of_week": 1,
      "start_time": "09:00:00",
      "end_time": "17:00:00"
    },
    ...
  ]
}
```

---

## 6️⃣ Nhận & Xử lý Booking {#bookings}

### A. Xem danh sách booking của mình

**Request:**
```
GET {{baseUrl}}/api/bookings/mine?as=expert
Authorization: Bearer {{token}}
```

**Query params:**
- `as=expert` - Xem bookings mình là expert
- `as=seeker` - Xem bookings mình là khách

**Response:**
```json
{
  "data": [
    {
      "id": 7,
      "user_id": 4,
      "expert_id": 5,
      "status": "PENDING",
      "channel": "VIDEO",
      "price": "500000.00",
      "start_at": "2025-11-23T14:00:00Z",
      "end_at": "2025-11-23T15:00:00Z",
      "user": {
        "full_name": "Nguyễn Thị B",
        "avatar_url": null
      }
    }
  ]
}
```

### B. Xem chi tiết booking

**Request:**
```
GET {{baseUrl}}/api/bookings/7
Authorization: Bearer {{token}}
```

### C. Xác nhận booking (Optional)

**Request:**
```
PATCH {{baseUrl}}/api/bookings/7/confirm
Authorization: Bearer {{token}}
```

**Response:**
```json
{
  "message": "Booking confirmed",
  "data": {
    "id": 7,
    "status": "CONFIRMED"
  }
}
```

### D. Hoàn thành booking (Sau khi tư vấn xong)

**Request:**
```
PATCH {{baseUrl}}/api/bookings/7/complete
Authorization: Bearer {{token}}
```

**⚡ Quan trọng:** Sau khi complete, tiền sẽ được chuyển vào ví của expert!

**Response:**
```json
{
  "message": "Booking completed successfully",
  "data": {
    "id": 7,
    "status": "COMPLETED"
  }
}
```

### E. Hủy booking

**Request:**
```
PATCH {{baseUrl}}/api/bookings/7/cancel
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body (optional):**
```json
{
  "reason": "Có việc bận đột xuất"
}
```

---

## 7️⃣ Rút tiền (Payout) {#payout}

### A. Xem số dư ví

**Request:**
```
GET {{baseUrl}}/api/wallets/balance
Authorization: Bearer {{token}}
```

**Response:**
```json
{
  "data": {
    "balance": "1500000.00",
    "currency": "VND"
  }
}
```

### B. Thêm tài khoản ngân hàng

**Request:**
```
POST {{baseUrl}}/api/payout-accounts
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:**
```json
{
  "bank_code": "VCB",
  "account_number": "1234567890",
  "account_name": "NGUYEN VAN A",
  "branch": "CN Hà Nội"
}
```

**Response:**
```json
{
  "message": "Payout account created",
  "data": {
    "id": 3,
    "user_id": 5,
    "bank_code": "VCB",
    "account_number": "***7890",
    "account_name": "NGUYEN VAN A",
    "is_default": true
  }
}
```

### C. Gửi yêu cầu rút tiền

**Request:**
```
POST {{baseUrl}}/api/payouts/request
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:**
```json
{
  "amount": 1000000,
  "payout_account_id": 3
}
```

**Response:**
```json
{
  "message": "Payout request created",
  "data": {
    "id": 5,
    "user_id": 5,
    "amount": "1000000.00",
    "status": "PENDING",
    "created_at": "2025-11-21T12:30:00Z"
  }
}
```

### D. Xem lịch sử rút tiền

**Request:**
```
GET {{baseUrl}}/api/payouts/history
Authorization: Bearer {{token}}
```

---

## 8️⃣ Reviews & Rating {#reviews}

### A. Xem reviews của mình

**Request:**
```
GET {{baseUrl}}/api/reviews?expert_id={{expertId}}
Authorization: Bearer {{token}}
```

**Response:**
```json
{
  "data": [
    {
      "id": 12,
      "expert_id": 5,
      "user_id": 4,
      "booking_id": 7,
      "rating": 5,
      "comment": "Rất chuyên nghiệp và tận tâm!",
      "created_at": "2025-11-21T15:00:00Z",
      "user": {
        "full_name": "Nguyễn Thị B",
        "avatar_url": null
      }
    }
  ]
}
```

### B. Xem thống kê của mình

**Request:**
```
GET {{baseUrl}}/api/experts/stats
Authorization: Bearer {{token}}
```

**Response:**
```json
{
  "data": {
    "total_bookings": 45,
    "completed_bookings": 38,
    "total_revenue": "19000000.00",
    "average_rating": "4.85",
    "total_reviews": 32,
    "response_rate": "98.5",
    "completion_rate": "84.4"
  }
}
```

---

## 🎯 Flow Test Hoàn Chỉnh

### Kịch bản: Expert từ đăng ký → Nhận booking → Rút tiền

```
1. Đăng ký account (POST /auth/register) ✓
   → Save token vào environment

2. Tạo expert profile (PUT /experts/profile) ✓
   → Điền bio, price, specializations

3. Thêm credentials:
   - Skills (POST /experts/skills) ✓
   - Experience (POST /experts/experience) ✓
   - Education (POST /experts/education) ✓
   - Certifications (POST /experts/certifications) ✓

4. Thêm availability (POST /experts/availability) ✓
   → Thứ 2-6, 9h-17h

5. Đợi seeker đặt lịch...
   (Hoặc tự test bằng account seeker khác)

6. Xem bookings (GET /bookings/mine?as=expert) ✓
   → Có 1 booking PENDING

7. Xác nhận booking (PATCH /bookings/:id/confirm) ✓
   → Status: CONFIRMED

8. Sau khi tư vấn xong:
   Complete booking (PATCH /bookings/:id/complete) ✓
   → Tiền vào ví

9. Kiểm tra ví (GET /wallets/balance) ✓
   → Có 500,000 VND

10. Thêm tài khoản ngân hàng (POST /payout-accounts) ✓

11. Rút tiền (POST /payouts/request) ✓
    → Status: PENDING

12. Admin duyệt → Tiền về tài khoản
```

---

## 📝 Notes quan trọng

### Authentication
- Mọi API (trừ login/register) cần header: `Authorization: Bearer {token}`
- Token có thời hạn (check JWT_EXPIRY trong .env)

### Booking Flow
- PENDING → CONFIRMED → COMPLETED
- Chỉ có thể complete khi booking đã CONFIRMED
- Complete = Expert nhận tiền vào ví

### Payout
- Cần có balance > 0 trong ví
- Phải thêm tài khoản ngân hàng trước
- Admin phải approve thì mới rút được

### Testing Tips
- Dùng environment variables ({{token}}, {{bookingId}})
- Setup Tests scripts để tự động save responses
- Test cả success & error cases

---

## 🔧 Postman Collection

Import collection này để test nhanh:

**File:** `Healing_Expert_API.postman_collection.json`

```json
{
  "info": {
    "name": "Healing Expert API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Register Expert",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "url": "{{baseUrl}}/api/auth/register",
            "body": {
              "mode": "raw",
              "raw": "{\n  \"email\": \"expert1@healing.com\",\n  \"password\": \"Expert@123456\",\n  \"full_name\": \"Dr. Nguyễn Văn A\",\n  \"handle\": \"expert_nguyen_a\",\n  \"role_primary\": \"EXPERT\"\n}"
            }
          }
        },
        {
          "name": "Login",
          "event": [{
            "listen": "test",
            "script": {
              "exec": ["if (pm.response.code === 200) {", "  pm.environment.set('token', pm.response.json().data.token);", "}"]
            }
          }],
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "url": "{{baseUrl}}/api/auth/login",
            "body": {
              "mode": "raw",
              "raw": "{\n  \"email\": \"expert1@healing.com\",\n  \"password\": \"Expert@123456\"\n}"
            }
          }
        }
      ]
    }
  ]
}
```

---

**Happy Testing! 🚀**

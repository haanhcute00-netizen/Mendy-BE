# 🔐 PHÂN TÍCH CHI TIẾT MODULE AUTHENTICATION

## 📁 Cấu Trúc Files

```
src/modules/auth/
├── auth.controller.js    # Xử lý HTTP requests
├── auth.service.js       # Business logic chính
├── auth.routes.js        # Định nghĩa routes
├── oauth.repo.js         # Database queries cho OAuth
└── oauth.service.js      # Logic xử lý Google OAuth

src/middlewares/
└── auth.js               # JWT middleware

src/config/
├── passport.js           # Cấu hình Passport.js
└── mailer.js             # Cấu hình gửi email
```

---

## 🌐 API ENDPOINTS

| Method | Endpoint | Mô tả | Auth Required |
|--------|----------|-------|---------------|
| POST | `/api/v1/auth/register` | Đăng ký tài khoản | ❌ |
| POST | `/api/v1/auth/login` | Đăng nhập | ❌ |
| POST | `/api/v1/auth/refresh` | Làm mới access token | ❌ |
| POST | `/api/v1/auth/forgot-password` | Yêu cầu OTP reset password | ❌ |
| POST | `/api/v1/auth/verify-reset-otp` | Xác thực OTP | ❌ |
| POST | `/api/v1/auth/reset-password` | Đặt lại mật khẩu | ❌ |
| GET | `/api/v1/auth/google` | Redirect đến Google OAuth | ❌ |
| GET | `/api/v1/auth/google/callback` | Callback từ Google | ❌ |
| GET | `/api/v1/auth/oauth-profile` | Lấy profile OAuth | ✅ |

---

## 📋 CHI TIẾT TỪNG CHỨC NĂNG

---

### 1. 📝 ĐĂNG KÝ (Register)

**Endpoint:** `POST /api/v1/auth/register`

**Request Body:**
```json
{
  "handle": "username123",      // Bắt buộc - unique
  "email": "user@example.com",  // Tùy chọn - unique nếu có
  "password": "mypassword"      // Bắt buộc
}
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "auth.register.success",
  "data": {
    "user": {
      "id": 1,
      "handle": "username123",
      "email": "user@example.com",
      "role_primary": "SEEKER",
      "status": "ACTIVE",
      "created_at": "2025-12-25T10:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": "1h"
  }
}
```

**Validation Rules:**
| Field | Rule |
|-------|------|
| handle | Bắt buộc, unique |
| email | Tùy chọn, format email hợp lệ, unique |
| password | Bắt buộc |

**Error Cases:**
| Status | Message | Nguyên nhân |
|--------|---------|-------------|
| 400 | "handle & password are required" | Thiếu handle hoặc password |
| 400 | "Invalid email format" | Email không đúng định dạng |
| 409 | "Handle already exists" | Handle đã tồn tại |
| 409 | "Email already exists" | Email đã được sử dụng |

**Flow:**
```
1. Validate input (handle, email format)
2. Check handle exists → 409 nếu có
3. Check email exists (nếu có email) → 409 nếu có
4. Hash password với bcrypt (salt rounds = 10)
5. Insert user vào DB với role = "SEEKER"
6. Generate JWT access token
7. Return user + token
```

---

### 2. 🔑 ĐĂNG NHẬP (Login)

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**
```json
{
  "identifier": "user@example.com",  // Email hoặc handle
  "password": "mypassword"
}
```

*Hoặc (backward compatible):*
```json
{
  "email": "user@example.com",
  "password": "mypassword"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "auth.login.success",
  "data": {
    "user": {
      "id": 1,
      "handle": "username123",
      "email": "user@example.com",
      "role_primary": "SEEKER",
      "status": "ACTIVE"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": "1h"
  }
}
```

**Error Cases:**
| Status | Message | Nguyên nhân |
|--------|---------|-------------|
| 400 | "Email/handle and password are required" | Thiếu thông tin |
| 401 | "Invalid email or handle" | Không tìm thấy user |
| 401 | "Invalid password" | Sai mật khẩu |
| 401 | "Account not found" | Tài khoản đã bị xóa |
| 403 | "Account suspended" | Tài khoản bị khóa |

**Flow:**
```
1. Tìm user theo email HOẶC handle
2. Check account status (SUSPENDED/DELETED)
3. So sánh password với bcrypt.compare()
4. Generate access token (1h) + refresh token (30d)
5. Lưu session vào DB (user_sessions)
6. Return tokens + user info
```

**Session Storage:**
```sql
INSERT INTO app.user_sessions 
  (user_id, token, device_info, ip_address, expires_at)
VALUES ($1, $2, $3, $4, $5)
```

---

### 3. 🔄 LÀM MỚI TOKEN (Refresh)

**Endpoint:** `POST /api/v1/auth/refresh`

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."  // Refresh token
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "auth.refresh.success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": "1h"
  }
}
```

**Validation:**
- Token phải có `typ: "refresh"`
- Token phải còn hạn
- User phải tồn tại

**Error Cases:**
| Status | Message | Nguyên nhân |
|--------|---------|-------------|
| 400 | "auth.refresh.invalidToken" | Không có token |
| 401 | "Invalid token" | Token không phải refresh type |
| 401 | "users.profile.notFound" | User không tồn tại |

---

### 4. 📧 QUÊN MẬT KHẨU (Forgot Password)

**Endpoint:** `POST /api/v1/auth/forgot-password`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "auth.forgotPassword.success",
  "data": {
    "sent": true,
    "message": "OTP sent to email"
  }
}
```

**Security Features:**

1. **Email Enumeration Protection:**
   - Luôn trả về success dù email có tồn tại hay không
   - Không tiết lộ email nào đã đăng ký

2. **Rate Limiting:**
   - Tối đa 3 requests/giờ/email
   - Trả về 429 nếu vượt quá

3. **OTP Generation:**
   - 6 chữ số ngẫu nhiên
   - Hết hạn sau 10 phút

**Database Storage:**
```sql
INSERT INTO app.password_resets 
  (user_id, email, otp_code, expires_at, ip_address, user_agent)
VALUES ($1, $2, $3, $4, $5, $6)
```

**Email Template:**
```html
<div style="font-family: Arial, sans-serif; max-width: 600px;">
  <h2 style="color: #4A90A4;">Đặt lại mật khẩu</h2>
  <p>Mã OTP của bạn là:</p>
  <div style="background: #f5f5f5; padding: 20px; text-align: center;">
    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px;">
      123456
    </span>
  </div>
  <p><strong>Mã có hiệu lực trong 10 phút.</strong></p>
</div>
```

**Error Cases:**
| Status | Message | Nguyên nhân |
|--------|---------|-------------|
| 400 | "Email is required" | Không có email |
| 400 | "Invalid email format" | Email sai định dạng |
| 403 | "Account suspended" | Tài khoản bị khóa |
| 429 | "Too many requests..." | Vượt quá rate limit |

---

### 5. ✅ XÁC THỰC OTP (Verify Reset OTP)

**Endpoint:** `POST /api/v1/auth/verify-reset-otp`

**Request Body:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "auth.verifyOtp.success",
  "data": {
    "valid": true,
    "reset_token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Reset Token:**
- JWT với `purpose: "password_reset"`
- Hết hạn sau 5 phút
- Dùng để reset password ở bước tiếp theo

**Validation:**
```
1. Tìm OTP mới nhất chưa sử dụng cho email
2. Check OTP chưa hết hạn
3. So sánh OTP code
4. Generate reset_token (5 phút)
```

**Error Cases:**
| Status | Message | Nguyên nhân |
|--------|---------|-------------|
| 400 | "Email and OTP are required" | Thiếu thông tin |
| 400 | "OTP not found or expired" | Không tìm thấy OTP |
| 400 | "OTP expired" | OTP đã hết hạn |
| 400 | "Invalid OTP" | OTP sai |

---

### 6. 🔒 ĐẶT LẠI MẬT KHẨU (Reset Password)

**Endpoint:** `POST /api/v1/auth/reset-password`

**Method 1 - Dùng Reset Token:**
```json
{
  "reset_token": "eyJhbGciOiJIUzI1NiIs...",
  "new_password": "newpassword123"
}
```

**Method 2 - Dùng Email + OTP:**
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "new_password": "newpassword123"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "auth.resetPassword.success",
  "data": {
    "success": true,
    "message": "Password reset successfully"
  }
}
```

**Validation:**
| Field | Rule |
|-------|------|
| new_password | Bắt buộc, tối thiểu 6 ký tự |
| reset_token | Hoặc email + otp |

**Post-Reset Actions:**
```sql
-- 1. Update password
UPDATE app.users SET password_hash = $1 WHERE id = $2

-- 2. Invalidate all OTPs
UPDATE app.password_resets SET used = TRUE WHERE user_id = $1

-- 3. Revoke all sessions (force re-login)
UPDATE app.user_sessions SET revoked = TRUE WHERE user_id = $1
```

**Error Cases:**
| Status | Message | Nguyên nhân |
|--------|---------|-------------|
| 400 | "New password is required" | Thiếu password mới |
| 400 | "Password must be at least 6 characters" | Password quá ngắn |
| 400 | "Invalid or expired reset token" | Token không hợp lệ |
| 400 | "OTP not found or expired" | OTP không hợp lệ |

---

### 7. 🌐 GOOGLE OAUTH

#### 7.1 Redirect to Google

**Endpoint:** `GET /api/v1/auth/google`

**Flow:**
```
1. User click "Login with Google"
2. Redirect đến Google OAuth consent screen
3. User đồng ý cấp quyền
4. Google redirect về callback URL
```

**Scopes requested:**
- `profile` - Thông tin cơ bản
- `email` - Địa chỉ email

#### 7.2 Google Callback

**Endpoint:** `GET /api/v1/auth/google/callback`

**Response Success (200):**
```json
{
  "success": true,
  "message": "auth.login.success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "handle": "google_abc123",
      "email": "user@gmail.com",
      "role_primary": "SEEKER"
    }
  }
}
```

**OAuth Flow Logic:**
```
1. Nhận profile từ Google (id, email, name, avatar)
2. Check oauth_users table có google_id chưa?
   ├── CÓ → Lấy app_user_id, return user
   └── CHƯA:
       3. Check app.users có email này chưa?
          ├── CÓ → Link với existing user
          └── CHƯA → Tạo user mới
       4. Tạo record trong oauth_users
       5. Return user + tokens
```

**Database Tables:**

```sql
-- app.oauth_users
CREATE TABLE app.oauth_users (
  id SERIAL PRIMARY KEY,
  app_user_id INTEGER REFERENCES app.users(id),
  google_id VARCHAR(255) UNIQUE,
  email VARCHAR(255),
  name VARCHAR(255),
  avatar TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🔐 JWT TOKEN STRUCTURE

### Access Token

```javascript
{
  "sub": 1,                    // User ID
  "role": "SEEKER",            // User role
  "typ": "access",             // Token type
  "iat": 1703505600,           // Issued at
  "exp": 1703509200,           // Expires (1h)
  "iss": "healing.api",        // Issuer
  "aud": "healing.webapp"      // Audience
}
```

### Refresh Token

```javascript
{
  "sub": 1,                    // User ID
  "typ": "refresh",            // Token type
  "iat": 1703505600,           // Issued at
  "exp": 1706097600,           // Expires (30d)
  "iss": "healing.api",
  "aud": "healing.webapp"
}
```

### Reset Token

```javascript
{
  "sub": 1,                    // User ID
  "email": "user@example.com",
  "purpose": "password_reset", // Purpose
  "iat": 1703505600,
  "exp": 1703505900            // Expires (5m)
}
```

---

## 🛡️ MIDDLEWARE AUTHENTICATION

**File:** `src/middlewares/auth.js`

### auth() Middleware

```javascript
// Sử dụng
router.get("/protected", auth, controller);

// Logic
1. Lấy token từ header "Authorization: Bearer <token>"
2. Verify JWT với secret, issuer, audience
3. Attach user info vào req.user
4. Call next()
```

**Request sau khi qua middleware:**
```javascript
req.user = {
  id: 1,           // User ID từ token.sub
  role: "SEEKER"   // Role từ token.role
}
```

### requireRole() Middleware

```javascript
// Sử dụng
router.get("/admin-only", auth, requireRole("ADMIN"), controller);

// Logic
1. Check req.user tồn tại
2. Check req.user.role === requiredRole
3. Return 403 nếu không đủ quyền
```

---

## ⚙️ CONFIGURATION

### Environment Variables

```env
# JWT Configuration
JWT_SECRET=your-super-secret-key-at-least-32-characters
JWT_ISS=healing.api
JWT_AUD=healing.webapp
TOKEN_TTL=1h
REFRESH_TTL=30d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:4000/api/v1/auth/google/callback

# SMTP (Email)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM="Healing <noreply@healing.com>"
```

### JWT Secret Validation

```javascript
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET || JWT_SECRET.length < 32) {
  throw new Error("JWT_SECRET must be set to a strong random value (>=32 chars)");
}
```

---

## 🗄️ DATABASE SCHEMA

### app.users

```sql
CREATE TABLE app.users (
  id SERIAL PRIMARY KEY,
  handle VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255),
  role_primary VARCHAR(20) DEFAULT 'SEEKER',
  status VARCHAR(20) DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### app.user_sessions

```sql
CREATE TABLE app.user_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES app.users(id),
  token TEXT NOT NULL,
  device_info TEXT,
  ip_address VARCHAR(45),
  expires_at TIMESTAMP,
  revoked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### app.password_resets

```sql
CREATE TABLE app.password_resets (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES app.users(id),
  email VARCHAR(255) NOT NULL,
  otp_code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  used_at TIMESTAMP,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### app.oauth_users

```sql
CREATE TABLE app.oauth_users (
  id SERIAL PRIMARY KEY,
  app_user_id INTEGER REFERENCES app.users(id),
  google_id VARCHAR(255) UNIQUE,
  email VARCHAR(255),
  name VARCHAR(255),
  avatar TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🔒 SECURITY FEATURES

### 1. Password Security
- **Hashing:** bcrypt với salt rounds = 10
- **Min Length:** 6 ký tự (có thể tăng)

### 2. Token Security
- **JWT Secret:** Tối thiểu 32 ký tự
- **Short-lived Access:** 1 giờ
- **Long-lived Refresh:** 30 ngày
- **Issuer/Audience:** Validation

### 3. Rate Limiting
- **Password Reset:** 3 requests/giờ/email

### 4. Session Management
- **Session Storage:** Lưu vào DB
- **Device Tracking:** IP, User-Agent
- **Revocation:** Có thể revoke sessions

### 5. Email Enumeration Protection
- Không tiết lộ email có tồn tại hay không

### 6. Account Status Check
- Block login cho SUSPENDED accounts
- Hide DELETED accounts

---

## 📊 FLOW DIAGRAMS

### Registration Flow
```
┌─────────┐     ┌──────────┐     ┌─────────┐     ┌──────────┐
│ Client  │────▶│ Validate │────▶│ Hash PW │────▶│ Create   │
│         │     │ Input    │     │ bcrypt  │     │ User     │
└─────────┘     └──────────┘     └─────────┘     └──────────┘
                                                       │
┌─────────┐     ┌──────────┐                          │
│ Return  │◀────│ Generate │◀─────────────────────────┘
│ Token   │     │ JWT      │
└─────────┘     └──────────┘
```

### Login Flow
```
┌─────────┐     ┌──────────┐     ┌─────────┐     ┌──────────┐
│ Client  │────▶│ Find     │────▶│ Check   │────▶│ Compare  │
│         │     │ User     │     │ Status  │     │ Password │
└─────────┘     └──────────┘     └─────────┘     └──────────┘
                                                       │
┌─────────┐     ┌──────────┐     ┌─────────┐          │
│ Return  │◀────│ Generate │◀────│ Save    │◀─────────┘
│ Tokens  │     │ Tokens   │     │ Session │
└─────────┘     └──────────┘     └─────────┘
```

### Password Reset Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Forgot PW   │────▶│ Generate    │────▶│ Send Email  │
│ Request     │     │ OTP         │     │ with OTP    │
└─────────────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Verify OTP  │────▶│ Generate    │────▶│ Reset PW    │
│             │     │ Reset Token │     │ Request     │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │ Update PW   │
                                        │ Revoke All  │
                                        └─────────────┘
```

---

## 🧪 TESTING EXAMPLES

### Register
```bash
curl -X POST http://localhost:4000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "handle": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Login
```bash
curl -X POST http://localhost:4000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "test@example.com",
    "password": "password123"
  }'
```

### Refresh Token
```bash
curl -X POST http://localhost:4000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }'
```

### Forgot Password
```bash
curl -X POST http://localhost:4000/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

### Verify OTP
```bash
curl -X POST http://localhost:4000/api/v1/auth/verify-reset-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "otp": "123456"
  }'
```

### Reset Password
```bash
curl -X POST http://localhost:4000/api/v1/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "reset_token": "eyJhbGciOiJIUzI1NiIs...",
    "new_password": "newpassword123"
  }'
```

---

## 📝 SUMMARY

Module Authentication cung cấp:

| Feature | Status |
|---------|--------|
| Email/Handle Registration | ✅ |
| Email/Handle Login | ✅ |
| JWT Access + Refresh Tokens | ✅ |
| Google OAuth | ✅ |
| Password Reset via OTP | ✅ |
| Session Management | ✅ |
| Rate Limiting | ✅ |
| Account Status Check | ✅ |
| Email Enumeration Protection | ✅ |
| Role-based Access Control | ✅ |

**Điểm mạnh:**
- Hỗ trợ nhiều phương thức đăng nhập
- Bảo mật tốt với JWT + bcrypt
- Password reset flow hoàn chỉnh
- Session tracking với device info

**Có thể cải thiện:**
- Thêm 2FA (Two-Factor Authentication)
- Thêm login với Facebook/Apple
- Thêm password strength validation
- Thêm brute-force protection cho login
- Thêm email verification khi đăng ký

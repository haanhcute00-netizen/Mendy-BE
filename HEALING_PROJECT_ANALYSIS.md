# 📊 PHÂN TÍCH TOÀN DIỆN DỰ ÁN HEALING BACKEND

> **Ngày phân tích:** 09/12/2025  
> **Phiên bản:** 1.0  
> **Tác giả:** Kiro AI Assistant

---

## 📑 MỤC LỤC

1. [Tổng Quan Hệ Thống](#1-tổng-quan-hệ-thống)
2. [Các Lỗi Cần Sửa Ngay](#2-các-lỗi-cần-sửa-ngay)
3. [Cải Thiện Hiệu Năng](#3-cải-thiện-hiệu-năng)
4. [Chức Năng Cần Thêm](#4-chức-năng-cần-thêm)
5. [Bước Đột Phá Trong Lĩnh Vực Chữa Lành](#5-bước-đột-phá-trong-lĩnh-vực-chữa-lành)
6. [Roadmap Chi Tiết](#6-roadmap-chi-tiết)
7. [Database Migrations Cần Thiết](#7-database-migrations-cần-thiết)
8. [Kết Luận](#8-kết-luận)

---

## 1. TỔNG QUAN HỆ THỐNG

### 1.1 Kiến Trúc Hiện Tại

```
┌─────────────────────────────────────────────────────────────┐
│                      CLIENT APPS                             │
│              (Web, Mobile, Test Clients)                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    EXPRESS SERVER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Routes    │  │ Middlewares │  │   Socket.io │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    18 MODULES                                │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │
│  │  Auth  │ │ Users  │ │Experts │ │Bookings│ │Payments│   │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘   │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │
│  │  Chat  │ │Reviews │ │ Posts  │ │Comments│ │Disputes│   │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘   │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │
│  │Refunds │ │Payouts │ │Wallets │ │Recurring│ │ Admin │   │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘   │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                 AI COMPANION MODULE                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Emotion  │ │ Persona  │ │Notifications│ │Schedule │       │
│  │ Service  │ │ Service  │ │  Service  │ │ Service │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                      │                                       │
│                      ▼                                       │
│              ┌──────────────┐                                │
│              │  Gemini AI   │                                │
│              │   (2.5-flash)│                                │
│              └──────────────┘                                │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   POSTGRESQL                                 │
│                   (~70+ tables)                              │
│                   Schema: app                                │
└─────────────────────────────────────────────────────────────┘
```


### 1.2 Tech Stack

| Layer | Technology |
|-------|------------|
| Runtime | Node.js (ES Modules) |
| Framework | Express 5.x |
| Database | PostgreSQL 17 |
| Realtime | Socket.io 4.x |
| AI | Google Gemini 2.5-flash |
| Auth | JWT + Passport.js |
| Payment | MoMo |
| File Storage | Cloudinary |
| Email | Nodemailer (SMTP) |
| Validation | Zod |
| Logging | Winston |

### 1.3 Database Statistics

- **Tổng số bảng:** ~70+
- **Schema chính:** `app`
- **Extensions:** `citext`, `btree_gist`
- **Custom Types:** 15+ ENUM types

### 1.4 Các Module Chính

| Module | Chức năng | Files |
|--------|-----------|-------|
| `auth` | Đăng ký, đăng nhập, OAuth Google | 5 |
| `users` | Profile, follows, blocks | 9 |
| `experts` | Expert profiles, skills, certifications | 4 |
| `bookings` | Đặt lịch, quản lý session | 5 |
| `payments` | MoMo integration, payment intents | 6 |
| `chat` | DM, booking chat, attachments | 5 |
| `AI` | Companion, emotion, persona, schedule | 15+ |
| `disputes` | Tranh chấp, giải quyết | 4 |
| `reviews` | Đánh giá expert | 4 |
| `posts` | Bài viết cộng đồng | 4 |
| `comments` | Bình luận, reactions | 4 |

---

## 2. CÁC LỖI CẦN SỬA NGAY

### 2.1 🔴 LỖI NGHIÊM TRỌNG (Critical)

#### 2.1.1 Auto-Complete Booking trong Reviews

**File:** `src/modules/reviews/reviews.service.js` (Line 25-35)

**Vấn đề:**
```javascript
// ❌ LỖI BẢO MẬT NGHIÊM TRỌNG
if (canReviewResult.reason === "Booking must be completed to review" && canReviewResult.booking) {
  console.log(`[DEBUG] Review service - Auto-updating booking ${bookingId} to COMPLETED for testing`);
  await BookingsRepo.updateStatus({ id: bookingId, status: 'COMPLETED' });
  // ...
}
```

**Hậu quả:**
- User có thể review mà không cần hoàn thành session thực sự
- Expert có thể bị đánh giá không công bằng
- Dữ liệu booking bị sai lệch
- Có thể bị lợi dụng để gian lận thanh toán

**Cách sửa:**
```javascript
// ✅ ĐÚNG: Chỉ cho phép review booking đã COMPLETED
export async function createReview({ userId, bookingId, rating, comment }) {
  if (rating < 1 || rating > 5) {
    throw Object.assign(new Error("Rating must be between 1 and 5"), { status: 400 });
  }

  const canReviewResult = await ReviewsRepo.canReviewBooking(userId, bookingId);
  if (!canReviewResult.canReview) {
    throw Object.assign(new Error(canReviewResult.reason), { status: 400 });
  }

  // Tiếp tục logic tạo review...
}
```

#### 2.1.2 Undefined Property trong Disputes

**File:** `src/modules/disputes/disputes.service.js` (Line 95)

**Vấn đề:**
```javascript
// ❌ dispute.booking_user_id không tồn tại trong query result
const seekerId = dispute.raised_by === dispute.booking_user_id 
  ? dispute.raised_by 
  : dispute.against_user;
```

**Cách sửa:**
```javascript
// ✅ Cần join với bookings table hoặc fetch riêng
const booking = await BookingsRepo.getBookingById(dispute.booking_id);
const seekerId = booking.user_id;
```

### 2.2 🟡 LỖI TRUNG BÌNH (Medium)

#### 2.2.1 Memory Leak trong Rate Limiter

**File:** `src/sockets/chat.socket.js`

**Vấn đề:**
```javascript
// ❌ Map không bao giờ được cleanup
const buckets = new Map();
function allow(key, rate = 20, windowMs = 60_000) {
  // buckets chỉ thêm, không bao giờ xóa
}
```

**Cách sửa:**
```javascript
// ✅ Thêm cleanup mechanism
const buckets = new Map();
const CLEANUP_INTERVAL = 5 * 60 * 1000; // 5 phút

setInterval(() => {
  const now = Date.now();
  for (const [key, bucket] of buckets.entries()) {
    if (now - bucket.ts > 60_000 * 2) { // Xóa bucket cũ hơn 2 phút
      buckets.delete(key);
    }
  }
}, CLEANUP_INTERVAL);
```

#### 2.2.2 Thiếu Input Validation

**Files bị ảnh hưởng:**
- `src/AI/aiCore.js` - Không limit độ dài userMessage
- `src/AI/companion/persona/persona.service.js` - Không sanitize custom_nickname
- `src/modules/chat/chat.service.js` - Không validate threadId

**Cách sửa:**
```javascript
// ✅ Thêm validation
export const handleChat = async (userId, userMessage) => {
  // Validate input
  if (!userId || typeof userId !== 'number') {
    throw new Error('Invalid userId');
  }
  if (!userMessage || typeof userMessage !== 'string') {
    throw new Error('Invalid message');
  }
  if (userMessage.length > 5000) {
    throw new Error('Message too long (max 5000 characters)');
  }
  
  // Sanitize
  const sanitizedMessage = userMessage.trim().slice(0, 5000);
  // ...
};
```

### 2.3 🟢 LỖI NHẸ (Low)

| File | Vấn đề | Cách sửa |
|------|--------|----------|
| `emotion.service.js` | Console.warn trong production | Dùng logger thay vì console |
| `aiCore.js` | Hardcoded model name | Đưa vào env variable |
| `prompt.js` | Crisis keywords hardcoded | Đưa vào config file |

---

## 3. CẢI THIỆN HIỆU NĂNG

### 3.1 Database Indexes Cần Thêm

```sql
-- 1. Emotion logs - Query theo user và thời gian
CREATE INDEX idx_emotion_logs_user_time 
ON app.emotion_logs(user_id, detected_at DESC);

-- 2. AI Chat history - Query lịch sử chat
CREATE INDEX idx_ai_chat_user_time 
ON app.ai_chat_history(user_id, created_at DESC);

-- 3. Mental state - Query users cần attention
CREATE INDEX idx_mental_state_stress 
ON app.user_mental_state(stress_level) 
WHERE stress_level >= 7;

CREATE INDEX idx_mental_state_vulnerability 
ON app.user_mental_state(vulnerability_score) 
WHERE vulnerability_score >= 0.7;

-- 4. Bookings - Query theo expert và thời gian
CREATE INDEX idx_bookings_expert_time 
ON app.bookings(expert_id, start_at DESC) 
WHERE status IN ('PENDING', 'CONFIRMED');

-- 5. Expert search - Full text search
CREATE INDEX idx_expert_profiles_specialties 
ON app.expert_profiles USING GIN(specialties);

-- 6. Posts - Query theo author và thời gian
CREATE INDEX idx_posts_author_time 
ON app.posts(author_id, created_at DESC);

-- 7. Daily checkins - Query theo user và ngày
CREATE INDEX idx_checkins_user_date 
ON app.daily_mood_checkins(user_id, checkin_date DESC);
```

### 3.2 Query Optimization

#### 3.2.1 Expert Search Query

**Hiện tại:** 5+ JOINs, nhiều subqueries
**Cải thiện:** Sử dụng Materialized View

```sql
-- Tạo materialized view cho expert search
CREATE MATERIALIZED VIEW app.mv_expert_search AS
SELECT 
  ep.id AS expert_id,
  ep.user_id,
  ep.specialties,
  ep.price_per_session,
  ep.rating_avg,
  ep.intro,
  ep.kyc_status,
  u.handle,
  up.display_name,
  up.avatar_url,
  es.is_online,
  es.last_active_at,
  eperf.total_sessions,
  eperf.total_reviews,
  eperf.response_time_avg
FROM app.expert_profiles ep
JOIN app.users u ON ep.user_id = u.id
LEFT JOIN app.user_profiles up ON u.id = up.user_id
LEFT JOIN app.expert_status es ON ep.id = es.expert_id
LEFT JOIN app.expert_performance eperf ON ep.id = eperf.expert_id;

-- Refresh mỗi 5 phút
CREATE INDEX idx_mv_expert_search_rating ON app.mv_expert_search(rating_avg DESC);
CREATE INDEX idx_mv_expert_search_price ON app.mv_expert_search(price_per_session);
```

### 3.3 Caching Strategy

```javascript
// src/utils/cache.js - Cải thiện

// 1. Cache expert search results
const CACHE_KEYS = {
  EXPERT_SEARCH: 'expert:search:',
  EXPERT_DETAIL: 'expert:detail:',
  USER_MENTAL_STATE: 'user:mental:',
  SEARCH_FACETS: 'search:facets'
};

// 2. Cache với TTL phù hợp
const CACHE_TTL = {
  EXPERT_SEARCH: 60 * 1000,      // 1 phút
  EXPERT_DETAIL: 5 * 60 * 1000,  // 5 phút
  USER_MENTAL_STATE: 30 * 1000,  // 30 giây
  SEARCH_FACETS: 10 * 60 * 1000  // 10 phút
};

// 3. Cache invalidation khi data thay đổi
export const invalidateExpertCache = (expertId) => {
  cache.delete(`${CACHE_KEYS.EXPERT_DETAIL}${expertId}`);
  // Invalidate search cache có chứa expert này
  cache.keys()
    .filter(k => k.startsWith(CACHE_KEYS.EXPERT_SEARCH))
    .forEach(k => cache.delete(k));
};
```

### 3.4 Connection Pool Optimization

```javascript
// src/config/db.js - Cải thiện

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: parseInt(process.env.DB_POOL_MAX) || 50,        // Tăng từ 20 lên 50
  min: parseInt(process.env.DB_POOL_MIN) || 5,         // Tăng min connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,                        // Tăng timeout
  maxUses: 7500,                                        // Recycle connections
  allowExitOnIdle: false
});

// Health check
pool.on('error', (err) => {
  logger.error('Unexpected pool error', { error: err.message });
});

// Monitor pool stats
setInterval(() => {
  const { totalCount, idleCount, waitingCount } = pool;
  logger.info('Pool stats', { totalCount, idleCount, waitingCount });
}, 60000);
```


---

## 4. CHỨC NĂNG CẦN THÊM

### 4.1 Tính Năng Chữa Lành Cốt Lõi

#### 4.1.1 Crisis Intervention System (Ưu tiên: 🔴 CAO)

**Mô tả:** Hệ thống tự động phát hiện và can thiệp khi user có dấu hiệu nguy hiểm

**Components:**
```
┌─────────────────────────────────────────────────────────────┐
│                 CRISIS INTERVENTION SYSTEM                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Detection  │───▶│  Assessment  │───▶│   Response   │  │
│  │    Layer     │    │    Layer     │    │    Layer     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                   │                   │           │
│         ▼                   ▼                   ▼           │
│  • Keyword matching   • Risk scoring     • Auto-escalate   │
│  • Pattern detection  • Context analysis • Notify admin    │
│  • Behavior anomaly   • History check    • Emergency info  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Database Schema:**
```sql
CREATE TABLE app.crisis_alerts (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  trigger_type TEXT NOT NULL, -- 'keyword', 'pattern', 'behavior'
  trigger_content TEXT,
  risk_level TEXT NOT NULL, -- 'low', 'medium', 'high', 'critical'
  status TEXT DEFAULT 'OPEN', -- 'OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'FALSE_POSITIVE'
  assigned_to BIGINT REFERENCES app.users(id),
  response_action TEXT,
  response_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'
);

CREATE TABLE app.crisis_responses (
  id BIGSERIAL PRIMARY KEY,
  alert_id BIGINT NOT NULL REFERENCES app.crisis_alerts(id),
  responder_id BIGINT NOT NULL REFERENCES app.users(id),
  action_type TEXT NOT NULL, -- 'message', 'call', 'escalate', 'close'
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Service Implementation:**
```javascript
// src/modules/crisis/crisis.service.js

const CRISIS_KEYWORDS = {
  critical: ['tự tử', 'suicide', 'kết thúc cuộc đời', 'không muốn sống'],
  high: ['tự làm hại', 'cắt tay', 'self-harm', 'muốn chết'],
  medium: ['tuyệt vọng', 'không còn hy vọng', 'hopeless']
};

export const detectCrisis = async (userId, text, source) => {
  let riskLevel = 'low';
  let triggers = [];

  // 1. Keyword detection
  for (const [level, keywords] of Object.entries(CRISIS_KEYWORDS)) {
    for (const keyword of keywords) {
      if (text.toLowerCase().includes(keyword)) {
        riskLevel = level;
        triggers.push({ type: 'keyword', value: keyword });
      }
    }
  }

  // 2. Pattern detection (consecutive negative emotions)
  const recentEmotions = await getRecentEmotions(userId, 24); // 24 hours
  const negativeCount = recentEmotions.filter(e => 
    ['sad', 'anxious', 'stressed', 'angry'].includes(e.emotion)
  ).length;
  
  if (negativeCount >= 5 && riskLevel === 'low') {
    riskLevel = 'medium';
    triggers.push({ type: 'pattern', value: 'consecutive_negative' });
  }

  // 3. Create alert if needed
  if (riskLevel !== 'low') {
    const alert = await createCrisisAlert({
      userId,
      triggerType: triggers[0].type,
      triggerContent: text.substring(0, 500),
      riskLevel,
      metadata: { triggers, source }
    });

    // 4. Auto-response based on risk level
    if (riskLevel === 'critical') {
      await notifyAdminsImmediately(alert);
      await sendCrisisResources(userId);
    } else if (riskLevel === 'high') {
      await notifyOnCallAdmin(alert);
    }

    return { detected: true, alert, riskLevel };
  }

  return { detected: false };
};
```

#### 4.1.2 Mood Journal với AI Analysis (Ưu tiên: 🟡 TRUNG BÌNH)

**Mô tả:** Nhật ký cảm xúc hàng ngày với AI phân tích xu hướng

**Features:**
- Ghi chép cảm xúc tự do hoặc guided prompts
- AI phân tích và tóm tắt xu hướng hàng tuần
- Phát hiện triggers và patterns
- Đề xuất coping strategies cá nhân hóa

**Database Schema:**
```sql
CREATE TABLE app.mood_journal_entries (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  entry_type TEXT DEFAULT 'free', -- 'free', 'guided', 'quick'
  content TEXT NOT NULL,
  mood_before TEXT,
  mood_after TEXT,
  tags TEXT[],
  ai_analysis JSONB, -- AI-generated insights
  is_private BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, entry_date, entry_type)
);

CREATE TABLE app.mood_journal_prompts (
  id BIGSERIAL PRIMARY KEY,
  prompt_text TEXT NOT NULL,
  category TEXT, -- 'gratitude', 'reflection', 'goals', 'emotions'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4.1.3 Guided Wellness Activities (Ưu tiên: 🟡 TRUNG BÌNH)

**Mô tả:** Bài tập thở, thiền, grounding có hướng dẫn

**Features:**
- Breathing exercises (4-7-8, box breathing)
- Guided meditation (5-10-15 phút)
- Grounding techniques (5-4-3-2-1)
- Progressive muscle relaxation
- Audio/video hướng dẫn

**Database Schema:**
```sql
CREATE TABLE app.wellness_exercises (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL, -- 'breathing', 'meditation', 'grounding', 'relaxation'
  duration_minutes INTEGER NOT NULL,
  difficulty TEXT DEFAULT 'beginner', -- 'beginner', 'intermediate', 'advanced'
  description TEXT,
  instructions JSONB NOT NULL, -- Step-by-step instructions
  audio_url TEXT,
  video_url TEXT,
  thumbnail_url TEXT,
  benefits TEXT[],
  suitable_for TEXT[], -- ['anxiety', 'stress', 'sleep', 'panic']
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE app.user_exercise_history (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  exercise_id BIGINT NOT NULL REFERENCES app.wellness_exercises(id),
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  duration_actual INTEGER, -- Actual time spent
  mood_before TEXT,
  mood_after TEXT,
  effectiveness_rating INTEGER CHECK (effectiveness_rating BETWEEN 1 AND 5),
  notes TEXT
);
```

#### 4.1.4 Progress Tracking Dashboard (Ưu tiên: 🟡 TRUNG BÌNH)

**Mô tả:** Dashboard hiển thị tiến trình chữa lành theo thời gian

**Metrics to track:**
- Mood trend (daily/weekly/monthly)
- Session completion rate
- Wellness activity streak
- Emotion distribution
- Sleep quality trend
- Stress level trend

**API Endpoints:**
```javascript
// GET /api/v1/progress/overview
{
  "period": "30d",
  "mood_trend": {
    "current_avg": 3.5,
    "previous_avg": 3.2,
    "change_percent": 9.4,
    "trend": "improving"
  },
  "sessions_completed": 8,
  "wellness_streak": 12,
  "top_emotions": ["calm", "hopeful", "anxious"],
  "recommendations": [...]
}

// GET /api/v1/progress/charts
{
  "mood_chart": [...],
  "emotion_distribution": {...},
  "activity_heatmap": [...],
  "sleep_chart": [...]
}
```

### 4.2 Tính Năng AI Nâng Cao

#### 4.2.1 Smart Expert Matching (Ưu tiên: 🔴 CAO)

**Mô tả:** AI matching expert dựa trên nhiều yếu tố

**Matching Factors:**
```javascript
const matchingFactors = {
  // Issue-based matching (40%)
  issueMatch: {
    weight: 0.4,
    factors: ['specialties', 'experience', 'certifications']
  },
  
  // Personality compatibility (25%)
  personalityMatch: {
    weight: 0.25,
    factors: ['communication_style', 'approach', 'gender_preference']
  },
  
  // Practical factors (20%)
  practicalMatch: {
    weight: 0.2,
    factors: ['price_range', 'availability', 'language']
  },
  
  // Performance (15%)
  performanceMatch: {
    weight: 0.15,
    factors: ['rating', 'completion_rate', 'response_time']
  }
};
```

#### 4.2.2 Session Summary AI (Ưu tiên: 🟢 THẤP)

**Mô tả:** AI tự động tóm tắt nội dung sau mỗi session

**Features:**
- Tóm tắt key points discussed
- Identify action items
- Track progress từ session trước
- Suggest follow-up topics

### 4.3 Tính Năng Engagement

#### 4.3.1 Gamification System (Ưu tiên: 🟢 THẤP)

**Database Schema:**
```sql
CREATE TABLE app.achievements (
  id BIGSERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  category TEXT, -- 'streak', 'milestone', 'activity', 'social'
  points INTEGER DEFAULT 0,
  requirements JSONB NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE app.user_achievements (
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  achievement_id BIGINT NOT NULL REFERENCES app.achievements(id),
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE app.user_points (
  user_id BIGINT PRIMARY KEY REFERENCES app.users(id),
  total_points INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_activity_date DATE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Achievement Examples:**
```javascript
const achievements = [
  { code: 'FIRST_CHECKIN', name: 'Bước đầu tiên', points: 10 },
  { code: 'STREAK_7', name: '7 ngày liên tiếp', points: 50 },
  { code: 'STREAK_30', name: '30 ngày liên tiếp', points: 200 },
  { code: 'FIRST_SESSION', name: 'Session đầu tiên', points: 100 },
  { code: 'JOURNAL_MASTER', name: '30 bài journal', points: 150 },
  { code: 'BREATHING_PRO', name: '50 bài tập thở', points: 100 }
];
```

#### 4.3.2 Peer Support Groups (Ưu tiên: 🟡 TRUNG BÌNH)

**Mô tả:** Nhóm hỗ trợ đồng đẳng với moderation

**Database Schema:**
```sql
CREATE TABLE app.support_groups (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL, -- 'anxiety', 'depression', 'grief', 'general'
  is_anonymous BOOLEAN DEFAULT TRUE,
  max_members INTEGER DEFAULT 50,
  rules TEXT[],
  moderator_ids BIGINT[],
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE app.support_group_members (
  group_id BIGINT NOT NULL REFERENCES app.support_groups(id),
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  role TEXT DEFAULT 'member', -- 'member', 'moderator', 'admin'
  anonymous_name TEXT, -- Generated anonymous name
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (group_id, user_id)
);

CREATE TABLE app.support_group_messages (
  id BIGSERIAL PRIMARY KEY,
  group_id BIGINT NOT NULL REFERENCES app.support_groups(id),
  sender_id BIGINT NOT NULL REFERENCES app.users(id),
  content TEXT NOT NULL,
  is_anonymous BOOLEAN DEFAULT TRUE,
  is_moderated BOOLEAN DEFAULT FALSE,
  moderation_status TEXT DEFAULT 'approved',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```


---

## 5. BƯỚC ĐỘT PHÁ TRONG LĨNH VỰC CHỮA LÀNH

### 5.1 🚀 Đột Phá #1: Proactive AI Care System

**Vấn đề hiện tại:**
- AI chỉ phản hồi khi user chủ động nhắn tin
- Không có cơ chế chủ động reach out
- User có thể "biến mất" mà không ai biết

**Giải pháp đột phá:**

```
┌─────────────────────────────────────────────────────────────┐
│              PROACTIVE AI CARE SYSTEM                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                 TRIGGER DETECTION                     │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │ • Negative emotion pattern (3+ days)                 │   │
│  │ • Unusual inactivity (normally active user)          │   │
│  │ • Special dates (trauma anniversary, holidays)       │   │
│  │ • Weather/seasonal triggers (SAD)                    │   │
│  │ • Time-based (late night activity)                   │   │
│  │ • Incomplete wellness activities                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              PERSONALIZED OUTREACH                    │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │ • Context-aware message generation                   │   │
│  │ • Persona-consistent tone                            │   │
│  │ • Non-intrusive timing (respect quiet hours)         │   │
│  │ • Escalation if no response                          │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:**

```javascript
// src/AI/proactive/proactive.service.js

import cron from 'node-cron';

// Chạy mỗi giờ
cron.schedule('0 * * * *', async () => {
  await checkAndSendProactiveMessages();
});

export const checkAndSendProactiveMessages = async () => {
  // 1. Users với pattern tiêu cực
  const negativePatternUsers = await getUsersWithNegativePattern(3);
  
  // 2. Users không hoạt động bất thường
  const inactiveUsers = await getUnusuallyInactiveUsers();
  
  // 3. Users có ngày đặc biệt
  const specialDateUsers = await getUsersWithSpecialDates();
  
  // 4. Gộp và loại trùng
  const usersToContact = deduplicateUsers([
    ...negativePatternUsers,
    ...inactiveUsers,
    ...specialDateUsers
  ]);
  
  for (const user of usersToContact) {
    // Check quiet hours
    if (isInQuietHours(user)) continue;
    
    // Check if already contacted recently
    if (await wasContactedRecently(user.id, 24)) continue;
    
    // Generate personalized message
    const message = await generateProactiveMessage(user);
    
    // Send via preferred channel
    await sendProactiveMessage(user.id, message);
    
    // Log for analytics
    await logProactiveOutreach(user.id, message.trigger);
  }
};

const generateProactiveMessage = async (user) => {
  const settings = await getUserAISettings(user.id);
  const persona = await getPersona(settings.persona_id);
  const context = await getUserContext(user.id);
  
  const triggers = {
    negative_pattern: {
      template: "Mình thấy mấy ngày qua bạn có vẻ không vui lắm. Bạn có muốn tâm sự gì không?",
      priority: 'high'
    },
    inactivity: {
      template: "Lâu rồi không thấy bạn, mình hơi lo. Bạn có ổn không?",
      priority: 'medium'
    },
    special_date: {
      template: "Mình biết hôm nay có thể là ngày khó khăn với bạn. Mình ở đây nếu bạn cần.",
      priority: 'high'
    }
  };
  
  // Personalize based on persona and relationship level
  return personalizeMessage(triggers[user.trigger], persona, settings);
};
```

**Database Schema:**
```sql
CREATE TABLE app.proactive_outreach_log (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  trigger_type TEXT NOT NULL,
  message_content TEXT NOT NULL,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  user_responded BOOLEAN DEFAULT FALSE,
  response_at TIMESTAMPTZ,
  effectiveness_score INTEGER -- 1-5 based on user engagement after
);

CREATE TABLE app.user_special_dates (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  date_type TEXT NOT NULL, -- 'trauma_anniversary', 'loss_anniversary', 'birthday'
  month INTEGER NOT NULL,
  day INTEGER NOT NULL,
  description TEXT,
  sensitivity_level TEXT DEFAULT 'medium', -- 'low', 'medium', 'high'
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5.2 🚀 Đột Phá #2: Trauma-Informed AI Responses

**Vấn đề hiện tại:**
- AI dùng chung 1 prompt cho tất cả users
- Không biết triggers cụ thể của từng người
- Có thể vô tình trigger trauma

**Giải pháp đột phá:**

```javascript
// src/AI/trauma/trauma.service.js

export const buildTraumaInformedPrompt = async (userId, basePrompt) => {
  const traumaProfile = await getTraumaProfile(userId);
  
  if (!traumaProfile) return basePrompt;
  
  const traumaGuidelines = `
⚠️ THÔNG TIN QUAN TRỌNG VỀ NGƯỜI DÙNG NÀY:

🚫 TRÁNH ĐỀ CẬP:
${traumaProfile.avoid_topics.map(t => `- ${t}`).join('\n')}

⚡ TRIGGERS ĐÃ BIẾT:
${traumaProfile.known_triggers.map(t => `- ${t}`).join('\n')}

✅ COPING STRATEGIES HIỆU QUẢ:
${traumaProfile.effective_coping.map(c => `- ${c}`).join('\n')}

📝 GHI CHÚ:
- Loại trauma: ${traumaProfile.trauma_types.join(', ')}
- Tiếp cận nhẹ nhàng, không ép buộc chia sẻ
- Nếu user có dấu hiệu triggered, chuyển sang grounding techniques
`;

  return `${basePrompt}\n\n${traumaGuidelines}`;
};
```

**Database Schema:**
```sql
CREATE TABLE app.user_trauma_profiles (
  user_id BIGINT PRIMARY KEY REFERENCES app.users(id),
  trauma_types TEXT[], -- ['childhood', 'relationship', 'grief', 'accident']
  known_triggers TEXT[], -- ['loud_noises', 'certain_dates', 'specific_topics']
  avoid_topics TEXT[], -- Topics AI should not mention
  effective_coping TEXT[], -- ['breathing', 'grounding', 'journaling']
  safe_topics TEXT[], -- Topics that help calm user
  communication_preferences JSONB, -- {'pace': 'slow', 'directness': 'gentle'}
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_reviewed_by BIGINT REFERENCES app.users(id),
  last_reviewed_at TIMESTAMPTZ
);

-- Trigger learning from conversations
CREATE TABLE app.trauma_trigger_detections (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES app.users(id),
  detected_trigger TEXT NOT NULL,
  context TEXT,
  confidence NUMERIC(3,2) DEFAULT 0.5,
  confirmed_by_user BOOLEAN,
  detected_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5.3 🚀 Đột Phá #3: Multi-Signal Crisis Detection

**Vấn đề hiện tại:**
- Chỉ detect crisis qua keywords
- Bỏ sót nhiều trường hợp nguy hiểm
- False positives cao

**Giải pháp đột phá:**

```
┌─────────────────────────────────────────────────────────────┐
│           MULTI-SIGNAL CRISIS DETECTION                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Signal 1: TEXT ANALYSIS (Weight: 30%)                      │
│  ├── Keyword matching                                        │
│  ├── Sentiment analysis                                      │
│  └── Semantic similarity to crisis phrases                   │
│                                                              │
│  Signal 2: BEHAVIORAL PATTERNS (Weight: 25%)                │
│  ├── Message frequency changes                               │
│  ├── Time of activity (3AM messages)                        │
│  └── Session abandonment                                     │
│                                                              │
│  Signal 3: HISTORICAL CONTEXT (Weight: 25%)                 │
│  ├── Previous crisis history                                 │
│  ├── Emotion trend (declining)                               │
│  └── Deviation from baseline                                 │
│                                                              │
│  Signal 4: CONTEXTUAL FACTORS (Weight: 20%)                 │
│  ├── Recent life events (from journal)                       │
│  ├── Upcoming triggers (anniversaries)                       │
│  └── Social isolation indicators                             │
│                                                              │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              RISK SCORE CALCULATION                   │   │
│  │                                                        │   │
│  │   Score = Σ(signal_weight × signal_score)             │   │
│  │                                                        │   │
│  │   0.0 - 0.3: Low risk                                 │   │
│  │   0.3 - 0.5: Medium risk → Monitor                    │   │
│  │   0.5 - 0.7: High risk → Alert admin                  │   │
│  │   0.7 - 1.0: Critical → Immediate intervention        │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:**
```javascript
// src/AI/crisis/multiSignalDetector.js

export const calculateCrisisRisk = async (userId, currentMessage) => {
  const signals = await Promise.all([
    analyzeTextSignal(currentMessage),           // 30%
    analyzeBehavioralSignal(userId),             // 25%
    analyzeHistoricalSignal(userId),             // 25%
    analyzeContextualSignal(userId)              // 20%
  ]);
  
  const weights = [0.30, 0.25, 0.25, 0.20];
  const riskScore = signals.reduce((sum, signal, i) => 
    sum + (signal.score * weights[i]), 0
  );
  
  const riskLevel = getRiskLevel(riskScore);
  
  // Log for ML training
  await logRiskAssessment(userId, {
    signals,
    riskScore,
    riskLevel,
    message: currentMessage.substring(0, 200)
  });
  
  return {
    riskScore,
    riskLevel,
    signals,
    recommendedAction: getRecommendedAction(riskLevel)
  };
};

const analyzeBehavioralSignal = async (userId) => {
  const recentActivity = await getUserActivityLast24h(userId);
  const baseline = await getUserActivityBaseline(userId);
  
  let score = 0;
  
  // Late night activity (2AM - 5AM)
  const lateNightMessages = recentActivity.filter(a => {
    const hour = new Date(a.created_at).getHours();
    return hour >= 2 && hour <= 5;
  });
  if (lateNightMessages.length > 0) score += 0.3;
  
  // Message frequency spike
  if (recentActivity.length > baseline.avgDaily * 2) score += 0.2;
  
  // Sudden inactivity after high activity
  const hoursSinceLastActivity = getHoursSinceLastActivity(userId);
  if (baseline.avgGapHours < 12 && hoursSinceLastActivity > 48) score += 0.4;
  
  return { score: Math.min(score, 1), factors: [...] };
};
```

### 5.4 🚀 Đột Phá #4: Healing Journey Visualization

**Mô tả:** Tạo "bản đồ hành trình chữa lành" visual và interactive

```
┌─────────────────────────────────────────────────────────────┐
│              HEALING JOURNEY MAP                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📅 Timeline View                                            │
│  ─────────────────────────────────────────────────────────  │
│  Jan    Feb    Mar    Apr    May    Jun                     │
│   │      │      │      │      │      │                      │
│   🌱     📈     ⭐     📉     🔄     🌟                      │
│  Start  First  Major  Setback Recovery Milestone            │
│         Progress Win                                         │
│                                                              │
│  📊 Emotion Heatmap                                          │
│  ─────────────────────────────────────────────────────────  │
│  Mon ████████░░ (mostly positive)                           │
│  Tue ██████░░░░ (mixed)                                     │
│  Wed ████░░░░░░ (challenging)                               │
│  Thu ██████████ (great day!)                                │
│  Fri ████████░░ (good)                                      │
│                                                              │
│  🔗 Correlation Insights                                     │
│  ─────────────────────────────────────────────────────────  │
│  "Bạn thường cảm thấy tốt hơn sau khi:"                     │
│  • Tập thở buổi sáng (+23% mood)                            │
│  • Viết journal (+18% mood)                                 │
│  • Session với expert (+31% mood)                           │
│                                                              │
│  "Những ngày khó khăn thường liên quan đến:"                │
│  • Thiếu ngủ (-15% mood)                                    │
│  • Không tập thể dục (-12% mood)                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**API Response:**
```javascript
// GET /api/v1/journey/map
{
  "timeline": {
    "start_date": "2025-01-15",
    "milestones": [
      {
        "date": "2025-01-15",
        "type": "journey_start",
        "title": "Bắt đầu hành trình",
        "icon": "🌱"
      },
      {
        "date": "2025-02-20",
        "type": "streak_achievement",
        "title": "30 ngày check-in liên tiếp",
        "icon": "🔥"
      },
      {
        "date": "2025-03-10",
        "type": "breakthrough",
        "title": "Vượt qua nỗi sợ nói chuyện",
        "icon": "⭐",
        "notes": "First time sharing in group"
      }
    ]
  },
  "emotion_heatmap": {
    "period": "last_30_days",
    "data": [
      { "date": "2025-12-01", "score": 0.7, "dominant": "calm" },
      { "date": "2025-12-02", "score": 0.5, "dominant": "anxious" }
      // ...
    ]
  },
  "correlations": {
    "positive_factors": [
      { "factor": "morning_breathing", "impact": 0.23 },
      { "factor": "journaling", "impact": 0.18 },
      { "factor": "expert_session", "impact": 0.31 }
    ],
    "negative_factors": [
      { "factor": "poor_sleep", "impact": -0.15 },
      { "factor": "no_exercise", "impact": -0.12 }
    ]
  },
  "predictions": {
    "next_week_outlook": "positive",
    "confidence": 0.72,
    "suggestions": [
      "Tiếp tục duy trì thói quen tập thở buổi sáng",
      "Cân nhắc đặt thêm 1 session với expert"
    ]
  }
}
```

### 5.5 🚀 Đột Phá #5: Expert-AI Collaboration

**Mô tả:** AI hỗ trợ Expert trong và sau session

```
┌─────────────────────────────────────────────────────────────┐
│           EXPERT-AI COLLABORATION DASHBOARD                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📊 REAL-TIME CLIENT INSIGHTS (During Session)              │
│  ─────────────────────────────────────────────────────────  │
│  Current Emotion: 😟 Anxious (confidence: 85%)              │
│  Stress Level: ████████░░ 8/10                              │
│  Engagement: ██████░░░░ 6/10                                │
│                                                              │
│  ⚠️ ALERTS:                                                  │
│  • Client mentioned "không ngủ được" - possible sleep issue │
│  • Detected hesitation when discussing family               │
│                                                              │
│  💡 SUGGESTED TECHNIQUES:                                    │
│  • Grounding exercise (client responds well to this)        │
│  • Open-ended question about sleep patterns                 │
│                                                              │
│  📝 AUTO-GENERATED SESSION NOTES                            │
│  ─────────────────────────────────────────────────────────  │
│  Key Topics Discussed:                                       │
│  1. Work stress and deadline pressure                       │
│  2. Sleep difficulties (3rd session mentioning this)        │
│  3. Relationship with mother                                │
│                                                              │
│  Action Items:                                               │
│  • Practice 4-7-8 breathing before bed                      │
│  • Journal about work boundaries                            │
│                                                              │
│  Progress Since Last Session:                                │
│  • Mood improved from 3.2 to 3.8 average                    │
│  • Completed 5/7 suggested activities                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```


---

## 6. ROADMAP CHI TIẾT

### 6.1 Phase 1: Critical Fixes (Tuần 1-2)

#### Sprint 1.1 (
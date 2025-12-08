# 🚀 AI COMPANION SYSTEM - TASK LIST

## 📊 Tổng quan
- **Tính khả thi:** 65-70%
- **Thời gian ước tính:** 4-6 tuần (1 dev)
- **Độ phức tạp:** Trung bình - Cao

---

## 🗓️ PHASE 1: PERSONA ENGINE + NOTIFICATIONS (Tuần 1-2)

### 1.1 Database Schema
- [x] Tạo bảng `app.ai_personas` (id, name, tone, emotion_pattern, behavior_rules, signature_messages)
- [x] Tạo bảng `app.user_ai_settings` (user_id, persona_id, relationship_level, custom_nickname)
- [x] Tạo bảng `app.scheduled_notifications` (id, user_id, type, persona_id, scheduled_at, content, sent)
- [x] Tạo bảng `app.ai_conversation_context` (user context memory)
- [x] Migration script: `src/migrations/20251202_ai_companion_phase1.sql`
- [x] Seed data: `src/migrations/20251202_ai_companion_seed.sql`

### 1.2 Persona Engine Module
- [x] Tạo `src/modules/ai-companion/persona/` folder structure
- [x] `persona.repo.js` - CRUD personas, user settings, context
- [x] `persona.service.js` - Logic chọn persona, generate response theo tone
- [x] `persona.controller.js` - API endpoints
- [x] Seed data cho 5 personas mặc định (Mother, Lover, BestFriend, Mentor, Pet)

### 1.3 Notification Engine
- [x] Tạo `src/modules/ai-companion/notifications/` folder
- [x] `notification.repo.js` - CRUD scheduled notifications
- [x] `notification.service.js` - Logic tạo/gửi notifications với templates
- [x] `notification.scheduler.js` - Scheduler với setInterval (production: dùng node-cron)
- [x] `notification.controller.js` - API endpoints
- [ ] Tích hợp Socket.io để push realtime notifications (cần thêm)

### 1.4 API Endpoints Phase 1
- [x] `GET /api/v1/ai-companion/personas` - Danh sách personas
- [x] `GET /api/v1/ai-companion/personas/:id` - Chi tiết persona
- [x] `GET /api/v1/ai-companion/settings` - Lấy settings hiện tại
- [x] `POST /api/v1/ai-companion/settings` - Tạo/cập nhật settings
- [x] `PUT /api/v1/ai-companion/settings` - Cập nhật settings
- [x] `POST /api/v1/ai-companion/persona/select` - Chọn persona
- [x] `GET /api/v1/ai-companion/context` - Lấy user context
- [x] `POST /api/v1/ai-companion/context` - Lưu user context
- [x] `GET /api/v1/ai-companion/notifications` - Lấy notifications
- [x] `POST /api/v1/ai-companion/notifications/schedule` - Schedule notification
- [x] `POST /api/v1/ai-companion/notifications/random` - Schedule random message
- [x] `DELETE /api/v1/ai-companion/notifications/:id` - Xóa notification
- [x] Admin endpoints cho scheduling và cleanup

### 1.5 Integration
- [x] Tích hợp persona vào `aiCore.js`
- [x] Cập nhật `prompt.js` với `buildPromptWithPersona()`
- [x] Đăng ký routes trong `src/routes/index.js`
- [x] Test client: `test_client/ai_companion_test.html`

---

## 🗓️ PHASE 2: EMOTIONAL MEMORY + MENTAL HEALTH (Tuần 3-4)

### 2.1 Database Schema
- [x] Tạo bảng `app.emotion_logs` (id, user_id, emotion, intensity, detected_at, source, confidence, metadata)
- [x] Tạo bảng `app.user_mental_state` (user_id, current_mood, stress_level, anxiety_level, energy_level, vulnerability_score, consecutive_negative_days)
- [x] Tạo bảng `app.mental_health_assessments` (id, user_id, risk_level, burnout_score, depression/anxiety indicators, recommendations)
- [x] Tạo bảng `app.wellness_activities` (id, user_id, type, duration, mood_before/after, effectiveness_rating)
- [x] Tạo bảng `app.daily_mood_checkins` (user_id, date, mood, energy, sleep, stress, gratitude_notes)
- [x] Tạo bảng `app.emotion_patterns` (user_id, pattern_type, pattern_key, pattern_data, frequency)
- [x] Index cho query emotion timeline + views cho monitoring
- [x] Migration: `src/migrations/20251202_ai_companion_phase2.sql`

### 2.2 Emotional Memory Engine
- [x] Tạo `src/modules/ai-companion/emotion/` folder
- [x] `emotion.repo.js` - CRUD emotion logs, mental state, assessments, wellness, checkins, patterns
- [x] `emotion.analyzer.js` - Phân tích sentiment (keyword-based + AI-based với Gemini)
- [x] `emotion.service.js` - Logic cập nhật mental state, tạo assessment, gợi ý wellness
- [x] `emotion.controller.js` - API endpoints
- [x] Tích hợp vào `aiCore.js` - Auto log emotion sau mỗi chat

### 2.3 Mental Health Engine (Tích hợp trong emotion module)
- [x] Assessment system với risk level (low/moderate/high/critical)
- [x] Burnout score calculation
- [x] Auto-generate recommendations dựa trên mental state
- [x] Wellness activity suggestions dựa trên current state
- [x] Daily mood check-in system
- [x] Admin view: Users needing attention

### 2.4 API Endpoints Phase 2
- [x] `GET /api/v1/ai-companion/emotion/timeline` - Emotion history với trend analysis
- [x] `GET /api/v1/ai-companion/emotion/stats` - Emotion statistics
- [x] `GET /api/v1/ai-companion/mental-state` - Current mental state với interpretation
- [x] `POST /api/v1/ai-companion/assessment` - Tạo assessment mới
- [x] `GET /api/v1/ai-companion/assessment/latest` - Assessment gần nhất
- [x] `GET /api/v1/ai-companion/assessment/history` - Lịch sử assessments
- [x] `POST /api/v1/ai-companion/wellness/log` - Log wellness activity
- [x] `GET /api/v1/ai-companion/wellness/history` - Lịch sử activities
- [x] `GET /api/v1/ai-companion/wellness/stats` - Thống kê activities
- [x] `GET /api/v1/ai-companion/wellness/suggestions` - Gợi ý activities
- [x] `POST /api/v1/ai-companion/checkin` - Submit daily check-in
- [x] `GET /api/v1/ai-companion/checkin/today` - Check-in hôm nay
- [x] `GET /api/v1/ai-companion/checkin/history` - Lịch sử check-in
- [x] `GET /api/v1/ai-companion/admin/users-needing-attention` - Admin monitoring

---

## 🗓️ PHASE 3: SMART SCHEDULE + PROACTIVE AI (Tuần 5-6)

### 3.1 Database Schema
- [x] Tạo bảng `app.user_schedules` (id, user_id, title, type, start_at, end_at, recurrence, ai_generated, priority)
- [x] Tạo bảng `app.sleep_logs` (user_id, date, sleep_at, wake_at, quality, duration, interruptions, factors)
- [x] Tạo bảng `app.behavior_patterns` (user_id, pattern_type, pattern_name, pattern_data, confidence, occurrences)
- [x] Tạo bảng `app.proactive_messages` (user_id, trigger_type, message_content, scheduled_at, priority)
- [x] Tạo bảng `app.ai_suggestions` (user_id, suggestion_type, suggestion_content, accepted, feedback)
- [x] Tạo bảng `app.user_activity_logs` (user_id, activity_type, activity_data, session_id)
- [x] Views: v_today_schedules, v_user_sleep_summary, v_inactive_users
- [x] Migration: `src/migrations/20251202_ai_companion_phase3.sql`

### 3.2 Smart Schedule Engine
- [x] Tạo `src/modules/ai-companion/schedule/` folder
- [x] `schedule.repo.js` - CRUD schedules, sleep logs, patterns, proactive messages, suggestions, activity
- [x] `schedule.service.js` - Logic tạo/quản lý lịch, AI suggestions, sleep analysis, pattern detection
- [x] `schedule.controller.js` - API endpoints

### 3.3 Proactive AI System
- [x] Proactive messages queue với trigger types (schedule, emotion, behavior, inactivity)
- [x] Inactive user detection và auto-generate messages
- [x] AI suggestions system với accept/dismiss tracking
- [x] Behavior pattern detection (sleep patterns, activity patterns)

### 3.4 API Endpoints Phase 3
- [x] `POST /api/v1/ai-companion/schedule` - Tạo lịch mới
- [x] `GET /api/v1/ai-companion/schedule` - Lấy lịch user (với filters)
- [x] `GET /api/v1/ai-companion/schedule/today` - Lịch hôm nay
- [x] `GET /api/v1/ai-companion/schedule/upcoming` - Lịch sắp tới
- [x] `PUT /api/v1/ai-companion/schedule/:id` - Cập nhật lịch
- [x] `POST /api/v1/ai-companion/schedule/:id/complete` - Hoàn thành lịch
- [x] `DELETE /api/v1/ai-companion/schedule/:id` - Xóa lịch
- [x] `GET /api/v1/ai-companion/schedule/ai-suggest` - AI gợi ý lịch
- [x] `POST /api/v1/ai-companion/schedule/ai-suggest/accept` - Chấp nhận gợi ý
- [x] `POST /api/v1/ai-companion/sleep/log` - Log giấc ngủ
- [x] `GET /api/v1/ai-companion/sleep/history` - Lịch sử giấc ngủ
- [x] `GET /api/v1/ai-companion/sleep/analysis` - Phân tích giấc ngủ
- [x] `GET /api/v1/ai-companion/patterns` - Xem behavior patterns
- [x] `GET /api/v1/ai-companion/suggestions` - Xem pending suggestions
- [x] `POST /api/v1/ai-companion/suggestions/:id/respond` - Respond to suggestion
- [x] `POST /api/v1/ai-companion/admin/generate-proactive` - Admin: Generate proactive messages
- [x] `GET /api/v1/ai-companion/admin/proactive-pending` - Admin: Get pending proactive messages

---

## 🔧 TASKS CHUNG (Xuyên suốt)

### Cập nhật AI Core
- [x] Refactor `aiCore.js` để support persona context
- [x] Thêm emotion detection vào response flow
- [x] Cập nhật `prompt.js` với dynamic persona prompts
- [x] Thêm relationship level vào prompt context

### Infrastructure
- [x] Cài đặt `node-cron` cho scheduled tasks
- [ ] Setup Redis/Bull queue cho notifications (optional, khi scale)
- [x] Logging system cho AI interactions (`src/AI/aiLogger.js`)
- [x] Rate limiting cho Gemini API calls (`src/AI/rateLimiter.js`)

### Testing
- [x] Unit tests cho persona service (`src/AI/companion/__tests__/persona.service.test.js`)
- [x] Unit tests cho emotion analyzer (`src/AI/companion/__tests__/emotion.analyzer.test.js`)
- [x] Integration tests cho notification flow (`src/AI/companion/__tests__/notification.scheduler.test.js`)
- [x] Test client HTML cho AI Companion features (`test_client/ai_companion_test.html`)

### Documentation
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Persona configuration guide
- [ ] Privacy policy update (emotion data)

---

## ⚠️ RỦI RO & GIẢI PHÁP

| Rủi ro | Giải pháp |
|--------|-----------|
| Token cost cao | Cache emotion analysis, batch processing |
| Privacy concerns | Encryption emotion data, user consent flow |
| Persona lệch tông | A/B testing prompts, user feedback loop |
| Notification spam | Smart throttling, user preferences |
| Scale issues | Redis queue, horizontal scaling |

---

## 📦 DEPENDENCIES CẦN CÀI

```bash
npm install node-cron    # Scheduled tasks
npm install ioredis      # Redis client (optional)
npm install bull         # Job queue (optional)
```

---

## 📁 CẤU TRÚC THƯ MỤC ĐỀ XUẤT

```
src/modules/ai-companion/
├── persona/
│   ├── persona.repo.js
│   ├── persona.service.js
│   └── persona.controller.js
├── emotion/
│   ├── emotion.repo.js
│   ├── emotion.analyzer.js
│   └── emotion.service.js
├── mental-health/
│   ├── mentalHealth.repo.js
│   ├── mentalHealth.service.js
│   └── mentalHealth.controller.js
├── schedule/
│   ├── schedule.repo.js
│   ├── schedule.service.js
│   ├── schedule.ai.js
│   └── schedule.controller.js
├── notifications/
│   ├── notification.repo.js
│   ├── notification.service.js
│   ├── notification.scheduler.js
│   └── proactive.service.js
├── routes.js
└── index.js
```

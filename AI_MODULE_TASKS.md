# 📋 AI MODULE - DANH SÁCH TASK CẦN LÀM

> **Ngày tạo:** 12/12/2025  
> **Dựa trên:** Phân tích AI Module Healing Backend  
> **Tổng số tasks:** 32 tasks

---

## 📊 TỔNG QUAN

| Mức độ | Số lượng | Mô tả |
|--------|----------|-------|
| 🔴 Critical | 4 | Cần sửa ngay, ảnh hưởng security/stability |
| 🟡 Medium | 12 | Cần sửa sớm, ảnh hưởng performance/scalability |
| 🟢 Low | 8 | Cải thiện code quality |
| 🚀 Feature | 8 | Tính năng mới nên thêm |

---

## 🔴 CRITICAL - CẦN SỬA NGAY

### Task 1: Thêm Input Validation cho AI Chat
- **File:** `src/AI/aiCore.js`
- **Vấn đề:** Không validate `userMessage` - có thể bị injection hoặc quá dài
- **Công việc:**
  - [ ] Validate userId (number, > 0)
  - [ ] Validate userMessage (string, not empty)
  - [ ] Trim và limit length (max 5000 chars)
  - [ ] Sanitize input trước khi gửi Gemini
- **Estimate:** 1h

### Task 2: Xóa Console.log trong Production
- **File:** `src/AI/aiCore.js` (Line 76-78)
- **Vấn đề:** Log raw Gemini response ra console
- **Công việc:**
  - [ ] Thay console.log bằng logger.debug
  - [ ] Chỉ log ở development mode
  - [ ] Limit log length (max 500 chars)
- **Estimate:** 30m

### Task 3: Xử lý Crisis Detection Properly
- **File:** `src/AI/companion/emotion/emotion.service.js` (Line 37)
- **Vấn đề:** Chỉ console.warn khi detect crisis, không có action
- **Công việc:**
  - [ ] Thay console.warn bằng logger
  - [ ] Gọi logCrisisDetected để track
  - [ ] Tạo alert record trong database
  - [ ] Notify admin nếu critical
- **Estimate:** 2h

### Task 4: Validate Persona Custom Nickname
- **File:** `src/AI/companion/persona/persona.service.js`
- **Vấn đề:** Không sanitize custom_nickname - XSS risk
- **Công việc:**
  - [ ] Validate type là string
  - [ ] Remove special chars (<, >, ", ', &)
  - [ ] Limit length (max 50 chars)
  - [ ] Set null nếu empty sau sanitize
- **Estimate:** 30m

---

## 🟡 MEDIUM - CẦN SỬA SỚM

### Task 5: Tạo Shared AI Config
- **File:** Tạo mới `src/AI/config.js`
- **Vấn đề:** Model name hardcoded, không nhất quán giữa các file
- **Công việc:**
  - [ ] Tạo file config.js export GEMINI_MODEL
  - [ ] Đọc từ env variable
  - [ ] Export shared geminiModel instance
  - [ ] Update aiCore.js sử dụng shared config
  - [ ] Update emotion.analyzer.js sử dụng shared config
- **Estimate:** 1h

### Task 6: Thêm Redis Support cho Rate Limiter
- **File:** `src/AI/rateLimiter.js`
- **Vấn đề:** In-memory Map không scale với multiple instances
- **Công việc:**
  - [ ] Thêm Redis adapter
  - [ ] Check REDIS_URL để quyết định dùng Redis hay Memory
  - [ ] Implement checkLimitRedis()
  - [ ] Implement recordRequestRedis()
  - [ ] Test với Redis local
- **Estimate:** 3h

### Task 7: Thêm Timeout cho Gemini API Calls
- **File:** `src/AI/companion/emotion/emotion.analyzer.js`
- **Vấn đề:** Không có timeout, có thể hang
- **Công việc:**
  - [ ] Thêm timeout parameter (default 5000ms)
  - [ ] Sử dụng Promise.race với timeout
  - [ ] Handle AbortController
  - [ ] Log timeout errors
- **Estimate:** 1h

### Task 8: Fix Timezone Handling cho Notifications
- **File:** `src/AI/companion/notifications/notification.service.js`
- **Vấn đề:** Hardcoded timezone, không dùng user timezone
- **Công việc:**
  - [ ] Install luxon package
  - [ ] Tạo helper getScheduledTimeForUser()
  - [ ] Đọc timezone từ user settings
  - [ ] Update scheduleMorningCheckins()
  - [ ] Update scheduleEveningCheckins()
- **Estimate:** 2h

### Task 9: Thêm Fallback cho Expert Matching
- **File:** `src/AI/database/expert.js`
- **Vấn đề:** Không handle case không tìm thấy expert
- **Công việc:**
  - [ ] Check result.rows.length
  - [ ] Fallback to top rated experts nếu empty
  - [ ] Return flag `fallback: true`
  - [ ] Return message giải thích
- **Estimate:** 1h

### Task 10: Tạo Crisis Config File
- **File:** Tạo mới `src/AI/config/crisis.config.js`
- **Vấn đề:** Crisis keywords hardcoded trong prompt.js
- **Công việc:**
  - [ ] Tạo file config với keywords theo level
  - [ ] Thêm hotline info
  - [ ] Thêm response templates
  - [ ] Update prompt.js import từ config
- **Estimate:** 1h

### Task 11: Thêm Error Handling cho Emotion AI Analysis
- **File:** `src/AI/companion/emotion/emotion.analyzer.js`
- **Vấn đề:** Error handling chưa đầy đủ
- **Công việc:**
  - [ ] Limit input text length (max 1000 chars)
  - [ ] Validate response không empty
  - [ ] Log warning với context
  - [ ] Return fallback_reason trong response
- **Estimate:** 1h

### Task 12: Thêm Validation cho Schedule Service
- **File:** `src/AI/companion/schedule/schedule.service.js`
- **Vấn đề:** Không validate schedule data
- **Công việc:**
  - [ ] Validate title (required, max 200 chars)
  - [ ] Validate schedule_type (enum)
  - [ ] Validate start_at (valid date, not in past)
  - [ ] Validate priority (1-5)
- **Estimate:** 1h

### Task 13: Thêm Validation cho Emotion Service
- **File:** `src/AI/companion/emotion/emotion.service.js`
- **Vấn đề:** Không validate checkin data
- **Công việc:**
  - [ ] Validate mood (enum)
  - [ ] Validate mood_score (1-5)
  - [ ] Validate stress_level (0-10)
  - [ ] Validate energy_level (0-10)
- **Estimate:** 1h

### Task 14: Thêm Pagination cho Chat History
- **File:** `src/AI/database.js`
- **Vấn đề:** getAIChatHistory chỉ có limit, không có offset
- **Công việc:**
  - [ ] Thêm offset parameter
  - [ ] Return total count
  - [ ] Update controller để support pagination
- **Estimate:** 1h

### Task 15: Optimize Expert Search Query
- **File:** `src/AI/database/expert.js`
- **Vấn đề:** Query có thể chậm với data lớn
- **Công việc:**
  - [ ] Thêm index cho specialties (GIN)
  - [ ] Thêm index cho rating_avg
  - [ ] Consider materialized view
- **Estimate:** 2h

### Task 16: Thêm Caching cho Persona Data
- **File:** `src/AI/companion/persona/persona.service.js`
- **Vấn đề:** Query persona mỗi lần chat
- **Công việc:**
  - [ ] Cache persona list (TTL 10 phút)
  - [ ] Cache user settings (TTL 5 phút)
  - [ ] Invalidate cache khi update
- **Estimate:** 2h

---

## 🟢 LOW - CẢI THIỆN CODE QUALITY

### Task 17: Thêm JSDoc Comments
- **Files:** Tất cả files trong src/AI/
- **Công việc:**
  - [ ] Thêm JSDoc cho tất cả exported functions
  - [ ] Document parameters và return types
  - [ ] Thêm examples cho complex functions
- **Estimate:** 3h

### Task 18: Tạo Constants File
- **File:** Tạo mới `src/AI/constants.js`
- **Công việc:**
  - [ ] Move EMOTION_KEYWORDS từ emotion.analyzer.js
  - [ ] Move DB_KEYWORDS từ expert.js
  - [ ] Move notification templates
  - [ ] Export tất cả constants
- **Estimate:** 1h

### Task 19: Refactor Notification Templates
- **File:** `src/AI/companion/notifications/notification.service.js`
- **Vấn đề:** Templates hardcoded trong file
- **Công việc:**
  - [ ] Move templates ra file riêng
  - [ ] Support i18n (multi-language)
  - [ ] Thêm more templates
- **Estimate:** 2h

### Task 20: Thêm Unit Tests cho Emotion Analyzer
- **File:** Tạo mới `src/AI/companion/emotion/emotion.analyzer.test.js`
- **Công việc:**
  - [ ] Test analyzeEmotionSimple()
  - [ ] Test crisis detection
  - [ ] Test emotion trend analysis
  - [ ] Mock Gemini API cho AI tests
- **Estimate:** 3h

### Task 21: Thêm Unit Tests cho Rate Limiter
- **File:** Tạo mới `src/AI/rateLimiter.test.js`
- **Công việc:**
  - [ ] Test user limit
  - [ ] Test global limit
  - [ ] Test daily limit
  - [ ] Test cleanup
- **Estimate:** 2h

### Task 22: Cleanup Unused Imports
- **Files:** Tất cả files trong src/AI/
- **Công việc:**
  - [ ] Review và remove unused imports
  - [ ] Organize imports (external → internal)
- **Estimate:** 1h

### Task 23: Thêm TypeScript Types (Optional)
- **File:** Tạo mới `src/AI/types.d.ts`
- **Công việc:**
  - [ ] Define EmotionAnalysis type
  - [ ] Define MentalState type
  - [ ] Define Persona type
  - [ ] Define Schedule type
- **Estimate:** 2h

### Task 24: Improve Error Messages
- **Files:** Tất cả service files
- **Công việc:**
  - [ ] Standardize error format
  - [ ] Add error codes
  - [ ] Improve user-facing messages
- **Estimate:** 2h

---

## 🚀 FEATURE - TÍNH NĂNG MỚI

### Task 25: Implement Multi-Signal Crisis Detection
- **Mô tả:** Kết hợp nhiều tín hiệu để detect crisis chính xác hơn
- **Công việc:**
  - [ ] Tạo `src/AI/crisis/multiSignalDetector.js`
  - [ ] Implement text analysis signal (30%)
  - [ ] Implement behavioral signal (25%)
  - [ ] Implement historical signal (25%)
  - [ ] Implement contextual signal (20%)
  - [ ] Calculate combined risk score
  - [ ] Create crisis_alerts table
  - [ ] Implement alert notification
- **Estimate:** 8h

### Task 26: Implement Proactive AI Care System
- **Mô tả:** AI chủ động reach out khi user cần
- **Công việc:**
  - [ ] Detect negative emotion patterns
  - [ ] Detect unusual inactivity
  - [ ] Detect special dates (anniversaries)
  - [ ] Generate personalized outreach messages
  - [ ] Respect quiet hours
  - [ ] Track effectiveness
- **Estimate:** 6h

### Task 27: Implement Trauma-Informed Responses
- **Mô tả:** AI tránh trigger trauma đã biết của user
- **Công việc:**
  - [ ] Create user_trauma_profiles table
  - [ ] Build trauma-informed prompt builder
  - [ ] Detect and learn triggers from conversations
  - [ ] Implement safe topic suggestions
- **Estimate:** 6h

### Task 28: Implement Voice Message Support
- **Mô tả:** Gửi voice message theo persona
- **Công việc:**
  - [ ] Integrate TTS API (Google/Azure)
  - [ ] Generate voice per persona
  - [ ] Store voice files (Cloudinary)
  - [ ] Add voice notification type
- **Estimate:** 8h

### Task 29: Implement Healing Journey Dashboard API
- **Mô tả:** API cho dashboard tiến trình chữa lành
- **Công việc:**
  - [ ] GET /journey/overview - tổng quan
  - [ ] GET /journey/timeline - milestones
  - [ ] GET /journey/heatmap - emotion heatmap
  - [ ] GET /journey/correlations - insights
  - [ ] GET /journey/predictions - dự đoán
- **Estimate:** 6h

### Task 30: Implement Expert-AI Collaboration
- **Mô tả:** AI hỗ trợ expert trong session
- **Công việc:**
  - [ ] Real-time emotion detection during session
  - [ ] Suggest techniques to expert
  - [ ] Auto-generate session notes
  - [ ] Track progress between sessions
- **Estimate:** 10h

### Task 31: Implement Guided Wellness Exercises
- **Mô tả:** Bài tập thở, thiền có hướng dẫn
- **Công việc:**
  - [ ] Create wellness_exercises table
  - [ ] Add breathing exercises (4-7-8, box)
  - [ ] Add grounding techniques (5-4-3-2-1)
  - [ ] Add meditation guides
  - [ ] Track completion và effectiveness
- **Estimate:** 6h

### Task 32: Implement Mood Journal với AI Analysis
- **Mô tả:** Nhật ký cảm xúc với AI phân tích
- **Công việc:**
  - [ ] Create mood_journal_entries table
  - [ ] Create mood_journal_prompts table
  - [ ] Implement free/guided entry types
  - [ ] AI weekly summary generation
  - [ ] Detect patterns và triggers
- **Estimate:** 6h

---

## 📅 SUGGESTED SPRINT PLAN

### Sprint 1 (Week 1): Critical Fixes
- Task 1: Input Validation ✅
- Task 2: Remove Console.log ✅
- Task 3: Crisis Detection ✅
- Task 4: Validate Nickname ✅
- Task 5: Shared AI Config ✅

### Sprint 2 (Week 2): Medium Priority
- Task 6: Redis Rate Limiter
- Task 7: Gemini Timeout
- Task 8: Timezone Handling
- Task 9: Expert Fallback
- Task 10: Crisis Config

### Sprint 3 (Week 3): Medium Priority (cont.)
- Task 11: Error Handling
- Task 12: Schedule Validation
- Task 13: Emotion Validation
- Task 14: Pagination
- Task 15: Query Optimization
- Task 16: Caching

### Sprint 4 (Week 4): Code Quality
- Task 17-24: Low priority tasks

### Sprint 5-8 (Month 2): New Features
- Task 25-32: Feature tasks

---

## 📝 NOTES

1. **Dependencies:**
   - Task 6 cần Redis server
   - Task 8 cần install `luxon` package
   - Task 28 cần TTS API key

2. **Testing:**
   - Tất cả tasks cần test manual trước khi merge
   - Tasks 20-21 là unit tests

3. **Database Migrations:**
   - Task 25 cần migration cho crisis_alerts
   - Task 27 cần migration cho user_trauma_profiles
   - Task 31 cần migration cho wellness_exercises
   - Task 32 cần migration cho mood_journal

4. **Environment Variables cần thêm:**
   ```
   GEMINI_MODEL=gemini-2.5-flash
   REDIS_URL=redis://localhost:6379
   TTS_API_KEY=xxx (cho Task 28)
   ```

---

**Cập nhật lần cuối:** 12/12/2025

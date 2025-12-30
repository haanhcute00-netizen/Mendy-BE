# 🔍 PHÂN TÍCH GAP & ĐỀ XUẤT TÍNH NĂNG CHAT CHO HEALING APP

> **Ngày tạo:** 29/12/2024  
> **Tham khảo:** Zalo, Messenger, Telegram  
> **Mục tiêu:** Nâng cấp module chat phù hợp với nền tảng chữa lành tâm lý

---

## 📊 HIỆN TRẠNG MODULE CHAT

### Đã có:
- ✅ Text messaging cơ bản
- ✅ Read receipts (đánh dấu đã đọc)
- ✅ DM threads (1-1)
- ✅ Booking threads
- ✅ Rate limiting (20 msg/phút)
- ✅ XSS protection
- ✅ Attachments (repo level)
- ✅ Edit/Delete message (repo level)
- ✅ Group chat (repo level)

### Chưa có API/Service:
- ❌ Typing indicator
- ❌ Online status
- ❌ Message reactions
- ❌ Reply to message
- ❌ Voice message
- ❌ Pin message
- ❌ Mute conversation
- ❌ Message search
- ❌ Delete for everyone

---

## 📈 SO SÁNH VỚI CÁC NỀN TẢNG LỚN

| Tính năng | Zalo | Messenger | Telegram | Healing | Cần cho Healing? |
|-----------|:----:|:---------:|:--------:|:-------:|:----------------:|
| Text messaging | ✅ | ✅ | ✅ | ✅ | ✅ Đã có |
| Read receipts | ✅ | ✅ | ✅ | ✅ | ✅ Đã có |
| Typing indicator | ✅ | ✅ | ✅ | ❌ | 🔴 Cần thiết |
| Online status | ✅ | ✅ | ✅ | ❌ | 🟡 Tùy chọn |
| Message reactions | ✅ | ✅ | ✅ | ❌ | 🔴 Cần thiết |
| Reply to message | ✅ | ✅ | ✅ | ❌ | 🔴 Cần thiết |
| Forward message | ✅ | ✅ | ✅ | ❌ | ⚪ Không cần |
| Pin message | ✅ | ✅ | ✅ | ❌ | 🟡 Nên có |
| Delete for everyone | ✅ | ✅ | ✅ | ❌ | 🔴 Cần thiết |
| Edit message | ❌ | ✅ | ✅ | ✅ | ✅ Đã có |
| Voice message | ✅ | ✅ | ✅ | ❌ | 🔴 Cần thiết |
| Image/File sharing | ✅ | ✅ | ✅ | ✅ | ✅ Đã có |
| Message search | ✅ | ✅ | ✅ | ❌ | 🟡 Nên có |
| Mute conversation | ✅ | ✅ | ✅ | ❌ | 🟡 Nên có |
| Block user | ✅ | ✅ | ✅ | ✅ | ✅ Đã có |
| E2E encryption | ❌ | ✅ | ✅ | ❌ | 🟡 Tùy chọn |
| Disappearing messages | ❌ | ✅ | ✅ | ❌ | 🔴 Cần thiết |
| Scheduled messages | ❌ | ❌ | ✅ | ❌ | ⚪ Không cần |

**Chú thích:**
- 🔴 Cần thiết - Ưu tiên cao
- 🟡 Nên có - Ưu tiên trung bình  
- ⚪ Không cần - Ưu tiên thấp/Không phù hợp

---

## 🎯 TÍNH NĂNG ĐỀ XUẤT CHO HEALING APP

### 🔴 ƯU TIÊN CAO (Phase 1)

#### 1. Typing Indicator
**Lý do:** Giúp người dùng biết expert đang phản hồi → giảm lo âu khi chờ đợi

```
WebSocket Events:
- Client → Server: typing:start, typing:stop
- Server → Client: user:typing (broadcast to thread members)
```

#### 2. Message Reactions (Healing-Specific)
**Lý do:** Expert có thể phản hồi nhanh, thể hiện sự đồng cảm mà không cần gõ nhiều

| Emoji | Code | Ý nghĩa Healing |
|:-----:|------|-----------------|
| 🤗 | HUG | Ôm ấp, đồng cảm |
| 💪 | STRONG | Cổ vũ, mạnh mẽ |
| 🙏 | GRATEFUL | Biết ơn |
| ❤️ | SUPPORT | Ủng hộ, yêu thương |
| ✨ | UNDERSTOOD | Đã hiểu, ghi nhận |
| 🌱 | GROWTH | Tiến bộ, phát triển |

#### 3. Reply to Specific Message
**Lý do:** Quan trọng trong tư vấn để reference lại vấn đề cụ thể của client

```json
{
  "content": "Về vấn đề này, tôi nghĩ...",
  "reply_to_id": 123
}
```

#### 4. Voice Message
**Lý do:** Nhiều người khó diễn đạt bằng text → voice giúp thể hiện cảm xúc tốt hơn

- Max duration: 5 phút
- Format: MP3/OGG
- Auto-transcribe (optional, dùng AI)

#### 5. Delete for Everyone
**Lý do:** Cho phép xóa tin nhắn gửi nhầm hoặc nội dung nhạy cảm

- Giới hạn: trong 24 giờ
- Hiển thị: "Tin nhắn đã bị xóa"

#### 6. Disappearing Messages (Auto-delete)
**Lý do:** Bảo mật thông tin nhạy cảm sau khi session kết thúc

- Options: 7 ngày / 30 ngày / Sau khi booking complete
- Configurable per thread

---

### 🟡 ƯU TIÊN TRUNG BÌNH (Phase 2)

#### 7. Session Notes (Expert Only)
**Lý do:** Expert ghi chú riêng về client (không hiển thị cho client)

- Private notes per thread
- Chỉ expert của thread mới xem được
- Hỗ trợ markdown

#### 8. Quick Replies / Canned Responses
**Lý do:** Expert có thể lưu các câu trả lời mẫu thường dùng

```
Ví dụ:
- "Cảm ơn bạn đã chia sẻ. Tôi hiểu cảm giác của bạn..."
- "Hãy thử bài tập thở này: Hít vào 4 giây..."
- "Chúng ta sẽ tiếp tục trong buổi tới nhé!"
```

#### 9. Mood Check-in Prompt
**Lý do:** Tự động hỏi mood trước/sau session trong chat

```
[System Message]
"Trước khi bắt đầu, bạn đang cảm thấy thế nào hôm nay?"
[😢 Rất tệ] [😕 Không tốt] [😐 Bình thường] [🙂 Khá ổn] [😊 Rất tốt]
```

#### 10. Pin Important Message
**Lý do:** Ghim hướng dẫn, bài tập về nhà từ expert

- Max 3 pinned messages per thread
- Hiển thị ở đầu thread

#### 11. Mute Conversation
**Lý do:** Tắt thông báo khi cần nghỉ ngơi

- Options: 1 giờ / 8 giờ / 1 ngày / Cho đến khi bật lại

#### 12. Online/Last Seen Status
**Lý do:** Biết expert có online không

- **Privacy control:** Cho phép ẩn
- Hiển thị: "Online" / "Hoạt động 5 phút trước" / "Ẩn"

---

### ⚪ ƯU TIÊN THẤP (Phase 3)

#### 13. Message Search
- Full-text search trong thread
- Filter by date range

#### 14. Chat Export
- Export conversation ra PDF
- Cho client lưu lại lời khuyên

#### 15. Chat Themes
- Dark/Light mode
- Calming colors cho healing

---

## 🗄️ DATABASE CHANGES

### Bảng mới cần tạo:

```sql
-- 1. Message Reactions (Healing-specific)
CREATE TABLE app.message_reactions (
  id SERIAL PRIMARY KEY,
  message_id INT NOT NULL REFERENCES app.chat_messages(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL, -- HUG, STRONG, GRATEFUL, SUPPORT, UNDERSTOOD, GROWTH
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(message_id, user_id, type)
);

CREATE INDEX idx_reactions_message ON app.message_reactions(message_id);

-- 2. Expert Session Notes (Private)
CREATE TABLE app.session_notes (
  id SERIAL PRIMARY KEY,
  thread_id INT NOT NULL REFERENCES app.chat_threads(id) ON DELETE CASCADE,
  expert_id INT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_session_notes_thread ON app.session_notes(thread_id);

-- 3. Expert Quick Replies
CREATE TABLE app.expert_quick_replies (
  id SERIAL PRIMARY KEY,
  expert_id INT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(50), -- greeting, exercise, closing, etc.
  usage_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_quick_replies_expert ON app.expert_quick_replies(expert_id);

-- 4. Thread Settings (Mute, Pin, etc.)
CREATE TABLE app.thread_user_settings (
  thread_id INT NOT NULL REFERENCES app.chat_threads(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
  muted_until TIMESTAMP,
  notification_enabled BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (thread_id, user_id)
);

-- 5. Pinned Messages
CREATE TABLE app.pinned_messages (
  id SERIAL PRIMARY KEY,
  thread_id INT NOT NULL REFERENCES app.chat_threads(id) ON DELETE CASCADE,
  message_id INT NOT NULL REFERENCES app.chat_messages(id) ON DELETE CASCADE,
  pinned_by INT NOT NULL REFERENCES app.users(id),
  pinned_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(thread_id, message_id)
);
```

### Cập nhật bảng hiện có:

```sql
-- chat_messages: Thêm các cột mới
ALTER TABLE app.chat_messages 
ADD COLUMN IF NOT EXISTS reply_to_id INT REFERENCES app.chat_messages(id),
ADD COLUMN IF NOT EXISTS message_type VARCHAR(20) DEFAULT 'TEXT', -- TEXT, VOICE, IMAGE, FILE, SYSTEM
ADD COLUMN IF NOT EXISTS deleted_for_all BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS voice_duration_seconds INT,
ADD COLUMN IF NOT EXISTS voice_url TEXT;

CREATE INDEX idx_messages_reply ON app.chat_messages(reply_to_id) WHERE reply_to_id IS NOT NULL;

-- chat_threads: Thêm auto-delete setting
ALTER TABLE app.chat_threads 
ADD COLUMN IF NOT EXISTS auto_delete_days INT, -- NULL = never, 7, 30
ADD COLUMN IF NOT EXISTS auto_delete_after_complete BOOLEAN DEFAULT FALSE;

-- users: Thêm online status
ALTER TABLE app.users 
ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS show_online_status BOOLEAN DEFAULT TRUE;
```

---

## 🌐 API ENDPOINTS MỚI

### Phase 1 APIs:

```
# Reactions
POST   /chat/messages/:id/react          - Thêm reaction
DELETE /chat/messages/:id/react/:type    - Xóa reaction
GET    /chat/messages/:id/reactions      - Lấy danh sách reactions

# Reply (update existing send message)
POST   /chat/threads/:id/messages        - Thêm field reply_to_id

# Voice Message
POST   /chat/threads/:id/voice           - Upload voice message

# Delete for everyone
DELETE /chat/messages/:id/everyone       - Xóa cho tất cả (trong 24h)

# Auto-delete settings
PUT    /chat/threads/:id/auto-delete     - Cài đặt tự động xóa
```

### Phase 2 APIs:

```
# Session Notes (Expert only)
GET    /chat/threads/:id/notes           - Lấy notes
POST   /chat/threads/:id/notes           - Tạo note
PUT    /chat/threads/:id/notes/:noteId   - Sửa note
DELETE /chat/threads/:id/notes/:noteId   - Xóa note

# Quick Replies
GET    /experts/quick-replies            - Lấy danh sách
POST   /experts/quick-replies            - Tạo mới
PUT    /experts/quick-replies/:id        - Sửa
DELETE /experts/quick-replies/:id        - Xóa

# Pin Message
POST   /chat/threads/:id/pin/:messageId  - Ghim tin nhắn
DELETE /chat/threads/:id/pin/:messageId  - Bỏ ghim
GET    /chat/threads/:id/pinned          - Lấy tin nhắn đã ghim

# Mute
PUT    /chat/threads/:id/mute            - Tắt thông báo
DELETE /chat/threads/:id/mute            - Bật lại thông báo

# Online Status
PUT    /users/me/online-status           - Cập nhật cài đặt hiển thị
```

### WebSocket Events Mới:

```javascript
// Typing Indicator
socket.emit('typing:start', { threadId });
socket.emit('typing:stop', { threadId });
socket.on('user:typing', { threadId, userId, isTyping });

// Online Status
socket.on('user:online', { userId });
socket.on('user:offline', { userId, lastSeen });

// Reactions
socket.on('message:reacted', { messageId, reaction, userId });
socket.on('message:unreacted', { messageId, reactionType, userId });

// Message Updates
socket.on('message:deleted', { messageId, deletedForAll });
socket.on('message:pinned', { threadId, messageId });
```

---

## 📅 ROADMAP ĐỀ XUẤT

### Phase 1 (2-3 tuần) ✅ COMPLETED
- [x] Typing indicator (WebSocket)
- [x] Message reactions (6 healing reactions)
- [x] Reply to message
- [x] Voice message upload
- [x] Delete for everyone

**Files đã tạo/cập nhật:**
- `src/migrations/20241229_chat_phase1.sql` - Database migration
- `src/modules/chat/chat.repo.js` - Repository functions
- `src/modules/chat/chat.service.js` - Business logic
- `src/modules/chat/chat.controller.js` - API controllers
- `src/modules/chat/chat.routes.js` - API routes
- `src/sockets/chat.socket.js` - WebSocket events
- `test_client/chat_phase1_test.html` - Test client

### Phase 2 (2-3 tuần)
- [ ] Auto-delete messages
- [ ] Expert session notes
- [ ] Quick replies cho expert
- [ ] Pin message
- [ ] Mute conversation

### Phase 3 (1-2 tuần)
- [ ] Online status với privacy
- [ ] Message search
- [ ] Mood check-in integration
- [ ] Chat export (PDF)

---

## 💡 GỢI Ý THÊM CHO HEALING APP

### 1. Crisis Detection trong Chat
Tích hợp với AI module hiện có để phát hiện từ khóa nguy hiểm:
- "tự tử", "không muốn sống", "kết thúc tất cả"
- Auto-alert cho expert và admin

### 2. Scheduled Check-in Messages
Expert có thể lên lịch tin nhắn tự động:
- "Chào bạn, hôm nay bạn thế nào?"
- Gửi vào giờ cố định hàng ngày/tuần

### 3. Resource Sharing
Thư viện tài liệu healing mà expert có thể share nhanh:
- Bài tập thở
- Guided meditation links
- Worksheets

### 4. Session Summary
Tự động tạo tóm tắt sau mỗi booking complete:
- Key points discussed
- Homework assigned
- Next steps

---

## 📞 LIÊN HỆ

Nếu có thắc mắc về đề xuất này, liên hệ Backend Team.


---

## 📖 PHASE 1 API DOCUMENTATION

### New REST Endpoints

#### Reactions
```
POST   /api/v1/chat/messages/:id/react
Body: { "type": "HUG" | "STRONG" | "GRATEFUL" | "SUPPORT" | "UNDERSTOOD" | "GROWTH" }

DELETE /api/v1/chat/messages/:id/react/:type

GET    /api/v1/chat/messages/:id/reactions

GET    /api/v1/chat/reactions/types
```

#### Delete for Everyone
```
DELETE /api/v1/chat/messages/:id/everyone
(Only within 24 hours, only message sender)
```

#### Voice Message
```
POST   /api/v1/chat/threads/:id/voice
Body: { "voice_url": "https://...", "voice_duration": 60 }
```

#### Send Message (Enhanced)
```
POST   /api/v1/chat/threads/:id/messages
Body: {
  "content": "Hello",
  "reply_to_id": 123,           // optional
  "message_type": "TEXT",       // TEXT | VOICE | IMAGE | FILE
  "voice_url": "...",           // for VOICE type
  "voice_duration": 60,         // for VOICE type
  "file_url": "...",            // for FILE/IMAGE type
  "file_name": "doc.pdf",
  "file_size": 1024,
  "file_mime_type": "application/pdf"
}
```

### New WebSocket Events

#### Client → Server
```javascript
// Typing
socket.emit('typing:start', { threadId: 1 });
socket.emit('typing:stop', { threadId: 1 });

// Message with reply
socket.emit('message:send', { 
  threadId: 1, 
  content: 'Hello', 
  replyToId: 123,
  messageType: 'TEXT'
}, callback);

// Reactions
socket.emit('reaction:add', { messageId: 1, type: 'HUG' }, callback);
socket.emit('reaction:remove', { messageId: 1, type: 'HUG' }, callback);

// Delete
socket.emit('message:delete', { messageId: 1 }, callback);
```

#### Server → Client
```javascript
// Typing
socket.on('user:typing', { threadId, userId, isTyping, timestamp });

// Reactions
socket.on('message:reacted', { messageId, reaction: { type, userId, created_at } });
socket.on('message:unreacted', { messageId, type, userId });

// Delete
socket.on('message:deleted', { messageId, threadId, deletedForAll: true });

// Online status
socket.on('user:online', { userId });
socket.on('user:offline', { userId, lastSeen });
```

### Run Migration
```bash
# Connect to PostgreSQL and run:
psql -U postgres -d healing_dev -f src/migrations/20241229_chat_phase1.sql
```

### Test
Open `test_client/chat_phase1_test.html` in browser to test all Phase 1 features.

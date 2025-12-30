// sockets/chat.socket.js
import * as ChatRepo from "../modules/chat/chat.repo.js";
import { verifyJwt } from "../utils/verifyJwt.js";

// Rate limiting
const buckets = new Map();
function allow(key, rate = 20, windowMs = 60_000) {
  const now = Date.now();
  let b = buckets.get(key) || { tokens: rate, ts: now };
  const refill = ((now - b.ts) / windowMs) * rate;
  b.tokens = Math.min(rate, b.tokens + refill);
  b.ts = now;
  if (b.tokens < 1) { buckets.set(key, b); return false; }
  b.tokens -= 1; buckets.set(key, b); return true;
}

function escapeHtml(s) {
  return s.replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

// Track typing status per thread
const typingUsers = new Map(); // threadId -> Set of userIds

// Track online users
const onlineUsers = new Map(); // socketId -> userId
const userSockets = new Map(); // userId -> Set of socketIds

export function initChatSocket(io) {
  // JWT Authentication middleware
  io.use((socket, next) => {
    try {
      const token =
        socket.handshake.auth?.token ||
        socket.handshake.headers?.authorization?.replace("Bearer ", "");
      const payload = verifyJwt(token);
      socket.userId = Number(payload.sub);
      socket.role = payload.role || "SEEKER";
      next();
    } catch (err) {
      next(new Error("Unauthorized"));
    }
  });

  io.on("connection", (socket) => {
    const userId = socket.userId;

    // Track online status
    onlineUsers.set(socket.id, userId);
    if (!userSockets.has(userId)) {
      userSockets.set(userId, new Set());
    }
    userSockets.get(userId).add(socket.id);

    // Broadcast online status
    socket.broadcast.emit("user:online", { userId });

    // =============================================
    // THREAD EVENTS
    // =============================================

    socket.on("thread:join", async (threadId) => {
      const isMem = await ChatRepo.isMember(threadId, userId);
      if (!isMem) return;

      socket.join(`thread:${threadId}`);
      io.to(`thread:${threadId}`).emit("presence:joined", {
        threadId,
        userId,
        timestamp: new Date().toISOString()
      });
    });

    socket.on("thread:leave", (threadId) => {
      socket.leave(`thread:${threadId}`);

      // Clear typing status when leaving
      const threadTyping = typingUsers.get(threadId);
      if (threadTyping) {
        threadTyping.delete(userId);
      }

      io.to(`thread:${threadId}`).emit("presence:left", {
        threadId,
        userId,
        timestamp: new Date().toISOString()
      });
    });

    // =============================================
    // TYPING INDICATOR (Phase 1)
    // =============================================

    socket.on("typing:start", async ({ threadId }) => {
      const isMem = await ChatRepo.isMember(threadId, userId);
      if (!isMem) return;

      if (!typingUsers.has(threadId)) {
        typingUsers.set(threadId, new Set());
      }
      typingUsers.get(threadId).add(userId);

      socket.to(`thread:${threadId}`).emit("user:typing", {
        threadId,
        userId,
        isTyping: true,
        timestamp: new Date().toISOString()
      });

      // Auto-clear typing after 5 seconds
      setTimeout(() => {
        const threadTyping = typingUsers.get(threadId);
        if (threadTyping && threadTyping.has(userId)) {
          threadTyping.delete(userId);
          socket.to(`thread:${threadId}`).emit("user:typing", {
            threadId,
            userId,
            isTyping: false
          });
        }
      }, 5000);
    });

    socket.on("typing:stop", async ({ threadId }) => {
      const threadTyping = typingUsers.get(threadId);
      if (threadTyping) {
        threadTyping.delete(userId);
      }

      socket.to(`thread:${threadId}`).emit("user:typing", {
        threadId,
        userId,
        isTyping: false,
        timestamp: new Date().toISOString()
      });
    });

    // Legacy typing event (backward compatible)
    socket.on("typing", ({ threadId, isTyping }) => {
      io.to(`thread:${threadId}`).emit("typing", {
        threadId,
        userId,
        isTyping: !!isTyping
      });
    });

    // =============================================
    // MESSAGE EVENTS (Phase 1 Enhanced)
    // =============================================

    socket.on("message:send", async ({ threadId, content, replyToId, messageType = 'TEXT' }, cb) => {
      try {
        const key = `msg:${userId}:${threadId}`;
        if (!allow(key, 20, 60_000)) return cb?.({ error: "rate_limited" });

        const member = await ChatRepo.isMember(threadId, userId);
        if (!member) return cb?.({ error: "forbidden" });

        const raw = String(content || "");
        const cleaned = escapeHtml(raw.trim()).slice(0, 2000);
        if (!cleaned && messageType === 'TEXT') return cb?.({ error: "empty_message" });

        // Validate reply
        if (replyToId) {
          const replyMsg = await ChatRepo.getMessageById(replyToId);
          if (!replyMsg || replyMsg.thread_id !== threadId) {
            return cb?.({ error: "invalid_reply" });
          }
        }

        const msg = await ChatRepo.insertMessage({
          threadId,
          senderId: userId,
          content: cleaned,
          replyToId: replyToId || null,
          messageType
        });

        // Clear typing status
        const threadTyping = typingUsers.get(threadId);
        if (threadTyping) {
          threadTyping.delete(userId);
        }

        // Broadcast message
        io.to(`thread:${threadId}`).emit("message:new", {
          ...msg,
          reactions: {}
        });

        cb?.({ ok: true, message: msg });
      } catch (e) {
        cb?.({ error: e.message });
      }
    });

    // =============================================
    // REACTION EVENTS (Phase 1)
    // =============================================

    socket.on("reaction:add", async ({ messageId, type }, cb) => {
      try {
        const message = await ChatRepo.getMessageById(messageId);
        if (!message) return cb?.({ error: "message_not_found" });

        const isMem = await ChatRepo.isMember(message.thread_id, userId);
        if (!isMem) return cb?.({ error: "forbidden" });

        const reaction = await ChatRepo.addReaction({
          messageId,
          userId,
          type: type.toUpperCase()
        });

        // Broadcast to thread
        io.to(`thread:${message.thread_id}`).emit("message:reacted", {
          messageId,
          reaction: {
            type: type.toUpperCase(),
            userId,
            created_at: reaction?.created_at || new Date().toISOString()
          }
        });

        cb?.({ ok: true, reaction });
      } catch (e) {
        cb?.({ error: e.message });
      }
    });

    socket.on("reaction:remove", async ({ messageId, type }, cb) => {
      try {
        const message = await ChatRepo.getMessageById(messageId);
        if (!message) return cb?.({ error: "message_not_found" });

        const isMem = await ChatRepo.isMember(message.thread_id, userId);
        if (!isMem) return cb?.({ error: "forbidden" });

        await ChatRepo.removeReaction({ messageId, userId, type: type.toUpperCase() });

        // Broadcast to thread
        io.to(`thread:${message.thread_id}`).emit("message:unreacted", {
          messageId,
          type: type.toUpperCase(),
          userId
        });

        cb?.({ ok: true });
      } catch (e) {
        cb?.({ error: e.message });
      }
    });

    // =============================================
    // DELETE FOR EVERYONE (Phase 1)
    // =============================================

    socket.on("message:delete", async ({ messageId }, cb) => {
      try {
        const message = await ChatRepo.getMessageById(messageId);
        if (!message) return cb?.({ error: "message_not_found" });

        const result = await ChatRepo.deleteForEveryone(messageId, userId);

        // Broadcast to thread
        io.to(`thread:${result.thread_id}`).emit("message:deleted", {
          messageId,
          threadId: result.thread_id,
          deletedForAll: true
        });

        cb?.({ ok: true });
      } catch (e) {
        cb?.({ error: e.message });
      }
    });

    // =============================================
    // READ RECEIPTS
    // =============================================

    socket.on("read", async ({ threadId, last_read_message_id }) => {
      try {
        const r = await ChatRepo.markRead({
          threadId,
          userId,
          messageId: Number(last_read_message_id)
        });
        io.to(`thread:${threadId}`).emit("read:updated", {
          userId: r.user_id,
          threadId: r.thread_id,
          last_read_message_id: r.last_read_message_id,
          timestamp: new Date().toISOString()
        });
      } catch { /* ignore */ }
    });

    // =============================================
    // DISCONNECT
    // =============================================

    socket.on("disconnect", () => {
      // Clean up online status
      onlineUsers.delete(socket.id);
      const sockets = userSockets.get(userId);
      if (sockets) {
        sockets.delete(socket.id);
        if (sockets.size === 0) {
          userSockets.delete(userId);
          // User is fully offline
          socket.broadcast.emit("user:offline", {
            userId,
            lastSeen: new Date().toISOString()
          });
        }
      }

      // Clean up typing status
      for (const [threadId, users] of typingUsers.entries()) {
        if (users.has(userId)) {
          users.delete(userId);
          io.to(`thread:${threadId}`).emit("user:typing", {
            threadId,
            userId,
            isTyping: false
          });
        }
      }
    });
  });
}

// Helper to check if user is online
export function isUserOnline(userId) {
  return userSockets.has(userId) && userSockets.get(userId).size > 0;
}

// Helper to get online users count
export function getOnlineUsersCount() {
  return userSockets.size;
}

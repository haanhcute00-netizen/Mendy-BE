// routes/chat.routes.js
import { Router } from "express";
import { auth } from "../../middlewares/auth.js";
import rateLimit from "express-rate-limit";
import {
  startDm,
  sendMessage,
  listMessages,
  listThreads,
  markRead,
  // Phase 1: Reactions
  addReaction,
  removeReaction,
  getReactions,
  getValidReactions,
  // Phase 1: Delete for everyone
  deleteForEveryone,
  // Phase 1: Voice message
  sendVoiceMessage
} from "../chat/chat.controller.js";

const messageLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 20, // max 20 msg/minute
  message: { success: false, error: "Too many messages, please slow down" },
});

const r = Router();

// All routes require authentication
r.use(auth);

// =============================================
// THREAD ROUTES
// =============================================

// Start DM with another user
r.post("/dm/start", startDm);

// List my threads
r.get("/threads", listThreads);

// =============================================
// MESSAGE ROUTES (Phase 1 Enhanced)
// =============================================

// Get messages in a thread (cursor-based: ?before=ISO&limit=30)
r.get("/threads/:id/messages", listMessages);

// Send message to thread (supports reply_to_id, message_type)
r.post("/threads/:id/messages", messageLimiter, sendMessage);

// Send voice message to thread
r.post("/threads/:id/voice", messageLimiter, sendVoiceMessage);

// Mark messages as read
r.post("/threads/:id/read", markRead);

// =============================================
// REACTION ROUTES (Phase 1)
// =============================================

// Get valid reaction types for healing app
r.get("/reactions/types", getValidReactions);

// Add reaction to message
r.post("/messages/:id/react", addReaction);

// Remove reaction from message
r.delete("/messages/:id/react/:type", removeReaction);

// Get all reactions for a message
r.get("/messages/:id/reactions", getReactions);

// =============================================
// DELETE FOR EVERYONE (Phase 1)
// =============================================

// Delete message for everyone (within 24 hours)
r.delete("/messages/:id/everyone", deleteForEveryone);

export default r;

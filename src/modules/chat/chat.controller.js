// src/controllers/chat.controller.js
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, paginated } from "../../utils/response.js";
import * as ChatService from "../chat/chat.service.js";
import { VALID_REACTIONS } from "../chat/chat.repo.js";

// =============================================
// THREAD & DM CONTROLLERS
// =============================================

export const startDm = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const role = req.user.role || "SEEKER";
  const { peer_handle, peer_id } = req.body;

  const t = await ChatService.startDm({
    me,
    role,
    peerHandle: peer_handle,
    peerId: peer_id
  });

  return created(res, "Direct message thread created", { thread_id: t.id });
});

export const listThreads = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { limit = 50, offset = 0 } = req.query;
  const rows = await ChatService.listMyThreads({ me, limit: Number(limit), offset: Number(offset) });
  return paginated(res, "Threads retrieved successfully", rows, {
    limit: Number(limit),
    offset: Number(offset)
  });
});

// =============================================
// MESSAGE CONTROLLERS (Phase 1 Enhanced)
// =============================================

export const sendMessage = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;
  const {
    content,
    reply_to_id,
    message_type = 'TEXT',
    voice_url,
    voice_duration,
    file_url,
    file_name,
    file_size,
    file_mime_type
  } = req.body;

  const msg = await ChatService.sendMessage({
    me,
    threadId: Number(id),
    content,
    replyToId: reply_to_id ? Number(reply_to_id) : null,
    messageType: message_type,
    voiceUrl: voice_url,
    voiceDuration: voice_duration ? Number(voice_duration) : null,
    fileUrl: file_url,
    fileName: file_name,
    fileSize: file_size ? Number(file_size) : null,
    fileMimeType: file_mime_type
  });

  return created(res, "Message sent successfully", { message: msg });
});

export const listMessages = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;
  const { limit = 30, before } = req.query;
  const rows = await ChatService.listThreadMessages({ me, threadId: Number(id), limit: Number(limit), before });
  return paginated(res, "Messages retrieved successfully", rows, {
    limit: Number(limit),
    nextCursor: rows.at(-1)?.created_at
  });
});

export const markRead = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;
  const { last_read_message_id } = req.body;
  const r = await ChatService.markRead({ me, threadId: Number(id), messageId: Number(last_read_message_id) });
  return success(res, "Messages marked as read", r);
});

// =============================================
// REACTION CONTROLLERS (Phase 1)
// =============================================

export const addReaction = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id: messageId } = req.params;
  const { type } = req.body;

  if (!type) {
    return res.status(400).json({
      success: false,
      message: `Reaction type required. Valid types: ${VALID_REACTIONS.join(', ')}`
    });
  }

  const reaction = await ChatService.addReaction({
    me,
    messageId: Number(messageId),
    type: type.toUpperCase()
  });

  return created(res, "Reaction added", { reaction });
});

export const removeReaction = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id: messageId, type } = req.params;

  const result = await ChatService.removeReaction({
    me,
    messageId: Number(messageId),
    type: type.toUpperCase()
  });

  return success(res, "Reaction removed", result);
});

export const getReactions = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id: messageId } = req.params;

  const data = await ChatService.getMessageReactions({
    me,
    messageId: Number(messageId)
  });

  return success(res, "Reactions retrieved", data);
});

// =============================================
// DELETE FOR EVERYONE (Phase 1)
// =============================================

export const deleteForEveryone = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id: messageId } = req.params;

  const result = await ChatService.deleteMessageForEveryone({
    me,
    messageId: Number(messageId)
  });

  return success(res, "Message deleted for everyone", result);
});

// =============================================
// VOICE MESSAGE (Phase 1)
// =============================================

export const sendVoiceMessage = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id: threadId } = req.params;
  const { voice_url, voice_duration, content } = req.body;

  if (!voice_url) {
    return res.status(400).json({
      success: false,
      message: "voice_url is required"
    });
  }

  const msg = await ChatService.sendVoiceMessage({
    me,
    threadId: Number(threadId),
    voiceUrl: voice_url,
    voiceDuration: voice_duration ? Number(voice_duration) : null,
    content
  });

  return created(res, "Voice message sent", { message: msg });
});

// =============================================
// GET VALID REACTIONS (Helper endpoint)
// =============================================

export const getValidReactions = asyncHandler(async (req, res) => {
  const reactions = VALID_REACTIONS.map(type => ({
    type,
    emoji: getReactionEmoji(type),
    meaning: getReactionMeaning(type)
  }));

  return success(res, "Valid reactions for healing app", { reactions });
});

function getReactionEmoji(type) {
  const map = {
    'HUG': '🤗',
    'STRONG': '💪',
    'GRATEFUL': '🙏',
    'SUPPORT': '❤️',
    'UNDERSTOOD': '✨',
    'GROWTH': '🌱'
  };
  return map[type] || '👍';
}

function getReactionMeaning(type) {
  const map = {
    'HUG': 'Om ap, dong cam',
    'STRONG': 'Co vu, manh me',
    'GRATEFUL': 'Biet on',
    'SUPPORT': 'Ung ho, yeu thuong',
    'UNDERSTOOD': 'Da hieu, ghi nhan',
    'GROWTH': 'Tien bo, phat trien'
  };
  return map[type] || '';
}

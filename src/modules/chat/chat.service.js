// src/services/chat.service.js
import * as UsersRepo from "../users/users.repo.js";
import * as ChatRepo from "../chat/chat.repo.js";
import * as BookingsRepo from "../bookings/bookings.repo.js";

function escapeHtml(s) {
  return s.replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

// =============================================
// DM & THREAD FUNCTIONS
// =============================================

export async function startDm({ me, role, peerHandle, peerId }) {
  if (!me) throw Object.assign(new Error("Missing current user"), { status: 401 });

  let peer;
  if (peerId) {
    peer = { id: Number(peerId) };
  } else if (peerHandle) {
    const u = await UsersRepo.getByHandle(peerHandle);
    if (!u) throw Object.assign(new Error("Peer not found"), { status: 404 });
    peer = { id: u.id, role: u.role_primary };
  } else {
    throw Object.assign(new Error("peerHandle or peerId is required"), { status: 400 });
  }

  if (me === peer.id) throw Object.assign(new Error("Cannot DM yourself"), { status: 400 });

  const meRole = role || "SEEKER";
  if (meRole === "SEEKER") {
    let peerRole = peer.role;
    if (!peerRole && peer.id) {
      const found = await UsersRepo.getProfileByUserId(peer.id);
      peerRole = found?.role_primary || "SEEKER";
    }

    if (peerRole === "EXPERT") {
      const hasBooking = await BookingsRepo.hasActiveBooking(me, peer.id);
      if (!hasBooking) {
        throw Object.assign(
          new Error("Ban can co booking dang hoat dong hoac sap toi voi chuyen gia de nhan tin."),
          { status: 403 }
        );
      }
    }
  }

  const t = await ChatRepo.getOrCreateDmThread(me, peer.id);
  return t;
}

export async function listMyThreads({ me, limit = 50, offset = 0 }) {
  return ChatRepo.listThreads(me, limit, offset);
}

// =============================================
// MESSAGE FUNCTIONS (Phase 1 Enhanced)
// =============================================

export async function sendMessage({
  me,
  threadId,
  content,
  replyToId = null,
  messageType = 'TEXT',
  voiceUrl = null,
  voiceDuration = null,
  fileUrl = null,
  fileName = null,
  fileSize = null,
  fileMimeType = null
}) {
  // Validate membership
  const isMem = await ChatRepo.isMember(threadId, me);
  if (!isMem) {
    throw Object.assign(new Error("Forbidden"), { status: 403 });
  }

  // Validate content based on message type
  if (messageType === 'TEXT') {
    const raw = String(content ?? "");
    const cleaned = escapeHtml(raw.trim()).slice(0, 2000);
    if (!cleaned) {
      throw Object.assign(new Error("Message content required"), { status: 400 });
    }
    content = cleaned;
  } else if (messageType === 'VOICE') {
    if (!voiceUrl) {
      throw Object.assign(new Error("Voice URL required for voice message"), { status: 400 });
    }
    content = content || '[Voice message]';
  } else if (messageType === 'IMAGE' || messageType === 'FILE') {
    if (!fileUrl) {
      throw Object.assign(new Error("File URL required"), { status: 400 });
    }
    content = content || `[${messageType}]`;
  }

  // Validate reply_to_id if provided
  if (replyToId) {
    const replyMsg = await ChatRepo.getMessageById(replyToId);
    if (!replyMsg || replyMsg.thread_id !== threadId) {
      throw Object.assign(new Error("Invalid reply message"), { status: 400 });
    }
  }

  return ChatRepo.insertMessage({
    threadId,
    senderId: me,
    content,
    replyToId,
    messageType,
    voiceUrl,
    voiceDuration,
    fileUrl,
    fileName,
    fileSize,
    fileMimeType
  });
}

export async function listThreadMessages({ me, threadId, limit = 30, before }) {
  const isMem = await ChatRepo.isMember(threadId, me);
  if (!isMem) {
    throw Object.assign(new Error("Forbidden"), { status: 403 });
  }

  const messages = await ChatRepo.listMessages({ threadId, limit, before });

  // Attach reactions summary to each message
  for (const msg of messages) {
    msg.reactions = await ChatRepo.getReactionsSummary(msg.id);
  }

  return messages;
}

export async function markRead({ me, threadId, messageId }) {
  const isMem = await ChatRepo.isMember(threadId, me);
  if (!isMem) {
    throw Object.assign(new Error("Forbidden"), { status: 403 });
  }
  return ChatRepo.markRead({ threadId, userId: me, messageId });
}

// =============================================
// REACTION FUNCTIONS (Phase 1)
// =============================================

export async function addReaction({ me, messageId, type }) {
  // Get message to check thread membership
  const message = await ChatRepo.getMessageById(messageId);
  if (!message) {
    throw Object.assign(new Error("Message not found"), { status: 404 });
  }

  const isMem = await ChatRepo.isMember(message.thread_id, me);
  if (!isMem) {
    throw Object.assign(new Error("Forbidden"), { status: 403 });
  }

  const reaction = await ChatRepo.addReaction({ messageId, userId: me, type });
  return {
    ...reaction,
    thread_id: message.thread_id
  };
}

export async function removeReaction({ me, messageId, type }) {
  const message = await ChatRepo.getMessageById(messageId);
  if (!message) {
    throw Object.assign(new Error("Message not found"), { status: 404 });
  }

  const isMem = await ChatRepo.isMember(message.thread_id, me);
  if (!isMem) {
    throw Object.assign(new Error("Forbidden"), { status: 403 });
  }

  const result = await ChatRepo.removeReaction({ messageId, userId: me, type });
  return {
    removed: !!result,
    thread_id: message.thread_id
  };
}

export async function getMessageReactions({ me, messageId }) {
  const message = await ChatRepo.getMessageById(messageId);
  if (!message) {
    throw Object.assign(new Error("Message not found"), { status: 404 });
  }

  const isMem = await ChatRepo.isMember(message.thread_id, me);
  if (!isMem) {
    throw Object.assign(new Error("Forbidden"), { status: 403 });
  }

  const reactions = await ChatRepo.getMessageReactions(messageId);
  const summary = await ChatRepo.getReactionsSummary(messageId);

  return {
    reactions,
    summary,
    total: reactions.length
  };
}

// =============================================
// DELETE FOR EVERYONE (Phase 1)
// =============================================

export async function deleteMessageForEveryone({ me, messageId }) {
  const message = await ChatRepo.getMessageById(messageId);
  if (!message) {
    throw Object.assign(new Error("Message not found"), { status: 404 });
  }

  const isMem = await ChatRepo.isMember(message.thread_id, me);
  if (!isMem) {
    throw Object.assign(new Error("Forbidden"), { status: 403 });
  }

  const result = await ChatRepo.deleteForEveryone(messageId, me);
  return result;
}

// =============================================
// VOICE MESSAGE (Phase 1)
// =============================================

export async function sendVoiceMessage({ me, threadId, voiceUrl, voiceDuration, content = '' }) {
  return sendMessage({
    me,
    threadId,
    content: content || '[Voice message]',
    messageType: 'VOICE',
    voiceUrl,
    voiceDuration
  });
}

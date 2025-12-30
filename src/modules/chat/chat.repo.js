// repositories/chat.repo.js
import { query } from "../../config/db.js";

// Valid reaction types for healing app
export const VALID_REACTIONS = ['HUG', 'STRONG', 'GRATEFUL', 'SUPPORT', 'UNDERSTOOD', 'GROWTH'];

export async function getOrCreateDmThread(userA, userB) {
  if (userA === userB) throw Object.assign(new Error("Cannot DM yourself"), { status: 400 });

  const { rows: found } = await query(
    `SELECT t.id FROM app.chat_threads t
     JOIN app.chat_members m1 ON m1.thread_id = t.id AND m1.user_id = $1
     JOIN app.chat_members m2 ON m2.thread_id = t.id AND m2.user_id = $2
     WHERE t.type = 'DM' LIMIT 1`,
    [userA, userB]
  );
  if (found[0]) return found[0];

  const { rows: t } = await query(
    `INSERT INTO app.chat_threads (type, created_at, last_message_at)
     VALUES ('DM', now(), now()) RETURNING id`
  );
  const threadId = t[0].id;

  await query(
    `INSERT INTO app.chat_members (thread_id, user_id, role_in_thread, joined_at)
     VALUES ($1,$2,'PARTICIPANT', now()), ($1,$3,'PARTICIPANT', now())
     ON CONFLICT DO NOTHING`,
    [threadId, userA, userB]
  );

  return { id: threadId };
}

export async function isMember(threadId, userId) {
  const { rows } = await query(
    `SELECT 1 FROM app.chat_members WHERE thread_id = $1 AND user_id = $2 LIMIT 1`,
    [threadId, userId]
  );
  return !!rows[0];
}

// =============================================
// MESSAGE FUNCTIONS (Phase 1 Enhanced)
// =============================================

export async function insertMessage({
  threadId,
  senderId,
  content,
  replyToId = null,
  messageType = 'TEXT',
  voiceUrl = null,
  voiceDuration = null,
  fileUrl = null,
  fileName = null,
  fileSize = null,
  fileMimeType = null,
  attachments = []
}) {
  const { rows } = await query(
    `INSERT INTO app.chat_messages (
      thread_id, sender_id, content, reply_to_id, message_type,
      voice_url, voice_duration_seconds, file_url, file_name, file_size, file_mime_type,
      created_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, now())
     RETURNING id, thread_id, sender_id, content, reply_to_id, message_type,
               voice_url, voice_duration_seconds, file_url, file_name, file_size, file_mime_type,
               created_at, deleted_for_all`,
    [threadId, senderId, content, replyToId, messageType, voiceUrl, voiceDuration, fileUrl, fileName, fileSize, fileMimeType]
  );
  const message = rows[0];

  if (attachments.length > 0) {
    const values = attachments.map((_, idx) => `($${idx * 5 + 1}, $${idx * 5 + 2}, $${idx * 5 + 3}, $${idx * 5 + 4}, $${idx * 5 + 5})`).join(',');
    const params = [];
    attachments.forEach((file) => {
      params.push(message.id, file.file_name, file.mime_type, file.url, file.size_bytes);
    });
    await query(`INSERT INTO app.chat_attachments (message_id, file_name, mime_type, url, size_bytes) VALUES ${values}`, params);
    message.attachments = attachments;
  }

  await query(`UPDATE app.chat_threads SET last_message_at = now() WHERE id = $1`, [threadId]);
  return message;
}

export async function getMessageById(messageId) {
  const { rows } = await query(
    `SELECT m.*, u.handle as sender_handle, up.display_name as sender_name, up.avatar_url as sender_avatar
     FROM app.chat_messages m
     LEFT JOIN app.users u ON u.id = m.sender_id
     LEFT JOIN app.user_profiles up ON up.user_id = m.sender_id
     WHERE m.id = $1`,
    [messageId]
  );
  return rows[0];
}

export async function listMessages({ threadId, limit = 30, before }) {
  const baseQuery = `
    SELECT m.id, m.thread_id, m.sender_id, m.content, m.reply_to_id, m.message_type,
           m.voice_url, m.voice_duration_seconds, m.file_url, m.file_name,
           m.created_at, m.edited_at, m.deleted_for_all,
           u.handle as sender_handle, up.display_name as sender_name, up.avatar_url as sender_avatar,
           rm.content as reply_content, rm.sender_id as reply_sender_id
    FROM app.chat_messages m
    LEFT JOIN app.users u ON u.id = m.sender_id
    LEFT JOIN app.user_profiles up ON up.user_id = m.sender_id
    LEFT JOIN app.chat_messages rm ON rm.id = m.reply_to_id
    WHERE m.thread_id = $1 AND (m.deleted_for_all = false OR m.deleted_for_all IS NULL)
  `;

  if (before) {
    const { rows } = await query(
      `${baseQuery} AND m.created_at < $2 ORDER BY m.created_at DESC LIMIT $3`,
      [threadId, new Date(before), limit]
    );
    return rows;
  }

  const { rows } = await query(
    `${baseQuery} ORDER BY m.created_at DESC LIMIT $2`,
    [threadId, limit]
  );
  return rows;
}

export async function listThreads(userId, limit = 50, offset = 0) {
  const { rows } = await query(
    `WITH my_threads AS (
      SELECT t.id, t.type, t.last_message_at
      FROM app.chat_threads t
      JOIN app.chat_members m ON m.thread_id = t.id
      WHERE m.user_id = $1
    ),
    last_msg AS (
      SELECT DISTINCT ON (thread_id)
             thread_id, id as message_id, content, sender_id, created_at, message_type, deleted_for_all
      FROM app.chat_messages
      ORDER BY thread_id, created_at DESC
    ),
    peers AS (
      SELECT cm.thread_id, u.id AS peer_id, u.handle, up.display_name, up.avatar_url
      FROM app.chat_members cm
      JOIN app.users u ON u.id = cm.user_id
      LEFT JOIN app.user_profiles up ON up.user_id = u.id
      WHERE cm.thread_id IN (SELECT id FROM my_threads) AND cm.user_id <> $1
    )
    SELECT mt.id, mt.type, mt.last_message_at,
           lm.message_id, 
           CASE WHEN lm.deleted_for_all THEN '[Tin nhan da xoa]' ELSE lm.content END as last_message,
           lm.sender_id, lm.created_at as last_message_at2, lm.message_type,
           p.peer_id, p.handle as peer_handle, p.display_name as peer_name, p.avatar_url as peer_avatar
    FROM my_threads mt
    LEFT JOIN last_msg lm ON lm.thread_id = mt.id
    LEFT JOIN peers p ON p.thread_id = mt.id
    ORDER BY mt.last_message_at DESC
    LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

// =============================================
// REACTION FUNCTIONS (Phase 1)
// =============================================

export async function addReaction({ messageId, userId, type }) {
  if (!VALID_REACTIONS.includes(type)) {
    throw Object.assign(new Error(`Invalid reaction type. Valid: ${VALID_REACTIONS.join(', ')}`), { status: 400 });
  }

  const { rows } = await query(
    `INSERT INTO app.message_reactions (message_id, user_id, type, created_at)
     VALUES ($1, $2, $3, now())
     ON CONFLICT (message_id, user_id, type) DO NOTHING
     RETURNING id, message_id, user_id, type, created_at`,
    [messageId, userId, type]
  );
  return rows[0];
}

export async function removeReaction({ messageId, userId, type }) {
  const { rows } = await query(
    `DELETE FROM app.message_reactions 
     WHERE message_id = $1 AND user_id = $2 AND type = $3
     RETURNING id`,
    [messageId, userId, type]
  );
  return rows[0];
}

export async function getMessageReactions(messageId) {
  const { rows } = await query(
    `SELECT r.type, r.user_id, r.created_at, u.handle, up.display_name, up.avatar_url
     FROM app.message_reactions r
     LEFT JOIN app.users u ON u.id = r.user_id
     LEFT JOIN app.user_profiles up ON up.user_id = r.user_id
     WHERE r.message_id = $1
     ORDER BY r.created_at ASC`,
    [messageId]
  );
  return rows;
}

export async function getReactionsSummary(messageId) {
  const { rows } = await query(
    `SELECT type, COUNT(*) as count
     FROM app.message_reactions
     WHERE message_id = $1
     GROUP BY type`,
    [messageId]
  );
  return rows.reduce((acc, r) => ({ ...acc, [r.type]: parseInt(r.count) }), {});
}

// =============================================
// DELETE FOR EVERYONE (Phase 1)
// =============================================

export async function deleteForEveryone(messageId, userId) {
  // Check if message exists and user is sender
  const { rows: msgRows } = await query(
    `SELECT id, sender_id, created_at FROM app.chat_messages WHERE id = $1`,
    [messageId]
  );

  if (!msgRows[0]) {
    throw Object.assign(new Error("Message not found"), { status: 404 });
  }

  if (msgRows[0].sender_id !== userId) {
    throw Object.assign(new Error("You can only delete your own messages"), { status: 403 });
  }

  // Check if within 24 hours
  const messageTime = new Date(msgRows[0].created_at);
  const now = new Date();
  const hoursDiff = (now - messageTime) / (1000 * 60 * 60);

  if (hoursDiff > 24) {
    throw Object.assign(new Error("Can only delete messages within 24 hours"), { status: 400 });
  }

  const { rows } = await query(
    `UPDATE app.chat_messages 
     SET deleted_for_all = true, deleted_for_all_at = now(), content = '[Tin nhan da bi xoa]'
     WHERE id = $1
     RETURNING id, thread_id, deleted_for_all`,
    [messageId]
  );
  return rows[0];
}

// =============================================
// EXISTING FUNCTIONS
// =============================================

export async function createBookingThread({ bookingId, seekerId, expertId }) {
  const { rows: existing } = await query(
    `SELECT id FROM app.chat_threads WHERE booking_id = $1 LIMIT 1`,
    [bookingId]
  );
  if (existing[0]) return existing[0];

  const { rows: t } = await query(
    `INSERT INTO app.chat_threads (type, booking_id, created_at, last_message_at)
     VALUES ('BOOKING', $1, now(), now()) RETURNING id`,
    [bookingId]
  );
  const threadId = t[0].id;

  await query(
    `INSERT INTO app.chat_members (thread_id, user_id, role_in_thread, joined_at)
     VALUES ($1,$2,'PARTICIPANT', now()), ($1,$3,'PARTICIPANT', now()) ON CONFLICT DO NOTHING`,
    [threadId, seekerId, expertId]
  );
  return { id: threadId };
}

export async function createGroup({ name, ownerId, memberIds = [] }) {
  const { rows: t } = await query(
    `INSERT INTO app.chat_threads (type, name, created_at, last_message_at)
     VALUES ('GROUP', $1, now(), now()) RETURNING id`,
    [name]
  );
  const threadId = t[0].id;

  await query(
    `INSERT INTO app.chat_members (thread_id, user_id, role_in_thread, joined_at)
     VALUES ($1,$2,'OWNER', now()) ON CONFLICT DO NOTHING`,
    [threadId, ownerId]
  );

  for (const uid of memberIds) {
    await query(
      `INSERT INTO app.chat_thread_invitations (thread_id, inviter_id, invitee_id)
       VALUES ($1,$2,$3) ON CONFLICT DO NOTHING`,
      [threadId, ownerId, uid]
    );
  }
  return { id: threadId };
}

export async function inviteToGroup({ threadId, inviterId, inviteeId }) {
  await query(
    `INSERT INTO app.chat_thread_invitations (thread_id, inviter_id, invitee_id)
     VALUES ($1,$2,$3) ON CONFLICT DO NOTHING`,
    [threadId, inviterId, inviteeId]
  );
  return true;
}

export async function acceptGroupInvitation({ invitationId }) {
  await query(
    `UPDATE app.chat_thread_invitations SET status = 'ACCEPTED' WHERE id = $1`,
    [invitationId]
  );
  const { rows } = await query(
    `SELECT thread_id, invitee_id FROM app.chat_thread_invitations WHERE id = $1`,
    [invitationId]
  );
  const inv = rows[0];
  await query(
    `INSERT INTO app.chat_members (thread_id, user_id, role_in_thread, joined_at)
     VALUES ($1,$2,'PARTICIPANT', now()) ON CONFLICT DO NOTHING`,
    [inv.thread_id, inv.invitee_id]
  );
  return true;
}

export async function markRead({ threadId, userId, messageId }) {
  const { rows } = await query(
    `INSERT INTO app.chat_read_state (thread_id, user_id, last_read_message_id, updated_at)
     VALUES ($1,$2,$3, now())
     ON CONFLICT (thread_id, user_id)
     DO UPDATE SET last_read_message_id = GREATEST(EXCLUDED.last_read_message_id, app.chat_read_state.last_read_message_id),
                   updated_at = now()
     RETURNING thread_id, user_id, last_read_message_id, updated_at`,
    [threadId, userId, messageId]
  );
  return rows[0];
}

export async function updateMessage(messageId, { content }) {
  const { rows } = await query(
    `UPDATE app.chat_messages SET content = $1, edited_at = now() WHERE id = $2 RETURNING *`,
    [content, messageId]
  );
  return rows[0];
}

export async function softDeleteMessage(messageId) {
  const { rows } = await query(
    `UPDATE app.chat_messages SET deleted_at = now() WHERE id = $1 RETURNING *`,
    [messageId]
  );
  return rows[0];
}

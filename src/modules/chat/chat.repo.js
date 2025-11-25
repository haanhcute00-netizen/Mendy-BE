// repositories/chat.repo.js
import { query } from "../../config/db.js";


export async function getOrCreateDmThread(userA, userB) {
  // existing implementation unchanged
  if (userA === userB) throw Object.assign(new Error("Cannot DM yourself"), { status: 400 });

  // Tìm thread DM có đúng 2 members này
  const { rows: found } = await query(
    `
    SELECT t.id
    FROM app.chat_threads t
    JOIN app.chat_members m1 ON m1.thread_id = t.id AND m1.user_id = $1
    JOIN app.chat_members m2 ON m2.thread_id = t.id AND m2.user_id = $2
    WHERE t.type = 'DM' LIMIT 1
    `,
    [userA, userB]
  );
  if (found[0]) return found[0];

  // Tạo thread + 2 members (transaction nhẹ nhàng)
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

// Kiểm tra thành viên
export async function isMember(threadId, userId) {
  const { rows } = await query(
    `SELECT 1 FROM app.chat_members WHERE thread_id = $1 AND user_id = $2 LIMIT 1`,
    [threadId, userId]
  );
  return !!rows[0];
}

// Gửi tin nhắn
export async function insertMessage({ threadId, senderId, content, attachments = [] }) {
  const { rows } = await query(
    `INSERT INTO app.chat_messages (thread_id, sender_id, content, created_at)
     VALUES ($1,$2,$3, now())
     RETURNING id, thread_id, sender_id, content, created_at`,
    [threadId, senderId, content]
  );
  const message = rows[0];
  // Insert attachments if any
  if (attachments.length > 0) {
    const values = attachments.map((file, idx) => `($${idx * 5 + 1}, $${idx * 5 + 2}, $${idx * 5 + 3}, $${idx * 5 + 4}, $${idx * 5 + 5})`).join(',');
    const params = [];
    attachments.forEach((file) => {
      params.push(message.id, file.file_name, file.mime_type, file.url, file.size_bytes);
    });
    const insertSql = `INSERT INTO app.chat_attachments (message_id, file_name, mime_type, url, size_bytes) VALUES ${values}`;
    await query(insertSql, params);
    message.attachments = attachments;
  }
  // cập nhật last_message_at
  await query(`UPDATE app.chat_threads SET last_message_at = now() WHERE id = $1`, [threadId]);
  return message;
}

// Lấy messages phân trang (cursor = created_at ISO hoặc message id)
export async function listMessages({ threadId, limit = 30, before }) {
  if (before) {
    const { rows } = await query(
      `SELECT id, thread_id, sender_id, content, created_at
       FROM app.chat_messages
       WHERE thread_id = $1 AND created_at < $2
       ORDER BY created_at DESC
       LIMIT $3`,
      [threadId, new Date(before), limit]
    );
    return rows;
  }
  const { rows } = await query(
    `SELECT id, thread_id, sender_id, content, created_at
     FROM app.chat_messages
     WHERE thread_id = $1
     ORDER BY created_at DESC
     LIMIT $2`,
    [threadId, limit]
  );
  return rows;
}

// Danh sách thread của user + last message + peer basic info
export async function listThreads(userId, limit = 50, offset = 0) {
  const { rows } = await query(
    `
    WITH my_threads AS (
      SELECT t.id, t.type, t.last_message_at
      FROM app.chat_threads t
      JOIN app.chat_members m ON m.thread_id = t.id
      WHERE m.user_id = $1
    ),
    last_msg AS (
      SELECT DISTINCT ON (thread_id)
             thread_id, id as message_id, content, sender_id, created_at
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
           lm.message_id, lm.content as last_message, lm.sender_id, lm.created_at as last_message_at2,
           p.peer_id, p.handle as peer_handle, p.display_name as peer_name, p.avatar_url as peer_avatar
    FROM my_threads mt
    LEFT JOIN last_msg lm ON lm.thread_id = mt.id
    LEFT JOIN peers p ON p.thread_id = mt.id
    ORDER BY mt.last_message_at DESC
    LIMIT $2 OFFSET $3
    `,
    [userId, limit, offset]
  );
  return rows;
}

// Create a thread for a booking (type = 'BOOKING')
export async function createBookingThread({ bookingId, seekerId, expertId }) {
  // Check if thread already exists for this booking
  const { rows: existing } = await query(
    `SELECT id FROM app.chat_threads WHERE booking_id = $1 LIMIT 1`,
    [bookingId]
  );
  if (existing[0]) return existing[0];

  // Create thread
  const { rows: t } = await query(
    `INSERT INTO app.chat_threads (type, booking_id, created_at, last_message_at)
     VALUES ('BOOKING', $1, now(), now()) RETURNING id`,
    [bookingId]
  );
  const threadId = t[0].id;

  // Add members: seeker and expert
  await query(
    `INSERT INTO app.chat_members (thread_id, user_id, role_in_thread, joined_at)
     VALUES ($1,$2,'PARTICIPANT', now()), ($1,$3,'PARTICIPANT', now()) ON CONFLICT DO NOTHING`,
    [threadId, seekerId, expertId]
  );
  return { id: threadId };
}

// Group chat creation
export async function createGroup({ name, ownerId, memberIds = [] }) {
  const { rows: t } = await query(
    `INSERT INTO app.chat_threads (type, name, created_at, last_message_at)
     VALUES ('GROUP', $1, now(), now()) RETURNING id`,
    [name]
  );
  const threadId = t[0].id;
  // Owner as participant
  await query(
    `INSERT INTO app.chat_members (thread_id, user_id, role_in_thread, joined_at)
     VALUES ($1,$2,'OWNER', now()) ON CONFLICT DO NOTHING`,
    [threadId, ownerId]
  );
  // Invite other members
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
  // Update invitation status
  await query(
    `UPDATE app.chat_thread_invitations SET status = 'ACCEPTED' WHERE id = $1`,
    [invitationId]
  );
  // Get invitation details
  const { rows } = await query(
    `SELECT thread_id, invitee_id FROM app.chat_thread_invitations WHERE id = $1`,
    [invitationId]
  );
  const inv = rows[0];
  // Add member to thread
  await query(
    `INSERT INTO app.chat_members (thread_id, user_id, role_in_thread, joined_at)
     VALUES ($1,$2,'PARTICIPANT', now()) ON CONFLICT DO NOTHING`,
    [inv.thread_id, inv.invitee_id]
  );
  return true;
}


// Đánh dấu đã đọc (lưu mức "đọc tới id" theo user & thread)
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

// Update message content (edit)
export async function updateMessage(messageId, { content }) {
  const { rows } = await query(
    `UPDATE app.chat_messages SET content = $1, edited_at = now() WHERE id = $2 RETURNING *`,
    [content, messageId]
  );
  return rows[0];
}

// Soft delete message
export async function softDeleteMessage(messageId) {
  const { rows } = await query(
    `UPDATE app.chat_messages SET deleted_at = now() WHERE id = $1 RETURNING *`,
    [messageId]
  );
  return rows[0];
}

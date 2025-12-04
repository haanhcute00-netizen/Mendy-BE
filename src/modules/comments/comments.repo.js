import { query } from "../../config/db.js";

// ========== COMMENTS ==========
export async function addComment({ postId, authorId, parentId, content, anonymous = true }) {
  const { rows } = await query(
    `INSERT INTO app.comments (post_id, author_id, parent_id, content, anonymous)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, post_id, author_id, parent_id, content, anonymous, created_at`,
    [postId, authorId, parentId ?? null, String(content || "").trim(), anonymous]
  );
  return rows[0];
}

export async function updateComment({ id, authorId, content }) {
  const { rows } = await query(
    `UPDATE app.comments
         SET content = $3, edited = TRUE, updated_at = now()
         WHERE id = $1 AND author_id = $2
         RETURNING id, post_id, author_id, parent_id, content, anonymous, edited, updated_at`,
    [id, authorId, String(content || "").trim()]
  );
  return rows[0];
}

export async function deleteComment({ id, authorId }) {
  const { rowCount } = await query(
    `DELETE FROM app.comments WHERE id = $1 AND author_id = $2`,
    [id, authorId]
  );
  return rowCount > 0;
}

export async function getCommentById(id) {
  const { rows } = await query(
    `SELECT c.*, p.author_id as post_author_id, p.privacy as post_privacy
         FROM app.comments c
         JOIN app.posts p ON p.id = c.post_id
         WHERE c.id = $1`,
    [id]
  );
  return rows[0];
}

export async function listComments({ postId, limit = 50, before }) {
  const params = [postId];
  let cursor = "";
  if (before) {
    params.push(new Date(before));
    cursor = `AND c.created_at < $${params.length}`;
  }

  const { rows } = await query(
    `SELECT c.id, c.post_id, c.author_id, c.parent_id, c.content, 
                c.anonymous, c.edited, c.created_at, c.updated_at,
                u.handle, up.display_name, up.avatar_url,
                (SELECT COUNT(*) FROM app.comment_reactions cr WHERE cr.comment_id = c.id) as reaction_count
         FROM app.comments c
         JOIN app.users u ON u.id = c.author_id
         LEFT JOIN app.user_profiles up ON up.user_id = u.id
         WHERE c.post_id = $1 ${cursor}
         ORDER BY c.created_at DESC
         LIMIT $${params.length + 1}`,
    [...params, limit]
  );
  return rows;
}

// ========== COMMENT REACTIONS ==========
export async function reactComment({ commentId, userId, kind }) {
  const { rows } = await query(
    `INSERT INTO app.comment_reactions (comment_id, user_id, kind)
         VALUES ($1, $2, $3::app.reaction_kind)
         ON CONFLICT (comment_id, user_id)
         DO UPDATE SET kind = EXCLUDED.kind, created_at = now()
         RETURNING comment_id, user_id, kind, created_at`,
    [commentId, userId, kind]
  );
  return rows[0];
}

export async function unreactComment({ commentId, userId }) {
  const { rowCount } = await query(
    `DELETE FROM app.comment_reactions WHERE comment_id = $1 AND user_id = $2`,
    [commentId, userId]
  );
  return rowCount > 0;
}

export async function getCommentReactions(commentId) {
  const { rows } = await query(
    `SELECT kind, COUNT(*) as count
         FROM app.comment_reactions
         WHERE comment_id = $1
         GROUP BY kind`,
    [commentId]
  );
  return rows;
}

export async function getUserReactionOnComment({ commentId, userId }) {
  const { rows } = await query(
    `SELECT kind FROM app.comment_reactions 
         WHERE comment_id = $1 AND user_id = $2`,
    [commentId, userId]
  );
  return rows[0]?.kind || null;
}

// ========== HELPERS ==========
export async function getPostPrivacy(postId) {
  const { rows } = await query(
    `SELECT author_id, privacy FROM app.posts WHERE id = $1`,
    [postId]
  );
  return rows[0];
}

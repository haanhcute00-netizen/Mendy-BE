import * as Comments from "../comments/comments.repo.js";
import * as Follows from "../users/follows.repo.js";

const REACTIONS = new Set(["LIKE", "LOVE", "CARE", "HAHA", "WOW", "SAD", "ANGRY"]);

/**
 * Kiểm tra quyền truy cập post trước khi comment
 */
async function checkPostAccess(postId, userId) {
  const post = await Comments.getPostPrivacy(postId);
  if (!post) {
    throw Object.assign(new Error("Post not found"), { status: 404 });
  }

  const isOwner = post.author_id === Number(userId);

  if (post.privacy === "ONLY_ME" && !isOwner) {
    throw Object.assign(new Error("Cannot comment on private post"), { status: 403 });
  }

  if (post.privacy === "FRIENDS" && !isOwner) {
    const isFollowing = await Follows.isFollower({ followerId: userId, followeeId: post.author_id });
    if (!isFollowing) {
      throw Object.assign(new Error("Cannot comment on this post"), { status: 403 });
    }
  }

  return post;
}

/**
 * Format comment response - ẩn thông tin author nếu anonymous
 */
function formatComment(comment, requesterId) {
  const isOwner = comment.author_id === Number(requesterId);

  // Nếu anonymous và không phải owner, ẩn thông tin author
  if (comment.anonymous && !isOwner) {
    return {
      ...comment,
      handle: null,
      display_name: "Ẩn danh",
      avatar_url: null,
      is_anonymous: true,
      is_owner: false,
      reaction_count: parseInt(comment.reaction_count) || 0
    };
  }

  return {
    ...comment,
    is_anonymous: comment.anonymous,
    is_owner: isOwner,
    reaction_count: parseInt(comment.reaction_count) || 0
  };
}

// ========== CRUD ==========
export async function add({ me, postId, parentId, content, anonymous = true }) {
  // Check post access
  await checkPostAccess(postId, me);

  // Validate parent comment if provided
  if (parentId) {
    const parent = await Comments.getCommentById(parentId);
    if (!parent) {
      throw Object.assign(new Error("Parent comment not found"), { status: 404 });
    }
    if (Number(parent.post_id) !== Number(postId)) {
      throw Object.assign(new Error("Parent comment does not belong to this post"), { status: 400 });
    }
  }

  if (!content || !content.trim()) {
    throw Object.assign(new Error("Content is required"), { status: 400 });
  }

  const comment = await Comments.addComment({
    postId,
    authorId: me,
    parentId,
    content,
    anonymous
  });

  return comment;
}

export async function update({ me, commentId, content }) {
  if (!content || !content.trim()) {
    throw Object.assign(new Error("Content is required"), { status: 400 });
  }

  const comment = await Comments.updateComment({
    id: commentId,
    authorId: me,
    content
  });

  if (!comment) {
    throw Object.assign(new Error("Comment not found or forbidden"), { status: 404 });
  }

  return comment;
}

export async function remove({ me, commentId }) {
  const ok = await Comments.deleteComment({ id: commentId, authorId: me });
  if (!ok) {
    throw Object.assign(new Error("Comment not found or forbidden"), { status: 404 });
  }
  return { deleted: true };
}

export async function list({ me, postId, limit, before }) {
  // Check post access before listing comments
  await checkPostAccess(postId, me);

  const comments = await Comments.listComments({ postId, limit, before });

  // Format each comment based on anonymous status
  return comments.map(c => formatComment(c, me));
}

export async function detail({ me, commentId }) {
  const comment = await Comments.getCommentById(commentId);
  if (!comment) {
    throw Object.assign(new Error("Comment not found"), { status: 404 });
  }

  // Check post access
  await checkPostAccess(comment.post_id, me);

  // Get user reaction
  const userReaction = await Comments.getUserReactionOnComment({
    commentId,
    userId: me
  });

  // Get reaction breakdown
  const reactions = await Comments.getCommentReactions(commentId);

  return {
    ...formatComment(comment, me),
    user_reaction: userReaction,
    reactions: reactions.reduce((acc, r) => {
      acc[r.kind] = parseInt(r.count);
      return acc;
    }, {})
  };
}

// ========== REACTIONS ==========
export async function react({ me, commentId, kind }) {
  kind = String(kind || "").toUpperCase();
  if (!REACTIONS.has(kind)) {
    throw Object.assign(new Error("Invalid reaction kind"), { status: 400 });
  }

  // Check comment exists
  const comment = await Comments.getCommentById(commentId);
  if (!comment) {
    throw Object.assign(new Error("Comment not found"), { status: 404 });
  }

  // Check post access
  await checkPostAccess(comment.post_id, me);

  return Comments.reactComment({ commentId, userId: me, kind });
}

export async function unreact({ me, commentId }) {
  const removed = await Comments.unreactComment({ commentId, userId: me });
  return { removed };
}

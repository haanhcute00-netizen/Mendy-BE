import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, paginated } from "../../utils/response.js";
import * as CommentsService from "../comments/comments.service.js";

export const add = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { post_id, parent_id, content, anonymous } = req.body;

  // Parse parent_id - handle empty string, null, undefined, "null"
  let parsedParentId = null;
  if (parent_id && parent_id !== "null" && parent_id !== "") {
    const num = Number(parent_id);
    if (!isNaN(num) && num > 0) {
      parsedParentId = num;
    }
  }

  const comment = await CommentsService.add({
    me,
    postId: Number(post_id),
    parentId: parsedParentId,
    content,
    anonymous: anonymous !== false // default true
  });

  return created(res, "Comment added successfully", comment);
});

export const update = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;
  const { content } = req.body;

  const comment = await CommentsService.update({
    me,
    commentId: Number(id),
    content
  });

  return success(res, "Comment updated successfully", comment);
});

export const remove = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;

  const result = await CommentsService.remove({
    me,
    commentId: Number(id)
  });

  return success(res, "Comment removed successfully", result);
});

export const list = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { post_id, limit = 50, before } = req.query;

  if (!post_id) {
    return res.status(400).json({
      success: false,
      message: "post_id is required"
    });
  }

  const comments = await CommentsService.list({
    me,
    postId: Number(post_id),
    limit: Number(limit),
    before
  });

  return paginated(res, "Comments retrieved successfully", comments, {
    limit: Number(limit),
    nextCursor: comments.at(-1)?.created_at
  });
});

export const detail = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;

  const comment = await CommentsService.detail({
    me,
    commentId: Number(id)
  });

  return success(res, "Comment retrieved successfully", comment);
});

export const react = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;
  const { kind } = req.body;

  const reaction = await CommentsService.react({
    me,
    commentId: Number(id),
    kind
  });

  return created(res, "Reaction added successfully", reaction);
});

export const unreact = asyncHandler(async (req, res) => {
  const me = req.user.id;
  const { id } = req.params;

  const result = await CommentsService.unreact({
    me,
    commentId: Number(id)
  });

  return success(res, "Reaction removed successfully", result);
});

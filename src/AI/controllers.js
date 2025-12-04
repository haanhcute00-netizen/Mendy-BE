import { handleChat } from './aiCore.js';
import { findExpertsByKeywordsSmart } from "./database/expert.js";
import { getAIChatHistory, clearAIChatHistory } from "./database.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const chat = asyncHandler(async (req, res) => {
  const { message } = req.body;
  const userId = req.user.id;

  if (!message) {
    return res.status(400).json({ error: 'message is required' });
  }

  const response = await handleChat(userId, message);
  res.status(200).json(response);
});

// GET /api/v1/ai/history - Lấy lịch sử chat với AI
export const getChatHistory = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const limit = parseInt(req.query.limit) || 50;

  const history = await getAIChatHistory(userId, limit);
  res.json({
    success: true,
    data: history,
    count: history.length
  });
});

// DELETE /api/v1/ai/history - Xóa lịch sử chat
export const deleteChatHistory = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const deleted = await clearAIChatHistory(userId);
  res.json({
    success: true,
    message: `Đã xóa ${deleted} tin nhắn`,
    deleted
  });
});

export const smartMatch = asyncHandler(async (req, res) => {
  const { keywords } = req.body;

  if (!keywords || !Array.isArray(keywords) || keywords.length === 0) {
    return res.status(400).json({
      error: 'keywords array is required and must not be empty'
    });
  }

  const result = await findExpertsByKeywordsSmart(keywords);

  res.json({
    message: "Smart expert matching success",
    matchedKeywords: result.matchedKeywords,
    experts: result.experts
  });
});

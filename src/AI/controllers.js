import { handleChat } from './aiCore.js';
import { findExpertsByKeywordsSmart } from "./database/expert.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const chat = asyncHandler(async (req, res) => {
  const { message } = req.body;
  const userId = req.user.id; // Get userId from authenticated user

  if (!message) {
    return res.status(400).json({ error: 'message is required' });
  }

  const response = await handleChat(userId, message);
  res.status(200).json(response);
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

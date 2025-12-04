import express from 'express';
import { chat, smartMatch, getChatHistory, deleteChatHistory } from './controllers.js';
import { auth } from "../middlewares/auth.js";

const router = express.Router();

// Chat với AI
router.post('/chat', auth, chat);

// Lịch sử chat với AI
router.get('/history', auth, getChatHistory);
router.delete('/history', auth, deleteChatHistory);

// Smart match experts
router.post("/smart-match", auth, smartMatch);

export default router;
import express from 'express';
import { chat,smartMatch  } from './controllers.js';
import { auth } from "../middlewares/auth.js";

const router = express.Router();

router.post('/chat', auth, chat);

router.post("/smart-match", auth, smartMatch);

export default router;
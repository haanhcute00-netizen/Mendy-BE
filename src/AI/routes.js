import express from 'express';
import { chat } from './controllers.js';
import { auth } from "../middlewares/auth.js";

const router = express.Router();

router.post('/chat', auth, chat);

export default router;
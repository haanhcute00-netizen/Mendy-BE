// =============================================
// AI MODULE - SHARED CONFIGURATION (Task 5)
// =============================================

import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";
dotenv.config();

// ========== GEMINI MODEL CONFIG ==========
export const GEMINI_MODEL = process.env.GEMINI_MODEL || "gemini-2.5-flash";
export const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Validate API key
if (!GEMINI_API_KEY) {
    console.warn("⚠️ GEMINI_API_KEY not set in environment variables");
}

// ========== SHARED GEMINI INSTANCE ==========
let genAI = null;
let sharedModel = null;

export const getGenAI = () => {
    if (!genAI && GEMINI_API_KEY) {
        genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
    }
    return genAI;
};

export const getGeminiModel = () => {
    if (!sharedModel) {
        const ai = getGenAI();
        if (ai) {
            sharedModel = ai.getGenerativeModel({ model: GEMINI_MODEL });
        }
    }
    return sharedModel;
};

// ========== AI LIMITS CONFIG ==========
export const AI_LIMITS = {
    MAX_MESSAGE_LENGTH: 5000,
    MAX_NICKNAME_LENGTH: 50,
    MAX_CHAT_HISTORY: 50,
    MAX_EMOTION_TEXT: 1000,
    GEMINI_TIMEOUT_MS: 10000,
};

// ========== RATE LIMIT CONFIG ==========
export const RATE_LIMIT_CONFIG = {
    user: {
        maxRequests: 30,
        windowMs: 60 * 1000,
        maxDaily: 500
    },
    global: {
        maxRequests: 1000,
        windowMs: 60 * 1000,
        maxDaily: 50000
    },
    emotion: {
        maxRequests: 60,
        windowMs: 60 * 1000
    }
};

export default {
    GEMINI_MODEL,
    GEMINI_API_KEY,
    getGenAI,
    getGeminiModel,
    AI_LIMITS,
    RATE_LIMIT_CONFIG
};

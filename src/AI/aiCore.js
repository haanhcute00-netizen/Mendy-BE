import { buildPrompt, buildPromptWithPersona } from "./prompt.js";
import { getRecentAIChatForPrompt, saveAIChatMessage, getAIChatHistory, clearAIChatHistory } from "./database.js";
import { findExpertsByKeywordsSmart } from "./database/expert.js";
import { GoogleGenerativeAI } from "@google/generative-ai";
import * as personaService from "../modules/ai-companion/persona/persona.service.js";
import * as emotionService from "../modules/ai-companion/emotion/emotion.service.js";

import dotenv from "dotenv";
dotenv.config();

// Khởi tạo Gemini với thư viện chính thức
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
// Sử dụng model gemini-2.0-flash (hoặc gemini-pro nếu không có)
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

export const handleChat = async (userId, userMessage) => {
    try {
        // Get recent AI chat history for context
        const conversationHistory = await getRecentAIChatForPrompt(userId, 10);

        // Save user message to history
        let personaId = null;

        // Get user's persona settings
        let personaPrompt = '';
        try {
            const settings = await personaService.getUserSettings(userId);
            if (settings?.persona_id) {
                personaId = settings.persona_id;
                const userContext = await personaService.getUserContext(userId);
                personaPrompt = personaService.buildPersonaPrompt(
                    {
                        display_name: settings.persona_display_name,
                        tone: settings.persona_tone,
                        description: settings.persona_name,
                        emotion_pattern: settings.emotion_pattern,
                        signature_messages: settings.signature_messages
                    },
                    settings,
                    userContext
                );
            }
        } catch (err) {
            console.log("Persona loading skipped:", err.message);
        }

        // Save user message
        await saveAIChatMessage(userId, 'user', userMessage, { persona_id: personaId });

        const prompt = buildPromptWithPersona(conversationHistory, userMessage, personaPrompt);

        // Sử dụng thư viện @google/generative-ai thay vì fetch API
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const aiRaw = response.text();

        console.log("===== RAW GEMINI RESPONSE =====");
        console.log(aiRaw);
        console.log("================================");

        if (!aiRaw) {
            return {
                aiMessage: "Mình rất tiếc, hiện mình chưa thể phản hồi ngay lúc này. Bạn cứ bình tĩnh một chút nhé, mình sẽ quay lại với bạn sớm nhất có thể.",
                suggestions: { experts: [] },
            };
        }

        // ==============================
        // 1. Parse JSON từ AI
        // ==============================
        let clean = aiRaw.trim();

        // Xóa ```json  và ```
        clean = clean.replace(/```json/gi, "");
        clean = clean.replace(/```/g, "");

        // Xóa ký tự lạ ngoài JSON
        clean = clean.trim();

        let aiJSON;
        try {
            aiJSON = JSON.parse(clean);
        } catch (err) {
            console.log("❌ JSON parse error - CLEAN FAILED");
            console.log("AI RAW CLEANED:", clean);
            return {
                aiMessage: aiRaw,
                suggestions: { experts: [] },
            };
        }

        const aiMessage = aiJSON.response;
        const keywords = aiJSON.keywords || [];

        // ==============================
        // 2. Query expert từ DB theo keywords
        // ==============================
        let experts = [];
        let matchedKeywords = [];

        if (keywords.length > 0) {
            const result = await findExpertsByKeywordsSmart(keywords);
            experts = result.experts;
            matchedKeywords = result.matchedKeywords;
        }



        // ==============================
        // 3. Detect and log emotion (async, non-blocking)
        // ==============================
        try {
            emotionService.detectAndLogEmotion(userId, userMessage, 'chat', { useAI: false })
                .catch(err => console.log("Emotion logging failed:", err.message));
        } catch (err) {
            console.log("Emotion detection skipped:", err.message);
        }

        // ==============================
        // 4. Save AI response to history
        // ==============================
        await saveAIChatMessage(userId, 'ai', aiMessage, {
            persona_id: personaId,
            keywords: matchedKeywords
        });

        // ==============================
        // 5. Trả response
        // ==============================
        return {
            aiMessage,
            suggestions: {
                experts,
                keywords: matchedKeywords
            }
        };



    } catch (error) {
        console.error("Error in AI Core Service:", error);

        return {
            aiMessage:
                "Xin lỗi, tôi đang gặp sự cố khi xử lý yêu cầu. Bạn có thể thử lại sau?",
            suggestions: { experts: [] },
        };
    }
};

import { buildPrompt } from "./prompt.js";
import { getRecentChatHistory, findExpertsByKeywords } from "./database.js";
import dotenv from "dotenv";
dotenv.config();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

export const handleChat = async (userId, userMessage) => {
    try {
        const conversationHistory = await getRecentChatHistory(userId);
        const prompt = buildPrompt(conversationHistory, userMessage);

        const GEMINI_URL =
            "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";

        const response = await fetch(`${GEMINI_URL}?key=${GEMINI_API_KEY}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                contents: [
                    {
                        parts: [{ text: prompt }],
                    },
                ],
            }),
        });

        const data = await response.json();

        console.log("===== RAW GEMINI RESPONSE =====");
        console.log(JSON.stringify(data, null, 2));
        console.log("================================");

        const aiRaw =
            data?.candidates?.[0]?.content?.parts?.[0]?.text ?? null;

        if (!aiRaw) {
            return {
                aiMessage: "Xin lỗi, tôi chưa thể trả lời lúc này.",
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
        if (keywords.length > 0) {
            experts = await findExpertsByKeywords(keywords);
        }

        // ==============================
        // 3. Trả response
        // ==============================
        return {
            aiMessage,
            suggestions: {
                experts,
                keywords,
            },
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

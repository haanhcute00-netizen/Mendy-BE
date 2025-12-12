import { buildPrompt, buildPromptWithPersona } from "./prompt.js";
import { getRecentAIChatForPrompt, saveAIChatMessage, getAIChatHistory, clearAIChatHistory } from "./database.js";
import { findExpertsByKeywordsSmart } from "./database/expert.js";
import * as personaService from "./companion/persona/persona.service.js";
import * as emotionService from "./companion/emotion/emotion.service.js";
import { logChatInteraction, logGeminiRequest, logGeminiResponse, logGeminiError } from "./aiLogger.js";
import { checkGeminiRateLimit, recordGeminiRequest } from "./rateLimiter.js";
import { v4 as uuidv4 } from 'uuid';
import { createChildLogger } from "../utils/logger.js";
// Task 5: Use shared AI config
import { getGeminiModel, GEMINI_MODEL, AI_LIMITS } from "./config.js";

// Create logger for AI Core
const logger = createChildLogger({ module: 'ai-core' });

// Task 5: Use shared Gemini model
const getModel = () => getGeminiModel();

// ========== INPUT VALIDATION (Task 1) ==========
const MAX_MESSAGE_LENGTH = AI_LIMITS.MAX_MESSAGE_LENGTH;

const validateChatInput = (userId, userMessage) => {
    // Validate userId
    if (userId === undefined || userId === null) {
        return { valid: false, error: 'userId is required' };
    }
    if (typeof userId !== 'number' || userId <= 0 || !Number.isInteger(userId)) {
        return { valid: false, error: 'userId must be a positive integer' };
    }

    // Validate userMessage
    if (!userMessage) {
        return { valid: false, error: 'userMessage is required' };
    }
    if (typeof userMessage !== 'string') {
        return { valid: false, error: 'userMessage must be a string' };
    }

    // Trim and check empty
    const trimmed = userMessage.trim();
    if (trimmed.length === 0) {
        return { valid: false, error: 'userMessage cannot be empty' };
    }

    // Check max length
    if (trimmed.length > MAX_MESSAGE_LENGTH) {
        return { valid: false, error: `userMessage exceeds maximum length of ${MAX_MESSAGE_LENGTH} characters` };
    }

    return { valid: true, sanitizedMessage: trimmed };
};

const sanitizeInput = (text) => {
    // Remove potential injection patterns
    return text
        .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '') // Remove control characters
        .trim();
};

// Task 5: Removed - now using shared config from ./config.js

export const handleChat = async (userId, userMessage) => {
    const startTime = Date.now();
    const requestId = uuidv4();

    try {
        // Task 1: Validate input
        const validation = validateChatInput(userId, userMessage);
        if (!validation.valid) {
            return {
                aiMessage: "Xin lỗi, tin nhắn không hợp lệ. Vui lòng thử lại.",
                suggestions: { experts: [] },
                error: validation.error
            };
        }

        // Sanitize the message
        userMessage = sanitizeInput(validation.sanitizedMessage);

        // Check rate limit before processing
        const rateLimitCheck = await checkGeminiRateLimit(userId, 'chat');
        if (!rateLimitCheck.allowed) {
            return {
                aiMessage: rateLimitCheck.reason === 'user_daily_limit'
                    ? "Bạn đã đạt giới hạn sử dụng AI trong ngày. Vui lòng thử lại vào ngày mai nhé!"
                    : "Mình đang bận một chút, bạn thử lại sau vài giây nhé!",
                suggestions: { experts: [] },
                rateLimited: true,
                retryAfter: rateLimitCheck.retryAfter
            };
        }

        // Get recent AI chat history for context
        const conversationHistory = await getRecentAIChatForPrompt(userId, 10);

        // Save user message to history
        let personaId = null;
        let relationshipLevel = 1;

        // Get user's persona settings
        let personaPrompt = '';
        try {
            const settings = await personaService.getUserSettings(userId);
            if (settings?.persona_id) {
                personaId = settings.persona_id;
                relationshipLevel = settings.relationship_level || 1;
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
            // Task 2: Use logger instead of console.log
            logger.debug("Persona loading skipped:", err.message);
        }

        // Save user message
        await saveAIChatMessage(userId, 'user', userMessage, { persona_id: personaId });

        const prompt = buildPromptWithPersona(conversationHistory, userMessage, personaPrompt);

        // Log Gemini request - Task 5: Use shared model name
        logGeminiRequest(requestId, { prompt_length: prompt.length, model: GEMINI_MODEL });

        // Record rate limit
        await recordGeminiRequest(userId, 'chat');

        // Task 5: Use shared Gemini model
        const model = getModel();
        if (!model) {
            logger.error("Gemini model not available");
            return {
                aiMessage: "Xin lỗi, hệ thống AI đang bảo trì. Vui lòng thử lại sau.",
                suggestions: { experts: [] },
            };
        }

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const aiRaw = response.text();

        // Log Gemini response
        logGeminiResponse(requestId, {
            response_length: aiRaw?.length || 0,
            duration_ms: Date.now() - startTime,
            success: true
        });

        // Task 2: Replace console.log with logger.debug (only in development)
        if (process.env.NODE_ENV !== 'production') {
            const logPreview = aiRaw?.substring(0, 500) || '';
            logger.debug(`Gemini response preview: ${logPreview}${aiRaw?.length > 500 ? '...[truncated]' : ''}`);
        }

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
            // Task 2: Use logger instead of console.log
            logger.warn("JSON parse error - CLEAN FAILED", {
                preview: clean.substring(0, 200),
                requestId
            });
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
        // Task 2: Use logger instead of console.log
        try {
            emotionService.detectAndLogEmotion(userId, userMessage, 'chat', { useAI: false })
                .catch(err => logger.debug("Emotion logging failed:", err.message));
        } catch (err) {
            logger.debug("Emotion detection skipped:", err.message);
        }

        // ==============================
        // 4. Save AI response to history
        // ==============================
        await saveAIChatMessage(userId, 'ai', aiMessage, {
            persona_id: personaId,
            keywords: matchedKeywords
        });

        // ==============================
        // 5. Log interaction and return response
        // ==============================
        const duration = Date.now() - startTime;
        logChatInteraction(userId, {
            userMessage,
            aiResponse: aiMessage,
            keywords: matchedKeywords,
            personaId,
            duration
        });

        return {
            aiMessage,
            suggestions: {
                experts,
                keywords: matchedKeywords
            },
            meta: {
                duration,
                relationshipLevel
            }
        };

    } catch (error) {
        // Task 2: Use logger instead of console.error
        logger.error("Error in AI Core Service:", { error: error.message, stack: error.stack });

        // Log error
        logGeminiError(requestId, {
            error,
            prompt_preview: userMessage
        });

        return {
            aiMessage:
                "Xin lỗi, tôi đang gặp sự cố khi xử lý yêu cầu. Bạn có thể thử lại sau?",
            suggestions: { experts: [] },
        };
    }
};

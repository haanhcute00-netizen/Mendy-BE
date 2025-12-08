// =============================================
// AI INTERACTION LOGGER
// Logging system for AI interactions
// =============================================

import { logger, createChildLogger } from '../utils/logger.js';

// Create child logger for AI interactions
const aiLogger = createChildLogger({ module: 'ai-companion' });

// ========== AI INTERACTION LOGGING ==========

export const logAIInteraction = (userId, type, data) => {
    aiLogger.info({
        type: 'ai_interaction',
        interaction_type: type,
        user_id: userId,
        ...data,
        timestamp: new Date().toISOString()
    });
};

export const logChatInteraction = (userId, { userMessage, aiResponse, keywords, personaId, duration }) => {
    aiLogger.info({
        type: 'ai_chat',
        user_id: userId,
        message_length: userMessage?.length || 0,
        response_length: aiResponse?.length || 0,
        keywords_count: keywords?.length || 0,
        persona_id: personaId,
        duration_ms: duration,
        timestamp: new Date().toISOString()
    });
};

export const logEmotionDetection = (userId, { emotion, intensity, confidence, source }) => {
    aiLogger.info({
        type: 'emotion_detection',
        user_id: userId,
        emotion,
        intensity,
        confidence,
        source,
        timestamp: new Date().toISOString()
    });
};

export const logPersonaSelection = (userId, { personaId, personaName }) => {
    aiLogger.info({
        type: 'persona_selection',
        user_id: userId,
        persona_id: personaId,
        persona_name: personaName,
        timestamp: new Date().toISOString()
    });
};

export const logMentalStateUpdate = (userId, { previousState, newState, trigger }) => {
    aiLogger.info({
        type: 'mental_state_update',
        user_id: userId,
        previous_mood: previousState?.current_mood,
        new_mood: newState?.current_mood,
        stress_level: newState?.stress_level,
        anxiety_level: newState?.anxiety_level,
        trigger,
        timestamp: new Date().toISOString()
    });
};

export const logAssessmentCreated = (userId, { riskLevel, burnoutScore, recommendations }) => {
    aiLogger.info({
        type: 'assessment_created',
        user_id: userId,
        risk_level: riskLevel,
        burnout_score: burnoutScore,
        recommendations_count: recommendations?.length || 0,
        timestamp: new Date().toISOString()
    });
};

export const logScheduleCreated = (userId, { scheduleType, aiGenerated, title }) => {
    aiLogger.info({
        type: 'schedule_created',
        user_id: userId,
        schedule_type: scheduleType,
        ai_generated: aiGenerated,
        title,
        timestamp: new Date().toISOString()
    });
};

export const logNotificationSent = (userId, { notificationType, personaId }) => {
    aiLogger.info({
        type: 'notification_sent',
        user_id: userId,
        notification_type: notificationType,
        persona_id: personaId,
        timestamp: new Date().toISOString()
    });
};

export const logCrisisDetected = (userId, { text, indicators }) => {
    aiLogger.warn({
        type: 'crisis_detected',
        user_id: userId,
        text_preview: text?.substring(0, 100),
        indicators,
        timestamp: new Date().toISOString()
    });
};

// ========== GEMINI API LOGGING ==========

export const logGeminiRequest = (requestId, { prompt_length, model }) => {
    aiLogger.debug({
        type: 'gemini_request',
        request_id: requestId,
        prompt_length,
        model,
        timestamp: new Date().toISOString()
    });
};

export const logGeminiResponse = (requestId, { response_length, duration_ms, success }) => {
    aiLogger.debug({
        type: 'gemini_response',
        request_id: requestId,
        response_length,
        duration_ms,
        success,
        timestamp: new Date().toISOString()
    });
};

export const logGeminiError = (requestId, { error, prompt_preview }) => {
    aiLogger.error({
        type: 'gemini_error',
        request_id: requestId,
        error: error?.message || error,
        prompt_preview: prompt_preview?.substring(0, 200),
        timestamp: new Date().toISOString()
    });
};

// ========== RATE LIMIT LOGGING ==========

export const logRateLimitHit = (userId, { endpoint, limit, window }) => {
    aiLogger.warn({
        type: 'rate_limit_hit',
        user_id: userId,
        endpoint,
        limit,
        window,
        timestamp: new Date().toISOString()
    });
};

export default {
    logAIInteraction,
    logChatInteraction,
    logEmotionDetection,
    logPersonaSelection,
    logMentalStateUpdate,
    logAssessmentCreated,
    logScheduleCreated,
    logNotificationSent,
    logCrisisDetected,
    logGeminiRequest,
    logGeminiResponse,
    logGeminiError,
    logRateLimitHit
};

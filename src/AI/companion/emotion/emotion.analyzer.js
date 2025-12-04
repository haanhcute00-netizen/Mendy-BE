// =============================================
// AI COMPANION - EMOTION ANALYZER
// Phân tích cảm xúc từ text sử dụng Gemini
// =============================================

import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

// ========== EMOTION KEYWORDS (Fallback) ==========

const EMOTION_KEYWORDS = {
    happy: ['vui', 'hạnh phúc', 'tuyệt vời', 'tốt', 'hay', 'thích', 'yêu', 'cảm ơn', 'biết ơn', 'hài lòng', 'phấn khởi', 'happy', 'great', 'good', 'love', 'thanks'],
    sad: ['buồn', 'khóc', 'đau', 'mất', 'cô đơn', 'trống rỗng', 'thất vọng', 'sad', 'cry', 'lonely', 'empty', 'disappointed', 'miss'],
    anxious: ['lo', 'lo lắng', 'sợ', 'bất an', 'hồi hộp', 'căng thẳng', 'anxious', 'worried', 'afraid', 'nervous', 'scared'],
    stressed: ['stress', 'áp lực', 'mệt', 'kiệt sức', 'quá tải', 'deadline', 'stressed', 'pressure', 'exhausted', 'overwhelmed', 'tired'],
    angry: ['tức', 'giận', 'bực', 'khó chịu', 'ghét', 'angry', 'mad', 'annoyed', 'hate', 'frustrated'],
    excited: ['hào hứng', 'phấn khích', 'háo hức', 'nóng lòng', 'excited', 'thrilled', 'eager'],
    tired: ['mệt', 'uể oải', 'kiệt sức', 'buồn ngủ', 'tired', 'sleepy', 'exhausted', 'drained'],
    neutral: ['bình thường', 'ổn', 'được', 'okay', 'fine', 'normal', 'so so']
};

const NEGATIVE_EMOTIONS = ['sad', 'anxious', 'stressed', 'angry', 'tired'];
const POSITIVE_EMOTIONS = ['happy', 'excited'];

// ========== SIMPLE KEYWORD-BASED ANALYSIS ==========

export const analyzeEmotionSimple = (text) => {
    const lowerText = text.toLowerCase();
    const scores = {};

    for (const [emotion, keywords] of Object.entries(EMOTION_KEYWORDS)) {
        let score = 0;
        for (const keyword of keywords) {
            if (lowerText.includes(keyword)) {
                score += 1;
            }
        }
        if (score > 0) {
            scores[emotion] = score;
        }
    }

    if (Object.keys(scores).length === 0) {
        return { emotion: 'neutral', intensity: 0.3, confidence: 0.3 };
    }

    // Get emotion with highest score
    const topEmotion = Object.entries(scores).sort((a, b) => b[1] - a[1])[0];
    const intensity = Math.min(topEmotion[1] / 3, 1); // Normalize to 0-1

    return {
        emotion: topEmotion[0],
        intensity: intensity,
        confidence: 0.5,
        all_scores: scores
    };
};

// ========== AI-BASED ANALYSIS ==========

const EMOTION_ANALYSIS_PROMPT = `
Phân tích cảm xúc từ đoạn text sau. Trả về JSON với format:
{
    "emotion": "happy|sad|anxious|stressed|angry|excited|tired|neutral",
    "intensity": 0.0-1.0,
    "confidence": 0.0-1.0,
    "secondary_emotions": ["emotion1", "emotion2"],
    "indicators": ["từ/cụm từ gợi ý cảm xúc"],
    "is_crisis": true/false,
    "needs_support": true/false
}

Quy tắc:
- emotion: cảm xúc chính
- intensity: mức độ mạnh (0=nhẹ, 1=rất mạnh)
- confidence: độ tin cậy của phân tích
- is_crisis: true nếu có dấu hiệu tự hại, tự tử
- needs_support: true nếu cần hỗ trợ ngay

CHỈ TRẢ VỀ JSON, KHÔNG GIẢI THÍCH.

Text cần phân tích:
`;

export const analyzeEmotionAI = async (text) => {
    try {
        const prompt = EMOTION_ANALYSIS_PROMPT + `"${text}"`;
        const result = await model.generateContent(prompt);
        const response = result.response;
        const aiRaw = response.text();

        // Clean and parse JSON
        let clean = aiRaw.trim()
            .replace(/```json/gi, '')
            .replace(/```/g, '')
            .trim();

        const analysis = JSON.parse(clean);

        return {
            emotion: analysis.emotion || 'neutral',
            intensity: analysis.intensity || 0.5,
            confidence: analysis.confidence || 0.7,
            secondary_emotions: analysis.secondary_emotions || [],
            indicators: analysis.indicators || [],
            is_crisis: analysis.is_crisis || false,
            needs_support: analysis.needs_support || false,
            source: 'ai'
        };
    } catch (error) {
        console.error('AI emotion analysis failed, using fallback:', error.message);
        // Fallback to simple analysis
        return {
            ...analyzeEmotionSimple(text),
            source: 'fallback'
        };
    }
};

// ========== COMBINED ANALYSIS ==========

export const analyzeEmotion = async (text, useAI = true) => {
    if (!text || text.trim().length < 3) {
        return { emotion: 'neutral', intensity: 0.1, confidence: 0.1 };
    }

    // Quick check for crisis keywords first
    const crisisKeywords = ['tự tử', 'tự sát', 'chết', 'kết thúc', 'suicide', 'kill myself', 'end it'];
    const lowerText = text.toLowerCase();
    const isCrisis = crisisKeywords.some(k => lowerText.includes(k));

    if (isCrisis) {
        return {
            emotion: 'sad',
            intensity: 1.0,
            confidence: 1.0,
            is_crisis: true,
            needs_support: true,
            source: 'crisis_detection'
        };
    }

    // Use AI if enabled and text is substantial
    if (useAI && text.length > 10) {
        return await analyzeEmotionAI(text);
    }

    // Otherwise use simple analysis
    return {
        ...analyzeEmotionSimple(text),
        source: 'simple'
    };
};

// ========== EMOTION TREND ANALYSIS ==========

export const analyzeEmotionTrend = (emotionLogs) => {
    if (!emotionLogs || emotionLogs.length < 3) {
        return { trend: 'insufficient_data', change: 0 };
    }

    // Split into recent and older
    const midpoint = Math.floor(emotionLogs.length / 2);
    const recent = emotionLogs.slice(0, midpoint);
    const older = emotionLogs.slice(midpoint);

    // Calculate average mood scores
    const moodScore = (emotion) => {
        const scores = {
            happy: 1, excited: 0.9, neutral: 0.5,
            tired: 0.3, anxious: 0.2, stressed: 0.2, sad: 0.1, angry: 0.1
        };
        return scores[emotion] || 0.5;
    };

    const recentAvg = recent.reduce((sum, log) => sum + moodScore(log.emotion), 0) / recent.length;
    const olderAvg = older.reduce((sum, log) => sum + moodScore(log.emotion), 0) / older.length;

    const change = recentAvg - olderAvg;

    let trend;
    if (change > 0.2) trend = 'improving';
    else if (change < -0.2) trend = 'declining';
    else trend = 'stable';

    return {
        trend,
        change: Math.round(change * 100) / 100,
        recent_avg: Math.round(recentAvg * 100) / 100,
        older_avg: Math.round(olderAvg * 100) / 100
    };
};

// ========== HELPERS ==========

export const isNegativeEmotion = (emotion) => NEGATIVE_EMOTIONS.includes(emotion);
export const isPositiveEmotion = (emotion) => POSITIVE_EMOTIONS.includes(emotion);

export const getEmotionCategory = (emotion) => {
    if (POSITIVE_EMOTIONS.includes(emotion)) return 'positive';
    if (NEGATIVE_EMOTIONS.includes(emotion)) return 'negative';
    return 'neutral';
};

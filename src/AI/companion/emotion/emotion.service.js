// =============================================
// AI COMPANION - EMOTION SERVICE
// =============================================

import * as emotionRepo from './emotion.repo.js';
import * as analyzer from './emotion.analyzer.js';

// ========== EMOTION LOGGING ==========

export const detectAndLogEmotion = async (userId, text, source = 'chat', options = {}) => {
    // Analyze emotion from text
    const analysis = await analyzer.analyzeEmotion(text, options.useAI !== false);

    // Log to database
    const emotionLog = await emotionRepo.logEmotion(
        userId,
        analysis.emotion,
        analysis.intensity,
        source,
        {
            raw_text: text.substring(0, 500), // Limit stored text
            confidence: analysis.confidence,
            message_id: options.message_id,
            metadata: {
                secondary_emotions: analysis.secondary_emotions,
                indicators: analysis.indicators,
                is_crisis: analysis.is_crisis,
                needs_support: analysis.needs_support
            }
        }
    );

    // Update mental state based on emotion
    await updateMentalStateFromEmotion(userId, analysis);

    // Check if needs immediate attention
    if (analysis.is_crisis || analysis.needs_support) {
        // Could trigger alert here
        console.warn(`⚠️ User ${userId} needs support - Crisis: ${analysis.is_crisis}`);
    }

    return {
        log: emotionLog,
        analysis
    };
};

// ========== MENTAL STATE MANAGEMENT ==========

const updateMentalStateFromEmotion = async (userId, analysis) => {
    const currentState = await emotionRepo.getMentalState(userId);
    const isNegative = analyzer.isNegativeEmotion(analysis.emotion);
    const isPositive = analyzer.isPositiveEmotion(analysis.emotion);

    // Calculate new state values
    const updates = {
        current_mood: analysis.emotion,
        mood_score: getMoodScore(analysis.emotion, analysis.intensity)
    };

    // Update stress/anxiety based on emotion
    if (analysis.emotion === 'stressed') {
        updates.stress_level = Math.min((currentState?.stress_level || 0) + 1, 10);
    } else if (analysis.emotion === 'anxious') {
        updates.anxiety_level = Math.min((currentState?.anxiety_level || 0) + 1, 10);
    } else if (isPositive) {
        // Positive emotions reduce stress/anxiety
        updates.stress_level = Math.max((currentState?.stress_level || 0) - 1, 0);
        updates.anxiety_level = Math.max((currentState?.anxiety_level || 0) - 1, 0);
    }

    // Track consecutive negative days
    if (isNegative && analysis.intensity > 0.5) {
        updates.consecutive_negative_days = (currentState?.consecutive_negative_days || 0) + 1;
        updates.vulnerability_score = Math.min(
            (currentState?.vulnerability_score || 0) + 0.1,
            1.0
        );
    } else if (isPositive) {
        updates.consecutive_negative_days = 0;
        updates.last_positive_interaction = new Date();
        updates.vulnerability_score = Math.max(
            (currentState?.vulnerability_score || 0) - 0.1,
            0
        );
    }

    await emotionRepo.upsertMentalState(userId, updates);
};

const getMoodScore = (emotion, intensity) => {
    const baseScores = {
        happy: 0.9, excited: 0.85, neutral: 0.5,
        tired: 0.35, anxious: 0.25, stressed: 0.25, sad: 0.15, angry: 0.2
    };
    const base = baseScores[emotion] || 0.5;
    // Adjust by intensity
    return base * (0.5 + intensity * 0.5);
};

// ========== EMOTION TIMELINE & STATS ==========

export const getEmotionTimeline = async (userId, days = 7) => {
    const timeline = await emotionRepo.getEmotionTimeline(userId, days);
    const trend = analyzer.analyzeEmotionTrend(timeline);

    return {
        timeline,
        trend,
        total_logs: timeline.length
    };
};

export const getEmotionStats = async (userId, days = 7) => {
    const stats = await emotionRepo.getEmotionStats(userId, days);
    const dominant = await emotionRepo.getDominantEmotion(userId, 24);

    // Calculate percentages
    const total = stats.reduce((sum, s) => sum + parseInt(s.count), 0);
    const statsWithPercent = stats.map(s => ({
        ...s,
        percentage: total > 0 ? Math.round((s.count / total) * 100) : 0
    }));

    return {
        stats: statsWithPercent,
        dominant_emotion: dominant,
        total_logs: total,
        period_days: days
    };
};

// ========== MENTAL STATE ==========

export const getMentalState = async (userId) => {
    let state = await emotionRepo.getMentalState(userId);

    if (!state) {
        // Create default state
        state = await emotionRepo.upsertMentalState(userId, {
            current_mood: 'neutral',
            mood_score: 0.5,
            stress_level: 0,
            anxiety_level: 0,
            energy_level: 5
        });
    }

    // Add interpretation
    return {
        ...state,
        interpretation: interpretMentalState(state)
    };
};

const interpretMentalState = (state) => {
    const interpretations = [];

    if (state.stress_level >= 7) {
        interpretations.push('Mức stress cao, cần chú ý nghỉ ngơi');
    }
    if (state.anxiety_level >= 7) {
        interpretations.push('Mức lo âu cao, có thể cần hỗ trợ');
    }
    if (state.vulnerability_score >= 0.7) {
        interpretations.push('Đang trong giai đoạn dễ tổn thương');
    }
    if (state.consecutive_negative_days >= 3) {
        interpretations.push(`${state.consecutive_negative_days} ngày liên tiếp có cảm xúc tiêu cực`);
    }
    if (state.energy_level <= 3) {
        interpretations.push('Năng lượng thấp');
    }

    return interpretations.length > 0 ? interpretations : ['Trạng thái ổn định'];
};

// ========== ASSESSMENTS ==========

export const createAssessment = async (userId, type = 'auto') => {
    // Gather data for assessment
    const mentalState = await emotionRepo.getMentalState(userId);
    const recentEmotions = await emotionRepo.getEmotionStats(userId, 7);
    const checkins = await emotionRepo.getCheckinHistory(userId, 7);

    // Calculate risk level
    let riskScore = 0;
    let burnoutScore = 0;
    let depressionIndicators = 0;
    let anxietyIndicators = 0;

    if (mentalState) {
        if (mentalState.stress_level >= 8) riskScore += 2;
        else if (mentalState.stress_level >= 6) riskScore += 1;

        if (mentalState.anxiety_level >= 8) riskScore += 2;
        else if (mentalState.anxiety_level >= 6) riskScore += 1;

        if (mentalState.vulnerability_score >= 0.8) riskScore += 2;
        else if (mentalState.vulnerability_score >= 0.5) riskScore += 1;

        if (mentalState.consecutive_negative_days >= 5) riskScore += 2;
        else if (mentalState.consecutive_negative_days >= 3) riskScore += 1;

        burnoutScore = Math.min(
            (mentalState.stress_level * 5) +
            ((10 - mentalState.energy_level) * 3) +
            (mentalState.consecutive_negative_days * 2),
            100
        );
    }

    // Check emotion patterns
    const negativeEmotions = recentEmotions.filter(e =>
        ['sad', 'anxious', 'stressed', 'angry'].includes(e.emotion)
    );
    const totalNegative = negativeEmotions.reduce((sum, e) => sum + parseInt(e.count), 0);

    if (totalNegative > 10) riskScore += 2;
    else if (totalNegative > 5) riskScore += 1;

    // Determine risk level
    let riskLevel;
    if (riskScore >= 8) riskLevel = 'critical';
    else if (riskScore >= 5) riskLevel = 'high';
    else if (riskScore >= 3) riskLevel = 'moderate';
    else riskLevel = 'low';

    // Generate recommendations
    const recommendations = generateRecommendations(riskLevel, mentalState, recentEmotions);

    // Create assessment
    const assessment = await emotionRepo.createAssessment(userId, {
        assessment_type: type,
        risk_level: riskLevel,
        burnout_score: burnoutScore,
        depression_indicators: depressionIndicators,
        anxiety_indicators: anxietyIndicators,
        recommendations,
        notes: `Auto-assessed. Risk score: ${riskScore}`
    });

    return assessment;
};

const generateRecommendations = (riskLevel, mentalState, emotions) => {
    const recommendations = [];

    if (riskLevel === 'critical' || riskLevel === 'high') {
        recommendations.push({
            type: 'professional',
            priority: 'high',
            message: 'Nên trao đổi với chuyên gia tâm lý'
        });
    }

    if (mentalState?.stress_level >= 6) {
        recommendations.push({
            type: 'activity',
            activity: 'breathing',
            priority: 'medium',
            message: 'Thử bài tập thở 4-7-8 để giảm stress'
        });
    }

    if (mentalState?.anxiety_level >= 6) {
        recommendations.push({
            type: 'activity',
            activity: 'grounding',
            priority: 'medium',
            message: 'Thử kỹ thuật grounding 5-4-3-2-1'
        });
    }

    if (mentalState?.energy_level <= 3) {
        recommendations.push({
            type: 'lifestyle',
            priority: 'medium',
            message: 'Cần nghỉ ngơi và ngủ đủ giấc'
        });
    }

    if (mentalState?.consecutive_negative_days >= 3) {
        recommendations.push({
            type: 'activity',
            activity: 'gratitude',
            priority: 'low',
            message: 'Thử viết 3 điều biết ơn mỗi ngày'
        });
    }

    // Default recommendation
    if (recommendations.length === 0) {
        recommendations.push({
            type: 'maintenance',
            priority: 'low',
            message: 'Tiếp tục duy trì thói quen tốt!'
        });
    }

    return recommendations;
};

export const getLatestAssessment = async (userId) => {
    return await emotionRepo.getLatestAssessment(userId);
};

export const getAssessmentHistory = async (userId, limit = 10) => {
    return await emotionRepo.getAssessmentHistory(userId, limit);
};

// ========== WELLNESS ACTIVITIES ==========

export const logWellnessActivity = async (userId, activity) => {
    const log = await emotionRepo.logWellnessActivity(userId, activity);

    // If mood improved, update mental state
    if (activity.mood_after && activity.mood_before) {
        const moodImproved = getMoodScore(activity.mood_after, 0.5) >
            getMoodScore(activity.mood_before, 0.5);
        if (moodImproved) {
            await emotionRepo.resetNegativeDays(userId);
        }
    }

    return log;
};

export const getWellnessHistory = async (userId, days = 30) => {
    return await emotionRepo.getWellnessHistory(userId, days);
};

export const getWellnessStats = async (userId, days = 30) => {
    return await emotionRepo.getWellnessStats(userId, days);
};

export const suggestWellnessActivity = async (userId) => {
    const mentalState = await emotionRepo.getMentalState(userId);
    const recentActivities = await emotionRepo.getWellnessHistory(userId, 7, 10);

    // Get activities user hasn't done recently
    const recentTypes = new Set(recentActivities.map(a => a.activity_type));

    const suggestions = [];

    // Suggest based on current state
    if (mentalState?.stress_level >= 5) {
        if (!recentTypes.has('breathing')) {
            suggestions.push({
                activity_type: 'breathing',
                title: 'Bài tập thở 4-7-8',
                description: 'Hít vào 4 giây, giữ 7 giây, thở ra 8 giây. Lặp lại 4 lần.',
                duration_minutes: 5,
                reason: 'Giúp giảm stress nhanh chóng'
            });
        }
    }

    if (mentalState?.anxiety_level >= 5) {
        if (!recentTypes.has('grounding')) {
            suggestions.push({
                activity_type: 'grounding',
                title: 'Kỹ thuật Grounding 5-4-3-2-1',
                description: 'Nhận biết 5 thứ nhìn thấy, 4 thứ chạm được, 3 thứ nghe được, 2 mùi, 1 vị.',
                duration_minutes: 5,
                reason: 'Giúp giảm lo âu và quay về hiện tại'
            });
        }
    }

    if (!recentTypes.has('gratitude')) {
        suggestions.push({
            activity_type: 'gratitude',
            title: 'Viết nhật ký biết ơn',
            description: 'Viết ra 3 điều bạn biết ơn hôm nay.',
            duration_minutes: 10,
            reason: 'Tăng cảm xúc tích cực'
        });
    }

    if (!recentTypes.has('meditation')) {
        suggestions.push({
            activity_type: 'meditation',
            title: 'Thiền 5 phút',
            description: 'Ngồi yên, tập trung vào hơi thở trong 5 phút.',
            duration_minutes: 5,
            reason: 'Giúp tâm trí bình an'
        });
    }

    return suggestions.slice(0, 3); // Return top 3 suggestions
};

// ========== DAILY CHECKIN ==========

export const submitDailyCheckin = async (userId, checkin) => {
    const result = await emotionRepo.createDailyCheckin(userId, checkin);

    // Also log as emotion
    await detectAndLogEmotion(userId, `Mood: ${checkin.mood}`, 'checkin', { useAI: false });

    // Update mental state
    await emotionRepo.upsertMentalState(userId, {
        current_mood: checkin.mood,
        stress_level: checkin.stress_level || undefined,
        energy_level: checkin.energy_level || undefined
    });

    return result;
};

export const getTodayCheckin = async (userId) => {
    return await emotionRepo.getTodayCheckin(userId);
};

export const getCheckinHistory = async (userId, days = 30) => {
    return await emotionRepo.getCheckinHistory(userId, days);
};

// ========== ADMIN/MONITORING ==========

export const getUsersNeedingAttention = async () => {
    return await emotionRepo.getUsersNeedingAttention();
};

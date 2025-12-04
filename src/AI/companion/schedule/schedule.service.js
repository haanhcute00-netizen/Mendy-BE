// =============================================
// AI COMPANION - SCHEDULE SERVICE
// =============================================

import * as scheduleRepo from './schedule.repo.js';
import * as emotionRepo from '../emotion/emotion.repo.js';
import * as personaRepo from '../persona/persona.repo.js';

// ========== SCHEDULE MANAGEMENT ==========

export const createSchedule = async (userId, scheduleData) => {
    return await scheduleRepo.createSchedule(userId, scheduleData);
};

export const getUserSchedules = async (userId, options = {}) => {
    return await scheduleRepo.getUserSchedules(userId, options);
};

export const getTodaySchedules = async (userId) => {
    return await scheduleRepo.getTodaySchedules(userId);
};

export const getUpcomingSchedules = async (userId, hours = 24) => {
    return await scheduleRepo.getUpcomingSchedules(userId, hours);
};

export const updateSchedule = async (scheduleId, userId, updates) => {
    return await scheduleRepo.updateSchedule(scheduleId, userId, updates);
};

export const completeSchedule = async (scheduleId, userId) => {
    return await scheduleRepo.completeSchedule(scheduleId, userId);
};

export const deleteSchedule = async (scheduleId, userId) => {
    return await scheduleRepo.deleteSchedule(scheduleId, userId);
};

// ========== AI SCHEDULE SUGGESTIONS ==========

export const suggestSchedule = async (userId) => {
    const suggestions = [];

    // Get user data
    const mentalState = await emotionRepo.getMentalState(userId);
    const sleepSummary = await scheduleRepo.getSleepSummary(userId);
    const todaySchedules = await scheduleRepo.getTodaySchedules(userId);
    const patterns = await scheduleRepo.getUserPatterns(userId);

    // Suggest based on sleep patterns
    if (sleepSummary) {
        if (sleepSummary.avg_duration < 420) { // Less than 7 hours
            suggestions.push({
                type: 'sleep',
                title: 'Đi ngủ sớm hơn',
                description: `Bạn đang ngủ trung bình ${Math.round(sleepSummary.avg_duration / 60)} giờ/đêm. Nên ngủ ít nhất 7-8 giờ.`,
                suggested_time: '22:00',
                priority: 4
            });
        }
        if (sleepSummary.avg_quality < 3) {
            suggestions.push({
                type: 'wellness',
                title: 'Thư giãn trước khi ngủ',
                description: 'Chất lượng giấc ngủ thấp. Thử thiền hoặc đọc sách 30 phút trước khi ngủ.',
                suggested_time: '21:30',
                priority: 3
            });
        }
    }

    // Suggest based on mental state
    if (mentalState) {
        if (mentalState.stress_level >= 6) {
            suggestions.push({
                type: 'wellness',
                title: 'Nghỉ ngơi giảm stress',
                description: 'Mức stress cao. Hãy dành 15 phút để thở sâu hoặc đi dạo.',
                priority: 4
            });
        }
        if (mentalState.energy_level <= 3) {
            suggestions.push({
                type: 'health',
                title: 'Nghỉ ngơi ngắn',
                description: 'Năng lượng thấp. Thử power nap 20 phút hoặc uống nước.',
                priority: 3
            });
        }
    }

    // Suggest breaks if many schedules
    if (todaySchedules.length >= 5) {
        suggestions.push({
            type: 'health',
            title: 'Nghỉ giải lao',
            description: `Bạn có ${todaySchedules.length} việc hôm nay. Nhớ nghỉ ngơi giữa các công việc.`,
            priority: 2
        });
    }

    // Default wellness suggestion
    if (suggestions.length === 0) {
        suggestions.push({
            type: 'wellness',
            title: 'Viết nhật ký biết ơn',
            description: 'Dành 5 phút viết 3 điều bạn biết ơn hôm nay.',
            suggested_time: '21:00',
            priority: 2
        });
    }

    return suggestions;
};

export const createAISuggestedSchedule = async (userId, suggestion) => {
    const schedule = {
        title: suggestion.title,
        description: suggestion.description,
        schedule_type: suggestion.type || 'custom',
        start_at: suggestion.start_at || new Date(),
        priority: suggestion.priority || 2,
        ai_generated: true,
        metadata: { suggestion_reason: suggestion.reason }
    };

    return await scheduleRepo.createSchedule(userId, schedule);
};

// ========== SLEEP TRACKING ==========

export const logSleep = async (userId, sleepData) => {
    const log = await scheduleRepo.logSleep(userId, sleepData);

    // Analyze and detect patterns
    await analyzeSleepPattern(userId);

    return log;
};

export const getSleepHistory = async (userId, days = 30) => {
    return await scheduleRepo.getSleepHistory(userId, days);
};

export const getSleepAnalysis = async (userId) => {
    const summary = await scheduleRepo.getSleepSummary(userId);
    const history = await scheduleRepo.getSleepHistory(userId, 7);

    const analysis = {
        summary,
        history,
        insights: [],
        recommendations: []
    };

    if (summary) {
        // Generate insights
        if (summary.avg_duration < 360) {
            analysis.insights.push('Bạn đang ngủ ít hơn 6 giờ/đêm - thiếu ngủ nghiêm trọng');
            analysis.recommendations.push('Cố gắng đi ngủ sớm hơn 1 giờ mỗi tối');
        } else if (summary.avg_duration < 420) {
            analysis.insights.push('Thời gian ngủ hơi ít, nên ngủ 7-8 giờ/đêm');
        }

        if (summary.avg_quality < 3) {
            analysis.insights.push('Chất lượng giấc ngủ chưa tốt');
            analysis.recommendations.push('Tránh caffeine sau 2PM và màn hình 1 giờ trước khi ngủ');
        }

        if (summary.avg_interruptions > 2) {
            analysis.insights.push('Giấc ngủ bị gián đoạn nhiều');
            analysis.recommendations.push('Kiểm tra môi trường ngủ: nhiệt độ, ánh sáng, tiếng ồn');
        }
    }

    return analysis;
};

const analyzeSleepPattern = async (userId) => {
    const history = await scheduleRepo.getSleepHistory(userId, 14);
    if (history.length < 7) return;

    // Detect late sleep pattern
    const lateSleepCount = history.filter(h => {
        if (!h.sleep_at) return false;
        const hour = new Date(h.sleep_at).getHours();
        return hour >= 0 && hour < 6; // After midnight
    }).length;

    if (lateSleepCount >= 5) {
        await scheduleRepo.upsertBehaviorPattern(
            userId,
            'sleep',
            'late_sleeper',
            { late_sleep_count: lateSleepCount, period_days: 14 },
            lateSleepCount / history.length
        );
    }

    // Detect irregular sleep pattern
    const sleepTimes = history.filter(h => h.sleep_at).map(h => new Date(h.sleep_at).getHours());
    if (sleepTimes.length >= 5) {
        const variance = calculateVariance(sleepTimes);
        if (variance > 4) {
            await scheduleRepo.upsertBehaviorPattern(
                userId,
                'sleep',
                'irregular_sleep',
                { variance, sample_size: sleepTimes.length },
                0.7
            );
        }
    }
};

const calculateVariance = (arr) => {
    const mean = arr.reduce((a, b) => a + b, 0) / arr.length;
    return arr.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / arr.length;
};

// ========== PROACTIVE AI ==========

export const generateProactiveMessages = async () => {
    const messages = [];

    // Get inactive users
    const inactiveUsers = await scheduleRepo.getInactiveUsers();
    for (const user of inactiveUsers) {
        const content = generateInactivityMessage(user);
        messages.push({
            user_id: user.user_id,
            trigger_type: 'inactivity',
            trigger_data: { hours_inactive: user.hours_inactive },
            message_content: content,
            persona_id: user.persona_id,
            priority: 2,
            scheduled_at: new Date()
        });
    }

    // Save messages
    for (const msg of messages) {
        await scheduleRepo.createProactiveMessage(msg);
    }

    return messages.length;
};

const generateInactivityMessage = (user) => {
    const templates = {
        default: [
            'Lâu rồi không thấy bạn, bạn có khỏe không?',
            'Mình nhớ bạn quá! Hôm nay bạn thế nào?',
            'Hey, bạn ổn chứ? Có gì muốn chia sẻ không?'
        ]
    };

    const msgs = templates.default;
    return msgs[Math.floor(Math.random() * msgs.length)];
};

export const getPendingProactiveMessages = async () => {
    return await scheduleRepo.getPendingProactiveMessages();
};

export const markProactiveMessageSent = async (messageId) => {
    return await scheduleRepo.markProactiveMessageSent(messageId);
};

// ========== ACTIVITY TRACKING ==========

export const logActivity = async (userId, activityType, data = {}) => {
    return await scheduleRepo.logActivity(userId, activityType, data);
};

export const getLastActivity = async (userId) => {
    return await scheduleRepo.getLastActivity(userId);
};

// ========== AI SUGGESTIONS ==========

export const createSuggestion = async (userId, suggestion) => {
    return await scheduleRepo.createSuggestion(userId, suggestion);
};

export const respondToSuggestion = async (suggestionId, userId, accepted, feedback) => {
    return await scheduleRepo.respondToSuggestion(suggestionId, userId, accepted, feedback);
};

export const getPendingSuggestions = async (userId) => {
    return await scheduleRepo.getPendingSuggestions(userId);
};

// ========== BEHAVIOR PATTERNS ==========

export const getUserPatterns = async (userId, type = null) => {
    return await scheduleRepo.getUserPatterns(userId, type);
};

export const detectPatterns = async (userId) => {
    // This would analyze user data and detect patterns
    // Called periodically by a background job
    const patterns = [];

    // Analyze activity patterns
    // Analyze mood patterns
    // Analyze schedule completion patterns

    return patterns;
};

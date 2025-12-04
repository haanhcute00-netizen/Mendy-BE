// =============================================
// AI COMPANION - EMOTION CONTROLLER
// =============================================

import * as emotionService from './emotion.service.js';

// ========== EMOTION TIMELINE ==========

// GET /api/v1/ai-companion/emotion/timeline
export const getTimeline = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const days = parseInt(req.query.days) || 7;

        const data = await emotionService.getEmotionTimeline(userId, days);
        res.json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/emotion/stats
export const getStats = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const days = parseInt(req.query.days) || 7;

        const data = await emotionService.getEmotionStats(userId, days);
        res.json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

// ========== MENTAL STATE ==========

// GET /api/v1/ai-companion/mental-state
export const getMentalState = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const state = await emotionService.getMentalState(userId);
        res.json({
            success: true,
            data: state
        });
    } catch (error) {
        next(error);
    }
};

// ========== ASSESSMENTS ==========

// POST /api/v1/ai-companion/assessment
export const createAssessment = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { type } = req.body;

        const assessment = await emotionService.createAssessment(userId, type || 'manual');
        res.status(201).json({
            success: true,
            message: 'Assessment created',
            data: assessment
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/assessment/latest
export const getLatestAssessment = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const assessment = await emotionService.getLatestAssessment(userId);

        if (!assessment) {
            return res.status(404).json({
                success: false,
                message: 'No assessment found'
            });
        }

        res.json({
            success: true,
            data: assessment
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/assessment/history
export const getAssessmentHistory = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const limit = parseInt(req.query.limit) || 10;

        const history = await emotionService.getAssessmentHistory(userId, limit);
        res.json({
            success: true,
            data: history
        });
    } catch (error) {
        next(error);
    }
};

// ========== WELLNESS ACTIVITIES ==========

// POST /api/v1/ai-companion/wellness/log
export const logWellnessActivity = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const activity = req.body;

        if (!activity.activity_type) {
            return res.status(400).json({
                success: false,
                message: 'activity_type is required'
            });
        }

        const validTypes = ['breathing', 'meditation', 'journaling', 'exercise', 'gratitude', 'grounding', 'affirmation'];
        if (!validTypes.includes(activity.activity_type)) {
            return res.status(400).json({
                success: false,
                message: `Invalid activity_type. Must be one of: ${validTypes.join(', ')}`
            });
        }

        const log = await emotionService.logWellnessActivity(userId, activity);
        res.status(201).json({
            success: true,
            message: 'Activity logged',
            data: log
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/wellness/history
export const getWellnessHistory = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const days = parseInt(req.query.days) || 30;

        const history = await emotionService.getWellnessHistory(userId, days);
        res.json({
            success: true,
            data: history
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/wellness/stats
export const getWellnessStats = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const days = parseInt(req.query.days) || 30;

        const stats = await emotionService.getWellnessStats(userId, days);
        res.json({
            success: true,
            data: stats
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/wellness/suggestions
export const getWellnessSuggestions = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const suggestions = await emotionService.suggestWellnessActivity(userId);
        res.json({
            success: true,
            data: suggestions
        });
    } catch (error) {
        next(error);
    }
};

// ========== DAILY CHECKIN ==========

// POST /api/v1/ai-companion/checkin
export const submitCheckin = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const checkin = req.body;

        if (!checkin.mood) {
            return res.status(400).json({
                success: false,
                message: 'mood is required'
            });
        }

        const validMoods = ['great', 'good', 'okay', 'bad', 'terrible'];
        if (!validMoods.includes(checkin.mood)) {
            return res.status(400).json({
                success: false,
                message: `Invalid mood. Must be one of: ${validMoods.join(', ')}`
            });
        }

        const result = await emotionService.submitDailyCheckin(userId, checkin);
        res.status(201).json({
            success: true,
            message: 'Check-in submitted',
            data: result
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/checkin/today
export const getTodayCheckin = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const checkin = await emotionService.getTodayCheckin(userId);

        res.json({
            success: true,
            data: checkin,
            has_checked_in: !!checkin
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/checkin/history
export const getCheckinHistory = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const days = parseInt(req.query.days) || 30;

        const history = await emotionService.getCheckinHistory(userId, days);
        res.json({
            success: true,
            data: history
        });
    } catch (error) {
        next(error);
    }
};

// ========== ADMIN ==========

// GET /api/v1/ai-companion/admin/users-needing-attention
export const adminGetUsersNeedingAttention = async (req, res, next) => {
    try {
        const users = await emotionService.getUsersNeedingAttention();
        res.json({
            success: true,
            data: users,
            count: users.length
        });
    } catch (error) {
        next(error);
    }
};

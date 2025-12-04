// =============================================
// AI COMPANION - SCHEDULE CONTROLLER
// =============================================

import * as scheduleService from './schedule.service.js';

// ========== SCHEDULES ==========

// POST /api/v1/ai-companion/schedule
export const createSchedule = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { title, description, schedule_type, start_at, end_at, remind_before, priority, recurrence } = req.body;

        if (!title || !start_at) {
            return res.status(400).json({ success: false, message: 'title và start_at là bắt buộc' });
        }

        const schedule = await scheduleService.createSchedule(userId, {
            title, description, schedule_type, start_at, end_at, remind_before, priority, recurrence
        });

        res.status(201).json({ success: true, message: 'Đã tạo lịch', data: schedule });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/schedule
export const getSchedules = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { start_date, end_date, type, completed, limit } = req.query;

        const schedules = await scheduleService.getUserSchedules(userId, {
            startDate: start_date,
            endDate: end_date,
            type,
            completed: completed === 'true' ? true : completed === 'false' ? false : undefined,
            limit: parseInt(limit) || 50
        });

        res.json({ success: true, data: schedules, count: schedules.length });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/schedule/today
export const getTodaySchedules = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const schedules = await scheduleService.getTodaySchedules(userId);
        res.json({ success: true, data: schedules, count: schedules.length });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/schedule/upcoming
export const getUpcomingSchedules = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const hours = parseInt(req.query.hours) || 24;
        const schedules = await scheduleService.getUpcomingSchedules(userId, hours);
        res.json({ success: true, data: schedules, count: schedules.length });
    } catch (error) {
        next(error);
    }
};

// PUT /api/v1/ai-companion/schedule/:id
export const updateSchedule = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const updates = req.body;

        const schedule = await scheduleService.updateSchedule(parseInt(id), userId, updates);
        if (!schedule) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy lịch' });
        }

        res.json({ success: true, message: 'Đã cập nhật', data: schedule });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/schedule/:id/complete
export const completeSchedule = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        const schedule = await scheduleService.completeSchedule(parseInt(id), userId);
        if (!schedule) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy lịch' });
        }

        res.json({ success: true, message: 'Đã hoàn thành', data: schedule });
    } catch (error) {
        next(error);
    }
};

// DELETE /api/v1/ai-companion/schedule/:id
export const deleteSchedule = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        const deleted = await scheduleService.deleteSchedule(parseInt(id), userId);
        if (!deleted) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy lịch' });
        }

        res.json({ success: true, message: 'Đã xóa' });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/schedule/ai-suggest
export const getAISuggestions = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const suggestions = await scheduleService.suggestSchedule(userId);
        res.json({ success: true, data: suggestions });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/schedule/ai-suggest/accept
export const acceptAISuggestion = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { suggestion, start_at } = req.body;

        if (!suggestion) {
            return res.status(400).json({ success: false, message: 'suggestion là bắt buộc' });
        }

        const schedule = await scheduleService.createAISuggestedSchedule(userId, {
            ...suggestion,
            start_at: start_at || new Date()
        });

        res.status(201).json({ success: true, message: 'Đã thêm vào lịch', data: schedule });
    } catch (error) {
        next(error);
    }
};

// ========== SLEEP ==========

// POST /api/v1/ai-companion/sleep/log
export const logSleep = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const sleepData = req.body;

        const log = await scheduleService.logSleep(userId, sleepData);
        res.status(201).json({ success: true, message: 'Đã ghi nhận giấc ngủ', data: log });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/sleep/history
export const getSleepHistory = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const days = parseInt(req.query.days) || 30;

        const history = await scheduleService.getSleepHistory(userId, days);
        res.json({ success: true, data: history, count: history.length });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/sleep/analysis
export const getSleepAnalysis = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const analysis = await scheduleService.getSleepAnalysis(userId);
        res.json({ success: true, data: analysis });
    } catch (error) {
        next(error);
    }
};

// ========== PATTERNS ==========

// GET /api/v1/ai-companion/patterns
export const getPatterns = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { type } = req.query;

        const patterns = await scheduleService.getUserPatterns(userId, type);
        res.json({ success: true, data: patterns });
    } catch (error) {
        next(error);
    }
};

// ========== SUGGESTIONS ==========

// GET /api/v1/ai-companion/suggestions
export const getPendingSuggestions = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const suggestions = await scheduleService.getPendingSuggestions(userId);
        res.json({ success: true, data: suggestions });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/suggestions/:id/respond
export const respondToSuggestion = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const { accepted, feedback } = req.body;

        if (accepted === undefined) {
            return res.status(400).json({ success: false, message: 'accepted là bắt buộc' });
        }

        const suggestion = await scheduleService.respondToSuggestion(parseInt(id), userId, accepted, feedback);
        if (!suggestion) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy gợi ý' });
        }

        res.json({ success: true, message: accepted ? 'Đã chấp nhận' : 'Đã bỏ qua', data: suggestion });
    } catch (error) {
        next(error);
    }
};

// ========== ADMIN ==========

// POST /api/v1/ai-companion/admin/generate-proactive
export const adminGenerateProactive = async (req, res, next) => {
    try {
        const count = await scheduleService.generateProactiveMessages();
        res.json({ success: true, message: `Đã tạo ${count} tin nhắn chủ động`, count });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/admin/proactive-pending
export const adminGetProactivePending = async (req, res, next) => {
    try {
        const messages = await scheduleService.getPendingProactiveMessages();
        res.json({ success: true, data: messages, count: messages.length });
    } catch (error) {
        next(error);
    }
};

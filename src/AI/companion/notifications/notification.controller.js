// =============================================
// AI COMPANION - NOTIFICATION CONTROLLER
// =============================================

import * as notificationService from './notification.service.js';

// GET /api/v1/ai-companion/notifications
export const getNotifications = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const limit = parseInt(req.query.limit) || 20;

        const notifications = await notificationService.getUserNotificationHistory(userId, limit);
        res.json({
            success: true,
            data: notifications
        });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/notifications/schedule
export const scheduleNotification = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { type, content, scheduled_at, metadata } = req.body;

        if (!type || !content || !scheduled_at) {
            return res.status(400).json({
                success: false,
                message: 'type, content, and scheduled_at are required'
            });
        }

        const validTypes = ['morning', 'evening', 'checkin', 'reminder', 'random', 'emotion_based', 'schedule_based'];
        if (!validTypes.includes(type)) {
            return res.status(400).json({
                success: false,
                message: `Invalid type. Must be one of: ${validTypes.join(', ')}`
            });
        }

        const notification = await notificationService.scheduleNotification(
            userId, type, content, new Date(scheduled_at), metadata || {}
        );

        res.status(201).json({
            success: true,
            message: 'Notification scheduled successfully',
            data: notification
        });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/notifications/random
export const scheduleRandomMessage = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const notification = await notificationService.scheduleRandomMessage(userId);

        if (!notification) {
            return res.status(400).json({
                success: false,
                message: 'Random messages are disabled for this user'
            });
        }

        res.status(201).json({
            success: true,
            message: 'Random message scheduled',
            data: notification
        });
    } catch (error) {
        next(error);
    }
};

// DELETE /api/v1/ai-companion/notifications/:id
export const deleteNotification = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        const deleted = await notificationService.deleteNotification(parseInt(id), userId);

        if (!deleted) {
            return res.status(404).json({
                success: false,
                message: 'Notification not found'
            });
        }

        res.json({
            success: true,
            message: 'Notification deleted'
        });
    } catch (error) {
        next(error);
    }
};

// ========== ADMIN/SYSTEM ENDPOINTS ==========

// POST /api/v1/ai-companion/notifications/admin/schedule-morning
export const adminScheduleMorning = async (req, res, next) => {
    try {
        const scheduled = await notificationService.scheduleMorningCheckins();
        res.json({
            success: true,
            message: `Scheduled ${scheduled.length} morning check-ins`,
            count: scheduled.length
        });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/notifications/admin/schedule-evening
export const adminScheduleEvening = async (req, res, next) => {
    try {
        const scheduled = await notificationService.scheduleEveningCheckins();
        res.json({
            success: true,
            message: `Scheduled ${scheduled.length} evening check-ins`,
            count: scheduled.length
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/notifications/admin/pending
export const adminGetPending = async (req, res, next) => {
    try {
        const pending = await notificationService.getPendingNotifications();
        res.json({
            success: true,
            data: pending,
            count: pending.length
        });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/notifications/admin/cleanup
export const adminCleanup = async (req, res, next) => {
    try {
        const deleted = await notificationService.cleanupOldNotifications();
        res.json({
            success: true,
            message: `Cleaned up ${deleted} old notifications`,
            deleted
        });
    } catch (error) {
        next(error);
    }
};

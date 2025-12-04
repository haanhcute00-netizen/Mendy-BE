// =============================================
// AI COMPANION - NOTIFICATION SCHEDULER
// Cron jobs for automated notifications
// =============================================

import * as notificationService from './notification.service.js';
import { logger } from '../../../utils/logger.js';

let schedulerInterval = null;
let morningJobInterval = null;
let eveningJobInterval = null;
let cleanupJobInterval = null;

// ========== NOTIFICATION SENDER ==========

// This function should be called by Socket.io or push notification service
let notificationSender = null;

export const setNotificationSender = (sender) => {
    notificationSender = sender;
};

const sendNotification = async (notification) => {
    if (notificationSender) {
        try {
            await notificationSender(notification);
            await notificationService.markNotificationSent(notification.id);
            logger.info(`Notification sent: ${notification.id} to user ${notification.user_id}`);
        } catch (error) {
            logger.error(`Failed to send notification ${notification.id}:`, error);
        }
    } else {
        // If no sender configured, just mark as sent (for testing)
        await notificationService.markNotificationSent(notification.id);
        logger.warn(`No notification sender configured. Marked ${notification.id} as sent.`);
    }
};

// ========== PROCESS PENDING NOTIFICATIONS ==========

const processPendingNotifications = async () => {
    try {
        const pending = await notificationService.getPendingNotifications();

        for (const notification of pending) {
            // Check quiet hours
            if (isInQuietHours(notification)) {
                continue;
            }

            await sendNotification(notification);
        }

        if (pending.length > 0) {
            logger.info(`Processed ${pending.length} pending notifications`);
        }
    } catch (error) {
        logger.error('Error processing pending notifications:', error);
    }
};

// ========== QUIET HOURS CHECK ==========

const isInQuietHours = (notification) => {
    if (!notification.quiet_hours_start || !notification.quiet_hours_end) {
        return false;
    }

    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentTime = currentHour * 60 + currentMinute;

    const [startHour, startMinute] = notification.quiet_hours_start.split(':').map(Number);
    const [endHour, endMinute] = notification.quiet_hours_end.split(':').map(Number);

    const startTime = startHour * 60 + startMinute;
    const endTime = endHour * 60 + endMinute;

    // Handle overnight quiet hours (e.g., 23:00 - 07:00)
    if (startTime > endTime) {
        return currentTime >= startTime || currentTime < endTime;
    }

    return currentTime >= startTime && currentTime < endTime;
};

// ========== SCHEDULED JOBS ==========

const scheduleMorningCheckins = async () => {
    try {
        const scheduled = await notificationService.scheduleMorningCheckins();
        if (scheduled.length > 0) {
            logger.info(`Scheduled ${scheduled.length} morning check-ins`);
        }
    } catch (error) {
        logger.error('Error scheduling morning check-ins:', error);
    }
};

const scheduleEveningCheckins = async () => {
    try {
        const scheduled = await notificationService.scheduleEveningCheckins();
        if (scheduled.length > 0) {
            logger.info(`Scheduled ${scheduled.length} evening check-ins`);
        }
    } catch (error) {
        logger.error('Error scheduling evening check-ins:', error);
    }
};

const cleanupOldNotifications = async () => {
    try {
        const deleted = await notificationService.cleanupOldNotifications();
        if (deleted > 0) {
            logger.info(`Cleaned up ${deleted} old notifications`);
        }
    } catch (error) {
        logger.error('Error cleaning up notifications:', error);
    }
};

// ========== SCHEDULER CONTROL ==========

export const startScheduler = () => {
    logger.info('Starting AI Companion notification scheduler...');

    // Process pending notifications every minute
    schedulerInterval = setInterval(processPendingNotifications, 60 * 1000);

    // Schedule morning check-ins at 6:00 AM daily
    // Using setInterval for simplicity - in production, use node-cron
    morningJobInterval = setInterval(() => {
        const now = new Date();
        if (now.getHours() === 6 && now.getMinutes() === 0) {
            scheduleMorningCheckins();
        }
    }, 60 * 1000);

    // Schedule evening check-ins at 9:00 PM daily
    eveningJobInterval = setInterval(() => {
        const now = new Date();
        if (now.getHours() === 21 && now.getMinutes() === 0) {
            scheduleEveningCheckins();
        }
    }, 60 * 1000);

    // Cleanup old notifications at 3:00 AM daily
    cleanupJobInterval = setInterval(() => {
        const now = new Date();
        if (now.getHours() === 3 && now.getMinutes() === 0) {
            cleanupOldNotifications();
        }
    }, 60 * 1000);

    // Run initial scheduling
    scheduleMorningCheckins();
    scheduleEveningCheckins();

    logger.info('AI Companion notification scheduler started');
};

export const stopScheduler = () => {
    if (schedulerInterval) {
        clearInterval(schedulerInterval);
        schedulerInterval = null;
    }
    if (morningJobInterval) {
        clearInterval(morningJobInterval);
        morningJobInterval = null;
    }
    if (eveningJobInterval) {
        clearInterval(eveningJobInterval);
        eveningJobInterval = null;
    }
    if (cleanupJobInterval) {
        clearInterval(cleanupJobInterval);
        cleanupJobInterval = null;
    }
    logger.info('AI Companion notification scheduler stopped');
};

// ========== MANUAL TRIGGERS (for testing) ==========

export const triggerMorningCheckins = scheduleMorningCheckins;
export const triggerEveningCheckins = scheduleEveningCheckins;
export const triggerProcessPending = processPendingNotifications;
export const triggerCleanup = cleanupOldNotifications;

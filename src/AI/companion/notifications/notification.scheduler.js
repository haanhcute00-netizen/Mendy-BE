// =============================================
// AI COMPANION - NOTIFICATION SCHEDULER
// Cron jobs for automated notifications using node-cron
// =============================================

import cron from 'node-cron';
import * as notificationService from './notification.service.js';
import { logger } from '../../../utils/logger.js';

// Store cron jobs for cleanup
const cronJobs = {
    pendingProcessor: null,
    morningCheckin: null,
    eveningCheckin: null,
    cleanup: null,
    proactiveMessages: null
};

// ========== NOTIFICATION SENDER ==========

// This function should be called by Socket.io or push notification service
let notificationSender = null;

export const setNotificationSender = (sender) => {
    notificationSender = sender;
    logger.info('Notification sender configured');
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
    logger.info('Starting AI Companion notification scheduler with node-cron...');

    // Process pending notifications every minute
    // Cron: "* * * * *" = every minute
    cronJobs.pendingProcessor = cron.schedule('* * * * *', processPendingNotifications, {
        scheduled: true,
        timezone: 'Asia/Ho_Chi_Minh'
    });

    // Schedule morning check-ins at 6:00 AM daily
    // Cron: "0 6 * * *" = at 06:00 every day
    cronJobs.morningCheckin = cron.schedule('0 6 * * *', scheduleMorningCheckins, {
        scheduled: true,
        timezone: 'Asia/Ho_Chi_Minh'
    });

    // Schedule evening check-ins at 9:00 PM daily
    // Cron: "0 21 * * *" = at 21:00 every day
    cronJobs.eveningCheckin = cron.schedule('0 21 * * *', scheduleEveningCheckins, {
        scheduled: true,
        timezone: 'Asia/Ho_Chi_Minh'
    });

    // Cleanup old notifications at 3:00 AM daily
    // Cron: "0 3 * * *" = at 03:00 every day
    cronJobs.cleanup = cron.schedule('0 3 * * *', cleanupOldNotifications, {
        scheduled: true,
        timezone: 'Asia/Ho_Chi_Minh'
    });

    // Process proactive messages every 30 minutes
    // Cron: "*/30 * * * *" = every 30 minutes
    cronJobs.proactiveMessages = cron.schedule('*/30 * * * *', async () => {
        try {
            // Import dynamically to avoid circular dependency
            const scheduleService = await import('../schedule/schedule.service.js');
            await scheduleService.processProactiveMessages?.();
        } catch (error) {
            logger.error('Error processing proactive messages:', error);
        }
    }, {
        scheduled: true,
        timezone: 'Asia/Ho_Chi_Minh'
    });

    // Run initial scheduling
    scheduleMorningCheckins();
    scheduleEveningCheckins();

    logger.info('AI Companion notification scheduler started with node-cron');
    logger.info('Scheduled jobs: pending (1min), morning (6AM), evening (9PM), cleanup (3AM), proactive (30min)');
};

export const stopScheduler = () => {
    Object.entries(cronJobs).forEach(([name, job]) => {
        if (job) {
            job.stop();
            cronJobs[name] = null;
            logger.info(`Stopped cron job: ${name}`);
        }
    });
    logger.info('AI Companion notification scheduler stopped');
};

// ========== MANUAL TRIGGERS (for testing/admin) ==========

export const triggerMorningCheckins = scheduleMorningCheckins;
export const triggerEveningCheckins = scheduleEveningCheckins;
export const triggerProcessPending = processPendingNotifications;
export const triggerCleanup = cleanupOldNotifications;

// ========== SCHEDULER STATUS ==========

export const getSchedulerStatus = () => {
    return {
        running: Object.values(cronJobs).some(job => job !== null),
        jobs: Object.entries(cronJobs).map(([name, job]) => ({
            name,
            active: job !== null
        }))
    };
};

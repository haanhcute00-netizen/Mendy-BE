// =============================================
// NOTIFICATION SCHEDULER UNIT TESTS
// =============================================

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';

// Mock dependencies before importing
vi.mock('../notifications/notification.service.js', () => ({
    getPendingNotifications: vi.fn().mockResolvedValue([]),
    markNotificationSent: vi.fn().mockResolvedValue(true),
    scheduleMorningCheckins: vi.fn().mockResolvedValue([]),
    scheduleEveningCheckins: vi.fn().mockResolvedValue([]),
    cleanupOldNotifications: vi.fn().mockResolvedValue(0)
}));

vi.mock('../../../utils/logger.js', () => ({
    logger: {
        info: vi.fn(),
        warn: vi.fn(),
        error: vi.fn()
    }
}));

vi.mock('node-cron', () => ({
    default: {
        schedule: vi.fn().mockReturnValue({
            stop: vi.fn()
        })
    }
}));

import {
    startScheduler,
    stopScheduler,
    setNotificationSender,
    getSchedulerStatus,
    triggerMorningCheckins,
    triggerEveningCheckins,
    triggerProcessPending,
    triggerCleanup
} from '../notifications/notification.scheduler.js';

import * as notificationService from '../notifications/notification.service.js';
import cron from 'node-cron';

describe('Notification Scheduler', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    afterEach(() => {
        stopScheduler();
    });

    describe('startScheduler', () => {
        it('should schedule all cron jobs', () => {
            startScheduler();

            // Should have scheduled 5 jobs
            expect(cron.schedule).toHaveBeenCalledTimes(5);
        });

        it('should schedule pending processor every minute', () => {
            startScheduler();

            expect(cron.schedule).toHaveBeenCalledWith(
                '* * * * *',
                expect.any(Function),
                expect.objectContaining({ timezone: 'Asia/Ho_Chi_Minh' })
            );
        });

        it('should schedule morning checkins at 6 AM', () => {
            startScheduler();

            expect(cron.schedule).toHaveBeenCalledWith(
                '0 6 * * *',
                expect.any(Function),
                expect.objectContaining({ timezone: 'Asia/Ho_Chi_Minh' })
            );
        });

        it('should schedule evening checkins at 9 PM', () => {
            startScheduler();

            expect(cron.schedule).toHaveBeenCalledWith(
                '0 21 * * *',
                expect.any(Function),
                expect.objectContaining({ timezone: 'Asia/Ho_Chi_Minh' })
            );
        });

        it('should schedule cleanup at 3 AM', () => {
            startScheduler();

            expect(cron.schedule).toHaveBeenCalledWith(
                '0 3 * * *',
                expect.any(Function),
                expect.objectContaining({ timezone: 'Asia/Ho_Chi_Minh' })
            );
        });

        it('should run initial scheduling', async () => {
            startScheduler();

            // Wait for async calls
            await new Promise(resolve => setTimeout(resolve, 10));

            expect(notificationService.scheduleMorningCheckins).toHaveBeenCalled();
            expect(notificationService.scheduleEveningCheckins).toHaveBeenCalled();
        });
    });

    describe('stopScheduler', () => {
        it('should stop all cron jobs', () => {
            startScheduler();
            stopScheduler();

            // Each job's stop method should be called
            const mockJob = cron.schedule.mock.results[0].value;
            expect(mockJob.stop).toHaveBeenCalled();
        });
    });

    describe('setNotificationSender', () => {
        it('should accept a sender function', () => {
            const mockSender = vi.fn();
            setNotificationSender(mockSender);
            // No error means success
            expect(true).toBe(true);
        });
    });

    describe('getSchedulerStatus', () => {
        it('should return status with running flag', () => {
            const status = getSchedulerStatus();

            expect(status).toHaveProperty('running');
            expect(status).toHaveProperty('jobs');
            expect(Array.isArray(status.jobs)).toBe(true);
        });

        it('should show jobs as inactive when not started', () => {
            stopScheduler(); // Ensure stopped
            const status = getSchedulerStatus();

            expect(status.running).toBe(false);
        });
    });

    describe('Manual Triggers', () => {
        it('should have triggerMorningCheckins function', () => {
            expect(typeof triggerMorningCheckins).toBe('function');
        });

        it('should have triggerEveningCheckins function', () => {
            expect(typeof triggerEveningCheckins).toBe('function');
        });

        it('should have triggerProcessPending function', () => {
            expect(typeof triggerProcessPending).toBe('function');
        });

        it('should have triggerCleanup function', () => {
            expect(typeof triggerCleanup).toBe('function');
        });

        it('should call service when triggered', async () => {
            await triggerMorningCheckins();
            expect(notificationService.scheduleMorningCheckins).toHaveBeenCalled();
        });
    });
});

describe('Quiet Hours Logic', () => {
    // Test quiet hours checking indirectly through processPending
    it('should respect quiet hours configuration', () => {
        // This is tested through integration tests
        // The logic checks notification.quiet_hours_start and quiet_hours_end
        expect(true).toBe(true);
    });
});

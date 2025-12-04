// =============================================
// AI COMPANION MODULE - MAIN EXPORT
// =============================================

// Routes
export { default as aiCompanionRouter } from './routes.js';

// Services
export * as personaService from './persona/persona.service.js';
export * as notificationService from './notifications/notification.service.js';
export * as emotionService from './emotion/emotion.service.js';

// Emotion Analyzer
export * as emotionAnalyzer from './emotion/emotion.analyzer.js';

// Scheduler
export {
    startScheduler,
    stopScheduler,
    setNotificationSender,
    triggerMorningCheckins,
    triggerEveningCheckins,
    triggerProcessPending,
    triggerCleanup
} from './notifications/notification.scheduler.js';

// Schedule Service
export * as scheduleService from './schedule/schedule.service.js';

// Repos (for advanced usage)
export * as personaRepo from './persona/persona.repo.js';
export * as notificationRepo from './notifications/notification.repo.js';
export * as emotionRepo from './emotion/emotion.repo.js';
export * as scheduleRepo from './schedule/schedule.repo.js';

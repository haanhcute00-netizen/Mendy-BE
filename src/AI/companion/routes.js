// =============================================
// AI COMPANION - ROUTES
// =============================================

import { Router } from 'express';
import { auth, requireRole } from '../../middlewares/auth.js';

// Controllers
import * as personaController from './persona/persona.controller.js';
import * as notificationController from './notifications/notification.controller.js';
import * as emotionController from './emotion/emotion.controller.js';
import * as scheduleController from './schedule/schedule.controller.js';

const router = Router();

// ========== PUBLIC ROUTES ==========

// Get all available personas (public for display)
router.get('/personas', personaController.listPersonas);
router.get('/personas/:id', personaController.getPersona);

// ========== AUTHENTICATED ROUTES ==========

// User AI Settings
router.get('/settings', auth, personaController.getSettings);
router.post('/settings', auth, personaController.createOrUpdateSettings);
router.put('/settings', auth, personaController.updateSettings);

// Persona Selection
router.post('/persona/select', auth, personaController.selectPersona);

// User Context
router.get('/context', auth, personaController.getContext);
router.post('/context', auth, personaController.saveContext);

// User Notifications
router.get('/notifications', auth, notificationController.getNotifications);
router.post('/notifications/schedule', auth, notificationController.scheduleNotification);
router.post('/notifications/random', auth, notificationController.scheduleRandomMessage);
router.delete('/notifications/:id', auth, notificationController.deleteNotification);

// ========== EMOTION & MENTAL HEALTH ROUTES ==========

// Emotion Timeline & Stats
router.get('/emotion/timeline', auth, emotionController.getTimeline);
router.get('/emotion/stats', auth, emotionController.getStats);

// Mental State
router.get('/mental-state', auth, emotionController.getMentalState);

// Assessments
router.post('/assessment', auth, emotionController.createAssessment);
router.get('/assessment/latest', auth, emotionController.getLatestAssessment);
router.get('/assessment/history', auth, emotionController.getAssessmentHistory);

// Wellness Activities
router.post('/wellness/log', auth, emotionController.logWellnessActivity);
router.get('/wellness/history', auth, emotionController.getWellnessHistory);
router.get('/wellness/stats', auth, emotionController.getWellnessStats);
router.get('/wellness/suggestions', auth, emotionController.getWellnessSuggestions);

// Daily Check-in
router.post('/checkin', auth, emotionController.submitCheckin);
router.get('/checkin/today', auth, emotionController.getTodayCheckin);
router.get('/checkin/history', auth, emotionController.getCheckinHistory);

// ========== SCHEDULE & SMART AI ROUTES ==========

// User Schedules
router.post('/schedule', auth, scheduleController.createSchedule);
router.get('/schedule', auth, scheduleController.getSchedules);
router.get('/schedule/today', auth, scheduleController.getTodaySchedules);
router.get('/schedule/upcoming', auth, scheduleController.getUpcomingSchedules);
router.put('/schedule/:id', auth, scheduleController.updateSchedule);
router.post('/schedule/:id/complete', auth, scheduleController.completeSchedule);
router.delete('/schedule/:id', auth, scheduleController.deleteSchedule);

// AI Schedule Suggestions
router.get('/schedule/ai-suggest', auth, scheduleController.getAISuggestions);
router.post('/schedule/ai-suggest/accept', auth, scheduleController.acceptAISuggestion);

// Sleep Tracking
router.post('/sleep/log', auth, scheduleController.logSleep);
router.get('/sleep/history', auth, scheduleController.getSleepHistory);
router.get('/sleep/analysis', auth, scheduleController.getSleepAnalysis);

// Behavior Patterns
router.get('/patterns', auth, scheduleController.getPatterns);

// AI Suggestions
router.get('/suggestions', auth, scheduleController.getPendingSuggestions);
router.post('/suggestions/:id/respond', auth, scheduleController.respondToSuggestion);

// ========== ADMIN ROUTES ==========

router.post('/notifications/admin/schedule-morning', auth, requireRole('ADMIN'), notificationController.adminScheduleMorning);
router.post('/notifications/admin/schedule-evening', auth, requireRole('ADMIN'), notificationController.adminScheduleEvening);
router.get('/notifications/admin/pending', auth, requireRole('ADMIN'), notificationController.adminGetPending);
router.post('/notifications/admin/cleanup', auth, requireRole('ADMIN'), notificationController.adminCleanup);

// Admin - Mental Health Monitoring
router.get('/admin/users-needing-attention', auth, requireRole('ADMIN'), emotionController.adminGetUsersNeedingAttention);

// Admin - Proactive AI
router.post('/admin/generate-proactive', auth, requireRole('ADMIN'), scheduleController.adminGenerateProactive);
router.get('/admin/proactive-pending', auth, requireRole('ADMIN'), scheduleController.adminGetProactivePending);

export default router;

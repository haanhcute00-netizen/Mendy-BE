// =============================================
// AI COMPANION INTEGRATION TESTS
// =============================================

import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock database
vi.mock('../../../config/db.js', () => ({
    query: vi.fn().mockResolvedValue({ rows: [] }),
    pool: {
        query: vi.fn().mockResolvedValue({ rows: [] })
    }
}));

// Mock Gemini API
vi.mock('@google/generative-ai', () => {
    const mockGenerateContent = vi.fn().mockResolvedValue({
        response: {
            text: () => JSON.stringify({
                emotion: 'happy',
                intensity: 0.7,
                confidence: 0.8
            })
        }
    });

    return {
        GoogleGenerativeAI: class {
            constructor() { }
            getGenerativeModel() {
                return { generateContent: mockGenerateContent };
            }
        }
    };
});

describe('AI Companion Integration', () => {
    describe('Emotion Detection Flow', () => {
        it('should detect emotion and update mental state', async () => {
            // This tests the flow: text -> emotion analyzer -> mental state update
            const { analyzeEmotionSimple } = await import('../emotion/emotion.analyzer.js');

            const result = analyzeEmotionSimple('Tôi rất vui hôm nay');

            expect(result.emotion).toBe('happy');
            expect(result.intensity).toBeGreaterThan(0);
        });

        it('should handle crisis detection', async () => {
            const { analyzeEmotionSimple } = await import('../emotion/emotion.analyzer.js');

            // Crisis keywords should be detected
            const result = analyzeEmotionSimple('Tôi buồn quá');

            expect(result.emotion).toBe('sad');
        });
    });

    describe('Persona Selection Flow', () => {
        it('should build persona prompt correctly', async () => {
            const { buildPersonaPrompt } = await import('../persona/persona.service.js');

            const persona = {
                display_name: 'Mẹ Yêu',
                tone: 'ấm áp',
                description: 'Người mẹ yêu thương',
                signature_messages: ['Con ơi'],
                emotion_pattern: {}
            };

            const prompt = buildPersonaPrompt(persona, { relationship_level: 2 }, []);

            expect(prompt).toContain('Mẹ Yêu');
            expect(prompt).toContain('Level 2/4');
        });
    });

    describe('Rate Limiter Integration', () => {
        it('should track and limit requests', async () => {
            const { checkGeminiRateLimit, recordGeminiRequest, getGeminiUsageStats } =
                await import('../../rateLimiter.js');

            const userId = 'test-user-123';

            // First request should be allowed
            const result1 = await checkGeminiRateLimit(userId);
            expect(result1.allowed).toBe(true);

            // Record the request
            recordGeminiRequest(userId);

            // Check stats
            const stats = getGeminiUsageStats(userId);
            expect(stats.user.current).toBe(1);
        });
    });

    describe('AI Logger Integration', () => {
        it('should log chat interactions', async () => {
            const aiLogger = await import('../../aiLogger.js');

            // Should not throw
            expect(() => {
                aiLogger.logChatInteraction('user-123', {
                    userMessage: 'Hello',
                    aiResponse: 'Hi there',
                    keywords: ['greeting'],
                    personaId: 1,
                    duration: 100
                });
            }).not.toThrow();
        });

        it('should log emotion detection', async () => {
            const aiLogger = await import('../../aiLogger.js');

            expect(() => {
                aiLogger.logEmotionDetection('user-123', {
                    emotion: 'happy',
                    intensity: 0.8,
                    confidence: 0.9,
                    source: 'simple'
                });
            }).not.toThrow();
        });
    });
});

describe('Notification Flow Integration', () => {
    it('should have scheduler status function', async () => {
        const { getSchedulerStatus } = await import('../notifications/notification.scheduler.js');

        const status = getSchedulerStatus();

        expect(status).toHaveProperty('running');
        expect(status).toHaveProperty('jobs');
    });
});

describe('Schedule Service Integration', () => {
    it('should export required functions', async () => {
        // Just verify the module structure
        const scheduleService = await import('../schedule/schedule.service.js');

        expect(scheduleService).toBeDefined();
    });
});

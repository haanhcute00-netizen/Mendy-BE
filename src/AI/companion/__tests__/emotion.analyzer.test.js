// =============================================
// EMOTION ANALYZER UNIT TESTS
// =============================================

import { describe, it, expect, vi, beforeEach } from 'vitest';
import {
    analyzeEmotionSimple,
    analyzeEmotionTrend,
    isNegativeEmotion,
    isPositiveEmotion,
    getEmotionCategory
} from '../emotion/emotion.analyzer.js';

describe('Emotion Analyzer', () => {
    describe('analyzeEmotionSimple', () => {
        it('should detect happy emotion from Vietnamese keywords', () => {
            const result = analyzeEmotionSimple('Hôm nay tôi rất vui và hạnh phúc');
            expect(result.emotion).toBe('happy');
            expect(result.intensity).toBeGreaterThan(0);
        });

        it('should detect sad emotion', () => {
            const result = analyzeEmotionSimple('Tôi cảm thấy buồn và cô đơn');
            expect(result.emotion).toBe('sad');
        });

        it('should detect anxious emotion', () => {
            const result = analyzeEmotionSimple('Tôi lo lắng về công việc, sợ bị sa thải');
            expect(result.emotion).toBe('anxious');
        });

        it('should detect stressed emotion', () => {
            const result = analyzeEmotionSimple('Công việc quá áp lực, tôi stress quá');
            expect(result.emotion).toBe('stressed');
        });

        it('should detect angry emotion', () => {
            const result = analyzeEmotionSimple('Tôi rất tức giận và bực mình');
            expect(result.emotion).toBe('angry');
        });

        it('should detect tired emotion', () => {
            const result = analyzeEmotionSimple('Tôi mệt mỏi và buồn ngủ');
            expect(result.emotion).toBe('tired');
        });

        it('should return neutral for ambiguous text', () => {
            const result = analyzeEmotionSimple('xyz abc 123');
            expect(result.emotion).toBe('neutral');
            expect(result.confidence).toBeLessThan(0.5);
        });

        it('should handle English keywords', () => {
            const result = analyzeEmotionSimple('I am so happy and excited today');
            expect(result.emotion).toBe('happy');
        });

        it('should detect multiple emotions and pick strongest', () => {
            const result = analyzeEmotionSimple('Tôi vui nhưng cũng lo lắng và sợ');
            // Should pick the one with more keywords
            expect(['happy', 'anxious']).toContain(result.emotion);
        });

        it('should calculate intensity based on keyword count', () => {
            const lowIntensity = analyzeEmotionSimple('vui');
            const highIntensity = analyzeEmotionSimple('vui hạnh phúc tuyệt vời thích yêu');
            expect(highIntensity.intensity).toBeGreaterThan(lowIntensity.intensity);
        });
    });

    describe('analyzeEmotionTrend', () => {
        it('should return insufficient_data for less than 3 logs', () => {
            const result = analyzeEmotionTrend([{ emotion: 'happy' }]);
            expect(result.trend).toBe('insufficient_data');
        });

        it('should detect improving trend', () => {
            const logs = [
                { emotion: 'happy' },
                { emotion: 'happy' },
                { emotion: 'excited' },
                { emotion: 'sad' },
                { emotion: 'sad' },
                { emotion: 'anxious' }
            ];
            const result = analyzeEmotionTrend(logs);
            expect(result.trend).toBe('improving');
        });

        it('should detect declining trend', () => {
            const logs = [
                { emotion: 'sad' },
                { emotion: 'anxious' },
                { emotion: 'stressed' },
                { emotion: 'happy' },
                { emotion: 'happy' },
                { emotion: 'excited' }
            ];
            const result = analyzeEmotionTrend(logs);
            expect(result.trend).toBe('declining');
        });

        it('should detect stable trend', () => {
            const logs = [
                { emotion: 'neutral' },
                { emotion: 'neutral' },
                { emotion: 'neutral' },
                { emotion: 'neutral' },
                { emotion: 'neutral' },
                { emotion: 'neutral' }
            ];
            const result = analyzeEmotionTrend(logs);
            expect(result.trend).toBe('stable');
        });

        it('should calculate change value', () => {
            const logs = [
                { emotion: 'happy' },
                { emotion: 'happy' },
                { emotion: 'sad' },
                { emotion: 'sad' }
            ];
            const result = analyzeEmotionTrend(logs);
            expect(typeof result.change).toBe('number');
            expect(result.recent_avg).toBeDefined();
            expect(result.older_avg).toBeDefined();
        });
    });

    describe('Emotion Classification Helpers', () => {
        describe('isNegativeEmotion', () => {
            it('should return true for negative emotions', () => {
                expect(isNegativeEmotion('sad')).toBe(true);
                expect(isNegativeEmotion('anxious')).toBe(true);
                expect(isNegativeEmotion('stressed')).toBe(true);
                expect(isNegativeEmotion('angry')).toBe(true);
                expect(isNegativeEmotion('tired')).toBe(true);
            });

            it('should return false for positive/neutral emotions', () => {
                expect(isNegativeEmotion('happy')).toBe(false);
                expect(isNegativeEmotion('excited')).toBe(false);
                expect(isNegativeEmotion('neutral')).toBe(false);
            });
        });

        describe('isPositiveEmotion', () => {
            it('should return true for positive emotions', () => {
                expect(isPositiveEmotion('happy')).toBe(true);
                expect(isPositiveEmotion('excited')).toBe(true);
            });

            it('should return false for negative/neutral emotions', () => {
                expect(isPositiveEmotion('sad')).toBe(false);
                expect(isPositiveEmotion('neutral')).toBe(false);
            });
        });

        describe('getEmotionCategory', () => {
            it('should categorize emotions correctly', () => {
                expect(getEmotionCategory('happy')).toBe('positive');
                expect(getEmotionCategory('sad')).toBe('negative');
                expect(getEmotionCategory('neutral')).toBe('neutral');
                expect(getEmotionCategory('unknown')).toBe('neutral');
            });
        });
    });
});

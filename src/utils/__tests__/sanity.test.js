// Sanity test to verify Vitest is working
import { describe, it, expect } from 'vitest';

describe('Vitest Setup', () => {
    it('should run tests successfully', () => {
        expect(true).toBe(true);
    });

    it('should perform basic math', () => {
        expect(2 + 2).toBe(4);
    });

    it('should handle async operations', async () => {
        const result = await Promise.resolve('success');
        expect(result).toBe('success');
    });
});

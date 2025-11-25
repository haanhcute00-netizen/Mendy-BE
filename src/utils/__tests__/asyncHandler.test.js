// Test for asyncHandler utility
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { asyncHandler } from '../asyncHandler.js';

describe('asyncHandler', () => {
    let mockReq, mockRes, mockNext;

    beforeEach(() => {
        mockReq = {};
        mockRes = {
            status: vi.fn().mockReturnThis(),
            json: vi.fn().mockReturnThis()
        };
        mockNext = vi.fn();
    });

    it('should call the handler function with req, res, next', async () => {
        const handler = vi.fn().mockResolvedValue('success');
        const wrappedHandler = asyncHandler(handler);

        await wrappedHandler(mockReq, mockRes, mockNext);

        expect(handler).toHaveBeenCalledWith(mockReq, mockRes, mockNext);
    });

    it('should call next with error if handler throws', async () => {
        const error = new Error('Test error');
        const handler = vi.fn().mockRejectedValue(error);
        const wrappedHandler = asyncHandler(handler);

        await wrappedHandler(mockReq, mockRes, mockNext);

        expect(mockNext).toHaveBeenCalledWith(error);
    });

    it('should not call next if handler succeeds', async () => {
        const handler = vi.fn().mockResolvedValue('success');
        const wrappedHandler = asyncHandler(handler);

        await wrappedHandler(mockReq, mockRes, mockNext);

        expect(mockNext).not.toHaveBeenCalled();
    });
});

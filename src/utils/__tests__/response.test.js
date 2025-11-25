// Test for response utility functions
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { success, created, unauthorized, forbidden, notFound, apiStatus, serverError, validationError } from '../response.js';

describe('Response Utilities', () => {
    let mockRes;

    beforeEach(() => {
        mockRes = {
            status: vi.fn().mockReturnThis(),
            json: vi.fn().mockReturnThis(),
            send: vi.fn().mockReturnThis()
        };
    });

    describe('success()', () => {
        it('should return 200 status with success response', () => {
            const message = 'Success';
            const data = { id: 1, name: 'Test' };

            success(mockRes, message, data);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: true,
                    message,
                    data,
                    timestamp: expect.any(String)
                })
            );
        });
    });

    describe('created()', () => {
        it('should return 201 status', () => {
            const data = { id: 1 };

            created(mockRes, 'Created', data);

            expect(mockRes.status).toHaveBeenCalledWith(201);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: true,
                    message: 'Created',
                    data
                })
            );
        });
    });

    describe('unauthorized()', () => {
        it('should return 401 status', () => {
            unauthorized(mockRes, 'Not authenticated');

            expect(mockRes.status).toHaveBeenCalledWith(401);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    message: 'Not authenticated'
                })
            );
        });
    });

    describe('forbidden()', () => {
        it('should return 403 status', () => {
            forbidden(mockRes, 'Access denied');

            expect(mockRes.status).toHaveBeenCalledWith(403);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    message: 'Access denied'
                })
            );
        });
    });

    describe('notFound()', () => {
        it('should return 404 status', () => {
            notFound(mockRes, 'Resource not found');

            expect(mockRes.status).toHaveBeenCalledWith(404);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    message: 'Resource not found'
                })
            );
        });
    });

    describe('apiStatus()', () => {
        it('should return response with ok flag', () => {
            const data = { result: 'success' };

            apiStatus(mockRes, true, 'Operation successful', data);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    ok: true,
                    message: 'Operation successful',
                    result: 'success',
                    timestamp: expect.any(String)
                })
            );
        });
    });

    describe('serverError()', () => {
        it('should return 500 status', () => {
            serverError(mockRes, 'Internal error');

            expect(mockRes.status).toHaveBeenCalledWith(500);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    message: 'Internal error'
                })
            );
        });
    });

    describe('validationError()', () => {
        it('should return 422 status with validation errors', () => {
            const errors = { email: 'Invalid email' };

            validationError(mockRes, 'Validation failed', errors);

            expect(mockRes.status).toHaveBeenCalledWith(422);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    message: 'Validation failed',
                    errors
                })
            );
        });
    });
});

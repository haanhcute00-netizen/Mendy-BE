// src/modules/filter-search-expert/tests/validation.test.js
// Unit tests for expert search validation middleware
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { validateAdvancedSearch, validateQuickFilter } from '../validation.js';

describe('Expert Search Validation', () => {
    let mockReq;
    let mockRes;
    let mockNext;

    beforeEach(() => {
        mockReq = { query: {} };
        mockRes = {
            status: vi.fn().mockReturnThis(),
            json: vi.fn().mockReturnThis()
        };
        mockNext = vi.fn();
    });

    describe('validateAdvancedSearch', () => {
        it('should pass valid request', () => {
            mockReq.query = {
                keyword: 'test',
                minPrice: '100000',
                maxPrice: '500000',
                minRating: '4.0',
                page: '1',
                limit: '20'
            };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
            expect(mockRes.status).not.toHaveBeenCalled();
        });

        it('should reject negative numeric values', () => {
            mockReq.query = { minPrice: '-100' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    errors: expect.arrayContaining(['minPrice must be a positive number'])
                })
            );
        });

        it('should reject invalid rating range', () => {
            mockReq.query = { minRating: '6' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining(['minRating must be between 0 and 5'])
                })
            );
        });

        it('should reject invalid percentage values', () => {
            mockReq.query = { minCompletionRate: '150' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining(['minCompletionRate must be between 0 and 100'])
                })
            );
        });

        it('should reject lastActiveWithin over 10080', () => {
            mockReq.query = { lastActiveWithin: '20000' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining(['lastActiveWithin must be at most 10080 minutes (1 week)'])
                })
            );
        });

        it('should reject invalid pagination', () => {
            mockReq.query = { page: '0', limit: '200' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining([
                        'page must be a positive integer >= 1',
                        'limit must be between 1 and 100'
                    ])
                })
            );
        });

        it('should reject invalid sortBy', () => {
            mockReq.query = { sortBy: 'invalid_sort' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining([
                        expect.stringContaining('sortBy must be one of')
                    ])
                })
            );
        });

        it('should reject invalid kycStatus', () => {
            mockReq.query = { kycStatus: 'INVALID' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining([
                        expect.stringContaining('kycStatus must be one of')
                    ])
                })
            );
        });

        it('should reject invalid gender', () => {
            mockReq.query = { gender: 'INVALID' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining([
                        expect.stringContaining('gender must be one of')
                    ])
                })
            );
        });

        it('should reject keyword over 200 characters', () => {
            mockReq.query = { keyword: 'a'.repeat(201) };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining(['keyword must be less than 200 characters'])
                })
            );
        });

        it('should reject invalid boolean values', () => {
            mockReq.query = { isOnline: 'yes' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining(["isOnline must be 'true' or 'false'"])
                })
            );
        });

        it('should reject invalid date format', () => {
            mockReq.query = { availableFrom: 'not-a-date' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining(['availableFrom must be a valid ISO date'])
                })
            );
        });

        it('should reject availableFrom after availableTo', () => {
            mockReq.query = {
                availableFrom: '2025-12-15T10:00:00Z',
                availableTo: '2025-12-14T10:00:00Z'
            };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining(['availableFrom must be before availableTo'])
                })
            );
        });

        it('should support snake_case parameters', () => {
            mockReq.query = {
                min_price: '100000',
                max_price: '500000',
                min_rating: '4.0',
                sort_by: 'rating',
                sort_order: 'DESC'
            };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
        });

        it('should accept valid kycStatus array', () => {
            mockReq.query = { kycStatus: 'VERIFIED,PENDING' };

            validateAdvancedSearch(mockReq, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
        });
    });

    describe('validateQuickFilter', () => {
        it('should pass valid quick filter', () => {
            mockReq.query = { filter: 'top_rated', page: '1', limit: '10' };

            validateQuickFilter(mockReq, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
        });

        it('should reject invalid filter value', () => {
            mockReq.query = { filter: 'invalid_filter' };

            validateQuickFilter(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    errors: expect.arrayContaining([
                        expect.stringContaining('filter must be one of')
                    ])
                })
            );
        });

        it('should pass without filter (returns all)', () => {
            mockReq.query = {};

            validateQuickFilter(mockReq, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
        });

        it('should reject invalid pagination in quick filter', () => {
            mockReq.query = { filter: 'top_rated', page: '-1', limit: '500' };

            validateQuickFilter(mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
        });
    });
});

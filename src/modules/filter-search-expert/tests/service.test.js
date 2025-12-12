// src/modules/filter-search-expert/tests/service.test.js
// Unit tests for expert search service
import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock the repo module
vi.mock('../repo.js', () => ({
    advancedSearchExperts: vi.fn(),
    getSearchFacets: vi.fn(),
    getExpertFullDetails: vi.fn(),
    getSimilarExperts: vi.fn()
}));

// Mock cache
vi.mock('../../../utils/cache.js', () => ({
    cache: {
        get: vi.fn(),
        set: vi.fn(),
        delete: vi.fn()
    }
}));

// Mock logger
vi.mock('../../../utils/logger.js', () => ({
    logger: {
        info: vi.fn(),
        error: vi.fn(),
        debug: vi.fn()
    }
}));

// Import after mocks
import * as SearchService from '../service.js';
import * as SearchRepo from '../repo.js';
import { cache } from '../../../utils/cache.js';

describe('Expert Search Service', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('normalizeFilters', () => {
        it('should convert string arrays to arrays', async () => {
            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [],
                pagination: { page: 1, limit: 20, total: 0, totalPages: 0, hasNext: false, hasPrev: false }
            });

            await SearchService.advancedSearch({
                specialties: 'psychology,counseling',
                skillIds: '1,2,3'
            });

            expect(SearchRepo.advancedSearchExperts).toHaveBeenCalledWith(
                expect.objectContaining({
                    specialties: ['psychology', 'counseling'],
                    skillIds: [1, 2, 3]
                })
            );
        });

        it('should convert numeric strings to numbers', async () => {
            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [],
                pagination: { page: 1, limit: 20, total: 0, totalPages: 0, hasNext: false, hasPrev: false }
            });

            await SearchService.advancedSearch({
                minPrice: '100000',
                maxPrice: '500000',
                minRating: '4.0'
            });

            expect(SearchRepo.advancedSearchExperts).toHaveBeenCalledWith(
                expect.objectContaining({
                    minPrice: 100000,
                    maxPrice: 500000,
                    minRating: 4.0
                })
            );
        });

        it('should convert boolean strings to booleans', async () => {
            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [],
                pagination: { page: 1, limit: 20, total: 0, totalPages: 0, hasNext: false, hasPrev: false }
            });

            await SearchService.advancedSearch({
                isOnline: 'true',
                hasCertification: 'false'
            });

            expect(SearchRepo.advancedSearchExperts).toHaveBeenCalledWith(
                expect.objectContaining({
                    isOnline: true,
                    hasCertification: false
                })
            );
        });

        it('should enforce pagination limits', async () => {
            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [],
                pagination: { page: 1, limit: 100, total: 0, totalPages: 0, hasNext: false, hasPrev: false }
            });

            await SearchService.advancedSearch({
                page: -5,
                limit: 500
            });

            expect(SearchRepo.advancedSearchExperts).toHaveBeenCalledWith(
                expect.objectContaining({
                    page: 1,
                    limit: 100
                })
            );
        });
    });

    describe('getAvailabilityStatus', () => {
        it('should return online for online experts', async () => {
            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [{ is_online: true, last_active_at: new Date() }],
                pagination: { page: 1, limit: 20, total: 1, totalPages: 1, hasNext: false, hasPrev: false }
            });

            const result = await SearchService.advancedSearch({});
            expect(result.experts[0].availability_status).toBe('online');
        });

        it('should return offline for experts without recent activity', async () => {
            const oldDate = new Date();
            oldDate.setDate(oldDate.getDate() - 7);

            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [{ is_online: false, last_active_at: oldDate }],
                pagination: { page: 1, limit: 20, total: 1, totalPages: 1, hasNext: false, hasPrev: false }
            });

            const result = await SearchService.advancedSearch({});
            expect(result.experts[0].availability_status).toBe('offline');
        });
    });

    describe('getExperienceLevel', () => {
        it('should return top_rated for high performers', async () => {
            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [{ total_sessions: 150, rating_avg: 4.8 }],
                pagination: { page: 1, limit: 20, total: 1, totalPages: 1, hasNext: false, hasPrev: false }
            });

            const result = await SearchService.advancedSearch({});
            expect(result.experts[0].experience_level).toBe('top_rated');
        });

        it('should return new for beginners', async () => {
            SearchRepo.advancedSearchExperts.mockResolvedValue({
                experts: [{ total_sessions: 2, rating_avg: 4.0 }],
                pagination: { page: 1, limit: 20, total: 1, totalPages: 1, hasNext: false, hasPrev: false }
            });

            const result = await SearchService.advancedSearch({});
            expect(result.experts[0].experience_level).toBe('new');
        });
    });

    describe('getSearchFacets', () => {
        it('should return cached facets if available', async () => {
            const cachedFacets = { price_range: { min: 100, max: 1000 } };
            cache.get.mockReturnValue(cachedFacets);

            const result = await SearchService.getSearchFacets();

            expect(result).toEqual(cachedFacets);
            expect(SearchRepo.getSearchFacets).not.toHaveBeenCalled();
        });

        it('should fetch and cache facets if not cached', async () => {
            const dbFacets = { price_range: { min: 100, max: 1000 } };
            cache.get.mockReturnValue(null);
            SearchRepo.getSearchFacets.mockResolvedValue(dbFacets);

            const result = await SearchService.getSearchFacets();

            expect(result).toEqual(dbFacets);
            expect(SearchRepo.getSearchFacets).toHaveBeenCalled();
            expect(cache.set).toHaveBeenCalledWith('expert_search_facets', dbFacets, 300000);
        });
    });

    describe('getExpertFullDetails', () => {
        it('should throw 404 if expert not found', async () => {
            SearchRepo.getExpertFullDetails.mockResolvedValue(null);

            await expect(SearchService.getExpertFullDetails(999))
                .rejects.toThrow('Expert not found');
        });

        it('should return expert with computed fields', async () => {
            const mockExpert = {
                expert_id: 1,
                is_online: true,
                price_per_session: 200000,
                total_sessions: 50,
                rating_avg: 4.5,
                experience: [{ years: 5 }]
            };
            SearchRepo.getExpertFullDetails.mockResolvedValue(mockExpert);
            SearchRepo.getSimilarExperts.mockResolvedValue([]);

            const result = await SearchService.getExpertFullDetails(1);

            expect(result.availability_status).toBe('online');
            expect(result.experience_level).toBe('experienced');
            expect(result.total_experience_years).toBe(5);
            expect(result.similar_experts).toEqual([]);
        });
    });

    describe('invalidateFacetsCache', () => {
        it('should delete facets cache', () => {
            SearchService.invalidateFacetsCache();
            expect(cache.delete).toHaveBeenCalledWith('expert_search_facets');
        });
    });
});

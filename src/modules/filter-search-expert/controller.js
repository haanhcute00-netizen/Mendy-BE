// src/modules/filter-search-expert/controller.js
// Advanced Expert Search Controller
import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, failure } from "../../utils/response.js";
import { logger } from "../../utils/logger.js";
import * as SearchService from "./service.js";
import { SearchErrors, getErrorStatus } from "./errors.js";

/**
 * @route GET /api/v1/public/experts/search/advanced
 * @desc Advanced expert search with comprehensive filters
 * @access Public
 * 
 * Query Parameters:
 * - keyword: string - Full-text search in name, intro, specialties
 * - specialties: string (comma-separated) - Filter by specialties
 * - minPrice, maxPrice: number - Price range filter
 * - minRating, maxRating: number - Rating range filter (0-5)
 * - kycStatus: string - PENDING, VERIFIED, REJECTED (comma-separated for multiple)
 * - isOnline: boolean - Filter online experts only
 * - lastActiveWithin: number - Minutes since last active
 * - minCompletionRate: number - Minimum session completion rate (0-100)
 * - minAcceptanceRate: number - Minimum booking acceptance rate (0-100)
 * - maxResponseTime: number - Maximum response time in minutes
 * - minTotalSessions: number - Minimum completed sessions
 * - minTotalReviews: number - Minimum reviews count
 * - skillIds: string (comma-separated) - Filter by skill IDs
 * - skillCategories: string (comma-separated) - Filter by skill categories
 * - minExperienceYears: number - Minimum total experience years
 * - hasCertification: boolean - Has at least one certification
 * - certificationKeyword: string - Search in certification names
 * - educationKeyword: string - Search in education/institution
 * - audienceIds: string (comma-separated) - Filter by target audience
 * - domainIds: string (comma-separated) - Filter by domains
 * - gender: string - MALE, FEMALE, OTHER, UNSPECIFIED
 * - availableFrom, availableTo: ISO datetime - Check availability in time range
 * - sortBy: string - rating, price, price_low, sessions, response_time, active_score, reviews, completion_rate, newest
 * - sortOrder: string - ASC, DESC
 * - page: number - Page number (default: 1)
 * - limit: number - Items per page (default: 20, max: 100)
 */
export const advancedSearch = asyncHandler(async (req, res) => {
    const startTime = Date.now();

    try {
        const filters = {
            // Text search
            keyword: req.query.keyword || req.query.q,

            // Basic filters
            specialties: req.query.specialties,
            minPrice: req.query.minPrice || req.query.min_price,
            maxPrice: req.query.maxPrice || req.query.max_price,
            minRating: req.query.minRating || req.query.min_rating,
            maxRating: req.query.maxRating || req.query.max_rating,
            kycStatus: req.query.kycStatus || req.query.kyc_status,

            // Status filters
            isOnline: req.query.isOnline || req.query.is_online,
            lastActiveWithin: req.query.lastActiveWithin || req.query.last_active_within,

            // Performance filters
            minCompletionRate: req.query.minCompletionRate || req.query.min_completion_rate,
            minAcceptanceRate: req.query.minAcceptanceRate || req.query.min_acceptance_rate,
            maxResponseTime: req.query.maxResponseTime || req.query.max_response_time,
            minTotalSessions: req.query.minTotalSessions || req.query.min_total_sessions,
            minTotalReviews: req.query.minTotalReviews || req.query.min_total_reviews,

            // Skills & Experience
            skillIds: req.query.skillIds || req.query.skill_ids,
            skillCategories: req.query.skillCategories || req.query.skill_categories,
            minExperienceYears: req.query.minExperienceYears || req.query.min_experience_years,

            // Education & Certification
            hasCertification: req.query.hasCertification || req.query.has_certification,
            certificationKeyword: req.query.certificationKeyword || req.query.certification_keyword,
            educationKeyword: req.query.educationKeyword || req.query.education_keyword,

            // Audience & Domain
            audienceIds: req.query.audienceIds || req.query.audience_ids,
            domainIds: req.query.domainIds || req.query.domain_ids,

            // Profile filters
            gender: req.query.gender,

            // Availability
            availableFrom: req.query.availableFrom || req.query.available_from,
            availableTo: req.query.availableTo || req.query.available_to,

            // Sorting
            sortBy: req.query.sortBy || req.query.sort_by || 'rating',
            sortOrder: req.query.sortOrder || req.query.sort_order || 'DESC',

            // Pagination
            page: parseInt(req.query.page) || 1,
            limit: parseInt(req.query.limit) || 20
        };

        const result = await SearchService.advancedSearch(filters);

        // Log request metrics
        const duration = Date.now() - startTime;
        logger.info({
            type: 'api_request',
            endpoint: '/expert-search/advanced',
            method: 'GET',
            ip: req.ip,
            duration: `${duration}ms`,
            resultCount: result.experts.length,
            totalCount: result.pagination.total
        });

        return success(res, "experts.search.success", result);
    } catch (error) {
        const duration = Date.now() - startTime;
        logger.error({
            type: 'api_error',
            endpoint: '/expert-search/advanced',
            error: error.message,
            code: error.code || SearchErrors.INTERNAL_ERROR.code,
            duration: `${duration}ms`
        });

        return failure(res, error.message, {
            code: error.code || SearchErrors.DB_ERROR.code,
            status: getErrorStatus(error)
        });
    }
});

/**
 * @route GET /api/v1/public/experts/search/facets
 * @desc Get search facets/aggregations for filter UI
 * @access Public
 */
export const getSearchFacets = asyncHandler(async (req, res) => {
    const startTime = Date.now();

    try {
        const facets = await SearchService.getSearchFacets();

        const duration = Date.now() - startTime;
        logger.info({
            type: 'api_request',
            endpoint: '/expert-search/facets',
            method: 'GET',
            ip: req.ip,
            duration: `${duration}ms`
        });

        return success(res, "experts.facets.success", facets);
    } catch (error) {
        const duration = Date.now() - startTime;
        logger.error({
            type: 'api_error',
            endpoint: '/expert-search/facets',
            error: error.message,
            duration: `${duration}ms`
        });

        return failure(res, error.message, {
            code: error.code || SearchErrors.DB_ERROR.code,
            status: getErrorStatus(error)
        });
    }
});

/**
 * @route GET /api/v1/public/experts/:expertId/full
 * @desc Get expert full details with all related data
 * @access Public
 */
export const getExpertFullDetails = asyncHandler(async (req, res) => {
    const { expertId } = req.params;
    const startTime = Date.now();

    try {
        const expert = await SearchService.getExpertFullDetails(parseInt(expertId));

        const duration = Date.now() - startTime;
        logger.info({
            type: 'api_request',
            endpoint: `/expert-search/${expertId}/full`,
            method: 'GET',
            ip: req.ip,
            duration: `${duration}ms`
        });

        return success(res, "experts.details.success", expert);
    } catch (error) {
        const duration = Date.now() - startTime;
        logger.error({
            type: 'api_error',
            endpoint: `/expert-search/${expertId}/full`,
            error: error.message,
            duration: `${duration}ms`
        });

        return failure(res, error.message, {
            code: error.code || SearchErrors.EXPERT_NOT_FOUND.code,
            status: getErrorStatus(error)
        });
    }
});

/**
 * @route GET /api/v1/public/experts/:expertId/similar
 * @desc Get similar experts
 * @access Public
 */
export const getSimilarExperts = asyncHandler(async (req, res) => {
    const { expertId } = req.params;
    const limit = parseInt(req.query.limit) || 5;
    const startTime = Date.now();

    try {
        const similarExperts = await SearchService.getSimilarExperts(parseInt(expertId), limit);

        const duration = Date.now() - startTime;
        logger.info({
            type: 'api_request',
            endpoint: `/expert-search/${expertId}/similar`,
            method: 'GET',
            ip: req.ip,
            duration: `${duration}ms`,
            resultCount: similarExperts.length
        });

        return success(res, "experts.similar.success", similarExperts);
    } catch (error) {
        const duration = Date.now() - startTime;
        logger.error({
            type: 'api_error',
            endpoint: `/expert-search/${expertId}/similar`,
            error: error.message,
            duration: `${duration}ms`
        });

        return failure(res, error.message, {
            code: error.code || SearchErrors.DB_ERROR.code,
            status: getErrorStatus(error)
        });
    }
});

/**
 * @route GET /api/v1/public/experts/quick-filters
 * @desc Get experts with predefined quick filters
 * @access Public
 */
export const quickFilterExperts = asyncHandler(async (req, res) => {
    const { filter } = req.query;
    const startTime = Date.now();

    try {
        let filters = {
            page: parseInt(req.query.page) || 1,
            limit: parseInt(req.query.limit) || 10
        };

        // Predefined quick filters
        switch (filter) {
            case 'top_rated':
                filters.minRating = 4.5;
                filters.minTotalReviews = 5;
                filters.sortBy = 'rating';
                break;

            case 'most_experienced':
                filters.minTotalSessions = 50;
                filters.sortBy = 'sessions';
                break;

            case 'online_now':
                filters.isOnline = true;
                filters.sortBy = 'active_score';
                break;

            case 'recently_active':
                filters.lastActiveWithin = 30; // 30 minutes
                filters.sortBy = 'active_score';
                break;

            case 'fast_responders':
                filters.maxResponseTime = 15; // 15 minutes
                filters.sortBy = 'response_time';
                filters.sortOrder = 'ASC';
                break;

            case 'budget_friendly':
                filters.maxPrice = 200000;
                filters.sortBy = 'price_low';
                break;

            case 'premium':
                filters.minPrice = 500000;
                filters.minRating = 4.0;
                filters.sortBy = 'rating';
                break;

            case 'verified':
                filters.kycStatus = 'VERIFIED';
                filters.sortBy = 'rating';
                break;

            case 'new_experts':
                filters.sortBy = 'newest';
                break;

            case 'high_completion':
                filters.minCompletionRate = 90;
                filters.sortBy = 'completion_rate';
                break;

            default:
                // No special filter, return all
                break;
        }

        const result = await SearchService.advancedSearch(filters);

        const duration = Date.now() - startTime;
        logger.info({
            type: 'api_request',
            endpoint: '/expert-search/quick-filters',
            method: 'GET',
            ip: req.ip,
            filter: filter || 'none',
            duration: `${duration}ms`,
            resultCount: result.experts.length
        });

        return success(res, "experts.quick_filter.success", {
            filter_applied: filter || 'none',
            ...result
        });
    } catch (error) {
        const duration = Date.now() - startTime;
        logger.error({
            type: 'api_error',
            endpoint: '/expert-search/quick-filters',
            filter: filter || 'none',
            error: error.message,
            duration: `${duration}ms`
        });

        return failure(res, error.message, {
            code: error.code || SearchErrors.DB_ERROR.code,
            status: getErrorStatus(error)
        });
    }
});

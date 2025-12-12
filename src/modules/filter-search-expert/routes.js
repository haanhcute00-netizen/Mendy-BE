// src/modules/filter-search-expert/routes.js
// Public Expert Search Routes - No authentication required
import { Router } from "express";
import { createRateLimiter } from "../../utils/rateLimiter.js";
import * as SearchController from "./controller.js";
import { validateAdvancedSearch, validateQuickFilter } from "./validation.js";

const router = Router();

// ========== RATE LIMITERS ==========

/**
 * Rate limiter for advanced search - stricter limit
 * 30 requests per minute per IP
 */
const advancedSearchLimiter = createRateLimiter({
    windowMs: 60 * 1000, // 1 minute
    max: 30,
    message: {
        success: false,
        error: 'Too many search requests, please try again later',
        code: 'SEARCH_RATE_LIMITED'
    }
});

/**
 * Rate limiter for general search endpoints
 * 60 requests per minute per IP
 */
const generalSearchLimiter = createRateLimiter({
    windowMs: 60 * 1000, // 1 minute
    max: 60,
    message: {
        success: false,
        error: 'Too many requests, please try again later',
        code: 'SEARCH_RATE_LIMITED'
    }
});

/**
 * Rate limiter for facets - less strict (data rarely changes)
 * 120 requests per minute per IP
 */
const facetsLimiter = createRateLimiter({
    windowMs: 60 * 1000, // 1 minute
    max: 120,
    message: {
        success: false,
        error: 'Too many requests, please try again later',
        code: 'SEARCH_RATE_LIMITED'
    }
});

// ========== ADVANCED SEARCH ENDPOINTS ==========

/**
 * @route GET /api/v1/expert-search/advanced
 * @desc Advanced expert search with 30+ filter criteria
 * @access Public
 * @rateLimit 30 requests/minute
 */
router.get("/advanced", advancedSearchLimiter, validateAdvancedSearch, SearchController.advancedSearch);

/**
 * @route GET /api/v1/expert-search/facets
 * @desc Get search facets/aggregations for filter UI
 * @access Public
 * @rateLimit 120 requests/minute
 */
router.get("/facets", facetsLimiter, SearchController.getSearchFacets);

/**
 * @route GET /api/v1/expert-search/quick-filters
 * @desc Get experts with predefined quick filters
 * @access Public
 * @query filter - top_rated|most_experienced|online_now|recently_active|fast_responders|budget_friendly|premium|verified|new_experts|high_completion
 * @rateLimit 60 requests/minute
 */
router.get("/quick-filters", generalSearchLimiter, validateQuickFilter, SearchController.quickFilterExperts);

/**
 * @route GET /api/v1/expert-search/:expertId/full
 * @desc Get expert full details with all related data
 * @access Public
 * @rateLimit 60 requests/minute
 */
router.get("/:expertId/full", generalSearchLimiter, SearchController.getExpertFullDetails);

/**
 * @route GET /api/v1/expert-search/:expertId/similar
 * @desc Get similar experts based on specialties and skills
 * @access Public
 * @rateLimit 60 requests/minute
 */
router.get("/:expertId/similar", generalSearchLimiter, SearchController.getSimilarExperts);

export default router;

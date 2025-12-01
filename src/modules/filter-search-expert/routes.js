// src/modules/filter-search-expert/routes.js
// Public Expert Search Routes - No authentication required
import { Router } from "express";
import * as SearchController from "./controller.js";
import { validateAdvancedSearch, validateQuickFilter } from "./validation.js";

const router = Router();

// ========== ADVANCED SEARCH ENDPOINTS ==========

/**
 * @route GET /api/v1/expert-search/advanced
 * @desc Advanced expert search with 30+ filter criteria
 * @access Public
 */
router.get("/advanced", validateAdvancedSearch, SearchController.advancedSearch);

/**
 * @route GET /api/v1/expert-search/facets
 * @desc Get search facets/aggregations for filter UI
 * @access Public
 */
router.get("/facets", SearchController.getSearchFacets);

/**
 * @route GET /api/v1/expert-search/quick-filters
 * @desc Get experts with predefined quick filters
 * @access Public
 * @query filter - top_rated|most_experienced|online_now|recently_active|fast_responders|budget_friendly|premium|verified|new_experts|high_completion
 */
router.get("/quick-filters", validateQuickFilter, SearchController.quickFilterExperts);

/**
 * @route GET /api/v1/expert-search/:expertId/full
 * @desc Get expert full details with all related data
 * @access Public
 */
router.get("/:expertId/full", SearchController.getExpertFullDetails);

/**
 * @route GET /api/v1/expert-search/:expertId/similar
 * @desc Get similar experts based on specialties and skills
 * @access Public
 */
router.get("/:expertId/similar", SearchController.getSimilarExperts);

export default router;

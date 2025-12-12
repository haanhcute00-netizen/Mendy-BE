// src/modules/filter-search-expert/service.js
// Advanced Expert Search Service
import * as SearchRepo from "./repo.js";
import { cache } from "../../utils/cache.js";
import { logger } from "../../utils/logger.js";

// Cache keys and TTL
const FACETS_CACHE_KEY = 'expert_search_facets';
const FACETS_CACHE_TTL = 300000; // 5 minutes in milliseconds

/**
 * Advanced search experts with comprehensive filters
 * @param {Object} filters - Search filters
 * @returns {Promise<Object>} Search results with pagination
 */
export async function advancedSearch(filters) {
    const startTime = Date.now();

    try {
        // Normalize and validate filters
        const normalizedFilters = normalizeFilters(filters);

        // Execute search
        const result = await SearchRepo.advancedSearchExperts(normalizedFilters);

        // Enrich results with computed fields
        result.experts = result.experts.map(expert => ({
            ...expert,
            // Compute availability status text
            availability_status: getAvailabilityStatus(expert),
            // Format price for display (returns null if no price, let frontend handle i18n)
            price_formatted: formatPrice(expert.price_per_session),
            // Compute experience level
            experience_level: getExperienceLevel(expert)
        }));

        // Log search metrics
        const duration = Date.now() - startTime;
        logger.info({
            type: 'expert_search',
            filters: sanitizeFiltersForLog(normalizedFilters),
            resultCount: result.experts.length,
            totalCount: result.pagination.total,
            duration: `${duration}ms`
        });

        return result;
    } catch (error) {
        logger.error({
            type: 'expert_search_error',
            error: error.message,
            filters: sanitizeFiltersForLog(filters)
        });
        throw error;
    }
}

/**
 * Get search facets for filter UI (cached)
 * @returns {Promise<Object>} Facets data
 */
export async function getSearchFacets() {
    try {
        // Try cache first
        const cached = cache.get(FACETS_CACHE_KEY);
        if (cached) {
            logger.debug({ type: 'cache_hit', key: FACETS_CACHE_KEY });
            return cached;
        }

        // Fetch from DB
        const facets = await SearchRepo.getSearchFacets();

        // Cache result
        cache.set(FACETS_CACHE_KEY, facets, FACETS_CACHE_TTL);
        logger.debug({ type: 'cache_set', key: FACETS_CACHE_KEY, ttl: FACETS_CACHE_TTL });

        return facets;
    } catch (error) {
        logger.error({
            type: 'facets_error',
            error: error.message
        });
        throw error;
    }
}

/**
 * Invalidate facets cache (call when expert data changes)
 */
export function invalidateFacetsCache() {
    cache.delete(FACETS_CACHE_KEY);
    logger.debug({ type: 'cache_invalidate', key: FACETS_CACHE_KEY });
}

/**
 * Get expert full details
 * @param {number} expertId - Expert ID
 * @returns {Promise<Object>} Expert details with all related data
 */
export async function getExpertFullDetails(expertId) {
    const startTime = Date.now();

    try {
        const expert = await SearchRepo.getExpertFullDetails(expertId);

        if (!expert) {
            const error = new Error("Expert not found");
            error.status = 404;
            error.code = 'SEARCH_EXPERT_NOT_FOUND';
            throw error;
        }

        // Get similar experts
        const similarExperts = await SearchRepo.getSimilarExperts(expertId, 5);

        const result = {
            ...expert,
            similar_experts: similarExperts,
            // Computed fields
            availability_status: getAvailabilityStatus(expert),
            price_formatted: formatPrice(expert.price_per_session),
            experience_level: getExperienceLevel(expert),
            total_experience_years: calculateTotalExperience(expert.experience)
        };

        // Log request
        const duration = Date.now() - startTime;
        logger.info({
            type: 'expert_details',
            expertId,
            duration: `${duration}ms`
        });

        return result;
    } catch (error) {
        logger.error({
            type: 'expert_details_error',
            expertId,
            error: error.message
        });
        throw error;
    }
}

/**
 * Get similar experts
 * @param {number} expertId - Expert ID
 * @param {number} limit - Max results
 * @returns {Promise<Array>} Similar experts
 */
export async function getSimilarExperts(expertId, limit = 5) {
    try {
        const results = await SearchRepo.getSimilarExperts(expertId, limit);

        logger.info({
            type: 'similar_experts',
            expertId,
            resultCount: results.length
        });

        return results;
    } catch (error) {
        logger.error({
            type: 'similar_experts_error',
            expertId,
            error: error.message
        });
        throw error;
    }
}

// ========== HELPER FUNCTIONS ==========

function normalizeFilters(filters) {
    const normalized = { ...filters };

    // Convert string arrays
    if (typeof normalized.specialties === 'string') {
        normalized.specialties = normalized.specialties.split(',').map(s => s.trim()).filter(Boolean);
    }

    if (typeof normalized.skillIds === 'string') {
        normalized.skillIds = normalized.skillIds.split(',').map(Number).filter(n => !isNaN(n));
    }

    if (typeof normalized.skillCategories === 'string') {
        normalized.skillCategories = normalized.skillCategories.split(',').map(s => s.trim()).filter(Boolean);
    }

    if (typeof normalized.audienceIds === 'string') {
        normalized.audienceIds = normalized.audienceIds.split(',').map(Number).filter(n => !isNaN(n));
    }

    if (typeof normalized.domainIds === 'string') {
        normalized.domainIds = normalized.domainIds.split(',').map(Number).filter(n => !isNaN(n));
    }

    if (typeof normalized.kycStatus === 'string' && normalized.kycStatus.includes(',')) {
        normalized.kycStatus = normalized.kycStatus.split(',').map(s => s.trim());
    }

    // Convert numeric strings
    const numericFields = [
        'minPrice', 'maxPrice', 'minRating', 'maxRating',
        'lastActiveWithin', 'minCompletionRate', 'minAcceptanceRate',
        'maxResponseTime', 'minTotalSessions', 'minTotalReviews',
        'minExperienceYears', 'page', 'limit'
    ];

    numericFields.forEach(field => {
        if (normalized[field] !== undefined && typeof normalized[field] === 'string') {
            normalized[field] = parseFloat(normalized[field]);
            if (isNaN(normalized[field])) {
                delete normalized[field];
            }
        }
    });

    // Convert boolean strings
    if (typeof normalized.isOnline === 'string') {
        normalized.isOnline = normalized.isOnline === 'true';
    }

    if (typeof normalized.hasCertification === 'string') {
        normalized.hasCertification = normalized.hasCertification === 'true';
    }

    // Validate pagination
    normalized.page = Math.max(1, normalized.page || 1);
    normalized.limit = Math.min(100, Math.max(1, normalized.limit || 20));

    return normalized;
}

function getAvailabilityStatus(expert) {
    if (expert.is_online) {
        return 'online';
    }

    if (expert.last_active_at) {
        const lastActive = new Date(expert.last_active_at);
        const now = new Date();
        const diffMinutes = (now - lastActive) / (1000 * 60);

        if (diffMinutes < 5) return 'just_now';
        if (diffMinutes < 30) return 'recently_active';
        if (diffMinutes < 60) return 'active_hour_ago';
        if (diffMinutes < 1440) return 'active_today';
    }

    return 'offline';
}

/**
 * Format price for display
 * Returns null if no price (let frontend handle i18n/localization)
 * @param {number|null} price - Price value
 * @param {string} locale - Locale for formatting (default: vi-VN)
 * @param {string} currency - Currency code (default: VND)
 * @returns {string|null} Formatted price or null
 */
function formatPrice(price, locale = 'vi-VN', currency = 'VND') {
    if (!price && price !== 0) return null;
    try {
        return new Intl.NumberFormat(locale, {
            style: 'currency',
            currency: currency
        }).format(price);
    } catch {
        return price.toString();
    }
}

/**
 * Sanitize filters for logging (remove sensitive data)
 * @param {Object} filters
 * @returns {Object}
 */
function sanitizeFiltersForLog(filters) {
    if (!filters) return {};
    return {
        ...filters,
        keyword: filters.keyword ? '[REDACTED]' : undefined,
        certificationKeyword: filters.certificationKeyword ? '[REDACTED]' : undefined,
        educationKeyword: filters.educationKeyword ? '[REDACTED]' : undefined
    };
}

function getExperienceLevel(expert) {
    const sessions = expert.total_sessions || 0;
    const rating = expert.rating_avg || 0;

    if (sessions >= 100 && rating >= 4.5) return 'top_rated';
    if (sessions >= 50 && rating >= 4.0) return 'experienced';
    if (sessions >= 20) return 'established';
    if (sessions >= 5) return 'growing';
    return 'new';
}

function calculateTotalExperience(experiences) {
    if (!experiences || !Array.isArray(experiences)) return 0;

    return experiences.reduce((total, exp) => {
        if (exp.years) return total + exp.years;
        if (exp.start_year) {
            const endYear = exp.end_year || new Date().getFullYear();
            return total + (endYear - exp.start_year);
        }
        return total;
    }, 0);
}

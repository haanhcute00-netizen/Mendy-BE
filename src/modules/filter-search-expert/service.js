// src/modules/experts/experts.search.service.js
// Advanced Expert Search Service
import * as SearchRepo from "./repo.js";

/**
 * Advanced search experts with comprehensive filters
 */
export async function advancedSearch(filters) {
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
            // Format price for display
            price_formatted: formatPrice(expert.price_per_session),
            // Compute experience level
            experience_level: getExperienceLevel(expert)
        }));

        return result;
    } catch (error) {
        throw error;
    }
}

/**
 * Get search facets for filter UI
 */
export async function getSearchFacets() {
    try {
        return await SearchRepo.getSearchFacets();
    } catch (error) {
        throw error;
    }
}

/**
 * Get expert full details
 */
export async function getExpertFullDetails(expertId) {
    try {
        const expert = await SearchRepo.getExpertFullDetails(expertId);

        if (!expert) {
            throw Object.assign(new Error("Expert not found"), { status: 404 });
        }

        // Get similar experts
        const similarExperts = await SearchRepo.getSimilarExperts(expertId, 5);

        return {
            ...expert,
            similar_experts: similarExperts,
            // Computed fields
            availability_status: getAvailabilityStatus(expert),
            price_formatted: formatPrice(expert.price_per_session),
            experience_level: getExperienceLevel(expert),
            total_experience_years: calculateTotalExperience(expert.experience)
        };
    } catch (error) {
        throw error;
    }
}

/**
 * Get similar experts
 */
export async function getSimilarExperts(expertId, limit = 5) {
    try {
        return await SearchRepo.getSimilarExperts(expertId, limit);
    } catch (error) {
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

function formatPrice(price) {
    if (!price) return 'Liên hệ';
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(price);
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

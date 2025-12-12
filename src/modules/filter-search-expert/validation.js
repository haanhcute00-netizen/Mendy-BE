// src/modules/filter-search-expert/validation.js
// Validation schemas for advanced expert search
import { z } from "zod";

// Advanced search query schema - passthrough unknown keys
export const advancedSearchSchema = z.object({
    // Text search
    keyword: z.string().max(200).optional(),
    q: z.string().max(200).optional(),

    // Basic filters
    specialties: z.string().optional(),
    minPrice: z.string().optional(),
    min_price: z.string().optional(),
    maxPrice: z.string().optional(),
    max_price: z.string().optional(),
    minRating: z.string().optional(),
    min_rating: z.string().optional(),
    maxRating: z.string().optional(),
    max_rating: z.string().optional(),
    kycStatus: z.string().optional(),
    kyc_status: z.string().optional(),

    // Status filters
    isOnline: z.string().optional(),
    is_online: z.string().optional(),
    lastActiveWithin: z.string().optional(),
    last_active_within: z.string().optional(),

    // Performance filters
    minCompletionRate: z.string().optional(),
    min_completion_rate: z.string().optional(),
    minAcceptanceRate: z.string().optional(),
    min_acceptance_rate: z.string().optional(),
    maxResponseTime: z.string().optional(),
    max_response_time: z.string().optional(),
    minTotalSessions: z.string().optional(),
    min_total_sessions: z.string().optional(),
    minTotalReviews: z.string().optional(),
    min_total_reviews: z.string().optional(),

    // Skills & Experience
    skillIds: z.string().optional(),
    skill_ids: z.string().optional(),
    skillCategories: z.string().optional(),
    skill_categories: z.string().optional(),
    minExperienceYears: z.string().optional(),
    min_experience_years: z.string().optional(),

    // Education & Certification
    hasCertification: z.string().optional(),
    has_certification: z.string().optional(),
    certificationKeyword: z.string().max(100).optional(),
    certification_keyword: z.string().max(100).optional(),
    educationKeyword: z.string().max(100).optional(),
    education_keyword: z.string().max(100).optional(),

    // Audience & Domain
    audienceIds: z.string().optional(),
    audience_ids: z.string().optional(),
    domainIds: z.string().optional(),
    domain_ids: z.string().optional(),

    // Profile filters
    gender: z.string().optional(),

    // Availability
    availableFrom: z.string().optional(),
    available_from: z.string().optional(),
    availableTo: z.string().optional(),
    available_to: z.string().optional(),

    // Sorting
    sortBy: z.string().optional(),
    sort_by: z.string().optional(),
    sortOrder: z.string().optional(),
    sort_order: z.string().optional(),

    // Pagination
    page: z.string().optional(),
    limit: z.string().optional()
}).passthrough(); // Allow unknown keys

// Quick filter schema
export const quickFilterSchema = z.object({
    filter: z.string().optional(),
    page: z.string().optional(),
    limit: z.string().optional()
}).passthrough();

// Valid enum values
const VALID_SORT_BY = ['rating', 'price', 'price_low', 'sessions', 'response_time', 'active_score', 'reviews', 'completion_rate', 'newest'];
const VALID_SORT_ORDER = ['ASC', 'DESC', 'asc', 'desc'];
const VALID_KYC_STATUS = ['PENDING', 'VERIFIED', 'REJECTED'];
const VALID_GENDER = ['MALE', 'FEMALE', 'OTHER', 'UNSPECIFIED'];
const VALID_QUICK_FILTERS = ['top_rated', 'most_experienced', 'online_now', 'recently_active', 'fast_responders', 'budget_friendly', 'premium', 'verified', 'new_experts', 'high_completion'];

/**
 * Validate advanced search parameters
 */
export const validateAdvancedSearch = (req, res, next) => {
    const errors = [];

    // Helper to get value from camelCase or snake_case
    const getValue = (camel, snake) => req.query[camel] || req.query[snake];

    // Validate numeric fields (must be positive numbers)
    const numericFields = [
        ['minPrice', 'min_price'],
        ['maxPrice', 'max_price'],
        ['minRating', 'min_rating'],
        ['maxRating', 'max_rating'],
        ['lastActiveWithin', 'last_active_within'],
        ['minCompletionRate', 'min_completion_rate'],
        ['minAcceptanceRate', 'min_acceptance_rate'],
        ['maxResponseTime', 'max_response_time'],
        ['minTotalSessions', 'min_total_sessions'],
        ['minTotalReviews', 'min_total_reviews'],
        ['minExperienceYears', 'min_experience_years']
    ];

    numericFields.forEach(([camel, snake]) => {
        const value = getValue(camel, snake);
        if (value !== undefined && value !== '') {
            const num = parseFloat(value);
            if (isNaN(num) || num < 0) {
                errors.push(`${camel} must be a positive number`);
            }
        }
    });

    // Validate rating range (0-5)
    const minRating = getValue('minRating', 'min_rating');
    const maxRating = getValue('maxRating', 'max_rating');
    if (minRating !== undefined && minRating !== '') {
        const num = parseFloat(minRating);
        if (!isNaN(num) && (num < 0 || num > 5)) {
            errors.push('minRating must be between 0 and 5');
        }
    }
    if (maxRating !== undefined && maxRating !== '') {
        const num = parseFloat(maxRating);
        if (!isNaN(num) && (num < 0 || num > 5)) {
            errors.push('maxRating must be between 0 and 5');
        }
    }

    // Validate percentage fields (0-100)
    const percentFields = [
        ['minCompletionRate', 'min_completion_rate'],
        ['minAcceptanceRate', 'min_acceptance_rate']
    ];
    percentFields.forEach(([camel, snake]) => {
        const value = getValue(camel, snake);
        if (value !== undefined && value !== '') {
            const num = parseFloat(value);
            if (!isNaN(num) && (num < 0 || num > 100)) {
                errors.push(`${camel} must be between 0 and 100`);
            }
        }
    });

    // Validate lastActiveWithin max value (10080 = 1 week)
    const lastActiveWithin = getValue('lastActiveWithin', 'last_active_within');
    if (lastActiveWithin !== undefined && lastActiveWithin !== '') {
        const num = parseInt(lastActiveWithin);
        if (!isNaN(num) && num > 10080) {
            errors.push('lastActiveWithin must be at most 10080 minutes (1 week)');
        }
    }

    // Validate pagination
    const page = req.query.page;
    const limit = req.query.limit;
    if (page !== undefined && page !== '') {
        const num = parseInt(page);
        if (isNaN(num) || num < 1) {
            errors.push('page must be a positive integer >= 1');
        }
    }
    if (limit !== undefined && limit !== '') {
        const num = parseInt(limit);
        if (isNaN(num) || num < 1 || num > 100) {
            errors.push('limit must be between 1 and 100');
        }
    }

    // Validate sortBy
    const sortBy = getValue('sortBy', 'sort_by');
    if (sortBy && !VALID_SORT_BY.includes(sortBy)) {
        errors.push(`sortBy must be one of: ${VALID_SORT_BY.join(', ')}`);
    }

    // Validate sortOrder
    const sortOrder = getValue('sortOrder', 'sort_order');
    if (sortOrder && !VALID_SORT_ORDER.includes(sortOrder)) {
        errors.push(`sortOrder must be one of: ASC, DESC`);
    }

    // Validate kycStatus
    const kycStatus = getValue('kycStatus', 'kyc_status');
    if (kycStatus) {
        const statuses = kycStatus.includes(',') ? kycStatus.split(',').map(s => s.trim()) : [kycStatus];
        const invalidStatuses = statuses.filter(s => !VALID_KYC_STATUS.includes(s));
        if (invalidStatuses.length > 0) {
            errors.push(`kycStatus must be one of: ${VALID_KYC_STATUS.join(', ')}`);
        }
    }

    // Validate gender
    const gender = req.query.gender;
    if (gender && !VALID_GENDER.includes(gender)) {
        errors.push(`gender must be one of: ${VALID_GENDER.join(', ')}`);
    }

    // Validate keyword length
    const keyword = req.query.keyword || req.query.q;
    if (keyword && keyword.length > 200) {
        errors.push('keyword must be less than 200 characters');
    }

    // Validate certificationKeyword length
    const certKeyword = getValue('certificationKeyword', 'certification_keyword');
    if (certKeyword && certKeyword.length > 100) {
        errors.push('certificationKeyword must be less than 100 characters');
    }

    // Validate educationKeyword length
    const eduKeyword = getValue('educationKeyword', 'education_keyword');
    if (eduKeyword && eduKeyword.length > 100) {
        errors.push('educationKeyword must be less than 100 characters');
    }

    // Validate boolean fields
    const boolFields = [
        ['isOnline', 'is_online'],
        ['hasCertification', 'has_certification']
    ];
    boolFields.forEach(([camel, snake]) => {
        const value = getValue(camel, snake);
        if (value !== undefined && value !== '' && !['true', 'false'].includes(value)) {
            errors.push(`${camel} must be 'true' or 'false'`);
        }
    });

    // Validate date fields
    const availableFrom = getValue('availableFrom', 'available_from');
    const availableTo = getValue('availableTo', 'available_to');
    if (availableFrom && isNaN(Date.parse(availableFrom))) {
        errors.push('availableFrom must be a valid ISO date');
    }
    if (availableTo && isNaN(Date.parse(availableTo))) {
        errors.push('availableTo must be a valid ISO date');
    }
    if (availableFrom && availableTo) {
        if (new Date(availableFrom) >= new Date(availableTo)) {
            errors.push('availableFrom must be before availableTo');
        }
    }

    // Return errors if any
    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation failed',
            errors
        });
    }

    next();
};

/**
 * Validate quick filter parameters
 */
export const validateQuickFilter = (req, res, next) => {
    const errors = [];

    const { filter, page, limit } = req.query;

    // Validate filter value
    if (filter && !VALID_QUICK_FILTERS.includes(filter)) {
        errors.push(`filter must be one of: ${VALID_QUICK_FILTERS.join(', ')}`);
    }

    // Validate pagination
    if (page !== undefined && page !== '') {
        const num = parseInt(page);
        if (isNaN(num) || num < 1) {
            errors.push('page must be a positive integer >= 1');
        }
    }
    if (limit !== undefined && limit !== '') {
        const num = parseInt(limit);
        if (isNaN(num) || num < 1 || num > 100) {
            errors.push('limit must be between 1 and 100');
        }
    }

    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation failed',
            errors
        });
    }

    next();
};

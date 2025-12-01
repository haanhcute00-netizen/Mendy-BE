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

// Validation middleware - simplified, just pass through
export const validateAdvancedSearch = (req, res, next) => {
    // Skip strict validation, let service handle normalization
    next();
};

export const validateQuickFilter = (req, res, next) => {
    // Skip strict validation, let service handle normalization
    next();
};

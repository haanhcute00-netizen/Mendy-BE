// src/modules/filter-search-expert/errors.js
// Error codes and definitions for expert search module

/**
 * Search module error codes
 */
export const SearchErrors = {
    // Validation errors (400)
    INVALID_FILTER: {
        code: 'SEARCH_INVALID_FILTER',
        status: 400,
        message: 'Invalid filter parameter'
    },
    INVALID_PAGINATION: {
        code: 'SEARCH_INVALID_PAGINATION',
        status: 400,
        message: 'Invalid pagination parameters'
    },
    INVALID_SORT: {
        code: 'SEARCH_INVALID_SORT',
        status: 400,
        message: 'Invalid sort parameter'
    },
    INVALID_DATE_RANGE: {
        code: 'SEARCH_INVALID_DATE_RANGE',
        status: 400,
        message: 'Invalid date range'
    },
    KEYWORD_TOO_LONG: {
        code: 'SEARCH_KEYWORD_TOO_LONG',
        status: 400,
        message: 'Search keyword exceeds maximum length'
    },

    // Not found errors (404)
    EXPERT_NOT_FOUND: {
        code: 'SEARCH_EXPERT_NOT_FOUND',
        status: 404,
        message: 'Expert not found'
    },
    NO_RESULTS: {
        code: 'SEARCH_NO_RESULTS',
        status: 404,
        message: 'No experts found matching criteria'
    },

    // Rate limiting (429)
    RATE_LIMITED: {
        code: 'SEARCH_RATE_LIMITED',
        status: 429,
        message: 'Too many search requests, please try again later'
    },

    // Server errors (500)
    DB_ERROR: {
        code: 'SEARCH_DB_ERROR',
        status: 500,
        message: 'Database error occurred during search'
    },
    CACHE_ERROR: {
        code: 'SEARCH_CACHE_ERROR',
        status: 500,
        message: 'Cache error occurred'
    },
    INTERNAL_ERROR: {
        code: 'SEARCH_INTERNAL_ERROR',
        status: 500,
        message: 'Internal server error'
    }
};

/**
 * Create a search error with proper structure
 * @param {Object} errorType - Error type from SearchErrors
 * @param {string} [customMessage] - Optional custom message
 * @param {Object} [details] - Optional additional details
 * @returns {Error}
 */
export function createSearchError(errorType, customMessage = null, details = null) {
    const error = new Error(customMessage || errorType.message);
    error.code = errorType.code;
    error.status = errorType.status;
    if (details) {
        error.details = details;
    }
    return error;
}

/**
 * Check if an error is a search error
 * @param {Error} error
 * @returns {boolean}
 */
export function isSearchError(error) {
    return error && error.code && error.code.startsWith('SEARCH_');
}

/**
 * Get HTTP status from error
 * @param {Error} error
 * @returns {number}
 */
export function getErrorStatus(error) {
    if (error.status) return error.status;
    if (error.code) {
        const errorType = Object.values(SearchErrors).find(e => e.code === error.code);
        if (errorType) return errorType.status;
    }
    return 500;
}

export default SearchErrors;

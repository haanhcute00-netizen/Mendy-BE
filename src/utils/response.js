// utils/response.js - Standardized response utilities for API consistency with i18n support

/**
 * Helper function to translate message or use as literal
 * @param {Object} req - Request object with optional t function
 * @param {string} messageKey - Translation key or literal message
 * @param {Object} options - Translation options/interpolation
 * @returns {string} Translated message or original key
 */
const translate = (req, messageKey, options = {}) => {
  // If translation function exists and messageKey looks like a translation key (has dots)
  if (req && req.t && typeof messageKey === 'string' && messageKey.includes('.')) {
    return req.t(messageKey, options);
  }
  // Otherwise use messageKey as literal string (backward compatibility)
  return messageKey;
};

/**
 * Standard success response
 * @param {Object} res - Express response object
 * @param {string} messageKey - Success message or translation key (e.g., "auth.login.success")
 * @param {Object} data - Response data
 * @param {number} status - HTTP status code (default: 200)
 */
export const success = (res, messageKey, data = {}, status = 200) => {
  const message = translate(res.req, messageKey);
  return res.status(status).json({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Standard failure response
 * @param {Object} res - Express response object
 * @param {string} messageKey - Error message or translation key
 * @param {Object} error - Error details
 * @param {number} status - HTTP status code (default: 400)
 */
export const failure = (res, messageKey, error = {}, status = 400) => {
  const message = translate(res.req, messageKey);
  return res.status(status).json({
    success: false,
    message,
    error,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for created resources (201)
 * @param {Object} res - Express response object
 * @param {string} messageKey - Success message or translation key
 * @param {Object} data - Created resource data
 */
export const created = (res, messageKey, data = {}) => {
  const message = translate(res.req, messageKey);
  return res.status(201).json({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for no content (204)
 * @param {Object} res - Express response object
 */
export const noContent = (res) => {
  return res.status(204).send();
};

/**
 * Response for paginated data
 * @param {Object} res - Express response object
 * @param {string} messageKey - Success message or translation key
 * @param {Array} data - Array of data
 * @param {Object} pagination - Pagination metadata
 * @param {number} status - HTTP status code (default: 200)
 */
export const paginated = (res, messageKey, data = [], pagination = {}, status = 200) => {
  const message = translate(res.req, messageKey);
  return res.status(status).json({
    success: true,
    message,
    data,
    pagination: {
      total: pagination.total || data.length,
      limit: pagination.limit || 20,
      offset: pagination.offset || 0,
      hasMore: pagination.hasMore !== undefined ? pagination.hasMore : (pagination.total > (pagination.offset || 0) + data.length),
      nextCursor: pagination.nextCursor || pagination.next_before,
      ...pagination
    },
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for validation errors
 * @param {Object} res - Express response object
 * @param {string} messageKey - Validation error message or translation key (default: "validation.failed")
 * @param {Array|Object} errors - Validation error details
 */
export const validationError = (res, messageKey = "validation.failed", errors = {}) => {
  const message = translate(res.req, messageKey);
  return res.status(422).json({
    success: false,
    message,
    errors,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for unauthorized access (401)
 * @param {Object} res - Express response object
 * @param {string} messageKey - Error message or translation key (default: "errors.unauthorized")
 */
export const unauthorized = (res, messageKey = "errors.unauthorized") => {
  const message = translate(res.req, messageKey);
  return res.status(401).json({
    success: false,
    message,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for forbidden access (403)
 * @param {Object} res - Express response object
 * @param {string} messageKey - Error message or translation key (default: "errors.forbidden")
 */
export const forbidden = (res, messageKey = "errors.forbidden") => {
  const message = translate(res.req, messageKey);
  return res.status(403).json({
    success: false,
    message,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for not found resources (404)
 * @param {Object} res - Express response object
 * @param {string} messageKey - Error message or translation key (default: "errors.notFound")
 */
export const notFound = (res, messageKey = "errors.notFound") => {
  const message = translate(res.req, messageKey);
  return res.status(404).json({
    success: false,
    message,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for server errors (500)
 * @param {Object} res - Express response object
 * @param {string} messageKey - Error message or translation key (default: "errors.internal")
 * @param {Object} error - Error details
 */
export const serverError = (res, messageKey = "errors.internal", error = {}) => {
  const message = translate(res.req, messageKey);
  return res.status(500).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'production' ? {} : error,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Response for API specific status (like MoMo payment responses)
 * @param {Object} res - Express response object
 * @param {boolean} ok - Status flag
 * @param {string} messageKey - Response message or translation key
 * @param {Object} data - Additional data
 * @param {number} status - HTTP status code
 */
export const apiStatus = (res, ok, messageKey, data = {}, status = 200) => {
  const message = translate(res.req, messageKey);
  return res.status(status).json({
    ok,
    message,
    ...data,
    timestamp: new Date().toISOString(),
  });
};


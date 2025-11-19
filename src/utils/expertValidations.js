// src/utils/expertValidations.js - Enhanced validation schemas for expert profiles
import { z } from "zod";

// Enhanced expert profile validation schemas
export const expertSchemas = {
  // Complete expert profile update
  updateProfile: z.object({
    specialties: z.array(z.string().min(1).max(50)).min(1).max(10).optional(),
    price_per_session: z.number().min(0).max(10000000, "Price cannot exceed 10,000,000 VND").optional(),
    intro: z.string().min(10, "Introduction must be at least 10 characters").max(2000).optional(),
  }).refine(data => {
    // At least one field should be provided
    return Object.keys(data).length > 0;
  }, {
    message: "At least one field must be provided for update"
  }),

  // Skills validation
  addSkill: z.object({
    name: z.string().min(1).max(100),
    category: z.string().min(1).max(50)
  }),

  updateSkill: z.object({
    id: z.number().positive(),
    name: z.string().min(1).max(100).optional(),
    category: z.string().min(1).max(50).optional()
  }),

  // Experience validation
  addExperience: z.object({
    position: z.string().min(1).max(100),
    organization: z.string().min(1).max(100),
    years: z.number().min(0).max(50),
    description: z.string().max(500).optional(),
    start_year: z.number().min(1950).max(new Date().getFullYear()),
    end_year: z.number().min(1950).max(new Date().getFullYear() + 10).optional()
  }).refine(data => {
    if (data.end_year && data.end_year < data.start_year) {
      return false;
    }
    return true;
  }, {
    message: "End year must be after or equal to start year",
    path: ["end_year"]
  }),

  updateExperience: z.object({
    id: z.number().positive(),
    position: z.string().min(1).max(100).optional(),
    organization: z.string().min(1).max(100).optional(),
    years: z.number().min(0).max(50).optional(),
    description: z.string().max(500).optional(),
    start_year: z.number().min(1950).max(new Date().getFullYear()).optional(),
    end_year: z.number().min(1950).max(new Date().getFullYear() + 10).optional()
  }).refine(data => {
    if (data.start_year && data.end_year && data.end_year < data.start_year) {
      return false;
    }
    return true;
  }, {
    message: "End year must be after or equal to start year",
    path: ["end_year"]
  }),

  // Education validation
  addEducation: z.object({
    degree: z.string().min(1).max(100),
    institution: z.string().min(1).max(100),
    year_completed: z.number().min(1950).max(new Date().getFullYear()),
    description: z.string().max(500).optional()
  }),

  updateEducation: z.object({
    id: z.number().positive(),
    degree: z.string().min(1).max(100).optional(),
    institution: z.string().min(1).max(100).optional(),
    year_completed: z.number().min(1950).max(new Date().getFullYear()).optional(),
    description: z.string().max(500).optional()
  }),

  // Certifications validation
  addCertification: z.object({
    certificate_name: z.string().min(1).max(100),
    issuing_org: z.string().min(1).max(100),
    issued_at: z.string().datetime("Invalid issued date format"),
    expires_at: z.string().datetime("Invalid expiry date format").optional(),
    credential_url: z.string().url("Invalid URL format").optional()
  }).refine(data => {
    if (data.expires_at && new Date(data.expires_at) < new Date(data.issued_at)) {
      return false;
    }
    return true;
  }, {
    message: "Expiry date must be after issue date",
    path: ["expires_at"]
  }),

  updateCertification: z.object({
    id: z.number().positive(),
    certificate_name: z.string().min(1).max(100).optional(),
    issuing_org: z.string().min(1).max(100).optional(),
    issued_at: z.string().datetime().optional(),
    expires_at: z.string().datetime().optional(),
    credential_url: z.string().url().optional()
  }).refine(data => {
    if (data.issued_at && data.expires_at && new Date(data.expires_at) < new Date(data.issued_at)) {
      return false;
    }
    return true;
  }, {
    message: "Expiry date must be after issue date",
    path: ["expires_at"]
  }),

  // Expert availability validation
  createAvailability: z.object({
    start_at: z.string().datetime("Invalid start date format"),
    end_at: z.string().datetime("Invalid end date format"),
    is_recurring: z.boolean().default(false),
    recurring_pattern: z.object({
      type: z.enum(["WEEKLY", "MONTHLY"]),
      days_of_week: z.array(z.number().min(0).max(6)).optional(),
      day_of_month: z.number().min(1).max(31).optional()
    }).optional()
  }).refine(data => new Date(data.end_at) > new Date(data.start_at), {
    message: "End time must be after start time",
    path: ["end_at"]
  }),

  updateAvailability: z.object({
    id: z.number().positive(),
    start_at: z.string().datetime().optional(),
    end_at: z.string().datetime().optional(),
    is_recurring: z.boolean().optional(),
    recurring_pattern: z.object({
      type: z.enum(["WEEKLY", "MONTHLY"]),
      days_of_week: z.array(z.number().min(0).max(6)).optional(),
      day_of_month: z.number().min(1).max(31).optional()
    }).optional()
  }).refine(data => {
    if (data.start_at && data.end_at && new Date(data.end_at) <= new Date(data.start_at)) {
      return false;
    }
    return true;
  }, {
    message: "End time must be after start time",
    path: ["end_at"]
  }),

  // Target audience and domains
  updateTargetAudience: z.object({
    audience_ids: z.array(z.number().positive()).min(1).max(10)
  }),

  updateDomains: z.object({
    domain_ids: z.array(z.number().positive()).min(1).max(10)
  }),

  // Media/portfolio validation
  addMedia: z.object({
    media_type: z.enum(["IMAGE", "VIDEO", "DOCUMENT", "AUDIO"]),
    url: z.string().url("Invalid URL format"),
    title: z.string().min(1).max(200),
    description: z.string().max(500).optional()
  }),

  updateMedia: z.object({
    id: z.number().positive(),
    media_type: z.enum(["IMAGE", "VIDEO", "DOCUMENT", "AUDIO"]).optional(),
    url: z.string().url().optional(),
    title: z.string().min(1).max(200).optional(),
    description: z.string().max(500).optional()
  }),

  // Expert status update
  updateStatus: z.object({
    is_available: z.boolean().optional(),
    current_status: z.enum(["ONLINE", "OFFLINE", "BUSY", "AWAY"]).optional(),
    status_message: z.string().max(200).optional()
  }),

  // Performance metrics validation
  updatePerformance: z.object({
    response_time_avg: z.number().min(0).optional(),
    session_completion_rate: z.number().min(0).max(100).optional(),
    satisfaction_score: z.number().min(0).max(5).optional()
  })
};

// Query validation schemas
export const expertQuerySchemas = {
  // Get experts listing
  getExperts: z.object({
    page: z.string().regex(/^\d+$/).transform(Number).default("1"),
    limit: z.string().regex(/^\d+$/).transform(Number).default("20"),
    specialties: z.string().optional().transform(val => val ? val.split(',') : []),
    min_price: z.string().regex(/^\d+$/).transform(Number).optional(),
    max_price: z.string().regex(/^\d+$/).transform(Number).optional(),
    min_rating: z.string().regex(/^\d+(\.\d+)?$/).transform(Number).optional(),
    kyc_status: z.enum(["PENDING", "VERIFIED", "REJECTED"]).optional(),
    is_available: z.enum(["true", "false"]).transform(val => val === "true").optional()
  }).refine(data => {
    if (data.min_price && data.max_price && data.min_price > data.max_price) {
      return false;
    }
    return true;
  }, {
    message: "Minimum price cannot be greater than maximum price",
    path: ["min_price"]
  }),

  // Get expert availability
  getAvailability: z.object({
    expert_id: z.string().regex(/^\d+$/).transform(Number),
    date_from: z.string().datetime().optional(),
    date_to: z.string().datetime().optional()
  }).refine(data => {
    if (data.date_from && data.date_to && new Date(data.date_to) < new Date(data.date_from)) {
      return false;
    }
    return true;
  }, {
    message: "End date must be after start date",
    path: ["date_to"]
  }),

  // Search experts
  searchExperts: z.object({
    q: z.string().min(1).max(100),
    page: z.string().regex(/^\d+$/).transform(Number).default("1"),
    limit: z.string().regex(/^\d+$/).transform(Number).default("20"),
    filters: z.object({
      specialties: z.array(z.string()).optional(),
      price_range: z.object({
        min: z.number().min(0).optional(),
        max: z.number().min(0).optional()
      }).optional(),
      rating: z.number().min(0).max(5).optional(),
      availability: z.boolean().optional()
    }).optional()
  })
};

// Utility function to validate expert-specific data
export const validateExpertData = (schema) => (req, res, next) => {
  try {
    const validatedData = schema.parse(req.body);
    req.body = validatedData;
    next();
  } catch (error) {
    if (error instanceof z.ZodError) {
      const errorMessages = error.errors.map(err => ({
        field: err.path.join('.'),
        message: err.message
      }));
      return res.status(400).json({
        error: "Expert data validation failed",
        details: errorMessages
      });
    }
    next(error);
  }
};

// Utility function to validate expert query parameters
export const validateExpertQuery = (schema) => (req, res, next) => {
  try {
    const validatedQuery = schema.parse(req.query);
    req.query = validatedQuery;
    next();
  } catch (error) {
    if (error instanceof z.ZodError) {
      const errorMessages = error.errors.map(err => ({
        field: err.path.join('.'),
        message: err.message
      }));
      return res.status(400).json({
        error: "Expert query validation failed",
        details: errorMessages
      });
    }
    next(error);
  }
};

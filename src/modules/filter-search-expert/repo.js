// src/modules/filter-search-expert/repo.js
// Advanced Expert Search Repository
import { query } from "../../config/db.js";

/**
 * @typedef {Object} SearchFilters
 * @property {string} [keyword] - Full-text search keyword
 * @property {string[]} [specialties] - Filter by specialties
 * @property {number} [minPrice] - Minimum price per session
 * @property {number} [maxPrice] - Maximum price per session
 * @property {number} [minRating] - Minimum rating (0-5)
 * @property {number} [maxRating] - Maximum rating (0-5)
 * @property {string|string[]} [kycStatus] - KYC status filter (PENDING, VERIFIED, REJECTED)
 * @property {boolean} [isOnline] - Filter online experts only
 * @property {number} [lastActiveWithin] - Minutes since last active (max 10080)
 * @property {number} [minCompletionRate] - Minimum completion rate (0-100)
 * @property {number} [minAcceptanceRate] - Minimum acceptance rate (0-100)
 * @property {number} [maxResponseTime] - Maximum response time in minutes
 * @property {number} [minTotalSessions] - Minimum completed sessions
 * @property {number} [minTotalReviews] - Minimum reviews count
 * @property {number[]} [skillIds] - Filter by skill IDs
 * @property {string[]} [skillCategories] - Filter by skill categories
 * @property {number} [minExperienceYears] - Minimum total experience years
 * @property {boolean} [hasCertification] - Has at least one certification
 * @property {string} [certificationKeyword] - Search in certification names
 * @property {string} [educationKeyword] - Search in education/institution
 * @property {number[]} [audienceIds] - Filter by target audience IDs
 * @property {number[]} [domainIds] - Filter by domain IDs
 * @property {string} [gender] - Gender filter (MALE, FEMALE, OTHER, UNSPECIFIED)
 * @property {string} [availableFrom] - ISO datetime for availability start
 * @property {string} [availableTo] - ISO datetime for availability end
 * @property {string} [sortBy] - Sort field (rating, price, sessions, etc.)
 * @property {string} [sortOrder] - Sort order (ASC, DESC)
 * @property {number} [page] - Page number (default: 1)
 * @property {number} [limit] - Items per page (default: 20, max: 100)
 */

/**
 * @typedef {Object} SearchResult
 * @property {Object[]} experts - Array of expert objects
 * @property {Object} pagination - Pagination info
 * @property {number} pagination.page - Current page
 * @property {number} pagination.limit - Items per page
 * @property {number} pagination.total - Total items
 * @property {number} pagination.totalPages - Total pages
 * @property {boolean} pagination.hasNext - Has next page
 * @property {boolean} pagination.hasPrev - Has previous page
 */

/**
 * Advanced Expert Search with multiple filter criteria
 * Supports 30+ filter parameters for comprehensive expert discovery
 * 
 * @param {SearchFilters} filters - Search filter parameters
 * @returns {Promise<SearchResult>} Search results with pagination
 */
export async function advancedSearchExperts(filters) {
  const {
    keyword,
    specialties,
    minPrice,
    maxPrice,
    minRating,
    maxRating,
    kycStatus,
    isOnline,
    lastActiveWithin,
    minCompletionRate,
    minAcceptanceRate,
    maxResponseTime,
    minTotalSessions,
    minTotalReviews,
    skillIds,
    skillCategories,
    minExperienceYears,
    hasCertification,
    certificationKeyword,
    educationKeyword,
    audienceIds,
    domainIds,
    gender,
    availableFrom,
    availableTo,
    sortBy = 'rating',
    sortOrder = 'DESC',
    page = 1,
    limit = 20
  } = filters;

  const conditions = [];
  const params = [];
  let paramIndex = 1;

  // Helper to add parameter with $ prefix
  const addParam = (value) => {
    params.push(value);
    return '$' + (paramIndex++);
  };

  // TEXT SEARCH
  if (keyword) {
    const p1 = addParam('%' + keyword + '%');
    const p2 = addParam('%' + keyword + '%');
    const p3 = addParam('%' + keyword + '%');
    conditions.push(`(
      up.display_name ILIKE ${p1} OR
      ep.intro ILIKE ${p2} OR
      EXISTS (SELECT 1 FROM unnest(ep.specialties) AS spec WHERE spec ILIKE ${p3})
    )`);
  }

  // BASIC FILTERS
  if (specialties && specialties.length > 0) {
    conditions.push(`ep.specialties && ${addParam(specialties)}`);
  }

  if (minPrice !== undefined) {
    conditions.push(`ep.price_per_session >= ${addParam(minPrice)}`);
  }

  if (maxPrice !== undefined) {
    conditions.push(`ep.price_per_session <= ${addParam(maxPrice)}`);
  }

  if (minRating !== undefined) {
    conditions.push(`COALESCE(ep.rating_avg, 0) >= ${addParam(minRating)}`);
  }

  if (maxRating !== undefined) {
    conditions.push(`COALESCE(ep.rating_avg, 5) <= ${addParam(maxRating)}`);
  }

  if (kycStatus) {
    if (Array.isArray(kycStatus)) {
      conditions.push(`ep.kyc_status = ANY(${addParam(kycStatus)})`);
    } else {
      conditions.push(`ep.kyc_status = ${addParam(kycStatus)}`);
    }
  }

  // STATUS FILTERS
  if (isOnline !== undefined) {
    conditions.push(`COALESCE(es.is_online, false) = ${addParam(isOnline)}`);
  }

  if (lastActiveWithin) {
    const minutes = parseInt(lastActiveWithin);
    if (!isNaN(minutes) && minutes > 0 && minutes <= 10080) {
      conditions.push(`es.last_active_at >= NOW() - INTERVAL '1 minute' * ${addParam(minutes)}`);
    }
  }

  // PERFORMANCE FILTERS
  if (minCompletionRate !== undefined) {
    conditions.push(`COALESCE(eperf.completion_rate, 0) >= ${addParam(minCompletionRate)}`);
  }

  if (minAcceptanceRate !== undefined) {
    conditions.push(`COALESCE(eperf.acceptance_rate, 0) >= ${addParam(minAcceptanceRate)}`);
  }

  if (maxResponseTime !== undefined) {
    conditions.push(`COALESCE(eperf.response_time_avg, 999999) <= ${addParam(maxResponseTime)}`);
  }

  if (minTotalSessions !== undefined) {
    conditions.push(`COALESCE(eperf.total_sessions, 0) >= ${addParam(minTotalSessions)}`);
  }

  if (minTotalReviews !== undefined) {
    conditions.push(`COALESCE(eperf.total_reviews, 0) >= ${addParam(minTotalReviews)}`);
  }

  // SKILLS FILTERS
  if (skillIds && skillIds.length > 0) {
    conditions.push(`EXISTS (
      SELECT 1 FROM app.expert_skills eks 
      WHERE eks.expert_id = ep.id AND eks.skill_id = ANY(${addParam(skillIds)})
    )`);
  }

  if (skillCategories && skillCategories.length > 0) {
    conditions.push(`EXISTS (
      SELECT 1 FROM app.expert_skills eks 
      JOIN app.skills sk ON eks.skill_id = sk.id
      WHERE eks.expert_id = ep.id AND sk.category = ANY(${addParam(skillCategories)})
    )`);
  }

  // EXPERIENCE FILTERS
  if (minExperienceYears !== undefined) {
    conditions.push(`EXISTS (
      SELECT 1 FROM app.expert_experience ee 
      WHERE ee.expert_id = ep.id 
      GROUP BY ee.expert_id 
      HAVING SUM(COALESCE(ee.years, 0)) >= ${addParam(minExperienceYears)}
    )`);
  }

  // CERTIFICATION FILTERS
  if (hasCertification === true) {
    conditions.push(`EXISTS (SELECT 1 FROM app.expert_certifications ec WHERE ec.expert_id = ep.id)`);
  }

  if (certificationKeyword) {
    const p1 = addParam('%' + certificationKeyword + '%');
    const p2 = addParam('%' + certificationKeyword + '%');
    conditions.push(`EXISTS (
      SELECT 1 FROM app.expert_certifications ec 
      WHERE ec.expert_id = ep.id 
      AND (ec.certificate_name ILIKE ${p1} OR ec.issuing_org ILIKE ${p2})
    )`);
  }

  // EDUCATION FILTERS
  if (educationKeyword) {
    const p1 = addParam('%' + educationKeyword + '%');
    const p2 = addParam('%' + educationKeyword + '%');
    conditions.push(`EXISTS (
      SELECT 1 FROM app.expert_education edu 
      WHERE edu.expert_id = ep.id 
      AND (edu.degree ILIKE ${p1} OR edu.institution ILIKE ${p2})
    )`);
  }

  // AUDIENCE & DOMAIN FILTERS
  if (audienceIds && audienceIds.length > 0) {
    conditions.push(`EXISTS (
      SELECT 1 FROM app.expert_audience ea 
      WHERE ea.expert_id = ep.id AND ea.audience_id = ANY(${addParam(audienceIds)})
    )`);
  }

  if (domainIds && domainIds.length > 0) {
    conditions.push(`EXISTS (
      SELECT 1 FROM app.expert_domain ed 
      WHERE ed.expert_id = ep.id AND ed.domain_id = ANY(${addParam(domainIds)})
    )`);
  }

  // PROFILE FILTERS
  if (gender) {
    conditions.push(`up.gender = ${addParam(gender)}`);
  }

  // AVAILABILITY FILTERS
  if (availableFrom && availableTo) {
    const p1 = addParam(availableFrom);
    const p2 = addParam(availableTo);
    conditions.push(`NOT EXISTS (
      SELECT 1 FROM app.bookings b 
      WHERE b.expert_id = ep.id 
      AND b.status IN ('PENDING', 'CONFIRMED')
      AND b.time_slot && tstzrange(${p1}, ${p2}, '[)')
    )`);
  }

  const whereClause = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';

  // SORTING
  const sortColumns = {
    rating: 'COALESCE(ep.rating_avg, 0)',
    price: 'ep.price_per_session',
    price_low: 'ep.price_per_session',
    sessions: 'COALESCE(eperf.total_sessions, 0)',
    response_time: 'COALESCE(eperf.response_time_avg, 999999)',
    active_score: 'COALESCE(es.active_score, 0)',
    reviews: 'COALESCE(eperf.total_reviews, 0)',
    completion_rate: 'COALESCE(eperf.completion_rate, 0)',
    newest: 'ep.id'
  };

  const sortColumn = sortColumns[sortBy] || sortColumns.rating;
  const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
  const finalOrder = sortBy === 'price_low' ? 'ASC' : order;

  const offset = (page - 1) * limit;
  const limitParam = addParam(limit);
  const offsetParam = addParam(offset);

  const mainQuery = `
    SELECT
      ep.id AS expert_id,
      ep.user_id,
      ep.specialties,
      ep.price_per_session,
      ep.rating_avg,
      ep.intro,
      ep.kyc_status,
      u.handle,
      u.email,
      up.display_name,
      up.avatar_url,
      up.bio,
      up.gender,
      es.is_online,
      es.last_active_at,
      es.active_score,
      es.status_message,
      eperf.response_time_avg,
      eperf.acceptance_rate,
      eperf.completion_rate,
      eperf.total_sessions,
      eperf.total_reviews,
      eperf.ai_expertise_score,
      (
        SELECT COALESCE(json_agg(json_build_object(
          'id', sk.id, 'name', sk.name, 'category', sk.category
        )), '[]'::json)
        FROM app.expert_skills eks
        JOIN app.skills sk ON eks.skill_id = sk.id
        WHERE eks.expert_id = ep.id
      ) AS skills,
      (
        SELECT COUNT(*) FROM app.reviews r 
        JOIN app.bookings b ON r.booking_id = b.id 
        WHERE b.expert_id = ep.id
      ) AS review_count
    FROM app.expert_profiles ep
    JOIN app.users u ON ep.user_id = u.id
    LEFT JOIN app.user_profiles up ON u.id = up.user_id
    LEFT JOIN app.expert_status es ON ep.id = es.expert_id
    LEFT JOIN app.expert_performance eperf ON ep.id = eperf.expert_id
    ${whereClause}
    ORDER BY ${sortColumn} ${finalOrder}, ep.id DESC
    LIMIT ${limitParam} OFFSET ${offsetParam}
  `;

  // Count query - use params without limit/offset
  const countParams = params.slice(0, -2);
  const countQuery = `
    SELECT COUNT(ep.id) AS total
    FROM app.expert_profiles ep
    JOIN app.users u ON ep.user_id = u.id
    LEFT JOIN app.user_profiles up ON u.id = up.user_id
    LEFT JOIN app.expert_status es ON ep.id = es.expert_id
    LEFT JOIN app.expert_performance eperf ON ep.id = eperf.expert_id
    ${whereClause}
  `;

  const [expertsResult, countResult] = await Promise.all([
    query(mainQuery, params),
    query(countQuery, countParams)
  ]);

  const total = parseInt(countResult.rows[0]?.total || 0);

  return {
    experts: expertsResult.rows,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasNext: page * limit < total,
      hasPrev: page > 1
    }
  };
}

/**
 * @typedef {Object} SearchFacets
 * @property {Object} price_range - Price range statistics
 * @property {number} price_range.min - Minimum price
 * @property {number} price_range.max - Maximum price
 * @property {number} price_range.avg - Average price
 * @property {Object[]} rating_distribution - Rating distribution
 * @property {Object[]} top_specialties - Top specialties with counts
 * @property {Object[]} skill_categories - Skill categories with counts
 * @property {Object[]} kyc_status_counts - KYC status distribution
 * @property {Object} online_status - Online/offline counts
 * @property {Object[]} audiences - Available audiences
 * @property {Object[]} domains - Available domains
 * @property {number} total_experts - Total expert count
 */

/**
 * Get search facets/aggregations for filter UI
 * Returns statistics and distributions for building filter interfaces
 * 
 * @returns {Promise<SearchFacets>} Facets data for UI
 */
export async function getSearchFacets() {
  const facetsQuery = `
    SELECT 
      (SELECT json_build_object(
        'min', MIN(price_per_session),
        'max', MAX(price_per_session),
        'avg', ROUND(AVG(price_per_session), 0)
      ) FROM app.expert_profiles) AS price_range,
      
      (SELECT json_agg(json_build_object('rating', rating, 'count', cnt))
       FROM (
         SELECT FLOOR(COALESCE(rating_avg, 0)) AS rating, COUNT(*) AS cnt
         FROM app.expert_profiles
         GROUP BY FLOOR(COALESCE(rating_avg, 0))
         ORDER BY rating DESC
       ) r
      ) AS rating_distribution,
      
      (SELECT json_agg(json_build_object('specialty', spec, 'count', cnt))
       FROM (
         SELECT unnest(specialties) AS spec, COUNT(*) AS cnt
         FROM app.expert_profiles
         GROUP BY spec
         ORDER BY cnt DESC
         LIMIT 20
       ) s
      ) AS top_specialties,
      
      (SELECT json_agg(json_build_object('category', category, 'count', cnt))
       FROM (
         SELECT sk.category, COUNT(DISTINCT eks.expert_id) AS cnt
         FROM app.expert_skills eks
         JOIN app.skills sk ON eks.skill_id = sk.id
         WHERE sk.category IS NOT NULL
         GROUP BY sk.category
         ORDER BY cnt DESC
       ) c
      ) AS skill_categories,
      
      (SELECT json_agg(json_build_object('status', kyc_status, 'count', cnt))
       FROM (
         SELECT kyc_status, COUNT(*) AS cnt
         FROM app.expert_profiles
         GROUP BY kyc_status
       ) k
      ) AS kyc_status_counts,
      
      (SELECT json_build_object(
        'online', COUNT(*) FILTER (WHERE is_online = true),
        'offline', COUNT(*) FILTER (WHERE is_online = false OR is_online IS NULL)
      ) FROM app.expert_status) AS online_status,
      
      (SELECT COALESCE(json_agg(json_build_object('id', id, 'name', name)), '[]'::json)
       FROM app.audience) AS audiences,
      
      (SELECT COALESCE(json_agg(json_build_object('id', id, 'name', name)), '[]'::json)
       FROM app.domains) AS domains,
      
      (SELECT COUNT(*) FROM app.expert_profiles) AS total_experts
  `;

  const { rows } = await query(facetsQuery);
  return rows[0];
}

/**
 * @typedef {Object} ExpertFullDetails
 * @property {number} expert_id - Expert ID
 * @property {number} user_id - User ID
 * @property {string[]} specialties - Expert specialties
 * @property {number} price_per_session - Price per session
 * @property {number} rating_avg - Average rating
 * @property {string} intro - Expert introduction
 * @property {string} kyc_status - KYC verification status
 * @property {Object[]} skills - Expert skills
 * @property {Object[]} experience - Work experience
 * @property {Object[]} education - Education history
 * @property {Object[]} certifications - Certifications
 * @property {Object[]} media - Media files
 * @property {Object[]} target_audience - Target audiences
 * @property {Object[]} domains - Expert domains
 * @property {Object[]} recent_reviews - Recent reviews
 */

/**
 * Get expert full details with all related data
 * Fetches comprehensive expert profile including skills, experience, education, etc.
 * 
 * @param {number} expertId - Expert ID to fetch
 * @returns {Promise<ExpertFullDetails|null>} Expert details or null if not found
 */
export async function getExpertFullDetails(expertId) {
  const expertQuery = `
    SELECT 
      ep.id AS expert_id, ep.user_id, ep.specialties, ep.price_per_session,
      ep.rating_avg, ep.intro, ep.kyc_status,
      u.handle, u.email, u.created_at AS member_since,
      up.display_name, up.avatar_url, up.bio, up.gender, up.year_of_birth,
      es.is_online, es.last_active_at, es.active_score, es.status_message,
      eperf.response_time_avg, eperf.acceptance_rate, eperf.completion_rate,
      eperf.cancel_rate, eperf.avg_session_duration, eperf.total_sessions,
      eperf.total_reviews, eperf.ai_expertise_score
    FROM app.expert_profiles ep
    JOIN app.users u ON ep.user_id = u.id
    LEFT JOIN app.user_profiles up ON u.id = up.user_id
    LEFT JOIN app.expert_status es ON ep.id = es.expert_id
    LEFT JOIN app.expert_performance eperf ON ep.id = eperf.expert_id
    WHERE ep.id = $1
  `;

  const [
    expertResult,
    skillsResult,
    experienceResult,
    educationResult,
    certificationsResult,
    mediaResult,
    audienceResult,
    domainsResult,
    recentReviewsResult
  ] = await Promise.all([
    query(expertQuery, [expertId]),
    query(`SELECT sk.id, sk.name, sk.category FROM app.expert_skills eks JOIN app.skills sk ON eks.skill_id = sk.id WHERE eks.expert_id = $1 ORDER BY sk.category, sk.name`, [expertId]),
    query(`SELECT id, position, organization, years, description, start_year, end_year FROM app.expert_experience WHERE expert_id = $1 ORDER BY start_year DESC NULLS LAST`, [expertId]),
    query(`SELECT id, degree, institution, year_completed, description FROM app.expert_education WHERE expert_id = $1 ORDER BY year_completed DESC NULLS LAST`, [expertId]),
    query(`SELECT id, certificate_name, issuing_org, issued_at, expires_at, credential_url FROM app.expert_certifications WHERE expert_id = $1 ORDER BY issued_at DESC NULLS LAST`, [expertId]),
    query(`SELECT id, media_type, url, title, description, created_at FROM app.expert_media WHERE expert_id = $1 ORDER BY created_at DESC`, [expertId]),
    query(`SELECT a.id, a.name FROM app.expert_audience ea JOIN app.audience a ON ea.audience_id = a.id WHERE ea.expert_id = $1`, [expertId]),
    query(`SELECT d.id, d.name FROM app.expert_domain ed JOIN app.domains d ON ed.domain_id = d.id WHERE ed.expert_id = $1`, [expertId]),
    query(`SELECT r.id, r.rating, r.comment, r.created_at, up.display_name AS reviewer_name, up.avatar_url AS reviewer_avatar FROM app.reviews r JOIN app.bookings b ON r.booking_id = b.id LEFT JOIN app.user_profiles up ON r.user_id = up.user_id WHERE b.expert_id = $1 ORDER BY r.created_at DESC LIMIT 5`, [expertId])
  ]);

  if (!expertResult.rows[0]) return null;

  return {
    ...expertResult.rows[0],
    skills: skillsResult.rows,
    experience: experienceResult.rows,
    education: educationResult.rows,
    certifications: certificationsResult.rows,
    media: mediaResult.rows,
    target_audience: audienceResult.rows,
    domains: domainsResult.rows,
    recent_reviews: recentReviewsResult.rows
  };
}

/**
 * @typedef {Object} SimilarExpert
 * @property {number} expert_id - Expert ID
 * @property {number} user_id - User ID
 * @property {string[]} specialties - Expert specialties
 * @property {number} price_per_session - Price per session
 * @property {number} rating_avg - Average rating
 * @property {string} display_name - Display name
 * @property {string} avatar_url - Avatar URL
 * @property {boolean} is_online - Online status
 * @property {number} specialty_match - Number of matching specialties
 * @property {number} skill_match - Number of matching skills
 */

/**
 * Get similar experts based on specialties and skills
 * Uses specialty and skill overlap to find related experts
 * 
 * @param {number} expertId - Source expert ID
 * @param {number} [limit=5] - Maximum number of results
 * @returns {Promise<SimilarExpert[]>} Array of similar experts
 */
export async function getSimilarExperts(expertId, limit = 5) {
  const similarQuery = `
    WITH target_expert AS (
      SELECT id, specialties FROM app.expert_profiles WHERE id = $1
    ),
    target_skills AS (
      SELECT skill_id FROM app.expert_skills WHERE expert_id = $1
    )
    SELECT DISTINCT
      ep.id AS expert_id, ep.user_id, ep.specialties, ep.price_per_session,
      ep.rating_avg, up.display_name, up.avatar_url, es.is_online,
      (SELECT COUNT(*) FROM unnest(ep.specialties) AS s WHERE s = ANY((SELECT specialties FROM target_expert))) AS specialty_match,
      (SELECT COUNT(*) FROM app.expert_skills eks WHERE eks.expert_id = ep.id AND eks.skill_id IN (SELECT skill_id FROM target_skills)) AS skill_match
    FROM app.expert_profiles ep
    JOIN app.users u ON ep.user_id = u.id
    LEFT JOIN app.user_profiles up ON u.id = up.user_id
    LEFT JOIN app.expert_status es ON ep.id = es.expert_id
    WHERE ep.id != $1
    ORDER BY (specialty_match + skill_match) DESC, ep.rating_avg DESC NULLS LAST
    LIMIT $2
  `;

  const { rows } = await query(similarQuery, [expertId, limit]);
  return rows;
}

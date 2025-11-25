// src/repositories/experts.repo.js - Enhanced expert repository with comprehensive functionality
import { query, getClient } from "../../config/db.js";

// Basic expert profile operations
export async function getExpertProfile(userId) {
  const { rows } = await query(
    `SELECT ep.*, u.handle, u.email, up.display_name, up.avatar_url
     FROM app.expert_profiles ep
     JOIN app.users u ON ep.user_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     WHERE ep.user_id = $1`,
    [userId]
  );
  return rows[0];
}

export async function updateExpertProfile({ userId, specialties, pricePerSession, intro }) {
  const { rows } = await query(
    `UPDATE app.expert_profiles
       SET specialties = $1, price_per_session = $2, intro = $3, updated_at = now()
     WHERE user_id = $4
     RETURNING id, user_id, specialties, price_per_session, intro, rating_avg, kyc_status`,
    [specialties, pricePerSession, intro, userId]
  );
  return rows[0];
}

export async function createExpertProfile({ userId, specialties = [], pricePerSession = 0, intro = '', kycStatus = 'PENDING' }) {
  const { rows } = await query(
    `INSERT INTO app.expert_profiles (user_id, specialties, price_per_session, intro, kyc_status, created_at, updated_at)
     VALUES ($1, $2, $3, $4, $5, now(), now())
     RETURNING id, user_id, specialties, price_per_session, intro, rating_avg, kyc_status`,
    [userId, specialties, pricePerSession, intro, kycStatus]
  );
  return rows[0];
}

// Skills operations
export async function getExpertSkills(expertId) {
  const { rows } = await query(
    `SELECT es.id, es.skill_id, s.name, s.category
     FROM app.expert_skills es
     JOIN app.skills s ON es.skill_id = s.id
     WHERE es.expert_id = $1
     ORDER BY s.category, s.name`,
    [expertId]
  );
  return rows;
}

export async function addExpertSkill({ expertId, name, category }) {
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    
    // First create or get the skill
    const { rows: skillRows } = await client.query(
      `INSERT INTO app.skills (name, category, created_at)
       VALUES ($1, $2, now())
       ON CONFLICT (name) DO UPDATE SET category = $2, updated_at = now()
       RETURNING id`,
      [name, category]
    );
    
    const skillId = skillRows[0].id;
    
    // Then add it to expert skills
    const { rows } = await client.query(
      `INSERT INTO app.expert_skills (expert_id, skill_id, created_at)
       VALUES ($1, $2, now())
       ON CONFLICT (expert_id, skill_id) DO NOTHING
       RETURNING id, expert_id, skill_id`,
      [expertId, skillId]
    );
    
    await client.query('COMMIT');
    return rows[0] || { expert_id: expertId, skill_id: skillId };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function updateExpertSkill({ id, name, category }) {
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    
    // First update or create the skill
    const { rows: skillRows } = await client.query(
      `INSERT INTO app.skills (name, category, created_at)
       VALUES ($1, $2, now())
       ON CONFLICT (name) DO UPDATE SET category = $2, updated_at = now()
       RETURNING id`,
      [name, category]
    );
    
    const skillId = skillRows[0].id;
    
    // Then update the expert_skill reference
    const { rows } = await client.query(
      `UPDATE app.expert_skills SET skill_id = $1, updated_at = now()
       WHERE id = $2
       RETURNING id, expert_id, skill_id`,
      [skillId, id]
    );
    
    await client.query('COMMIT');
    return rows[0];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function removeExpertSkill({ expertId, skillId }) {
  const { rows } = await query(
    `DELETE FROM app.expert_skills WHERE expert_id = $1 AND skill_id = $2
     RETURNING id`,
    [expertId, skillId]
  );
  return rows[0];
}

// Experience operations
export async function getExpertExperience(expertId) {
  const { rows } = await query(
    `SELECT id, position, organization, years, description, start_year, end_year
     FROM app.expert_experience
     WHERE expert_id = $1
     ORDER BY start_year DESC`,
    [expertId]
  );
  return rows;
}

export async function addExpertExperience({ expertId, position, organization, years, description, startYear, endYear }) {
  const { rows } = await query(
    `INSERT INTO app.expert_experience 
       (expert_id, position, organization, years, description, start_year, end_year, created_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7, now())
     RETURNING id, expert_id, position, organization, years, description, start_year, end_year`,
    [expertId, position, organization, years, description, startYear, endYear]
  );
  return rows[0];
}

export async function updateExpertExperience({ id, position, organization, years, description, startYear, endYear }) {
  const { rows } = await query(
    `UPDATE app.expert_experience
       SET position = $1, organization = $2, years = $3, description = $4, 
           start_year = $5, end_year = $6, updated_at = now()
     WHERE id = $7
     RETURNING id, expert_id, position, organization, years, description, start_year, end_year`,
    [position, organization, years, description, startYear, endYear, id]
  );
  return rows[0];
}

export async function removeExpertExperience({ id, expertId }) {
  const { rows } = await query(
    `DELETE FROM app.expert_experience WHERE id = $1 AND expert_id = $2
     RETURNING id`,
    [id, expertId]
  );
  return rows[0];
}

// Education operations
export async function getExpertEducation(expertId) {
  const { rows } = await query(
    `SELECT id, degree, institution, year_completed, description
     FROM app.expert_education
     WHERE expert_id = $1
     ORDER BY year_completed DESC`,
    [expertId]
  );
  return rows;
}

export async function addExpertEducation({ expertId, degree, institution, yearCompleted, description }) {
  const { rows } = await query(
    `INSERT INTO app.expert_education 
       (expert_id, degree, institution, year_completed, description, created_at)
     VALUES ($1, $2, $3, $4, $5, now())
     RETURNING id, expert_id, degree, institution, year_completed, description`,
    [expertId, degree, institution, yearCompleted, description]
  );
  return rows[0];
}

export async function updateExpertEducation({ id, degree, institution, yearCompleted, description }) {
  const { rows } = await query(
    `UPDATE app.expert_education
       SET degree = $1, institution = $2, year_completed = $3, description = $4, updated_at = now()
     WHERE id = $5
     RETURNING id, expert_id, degree, institution, year_completed, description`,
    [degree, institution, yearCompleted, description, id]
  );
  return rows[0];
}

export async function removeExpertEducation({ id, expertId }) {
  const { rows } = await query(
    `DELETE FROM app.expert_education WHERE id = $1 AND expert_id = $2
     RETURNING id`,
    [id, expertId]
  );
  return rows[0];
}

// Certifications operations
export async function getExpertCertifications(expertId) {
  const { rows } = await query(
    `SELECT id, certificate_name, issuing_org, issued_at, expires_at, credential_url
     FROM app.expert_certifications
     WHERE expert_id = $1
     ORDER BY issued_at DESC`,
    [expertId]
  );
  return rows;
}

export async function addExpertCertification({ expertId, certificateName, issuingOrg, issuedAt, expiresAt, credentialUrl }) {
  const { rows } = await query(
    `INSERT INTO app.expert_certifications 
       (expert_id, certificate_name, issuing_org, issued_at, expires_at, credential_url, created_at)
     VALUES ($1, $2, $3, $4, $5, $6, now())
     RETURNING id, expert_id, certificate_name, issuing_org, issued_at, expires_at, credential_url`,
    [expertId, certificateName, issuingOrg, issuedAt, expiresAt, credentialUrl]
  );
  return rows[0];
}

export async function updateExpertCertification({ id, certificateName, issuingOrg, issuedAt, expiresAt, credentialUrl }) {
  const { rows } = await query(
    `UPDATE app.expert_certifications
       SET certificate_name = $1, issuing_org = $2, issued_at = $3, expires_at = $4, 
           credential_url = $5, updated_at = now()
     WHERE id = $6
     RETURNING id, expert_id, certificate_name, issuing_org, issued_at, expires_at, credential_url`,
    [certificateName, issuingOrg, issuedAt, expiresAt, credentialUrl, id]
  );
  return rows[0];
}

export async function removeExpertCertification({ id, expertId }) {
  const { rows } = await query(
    `DELETE FROM app.expert_certifications WHERE id = $1 AND expert_id = $2
     RETURNING id`,
    [id, expertId]
  );
  return rows[0];
}

// Availability operations
export async function getExpertAvailability(expertId, dateFrom = null, dateTo = null) {
  let whereClause = "WHERE expert_id = $1";
  let queryParams = [expertId];
  
  if (dateFrom) {
    whereClause += ` AND end_at >= $${queryParams.length + 1}`;
    queryParams.push(dateFrom);
  }
  
  if (dateTo) {
    whereClause += ` AND start_at <= $${queryParams.length + 1}`;
    queryParams.push(dateTo);
  }
  
  const { rows } = await query(
    `SELECT id, start_at, end_at, is_recurring, recurring_pattern, created_at
     FROM app.expert_availabilities
     ${whereClause}
     ORDER BY start_at`,
    queryParams
  );
  return rows;
}

export async function addExpertAvailability({ expertId, startAt, endAt, isRecurring = false, recurringPattern = null }) {
  const { rows } = await query(
    `INSERT INTO app.expert_availabilities 
       (expert_id, start_at, end_at, is_recurring, recurring_pattern, created_at)
     VALUES ($1, $2, $3, $4, $5, now())
     RETURNING id, expert_id, start_at, end_at, is_recurring, recurring_pattern`,
    [expertId, startAt, endAt, isRecurring, recurringPattern]
  );
  return rows[0];
}

export async function updateExpertAvailability({ id, startAt, endAt, isRecurring, recurringPattern }) {
  const { rows } = await query(
    `UPDATE app.expert_availabilities
       SET start_at = $1, end_at = $2, is_recurring = $3, recurring_pattern = $4, updated_at = now()
     WHERE id = $5
     RETURNING id, expert_id, start_at, end_at, is_recurring, recurring_pattern`,
    [startAt, endAt, isRecurring, recurringPattern, id]
  );
  return rows[0];
}

export async function removeExpertAvailability({ id, expertId }) {
  const { rows } = await query(
    `DELETE FROM app.expert_availabilities WHERE id = $1 AND expert_id = $2
     RETURNING id`,
    [id, expertId]
  );
  return rows[0];
}

// Target audience operations
export async function getExpertTargetAudience(expertId) {
  const { rows } = await query(
    `SELECT ea.id, a.id as audience_id, a.name
     FROM app.expert_audience ea
     JOIN app.audience a ON ea.audience_id = a.id
     WHERE ea.expert_id = $1
     ORDER BY a.name`,
    [expertId]
  );
  return rows;
}

export async function updateExpertTargetAudience({ expertId, audienceIds }) {
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    
    // Remove existing audience associations
    await client.query(
      `DELETE FROM app.expert_audience WHERE expert_id = $1`,
      [expertId]
    );
    
    // Add new audience associations
    if (audienceIds && audienceIds.length > 0) {
      const values = audienceIds.map((audienceId, index) => 
        `($1, $${index + 2})`
      ).join(', ');
      
      await client.query(
        `INSERT INTO app.expert_audience (expert_id, audience_id) VALUES ${values}`,
        [expertId, ...audienceIds]
      );
    }
    
    await client.query('COMMIT');
    return { success: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Domains operations
export async function getExpertDomains(expertId) {
  const { rows } = await query(
    `SELECT ed.id, d.id as domain_id, d.name
     FROM app.expert_domains ed
     JOIN app.domains d ON ed.domain_id = d.id
     WHERE ed.expert_id = $1
     ORDER BY d.name`,
    [expertId]
  );
  return rows;
}

export async function updateExpertDomains({ expertId, domainIds }) {
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    
    // Remove existing domain associations
    await client.query(
      `DELETE FROM app.expert_domains WHERE expert_id = $1`,
      [expertId]
    );
    
    // Add new domain associations
    if (domainIds && domainIds.length > 0) {
      const values = domainIds.map((domainId, index) => 
        `($1, $${index + 2})`
      ).join(', ');
      
      await client.query(
        `INSERT INTO app.expert_domains (expert_id, domain_id) VALUES ${values}`,
        [expertId, ...domainIds]
      );
    }
    
    await client.query('COMMIT');
    return { success: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Media/portfolio operations
export async function getExpertMedia(expertId) {
  const { rows } = await query(
    `SELECT id, media_type, url, title, description, created_at
     FROM app.expert_media
     WHERE expert_id = $1
     ORDER BY created_at DESC`,
    [expertId]
  );
  return rows;
}

export async function addExpertMedia({ expertId, mediaType, url, title, description }) {
  const { rows } = await query(
    `INSERT INTO app.expert_media (expert_id, media_type, url, title, description, created_at)
     VALUES ($1, $2, $3, $4, $5, now())
     RETURNING id, expert_id, media_type, url, title, description, created_at`,
    [expertId, mediaType, url, title, description]
  );
  return rows[0];
}

export async function updateExpertMedia({ id, mediaType, url, title, description }) {
  const { rows } = await query(
    `UPDATE app.expert_media
       SET media_type = $1, url = $2, title = $3, description = $4, updated_at = now()
     WHERE id = $5
     RETURNING id, expert_id, media_type, url, title, description`,
    [mediaType, url, title, description, id]
  );
  return rows[0];
}

export async function removeExpertMedia({ id, expertId }) {
  const { rows } = await query(
    `DELETE FROM app.expert_media WHERE id = $1 AND expert_id = $2
     RETURNING id`,
    [id, expertId]
  );
  return rows[0];
}

// Expert status operations
export async function getExpertStatus(expertId) {
  const { rows } = await query(
    `SELECT es.id, es.is_available, es.current_status, es.status_message, es.last_seen_at
     FROM app.expert_status es
     WHERE es.expert_id = $1`,
    [expertId]
  );
  return rows[0];
}

export async function updateExpertStatus({ expertId, isAvailable, currentStatus, statusMessage }) {
  const { rows } = await query(
    `INSERT INTO app.expert_status (expert_id, is_available, current_status, status_message, last_seen_at)
     VALUES ($1, $2, $3, $4, now())
     ON CONFLICT (expert_id) DO UPDATE SET
       is_available = EXCLUDED.is_available,
       current_status = EXCLUDED.current_status,
       status_message = EXCLUDED.status_message,
       last_seen_at = now()
     RETURNING id, expert_id, is_available, current_status, status_message, last_seen_at`,
    [expertId, isAvailable, currentStatus, statusMessage]
  );
  return rows[0];
}

// Performance operations
export async function getExpertPerformance(expertId) {
  const { rows } = await query(
    `SELECT ep.id, ep.response_time_avg, ep.session_completion_rate, ep.satisfaction_score, 
            ep.total_sessions, ep.total_earnings, ep.updated_at
     FROM app.expert_performance ep
     WHERE ep.expert_id = $1`,
    [expertId]
  );
  return rows[0];
}

export async function updateExpertPerformance({ expertId, responseTimeAvg, sessionCompletionRate, satisfactionScore }) {
  const { rows } = await query(
    `INSERT INTO app.expert_performance 
       (expert_id, response_time_avg, session_completion_rate, satisfaction_score, updated_at)
     VALUES ($1, $2, $3, $4, now())
     ON CONFLICT (expert_id) DO UPDATE SET
       response_time_avg = EXCLUDED.response_time_avg,
       session_completion_rate = EXCLUDED.session_completion_rate,
       satisfaction_score = EXCLUDED.satisfaction_score,
       updated_at = now()
     RETURNING id, expert_id, response_time_avg, session_completion_rate, satisfaction_score, updated_at`,
    [expertId, responseTimeAvg, sessionCompletionRate, satisfactionScore]
  );
  return rows[0];
}

// Search and listing operations
export async function searchExperts({ searchTerm, specialties, minPrice, maxPrice, minRating, kycStatus, isAvailable, page = 1, limit = 20 }) {
  let whereClauses = [];
  let queryParams = [];
  let paramIndex = 1;

  // Build WHERE clauses
  if (searchTerm) {
    whereClauses.push(`(
      up.display_name ILIKE $${paramIndex} OR 
      ep.intro ILIKE $${paramIndex} OR
      $${paramIndex} = ANY(ep.specialties)
    )`);
    queryParams.push(`%${searchTerm}%`);
    paramIndex++;
  }

  if (specialties && specialties.length > 0) {
    whereClauses.push(`ep.specialties && $${paramIndex}`);
    queryParams.push(specialties);
    paramIndex++;
  }

  if (minPrice !== undefined) {
    whereClauses.push(`ep.price_per_session >= $${paramIndex}`);
    queryParams.push(minPrice);
    paramIndex++;
  }

  if (maxPrice !== undefined) {
    whereClauses.push(`ep.price_per_session <= $${paramIndex}`);
    queryParams.push(maxPrice);
    paramIndex++;
  }

  if (minRating !== undefined) {
    whereClauses.push(`ep.rating_avg >= $${paramIndex}`);
    queryParams.push(minRating);
    paramIndex++;
  }

  if (kycStatus) {
    whereClauses.push(`ep.kyc_status = $${paramIndex}`);
    queryParams.push(kycStatus);
    paramIndex++;
  }

  if (isAvailable !== undefined) {
    whereClauses.push(`es.is_available = $${paramIndex}`);
    queryParams.push(isAvailable);
    paramIndex++;
  }

  const whereClause = whereClauses.length > 0 ? `WHERE ${whereClauses.join(' AND ')}` : '';
  const offset = (page - 1) * limit;

  const { rows } = await query(
    `SELECT DISTINCT 
       ep.id as expert_id, ep.user_id, ep.specialties, ep.price_per_session, 
       ep.rating_avg, ep.intro, ep.kyc_status,
       u.handle, up.display_name, up.avatar_url,
       es.is_available, es.current_status
     FROM app.expert_profiles ep
     JOIN app.users u ON ep.user_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.expert_status es ON ep.id = es.expert_id
     ${whereClause}
     ORDER BY ep.rating_avg DESC, ep.created_at DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...queryParams, limit, offset]
  );

  // Get total count
  const { rows: countRows } = await query(
    `SELECT COUNT(DISTINCT ep.id) as total
     FROM app.expert_profiles ep
     JOIN app.users u ON ep.user_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.expert_status es ON ep.id = es.expert_id
     ${whereClause}`,
    queryParams
  );

  return {
    experts: rows,
    pagination: {
      page,
      limit,
      total: parseInt(countRows[0].total),
      totalPages: Math.ceil(countRows[0].total / limit)
    }
  };
}

export async function getExpertById(expertId) {
  const { rows } = await query(
    `SELECT 
       ep.id as expert_id, ep.user_id, ep.specialties, ep.price_per_session, 
       ep.rating_avg, ep.intro, ep.kyc_status,
       u.handle, up.display_name, up.avatar_url,
       es.is_available, es.current_status, es.status_message
     FROM app.expert_profiles ep
     JOIN app.users u ON ep.user_id = u.id
     LEFT JOIN app.user_profiles up ON u.id = up.user_id
     LEFT JOIN app.expert_status es ON ep.id = es.expert_id
     WHERE ep.id = $1`,
    [expertId]
  );
  return rows[0];
}

// Statistics and analytics
export async function getExpertStats(expertId) {
  const { rows } = await query(
    `SELECT 
       COUNT(DISTINCT b.id) as total_bookings,
       COUNT(DISTINCT CASE WHEN b.status = 'COMPLETED' THEN b.id END) as completed_bookings,
       COUNT(DISTINCT CASE WHEN b.status = 'CANCELLED' THEN b.id END) as cancelled_bookings,
       COALESCE(AVG(CASE WHEN r.rating IS NOT NULL THEN r.rating END), 0) as avg_rating,
       COUNT(DISTINCT r.id) as total_reviews,
       COALESCE(SUM(CASE WHEN b.status = 'COMPLETED' THEN b.price END), 0) as total_earnings
     FROM app.expert_profiles ep
     LEFT JOIN app.bookings b ON ep.id = b.expert_id
     LEFT JOIN app.reviews r ON b.id = r.booking_id
     WHERE ep.id = $1`,
    [expertId]
  );
  return rows[0];
}

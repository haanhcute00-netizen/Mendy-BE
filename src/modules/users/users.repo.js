import { query } from "../../config/db.js";

export async function createUserWithHandle({ handle, passwordHash }) {
  const { rows } = await query(
    `INSERT INTO app.users (handle, password_hash)
     VALUES ($1, $2)
     RETURNING id, handle, role_primary, status, created_at`,
    [handle, passwordHash]
  );
  return rows[0];
}

// NEW: Create user with email support
export async function createUser({ handle, email, passwordHash }) {
  const { rows } = await query(
    `INSERT INTO app.users (handle, email, password_hash)
     VALUES ($1, $2, $3)
     RETURNING id, handle, email, role_primary, status, created_at`,
    [handle, email || null, passwordHash]
  );
  return rows[0];
}

// NEW: Create user with display_name (creates user + profile in transaction)
export async function createUserWithProfile({ handle, email, passwordHash, displayName }) {
  // Start transaction
  const client = await (await import("../../config/db.js")).pool.connect();
  try {
    await client.query('BEGIN');

    // Create user
    const { rows: userRows } = await client.query(
      `INSERT INTO app.users (handle, email, password_hash)
       VALUES ($1, $2, $3)
       RETURNING id, handle, email, role_primary, status, created_at`,
      [handle, email || null, passwordHash]
    );
    const user = userRows[0];

    // Create profile with display_name
    await client.query(
      `INSERT INTO app.user_profiles (user_id, display_name, is_anonymous)
       VALUES ($1, $2, true)`,
      [user.id, displayName]
    );

    await client.query('COMMIT');

    return { ...user, display_name: displayName };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

export const findAppUserById = async (id) => {
  const result = await query(
    `SELECT * FROM app.users WHERE id = $1`,
    [id]
  );
  return result.rows[0];
};

export async function getByHandle(handle) {
  const { rows } = await query(
    `SELECT id, handle, password_hash, role_primary, is_email_verified, email, status
     FROM app.users
     WHERE handle = $1`,
    [handle]
  );
  return rows[0];
}

// NEW: Get user by email
export async function getByEmail(email) {
  const { rows } = await query(
    `SELECT id, handle, email, password_hash, role_primary, is_email_verified, status
     FROM app.users
     WHERE LOWER(email) = LOWER($1)`,
    [email]
  );
  return rows[0];
}

// NEW: Get user by email OR handle (for flexible login)
export async function getByEmailOrHandle(identifier) {
  const { rows } = await query(
    `SELECT id, handle, email, password_hash, role_primary, is_email_verified, status
     FROM app.users
     WHERE LOWER(email) = LOWER($1) OR handle = $1
     LIMIT 1`,
    [identifier]
  );
  return rows[0];
}

export async function findUserByEmail(email) {
  const { rows } = await query(
    `SELECT id, handle, email, password_hash, role_primary, is_email_verified
     FROM app.users WHERE email = $1`,
    [email]
  );
  return rows[0];
}

// tạo user "chính" tương ứng cho Google user
export const createAppUserForGoogle = async ({ email, name, googleId }) => {

  const base =
    email?.split("@")[0] || `google_${(googleId || "").slice(0, 8) || "user"}`;
  const handle = `${base}_${Date.now().toString(36)}`;


  const passwordHash = "GOOGLE_OAUTH_ONLY";

  const result = await query(
    `
    INSERT INTO app.users (handle, email, password_hash)
    VALUES ($1, $2, $3)
    RETURNING *
    `,
    [handle, email || null, passwordHash]
  );

  return result.rows[0];
};




export async function upsertProfile({
  userId,
  displayName,
  avatarUrl,
  yob,
  gender,
  attachmentUrl,
  isAnonymous = true, // thêm tham số mới, mặc định true
}) {
  const prefs = { attachment_url: attachmentUrl ?? null };

  const { rows } = await query(
    `INSERT INTO app.user_profiles
       (user_id, display_name, avatar_url, year_of_birth, gender, preferences, is_anonymous)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     ON CONFLICT (user_id)
     DO UPDATE SET
         display_name   = EXCLUDED.display_name,
         avatar_url     = EXCLUDED.avatar_url,
         year_of_birth  = EXCLUDED.year_of_birth,
         gender         = EXCLUDED.gender,
         preferences    = EXCLUDED.preferences,
         is_anonymous   = EXCLUDED.is_anonymous,
         updated_at     = now()
     RETURNING user_id, display_name, avatar_url, year_of_birth, gender, preferences, is_anonymous`,
    [
      userId,
      displayName ?? null,
      avatarUrl ?? null,
      yob ?? null,
      gender ?? "UNSPECIFIED",
      prefs,
      isAnonymous,
    ]
  );

  return rows[0];
}



export async function setPrimaryRole(userId, role) {
  const { rows } = await query(
    `UPDATE app.users SET role_primary = $2, updated_at = now()
     WHERE id = $1 RETURNING id, role_primary`,
    [userId, role]
  );
  return rows[0];
}


export async function getById(id) {
  const { rows } = await query(
    `SELECT id, handle, email, role_primary, is_email_verified
       FROM app.users
      WHERE id = $1`,
    [id]
  );
  return rows[0];
}

export async function getProfileByUserId(userId) {
  const { rows } = await query(
    `
    SELECT
      u.id, u.handle, u.email, u.phone, u.role_primary, u.is_email_verified, 
      u.status, u.created_at, u.updated_at,

      -- User profile
      p.display_name, p.avatar_url, p.bio, p.gender, p.year_of_birth,
      p.updated_at as profile_updated_at, p.is_anonymous,
      COALESCE(p.preferences, '{}') as preferences,

      -- Roles
      COALESCE(
        json_agg(
          DISTINCT jsonb_build_object('role', ur.role)
        ) FILTER (WHERE ur.role IS NOT NULL), 
        '[]'::json
      ) AS roles,

      -- Attached files
      COALESCE(
        json_agg(
          DISTINCT jsonb_build_object(
            'id', uf.id,
            'file_type', uf.file_type,
            'file_url', uf.file_url,
            'mime_type', uf.mime_type,
            'byte_size', uf.byte_size,
            'created_at', uf.created_at
          )
        ) FILTER (WHERE uf.id IS NOT NULL),
        '[]'::json
      ) AS files,

      -- Expert basic profile
      COALESCE(
        jsonb_build_object(
          'id', ep.id,
          'specialties', ep.specialties,
          'price_per_session', ep.price_per_session,
          'rating_avg', ep.rating_avg,
          'kyc_status', ep.kyc_status,
          'intro', ep.intro
        ),
        NULL
      ) AS expert_profile,

      -- FULL Expert Skills
      (
        SELECT COALESCE(
          json_agg(
            jsonb_build_object(
              'id', s.id,
              'name', s.name,
              'category', s.category
            )
          ), '[]'
        )
        FROM app.expert_skills es
        JOIN app.skills s ON s.id = es.skill_id
        WHERE es.expert_id = ep.id
      ) AS expert_skills,

      -- FULL Experience
      (
        SELECT COALESCE(
          json_agg(
            jsonb_build_object(
              'id', ee.id,
              'position', ee.position,
              'organization', ee.organization,
              'years', ee.years,
              'description', ee.description,
              'start_year', ee.start_year,
              'end_year', ee.end_year
            )
          ), '[]'
        )
        FROM app.expert_experience ee
        WHERE ee.expert_id = ep.id
      ) AS expert_experience,

      -- FULL Education
      (
        SELECT COALESCE(
          json_agg(
            jsonb_build_object(
              'id', edu.id,
              'degree', edu.degree,
              'institution', edu.institution,
              'year_completed', edu.year_completed,
              'description', edu.description
            )
          ), '[]'
        )
        FROM app.expert_education edu
        WHERE edu.expert_id = ep.id
      ) AS expert_education,

      -- FULL Certifications
      (
        SELECT COALESCE(
          json_agg(
            jsonb_build_object(
              'id', cert.id,
              'certificate_name', cert.certificate_name,
              'issuing_org', cert.issuing_org,
              'issued_at', cert.issued_at,
              'expires_at', cert.expires_at,
              'credential_url', cert.credential_url
            )
          ), '[]'
        )
        FROM app.expert_certifications cert
        WHERE cert.expert_id = ep.id
      ) AS expert_certifications,

      -- Expert Performance
      (
        SELECT row_to_json(epf)
        FROM app.expert_performance epf
        WHERE epf.expert_id = ep.id
      ) AS expert_performance,

      -- Expert Realtime Status
      (
        SELECT row_to_json(es)
        FROM app.expert_status es
        WHERE es.expert_id = ep.id
      ) AS expert_status,

      -- Expert Media / Portfolio
      (
        SELECT COALESCE(
          json_agg(
            jsonb_build_object(
              'id', em.id,
              'media_type', em.media_type,
              'url', em.url,
              'title', em.title,
              'description', em.description,
              'created_at', em.created_at
            )
          ), '[]'
        )
        FROM app.expert_media em
        WHERE em.expert_id = ep.id
      ) AS expert_media,

      -- Expert Target Audience
      (
        SELECT COALESCE(
          json_agg(
            jsonb_build_object(
              'id', a.id,
              'name', a.name
            )
          ), '[]'
        )
        FROM app.expert_audience ea
        JOIN app.audience a ON a.id = ea.audience_id
        WHERE ea.expert_id = ep.id
      ) AS expert_audience,

      -- Expert Domains
      (
        SELECT COALESCE(
          json_agg(
            jsonb_build_object(
              'id', d.id,
              'name', d.name
            )
          ), '[]'
        )
        FROM app.expert_domain ed
        JOIN app.domains d ON d.id = ed.domain_id
        WHERE ed.expert_id = ep.id
      ) AS expert_domains,

      -- Listener profile
      COALESCE(
        jsonb_build_object(
          'id', lp.id,
          'intro', lp.intro,
          'verified', lp.verified
        ),
        NULL
      ) AS listener_profile,

      -- Wallet
      COALESCE(
        jsonb_build_object(
          'id', w.id,
          'balance', w.balance
        ),
        NULL
      ) AS wallet,

      -- Following & followers
      (SELECT COUNT(*) FROM app.user_follows WHERE follower_id = $1) AS following_count,
      (SELECT COUNT(*) FROM app.user_follows WHERE followee_id = $1) AS followers_count,

      -- Posts count
      (SELECT COUNT(*) FROM app.posts WHERE author_id = $1) AS posts_count,

      -- Completed expert sessions
      (
        SELECT COUNT(*)
        FROM app.bookings b
        JOIN app.expert_profiles ep2 ON ep2.id = b.expert_id
        WHERE ep2.user_id = $1
          AND b.status = 'COMPLETED'
      ) AS completed_sessions

    FROM app.users u
    LEFT JOIN app.user_profiles p ON p.user_id = u.id
    LEFT JOIN app.user_roles ur ON ur.user_id = u.id
    LEFT JOIN app.user_files uf ON uf.user_id = u.id
    LEFT JOIN app.expert_profiles ep ON ep.user_id = u.id
    LEFT JOIN app.listener_profiles lp ON lp.user_id = u.id
    LEFT JOIN app.wallets w ON w.owner_user_id = u.id

    WHERE u.id = $1
    GROUP BY 
      u.id, p.display_name, p.avatar_url, p.bio, p.gender, p.year_of_birth,
      p.updated_at, p.is_anonymous, p.preferences, ep.id, lp.id, w.id
    `,
    [userId]
  );

  return rows[0];
}




// ========== UPDATE PROFILE ==========
export async function updateBasicProfile({ userId, displayName, bio, gender, yearOfBirth, isAnonymous }) {
  const updates = [];
  const params = [userId];
  let paramIndex = 2;

  if (displayName !== undefined) {
    updates.push(`display_name = $${paramIndex++}`);
    params.push(displayName);
  }
  if (bio !== undefined) {
    updates.push(`bio = $${paramIndex++}`);
    params.push(bio);
  }
  if (gender !== undefined) {
    updates.push(`gender = $${paramIndex++}`);
    params.push(gender);
  }
  if (yearOfBirth !== undefined) {
    updates.push(`year_of_birth = $${paramIndex++}`);
    params.push(yearOfBirth);
  }
  if (isAnonymous !== undefined) {
    updates.push(`is_anonymous = $${paramIndex++}`);
    params.push(isAnonymous);
  }

  if (updates.length === 0) return null;

  updates.push("updated_at = now()");

  const { rows } = await query(
    `UPDATE app.user_profiles 
         SET ${updates.join(", ")}
         WHERE user_id = $1
         RETURNING user_id, display_name, bio, avatar_url, gender, year_of_birth, is_anonymous, updated_at`,
    params
  );
  return rows[0];
}

// ========== SEARCH USERS ==========
export async function searchUsers({ query: searchQuery, limit = 20, offset = 0, excludeUserId }) {
  const { rows } = await query(
    `SELECT u.id, u.handle, u.role_primary, u.created_at,
                up.display_name, up.avatar_url, up.is_anonymous
         FROM app.users u
         LEFT JOIN app.user_profiles up ON up.user_id = u.id
         WHERE u.status = 'ACTIVE'
           AND u.id != $1
           AND (
               u.handle ILIKE $2
               OR up.display_name ILIKE $2
           )
         ORDER BY 
           CASE WHEN u.handle ILIKE $3 THEN 0 ELSE 1 END,
           u.created_at DESC
         LIMIT $4 OFFSET $5`,
    [excludeUserId, `%${searchQuery}%`, `${searchQuery}%`, limit, offset]
  );
  return rows;
}

// ========== FOLLOWERS / FOLLOWING ==========
export async function getFollowers({ userId, limit = 50, offset = 0 }) {
  const { rows } = await query(
    `SELECT u.id, u.handle, u.role_primary,
                up.display_name, up.avatar_url, up.is_anonymous,
                uf.created_at as followed_at
         FROM app.user_follows uf
         JOIN app.users u ON u.id = uf.follower_id
         LEFT JOIN app.user_profiles up ON up.user_id = u.id
         WHERE uf.followee_id = $1
           AND u.status = 'ACTIVE'
         ORDER BY uf.created_at DESC
         LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

export async function getFollowing({ userId, limit = 50, offset = 0 }) {
  const { rows } = await query(
    `SELECT u.id, u.handle, u.role_primary,
                up.display_name, up.avatar_url, up.is_anonymous,
                uf.created_at as followed_at
         FROM app.user_follows uf
         JOIN app.users u ON u.id = uf.followee_id
         LEFT JOIN app.user_profiles up ON up.user_id = u.id
         WHERE uf.follower_id = $1
           AND u.status = 'ACTIVE'
         ORDER BY uf.created_at DESC
         LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

// ========== BLOCK USERS ==========
export async function blockUser({ blockerId, blockedId }) {
  await query(
    `INSERT INTO app.user_blocks (blocker_id, blocked_id)
         VALUES ($1, $2)
         ON CONFLICT (blocker_id, blocked_id) DO NOTHING`,
    [blockerId, blockedId]
  );
  return true;
}

export async function unblockUser({ blockerId, blockedId }) {
  const { rowCount } = await query(
    `DELETE FROM app.user_blocks WHERE blocker_id = $1 AND blocked_id = $2`,
    [blockerId, blockedId]
  );
  return rowCount > 0;
}

export async function isBlocked({ blockerId, blockedId }) {
  const { rows } = await query(
    `SELECT 1 FROM app.user_blocks WHERE blocker_id = $1 AND blocked_id = $2 LIMIT 1`,
    [blockerId, blockedId]
  );
  return !!rows[0];
}

export async function getBlockedUsers({ userId, limit = 50, offset = 0 }) {
  const { rows } = await query(
    `SELECT u.id, u.handle,
                up.display_name, up.avatar_url,
                ub.created_at as blocked_at
         FROM app.user_blocks ub
         JOIN app.users u ON u.id = ub.blocked_id
         LEFT JOIN app.user_profiles up ON up.user_id = u.id
         WHERE ub.blocker_id = $1
         ORDER BY ub.created_at DESC
         LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

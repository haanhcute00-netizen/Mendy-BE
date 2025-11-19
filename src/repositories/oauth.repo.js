import { query } from "../config/db.js";

export const findOAuthByGoogleId = async (googleId) => {
  const result = await query(
    `SELECT * FROM app.oauth_users WHERE google_id = $1`,
    [googleId]
  );
  return result.rows[0];
};

export const createOAuthUser = async ({
  appUserId,
  googleId,
  email,
  name,
  avatar,
}) => {
  const result = await query(
    `
    INSERT INTO app.oauth_users (app_user_id, google_id, email, name, avatar)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *
    `,
    [appUserId, googleId, email || null, name || null, avatar || null]
  );
  return result.rows[0];
};

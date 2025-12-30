import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import * as UsersRepo from "../users/users.repo.js";
import { query } from "../../config/db.js";
import { sendMail } from "../../config/mailer.js";

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET || JWT_SECRET.length < 32) {
  throw new Error("JWT_SECRET must be set to a strong random value (>=32 chars)");
}
const TOKEN_TTL = process.env.TOKEN_TTL;
const JWT_ISS = process.env.JWT_ISS;
const JWT_AUD = process.env.JWT_AUD;


export const sign = (user) => jwt.sign(
  { sub: user.id, role: user.role_primary || "SEEKER", typ: "access" },
  JWT_SECRET,
  { expiresIn: TOKEN_TTL, issuer: JWT_ISS, audience: JWT_AUD }
);

export const signAccess = (user) =>
  jwt.sign({ sub: user.id, role: user.role_primary, typ: "access" }, JWT_SECRET, {
    expiresIn: process.env.TOKEN_TTL || "1h",
    issuer: JWT_ISS,
    audience: JWT_AUD,
  });

export const signRefresh = (user) =>
  jwt.sign({ sub: user.id, typ: "refresh" }, JWT_SECRET, {
    expiresIn: process.env.REFRESH_TTL || "30d",
    issuer: JWT_ISS,
    audience: JWT_AUD,
  });


export async function registerStep1({ handle, email, password, displayName }) {
  if (!handle || !password) {
    const e = new Error("handle & password are required"); e.status = 400; throw e;
  }

  // Validate display_name (required)
  if (!displayName || !displayName.trim()) {
    const e = new Error("display_name is required"); e.status = 400; throw e;
  }

  const trimmedDisplayName = displayName.trim();
  if (trimmedDisplayName.length < 2 || trimmedDisplayName.length > 50) {
    const e = new Error("display_name must be between 2 and 50 characters"); e.status = 400; throw e;
  }

  // Validate email if provided
  if (email) {
    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
    if (!emailRegex.test(email)) {
      const e = new Error("Invalid email format"); e.status = 400; throw e;
    }

    // Check email exists
    const existingEmail = await UsersRepo.getByEmail(email);
    if (existingEmail) {
      const e = new Error("Email already exists"); e.status = 409; throw e;
    }
  }

  // Check handle exists
  const existed = await UsersRepo.getByHandle(handle);
  if (existed) { const e = new Error("Handle already exists"); e.status = 409; throw e; }

  const hash = await bcrypt.hash(password, 10);
  const user = await UsersRepo.createUserWithProfile({
    handle,
    email: email || null,
    passwordHash: hash,
    displayName: trimmedDisplayName
  });
  const token = sign(user);
  return { user, token, expires_in: TOKEN_TTL };
}

export async function login({ identifier, password, ip, agent }) {
  // identifier can be email or handle
  const user = await UsersRepo.getByEmailOrHandle(identifier);
  if (!user) throw Object.assign(new Error("Invalid email or handle"), { status: 401 });

  // Check account status
  if (user.status === 'SUSPENDED') {
    throw Object.assign(new Error("Account suspended"), { status: 403 });
  }
  if (user.status === 'DELETED') {
    throw Object.assign(new Error("Account not found"), { status: 401 });
  }

  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) throw Object.assign(new Error("Invalid password"), { status: 401 });

  const access = signAccess(user);
  const refresh = signRefresh(user);
  const expiresAt = new Date(Date.now() + 1000 * 60 * 60); // 1h

  // 🔹 lưu session vào DB
  await query(
    `INSERT INTO app.user_sessions (user_id, token, device_info, ip_address, expires_at)
     VALUES ($1,$2,$3,$4,$5)
     ON CONFLICT DO NOTHING`,
    [user.id, refresh, agent ?? null, ip ?? null, expiresAt]
  );

  return {
    user,
    access_token: access,
    refresh_token: refresh,
    expires_in: process.env.TOKEN_TTL || "1h",
  };
}


// ========== FORGOT PASSWORD ==========
const genOtp = () => String(Math.floor(100000 + Math.random() * 900000)); // 6 số

export async function forgotPassword({ email, ip, agent }) {
  if (!email) {
    throw Object.assign(new Error("Email is required"), { status: 400 });
  }

  // Validate email format
  const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
  if (!emailRegex.test(email)) {
    throw Object.assign(new Error("Invalid email format"), { status: 400 });
  }

  // Find user by email
  const user = await UsersRepo.getByEmail(email);
  if (!user) {
    // Return success even if email not found (security: don't reveal if email exists)
    return { sent: true, message: "If email exists, OTP will be sent" };
  }

  // Check account status
  if (user.status === 'SUSPENDED') {
    throw Object.assign(new Error("Account suspended"), { status: 403 });
  }
  if (user.status === 'DELETED') {
    return { sent: true, message: "If email exists, OTP will be sent" };
  }

  // Rate limit: max 3 requests per hour per email
  const { rows: recentRequests } = await query(
    `SELECT COUNT(*) as count FROM app.password_resets 
     WHERE email = $1 AND created_at > NOW() - INTERVAL '1 hour'`,
    [email]
  );
  if (parseInt(recentRequests[0].count) >= 3) {
    throw Object.assign(new Error("Too many requests. Please try again later."), { status: 429 });
  }

  const otp = genOtp();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 phút

  // Save OTP to database
  await query(
    `INSERT INTO app.password_resets (user_id, email, otp_code, expires_at, ip_address, user_agent)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [user.id, email, otp, expiresAt, ip ?? null, agent ?? null]
  );

  // Send email
  await sendMail({
    to: email,
    subject: "Mã OTP đặt lại mật khẩu - Healing",
    text: `Mã OTP đặt lại mật khẩu của bạn là: ${otp}\n\nMã có hiệu lực trong 10 phút.\n\nNếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #4A90A4;">Đặt lại mật khẩu</h2>
        <p>Xin chào,</p>
        <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Healing.</p>
        <p>Mã OTP của bạn là:</p>
        <div style="background: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0;">
          <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #333;">${otp}</span>
        </div>
        <p><strong>Mã có hiệu lực trong 10 phút.</strong></p>
        <p style="color: #666; font-size: 14px;">Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px;">Email này được gửi tự động từ Healing. Vui lòng không trả lời.</p>
      </div>
    `
  });

  return { sent: true, message: "OTP sent to email" };
}

// ========== VERIFY RESET OTP ==========
export async function verifyResetOtp({ email, otp }) {
  if (!email || !otp) {
    throw Object.assign(new Error("Email and OTP are required"), { status: 400 });
  }

  // Find latest unused OTP for this email
  const { rows } = await query(
    `SELECT id, user_id, otp_code, expires_at, used
     FROM app.password_resets
     WHERE email = $1 AND used = FALSE
     ORDER BY created_at DESC
     LIMIT 1`,
    [email]
  );

  const record = rows[0];
  if (!record) {
    throw Object.assign(new Error("OTP not found or expired"), { status: 400 });
  }

  if (record.expires_at < new Date()) {
    throw Object.assign(new Error("OTP expired"), { status: 400 });
  }

  if (record.otp_code !== otp) {
    throw Object.assign(new Error("Invalid OTP"), { status: 400 });
  }

  // Generate a temporary reset token (valid for 5 minutes)
  const resetToken = jwt.sign(
    { sub: record.user_id, email, purpose: "password_reset" },
    JWT_SECRET,
    { expiresIn: "5m" }
  );

  return { valid: true, reset_token: resetToken };
}

// ========== RESET PASSWORD ==========
export async function resetPassword({ email, otp, newPassword, resetToken }) {
  if (!newPassword) {
    throw Object.assign(new Error("New password is required"), { status: 400 });
  }

  if (newPassword.length < 6) {
    throw Object.assign(new Error("Password must be at least 6 characters"), { status: 400 });
  }

  let userId;

  // Method 1: Using reset_token (from verifyResetOtp)
  if (resetToken) {
    try {
      const payload = jwt.verify(resetToken, JWT_SECRET);
      if (payload.purpose !== "password_reset") {
        throw new Error("Invalid token");
      }
      userId = payload.sub;
    } catch (err) {
      throw Object.assign(new Error("Invalid or expired reset token"), { status: 400 });
    }
  }
  // Method 2: Using email + OTP directly
  else if (email && otp) {
    const { rows } = await query(
      `SELECT id, user_id, otp_code, expires_at, used
       FROM app.password_resets
       WHERE email = $1 AND used = FALSE
       ORDER BY created_at DESC
       LIMIT 1`,
      [email]
    );

    const record = rows[0];
    if (!record) {
      throw Object.assign(new Error("OTP not found or expired"), { status: 400 });
    }
    if (record.expires_at < new Date()) {
      throw Object.assign(new Error("OTP expired"), { status: 400 });
    }
    if (record.otp_code !== otp) {
      throw Object.assign(new Error("Invalid OTP"), { status: 400 });
    }

    userId = record.user_id;

    // Mark OTP as used
    await query(
      `UPDATE app.password_resets SET used = TRUE, used_at = NOW() WHERE id = $1`,
      [record.id]
    );
  } else {
    throw Object.assign(new Error("Either reset_token or (email + otp) is required"), { status: 400 });
  }

  // Hash new password
  const hash = await bcrypt.hash(newPassword, 10);

  // Update password
  await query(
    `UPDATE app.users SET password_hash = $1, updated_at = NOW() WHERE id = $2`,
    [hash, userId]
  );

  // Invalidate all password reset OTPs for this user
  await query(
    `UPDATE app.password_resets SET used = TRUE, used_at = NOW() 
     WHERE user_id = $1 AND used = FALSE`,
    [userId]
  );

  // Optionally: Revoke all existing sessions (force re-login)
  await query(
    `UPDATE app.user_sessions SET revoked = TRUE WHERE user_id = $1`,
    [userId]
  );

  return { success: true, message: "Password reset successfully" };
}

import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, failure, unauthorized } from "../../utils/response.js";
import * as AuthService from "./auth.service.js";
import jwt from "jsonwebtoken";
import * as UsersRepo from "../users/users.repo.js";
import passport from "passport";

// ========== FORGOT PASSWORD ==========
export const forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const ip = req.ip;
  const agent = req.headers['user-agent'];

  const result = await AuthService.forgotPassword({ email, ip, agent });
  return success(res, "auth.forgotPassword.success", result);
});

// ========== VERIFY RESET OTP ==========
export const verifyResetOtp = asyncHandler(async (req, res) => {
  const { email, otp } = req.body;

  if (!email || !otp) {
    return failure(res, "Email and OTP are required", 400);
  }

  const result = await AuthService.verifyResetOtp({ email, otp });
  return success(res, "auth.verifyOtp.success", result);
});

// ========== RESET PASSWORD ==========
export const resetPassword = asyncHandler(async (req, res) => {
  const { email, otp, new_password, reset_token } = req.body;

  if (!new_password) {
    return failure(res, "New password is required", 400);
  }

  const result = await AuthService.resetPassword({
    email,
    otp,
    newPassword: new_password,
    resetToken: reset_token
  });
  return success(res, "auth.resetPassword.success", result);
});

export const register = asyncHandler(async (req, res) => {
  const { handle, email, password } = req.body;
  const data = await AuthService.registerStep1({ handle, email, password });
  return created(res, "auth.register.success", data);
});

export const login = asyncHandler(async (req, res) => {
  // Accept 'identifier', 'email', or 'handle' for backward compatibility
  const { handle, email, identifier, password } = req.body;
  const loginIdentifier = identifier || email || handle;

  if (!loginIdentifier || !password) {
    return failure(res, "Email/handle and password are required");
  }

  const ip = req.ip;
  const agent = req.headers['user-agent'];
  const data = await AuthService.login({ identifier: loginIdentifier, password, ip, agent });
  return success(res, "auth.login.success", data);
});


export const refresh = asyncHandler(async (req, res) => {
  const { token } = req.body;
  if (!token) return failure(res, "auth.refresh.invalidToken");

  const payload = jwt.verify(token, process.env.JWT_SECRET, {
    issuer: process.env.JWT_ISS,
    audience: process.env.JWT_AUD,
  });

  if (payload.typ !== "refresh") throw Object.assign(new Error("Invalid token"), { status: 401 });

  const user = await UsersRepo.getById(payload.sub);
  if (!user) return unauthorized(res, "users.profile.notFound");

  return success(res, "auth.refresh.success", {
    access_token: AuthService.signAccess(user),
    expires_in: process.env.TOKEN_TTL || "1h",
  });
});



export const googleAuth = passport.authenticate("google", {
  scope: ["profile", "email"],
  session: false,
});

export const googleCallback = (req, res, next) => {
  passport.authenticate("google", { session: false }, async (err, user) => {
    const frontendUrl = process.env.FRONTEND_URL || 'https://mendy-three.vercel.app';

    if (err || !user) {
      console.error("Google OAuth error:", err);
      // Redirect về FE với error
      return res.redirect(`${frontendUrl}/auth/callback?error=login_failed`);
    }

    const accessToken = AuthService.signAccess(user);
    const refreshToken = AuthService.signRefresh(user);

    // Redirect về Frontend với data
    const responseData = {
      success: true,
      message: "Đăng nhập thành công",
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        user,
      }
    };

    const encodedData = encodeURIComponent(JSON.stringify(responseData));
    return res.redirect(`${frontendUrl}/auth/callback?data=${encodedData}`);
  })(req, res, next);
};

export const oauthProfile = asyncHandler(async (req, res) => {
  if (!req.user) return unauthorized(res, "errors.unauthorized");
  return success(res, "common.success", req.user);
});
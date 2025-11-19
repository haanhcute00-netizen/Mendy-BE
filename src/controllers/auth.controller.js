import { asyncHandler } from "../utils/asyncHandler.js";
import { created, success, failure, unauthorized } from "../utils/response.js";
import * as AuthService from "../services/auth.service.js";
import jwt from "jsonwebtoken";
import * as UsersRepo from "../repositories/users.repo.js"; 
import passport from "passport";

export const register = asyncHandler(async (req, res) => {
  const { handle, password } = req.body;          // ✅ chỉ 2 field
  const data = await AuthService.registerStep1({ handle, password });
  return created(res, "Registration successful", data);
});

export const login = asyncHandler(async (req, res) => {
  const { handle, password } = req.body;
  const ip = req.ip;
  const agent = req.headers['user-agent'];
  const data = await AuthService.login({ handle, password, ip, agent });
  return success(res, "Login successful", data);
});


export const refresh = asyncHandler(async (req, res) => {
  const { token } = req.body;
  if (!token) return failure(res, "Missing token");
  
  const payload = jwt.verify(token, process.env.JWT_SECRET, {
    issuer: process.env.JWT_ISS,
    audience: process.env.JWT_AUD,
  });
  
  if (payload.typ !== "refresh") throw Object.assign(new Error("Invalid token"), { status: 401 });

  const user = await UsersRepo.getById(payload.sub);
  if (!user) return unauthorized(res, "User not found");
  
  return success(res, "Token refreshed successfully", {
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
    if (err || !user) {
      console.error("Google OAuth error:", err);
      return unauthorized(res, "Google authentication failed");
    }

    const accessToken = AuthService.signAccess(user);
    const refreshToken = AuthService.signRefresh(user);

    return success(res, "Google login successful", {
      access_token: accessToken,
      refresh_token: refreshToken,
      user,
    });
  })(req, res, next);
};

export const oauthProfile = asyncHandler(async (req, res) => {
  if (!req.user) return unauthorized(res, "Not logged in");
  return success(res, "OAuth profile", req.user);
});
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, failure, unauthorized } from "../../utils/response.js";
import * as AuthService from "./auth.service.js";
import jwt from "jsonwebtoken";
import * as UsersRepo from "../users/users.repo.js";
import passport from "passport";

export const register = asyncHandler(async (req, res) => {
  const { handle, password } = req.body;          // ✅ chỉ 2 field
  const data = await AuthService.registerStep1({ handle, password });
  return created(res, "auth.register.success", data);
});

export const login = asyncHandler(async (req, res) => {
  const { handle, password } = req.body;
  const ip = req.ip;
  const agent = req.headers['user-agent'];
  const data = await AuthService.login({ handle, password, ip, agent });
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
    if (err || !user) {
      console.error("Google OAuth error:", err);
      return unauthorized(res, "auth.login.invalidCredentials");
    }

    const accessToken = AuthService.signAccess(user);
    const refreshToken = AuthService.signRefresh(user);

    return success(res, "auth.login.success", {
      access_token: accessToken,
      refresh_token: refreshToken,
      user,
    });
  })(req, res, next);
};

export const oauthProfile = asyncHandler(async (req, res) => {
  if (!req.user) return unauthorized(res, "errors.unauthorized");
  return success(res, "common.success", req.user);
});
import { Router } from "express";
import {
    register,
    login,
    refresh,
    googleAuth,
    googleCallback,
    oauthProfile,
    forgotPassword,
    verifyResetOtp,
    resetPassword
} from "./auth.controller.js";

const r = Router();

// Registration & Login
r.post("/register", register);
r.post("/login", login);
r.post("/refresh", refresh);

// Password Reset
r.post("/forgot-password", forgotPassword);
r.post("/verify-reset-otp", verifyResetOtp);
r.post("/reset-password", resetPassword);

// Google OAuth
r.get("/google", googleAuth);
r.get("/google/callback", googleCallback);
r.get("/oauth-profile", oauthProfile);

export default r;

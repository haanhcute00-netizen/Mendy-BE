import { Router } from "express";
import { register, login ,refresh , googleAuth , googleCallback , oauthProfile } from "../controllers/auth.controller.js";
const r = Router();
r.post("/register", register);

r.post("/login", login);

r.post("/refresh", refresh);

r.get("/google", googleAuth);

r.get("/google/callback", googleCallback);

r.get("/oauth-profile", oauthProfile);

export default r;

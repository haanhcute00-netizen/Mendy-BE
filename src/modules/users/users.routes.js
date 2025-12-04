import { Router } from "express";
import rateLimit from "express-rate-limit";
import { auth } from "../../middlewares/auth.js";
import {
    getProfile,
    updateMyProfile,
    searchUsers,
    getFollowers,
    getFollowing,
    blockUser,
    unblockUser,
    getBlockedUsers
} from "./users.controller.js";

const r = Router();
const limiter = rateLimit({ windowMs: 60_000, max: 30 });

r.use(auth);

// Search users
r.get("/search", searchUsers); // ?q=...&limit=20&offset=0

// Blocked users
r.get("/blocked", getBlockedUsers);
r.post("/block", limiter, blockUser); // body: user_id
r.post("/unblock", limiter, unblockUser); // body: user_id

// User profile by ID
r.get("/:id", getProfile);
r.get("/:id/followers", getFollowers);
r.get("/:id/following", getFollowing);

export default r;

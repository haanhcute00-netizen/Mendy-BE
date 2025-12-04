import { Router } from "express";
import { auth } from "../../middlewares/auth.js";
import upload from "../../config/multer.js"; // Memory storage for Cloudinary
import { completeProfile, getMyProfile, updateExpertProfile } from "./profile.controller.js";

const r = Router();

r.get("/me", auth, getMyProfile);

// Setup profile với upload avatar/attachment qua Cloudinary
r.post(
    "/setup",
    auth,
    upload.fields([
        { name: "avatar", maxCount: 1 },
        { name: "attachment", maxCount: 1 }
    ]),
    completeProfile
);

r.put("/expert", auth, updateExpertProfile);

export default r;

import { Router } from "express";
import rateLimit from "express-rate-limit";
import { auth } from "../../middlewares/auth.js";
import upload from "../../config/multer.js";
import {
  create, update, remove, detail, timeline, feed,
  react, unreact, save, unsave
} from "../posts/posts.controller.js";

const r = Router();
const limiter = rateLimit({ windowMs: 60_000, max: 20 });

r.use(auth);

r.get("/feed", feed);
r.get("/timeline", timeline); // ?user_id=...

// Hỗ trợ upload tối đa 10 ảnh + 1 video
r.post("/", limiter, upload.array("media", 11), create);  // body: content, privacy, file_ids[], media[]
r.patch("/:id", limiter, update);
r.delete("/:id", limiter, remove);
r.get("/:id", detail);

r.post("/:id/react", limiter, react);      // body: kind
r.delete("/:id/react", unreact);

r.post("/:id/save", limiter, save);
r.delete("/:id/save", unsave);

export default r;

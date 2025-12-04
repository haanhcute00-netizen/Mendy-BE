import { Router } from "express";
import rateLimit from "express-rate-limit";
import { auth } from "../../middlewares/auth.js";
import {
    add,
    update,
    remove,
    list,
    detail,
    react,
    unreact
} from "../comments/comments.controller.js";

const r = Router();
const limiter = rateLimit({ windowMs: 60_000, max: 40 });

r.use(auth);

// List comments of a post
r.get("/", list); // ?post_id=...&before=...&limit=...

// CRUD
r.post("/", limiter, add); // body: post_id, parent_id?, content, anonymous?
r.get("/:id", detail);
r.patch("/:id", limiter, update); // body: content
r.delete("/:id", limiter, remove);

// Reactions
r.post("/:id/react", limiter, react); // body: kind (LIKE, LOVE, etc.)
r.delete("/:id/react", unreact);

export default r;

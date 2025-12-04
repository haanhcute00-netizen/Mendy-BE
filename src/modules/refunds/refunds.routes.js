// src/modules/refunds/refunds.routes.js
import { Router } from "express";
import { auth, requireRole } from "../../middlewares/auth.js";
import * as RefundsController from "./refunds.controller.js";

const r = Router();

// User routes
r.use(auth);
r.get("/calculate/:booking_id", RefundsController.calculateRefund);
r.post("/request", RefundsController.requestRefund);
r.get("/mine", RefundsController.listMyRefunds);

// Admin routes
r.get("/admin/list", requireRole("ADMIN"), RefundsController.listAllRefunds);
r.post("/admin/:id/process", requireRole("ADMIN"), RefundsController.processRefund);

export default r;

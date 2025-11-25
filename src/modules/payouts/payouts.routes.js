// src/routes/payouts.routes.js
import { Router } from "express";
import * as PayoutsController from "./payouts.controller.js";
import { auth, requireRole } from "../../middlewares/auth.js";

const router = Router();

// Expert routes
router.post("/request", auth, requireRole("EXPERT"), PayoutsController.requestPayout);
router.get("/history", auth, requireRole("EXPERT"), PayoutsController.listMine);

// Admin routes
router.get("/admin/list", auth, requireRole("ADMIN"), PayoutsController.adminList);
router.post("/admin/:id/approve", auth, requireRole("ADMIN"), PayoutsController.adminApprove);
router.post("/admin/:id/reject", auth, requireRole("ADMIN"), PayoutsController.adminReject);

export default router;

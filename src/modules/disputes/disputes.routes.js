// src/modules/disputes/disputes.routes.js
import { Router } from "express";
import { auth, requireRole } from "../../middlewares/auth.js";
import * as DisputesController from "./disputes.controller.js";

const r = Router();

// User routes
r.use(auth);
r.post("/raise", DisputesController.raiseDispute);
r.get("/mine", DisputesController.listMyDisputes);
r.get("/:id", DisputesController.getDispute);
r.post("/:id/message", DisputesController.addMessage);

// Admin routes
r.get("/admin/list", requireRole("ADMIN"), DisputesController.listAllDisputes);
r.post("/admin/:id/assign", requireRole("ADMIN"), DisputesController.assignDispute);
r.post("/admin/:id/resolve", requireRole("ADMIN"), DisputesController.resolveDispute);
r.post("/admin/:id/escalate", requireRole("ADMIN"), DisputesController.escalateDispute);

export default r;

// src/modules/recurring/recurring.routes.js
import { Router } from "express";
import { auth, requireRole } from "../../middlewares/auth.js";
import * as RecurringController from "./recurring.controller.js";

const r = Router();

r.use(auth);

// User routes
r.post("/", RecurringController.createTemplate);
r.get("/mine", RecurringController.listMyTemplates);
r.get("/:id", RecurringController.getTemplate);
r.patch("/:id", RecurringController.updateTemplate);
r.delete("/:id", RecurringController.cancelTemplate);

// Admin route to manually trigger recurring booking processing
r.post("/admin/process", requireRole("ADMIN"), RecurringController.processRecurringBookings);

export default r;

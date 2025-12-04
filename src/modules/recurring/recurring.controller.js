// src/modules/recurring/recurring.controller.js
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, failure, notFound, forbidden } from "../../utils/response.js";
import * as RecurringService from "./recurring.service.js";

// Create recurring booking template
export const createTemplate = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const {
        expert_id, channel, start_time, duration_minutes, frequency,
        day_of_week, day_of_month, total_sessions, starts_from, ends_at
    } = req.body;

    if (!expert_id) return failure(res, "recurring.errors.expertIdRequired");
    if (!start_time) return failure(res, "recurring.errors.startTimeRequired");
    if (!duration_minutes) return failure(res, "recurring.errors.durationRequired");
    if (!frequency) return failure(res, "recurring.errors.frequencyRequired");
    if (!starts_from) return failure(res, "recurring.errors.startsFromRequired");

    const template = await RecurringService.createRecurringTemplate({
        userId: Number(userId),
        expertId: Number(expert_id),
        channel,
        startTime: start_time,
        durationMinutes: Number(duration_minutes),
        frequency,
        dayOfWeek: day_of_week !== undefined ? Number(day_of_week) : undefined,
        dayOfMonth: day_of_month !== undefined ? Number(day_of_month) : undefined,
        totalSessions: total_sessions ? Number(total_sessions) : null,
        startsFrom: starts_from,
        endsAt: ends_at
    });

    return created(res, "recurring.create.success", { template });
});

// Get template details
export const getTemplate = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    const result = await RecurringService.getTemplate(Number(id), Number(userId));
    return success(res, "recurring.get.success", result);
});

// Update template
export const updateTemplate = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const updates = req.body;

    const template = await RecurringService.updateTemplate(Number(id), Number(userId), updates);
    return success(res, "recurring.update.success", { template });
});

// Cancel template
export const cancelTemplate = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;

    const template = await RecurringService.cancelTemplate(Number(id), Number(userId));
    return success(res, "recurring.cancel.success", { template });
});

// List my templates
export const listMyTemplates = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { as_expert = 'false', limit = 20, offset = 0 } = req.query;

    const templates = await RecurringService.listMyTemplates(Number(userId), {
        asExpert: as_expert === 'true',
        limit: Math.min(50, Number(limit)),
        offset: Number(offset)
    });

    return success(res, "recurring.list.success", { templates });
});

// Admin: Process recurring bookings
export const processRecurringBookings = asyncHandler(async (req, res) => {
    const results = await RecurringService.processRecurringBookings();
    return success(res, "recurring.admin.process.success", results);
});

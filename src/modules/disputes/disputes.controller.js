// src/modules/disputes/disputes.controller.js
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, failure, notFound, forbidden } from "../../utils/response.js";
import * as DisputesService from "./disputes.service.js";

// Raise a dispute
export const raiseDispute = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { booking_id, reason, description, evidence_urls = [] } = req.body;

    if (!booking_id) return failure(res, "disputes.errors.bookingIdRequired");
    if (!reason) return failure(res, "disputes.errors.reasonRequired");
    if (!description) return failure(res, "disputes.errors.descriptionRequired");

    const dispute = await DisputesService.raiseDispute({
        userId: Number(userId),
        bookingId: Number(booking_id),
        reason,
        description,
        evidenceUrls: evidence_urls
    });

    return created(res, "disputes.raise.success", { dispute });
});

// Get dispute details
export const getDispute = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const isAdmin = req.user.role === 'ADMIN';

    const result = await DisputesService.getDispute(Number(id), Number(userId), isAdmin);
    return success(res, "disputes.get.success", result);
});

// Add message to dispute
export const addMessage = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const { message, attachments = [] } = req.body;
    const isAdmin = req.user.role === 'ADMIN';

    if (!message || message.trim().length === 0) {
        return failure(res, "disputes.errors.messageRequired");
    }

    const msg = await DisputesService.addMessage({
        disputeId: Number(id),
        userId: Number(userId),
        message,
        attachments,
        isAdmin
    });

    return created(res, "disputes.message.success", { message: msg });
});

// List my disputes
export const listMyDisputes = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { limit = 20, offset = 0 } = req.query;

    const disputes = await DisputesService.listMyDisputes(Number(userId), {
        limit: Math.min(50, Number(limit)),
        offset: Number(offset)
    });

    return success(res, "disputes.list.success", { disputes });
});

// Admin: List all disputes
export const listAllDisputes = asyncHandler(async (req, res) => {
    const { status, limit = 50, offset = 0 } = req.query;

    const disputes = await DisputesService.listAllDisputes({
        status,
        limit: Math.min(100, Number(limit)),
        offset: Number(offset)
    });

    return success(res, "disputes.admin.list.success", { disputes });
});

// Admin: Assign dispute to self
export const assignDispute = asyncHandler(async (req, res) => {
    const adminId = req.user.id;
    const { id } = req.params;

    const dispute = await DisputesService.assignToAdmin(Number(id), Number(adminId));
    return success(res, "disputes.admin.assign.success", { dispute });
});

// Admin: Resolve dispute
export const resolveDispute = asyncHandler(async (req, res) => {
    const adminId = req.user.id;
    const { id } = req.params;
    const { resolution, refund_percent = 0, favored_party } = req.body;

    if (!resolution) return failure(res, "disputes.errors.resolutionRequired");
    if (!['SEEKER', 'EXPERT', 'PARTIAL'].includes(favored_party)) {
        return failure(res, "disputes.errors.invalidFavoredParty");
    }

    const dispute = await DisputesService.resolveDispute({
        disputeId: Number(id),
        adminId: Number(adminId),
        resolution,
        refundPercent: Number(refund_percent),
        favoredParty: favored_party
    });

    return success(res, "disputes.admin.resolve.success", { dispute });
});

// Admin: Escalate dispute
export const escalateDispute = asyncHandler(async (req, res) => {
    const adminId = req.user.id;
    const { id } = req.params;

    const dispute = await DisputesService.escalateDispute(Number(id), Number(adminId));
    return success(res, "disputes.admin.escalate.success", { dispute });
});

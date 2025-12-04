// src/modules/refunds/refunds.controller.js
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, failure, notFound, forbidden } from "../../utils/response.js";
import * as RefundsService from "./refunds.service.js";

// Calculate refund amount (preview)
export const calculateRefund = asyncHandler(async (req, res) => {
    const { booking_id } = req.params;
    const result = await RefundsService.calculateRefundAmount(Number(booking_id));
    return success(res, "refunds.calculate.success", {
        booking_id: result.booking.id,
        paid_amount: result.paidAmount,
        refund_amount: result.refundAmount,
        refund_type: result.refundType,
        hours_until_booking: result.hoursUntilBooking,
        policy: {
            full_refund_hours: result.refundPolicyHours,
            partial_refund_percent: result.partialRefundPercent
        }
    });
});

// Request refund
export const requestRefund = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { booking_id, reason } = req.body;

    if (!booking_id) {
        return failure(res, "refunds.errors.bookingIdRequired");
    }
    if (!reason || reason.trim().length < 10) {
        return failure(res, "refunds.errors.reasonRequired");
    }

    const result = await RefundsService.requestRefund({
        userId: Number(userId),
        bookingId: Number(booking_id),
        reason: reason.trim()
    });

    return created(res, "refunds.request.success", result);
});

// List my refunds
export const listMyRefunds = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { limit = 20, offset = 0 } = req.query;

    const refunds = await RefundsService.listMyRefunds(Number(userId), {
        limit: Math.min(50, Number(limit)),
        offset: Number(offset)
    });

    return success(res, "refunds.list.success", { refunds });
});

// Admin: List all refunds
export const listAllRefunds = asyncHandler(async (req, res) => {
    const { status, limit = 50, offset = 0 } = req.query;

    const refunds = await RefundsService.listAllRefunds({
        status,
        limit: Math.min(100, Number(limit)),
        offset: Number(offset)
    });

    return success(res, "refunds.admin.list.success", { refunds });
});

// Admin: Process refund
export const processRefund = asyncHandler(async (req, res) => {
    const adminId = req.user.id;
    const { id } = req.params;
    const { action, admin_note } = req.body;

    if (!['APPROVE', 'REJECT'].includes(action)) {
        return failure(res, "refunds.errors.invalidAction");
    }

    const result = await RefundsService.processRefund({
        refundId: Number(id),
        adminId: Number(adminId),
        action,
        adminNote: admin_note
    });

    return success(res, `refunds.admin.${action.toLowerCase()}.success`, { refund: result });
});

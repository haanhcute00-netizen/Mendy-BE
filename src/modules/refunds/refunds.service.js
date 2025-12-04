// src/modules/refunds/refunds.service.js
import * as RefundsRepo from "./refunds.repo.js";
import * as BookingsRepo from "../bookings/bookings.repo.js";
import * as PaymentsRepo from "../payments/payments.repo.js";
import * as WalletsRepo from "../wallets/wallets.repo.js";
import * as PlatformRepo from "../platform/platform.repo.js";
import { getClient } from "../../config/db.js";

// Calculate refund amount based on cancellation time
export async function calculateRefundAmount(bookingId) {
    const booking = await BookingsRepo.getBookingById(bookingId);
    if (!booking) throw Object.assign(new Error("Booking not found"), { status: 404 });

    const paymentIntent = await PaymentsRepo.getIntentByBookingId(bookingId);
    if (!paymentIntent || paymentIntent.status !== 'PAID') {
        throw Object.assign(new Error("No paid payment found for this booking"), { status: 400 });
    }

    const settings = await PlatformRepo.getSettings();
    const refundPolicyHours = parseInt(settings.refund_policy_hours || 24);
    const partialRefundPercent = parseInt(settings.partial_refund_percent || 50);

    const now = new Date();
    const bookingStart = new Date(booking.start_at);
    const hoursUntilBooking = (bookingStart - now) / (1000 * 60 * 60);

    const paidAmount = Number(paymentIntent.amount);
    let refundAmount = 0;
    let refundType = 'NONE';

    if (hoursUntilBooking >= refundPolicyHours) {
        // Full refund
        refundAmount = paidAmount;
        refundType = 'FULL';
    } else if (hoursUntilBooking > 0) {
        // Partial refund
        refundAmount = Math.round(paidAmount * partialRefundPercent / 100);
        refundType = 'PARTIAL';
    } else {
        // No refund - booking already started
        refundAmount = 0;
        refundType = 'NONE';
    }

    return {
        booking,
        paymentIntent,
        paidAmount,
        refundAmount,
        refundType,
        hoursUntilBooking: Math.max(0, hoursUntilBooking),
        refundPolicyHours,
        partialRefundPercent
    };
}

// Request refund (user initiated)
export async function requestRefund({ userId, bookingId, reason }) {
    // Check if booking belongs to user
    const booking = await BookingsRepo.getBookingById(bookingId);
    if (!booking) throw Object.assign(new Error("Booking not found"), { status: 404 });
    if (Number(booking.user_id) !== Number(userId)) {
        throw Object.assign(new Error("You can only request refund for your own bookings"), { status: 403 });
    }

    // Check booking status
    if (!['CONFIRMED', 'PENDING'].includes(booking.status)) {
        throw Object.assign(new Error("Cannot refund a booking that is already cancelled or completed"), { status: 400 });
    }

    // Check if refund already exists
    const existingRefund = await RefundsRepo.getRefundByBookingId(bookingId);
    if (existingRefund && ['PENDING', 'PROCESSING', 'APPROVED'].includes(existingRefund.status)) {
        throw Object.assign(new Error("A refund request already exists for this booking"), { status: 400 });
    }

    // Calculate refund amount
    const refundCalc = await calculateRefundAmount(bookingId);

    if (refundCalc.refundAmount <= 0) {
        throw Object.assign(new Error("This booking is not eligible for refund"), { status: 400 });
    }

    const client = await getClient();
    try {
        await client.query('BEGIN');

        // Create refund request
        const refund = await RefundsRepo.createRefund({
            bookingId,
            paymentIntentId: refundCalc.paymentIntent.id,
            userId,
            amount: refundCalc.refundAmount,
            platformFeeRefunded: 0,
            reason
        }, client);

        // Update booking status to CANCELLED
        await BookingsRepo.updateStatus({ id: bookingId, status: 'CANCELLED', byUser: userId });

        await client.query('COMMIT');

        return {
            refund,
            refundType: refundCalc.refundType,
            originalAmount: refundCalc.paidAmount,
            refundAmount: refundCalc.refundAmount
        };
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

// Process refund (admin)
export async function processRefund({ refundId, adminId, action, adminNote }) {
    const refund = await RefundsRepo.getRefundById(refundId);
    if (!refund) throw Object.assign(new Error("Refund not found"), { status: 404 });

    if (refund.status !== 'PENDING' && refund.status !== 'APPROVED') {
        throw Object.assign(new Error("Refund is not in processable state"), { status: 400 });
    }

    const client = await getClient();
    try {
        await client.query('BEGIN');

        if (action === 'APPROVE') {
            // Update status to APPROVED then PROCESSING
            await RefundsRepo.updateRefundStatus({
                id: refundId,
                status: 'PROCESSING',
                adminNote,
                processedBy: adminId
            }, client);

            // Process the actual refund (credit back to user wallet)
            await WalletsRepo.creditWallet({
                userId: refund.user_id,
                amount: Number(refund.amount),
                refType: 'REFUND',
                refId: refundId,
                description: `Refund for booking #${refund.booking_id}`
            }, client);

            // Mark as completed
            const updated = await RefundsRepo.updateRefundStatus({
                id: refundId,
                status: 'COMPLETED',
                adminNote,
                processedBy: adminId
            }, client);

            await client.query('COMMIT');
            return updated;

        } else if (action === 'REJECT') {
            const updated = await RefundsRepo.updateRefundStatus({
                id: refundId,
                status: 'REJECTED',
                adminNote,
                processedBy: adminId
            }, client);

            await client.query('COMMIT');
            return updated;
        } else {
            throw Object.assign(new Error("Invalid action"), { status: 400 });
        }
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

// List user's refunds
export async function listMyRefunds(userId, options = {}) {
    return RefundsRepo.listUserRefunds(userId, options);
}

// List all refunds (admin)
export async function listAllRefunds(options = {}) {
    return RefundsRepo.listAllRefunds(options);
}

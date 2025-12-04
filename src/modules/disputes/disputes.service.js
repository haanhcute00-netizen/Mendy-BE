// src/modules/disputes/disputes.service.js
import * as DisputesRepo from "./disputes.repo.js";
import * as BookingsRepo from "../bookings/bookings.repo.js";
import * as WalletsRepo from "../wallets/wallets.repo.js";
import * as RefundsRepo from "../refunds/refunds.repo.js";
import * as PaymentsRepo from "../payments/payments.repo.js";
import { getClient } from "../../config/db.js";

const VALID_REASONS = [
    'NO_SHOW_EXPERT',
    'NO_SHOW_SEEKER',
    'POOR_QUALITY',
    'TECHNICAL_ISSUES',
    'INAPPROPRIATE_BEHAVIOR',
    'WRONG_EXPERTISE',
    'TIME_DISPUTE',
    'OTHER'
];

// Raise a dispute
export async function raiseDispute({ userId, bookingId, reason, description, evidenceUrls = [] }) {
    // Validate reason
    if (!VALID_REASONS.includes(reason)) {
        throw Object.assign(new Error(`Invalid reason. Must be one of: ${VALID_REASONS.join(', ')}`), { status: 400 });
    }

    if (!description || description.trim().length < 20) {
        throw Object.assign(new Error("Description must be at least 20 characters"), { status: 400 });
    }

    // Get booking
    const booking = await BookingsRepo.getBookingById(bookingId);
    if (!booking) throw Object.assign(new Error("Booking not found"), { status: 404 });

    // Check if user is part of booking
    const isSeeker = Number(booking.user_id) === Number(userId);
    const isExpert = Number(booking.expert_id) === Number(userId);

    if (!isSeeker && !isExpert) {
        throw Object.assign(new Error("You can only raise disputes for your own bookings"), { status: 403 });
    }

    // Check booking status - can only dispute CONFIRMED or COMPLETED bookings
    if (!['CONFIRMED', 'COMPLETED'].includes(booking.status)) {
        throw Object.assign(new Error("Can only raise disputes for confirmed or completed bookings"), { status: 400 });
    }

    // Check if dispute already exists
    const existingDispute = await DisputesRepo.getDisputeByBookingId(bookingId);
    if (existingDispute && !['CLOSED', 'RESOLVED_SEEKER', 'RESOLVED_EXPERT', 'RESOLVED_PARTIAL'].includes(existingDispute.status)) {
        throw Object.assign(new Error("An active dispute already exists for this booking"), { status: 400 });
    }

    // Determine against_user
    const againstUser = isSeeker ? booking.expert_id : booking.user_id;

    // Create dispute
    const dispute = await DisputesRepo.createDispute({
        bookingId,
        raisedBy: userId,
        againstUser,
        reason,
        description: description.trim(),
        evidenceUrls
    });

    return dispute;
}

// Get dispute details
export async function getDispute(disputeId, userId, isAdmin = false) {
    const dispute = await DisputesRepo.getDisputeById(disputeId);
    if (!dispute) throw Object.assign(new Error("Dispute not found"), { status: 404 });

    // Check access
    if (!isAdmin && Number(dispute.raised_by) !== Number(userId) && Number(dispute.against_user) !== Number(userId)) {
        throw Object.assign(new Error("Access denied"), { status: 403 });
    }

    // Get messages
    const messages = await DisputesRepo.getMessages(disputeId);

    return { dispute, messages };
}

// Add message to dispute
export async function addMessage({ disputeId, userId, message, attachments = [], isAdmin = false }) {
    const dispute = await DisputesRepo.getDisputeById(disputeId);
    if (!dispute) throw Object.assign(new Error("Dispute not found"), { status: 404 });

    // Check if dispute is still open
    if (['CLOSED', 'RESOLVED_SEEKER', 'RESOLVED_EXPERT', 'RESOLVED_PARTIAL'].includes(dispute.status)) {
        throw Object.assign(new Error("Cannot add messages to resolved disputes"), { status: 400 });
    }

    // Check access
    if (!isAdmin && Number(dispute.raised_by) !== Number(userId) && Number(dispute.against_user) !== Number(userId)) {
        throw Object.assign(new Error("Access denied"), { status: 403 });
    }

    return DisputesRepo.addMessage({
        disputeId,
        senderId: userId,
        message: message.trim(),
        attachments,
        isAdmin
    });
}

// Admin: Assign dispute to self
export async function assignToAdmin(disputeId, adminId) {
    const dispute = await DisputesRepo.getDisputeById(disputeId);
    if (!dispute) throw Object.assign(new Error("Dispute not found"), { status: 404 });

    return DisputesRepo.assignAdmin(disputeId, adminId);
}

// Admin: Resolve dispute
export async function resolveDispute({ disputeId, adminId, resolution, refundPercent = 0, favoredParty }) {
    const dispute = await DisputesRepo.getDisputeById(disputeId);
    if (!dispute) throw Object.assign(new Error("Dispute not found"), { status: 404 });

    if (['CLOSED', 'RESOLVED_SEEKER', 'RESOLVED_EXPERT', 'RESOLVED_PARTIAL'].includes(dispute.status)) {
        throw Object.assign(new Error("Dispute is already resolved"), { status: 400 });
    }

    const client = await getClient();
    try {
        await client.query('BEGIN');

        let status;
        let refundAmount = 0;

        // Determine resolution status and refund
        if (favoredParty === 'SEEKER') {
            status = 'RESOLVED_SEEKER';
            // Full or partial refund to seeker
            if (refundPercent > 0) {
                const paymentIntent = await PaymentsRepo.getIntentByBookingId(dispute.booking_id);
                if (paymentIntent && paymentIntent.status === 'PAID') {
                    refundAmount = Math.round(Number(paymentIntent.amount) * refundPercent / 100);

                    // Create refund
                    await RefundsRepo.createRefund({
                        bookingId: dispute.booking_id,
                        paymentIntentId: paymentIntent.id,
                        userId: dispute.raised_by === dispute.booking_user_id ? dispute.raised_by : dispute.against_user,
                        amount: refundAmount,
                        reason: `Dispute resolution: ${resolution}`
                    }, client);

                    // Credit to seeker wallet
                    const seekerId = dispute.raised_by === dispute.booking_user_id ? dispute.raised_by : dispute.against_user;
                    await WalletsRepo.creditWallet({
                        userId: seekerId,
                        amount: refundAmount,
                        refType: 'REFUND',
                        refId: disputeId,
                        description: `Dispute resolution refund for booking #${dispute.booking_id}`
                    }, client);
                }
            }
        } else if (favoredParty === 'EXPERT') {
            status = 'RESOLVED_EXPERT';
            // No refund, expert keeps the payment
        } else {
            status = 'RESOLVED_PARTIAL';
            // Partial resolution
            if (refundPercent > 0 && refundPercent < 100) {
                const paymentIntent = await PaymentsRepo.getIntentByBookingId(dispute.booking_id);
                if (paymentIntent && paymentIntent.status === 'PAID') {
                    refundAmount = Math.round(Number(paymentIntent.amount) * refundPercent / 100);

                    await RefundsRepo.createRefund({
                        bookingId: dispute.booking_id,
                        paymentIntentId: paymentIntent.id,
                        userId: dispute.raised_by,
                        amount: refundAmount,
                        reason: `Partial dispute resolution: ${resolution}`
                    }, client);

                    await WalletsRepo.creditWallet({
                        userId: dispute.raised_by,
                        amount: refundAmount,
                        refType: 'REFUND',
                        refId: disputeId,
                        description: `Partial dispute refund for booking #${dispute.booking_id}`
                    }, client);
                }
            }
        }

        // Update dispute
        const updated = await DisputesRepo.updateDisputeStatus({
            id: disputeId,
            status,
            resolution,
            refundAmount,
            assignedAdmin: adminId,
            resolvedAt: new Date()
        }, client);

        await client.query('COMMIT');
        return updated;

    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

// List user's disputes
export async function listMyDisputes(userId, options = {}) {
    return DisputesRepo.listUserDisputes(userId, options);
}

// Admin: List all disputes
export async function listAllDisputes(options = {}) {
    return DisputesRepo.listAllDisputes(options);
}

// Admin: Escalate dispute
export async function escalateDispute(disputeId, adminId) {
    const dispute = await DisputesRepo.getDisputeById(disputeId);
    if (!dispute) throw Object.assign(new Error("Dispute not found"), { status: 404 });

    return DisputesRepo.updateDisputeStatus({
        id: disputeId,
        status: 'ESCALATED',
        assignedAdmin: adminId
    });
}

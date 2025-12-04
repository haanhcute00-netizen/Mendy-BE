// controllers/bookings.controller.js
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, success, paginated, failure, notFound, forbidden } from "../../utils/response.js";
import * as BookingsService from "../bookings/bookings.service.js";
import { bookWithPayment, cancelBookingWithPayment, getBookingWithPayment } from "../bookings/bookingPayment.service.js";
import { query } from "../../config/db.js";

export const book = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { expert_id, start_at, end_at, channel, payment_method = "MOMO" } = req.body;

    try {
        // Check if payment integration is requested
        if (req.body.initiate_payment !== false) {
            // Use integrated booking and payment flow
            const out = await bookWithPayment({
                me,
                expertId: Number(expert_id),
                startAt: start_at,
                endAt: end_at,
                channel,
                paymentMethod: payment_method
            });
            return created(res, "bookings.create.paymentInitiated", out);
        } else {
            // Use legacy booking flow
            const out = await BookingsService.book({
                me,
                expertId: Number(expert_id),
                startAt: start_at,
                endAt: end_at,
                channel
            });
            return created(res, "bookings.create.success", out);
        }
    } catch (error) {
        // Handle specific booking conflicts
        if (error.code === "TIME_CONFLICT" ||
            (error.message && error.message.includes('conflicting key value violates exclusion constraint "no_overlap_per_expert"'))) {
            return failure(res, "bookings.errors.timeConflict", {
                code: "TIME_CONFLICT",
                suggestion: "bookings.errors.timeConflictSuggestion"
            });
        }
        throw error;
    }
});

export const listMine = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { as } = req.query; // seeker|expert
    console.log(`[DEBUG] listMine controller - User ID: ${me}, Role: ${req.user.role}, Query as: ${as}`);
    const rows = await BookingsService.listMine({ me, as });
    console.log(`[DEBUG] listMine controller - Returning ${rows.length} rows`);
    return success(res, "bookings.list.retrieved", { bookings: rows });
});

export const confirm = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { id } = req.params;
    console.log(`[DEBUG] confirm controller - User ID: ${me}, Role: ${req.user.role}, Booking ID: ${id}`);
    const bk = await BookingsService.confirm({ me, id: Number(id) });
    console.log(`[DEBUG] confirm controller - Result:`, bk);
    return success(res, "bookings.confirm.success", { booking: bk });
});

export const cancel = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { id } = req.params;
    const { reason } = req.body;

    try {
        const result = await cancelBookingWithPayment(Number(id), Number(me), reason);
        return success(res, "bookings.cancel.success", { booking: result });
    } catch (error) {
        if (error.status === 404) {
            return notFound(res, error.message);
        } else if (error.status === 403) {
            return forbidden(res, error.message);
        } else if (error.status === 400) {
            return failure(res, error.message);
        }
        throw error;
    }
});

// Get booking details with payment information
export const getBookingDetails = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { id } = req.params;

    try {
        const result = await getBookingWithPayment(Number(id), Number(me));
        return success(res, "bookings.details.retrieved", result);
    } catch (error) {
        if (error.status === 404) {
            return notFound(res, error.message);
        } else if (error.status === 403) {
            return forbidden(res, error.message);
        }
        throw error;
    }
});

export const complete = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { id } = req.params;

    try {
        const booking = await BookingsService.complete({ me, id: Number(id) });
        return success(res, "bookings.complete.success", { booking });
    } catch (error) {
        if (error.status === 404) {
            return notFound(res, error.message);
        } else if (error.status === 403) {
            return forbidden(res, error.message);
        } else if (error.status === 400) {
            return failure(res, error.message);
        }
        throw error;
    }
});

// Admin endpoint to auto-complete expired bookings
export const autoCompleteBookings = asyncHandler(async (req, res) => {
    if (req.user.role !== 'ADMIN') {
        return forbidden(res, "bookings.admin.accessRequired");
    }

    const completedBookings = await BookingsService.autoCompleteExpiredBookings();
    return success(res, "bookings.admin.autoComplete", {
        count: completedBookings.length,
        bookings: completedBookings
    });
});

// Debug endpoint to check all bookings in database
export const debugAllBookings = asyncHandler(async (req, res) => {
    const { rows } = await query(`SELECT id, user_id, expert_id, status, start_at, end_at FROM app.bookings ORDER BY id LIMIT 20`);
    return success(res, "Debug: All bookings retrieved", { bookings: rows });
});

// src/services/bookingPayment.service.js
import * as Bookings from "../bookings/bookings.repo.js";
import * as Payments from "../payments/payments.repo.js";
import * as WalletsRepo from "../wallets/wallets.repo.js";
import * as PlatformRepo from "../platform/platform.repo.js";
import { getClient } from "../../config/db.js";
import { EventEmitter } from "events";

// Utility functions for price calculation and time validation
function calculateBookingPrice(expertPricePerSession, startTime, endTime) {
  const durationInMs = endTime - startTime;
  const durationInMinutes = durationInMs / (1000 * 60);

  // Round to nearest 15 minutes
  const roundedHours = Math.ceil(durationInMinutes / 15) / 4;

  return Math.round(expertPricePerSession * roundedHours);
}

function validateBookingTime(startTime, endTime) {
  const now = new Date();
  const minStartTime = new Date(now.getTime() + 15 * 60 * 1000); // 15 mins from now
  const minDuration = 1 * 60 * 60 * 1000; // 1 hour
  const maxDuration = 3 * 60 * 60 * 1000; // 3 hours

  if (startTime < minStartTime) {
    throw Object.assign(new Error("Booking must be at least 15 minutes from now"), { status: 400, code: "INVALID_TIME" });
  }

  if (endTime <= startTime) {
    throw Object.assign(new Error("End time must be after start time"), { status: 400, code: "INVALID_TIME" });
  }

  const duration = endTime - startTime;
  if (duration < minDuration) {
    throw Object.assign(new Error("Booking duration must be at least 1 hour"), { status: 400, code: "INVALID_DURATION" });
  }

  if (duration > maxDuration) {
    throw Object.assign(new Error("Booking duration cannot exceed 3 hours"), { status: 400, code: "INVALID_DURATION" });
  }

  return true;
}

async function checkExpertAvailability(expertId, startTime, endTime) {
  // Check against expert_availabilities table
  const isAvailable = await Bookings.isWithinAvailability(expertId, startTime, endTime);

  if (!isAvailable) {
    throw Object.assign(new Error("Expert is not available during this time slot"), { status: 409, code: "EXPERT_UNAVAILABLE" });
  }

  // Check for existing bookings (database constraint handles this)
  const hasConflict = await Bookings.hasOverlap(expertId, startTime, endTime);

  if (hasConflict) {
    throw Object.assign(new Error("Expert already has a booking during this time"), { status: 409, code: "TIME_CONFLICT" });
  }

  return true;
}

// Booking State Machine
export class BookingStateMachine {
  static transitions = {
    'PENDING': ['CONFIRMED', 'CANCELLED'],
    'CONFIRMED': ['COMPLETED', 'CANCELLED'],
    'CANCELLED': [], // Terminal state
    'COMPLETED': [], // Terminal state
  };

  static canTransition(from, to) {
    return this.transitions[from]?.includes(to) || false;
  }

  static async transition(bookingId, to, metadata = {}) {
    const booking = await Bookings.getBookingById(bookingId);

    if (!this.canTransition(booking.status, to)) {
      throw new Error(`Invalid transition from ${booking.status} to ${to}`);
    }

    // Update booking status
    return await Bookings.updateStatus({ id: bookingId, status: to });
  }

  // New method to complete a booking
  static async completeBooking(bookingId, userId) {
    const booking = await Bookings.getBookingById(bookingId);

    if (!booking) {
      throw Object.assign(new Error("Booking not found"), { status: 404 });
    }

    // Check if user has access to this booking
    if (![Number(booking.user_id), Number(booking.expert_id)].includes(Number(userId))) {
      throw Object.assign(new Error("Access denied"), { status: 403 });
    }

    // Check if booking can be completed
    if (booking.status !== "CONFIRMED") {
      throw Object.assign(new Error("Only confirmed bookings can be completed"), { status: 400 });
    }

    // Transition to COMPLETED
    const result = await this.transition(bookingId, 'COMPLETED');

    // Credit expert wallet with platform fee deduction
    const client = await getClient();
    try {
      await client.query('BEGIN');

      const price = Number(booking.price);
      if (price > 0) {
        // Calculate platform fee
        const feeBreakdown = await PlatformRepo.calculateFees(price);

        // Store fee breakdown
        await PlatformRepo.createBookingFee({
          bookingId,
          grossAmount: feeBreakdown.grossAmount,
          platformFee: feeBreakdown.platformFee,
          platformFeePercent: feeBreakdown.platformFeePercent,
          expertEarning: feeBreakdown.expertEarning
        }, client);

        // Credit expert with net amount (after platform fee)
        await WalletsRepo.creditWallet({
          userId: booking.expert_id,
          amount: feeBreakdown.expertEarning,
          refType: 'BOOKING',
          refId: bookingId,
          description: `Payment for booking #${bookingId} (after ${feeBreakdown.platformFeePercent}% platform fee)`
        }, client);

        console.log(`Booking ${bookingId} completed: Gross=${price}, PlatformFee=${feeBreakdown.platformFee}, ExpertEarning=${feeBreakdown.expertEarning}`);
      }

      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      console.error(`Failed to credit wallet for booking ${bookingId}:`, err);
    } finally {
      client.release();
    }

    return result;
  }
}

// Event Eitter for booking events
export class BookingEventEmitter extends EventEmitter {
  static _instance = null;

  static getInstance() {
    if (!BookingEventEmitter._instance) {
      BookingEventEmitter._instance = new BookingEventEmitter();
    }
    return BookingEventEmitter._instance;
  }

  async emitBookingCreated(booking) {
    this.emit('booking.created', booking);
    return this;
  }

  async emitPaymentCompleted(payment) {
    this.emit('payment.completed', payment);
    return this;
  }

  async emitPaymentFailed(payment) {
    this.emit('payment.failed', payment);
    return this;
  }
}

// Initialize event listeners
const eventEmitter = BookingEventEmitter.getInstance();

// Event handlers
eventEmitter.on('booking.created', async (booking) => {
  console.log(`Booking created: ${booking.id}, scheduling payment reminder`);
  // Schedule payment reminder if not paid within timeframe
  setTimeout(async () => {
    const updatedBooking = await Bookings.getBookingById(booking.id);
    if (updatedBooking.status === 'PENDING') {
      console.log(`Payment reminder for booking: ${booking.id}`);
      // Here you would send a notification to the user
    }
  }, 30 * 60 * 1000); // 30 minutes
});

eventEmitter.on('payment.completed', async (payment) => {
  console.log(`Payment completed for booking: ${payment.booking_id}`);
  await UnifiedBookingService.handlePaymentSuccess(payment);
});

eventEmitter.on('payment.failed', async (payment) => {
  console.log(`Payment failed for booking: ${payment.booking_id}`);
  await UnifiedBookingService.handlePaymentFailure(payment);
});

// Unified Booking Service
export class UnifiedBookingService {
  static async createAndPay({ userId, expertId, startAt, endAt, channel, paymentMethod }) {
    // Validate input parameters first (before transaction)
    if (!expertId) throw Object.assign(new Error("expert_id is required"), { status: 400, code: "MISSING_EXPERT_ID" });
    if (!startAt || !endAt) throw Object.assign(new Error("start_at and end_at are required"), { status: 400, code: "MISSING_TIME" });

    const ALLOWED_CHANNELS = new Set(["CHAT", "AUDIO", "VIDEO"]);
    channel = String(channel || "CHAT").toUpperCase();
    if (!ALLOWED_CHANNELS.has(channel)) throw Object.assign(new Error("channel must be CHAT/AUDIO/VIDEO"), { status: 400, code: "INVALID_CHANNEL" });
    if (Number(expertId) === Number(userId)) throw Object.assign(new Error("Cannot book yourself"), { status: 400, code: "SELF_BOOKING" });

    // Convert to Date objects
    const startTime = new Date(startAt);
    const endTime = new Date(endAt);
    if (isNaN(startTime.getTime()) || isNaN(endTime.getTime())) throw Object.assign(new Error("Invalid datetime"), { status: 400, code: "INVALID_DATETIME" });

    // Validate booking time
    validateBookingTime(startTime, endTime);

    // Check expert availability
    await checkExpertAvailability(expertId, startTime, endTime);

    // Get price from expert
    const expertPricePerSession = await Bookings.getExpertPrice(expertId);

    // Calculate total price based on duration
    const totalPrice = calculateBookingPrice(expertPricePerSession, startTime, endTime);

    // Use transaction for database operations only
    const client = await getClient();
    let booking;

    try {
      await client.query('BEGIN');

      // Create booking with PENDING status (compatible with database enum)
      booking = await Bookings.createBooking({
        userId,
        expertId,
        startAt: startTime,
        endAt: endTime,
        channel,
        price: totalPrice,
        status: 'PENDING'
      }, client);

      // Create payment intent (but don't call external API yet)
      let paymentIntent;
      if (paymentMethod === 'MOMO') {
        // Create payment intent in database first
        const now = Date.now();
        const orderId = `BK${booking.id}_${now}`;
        const requestId = `REQ_${now}_${userId}`;

        paymentIntent = await Payments.createIntent({
          bookingId: booking.id,
          userId,
          provider: "MOMO",
          amount: totalPrice,
          orderId,
          requestId,
          extra: { requestType: "captureWallet" }
        }, client);
      } else {
        throw Object.assign(new Error(`Payment method ${paymentMethod} not supported`), { status: 400, code: "UNSUPPORTED_PAYMENT_METHOD" });
      }

      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');

      // Handle specific database constraint violation for overlapping bookings
      if (error.message && error.message.includes('conflicting key value violates exclusion constraint "no_overlap_per_expert"')) {
        throw Object.assign(new Error("Expert already has a booking during this time slot"), {
          status: 409,
          code: "TIME_CONFLICT",
          message: "The expert is already booked during this time period. Please select a different time."
        });
      }

      throw error;
    } finally {
      // Release the client back to the pool
      client.release();
    }

    // Now call external API outside of transaction
    let payment;
    if (paymentMethod === 'MOMO') {
      const { createForBooking } = await import('../payments/momo.service.js');
      payment = await createForBooking({ me: userId, bookingId: booking.id });
    }

    // Emit booking created event
    await eventEmitter.emitBookingCreated(booking);

    // Schedule payment expiry check (15 minutes)
    schedulePaymentExpiryCheck(booking.id, 15 * 60 * 1000);

    return {
      booking,
      payment,
      nextAction: 'COMPLETE_PAYMENT'
    };
  }

  static async handlePaymentSuccess(paymentIntent) {
    // Use transaction for atomic updates
    const client = await getClient();

    try {
      await client.query('BEGIN');

      // Update payment status
      await Payments.markIntentSucceeded({
        orderId: paymentIntent.orderId,
        transId: paymentIntent.transId,
        raw: paymentIntent.raw
      });

      // Update booking status using state machine
      await BookingStateMachine.transition(
        paymentIntent.booking_id,
        'CONFIRMED'
      );

      // Create chat thread
      const booking = await Bookings.getBookingById(paymentIntent.booking_id);
      await Bookings.createThreadForBooking({
        bookingId: booking.id,
        seekerId: booking.user_id,
        expertId: booking.expert_id
      });

      await client.query('COMMIT');

      // Cancel payment expiry job
      cancelPaymentExpiryCheck(paymentIntent.booking_id);

      // Schedule booking reminders
      scheduleBookingReminders(booking.id, booking.start_at);

      // Emit payment completed event
      await eventEmitter.emitPaymentCompleted(paymentIntent);

      return { success: true, bookingId: paymentIntent.booking_id };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      // Release the client back to the pool
      client.release();
    }
  }

  static async handlePaymentFailure(paymentIntent) {
    // Update payment status
    await Payments.markIntentFailed({
      orderId: paymentIntent.orderId,
      raw: paymentIntent.raw
    });

    // Update booking status to CANCELLED directly since PAYMENT_FAILED is not a valid status
    await BookingStateMachine.transition(
      paymentIntent.booking_id,
      'CANCELLED'
    );

    // Emit payment failed event
    await eventEmitter.emitPaymentFailed(paymentIntent);

    return { success: false, reason: 'Payment failed' };
  }
}

// Background job scheduler for payment expiry
const paymentExpiryJobs = new Map(); // Map<bookingId, timeoutId>

function schedulePaymentExpiryCheck(bookingId, delayMs) {
  // Clear existing job if any
  if (paymentExpiryJobs.has(bookingId)) {
    clearTimeout(paymentExpiryJobs.get(bookingId));
  }

  // Schedule new job
  const timeoutId = setTimeout(async () => {
    try {
      const booking = await Bookings.getBookingById(bookingId);
      if (booking && booking.status === 'PENDING') {
        // Update booking status to CANCELLED
        await BookingStateMachine.transition(bookingId, 'CANCELLED');

        // Update payment intent status to FAILED (instead of EXPIRED which is invalid)
        await Payments.updatePaymentStatusByBookingId(bookingId, 'FAILED');

        console.log(`Booking ${bookingId} cancelled due to payment expiry`);

        // Emit payment failed event
        await eventEmitter.emitPaymentFailed({
          booking_id: bookingId,
          reason: 'Payment expired'
        });
      }
    } catch (error) {
      console.error(`Error in payment expiry check for booking ${bookingId}:`, error);
    } finally {
      // Clean up job from map
      paymentExpiryJobs.delete(bookingId);
    }
  }, delayMs);

  // Store job reference
  paymentExpiryJobs.set(bookingId, timeoutId);
}

// Cancel payment expiry job (e.g., when payment is completed)
function cancelPaymentExpiryCheck(bookingId) {
  if (paymentExpiryJobs.has(bookingId)) {
    clearTimeout(paymentExpiryJobs.get(bookingId));
    paymentExpiryJobs.delete(bookingId);
    return true;
  }
  return false;
}

// Background job for checking expired bookings
export async function checkPaymentExpiry() {
  const expiredBookings = await Bookings.getExpiredPendingBookings();

  for (const booking of expiredBookings) {
    const client = await getClient();

    try {
      await client.query('BEGIN');

      // Update booking status
      await BookingStateMachine.transition(booking.id, 'CANCELLED');

      // Update payment intent status to FAILED
      await Payments.updatePaymentStatusByBookingId(booking.id, 'FAILED');

      await client.query('COMMIT');

      // Cancel scheduled job if exists
      cancelPaymentExpiryCheck(booking.id);

      // Send notification to user
      // Here you would send a notification to the user
      console.log(`Booking ${booking.id} cancelled due to payment expiry`);

      // Emit payment failed event
      await eventEmitter.emitPaymentFailed({
        booking_id: booking.id,
        reason: 'Payment expired'
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error(`Failed to process expired booking ${booking.id}:`, error);
    } finally {
      // Release the client back to the pool
      client.release();
    }
  }
}

// Background job for sending booking reminders
export async function sendBookingReminders() {
  // Send reminders for bookings in next 24 hours
  const upcomingBookings = await Bookings.getUpcomingBookings(24 * 60 * 60 * 1000);

  for (const booking of upcomingBookings) {
    // Send reminder to seeker
    // Here you would send a notification to the user
    console.log(`Sending 24h reminder for booking ${booking.id} to seeker ${booking.user_id}`);

    // Send reminder to expert
    // Here you would send a notification to the expert
    console.log(`Sending 24h reminder for booking ${booking.id} to expert ${booking.expert_id}`);
  }

  // Send reminders for bookings in next 2 hours
  const soonBookings = await Bookings.getUpcomingBookings(2 * 60 * 60 * 1000);

  for (const booking of soonBookings) {
    // Send reminder to seeker
    // Here you would send a notification to the user
    console.log(`Sending 2h reminder for booking ${booking.id} to seeker ${booking.user_id}`);

    // Send reminder to expert
    // Here you would send a notification to the expert
    console.log(`Sending 2h reminder for booking ${booking.id} to expert ${booking.expert_id}`);
  }
}

// Schedule booking reminders
function scheduleBookingReminders(bookingId, startTime) {
  const now = new Date();
  const bookingTime = new Date(startTime);

  // Calculate time differences
  const timeUntil24h = bookingTime.getTime() - now.getTime() - (24 * 60 * 60 * 1000);
  const timeUntil2h = bookingTime.getTime() - now.getTime() - (2 * 60 * 60 * 1000);

  // Schedule 24h reminder if in the future
  if (timeUntil24h > 0) {
    setTimeout(async () => {
      const booking = await Bookings.getBookingById(bookingId);
      if (booking && booking.status === 'CONFIRMED') {
        console.log(`Sending 24h reminder for booking ${bookingId}`);
        // Here you would send a notification to the user
      }
    }, timeUntil24h);
  }

  // Schedule 2h reminder if in the future
  if (timeUntil2h > 0) {
    setTimeout(async () => {
      const booking = await Bookings.getBookingById(bookingId);
      if (booking && booking.status === 'CONFIRMED') {
        console.log(`Sending 2h reminder for booking ${bookingId}`);
        // Here you would send a notification to the user
      }
    }, timeUntil2h);
  }
}

// Enhanced booking service with payment integration
export async function bookWithPayment({ me, expertId, startAt, endAt, channel = "CHAT", paymentMethod = "MOMO" }) {
  // Use the enhanced UnifiedBookingService
  return await UnifiedBookingService.createAndPay({
    userId: Number(me),
    expertId: Number(expertId),
    startAt,
    endAt,
    channel,
    paymentMethod
  });
}

// Cancel booking with automatic refund calculation
export async function cancelBookingWithPayment(bookingId, userId, reason = '') {
  const booking = await Bookings.getBookingById(bookingId);
  if (!booking) {
    throw Object.assign(new Error("Booking not found"), { status: 404 });
  }

  // Check access
  if (![Number(booking.user_id), Number(booking.expert_id)].includes(Number(userId))) {
    throw Object.assign(new Error("Access denied"), { status: 403 });
  }

  // Check if booking can be cancelled
  if (['CANCELLED', 'COMPLETED'].includes(booking.status)) {
    throw Object.assign(new Error("Booking cannot be cancelled"), { status: 400 });
  }

  const isSeeker = Number(booking.user_id) === Number(userId);
  const paymentIntent = await Payments.getIntentByBookingId(bookingId);

  const client = await getClient();
  try {
    await client.query('BEGIN');

    // Cancel the booking
    await Bookings.updateStatusWithClient({ id: bookingId, status: 'CANCELLED', client });

    let refundInfo = null;

    // If payment was made, calculate and process refund
    if (paymentIntent && paymentIntent.status === 'PAID') {
      const settings = await PlatformRepo.getSettings();
      const refundPolicyHours = parseInt(settings.refund_policy_hours || 24);
      const partialRefundPercent = parseInt(settings.partial_refund_percent || 50);

      const now = new Date();
      const bookingStart = new Date(booking.start_at);
      const hoursUntilBooking = (bookingStart - now) / (1000 * 60 * 60);

      const paidAmount = Number(paymentIntent.amount);
      let refundAmount = 0;
      let refundType = 'NONE';

      if (isSeeker) {
        // Seeker cancellation - apply refund policy
        if (hoursUntilBooking >= refundPolicyHours) {
          refundAmount = paidAmount;
          refundType = 'FULL';
        } else if (hoursUntilBooking > 0) {
          refundAmount = Math.round(paidAmount * partialRefundPercent / 100);
          refundType = 'PARTIAL';
        }
      } else {
        // Expert cancellation - full refund to seeker
        refundAmount = paidAmount;
        refundType = 'FULL';
      }

      if (refundAmount > 0) {
        // Import refunds repo dynamically to avoid circular dependency
        const RefundsRepo = await import('../refunds/refunds.repo.js');

        // Create refund record
        const refund = await RefundsRepo.createRefund({
          bookingId,
          paymentIntentId: paymentIntent.id,
          userId: booking.user_id, // Refund goes to seeker
          amount: refundAmount,
          platformFeeRefunded: 0,
          reason: reason || (isSeeker ? 'Seeker cancelled booking' : 'Expert cancelled booking')
        }, client);

        // Credit refund to seeker's wallet
        await WalletsRepo.creditWallet({
          userId: booking.user_id,
          amount: refundAmount,
          refType: 'REFUND',
          refId: refund.id,
          description: `Refund for cancelled booking #${bookingId}`
        }, client);

        // Auto-approve refund
        await client.query(
          `UPDATE app.refunds SET status = 'COMPLETED', processed_at = now() WHERE id = $1`,
          [refund.id]
        );

        refundInfo = {
          refundId: refund.id,
          refundType,
          refundAmount,
          originalAmount: paidAmount
        };
      }
    }

    await client.query('COMMIT');

    return {
      booking: { ...booking, status: 'CANCELLED' },
      refund: refundInfo,
      cancelledBy: isSeeker ? 'SEEKER' : 'EXPERT'
    };

  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Get booking details with payment and fee information
export async function getBookingWithPayment(bookingId, userId) {
  const booking = await Bookings.getBookingById(bookingId);
  if (!booking) {
    throw Object.assign(new Error("Booking not found"), { status: 404 });
  }

  // Check access
  if (![Number(booking.user_id), Number(booking.expert_id)].includes(Number(userId))) {
    throw Object.assign(new Error("Access denied"), { status: 403 });
  }

  const paymentIntent = await Payments.getIntentByBookingId(bookingId);
  const bookingFee = await PlatformRepo.getBookingFee(bookingId);

  // Get refund if exists
  const RefundsRepo = await import('../refunds/refunds.repo.js');
  const refund = await RefundsRepo.getRefundByBookingId(bookingId);

  return {
    booking,
    payment: paymentIntent,
    fees: bookingFee,
    refund
  };
}

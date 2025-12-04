// src/modules/recurring/recurring.service.js
import * as RecurringRepo from "./recurring.repo.js";
import * as BookingsRepo from "../bookings/bookings.repo.js";
import * as PlatformRepo from "../platform/platform.repo.js";
import { getClient } from "../../config/db.js";

const VALID_FREQUENCIES = ['DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY'];
const VALID_CHANNELS = ['CHAT', 'VIDEO', 'AUDIO'];

// Calculate next booking date based on frequency
function calculateNextDate(currentDate, frequency, dayOfWeek, dayOfMonth) {
    const date = new Date(currentDate);

    switch (frequency) {
        case 'DAILY':
            date.setDate(date.getDate() + 1);
            break;
        case 'WEEKLY':
            date.setDate(date.getDate() + 7);
            break;
        case 'BIWEEKLY':
            date.setDate(date.getDate() + 14);
            break;
        case 'MONTHLY':
            date.setMonth(date.getMonth() + 1);
            if (dayOfMonth) {
                date.setDate(Math.min(dayOfMonth, new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()));
            }
            break;
    }

    return date;
}

// Create recurring booking template
export async function createRecurringTemplate({
    userId, expertId, channel, startTime, durationMinutes, frequency,
    dayOfWeek, dayOfMonth, totalSessions, startsFrom, endsAt
}) {
    // Validations
    if (!VALID_FREQUENCIES.includes(frequency)) {
        throw Object.assign(new Error(`Invalid frequency. Must be one of: ${VALID_FREQUENCIES.join(', ')}`), { status: 400 });
    }

    channel = String(channel || 'CHAT').toUpperCase();
    if (!VALID_CHANNELS.includes(channel)) {
        throw Object.assign(new Error(`Invalid channel. Must be one of: ${VALID_CHANNELS.join(', ')}`), { status: 400 });
    }

    if (Number(userId) === Number(expertId)) {
        throw Object.assign(new Error("Cannot create recurring booking with yourself"), { status: 400 });
    }

    if (durationMinutes < 60 || durationMinutes > 180) {
        throw Object.assign(new Error("Duration must be between 60 and 180 minutes"), { status: 400 });
    }

    // Validate day_of_week for WEEKLY/BIWEEKLY
    if (['WEEKLY', 'BIWEEKLY'].includes(frequency) && (dayOfWeek === undefined || dayOfWeek < 0 || dayOfWeek > 6)) {
        throw Object.assign(new Error("day_of_week (0-6) is required for WEEKLY/BIWEEKLY frequency"), { status: 400 });
    }

    // Validate day_of_month for MONTHLY
    if (frequency === 'MONTHLY' && (dayOfMonth === undefined || dayOfMonth < 1 || dayOfMonth > 31)) {
        throw Object.assign(new Error("day_of_month (1-31) is required for MONTHLY frequency"), { status: 400 });
    }

    // Get expert's current price
    const expertPrice = await BookingsRepo.getExpertPrice(expertId);
    if (!expertPrice || expertPrice <= 0) {
        throw Object.assign(new Error("Expert has not set their price"), { status: 400 });
    }

    // Calculate price per session based on duration
    const pricePerSession = Math.round(expertPrice * (durationMinutes / 60));

    // Parse dates
    const startDate = new Date(startsFrom);
    if (isNaN(startDate.getTime())) {
        throw Object.assign(new Error("Invalid starts_from date"), { status: 400 });
    }

    let endDate = null;
    if (endsAt) {
        endDate = new Date(endsAt);
        if (isNaN(endDate.getTime())) {
            throw Object.assign(new Error("Invalid ends_at date"), { status: 400 });
        }
        if (endDate <= startDate) {
            throw Object.assign(new Error("ends_at must be after starts_from"), { status: 400 });
        }
    }

    // Create template
    const template = await RecurringRepo.createTemplate({
        userId,
        expertId,
        channel,
        startTime,
        durationMinutes,
        frequency,
        dayOfWeek: ['WEEKLY', 'BIWEEKLY'].includes(frequency) ? dayOfWeek : null,
        dayOfMonth: frequency === 'MONTHLY' ? dayOfMonth : null,
        pricePerSession,
        totalSessions: totalSessions || null,
        startsFrom: startDate,
        endsAt: endDate
    });

    return template;
}

// Get template details
export async function getTemplate(templateId, userId) {
    const template = await RecurringRepo.getTemplateById(templateId);
    if (!template) throw Object.assign(new Error("Template not found"), { status: 404 });

    // Check access
    if (Number(template.user_id) !== Number(userId) && Number(template.expert_id) !== Number(userId)) {
        throw Object.assign(new Error("Access denied"), { status: 403 });
    }

    // Get recent bookings from this template
    const bookings = await RecurringRepo.getBookingsFromTemplate(templateId, { limit: 10 });

    return { template, recentBookings: bookings };
}

// Update template
export async function updateTemplate(templateId, userId, updates) {
    const template = await RecurringRepo.getTemplateById(templateId);
    if (!template) throw Object.assign(new Error("Template not found"), { status: 404 });

    // Only seeker can update
    if (Number(template.user_id) !== Number(userId)) {
        throw Object.assign(new Error("Only the booking creator can update the template"), { status: 403 });
    }

    return RecurringRepo.updateTemplate(templateId, updates);
}

// Cancel/deactivate template
export async function cancelTemplate(templateId, userId) {
    const template = await RecurringRepo.getTemplateById(templateId);
    if (!template) throw Object.assign(new Error("Template not found"), { status: 404 });

    // Both seeker and expert can cancel
    if (Number(template.user_id) !== Number(userId) && Number(template.expert_id) !== Number(userId)) {
        throw Object.assign(new Error("Access denied"), { status: 403 });
    }

    return RecurringRepo.deactivateTemplate(templateId);
}

// List user's recurring templates
export async function listMyTemplates(userId, { asExpert = false, limit = 20, offset = 0 } = {}) {
    return RecurringRepo.listUserTemplates(userId, { asExpert, limit, offset });
}

// Process recurring bookings (called by cron job)
export async function processRecurringBookings() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get templates due for booking creation (look ahead 7 days)
    const lookAheadDate = new Date(today);
    lookAheadDate.setDate(lookAheadDate.getDate() + 7);

    const templates = await RecurringRepo.getTemplatesDueForBooking(lookAheadDate);
    const results = { created: [], failed: [], skipped: [] };

    for (const template of templates) {
        const client = await getClient();

        try {
            await client.query('BEGIN');

            // Calculate booking datetime
            const bookingDate = new Date(template.next_booking_date);
            const [hours, minutes] = template.start_time.split(':').map(Number);
            bookingDate.setHours(hours, minutes, 0, 0);

            const endTime = new Date(bookingDate);
            endTime.setMinutes(endTime.getMinutes() + template.duration_minutes);

            // Check if booking date is in the past
            if (bookingDate < new Date()) {
                // Skip and update next date
                const nextDate = calculateNextDate(template.next_booking_date, template.frequency, template.day_of_week, template.day_of_month);
                await RecurringRepo.updateAfterBookingCreated(template.id, nextDate, client);
                results.skipped.push({ templateId: template.id, reason: 'Date in past' });
                await client.query('COMMIT');
                continue;
            }

            // Check for conflicts
            const hasOverlap = await BookingsRepo.hasOverlap(template.expert_id, bookingDate, endTime);
            if (hasOverlap) {
                results.skipped.push({ templateId: template.id, reason: 'Time conflict' });
                await client.query('COMMIT');
                continue;
            }

            // Use current expert price or locked-in price
            const price = template.price_per_session;

            // Create booking
            const booking = await BookingsRepo.createBooking({
                userId: template.user_id,
                expertId: template.expert_id,
                startAt: bookingDate,
                endAt: endTime,
                channel: template.channel,
                price,
                status: 'PENDING' // Will need payment
            }, client);

            // Link booking to template
            await client.query(
                `UPDATE app.bookings SET recurring_template_id = $1, is_recurring = true WHERE id = $2`,
                [template.id, booking.id]
            );

            // Calculate next booking date
            const nextDate = calculateNextDate(template.next_booking_date, template.frequency, template.day_of_week, template.day_of_month);

            // Check if we've reached total sessions or end date
            const sessionsAfter = template.sessions_completed + 1;
            const shouldDeactivate =
                (template.total_sessions && sessionsAfter >= template.total_sessions) ||
                (template.ends_at && nextDate > new Date(template.ends_at));

            if (shouldDeactivate) {
                await client.query(
                    `UPDATE app.recurring_booking_templates SET is_active = false, sessions_completed = $2 WHERE id = $1`,
                    [template.id, sessionsAfter]
                );
            } else {
                await RecurringRepo.updateAfterBookingCreated(template.id, nextDate, client);
            }

            await client.query('COMMIT');
            results.created.push({ templateId: template.id, bookingId: booking.id });

        } catch (error) {
            await client.query('ROLLBACK');
            console.error(`Failed to process recurring template ${template.id}:`, error);
            results.failed.push({ templateId: template.id, error: error.message });
        } finally {
            client.release();
        }
    }

    return results;
}

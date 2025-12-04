// src/modules/platform/platform.repo.js
import { query } from "../../config/db.js";

// Get all platform settings as object
export async function getSettings() {
    const { rows } = await query(`SELECT key, value FROM app.platform_settings`);
    const settings = {};
    for (const row of rows) {
        settings[row.key] = typeof row.value === 'string' ? row.value : JSON.stringify(row.value);
    }
    return settings;
}

// Get single setting
export async function getSetting(key) {
    const { rows } = await query(
        `SELECT value FROM app.platform_settings WHERE key = $1`,
        [key]
    );
    return rows[0]?.value;
}

// Update setting
export async function updateSetting(key, value, updatedBy) {
    const { rows } = await query(
        `UPDATE app.platform_settings 
         SET value = $2, updated_at = now(), updated_by = $3
         WHERE key = $1
         RETURNING *`,
        [key, JSON.stringify(value), updatedBy]
    );
    return rows[0];
}

// Get platform fee percentage
export async function getPlatformFeePercent() {
    const value = await getSetting('platform_fee_percent');
    return parseFloat(value || 15);
}

// Get minimum platform fee
export async function getMinPlatformFee() {
    const value = await getSetting('min_platform_fee');
    return parseFloat(value || 5000);
}

// Calculate fees for a booking
export async function calculateFees(grossAmount) {
    const feePercent = await getPlatformFeePercent();
    const minFee = await getMinPlatformFee();

    let platformFee = Math.round(grossAmount * feePercent / 100);
    platformFee = Math.max(platformFee, minFee);

    const expertEarning = grossAmount - platformFee;

    return {
        grossAmount,
        platformFee,
        platformFeePercent: feePercent,
        expertEarning,
        minPlatformFee: minFee
    };
}

// Create booking fee record
export async function createBookingFee({ bookingId, grossAmount, platformFee, platformFeePercent, expertEarning, taxAmount = 0 }, client = null) {
    const sql = `
        INSERT INTO app.booking_fees (booking_id, gross_amount, platform_fee, platform_fee_percent, expert_earning, tax_amount)
        VALUES ($1, $2, $3, $4, $5, $6)
        ON CONFLICT (booking_id) DO UPDATE SET
            gross_amount = EXCLUDED.gross_amount,
            platform_fee = EXCLUDED.platform_fee,
            platform_fee_percent = EXCLUDED.platform_fee_percent,
            expert_earning = EXCLUDED.expert_earning,
            tax_amount = EXCLUDED.tax_amount
        RETURNING *
    `;
    const params = [bookingId, grossAmount, platformFee, platformFeePercent, expertEarning, taxAmount];

    if (client) {
        const { rows } = await client.query(sql, params);
        return rows[0];
    }
    const { rows } = await query(sql, params);
    return rows[0];
}

// Get booking fee breakdown
export async function getBookingFee(bookingId) {
    const { rows } = await query(
        `SELECT * FROM app.booking_fees WHERE booking_id = $1`,
        [bookingId]
    );
    return rows[0];
}

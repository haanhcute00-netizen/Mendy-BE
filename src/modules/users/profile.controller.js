import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, failure } from "../../utils/response.js";
import * as UsersRepo from "../users/users.repo.js";
import * as BookingsRepo from "../bookings/bookings.repo.js";
import { query } from "../../config/db.js";
import cloudinary from "../../config/cloudinary.js";

const ALLOWED_ROLES = new Set(["SEEKER", "LISTENER", "EXPERT"]);

/**
 * Upload file lên Cloudinary
 */
async function uploadToCloudinary(file, folder, resourceType = "image") {
    return new Promise((resolve, reject) => {
        const options = {
            folder: `mendy/${folder}`,
            resource_type: resourceType,
            // Tạo public_id dựa trên timestamp
            public_id: `${folder}_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`
        };
        const stream = cloudinary.uploader.upload_stream(options, (error, result) => {
            if (result) resolve(result);
            else reject(error);
        });
        stream.end(file.buffer);
    });
}

export const completeProfile = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const display_name = req.body.full_name?.trim() || null;
    const yob = req.body.year_of_birth ? Number(req.body.year_of_birth) : null;
    const gender = req.body.gender?.toUpperCase() || null;
    const role = (req.body.role || "SEEKER").toUpperCase();

    // Xử lý cờ ẩn danh
    const isAnonymous =
        req.body.is_anonymous !== undefined
            ? req.body.is_anonymous === "false"
                ? false
                : Boolean(req.body.is_anonymous)
            : true;

    if (!ALLOWED_ROLES.has(role)) {
        return failure(res, "Invalid role. Must be SEEKER, LISTENER, or EXPERT", null, 400);
    }

    if (yob && (yob < 1900 || yob > new Date().getFullYear())) {
        return failure(res, "Invalid year of birth", null, 400);
    }

    // Upload files lên Cloudinary
    let avatarUrl = null;
    let attachmentUrl = null;

    const avatarFile = req.files?.avatar?.[0] || null;
    const attachmentFile = req.files?.attachment?.[0] || null;

    if (avatarFile) {
        try {
            const result = await uploadToCloudinary(avatarFile, "avatars", "image");
            avatarUrl = result.secure_url;
        } catch (err) {
            console.error("Failed to upload avatar:", err.message);
            return failure(res, "Failed to upload avatar", null, 500);
        }
    }

    if (attachmentFile) {
        try {
            const result = await uploadToCloudinary(attachmentFile, "attachments", "raw");
            attachmentUrl = result.secure_url;
        } catch (err) {
            console.error("Failed to upload attachment:", err.message);
            return failure(res, "Failed to upload attachment", null, 500);
        }
    }

    // Upsert profile
    const profile = await UsersRepo.upsertProfile({
        userId,
        displayName: display_name,
        avatarUrl,
        yob,
        gender,
        attachmentUrl,
        isAnonymous,
    });

    await UsersRepo.setPrimaryRole(userId, role);

    // Tạo hồ sơ chuyên gia mặc định nếu role = EXPERT và chưa có
    if (role === "EXPERT") {
        await query(
            `INSERT INTO app.expert_profiles
                (user_id, specialties, price_per_session, kyc_status, intro)
             SELECT $1, '{}'::text[], 0, 'PENDING', 'New expert'
             WHERE NOT EXISTS (
                SELECT 1 FROM app.expert_profiles WHERE user_id = $1
             )`,
            [userId]
        );
    }

    return success(res, "Profile setup complete", {
        role_primary: role,
        profile,
        files: { avatar: avatarUrl, attachment: attachmentUrl },
    });
});

export const getMyProfile = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const u = await UsersRepo.getProfileByUserId(me);

    // Get payout account info if user is expert or listener
    let payoutAccount = null;
    if (u && ['EXPERT', 'LISTENER'].includes(u.role_primary)) {
        try {
            const { getMaskedPayoutAccount } = await import("../payouts/payoutAccounts.repo.js");
            payoutAccount = await getMaskedPayoutAccount(me);
        } catch (err) {
            // Ignore if payout module not available
        }
    }

    return success(res, "Profile retrieved", {
        ...u,
        payout_account: payoutAccount
    });
});

export const updateExpertProfile = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const { specialties, price_per_session, intro } = req.body;

    // Validate user is an expert
    const user = await UsersRepo.getProfileByUserId(userId);
    if (!user || user.role_primary !== 'EXPERT') {
        return failure(res, "Only experts can update expert profile", null, 403);
    }

    // Validate price
    if (price_per_session !== undefined && (isNaN(price_per_session) || Number(price_per_session) < 0)) {
        return failure(res, "Invalid price", null, 400);
    }

    // Validate specialties if provided
    if (specialties !== undefined && (!Array.isArray(specialties) || specialties.some(s => typeof s !== 'string'))) {
        return failure(res, "Specialties must be an array of strings", null, 400);
    }

    try {
        // Get current expert profile
        const { rows: currentProfile } = await query(
            `SELECT specialties, price_per_session, intro FROM app.expert_profiles WHERE user_id = $1`,
            [userId]
        );

        // Create expert profile if it doesn't exist
        if (!currentProfile[0]) {
            await query(
                `INSERT INTO app.expert_profiles (user_id, specialties, price_per_session, kyc_status, intro)
                 VALUES ($1, $2, $3, 'PENDING', $4)`,
                [userId, specialties || [], price_per_session || 0, intro || '']
            );

            const { rows: newProfile } = await query(
                `SELECT id, user_id, specialties, price_per_session, intro, rating_avg, kyc_status
                 FROM app.expert_profiles WHERE user_id = $1`,
                [userId]
            );

            return success(res, "Expert profile created", newProfile[0]);
        }

        const current = currentProfile[0];

        const updatedProfile = await BookingsRepo.updateExpertProfile({
            userId,
            specialties: specialties !== undefined ? specialties : current.specialties || [],
            pricePerSession: price_per_session !== undefined ? Number(price_per_session) : current.price_per_session,
            intro: intro !== undefined ? intro : current.intro
        });

        return success(res, "Expert profile updated", updatedProfile);
    } catch (error) {
        console.error("Error updating expert profile:", error);
        return failure(res, "Failed to update expert profile", null, 500);
    }
});

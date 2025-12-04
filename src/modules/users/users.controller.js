import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, paginated } from "../../utils/response.js";
import * as UsersService from "./users.service.js";

// Xem profile người khác
export const getProfile = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { id } = req.params;

    const profile = await UsersService.getPublicProfile({
        me,
        userId: Number(id)
    });

    return success(res, "Profile retrieved successfully", profile);
});

// Cập nhật profile của mình
export const updateMyProfile = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { display_name, bio, gender, year_of_birth, is_anonymous } = req.body;

    const updated = await UsersService.updateProfile({
        me,
        displayName: display_name,
        bio,
        gender,
        yearOfBirth: year_of_birth ? Number(year_of_birth) : undefined,
        isAnonymous: is_anonymous
    });

    return success(res, "Profile updated successfully", updated);
});

// Search users
export const searchUsers = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { q, limit = 20, offset = 0 } = req.query;

    const users = await UsersService.searchUsers({
        me,
        query: q,
        limit: Number(limit),
        offset: Number(offset)
    });

    return paginated(res, "Users found", users, {
        limit: Number(limit),
        offset: Number(offset)
    });
});

// Lấy danh sách followers
export const getFollowers = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { id } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const followers = await UsersService.getFollowers({
        me,
        userId: Number(id),
        limit: Number(limit),
        offset: Number(offset)
    });

    return paginated(res, "Followers retrieved", followers, {
        limit: Number(limit),
        offset: Number(offset)
    });
});

// Lấy danh sách following
export const getFollowing = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { id } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const following = await UsersService.getFollowing({
        me,
        userId: Number(id),
        limit: Number(limit),
        offset: Number(offset)
    });

    return paginated(res, "Following retrieved", following, {
        limit: Number(limit),
        offset: Number(offset)
    });
});

// Block user
export const blockUser = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { user_id } = req.body;

    const result = await UsersService.blockUser({
        me,
        userId: Number(user_id)
    });

    return success(res, "User blocked successfully", result);
});

// Unblock user
export const unblockUser = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { user_id } = req.body;

    const result = await UsersService.unblockUser({
        me,
        userId: Number(user_id)
    });

    return success(res, "User unblocked successfully", result);
});

// Lấy danh sách blocked users
export const getBlockedUsers = asyncHandler(async (req, res) => {
    const me = req.user.id;
    const { limit = 50, offset = 0 } = req.query;

    const blocked = await UsersService.getBlockedUsers({
        me,
        limit: Number(limit),
        offset: Number(offset)
    });

    return paginated(res, "Blocked users retrieved", blocked, {
        limit: Number(limit),
        offset: Number(offset)
    });
});

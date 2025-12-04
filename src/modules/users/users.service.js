import * as UsersRepo from "./users.repo.js";
import * as FollowsRepo from "./follows.repo.js";

/**
 * Lấy public profile của user khác
 * Ẩn thông tin nhạy cảm nếu user đó chọn anonymous
 */
export async function getPublicProfile({ me, userId }) {
    const profile = await UsersRepo.getProfileByUserId(userId);
    if (!profile) {
        throw Object.assign(new Error("User not found"), { status: 404 });
    }

    const isOwner = Number(me) === Number(userId);
    const isFollowing = !isOwner ? await FollowsRepo.isFollower({ followerId: me, followeeId: userId }) : false;
    const isFollower = !isOwner ? await FollowsRepo.isFollower({ followerId: userId, followeeId: me }) : false;

    // Nếu user chọn anonymous và không phải owner, ẩn một số thông tin
    if (profile.is_anonymous && !isOwner) {
        return {
            id: profile.id,
            handle: profile.handle,
            display_name: "Ẩn danh",
            avatar_url: null,
            bio: null,
            role_primary: profile.role_primary,
            created_at: profile.created_at,
            is_anonymous: true,
            following_count: parseInt(profile.following_count) || 0,
            followers_count: parseInt(profile.followers_count) || 0,
            posts_count: parseInt(profile.posts_count) || 0,
            is_following: isFollowing,
            is_follower: isFollower,
            is_owner: false
        };
    }

    // Public profile - hiển thị thông tin cơ bản
    return {
        id: profile.id,
        handle: profile.handle,
        display_name: profile.display_name,
        avatar_url: profile.avatar_url,
        bio: profile.bio,
        gender: profile.gender,
        role_primary: profile.role_primary,
        created_at: profile.created_at,
        is_anonymous: profile.is_anonymous,
        following_count: parseInt(profile.following_count) || 0,
        followers_count: parseInt(profile.followers_count) || 0,
        posts_count: parseInt(profile.posts_count) || 0,
        completed_sessions: parseInt(profile.completed_sessions) || 0,
        // Expert info nếu là expert
        expert_profile: profile.role_primary === 'EXPERT' ? profile.expert_profile : null,
        // Relationship với current user
        is_following: isFollowing,
        is_follower: isFollower,
        is_owner: isOwner
    };
}

/**
 * Cập nhật profile cơ bản
 */
export async function updateProfile({ me, displayName, bio, gender, yearOfBirth, isAnonymous }) {
    // Validate year of birth
    if (yearOfBirth !== undefined) {
        const year = Number(yearOfBirth);
        if (isNaN(year) || year < 1900 || year > new Date().getFullYear()) {
            throw Object.assign(new Error("Invalid year of birth"), { status: 400 });
        }
    }

    // Validate gender
    const validGenders = ["MALE", "FEMALE", "OTHER", "UNSPECIFIED"];
    if (gender !== undefined && !validGenders.includes(gender?.toUpperCase())) {
        throw Object.assign(new Error("Invalid gender"), { status: 400 });
    }

    const updated = await UsersRepo.updateBasicProfile({
        userId: me,
        displayName,
        bio,
        gender: gender?.toUpperCase(),
        yearOfBirth,
        isAnonymous
    });

    if (!updated) {
        throw Object.assign(new Error("Failed to update profile"), { status: 500 });
    }

    return updated;
}

/**
 * Search users
 */
export async function searchUsers({ me, query, limit = 20, offset = 0 }) {
    if (!query || query.trim().length < 2) {
        throw Object.assign(new Error("Search query must be at least 2 characters"), { status: 400 });
    }

    const users = await UsersRepo.searchUsers({
        query: query.trim(),
        limit,
        offset,
        excludeUserId: me
    });

    // Check follow status for each user
    const results = await Promise.all(users.map(async (user) => {
        const isFollowing = await FollowsRepo.isFollower({ followerId: me, followeeId: user.id });
        return {
            ...user,
            is_following: isFollowing
        };
    }));

    return results;
}

/**
 * Lấy danh sách followers
 */
export async function getFollowers({ me, userId, limit = 50, offset = 0 }) {
    const followers = await UsersRepo.getFollowers({ userId, limit, offset });

    // Check if current user follows each follower
    const results = await Promise.all(followers.map(async (user) => {
        const isFollowing = Number(me) !== user.id
            ? await FollowsRepo.isFollower({ followerId: me, followeeId: user.id })
            : false;
        return {
            ...user,
            is_following: isFollowing,
            is_me: Number(me) === user.id
        };
    }));

    return results;
}

/**
 * Lấy danh sách following
 */
export async function getFollowing({ me, userId, limit = 50, offset = 0 }) {
    const following = await UsersRepo.getFollowing({ userId, limit, offset });

    // Check if current user follows each user
    const results = await Promise.all(following.map(async (user) => {
        const isFollowing = Number(me) !== user.id
            ? await FollowsRepo.isFollower({ followerId: me, followeeId: user.id })
            : false;
        return {
            ...user,
            is_following: isFollowing,
            is_me: Number(me) === user.id
        };
    }));

    return results;
}

/**
 * Block user
 */
export async function blockUser({ me, userId }) {
    if (Number(me) === Number(userId)) {
        throw Object.assign(new Error("Cannot block yourself"), { status: 400 });
    }

    // Check if user exists
    const user = await UsersRepo.getById(userId);
    if (!user) {
        throw Object.assign(new Error("User not found"), { status: 404 });
    }

    // Block user
    await UsersRepo.blockUser({ blockerId: me, blockedId: userId });

    // Auto unfollow both ways
    await FollowsRepo.unfollow({ me, userId });
    await FollowsRepo.unfollow({ me: userId, userId: me });

    return { blocked: true };
}

/**
 * Unblock user
 */
export async function unblockUser({ me, userId }) {
    const unblocked = await UsersRepo.unblockUser({ blockerId: me, blockedId: userId });
    return { unblocked };
}

/**
 * Lấy danh sách blocked users
 */
export async function getBlockedUsers({ me, limit = 50, offset = 0 }) {
    return UsersRepo.getBlockedUsers({ userId: me, limit, offset });
}

/**
 * Check if blocked
 */
export async function isBlocked({ me, userId }) {
    return UsersRepo.isBlocked({ blockerId: me, blockedId: userId });
}

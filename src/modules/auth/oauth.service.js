import {
    findOAuthByGoogleId,
    createOAuthUser,
} from "./oauth.repo.js";
import {
    findAppUserById,
    findUserByEmail,
    createAppUserForGoogle,
} from "../users/users.repo.js";

export const loginWithGoogleService = async (profile) => {
    const googleId = profile.id;
    const email = profile.emails?.[0]?.value || null;
    const name = profile.displayName;
    const avatar = profile.photos?.[0]?.value || null;

    // 1. Đã có mapping google_id -> app_user_id chưa?
    const oauthRecord = await findOAuthByGoogleId(googleId);
    if (oauthRecord) {
        const appUser = await findAppUserById(oauthRecord.app_user_id);
        return appUser; // dùng app.users làm user "chính"
    }

    // 2. Chưa có mapping, nhưng có thể user đã đăng ký bằng email thường
    let appUser = null;
    if (email) {
        appUser = await findUserByEmail(email);
    }

    // 3. Nếu chưa có user trong app.users -> tạo mới
    if (!appUser) {
        appUser = await createAppUserForGoogle({ email, name, googleId });
    }

    // 4. Tạo mapping oauth_users
    await createOAuthUser({
        appUserId: appUser.id,
        googleId,
        email,
        name,
        avatar,
    });

    return appUser;
};

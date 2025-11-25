import passport from "passport";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import { loginWithGoogleService } from "../modules/auth/oauth.service.js";
import { findAppUserById } from "../modules/users/users.repo.js";

export default function setupPassport() {
  passport.use(
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: process.env.GOOGLE_CALLBACK_URL,
      },
      async (accessToken, refreshToken, profile, done) => {
        try {
          // tất cả logic nằm trong service
          const appUser = await loginWithGoogleService(profile);
          return done(null, appUser);
        } catch (err) {
          console.error("Google login error:", err);
          return done(err, null);
        }
      }
    )
  );

  passport.serializeUser((user, done) => {
    done(null, user.id); // id của app.users
  });

  passport.deserializeUser(async (id, done) => {
    try {
      const user = await findAppUserById(id);
      done(null, user);
    } catch (err) {
      done(err, null);
    }
  });

  return passport;
}

// =============================================
// AI RATE LIMITER
// Rate limiting for Gemini API calls
// =============================================

import { logRateLimitHit } from './aiLogger.js';

// ========== IN-MEMORY RATE LIMITER ==========
// For production with multiple instances, use Redis

class RateLimiter {
    constructor() {
        // Store: { userId: { count: number, resetAt: timestamp } }
        this.userLimits = new Map();
        this.globalLimits = { count: 0, resetAt: Date.now() };

        // Configuration
        this.config = {
            // Per-user limits
            user: {
                maxRequests: 30,        // Max requests per window
                windowMs: 60 * 1000,    // 1 minute window
                maxDaily: 500           // Max daily requests per user
            },
            // Global limits (protect API quota)
            global: {
                maxRequests: 1000,      // Max requests per window
                windowMs: 60 * 1000,    // 1 minute window
                maxDaily: 50000         // Max daily requests globally
            },
            // Emotion analysis specific (less critical)
            emotion: {
                maxRequests: 60,
                windowMs: 60 * 1000
            }
        };

        // Daily counters
        this.dailyUserCounts = new Map();
        this.dailyGlobalCount = 0;
        this.dailyResetAt = this.getNextMidnight();

        // Cleanup old entries every 5 minutes
        setInterval(() => this.cleanup(), 5 * 60 * 1000);
    }

    getNextMidnight() {
        const now = new Date();
        const midnight = new Date(now);
        midnight.setHours(24, 0, 0, 0);
        return midnight.getTime();
    }

    resetDailyIfNeeded() {
        const now = Date.now();
        if (now >= this.dailyResetAt) {
            this.dailyUserCounts.clear();
            this.dailyGlobalCount = 0;
            this.dailyResetAt = this.getNextMidnight();
        }
    }

    cleanup() {
        const now = Date.now();
        for (const [userId, data] of this.userLimits.entries()) {
            if (data.resetAt < now) {
                this.userLimits.delete(userId);
            }
        }
    }

    // Check if request is allowed
    async checkLimit(userId, type = 'chat') {
        this.resetDailyIfNeeded();
        const now = Date.now();
        const config = this.config[type] || this.config.user;

        // Check global limit
        if (this.globalLimits.resetAt < now) {
            this.globalLimits = { count: 0, resetAt: now + this.config.global.windowMs };
        }

        if (this.globalLimits.count >= this.config.global.maxRequests) {
            return {
                allowed: false,
                reason: 'global_limit',
                retryAfter: Math.ceil((this.globalLimits.resetAt - now) / 1000)
            };
        }

        // Check global daily limit
        if (this.dailyGlobalCount >= this.config.global.maxDaily) {
            return {
                allowed: false,
                reason: 'global_daily_limit',
                retryAfter: Math.ceil((this.dailyResetAt - now) / 1000)
            };
        }

        // Check user limit
        let userData = this.userLimits.get(userId);
        if (!userData || userData.resetAt < now) {
            userData = { count: 0, resetAt: now + config.windowMs };
            this.userLimits.set(userId, userData);
        }

        if (userData.count >= config.maxRequests) {
            logRateLimitHit(userId, {
                endpoint: type,
                limit: config.maxRequests,
                window: config.windowMs
            });
            return {
                allowed: false,
                reason: 'user_limit',
                retryAfter: Math.ceil((userData.resetAt - now) / 1000)
            };
        }

        // Check user daily limit
        const userDaily = this.dailyUserCounts.get(userId) || 0;
        if (userDaily >= this.config.user.maxDaily) {
            logRateLimitHit(userId, {
                endpoint: `${type}_daily`,
                limit: this.config.user.maxDaily,
                window: 'daily'
            });
            return {
                allowed: false,
                reason: 'user_daily_limit',
                retryAfter: Math.ceil((this.dailyResetAt - now) / 1000)
            };
        }

        return { allowed: true };
    }

    // Record a request
    recordRequest(userId, type = 'chat') {
        const now = Date.now();
        const config = this.config[type] || this.config.user;

        // Update global
        if (this.globalLimits.resetAt < now) {
            this.globalLimits = { count: 1, resetAt: now + this.config.global.windowMs };
        } else {
            this.globalLimits.count++;
        }
        this.dailyGlobalCount++;

        // Update user
        let userData = this.userLimits.get(userId);
        if (!userData || userData.resetAt < now) {
            userData = { count: 1, resetAt: now + config.windowMs };
        } else {
            userData.count++;
        }
        this.userLimits.set(userId, userData);

        // Update daily
        const userDaily = this.dailyUserCounts.get(userId) || 0;
        this.dailyUserCounts.set(userId, userDaily + 1);
    }

    // Get current usage stats
    getStats(userId) {
        this.resetDailyIfNeeded();
        const userData = this.userLimits.get(userId);
        const userDaily = this.dailyUserCounts.get(userId) || 0;

        return {
            user: {
                current: userData?.count || 0,
                limit: this.config.user.maxRequests,
                daily: userDaily,
                dailyLimit: this.config.user.maxDaily
            },
            global: {
                current: this.globalLimits.count,
                limit: this.config.global.maxRequests,
                daily: this.dailyGlobalCount,
                dailyLimit: this.config.global.maxDaily
            }
        };
    }
}

// Singleton instance
const rateLimiter = new RateLimiter();

// ========== EXPORTS ==========

export const checkGeminiRateLimit = async (userId, type = 'chat') => {
    return rateLimiter.checkLimit(userId, type);
};

export const recordGeminiRequest = (userId, type = 'chat') => {
    rateLimiter.recordRequest(userId, type);
};

export const getGeminiUsageStats = (userId) => {
    return rateLimiter.getStats(userId);
};

// Middleware for Express routes
export const geminiRateLimitMiddleware = (type = 'chat') => {
    return async (req, res, next) => {
        const userId = req.user?.id || req.ip;
        const result = await checkGeminiRateLimit(userId, type);

        if (!result.allowed) {
            return res.status(429).json({
                error: 'Rate limit exceeded',
                reason: result.reason,
                retryAfter: result.retryAfter,
                message: result.reason === 'user_daily_limit'
                    ? 'Bạn đã đạt giới hạn sử dụng AI trong ngày. Vui lòng thử lại vào ngày mai.'
                    : 'Quá nhiều yêu cầu. Vui lòng thử lại sau.'
            });
        }

        next();
    };
};

export default rateLimiter;

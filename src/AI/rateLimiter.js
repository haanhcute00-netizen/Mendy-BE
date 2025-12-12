// =============================================
// AI RATE LIMITER
// Rate limiting for Gemini API calls
// =============================================

import { logRateLimitHit } from './aiLogger.js';
import { RATE_LIMIT_CONFIG } from './config.js';
import { createChildLogger } from '../utils/logger.js';

const logger = createChildLogger({ module: 'rate-limiter' });

// ========== REDIS SUPPORT (Task 6) ==========
let redisClient = null;
let useRedis = false;

const initRedis = async () => {
    const redisUrl = process.env.REDIS_URL;
    if (!redisUrl) {
        logger.info('REDIS_URL not set, using in-memory rate limiter');
        return false;
    }

    try {
        const { createClient } = await import('redis');
        redisClient = createClient({ url: redisUrl });
        redisClient.on('error', (err) => logger.error('Redis error:', err.message));
        await redisClient.connect();
        useRedis = true;
        logger.info('Redis connected for rate limiting');
        return true;
    } catch (err) {
        logger.warn('Redis connection failed, using in-memory:', err.message);
        return false;
    }
};

// Initialize Redis on module load
initRedis().catch(() => { });

// ========== RATE LIMITER CLASS ==========

class RateLimiter {
    constructor() {
        // Store: { userId: { count: number, resetAt: timestamp } }
        this.userLimits = new Map();
        this.globalLimits = { count: 0, resetAt: Date.now() };

        // Task 5: Use shared config
        this.config = RATE_LIMIT_CONFIG;

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

    // Task 6: Check limit with Redis support
    async checkLimit(userId, type = 'chat') {
        // Use Redis if available
        if (useRedis && redisClient?.isOpen) {
            return this.checkLimitRedis(userId, type);
        }
        return this.checkLimitMemory(userId, type);
    }

    // Task 6: Redis-based rate limiting
    async checkLimitRedis(userId, type = 'chat') {
        const now = Date.now();
        const config = this.config[type] || this.config.user;

        try {
            // Check global limit
            const globalKey = `ratelimit:global:${type}`;
            const globalCount = await redisClient.incr(globalKey);
            if (globalCount === 1) {
                await redisClient.pExpire(globalKey, config.windowMs);
            }

            if (globalCount > this.config.global.maxRequests) {
                const ttl = await redisClient.pTTL(globalKey);
                return {
                    allowed: false,
                    reason: 'global_limit',
                    retryAfter: Math.ceil(ttl / 1000)
                };
            }

            // Check user limit
            const userKey = `ratelimit:user:${userId}:${type}`;
            const userCount = await redisClient.incr(userKey);
            if (userCount === 1) {
                await redisClient.pExpire(userKey, config.windowMs);
            }

            if (userCount > config.maxRequests) {
                const ttl = await redisClient.pTTL(userKey);
                logRateLimitHit(userId, { endpoint: type, limit: config.maxRequests, window: config.windowMs });
                return {
                    allowed: false,
                    reason: 'user_limit',
                    retryAfter: Math.ceil(ttl / 1000)
                };
            }

            // Check daily limit
            const dailyKey = `ratelimit:daily:${userId}`;
            const dailyCount = await redisClient.incr(dailyKey);
            if (dailyCount === 1) {
                // Expire at midnight
                const midnight = new Date();
                midnight.setHours(24, 0, 0, 0);
                await redisClient.pExpireAt(dailyKey, midnight.getTime());
            }

            if (dailyCount > this.config.user.maxDaily) {
                logRateLimitHit(userId, { endpoint: `${type}_daily`, limit: this.config.user.maxDaily, window: 'daily' });
                return {
                    allowed: false,
                    reason: 'user_daily_limit',
                    retryAfter: Math.ceil((new Date().setHours(24, 0, 0, 0) - now) / 1000)
                };
            }

            return { allowed: true };
        } catch (err) {
            logger.error('Redis rate limit check failed:', err.message);
            // Fallback to memory
            return this.checkLimitMemory(userId, type);
        }
    }

    // Original in-memory check (renamed)
    async checkLimitMemory(userId, type = 'chat') {
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

    // Task 6: Record request with Redis support
    async recordRequest(userId, type = 'chat') {
        // Redis already increments in checkLimit, so only record for memory
        if (useRedis && redisClient?.isOpen) {
            return; // Already recorded in checkLimitRedis
        }
        return this.recordRequestMemory(userId, type);
    }

    // Original in-memory record (renamed)
    recordRequestMemory(userId, type = 'chat') {
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

export const recordGeminiRequest = async (userId, type = 'chat') => {
    await rateLimiter.recordRequest(userId, type);
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

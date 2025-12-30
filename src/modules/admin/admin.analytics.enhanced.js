// =============================================
// ADMIN ANALYTICS ENHANCED
// Bổ sung các chức năng analytics mới
// =============================================

import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, failure } from "../../utils/response.js";
import * as AuditService from "./audit.repo.js";
import { query } from "../../config/db.js";

// Simple in-memory cache
const analyticsCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

function getCached(key) {
    const cached = analyticsCache.get(key);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        return cached.data;
    }
    return null;
}

function setCache(key, data) {
    analyticsCache.set(key, { data, timestamp: Date.now() });
}

// ============================================
// 1. COHORT ANALYSIS - Phân tích theo nhóm user
// ============================================

export const getCohortAnalysis = asyncHandler(async (req, res) => {
    const { months = 6 } = req.query;
    const cacheKey = `cohort_${months}`;

    const cached = getCached(cacheKey);
    if (cached) {
        return success(res, "Cohort analysis retrieved (cached)", cached);
    }

    // Lấy users theo tháng đăng ký
    const { rows: cohorts } = await query(`
        WITH monthly_cohorts AS (
            SELECT 
                DATE_TRUNC('month', created_at) as cohort_month,
                id as user_id
            FROM app.users
            WHERE created_at >= NOW() - INTERVAL '${parseInt(months)} months'
        ),
        user_activity AS (
            SELECT 
                mc.cohort_month,
                mc.user_id,
                DATE_TRUNC('month', b.created_at) as activity_month,
                COUNT(b.id) as bookings
            FROM monthly_cohorts mc
            LEFT JOIN app.bookings b ON b.user_id = mc.user_id
            GROUP BY mc.cohort_month, mc.user_id, DATE_TRUNC('month', b.created_at)
        )
        SELECT 
            cohort_month,
            COUNT(DISTINCT user_id) as cohort_size,
            COUNT(DISTINCT CASE WHEN activity_month = cohort_month THEN user_id END) as month_0,
            COUNT(DISTINCT CASE WHEN activity_month = cohort_month + INTERVAL '1 month' THEN user_id END) as month_1,
            COUNT(DISTINCT CASE WHEN activity_month = cohort_month + INTERVAL '2 month' THEN user_id END) as month_2,
            COUNT(DISTINCT CASE WHEN activity_month = cohort_month + INTERVAL '3 month' THEN user_id END) as month_3
        FROM user_activity
        GROUP BY cohort_month
        ORDER BY cohort_month DESC
    `);

    const result = {
        cohorts: cohorts.map(c => ({
            month: c.cohort_month,
            size: parseInt(c.cohort_size),
            retention: {
                month_0: parseInt(c.month_0),
                month_1: parseInt(c.month_1),
                month_2: parseInt(c.month_2),
                month_3: parseInt(c.month_3)
            },
            retention_rates: {
                month_0: c.cohort_size > 0 ? ((c.month_0 / c.cohort_size) * 100).toFixed(1) + '%' : '0%',
                month_1: c.cohort_size > 0 ? ((c.month_1 / c.cohort_size) * 100).toFixed(1) + '%' : '0%',
                month_2: c.cohort_size > 0 ? ((c.month_2 / c.cohort_size) * 100).toFixed(1) + '%' : '0%',
                month_3: c.cohort_size > 0 ? ((c.month_3 / c.cohort_size) * 100).toFixed(1) + '%' : '0%'
            }
        }))
    };

    setCache(cacheKey, result);
    return success(res, "Cohort analysis retrieved", result);
});

// ============================================
// 2. SESSION QUALITY ANALYTICS
// ============================================

export const getSessionQualityAnalytics = asyncHandler(async (req, res) => {
    const { days = 30 } = req.query;

    // Phân tích chất lượng sessions
    const { rows: sessionQuality } = await query(`
        SELECT 
            b.channel,
            COUNT(*) as total_sessions,
            COUNT(*) FILTER (WHERE b.status = 'COMPLETED') as completed,
            COUNT(*) FILTER (WHERE b.status = 'CANCELLED') as cancelled,
            COUNT(*) FILTER (WHERE b.status = 'NOSHOW') as noshow,
            AVG(EXTRACT(EPOCH FROM (b.end_at - b.start_at))/60) as avg_duration_minutes,
            AVG(r.rating) as avg_rating,
            COUNT(r.id) as reviews_count
        FROM app.bookings b
        LEFT JOIN app.reviews r ON r.booking_id = b.id
        WHERE b.created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        GROUP BY b.channel
    `);

    // Call quality metrics
    const { rows: callQuality } = await query(`
        SELECT 
            kind,
            COUNT(*) as total_calls,
            COUNT(*) FILTER (WHERE status = 'ENDED') as completed_calls,
            COUNT(*) FILTER (WHERE status = 'REJECTED') as rejected_calls,
            COUNT(*) FILTER (WHERE status = 'BUSY') as busy_calls,
            AVG(EXTRACT(EPOCH FROM (ended_at - connected_at))) as avg_duration_seconds
        FROM app.call_sessions
        WHERE started_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        GROUP BY kind
    `);

    // Rating distribution
    const { rows: ratingDist } = await query(`
        SELECT 
            rating,
            COUNT(*) as count
        FROM app.reviews
        WHERE created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        GROUP BY rating
        ORDER BY rating DESC
    `);

    return success(res, "Session quality analytics retrieved", {
        period: { days: parseInt(days) },
        by_channel: sessionQuality.map(s => ({
            channel: s.channel,
            total: parseInt(s.total_sessions),
            completed: parseInt(s.completed),
            cancelled: parseInt(s.cancelled),
            noshow: parseInt(s.noshow),
            completion_rate: s.total_sessions > 0
                ? ((s.completed / s.total_sessions) * 100).toFixed(1) + '%' : '0%',
            avg_duration_minutes: parseFloat(s.avg_duration_minutes || 0).toFixed(1),
            avg_rating: parseFloat(s.avg_rating || 0).toFixed(2),
            reviews: parseInt(s.reviews_count)
        })),
        call_quality: callQuality.map(c => ({
            type: c.kind,
            total: parseInt(c.total_calls),
            completed: parseInt(c.completed_calls),
            rejected: parseInt(c.rejected_calls),
            busy: parseInt(c.busy_calls),
            avg_duration_seconds: parseFloat(c.avg_duration_seconds || 0).toFixed(0)
        })),
        rating_distribution: ratingDist.map(r => ({
            rating: parseInt(r.rating),
            count: parseInt(r.count)
        }))
    });
});

// ============================================
// 3. EXPERT PERFORMANCE ANALYTICS
// ============================================

export const getExpertPerformanceAnalytics = asyncHandler(async (req, res) => {
    const { days = 30, limit = 20 } = req.query;

    const { rows: expertPerformance } = await query(`
        SELECT 
            u.id,
            u.handle,
            up.display_name,
            ep.specialties,
            ep.price_per_session,
            ep.rating_avg,
            COUNT(b.id) as total_bookings,
            COUNT(b.id) FILTER (WHERE b.status = 'COMPLETED') as completed_bookings,
            COUNT(b.id) FILTER (WHERE b.status = 'CANCELLED') as cancelled_bookings,
            COUNT(b.id) FILTER (WHERE b.status = 'NOSHOW') as noshow_bookings,
            COALESCE(SUM(b.price) FILTER (WHERE b.status = 'COMPLETED'), 0) as total_earnings,
            COUNT(DISTINCT b.user_id) as unique_clients,
            COUNT(r.id) as review_count,
            AVG(r.rating) as avg_review_rating,
            AVG(EXTRACT(EPOCH FROM (b.end_at - b.start_at))/60) as avg_session_duration
        FROM app.users u
        JOIN app.expert_profiles ep ON ep.user_id = u.id
        LEFT JOIN app.user_profiles up ON up.user_id = u.id
        LEFT JOIN app.bookings b ON b.expert_id = u.id 
            AND b.created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        LEFT JOIN app.reviews r ON r.expert_id = u.id 
            AND r.created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        WHERE ep.kyc_status = 'VERIFIED'
        GROUP BY u.id, u.handle, up.display_name, ep.specialties, ep.price_per_session, ep.rating_avg
        ORDER BY total_earnings DESC
        LIMIT $1
    `, [parseInt(limit)]);

    // Calculate performance scores
    const experts = expertPerformance.map(e => {
        const completionRate = e.total_bookings > 0
            ? (e.completed_bookings / e.total_bookings) : 0;
        const rating = parseFloat(e.avg_review_rating || e.rating_avg || 0);

        // Performance score: 40% completion rate + 40% rating + 20% volume
        const volumeScore = Math.min(e.completed_bookings / 10, 1); // Max at 10 bookings
        const performanceScore = (completionRate * 40) + (rating / 5 * 40) + (volumeScore * 20);

        return {
            id: e.id,
            handle: e.handle,
            display_name: e.display_name,
            specialties: e.specialties,
            price_per_session: parseFloat(e.price_per_session),
            bookings: {
                total: parseInt(e.total_bookings),
                completed: parseInt(e.completed_bookings),
                cancelled: parseInt(e.cancelled_bookings),
                noshow: parseInt(e.noshow_bookings),
                completion_rate: (completionRate * 100).toFixed(1) + '%'
            },
            earnings: parseFloat(e.total_earnings),
            unique_clients: parseInt(e.unique_clients),
            reviews: {
                count: parseInt(e.review_count),
                avg_rating: rating.toFixed(2)
            },
            avg_session_duration: parseFloat(e.avg_session_duration || 0).toFixed(0),
            performance_score: performanceScore.toFixed(1)
        };
    });

    return success(res, "Expert performance analytics retrieved", {
        period: { days: parseInt(days) },
        experts,
        summary: {
            total_experts: experts.length,
            avg_completion_rate: experts.length > 0
                ? (experts.reduce((sum, e) => sum + parseFloat(e.bookings.completion_rate), 0) / experts.length).toFixed(1) + '%'
                : '0%',
            total_earnings: experts.reduce((sum, e) => sum + e.earnings, 0),
            avg_performance_score: experts.length > 0
                ? (experts.reduce((sum, e) => sum + parseFloat(e.performance_score), 0) / experts.length).toFixed(1)
                : '0'
        }
    });
});

// ============================================
// 4. FINANCIAL HEALTH DASHBOARD
// ============================================

export const getFinancialHealthDashboard = asyncHandler(async (req, res) => {
    const { days = 30 } = req.query;

    // Revenue metrics
    const { rows: revenue } = await query(`
        SELECT 
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID'), 0) as gross_revenue,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID'), 0) * 0.15 as platform_revenue,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID'), 0) * 0.85 as expert_payable,
            COUNT(*) FILTER (WHERE status = 'PAID') as successful_transactions,
            COUNT(*) FILTER (WHERE status = 'FAILED') as failed_transactions,
            COALESCE(AVG(amount) FILTER (WHERE status = 'PAID'), 0) as avg_transaction
        FROM app.payment_intents
        WHERE created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
    `);

    // Payout liabilities
    const { rows: payouts } = await query(`
        SELECT 
            COALESCE(SUM(amount) FILTER (WHERE status = 'PENDING'), 0) as pending_payouts,
            COALESCE(SUM(amount) FILTER (WHERE status = 'APPROVED'), 0) as approved_payouts,
            COALESCE(SUM(amount) FILTER (WHERE status = 'COMPLETED'), 0) as completed_payouts,
            COUNT(*) FILTER (WHERE status = 'PENDING') as pending_count
        FROM app.payout_requests
        WHERE created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
    `);

    // Refund impact
    const { rows: refunds } = await query(`
        SELECT 
            COALESCE(SUM(amount) FILTER (WHERE status = 'PENDING'), 0) as pending_refunds,
            COALESCE(SUM(amount) FILTER (WHERE status = 'COMPLETED'), 0) as completed_refunds,
            COUNT(*) FILTER (WHERE status = 'PENDING') as pending_count,
            COUNT(*) FILTER (WHERE status = 'COMPLETED') as completed_count
        FROM app.refunds
        WHERE created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
    `);

    // Wallet balances
    const { rows: wallets } = await query(`
        SELECT 
            COALESCE(SUM(balance), 0) as total_balance,
            COUNT(*) as wallet_count,
            COALESCE(AVG(balance), 0) as avg_balance,
            COALESCE(MAX(balance), 0) as max_balance
        FROM app.wallets
        WHERE balance > 0
    `);

    // Daily revenue trend
    const { rows: dailyRevenue } = await query(`
        SELECT 
            DATE(created_at) as date,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID'), 0) as revenue,
            COUNT(*) FILTER (WHERE status = 'PAID') as transactions
        FROM app.payment_intents
        WHERE created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        GROUP BY DATE(created_at)
        ORDER BY date ASC
    `);

    const grossRevenue = parseFloat(revenue[0]?.gross_revenue || 0);
    const completedRefunds = parseFloat(refunds[0]?.completed_refunds || 0);
    const netRevenue = grossRevenue - completedRefunds;

    return success(res, "Financial health dashboard retrieved", {
        period: { days: parseInt(days) },
        revenue: {
            gross: grossRevenue,
            platform_share: parseFloat(revenue[0]?.platform_revenue || 0),
            expert_payable: parseFloat(revenue[0]?.expert_payable || 0),
            refunds_deducted: completedRefunds,
            net: netRevenue,
            transactions: {
                successful: parseInt(revenue[0]?.successful_transactions || 0),
                failed: parseInt(revenue[0]?.failed_transactions || 0),
                avg_amount: parseFloat(revenue[0]?.avg_transaction || 0)
            }
        },
        liabilities: {
            pending_payouts: parseFloat(payouts[0]?.pending_payouts || 0),
            pending_payouts_count: parseInt(payouts[0]?.pending_count || 0),
            pending_refunds: parseFloat(refunds[0]?.pending_refunds || 0),
            pending_refunds_count: parseInt(refunds[0]?.pending_count || 0),
            total_pending: parseFloat(payouts[0]?.pending_payouts || 0) + parseFloat(refunds[0]?.pending_refunds || 0)
        },
        wallets: {
            total_balance: parseFloat(wallets[0]?.total_balance || 0),
            wallet_count: parseInt(wallets[0]?.wallet_count || 0),
            avg_balance: parseFloat(wallets[0]?.avg_balance || 0),
            max_balance: parseFloat(wallets[0]?.max_balance || 0)
        },
        daily_trend: dailyRevenue.map(d => ({
            date: d.date,
            revenue: parseFloat(d.revenue),
            transactions: parseInt(d.transactions)
        })),
        health_indicators: {
            refund_rate: grossRevenue > 0
                ? ((completedRefunds / grossRevenue) * 100).toFixed(2) + '%' : '0%',
            payout_pending_ratio: parseFloat(revenue[0]?.expert_payable || 0) > 0
                ? ((parseFloat(payouts[0]?.pending_payouts || 0) / parseFloat(revenue[0]?.expert_payable || 0)) * 100).toFixed(2) + '%' : '0%'
        }
    });
});

// ============================================
// 5. CONTENT ENGAGEMENT ANALYTICS
// ============================================

export const getContentEngagementAnalytics = asyncHandler(async (req, res) => {
    const { days = 30 } = req.query;

    // Post engagement metrics
    const { rows: postEngagement } = await query(`
        SELECT 
            COUNT(p.id) as total_posts,
            COALESCE(SUM((SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id)), 0) as total_reactions,
            COALESCE(SUM((SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id)), 0) as total_comments,
            COALESCE(AVG((SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id)), 0) as avg_reactions_per_post,
            COALESCE(AVG((SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id)), 0) as avg_comments_per_post
        FROM app.posts p
        WHERE p.created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
    `);

    // Top engaging posts
    const { rows: topPosts } = await query(`
        SELECT 
            p.id,
            p.title,
            p.created_at,
            u.handle as author_handle,
            up.display_name as author_name,
            (SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id) as reactions,
            (SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id) as comments
        FROM app.posts p
        JOIN app.users u ON u.id = p.author_id
        LEFT JOIN app.user_profiles up ON up.user_id = p.author_id
        WHERE p.created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        ORDER BY (
            (SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id) +
            (SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id) * 2
        ) DESC
        LIMIT 10
    `);

    // Reaction breakdown
    const { rows: reactionBreakdown } = await query(`
        SELECT 
            kind,
            COUNT(*) as count
        FROM app.post_reactions
        WHERE created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'
        GROUP BY kind
        ORDER BY count DESC
    `);

    // Daily content activity
    const { rows: dailyActivity } = await query(`
        SELECT 
            DATE(created_at) as date,
            (SELECT COUNT(*) FROM app.posts WHERE DATE(created_at) = d.date) as posts,
            (SELECT COUNT(*) FROM app.comments WHERE DATE(created_at) = d.date) as comments,
            (SELECT COUNT(*) FROM app.post_reactions WHERE DATE(created_at) = d.date) as reactions
        FROM generate_series(
            CURRENT_DATE - INTERVAL '${parseInt(days)} days',
            CURRENT_DATE,
            '1 day'::interval
        ) as d(date)
        ORDER BY date ASC
    `);

    return success(res, "Content engagement analytics retrieved", {
        period: { days: parseInt(days) },
        overview: {
            total_posts: parseInt(postEngagement[0]?.total_posts || 0),
            total_reactions: parseInt(postEngagement[0]?.total_reactions || 0),
            total_comments: parseInt(postEngagement[0]?.total_comments || 0),
            avg_reactions_per_post: parseFloat(postEngagement[0]?.avg_reactions_per_post || 0).toFixed(2),
            avg_comments_per_post: parseFloat(postEngagement[0]?.avg_comments_per_post || 0).toFixed(2),
            engagement_rate: postEngagement[0]?.total_posts > 0
                ? (((parseInt(postEngagement[0]?.total_reactions || 0) + parseInt(postEngagement[0]?.total_comments || 0))
                    / parseInt(postEngagement[0]?.total_posts)) * 100).toFixed(2) + '%'
                : '0%'
        },
        top_posts: topPosts.map(p => ({
            id: p.id,
            title: p.title,
            author: p.author_name || p.author_handle,
            created_at: p.created_at,
            reactions: parseInt(p.reactions),
            comments: parseInt(p.comments),
            engagement_score: parseInt(p.reactions) + parseInt(p.comments) * 2
        })),
        reaction_breakdown: reactionBreakdown.map(r => ({
            type: r.kind,
            count: parseInt(r.count)
        })),
        daily_activity: dailyActivity.map(d => ({
            date: d.date,
            posts: parseInt(d.posts || 0),
            comments: parseInt(d.comments || 0),
            reactions: parseInt(d.reactions || 0)
        }))
    });
});

// ============================================
// 6. EXPORT ANALYTICS DATA
// ============================================

export const exportAnalyticsData = asyncHandler(async (req, res) => {
    const { type, format = 'json', days = 30 } = req.query;

    const validTypes = ['users', 'bookings', 'revenue', 'experts', 'content'];
    if (!type || !validTypes.includes(type)) {
        return failure(res, `Invalid type. Valid: ${validTypes.join(', ')}`, 400);
    }

    let data;
    const interval = parseInt(days);

    switch (type) {
        case 'users':
            const { rows: users } = await query(`
                SELECT u.id, u.handle, u.email, u.role_primary, u.status, u.created_at,
                       up.display_name, up.gender, up.year_of_birth
                FROM app.users u
                LEFT JOIN app.user_profiles up ON up.user_id = u.id
                WHERE u.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
                ORDER BY u.created_at DESC
            `);
            data = users;
            break;

        case 'bookings':
            const { rows: bookings } = await query(`
                SELECT b.id, b.user_id, b.expert_id, b.status, b.channel, b.price,
                       b.start_at, b.end_at, b.created_at
                FROM app.bookings b
                WHERE b.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
                ORDER BY b.created_at DESC
            `);
            data = bookings;
            break;

        case 'revenue':
            const { rows: payments } = await query(`
                SELECT pi.id, pi.booking_id, pi.amount, pi.status, pi.provider,
                       pi.created_at
                FROM app.payment_intents pi
                WHERE pi.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
                ORDER BY pi.created_at DESC
            `);
            data = payments;
            break;

        case 'experts':
            const { rows: experts } = await query(`
                SELECT u.id, u.handle, ep.specialties, ep.price_per_session,
                       ep.rating_avg, ep.kyc_status,
                       COUNT(b.id) as total_bookings,
                       COALESCE(SUM(b.price) FILTER (WHERE b.status = 'COMPLETED'), 0) as earnings
                FROM app.users u
                JOIN app.expert_profiles ep ON ep.user_id = u.id
                LEFT JOIN app.bookings b ON b.expert_id = u.id
                GROUP BY u.id, u.handle, ep.specialties, ep.price_per_session, ep.rating_avg, ep.kyc_status
            `);
            data = experts;
            break;

        case 'content':
            const { rows: posts } = await query(`
                SELECT p.id, p.author_id, p.title, p.privacy, p.created_at,
                       (SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id) as reactions,
                       (SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id) as comments
                FROM app.posts p
                WHERE p.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
                ORDER BY p.created_at DESC
            `);
            data = posts;
            break;
    }

    await AuditService.logAction({
        userId: req.user.id,
        action: "ANALYTICS_EXPORTED",
        meta: { type, format, days: interval, records: data.length },
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    if (format === 'csv') {
        // Convert to CSV
        if (data.length === 0) {
            return res.status(200).send('');
        }
        const headers = Object.keys(data[0]).join(',');
        const rows = data.map(row =>
            Object.values(row).map(v =>
                typeof v === 'string' ? `"${v.replace(/"/g, '""')}"` : v
            ).join(',')
        );
        const csv = [headers, ...rows].join('\n');

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=${type}_export_${Date.now()}.csv`);
        return res.send(csv);
    }

    return success(res, "Analytics data exported", {
        type,
        period: { days: interval },
        total_records: data.length,
        data
    });
});

// ============================================
// 7. ALERTS & ANOMALY DETECTION
// ============================================

export const getAnomalyAlerts = asyncHandler(async (req, res) => {
    const alerts = [];

    // Check for unusual refund rate
    const { rows: refundRate } = await query(`
        SELECT 
            COUNT(*) FILTER (WHERE status = 'COMPLETED') as refunds,
            (SELECT COUNT(*) FROM app.payment_intents WHERE status = 'PAID' 
             AND created_at >= CURRENT_DATE - INTERVAL '7 days') as payments
        FROM app.refunds
        WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
    `);

    const refundRatio = refundRate[0]?.payments > 0
        ? (refundRate[0]?.refunds / refundRate[0]?.payments) * 100 : 0;
    if (refundRatio > 10) {
        alerts.push({
            type: 'HIGH_REFUND_RATE',
            severity: 'warning',
            message: `Refund rate is ${refundRatio.toFixed(1)}% (threshold: 10%)`,
            value: refundRatio.toFixed(1) + '%'
        });
    }

    // Check for pending payouts backlog
    const { rows: payoutBacklog } = await query(`
        SELECT COUNT(*) as pending, COALESCE(SUM(amount), 0) as amount
        FROM app.payout_requests
        WHERE status = 'PENDING' AND created_at < CURRENT_DATE - INTERVAL '3 days'
    `);

    if (parseInt(payoutBacklog[0]?.pending || 0) > 10) {
        alerts.push({
            type: 'PAYOUT_BACKLOG',
            severity: 'warning',
            message: `${payoutBacklog[0]?.pending} payouts pending for more than 3 days`,
            value: parseInt(payoutBacklog[0]?.pending)
        });
    }

    // Check for high report volume
    const { rows: reportVolume } = await query(`
        SELECT COUNT(*) as today_reports
        FROM app.reports
        WHERE created_at >= CURRENT_DATE
    `);

    if (parseInt(reportVolume[0]?.today_reports || 0) > 50) {
        alerts.push({
            type: 'HIGH_REPORT_VOLUME',
            severity: 'info',
            message: `${reportVolume[0]?.today_reports} reports today (unusual activity)`,
            value: parseInt(reportVolume[0]?.today_reports)
        });
    }

    // Check for open disputes
    const { rows: openDisputes } = await query(`
        SELECT COUNT(*) as open_disputes
        FROM app.disputes
        WHERE status IN ('OPEN', 'UNDER_REVIEW')
    `);

    if (parseInt(openDisputes[0]?.open_disputes || 0) > 20) {
        alerts.push({
            type: 'HIGH_OPEN_DISPUTES',
            severity: 'warning',
            message: `${openDisputes[0]?.open_disputes} open disputes need attention`,
            value: parseInt(openDisputes[0]?.open_disputes)
        });
    }

    return success(res, "Anomaly alerts retrieved", {
        timestamp: new Date().toISOString(),
        total_alerts: alerts.length,
        alerts
    });
});

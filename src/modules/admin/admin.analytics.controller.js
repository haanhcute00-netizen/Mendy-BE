// =============================================
// ADMIN ANALYTICS CONTROLLERS
// Enhanced Dashboard & Statistics
// =============================================

import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, failure } from "../../utils/response.js";
import * as AuditService from "./audit.repo.js";
import { query } from "../../config/db.js";

// ============================================
// COMPREHENSIVE DASHBOARD
// ============================================

export const getComprehensiveDashboard = asyncHandler(async (req, res) => {
    const { startDate, endDate, days = 7 } = req.query;

    let dateFilter = '';
    let dateParams = [];

    if (startDate && endDate) {
        dateFilter = `AND created_at >= $1 AND created_at <= $2`;
        dateParams = [startDate, endDate];
    } else {
        dateFilter = `AND created_at >= CURRENT_DATE - INTERVAL '${parseInt(days)} days'`;
    }

    // User Statistics
    const { rows: userStats } = await query(`
        SELECT 
            COUNT(*) as total_users,
            COUNT(*) FILTER (WHERE status = 'ACTIVE') as active_users,
            COUNT(*) FILTER (WHERE status = 'SUSPENDED') as suspended_users,
            COUNT(*) FILTER (WHERE status = 'DELETED') as deleted_users,
            COUNT(*) FILTER (WHERE role_primary = 'SEEKER') as seekers,
            COUNT(*) FILTER (WHERE role_primary = 'EXPERT') as experts,
            COUNT(*) FILTER (WHERE role_primary = 'LISTENER') as listeners,
            COUNT(*) FILTER (WHERE role_primary = 'ADMIN') as admins,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as new_today,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as new_this_week,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as new_this_month
        FROM app.users
    `);

    // Booking Statistics
    const { rows: bookingStats } = await query(`
        SELECT 
            COUNT(*) as total_bookings,
            COUNT(*) FILTER (WHERE status = 'PENDING') as pending,
            COUNT(*) FILTER (WHERE status = 'CONFIRMED') as confirmed,
            COUNT(*) FILTER (WHERE status = 'COMPLETED') as completed,
            COUNT(*) FILTER (WHERE status = 'CANCELLED') as cancelled,
            COUNT(*) FILTER (WHERE status = 'NOSHOW') as noshow,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as this_week,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as this_month,
            COALESCE(SUM(price), 0) as total_revenue,
            COALESCE(SUM(price) FILTER (WHERE status = 'COMPLETED'), 0) as completed_revenue,
            COALESCE(AVG(price), 0) as avg_booking_price
        FROM app.bookings
    `);

    // Payment Statistics
    const { rows: paymentStats } = await query(`
        SELECT 
            COUNT(*) as total_payments,
            COUNT(*) FILTER (WHERE status = 'PAID') as paid,
            COUNT(*) FILTER (WHERE status = 'PENDING') as pending,
            COUNT(*) FILTER (WHERE status = 'FAILED') as failed,
            COUNT(*) FILTER (WHERE status = 'REFUNDED') as refunded,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID'), 0) as total_paid_amount,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID' AND created_at >= CURRENT_DATE), 0) as today_revenue,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID' AND created_at >= CURRENT_DATE - INTERVAL '7 days'), 0) as week_revenue,
            COALESCE(SUM(amount) FILTER (WHERE status = 'PAID' AND created_at >= CURRENT_DATE - INTERVAL '30 days'), 0) as month_revenue
        FROM app.payment_intents
    `);

    // Expert Statistics
    const { rows: expertStats } = await query(`
        SELECT 
            COUNT(*) as total_experts,
            COUNT(*) FILTER (WHERE kyc_status = 'VERIFIED') as verified,
            COUNT(*) FILTER (WHERE kyc_status = 'PENDING') as pending_kyc,
            COUNT(*) FILTER (WHERE kyc_status = 'REJECTED') as rejected,
            COALESCE(AVG(rating_avg), 0) as avg_rating,
            COALESCE(AVG(price_per_session), 0) as avg_price,
            COALESCE(MIN(price_per_session), 0) as min_price,
            COALESCE(MAX(price_per_session), 0) as max_price
        FROM app.expert_profiles
    `);

    // Content Statistics
    const { rows: contentStats } = await query(`
        SELECT 
            (SELECT COUNT(*) FROM app.posts) as total_posts,
            (SELECT COUNT(*) FROM app.posts WHERE created_at >= CURRENT_DATE) as posts_today,
            (SELECT COUNT(*) FROM app.posts WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as posts_week,
            (SELECT COUNT(*) FROM app.comments) as total_comments,
            (SELECT COUNT(*) FROM app.comments WHERE created_at >= CURRENT_DATE) as comments_today,
            (SELECT COUNT(*) FROM app.reviews) as total_reviews,
            (SELECT COALESCE(AVG(rating), 0) FROM app.reviews) as avg_review_rating
    `);

    // Moderation Statistics
    const { rows: moderationStats } = await query(`
        SELECT 
            COUNT(*) as total_reports,
            COUNT(*) FILTER (WHERE status = 'PENDING') as pending_reports,
            COUNT(*) FILTER (WHERE status = 'RESOLVED') as resolved_reports,
            COUNT(*) FILTER (WHERE status = 'DISMISSED') as dismissed_reports,
            COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as reports_today
        FROM app.reports
    `);

    // Financial Statistics
    const { rows: financialStats } = await query(`
        SELECT 
            (SELECT COALESCE(SUM(balance), 0) FROM app.wallets) as total_wallet_balance,
            (SELECT COUNT(*) FROM app.payout_requests WHERE status = 'PENDING') as pending_payouts,
            (SELECT COALESCE(SUM(amount), 0) FROM app.payout_requests WHERE status = 'PENDING') as pending_payout_amount,
            (SELECT COUNT(*) FROM app.refunds WHERE status = 'PENDING') as pending_refunds,
            (SELECT COALESCE(SUM(amount), 0) FROM app.refunds WHERE status = 'PENDING') as pending_refund_amount,
            (SELECT COUNT(*) FROM app.disputes WHERE status IN ('OPEN', 'UNDER_REVIEW')) as open_disputes
    `);

    // Communication Statistics
    const { rows: commStats } = await query(`
        SELECT 
            (SELECT COUNT(*) FROM app.chat_threads) as total_chat_threads,
            (SELECT COUNT(*) FROM app.chat_messages) as total_messages,
            (SELECT COUNT(*) FROM app.chat_messages WHERE created_at >= CURRENT_DATE) as messages_today,
            (SELECT COUNT(*) FROM app.call_sessions) as total_calls,
            (SELECT COUNT(*) FROM app.call_sessions WHERE started_at >= CURRENT_DATE) as calls_today,
            (SELECT COUNT(*) FROM app.call_sessions WHERE status = 'ENDED') as completed_calls
    `);

    await AuditService.logAction({
        userId: req.user.id,
        action: "COMPREHENSIVE_DASHBOARD_VIEWED",
        ip: req.ip,
        agent: req.get("User-Agent")
    });

    return success(res, "Comprehensive dashboard retrieved", {
        period: { days: parseInt(days), startDate, endDate },
        users: {
            total: parseInt(userStats[0].total_users),
            active: parseInt(userStats[0].active_users),
            suspended: parseInt(userStats[0].suspended_users),
            deleted: parseInt(userStats[0].deleted_users),
            by_role: {
                seekers: parseInt(userStats[0].seekers),
                experts: parseInt(userStats[0].experts),
                listeners: parseInt(userStats[0].listeners),
                admins: parseInt(userStats[0].admins)
            },
            growth: {
                today: parseInt(userStats[0].new_today),
                this_week: parseInt(userStats[0].new_this_week),
                this_month: parseInt(userStats[0].new_this_month)
            }
        },
        bookings: {
            total: parseInt(bookingStats[0].total_bookings),
            by_status: {
                pending: parseInt(bookingStats[0].pending),
                confirmed: parseInt(bookingStats[0].confirmed),
                completed: parseInt(bookingStats[0].completed),
                cancelled: parseInt(bookingStats[0].cancelled),
                noshow: parseInt(bookingStats[0].noshow)
            },
            period: {
                today: parseInt(bookingStats[0].today),
                this_week: parseInt(bookingStats[0].this_week),
                this_month: parseInt(bookingStats[0].this_month)
            },
            revenue: {
                total: parseFloat(bookingStats[0].total_revenue),
                completed: parseFloat(bookingStats[0].completed_revenue),
                average: parseFloat(bookingStats[0].avg_booking_price)
            }
        },
        payments: {
            total: parseInt(paymentStats[0].total_payments),
            by_status: {
                paid: parseInt(paymentStats[0].paid),
                pending: parseInt(paymentStats[0].pending),
                failed: parseInt(paymentStats[0].failed),
                refunded: parseInt(paymentStats[0].refunded)
            },
            revenue: {
                total: parseFloat(paymentStats[0].total_paid_amount),
                today: parseFloat(paymentStats[0].today_revenue),
                this_week: parseFloat(paymentStats[0].week_revenue),
                this_month: parseFloat(paymentStats[0].month_revenue)
            }
        },
        experts: {
            total: parseInt(expertStats[0].total_experts),
            verified: parseInt(expertStats[0].verified),
            pending_kyc: parseInt(expertStats[0].pending_kyc),
            rejected: parseInt(expertStats[0].rejected),
            pricing: {
                average: parseFloat(expertStats[0].avg_price),
                min: parseFloat(expertStats[0].min_price),
                max: parseFloat(expertStats[0].max_price)
            },
            avg_rating: parseFloat(expertStats[0].avg_rating)
        },
        content: {
            posts: {
                total: parseInt(contentStats[0].total_posts),
                today: parseInt(contentStats[0].posts_today),
                this_week: parseInt(contentStats[0].posts_week)
            },
            comments: {
                total: parseInt(contentStats[0].total_comments),
                today: parseInt(contentStats[0].comments_today)
            },
            reviews: {
                total: parseInt(contentStats[0].total_reviews),
                avg_rating: parseFloat(contentStats[0].avg_review_rating)
            }
        },
        moderation: {
            reports: {
                total: parseInt(moderationStats[0].total_reports),
                pending: parseInt(moderationStats[0].pending_reports),
                resolved: parseInt(moderationStats[0].resolved_reports),
                dismissed: parseInt(moderationStats[0].dismissed_reports),
                today: parseInt(moderationStats[0].reports_today)
            }
        },
        financial: {
            wallet_balance_total: parseFloat(financialStats[0].total_wallet_balance),
            payouts: {
                pending_count: parseInt(financialStats[0].pending_payouts),
                pending_amount: parseFloat(financialStats[0].pending_payout_amount)
            },
            refunds: {
                pending_count: parseInt(financialStats[0].pending_refunds),
                pending_amount: parseFloat(financialStats[0].pending_refund_amount)
            },
            disputes: {
                open: parseInt(financialStats[0].open_disputes)
            }
        },
        communication: {
            chat: {
                threads: parseInt(commStats[0].total_chat_threads),
                messages_total: parseInt(commStats[0].total_messages),
                messages_today: parseInt(commStats[0].messages_today)
            },
            calls: {
                total: parseInt(commStats[0].total_calls),
                today: parseInt(commStats[0].calls_today),
                completed: parseInt(commStats[0].completed_calls)
            }
        }
    });
});

// ============================================
// TIME SERIES ANALYTICS
// ============================================

export const getTimeSeriesAnalytics = asyncHandler(async (req, res) => {
    const { metric, days = 30, groupBy = 'day' } = req.query;

    const validMetrics = ['users', 'bookings', 'revenue', 'posts', 'reports'];
    if (metric && !validMetrics.includes(metric)) {
        return failure(res, `Invalid metric. Valid: ${validMetrics.join(', ')}`, 400);
    }

    const interval = parseInt(days);
    let dateFormat = 'YYYY-MM-DD';
    let dateTrunc = 'day';

    if (groupBy === 'hour') {
        dateTrunc = 'hour';
        dateFormat = 'YYYY-MM-DD HH24:00';
    } else if (groupBy === 'week') {
        dateTrunc = 'week';
    } else if (groupBy === 'month') {
        dateTrunc = 'month';
        dateFormat = 'YYYY-MM';
    }

    const results = {};

    // Users time series
    if (!metric || metric === 'users') {
        const { rows } = await query(`
            SELECT 
                DATE_TRUNC('${dateTrunc}', created_at) as date,
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE role_primary = 'SEEKER') as seekers,
                COUNT(*) FILTER (WHERE role_primary = 'EXPERT') as experts,
                COUNT(*) FILTER (WHERE role_primary = 'LISTENER') as listeners
            FROM app.users
            WHERE created_at >= CURRENT_DATE - INTERVAL '${interval} days'
            GROUP BY DATE_TRUNC('${dateTrunc}', created_at)
            ORDER BY date ASC
        `);
        results.users = rows.map(r => ({
            date: r.date,
            total: parseInt(r.total),
            seekers: parseInt(r.seekers),
            experts: parseInt(r.experts),
            listeners: parseInt(r.listeners)
        }));
    }

    // Bookings time series
    if (!metric || metric === 'bookings') {
        const { rows } = await query(`
            SELECT 
                DATE_TRUNC('${dateTrunc}', created_at) as date,
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE status = 'COMPLETED') as completed,
                COUNT(*) FILTER (WHERE status = 'CANCELLED') as cancelled,
                COALESCE(SUM(price), 0) as revenue
            FROM app.bookings
            WHERE created_at >= CURRENT_DATE - INTERVAL '${interval} days'
            GROUP BY DATE_TRUNC('${dateTrunc}', created_at)
            ORDER BY date ASC
        `);
        results.bookings = rows.map(r => ({
            date: r.date,
            total: parseInt(r.total),
            completed: parseInt(r.completed),
            cancelled: parseInt(r.cancelled),
            revenue: parseFloat(r.revenue)
        }));
    }

    // Revenue time series
    if (!metric || metric === 'revenue') {
        const { rows } = await query(`
            SELECT 
                DATE_TRUNC('${dateTrunc}', created_at) as date,
                COUNT(*) as transactions,
                COALESCE(SUM(amount) FILTER (WHERE status = 'PAID'), 0) as revenue,
                COALESCE(AVG(amount) FILTER (WHERE status = 'PAID'), 0) as avg_amount
            FROM app.payment_intents
            WHERE created_at >= CURRENT_DATE - INTERVAL '${interval} days'
            GROUP BY DATE_TRUNC('${dateTrunc}', created_at)
            ORDER BY date ASC
        `);
        results.revenue = rows.map(r => ({
            date: r.date,
            transactions: parseInt(r.transactions),
            revenue: parseFloat(r.revenue),
            avg_amount: parseFloat(r.avg_amount)
        }));
    }

    // Posts time series
    if (!metric || metric === 'posts') {
        const { rows } = await query(`
            SELECT 
                DATE_TRUNC('${dateTrunc}', created_at) as date,
                COUNT(*) as posts,
                (SELECT COUNT(*) FROM app.comments c WHERE DATE_TRUNC('${dateTrunc}', c.created_at) = DATE_TRUNC('${dateTrunc}', p.created_at)) as comments
            FROM app.posts p
            WHERE created_at >= CURRENT_DATE - INTERVAL '${interval} days'
            GROUP BY DATE_TRUNC('${dateTrunc}', created_at)
            ORDER BY date ASC
        `);
        results.posts = rows.map(r => ({
            date: r.date,
            posts: parseInt(r.posts),
            comments: parseInt(r.comments || 0)
        }));
    }

    // Reports time series
    if (!metric || metric === 'reports') {
        const { rows } = await query(`
            SELECT 
                DATE_TRUNC('${dateTrunc}', created_at) as date,
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE target_type = 'POST') as post_reports,
                COUNT(*) FILTER (WHERE target_type = 'COMMENT') as comment_reports,
                COUNT(*) FILTER (WHERE target_type = 'USER') as user_reports
            FROM app.reports
            WHERE created_at >= CURRENT_DATE - INTERVAL '${interval} days'
            GROUP BY DATE_TRUNC('${dateTrunc}', created_at)
            ORDER BY date ASC
        `);
        results.reports = rows.map(r => ({
            date: r.date,
            total: parseInt(r.total),
            post_reports: parseInt(r.post_reports),
            comment_reports: parseInt(r.comment_reports),
            user_reports: parseInt(r.user_reports)
        }));
    }

    return success(res, "Time series analytics retrieved", {
        period: { days: interval, groupBy },
        data: results
    });
});

// ============================================
// TOP PERFORMERS & RANKINGS
// ============================================

export const getTopPerformers = asyncHandler(async (req, res) => {
    const { limit = 10, days = 30 } = req.query;
    const interval = parseInt(days);
    const topLimit = parseInt(limit);

    // Top Experts by bookings
    const { rows: topExperts } = await query(`
        SELECT 
            u.id, u.handle, up.display_name, up.avatar_url,
            ep.rating_avg, ep.price_per_session,
            COUNT(b.id) as booking_count,
            COUNT(b.id) FILTER (WHERE b.status = 'COMPLETED') as completed_bookings,
            COALESCE(SUM(b.price) FILTER (WHERE b.status = 'COMPLETED'), 0) as total_earnings
        FROM app.users u
        JOIN app.expert_profiles ep ON ep.user_id = u.id
        LEFT JOIN app.user_profiles up ON up.user_id = u.id
        LEFT JOIN app.bookings b ON b.expert_id = u.id AND b.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        WHERE ep.kyc_status = 'VERIFIED'
        GROUP BY u.id, u.handle, up.display_name, up.avatar_url, ep.rating_avg, ep.price_per_session
        ORDER BY completed_bookings DESC, total_earnings DESC
        LIMIT $1
    `, [topLimit]);

    // Top Seekers by bookings
    const { rows: topSeekers } = await query(`
        SELECT 
            u.id, u.handle, up.display_name, up.avatar_url,
            COUNT(b.id) as booking_count,
            COUNT(b.id) FILTER (WHERE b.status = 'COMPLETED') as completed_bookings,
            COALESCE(SUM(b.price), 0) as total_spent
        FROM app.users u
        LEFT JOIN app.user_profiles up ON up.user_id = u.id
        LEFT JOIN app.bookings b ON b.user_id = u.id AND b.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        WHERE u.role_primary = 'SEEKER'
        GROUP BY u.id, u.handle, up.display_name, up.avatar_url
        HAVING COUNT(b.id) > 0
        ORDER BY completed_bookings DESC, total_spent DESC
        LIMIT $1
    `, [topLimit]);

    // Top Content Creators
    const { rows: topCreators } = await query(`
        SELECT 
            u.id, u.handle, up.display_name, up.avatar_url,
            COUNT(p.id) as post_count,
            COALESCE(SUM((SELECT COUNT(*) FROM app.post_reactions pr WHERE pr.post_id = p.id)), 0) as total_reactions,
            COALESCE(SUM((SELECT COUNT(*) FROM app.comments c WHERE c.post_id = p.id)), 0) as total_comments
        FROM app.users u
        LEFT JOIN app.user_profiles up ON up.user_id = u.id
        LEFT JOIN app.posts p ON p.author_id = u.id AND p.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        GROUP BY u.id, u.handle, up.display_name, up.avatar_url
        HAVING COUNT(p.id) > 0
        ORDER BY post_count DESC, total_reactions DESC
        LIMIT $1
    `, [topLimit]);

    // Most Reported Users
    const { rows: mostReported } = await query(`
        SELECT 
            u.id, u.handle, up.display_name, u.status,
            COUNT(r.id) as report_count,
            array_agg(DISTINCT r.reason) as report_reasons
        FROM app.users u
        LEFT JOIN app.user_profiles up ON up.user_id = u.id
        JOIN app.reports r ON r.target_type = 'USER' AND r.target_id = u.id
        WHERE r.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        GROUP BY u.id, u.handle, up.display_name, u.status
        ORDER BY report_count DESC
        LIMIT $1
    `, [topLimit]);

    return success(res, "Top performers retrieved", {
        period: { days: interval },
        top_experts: topExperts.map(e => ({
            id: e.id,
            handle: e.handle,
            display_name: e.display_name,
            avatar_url: e.avatar_url,
            rating: parseFloat(e.rating_avg) || 0,
            price_per_session: parseFloat(e.price_per_session),
            bookings: parseInt(e.booking_count),
            completed: parseInt(e.completed_bookings),
            earnings: parseFloat(e.total_earnings)
        })),
        top_seekers: topSeekers.map(s => ({
            id: s.id,
            handle: s.handle,
            display_name: s.display_name,
            avatar_url: s.avatar_url,
            bookings: parseInt(s.booking_count),
            completed: parseInt(s.completed_bookings),
            total_spent: parseFloat(s.total_spent)
        })),
        top_content_creators: topCreators.map(c => ({
            id: c.id,
            handle: c.handle,
            display_name: c.display_name,
            avatar_url: c.avatar_url,
            posts: parseInt(c.post_count),
            reactions: parseInt(c.total_reactions),
            comments: parseInt(c.total_comments)
        })),
        most_reported_users: mostReported.map(r => ({
            id: r.id,
            handle: r.handle,
            display_name: r.display_name,
            status: r.status,
            report_count: parseInt(r.report_count),
            reasons: r.report_reasons
        }))
    });
});

// ============================================
// REVENUE BREAKDOWN
// ============================================

export const getRevenueBreakdown = asyncHandler(async (req, res) => {
    const { startDate, endDate, days = 30 } = req.query;
    const interval = parseInt(days);

    // Revenue by payment method
    const { rows: byMethod } = await query(`
        SELECT 
            COALESCE(provider, 'UNKNOWN') as method,
            COUNT(*) as transactions,
            COALESCE(SUM(amount), 0) as total_amount
        FROM app.payment_intents
        WHERE status = 'PAID' AND created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        GROUP BY provider
        ORDER BY total_amount DESC
    `);

    // Revenue by expert specialty (top categories)
    const { rows: bySpecialty } = await query(`
        SELECT 
            unnest(ep.specialties) as specialty,
            COUNT(b.id) as bookings,
            COALESCE(SUM(b.price), 0) as revenue
        FROM app.bookings b
        JOIN app.expert_profiles ep ON ep.user_id = b.expert_id
        WHERE b.status = 'COMPLETED' AND b.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        GROUP BY unnest(ep.specialties)
        ORDER BY revenue DESC
        LIMIT 10
    `);

    // Revenue by booking channel
    const { rows: byChannel } = await query(`
        SELECT 
            channel,
            COUNT(*) as bookings,
            COALESCE(SUM(price), 0) as revenue,
            COALESCE(AVG(price), 0) as avg_price
        FROM app.bookings
        WHERE status = 'COMPLETED' AND created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        GROUP BY channel
        ORDER BY revenue DESC
    `);

    // Revenue summary (platform_fee không tồn tại trong payment_intents, tính từ bookings)
    const { rows: revenueSummary } = await query(`
        SELECT 
            COALESCE(SUM(pi.amount), 0) as gross_revenue,
            COALESCE(SUM(pi.amount * 0.15), 0) as estimated_platform_fees,
            COALESCE(SUM(pi.amount * 0.85), 0) as estimated_expert_earnings
        FROM app.payment_intents pi
        WHERE pi.status = 'PAID' AND pi.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
    `);

    // Refunds impact
    const { rows: refundsImpact } = await query(`
        SELECT 
            COUNT(*) as refund_count,
            COALESCE(SUM(amount), 0) as refunded_amount,
            COALESCE(SUM(platform_fee_refunded), 0) as platform_fee_refunded
        FROM app.refunds
        WHERE status = 'COMPLETED' AND created_at >= CURRENT_DATE - INTERVAL '${interval} days'
    `);

    return success(res, "Revenue breakdown retrieved", {
        period: { days: interval, startDate, endDate },
        by_payment_method: byMethod.map(m => ({
            method: m.method,
            transactions: parseInt(m.transactions),
            amount: parseFloat(m.total_amount)
        })),
        by_specialty: bySpecialty.map(s => ({
            specialty: s.specialty,
            bookings: parseInt(s.bookings),
            revenue: parseFloat(s.revenue)
        })),
        by_channel: byChannel.map(c => ({
            channel: c.channel,
            bookings: parseInt(c.bookings),
            revenue: parseFloat(c.revenue),
            avg_price: parseFloat(c.avg_price)
        })),
        summary: {
            gross_revenue: parseFloat(revenueSummary[0]?.gross_revenue || 0),
            platform_fees_estimated: parseFloat(revenueSummary[0]?.estimated_platform_fees || 0),
            expert_earnings_estimated: parseFloat(revenueSummary[0]?.estimated_expert_earnings || 0),
            refunds: {
                count: parseInt(refundsImpact[0]?.refund_count || 0),
                amount: parseFloat(refundsImpact[0]?.refunded_amount || 0),
                platform_fee_refunded: parseFloat(refundsImpact[0]?.platform_fee_refunded || 0)
            },
            net_revenue_estimated: parseFloat(revenueSummary[0]?.estimated_platform_fees || 0) - parseFloat(refundsImpact[0]?.platform_fee_refunded || 0)
        }
    });
});


// ============================================
// USER GROWTH & RETENTION
// ============================================

export const getUserGrowthAnalytics = asyncHandler(async (req, res) => {
    const { days = 30 } = req.query;
    const interval = parseInt(days);

    // Daily signups
    const { rows: dailySignups } = await query(`
        SELECT 
            DATE(created_at) as date,
            COUNT(*) as signups,
            COUNT(*) FILTER (WHERE role_primary = 'SEEKER') as seekers,
            COUNT(*) FILTER (WHERE role_primary = 'EXPERT') as experts
        FROM app.users
        WHERE created_at >= CURRENT_DATE - INTERVAL '${interval} days'
        GROUP BY DATE(created_at)
        ORDER BY date ASC
    `);

    // User retention (users who made bookings after signup)
    const { rows: retention } = await query(`
        SELECT 
            COUNT(DISTINCT u.id) as total_users,
            COUNT(DISTINCT b.user_id) as users_with_bookings,
            COUNT(DISTINCT CASE WHEN b.status = 'COMPLETED' THEN b.user_id END) as users_completed_booking
        FROM app.users u
        LEFT JOIN app.bookings b ON b.user_id = u.id
        WHERE u.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
    `);

    // Expert conversion (users who became experts)
    const { rows: expertConversion } = await query(`
        SELECT 
            COUNT(*) as total_expert_signups,
            COUNT(*) FILTER (WHERE ep.kyc_status = 'VERIFIED') as verified,
            COUNT(*) FILTER (WHERE ep.kyc_status = 'PENDING') as pending,
            COUNT(*) FILTER (WHERE ep.kyc_status = 'REJECTED') as rejected
        FROM app.users u
        JOIN app.expert_profiles ep ON ep.user_id = u.id
        WHERE u.created_at >= CURRENT_DATE - INTERVAL '${interval} days'
    `);

    // Active users (users who logged in or made activity)
    const { rows: activeUsers } = await query(`
        SELECT 
            COUNT(DISTINCT user_id) as active_users
        FROM app.audit_logs
        WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
    `);

    return success(res, "User growth analytics retrieved", {
        period: { days: interval },
        daily_signups: dailySignups.map(d => ({
            date: d.date,
            total: parseInt(d.signups),
            seekers: parseInt(d.seekers),
            experts: parseInt(d.experts)
        })),
        retention: {
            total_new_users: parseInt(retention[0]?.total_users || 0),
            users_with_bookings: parseInt(retention[0]?.users_with_bookings || 0),
            users_completed_booking: parseInt(retention[0]?.users_completed_booking || 0),
            booking_rate: retention[0]?.total_users > 0
                ? ((retention[0]?.users_with_bookings / retention[0]?.total_users) * 100).toFixed(2) + '%'
                : '0%'
        },
        expert_conversion: {
            total: parseInt(expertConversion[0]?.total_expert_signups || 0),
            verified: parseInt(expertConversion[0]?.verified || 0),
            pending: parseInt(expertConversion[0]?.pending || 0),
            rejected: parseInt(expertConversion[0]?.rejected || 0),
            verification_rate: expertConversion[0]?.total_expert_signups > 0
                ? ((expertConversion[0]?.verified / expertConversion[0]?.total_expert_signups) * 100).toFixed(2) + '%'
                : '0%'
        },
        active_users_last_7_days: parseInt(activeUsers[0]?.active_users || 0)
    });
});


// ============================================
// BOOKING ANALYTICS DETAILED
// ============================================

export const getBookingAnalyticsDetailed = asyncHandler(async (req, res) => {
    const { days = 30, expertId, channel } = req.query;
    const interval = parseInt(days);

    let whereClause = `WHERE created_at >= CURRENT_DATE - INTERVAL '${interval} days'`;
    const params = [];
    let paramIndex = 1;

    if (expertId) {
        whereClause += ` AND expert_id = $${paramIndex++}`;
        params.push(parseInt(expertId));
    }
    if (channel) {
        whereClause += ` AND channel = $${paramIndex++}`;
        params.push(channel);
    }

    // Booking funnel
    const { rows: funnel } = await query(`
        SELECT 
            COUNT(*) as total_created,
            COUNT(*) FILTER (WHERE status != 'PENDING') as confirmed_or_processed,
            COUNT(*) FILTER (WHERE status = 'COMPLETED') as completed,
            COUNT(*) FILTER (WHERE status = 'CANCELLED') as cancelled,
            COUNT(*) FILTER (WHERE status = 'NOSHOW') as noshow
        FROM app.bookings
        ${whereClause}
    `, params);

    // Booking by hour of day
    const { rows: byHour } = await query(`
        SELECT 
            EXTRACT(HOUR FROM start_at) as hour,
            COUNT(*) as bookings
        FROM app.bookings
        ${whereClause}
        GROUP BY EXTRACT(HOUR FROM start_at)
        ORDER BY hour
    `, params);

    // Booking by day of week
    const { rows: byDayOfWeek } = await query(`
        SELECT 
            EXTRACT(DOW FROM start_at) as day_of_week,
            COUNT(*) as bookings
        FROM app.bookings
        ${whereClause}
        GROUP BY EXTRACT(DOW FROM start_at)
        ORDER BY day_of_week
    `, params);

    // Average booking duration
    const { rows: duration } = await query(`
        SELECT 
            AVG(EXTRACT(EPOCH FROM (end_at - start_at))/60) as avg_duration_minutes,
            MIN(EXTRACT(EPOCH FROM (end_at - start_at))/60) as min_duration_minutes,
            MAX(EXTRACT(EPOCH FROM (end_at - start_at))/60) as max_duration_minutes
        FROM app.bookings
        ${whereClause}
    `, params);

    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    return success(res, "Booking analytics retrieved", {
        period: { days: interval, expertId, channel },
        funnel: {
            created: parseInt(funnel[0]?.total_created || 0),
            processed: parseInt(funnel[0]?.confirmed_or_processed || 0),
            completed: parseInt(funnel[0]?.completed || 0),
            cancelled: parseInt(funnel[0]?.cancelled || 0),
            noshow: parseInt(funnel[0]?.noshow || 0),
            completion_rate: funnel[0]?.total_created > 0
                ? ((funnel[0]?.completed / funnel[0]?.total_created) * 100).toFixed(2) + '%'
                : '0%',
            cancellation_rate: funnel[0]?.total_created > 0
                ? ((funnel[0]?.cancelled / funnel[0]?.total_created) * 100).toFixed(2) + '%'
                : '0%'
        },
        by_hour: byHour.map(h => ({
            hour: parseInt(h.hour),
            bookings: parseInt(h.bookings)
        })),
        by_day_of_week: byDayOfWeek.map(d => ({
            day: dayNames[parseInt(d.day_of_week)],
            day_number: parseInt(d.day_of_week),
            bookings: parseInt(d.bookings)
        })),
        duration: {
            average_minutes: parseFloat(duration[0]?.avg_duration_minutes || 0).toFixed(2),
            min_minutes: parseFloat(duration[0]?.min_duration_minutes || 0).toFixed(2),
            max_minutes: parseFloat(duration[0]?.max_duration_minutes || 0).toFixed(2)
        }
    });
});


// ============================================
// REAL-TIME METRICS
// ============================================

export const getRealTimeMetrics = asyncHandler(async (req, res) => {
    // Last 24 hours metrics
    const { rows: last24h } = await query(`
        SELECT 
            (SELECT COUNT(*) FROM app.users WHERE created_at >= NOW() - INTERVAL '24 hours') as new_users_24h,
            (SELECT COUNT(*) FROM app.bookings WHERE created_at >= NOW() - INTERVAL '24 hours') as new_bookings_24h,
            (SELECT COUNT(*) FROM app.bookings WHERE status = 'COMPLETED' AND created_at >= NOW() - INTERVAL '24 hours') as completed_24h,
            (SELECT COALESCE(SUM(amount), 0) FROM app.payment_intents WHERE status = 'PAID' AND created_at >= NOW() - INTERVAL '24 hours') as revenue_24h,
            (SELECT COUNT(*) FROM app.posts WHERE created_at >= NOW() - INTERVAL '24 hours') as new_posts_24h,
            (SELECT COUNT(*) FROM app.chat_messages WHERE created_at >= NOW() - INTERVAL '24 hours') as messages_24h,
            (SELECT COUNT(*) FROM app.reports WHERE created_at >= NOW() - INTERVAL '24 hours') as reports_24h
    `);

    // Last hour metrics
    const { rows: lastHour } = await query(`
        SELECT 
            (SELECT COUNT(*) FROM app.users WHERE created_at >= NOW() - INTERVAL '1 hour') as new_users_1h,
            (SELECT COUNT(*) FROM app.bookings WHERE created_at >= NOW() - INTERVAL '1 hour') as new_bookings_1h,
            (SELECT COALESCE(SUM(amount), 0) FROM app.payment_intents WHERE status = 'PAID' AND created_at >= NOW() - INTERVAL '1 hour') as revenue_1h
    `);

    // Currently active (approximate based on recent activity)
    const { rows: active } = await query(`
        SELECT 
            (SELECT COUNT(DISTINCT user_id) FROM app.audit_logs WHERE created_at >= NOW() - INTERVAL '15 minutes') as active_users_15m,
            (SELECT COUNT(*) FROM app.call_sessions WHERE status IN ('INIT', 'RINGING', 'CONNECTED')) as ongoing_calls,
            (SELECT COUNT(*) FROM app.bookings WHERE status = 'CONFIRMED' AND start_at <= NOW() AND end_at >= NOW()) as ongoing_sessions
    `);

    return success(res, "Real-time metrics retrieved", {
        timestamp: new Date().toISOString(),
        last_24_hours: {
            new_users: parseInt(last24h[0]?.new_users_24h || 0),
            new_bookings: parseInt(last24h[0]?.new_bookings_24h || 0),
            completed_bookings: parseInt(last24h[0]?.completed_24h || 0),
            revenue: parseFloat(last24h[0]?.revenue_24h || 0),
            new_posts: parseInt(last24h[0]?.new_posts_24h || 0),
            messages: parseInt(last24h[0]?.messages_24h || 0),
            reports: parseInt(last24h[0]?.reports_24h || 0)
        },
        last_hour: {
            new_users: parseInt(lastHour[0]?.new_users_1h || 0),
            new_bookings: parseInt(lastHour[0]?.new_bookings_1h || 0),
            revenue: parseFloat(lastHour[0]?.revenue_1h || 0)
        },
        currently_active: {
            users_last_15m: parseInt(active[0]?.active_users_15m || 0),
            ongoing_calls: parseInt(active[0]?.ongoing_calls || 0),
            ongoing_sessions: parseInt(active[0]?.ongoing_sessions || 0)
        }
    });
});

// ============================================
// COMPARISON ANALYTICS
// ============================================

export const getComparisonAnalytics = asyncHandler(async (req, res) => {
    const { period = 'week' } = req.query;

    let currentInterval, previousInterval;
    if (period === 'day') {
        currentInterval = '1 day';
        previousInterval = '2 days';
    } else if (period === 'month') {
        currentInterval = '30 days';
        previousInterval = '60 days';
    } else {
        currentInterval = '7 days';
        previousInterval = '14 days';
    }

    // Current period
    const { rows: current } = await query(`
        SELECT 
            (SELECT COUNT(*) FROM app.users WHERE created_at >= NOW() - INTERVAL '${currentInterval}') as users,
            (SELECT COUNT(*) FROM app.bookings WHERE created_at >= NOW() - INTERVAL '${currentInterval}') as bookings,
            (SELECT COALESCE(SUM(amount), 0) FROM app.payment_intents WHERE status = 'PAID' AND created_at >= NOW() - INTERVAL '${currentInterval}') as revenue,
            (SELECT COUNT(*) FROM app.posts WHERE created_at >= NOW() - INTERVAL '${currentInterval}') as posts
    `);

    // Previous period
    const { rows: previous } = await query(`
        SELECT 
            (SELECT COUNT(*) FROM app.users WHERE created_at >= NOW() - INTERVAL '${previousInterval}' AND created_at < NOW() - INTERVAL '${currentInterval}') as users,
            (SELECT COUNT(*) FROM app.bookings WHERE created_at >= NOW() - INTERVAL '${previousInterval}' AND created_at < NOW() - INTERVAL '${currentInterval}') as bookings,
            (SELECT COALESCE(SUM(amount), 0) FROM app.payment_intents WHERE status = 'PAID' AND created_at >= NOW() - INTERVAL '${previousInterval}' AND created_at < NOW() - INTERVAL '${currentInterval}') as revenue,
            (SELECT COUNT(*) FROM app.posts WHERE created_at >= NOW() - INTERVAL '${previousInterval}' AND created_at < NOW() - INTERVAL '${currentInterval}') as posts
    `);

    const calcChange = (curr, prev) => {
        if (prev === 0) return curr > 0 ? '+100%' : '0%';
        const change = ((curr - prev) / prev * 100).toFixed(1);
        return change >= 0 ? `+${change}%` : `${change}%`;
    };

    return success(res, "Comparison analytics retrieved", {
        period,
        current_period: {
            users: parseInt(current[0]?.users || 0),
            bookings: parseInt(current[0]?.bookings || 0),
            revenue: parseFloat(current[0]?.revenue || 0),
            posts: parseInt(current[0]?.posts || 0)
        },
        previous_period: {
            users: parseInt(previous[0]?.users || 0),
            bookings: parseInt(previous[0]?.bookings || 0),
            revenue: parseFloat(previous[0]?.revenue || 0),
            posts: parseInt(previous[0]?.posts || 0)
        },
        changes: {
            users: calcChange(parseInt(current[0]?.users || 0), parseInt(previous[0]?.users || 0)),
            bookings: calcChange(parseInt(current[0]?.bookings || 0), parseInt(previous[0]?.bookings || 0)),
            revenue: calcChange(parseFloat(current[0]?.revenue || 0), parseFloat(previous[0]?.revenue || 0)),
            posts: calcChange(parseInt(current[0]?.posts || 0), parseInt(previous[0]?.posts || 0))
        }
    });
});

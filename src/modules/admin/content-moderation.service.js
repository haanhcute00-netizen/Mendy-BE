/**
 * Content Moderation Service
 * Phát hiện và kiểm duyệt nội dung vi phạm, scam
 */

// Danh sách từ khóa scam phổ biến
const SCAM_KEYWORDS = [
    // Tiếng Việt
    'chuyển khoản ngay', 'gửi tiền trước', 'đầu tư siêu lợi nhuận', 'lãi suất cao',
    'kiếm tiền nhanh', 'làm giàu nhanh', 'thu nhập khủng', 'không cần vốn',
    'cam kết hoàn tiền', 'miễn phí 100%', 'trúng thưởng', 'bạn đã trúng',
    'click vào link', 'nhấn link ngay', 'đăng ký ngay hôm nay', 'cơ hội cuối',
    'số lượng có hạn', 'chỉ còn hôm nay', 'ưu đãi đặc biệt', 'giảm giá sốc',
    'forex', 'binary option', 'tiền ảo', 'bitcoin x100', 'crypto x1000',
    'đa cấp', 'mlm', 'hệ thống tự động', 'thu nhập thụ động',
    'zalo', 'telegram', 'liên hệ qua', 'inbox ngay', 'dm để biết thêm',
    // English
    'send money first', 'wire transfer', 'guaranteed profit', 'risk free',
    'make money fast', 'get rich quick', 'limited time offer', 'act now',
    'click here', 'free money', 'you have won', 'congratulations winner',
    'investment opportunity', 'double your money', 'passive income guaranteed'
];

// Từ khóa nội dung vi phạm
const VIOLATION_KEYWORDS = [
    // Bạo lực, đe dọa
    'giết', 'chết đi', 'tự tử', 'tự sát', 'kết liễu', 'đâm chém',
    // Quấy rối, xúc phạm
    'ngu', 'đần', 'khốn', 'chó', 'lừa đảo', 'bịp bợm',
    // Nội dung người lớn
    'khỏa thân', 'sex', 'xxx', 'porn',
    // Thông tin cá nhân
    'số cmnd', 'số cccd', 'mật khẩu', 'password', 'otp'
];

// Pattern phát hiện link đáng ngờ
const SUSPICIOUS_PATTERNS = [
    /bit\.ly\/\w+/gi,
    /tinyurl\.com\/\w+/gi,
    /t\.me\/\w+/gi,
    /wa\.me\/\w+/gi,
    /zalo\.me\/\w+/gi,
    /\d{10,11}/g, // Số điện thoại
    /https?:\/\/[^\s]+\.(xyz|tk|ml|ga|cf|gq)/gi, // Domain đáng ngờ
];

/**
 * Phân tích nội dung để phát hiện vi phạm
 * @param {string} content - Nội dung cần kiểm tra
 * @returns {Object} Kết quả phân tích
 */
export function analyzeContent(content) {
    if (!content) return { isClean: true, score: 0, flags: [] };

    const lowerContent = content.toLowerCase();
    const flags = [];
    let score = 0;

    // Kiểm tra từ khóa scam
    const scamMatches = SCAM_KEYWORDS.filter(kw => lowerContent.includes(kw.toLowerCase()));
    if (scamMatches.length > 0) {
        score += scamMatches.length * 15;
        flags.push({
            type: 'SCAM',
            severity: scamMatches.length >= 3 ? 'HIGH' : 'MEDIUM',
            matches: scamMatches,
            message: 'Phát hiện từ khóa liên quan đến scam/lừa đảo'
        });
    }

    // Kiểm tra từ khóa vi phạm
    const violationMatches = VIOLATION_KEYWORDS.filter(kw => lowerContent.includes(kw.toLowerCase()));
    if (violationMatches.length > 0) {
        score += violationMatches.length * 20;
        flags.push({
            type: 'VIOLATION',
            severity: violationMatches.length >= 2 ? 'HIGH' : 'MEDIUM',
            matches: violationMatches,
            message: 'Phát hiện nội dung vi phạm quy định'
        });
    }

    // Kiểm tra pattern đáng ngờ
    const suspiciousMatches = [];
    for (const pattern of SUSPICIOUS_PATTERNS) {
        const matches = content.match(pattern);
        if (matches) {
            suspiciousMatches.push(...matches);
        }
    }
    if (suspiciousMatches.length > 0) {
        score += suspiciousMatches.length * 10;
        flags.push({
            type: 'SUSPICIOUS_LINK',
            severity: 'MEDIUM',
            matches: [...new Set(suspiciousMatches)],
            message: 'Phát hiện link/số điện thoại đáng ngờ'
        });
    }

    // Kiểm tra ALL CAPS (spam indicator)
    const capsRatio = (content.match(/[A-Z]/g) || []).length / content.length;
    if (capsRatio > 0.5 && content.length > 20) {
        score += 10;
        flags.push({
            type: 'SPAM_INDICATOR',
            severity: 'LOW',
            message: 'Nội dung có quá nhiều chữ in hoa'
        });
    }

    // Kiểm tra lặp ký tự (spam indicator)
    if (/(.)\1{4,}/g.test(content)) {
        score += 5;
        flags.push({
            type: 'SPAM_INDICATOR',
            severity: 'LOW',
            message: 'Nội dung có ký tự lặp lại nhiều lần'
        });
    }

    return {
        isClean: score < 20,
        score,
        riskLevel: score >= 50 ? 'HIGH' : score >= 30 ? 'MEDIUM' : score >= 20 ? 'LOW' : 'SAFE',
        flags,
        recommendation: score >= 50 ? 'REJECT' : score >= 30 ? 'REVIEW' : 'APPROVE'
    };
}

/**
 * Kiểm tra bài đăng
 */
export function analyzePost(post) {
    const titleAnalysis = analyzeContent(post.title);
    const contentAnalysis = analyzeContent(post.content);

    const combinedScore = titleAnalysis.score + contentAnalysis.score;
    const allFlags = [...titleAnalysis.flags, ...contentAnalysis.flags];

    return {
        postId: post.id,
        title: post.title,
        isClean: combinedScore < 20,
        score: combinedScore,
        riskLevel: combinedScore >= 50 ? 'HIGH' : combinedScore >= 30 ? 'MEDIUM' : combinedScore >= 20 ? 'LOW' : 'SAFE',
        flags: allFlags,
        recommendation: combinedScore >= 50 ? 'REJECT' : combinedScore >= 30 ? 'REVIEW' : 'APPROVE',
        details: {
            title: titleAnalysis,
            content: contentAnalysis
        }
    };
}

export const MODERATION_STATUS = {
    PENDING: 'PENDING',
    APPROVED: 'APPROVED',
    REJECTED: 'REJECTED',
    FLAGGED: 'FLAGGED'
};

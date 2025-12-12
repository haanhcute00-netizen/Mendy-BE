// =============================================
// CRISIS DETECTION CONFIG (Task 10)
// =============================================

// ========== CRISIS KEYWORDS BY LEVEL ==========
export const CRISIS_KEYWORDS = {
    // Level 1: Critical - Immediate danger
    critical: [
        // Vietnamese
        "tự tử", "tự sát", "muốn chết", "kết thúc cuộc đời", "không muốn sống",
        "cắt tay", "tự làm hại", "tự gây thương tích",
        // English
        "suicide", "kill myself", "end my life", "want to die", "self-harm",
        "cut myself", "hurt myself"
    ],

    // Level 2: High - Serious concern
    high: [
        // Vietnamese
        "bạo lực", "đánh đập", "bị hành hạ", "bị lạm dụng",
        "không còn hy vọng", "tuyệt vọng", "không lối thoát",
        "quá đau khổ", "không chịu nổi nữa",
        // English
        "abuse", "violence", "hopeless", "no way out", "can't take it anymore",
        "beaten", "assaulted"
    ],

    // Level 3: Moderate - Needs attention
    moderate: [
        // Vietnamese
        "muốn biến mất", "không ai quan tâm", "cô đơn quá",
        "mệt mỏi với cuộc sống", "chán sống",
        // English
        "want to disappear", "nobody cares", "tired of living",
        "sick of life", "give up"
    ]
};

// ========== HOTLINE INFO ==========
export const CRISIS_HOTLINES = {
    vietnam: [
        {
            name: "Đường dây nóng tâm lý",
            number: "1800 599 913",
            description: "Miễn phí, 24/7",
            priority: 1
        },
        {
            name: "Bệnh viện Tâm thần Trung ương",
            number: "024 3826 3006",
            description: "Hà Nội",
            priority: 2
        },
        {
            name: "Bệnh viện Tâm thần TP.HCM",
            number: "028 3855 4269",
            description: "TP. Hồ Chí Minh",
            priority: 2
        },
        {
            name: "Tổng đài tư vấn sức khỏe tâm thần",
            number: "1800 599 920",
            description: "Miễn phí",
            priority: 1
        }
    ],
    international: [
        {
            name: "International Association for Suicide Prevention",
            url: "https://www.iasp.info/resources/Crisis_Centres/",
            description: "Find crisis centers worldwide"
        }
    ]
};

// ========== RESPONSE TEMPLATES ==========
export const CRISIS_RESPONSES = {
    critical: {
        vi: `Mình rất lo lắng cho bạn trong tình huống này. Đây cần sự hỗ trợ chuyên nghiệp khẩn cấp.

📞 Hãy liên hệ ngay:
• Đường dây nóng tâm lý: 1800 599 913 (miễn phí, 24/7)
• Bệnh viện Tâm thần TW: 024 3826 3006

Bạn không đơn độc. Luôn có người sẵn sàng giúp đỡ bạn. Mình ở đây lắng nghe bạn.`,

        en: `I'm very concerned about you right now. This situation needs immediate professional support.

📞 Please contact:
• Mental Health Hotline: 1800 599 913 (free, 24/7)
• Central Mental Hospital: 024 3826 3006

You are not alone. There are people ready to help you. I'm here to listen.`
    },

    high: {
        vi: `Mình nghe thấy bạn đang trải qua điều rất khó khăn. Cảm xúc của bạn hoàn toàn hợp lệ.

Mình nghĩ bạn nên nói chuyện với một chuyên gia có thể hỗ trợ bạn tốt hơn:
📞 Đường dây nóng: 1800 599 913 (miễn phí)

Bạn có muốn chia sẻ thêm với mình không?`,

        en: `I hear that you're going through something very difficult. Your feelings are completely valid.

I think you should talk to a professional who can better support you:
📞 Hotline: 1800 599 913 (free)

Would you like to share more with me?`
    },

    moderate: {
        vi: `Mình hiểu bạn đang cảm thấy rất nặng nề. Những cảm xúc này thật sự khó khăn.

Nếu bạn cần ai đó để nói chuyện, đường dây hỗ trợ tâm lý luôn sẵn sàng: 1800 599 913

Mình ở đây lắng nghe bạn. Bạn muốn chia sẻ điều gì đang xảy ra không?`,

        en: `I understand you're feeling very overwhelmed. These feelings are really difficult.

If you need someone to talk to, the mental health hotline is always available: 1800 599 913

I'm here to listen. Would you like to share what's happening?`
    }
};

// ========== HELPER FUNCTIONS ==========

export const detectCrisisLevel = (text) => {
    if (!text) return null;

    const lowerText = text.toLowerCase();

    // Check critical first
    for (const keyword of CRISIS_KEYWORDS.critical) {
        if (lowerText.includes(keyword.toLowerCase())) {
            return {
                level: 'critical',
                keyword,
                severity: 3
            };
        }
    }

    // Check high
    for (const keyword of CRISIS_KEYWORDS.high) {
        if (lowerText.includes(keyword.toLowerCase())) {
            return {
                level: 'high',
                keyword,
                severity: 2
            };
        }
    }

    // Check moderate
    for (const keyword of CRISIS_KEYWORDS.moderate) {
        if (lowerText.includes(keyword.toLowerCase())) {
            return {
                level: 'moderate',
                keyword,
                severity: 1
            };
        }
    }

    return null;
};

export const getCrisisResponse = (level, lang = 'vi') => {
    return CRISIS_RESPONSES[level]?.[lang] || CRISIS_RESPONSES.moderate.vi;
};

export const getHotlineInfo = (country = 'vietnam') => {
    return CRISIS_HOTLINES[country] || CRISIS_HOTLINES.vietnam;
};

export default {
    CRISIS_KEYWORDS,
    CRISIS_HOTLINES,
    CRISIS_RESPONSES,
    detectCrisisLevel,
    getCrisisResponse,
    getHotlineInfo
};

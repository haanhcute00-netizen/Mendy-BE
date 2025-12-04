// =============================================
// AI COMPANION - NOTIFICATION SERVICE
// =============================================

import * as notificationRepo from './notification.repo.js';
import * as personaRepo from '../persona/persona.repo.js';

// ========== NOTIFICATION TEMPLATES ==========

const MORNING_TEMPLATES = {
    mother: [
        'Chào buổi sáng con yêu! Hôm nay con có khỏe không?',
        'Con ơi, dậy chưa? Nhớ ăn sáng đầy đủ nha con.',
        'Sáng nay trời đẹp quá, mẹ chúc con một ngày tốt lành!'
    ],
    lover: [
        'Chào buổi sáng em/anh yêu! Ngủ có ngon không?',
        'Dậy chưa nè? Hôm nay nhớ giữ gìn sức khỏe nha!',
        'Good morning! Anh/em yêu bạn nhiều lắm đó 💕'
    ],
    bestfriend: [
        'Ê, dậy chưa đồ lười!',
        'Mày ơi, ngày mới rồi! Cố lên nha!',
        'Dậy đi con giời, còn bao nhiêu việc chờ mày kìa!'
    ],
    mentor: [
        'Chào buổi sáng! Hãy bắt đầu ngày mới với năng lượng tích cực.',
        'Một ngày mới, một cơ hội mới. Bạn sẵn sàng chưa?',
        'Good morning! Hôm nay bạn muốn đạt được điều gì?'
    ],
    pet: [
        'Gâu gâu! Chủ nhân dậy rồi! 🐶',
        'Meo meo~ Sáng rồi chủ nhân ơi! 🐱',
        '*vẫy đuôi* Chào buổi sáng chủ nhân yêu!'
    ]
};

const EVENING_TEMPLATES = {
    mother: [
        'Con ơi, tối rồi nhớ nghỉ ngơi sớm nha.',
        'Hôm nay con có mệt không? Nhớ đi ngủ sớm con nhé.',
        'Mẹ chúc con ngủ ngon, mơ đẹp nha con yêu.'
    ],
    lover: [
        'Tối rồi em/anh ơi, nghỉ ngơi đi nha!',
        'Ngủ ngon nha, mơ thấy anh/em nè 💕',
        'Hôm nay vất vả rồi, giờ là lúc thư giãn nha!'
    ],
    bestfriend: [
        'Ê, tối rồi đi ngủ đi!',
        'Thôi nghỉ đi, mai còn chiến tiếp!',
        'Đi ngủ đi con giời, thức khuya hại não lắm!'
    ],
    mentor: [
        'Một ngày đã qua. Hãy dành thời gian reflect và nghỉ ngơi.',
        'Bạn đã làm tốt lắm hôm nay. Giờ hãy cho bản thân nghỉ ngơi.',
        'Good night! Ngày mai sẽ là một ngày tuyệt vời.'
    ],
    pet: [
        '*ngáp* Chủ nhân ơi, đi ngủ thôi~ 🐶',
        'Meo meo, tối rồi, ngủ ngon nha chủ nhân! 🐱',
        '*cuộn tròn* Em buồn ngủ rồi, chủ nhân ngủ cùng em nha!'
    ]
};

const RANDOM_TEMPLATES = {
    mother: [
        'Con ơi, mẹ nhớ con quá!',
        'Con có uống đủ nước chưa?',
        'Mẹ luôn ở đây nếu con cần nha.'
    ],
    lover: [
        'Đang làm gì đó? Anh/em nhớ bạn quá!',
        'Chỉ muốn nói là anh/em yêu bạn thôi 💕',
        'Bạn có biết bạn tuyệt vời như thế nào không?'
    ],
    bestfriend: [
        'Ê, đang làm gì đấy?',
        'Tao nhớ mày quá, lâu rồi không nói chuyện!',
        'Có chuyện gì vui không kể tao nghe với!'
    ],
    mentor: [
        'Hãy nhớ: Bạn đang làm rất tốt.',
        'Đừng quên nghỉ ngơi giữa những lúc bận rộn.',
        'Một reminder nhỏ: Bạn xứng đáng được hạnh phúc.'
    ],
    pet: [
        '*vẫy đuôi* Em nhớ chủ nhân! 🐶',
        'Meo meo! Chủ nhân đang làm gì thế? 🐱',
        '*dụi đầu* Em yêu chủ nhân nhiều lắm!'
    ]
};

// ========== NOTIFICATION GENERATION ==========

const getTemplate = (templates, personaName, customNickname = null) => {
    const personaTemplates = templates[personaName] || templates.bestfriend;
    let message = personaTemplates[Math.floor(Math.random() * personaTemplates.length)];

    if (customNickname) {
        message = message.replace(/con |bạn |mày |chủ nhân /gi, `${customNickname} `);
    }

    return message;
};

export const generateMorningMessage = (personaName, customNickname = null) => {
    return getTemplate(MORNING_TEMPLATES, personaName, customNickname);
};

export const generateEveningMessage = (personaName, customNickname = null) => {
    return getTemplate(EVENING_TEMPLATES, personaName, customNickname);
};

export const generateRandomMessage = (personaName, customNickname = null) => {
    return getTemplate(RANDOM_TEMPLATES, personaName, customNickname);
};

// ========== SCHEDULING ==========

export const scheduleNotification = async (userId, type, content, scheduledAt, metadata = {}) => {
    const settings = await personaRepo.getUserAISettings(userId);

    return await notificationRepo.createNotification({
        user_id: userId,
        persona_id: settings?.persona_id || null,
        type,
        content,
        scheduled_at: scheduledAt,
        metadata
    });
};

export const scheduleMorningCheckins = async () => {
    const users = await notificationRepo.getUsersForMorningCheckin();
    const notifications = [];

    for (const user of users) {
        // Check if already scheduled today
        const hasScheduled = await notificationRepo.hasScheduledToday(user.user_id, 'morning');
        if (hasScheduled) continue;

        const content = generateMorningMessage(user.persona_name, user.custom_nickname);

        // Schedule for 7:00 AM in user's timezone (simplified - using fixed time)
        const scheduledAt = new Date();
        scheduledAt.setHours(7, 0, 0, 0);

        // If already past 7 AM, skip
        if (scheduledAt < new Date()) continue;

        notifications.push({
            user_id: user.user_id,
            persona_id: user.persona_id,
            type: 'morning',
            content,
            scheduled_at: scheduledAt,
            metadata: {}
        });
    }

    if (notifications.length > 0) {
        return await notificationRepo.scheduleMultipleNotifications(notifications);
    }
    return [];
};

export const scheduleEveningCheckins = async () => {
    const users = await notificationRepo.getUsersForEveningCheckin();
    const notifications = [];

    for (const user of users) {
        const hasScheduled = await notificationRepo.hasScheduledToday(user.user_id, 'evening');
        if (hasScheduled) continue;

        const content = generateEveningMessage(user.persona_name, user.custom_nickname);

        // Schedule for 10:00 PM
        const scheduledAt = new Date();
        scheduledAt.setHours(22, 0, 0, 0);

        if (scheduledAt < new Date()) continue;

        notifications.push({
            user_id: user.user_id,
            persona_id: user.persona_id,
            type: 'evening',
            content,
            scheduled_at: scheduledAt,
            metadata: {}
        });
    }

    if (notifications.length > 0) {
        return await notificationRepo.scheduleMultipleNotifications(notifications);
    }
    return [];
};

export const scheduleRandomMessage = async (userId) => {
    const settings = await personaRepo.getUserAISettings(userId);
    if (!settings?.random_messages) return null;

    const content = generateRandomMessage(settings.persona_name, settings.custom_nickname);

    // Random time between now and 4 hours from now
    const scheduledAt = new Date();
    scheduledAt.setMinutes(scheduledAt.getMinutes() + Math.floor(Math.random() * 240));

    return await notificationRepo.createNotification({
        user_id: userId,
        persona_id: settings.persona_id,
        type: 'random',
        content,
        scheduled_at: scheduledAt,
        metadata: {}
    });
};

// ========== SENDING ==========

export const getPendingNotifications = async () => {
    return await notificationRepo.getPendingNotifications();
};

export const markNotificationSent = async (notificationId) => {
    return await notificationRepo.markAsSent(notificationId);
};

export const getUserNotificationHistory = async (userId, limit = 20) => {
    return await notificationRepo.getUserNotifications(userId, limit, true);
};

export const deleteNotification = async (notificationId, userId) => {
    return await notificationRepo.deleteNotification(notificationId, userId);
};

// ========== CLEANUP ==========

export const cleanupOldNotifications = async () => {
    return await notificationRepo.deleteOldNotifications(30);
};

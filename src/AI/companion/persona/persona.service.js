// =============================================
// AI COMPANION - PERSONA SERVICE
// =============================================

import * as personaRepo from './persona.repo.js';

// ========== PERSONA MANAGEMENT ==========

export const listPersonas = async () => {
    return await personaRepo.getAllPersonas();
};

export const getPersona = async (personaId) => {
    const persona = await personaRepo.getPersonaById(personaId);
    if (!persona) {
        throw { status: 404, message: 'Persona not found' };
    }
    return persona;
};

// ========== USER SETTINGS ==========

export const getUserSettings = async (userId) => {
    let settings = await personaRepo.getUserAISettings(userId);

    // Auto-create default settings if not exists
    if (!settings) {
        // Get default persona (bestfriend)
        const defaultPersona = await personaRepo.getPersonaByName('bestfriend');
        settings = await personaRepo.createUserAISettings(userId, {
            persona_id: defaultPersona?.id || null
        });
        // Re-fetch with persona details
        settings = await personaRepo.getUserAISettings(userId);
    }

    return settings;
};

export const updateUserSettings = async (userId, updates) => {
    // Validate persona_id if provided
    if (updates.persona_id) {
        const persona = await personaRepo.getPersonaById(updates.persona_id);
        if (!persona) {
            throw { status: 400, message: 'Invalid persona_id' };
        }
    }

    // Validate relationship_level
    if (updates.relationship_level !== undefined) {
        if (updates.relationship_level < 1 || updates.relationship_level > 4) {
            throw { status: 400, message: 'relationship_level must be between 1 and 4' };
        }
    }

    // Ensure settings exist first
    await getUserSettings(userId);

    const updated = await personaRepo.updateUserAISettings(userId, updates);
    return await personaRepo.getUserAISettings(userId);
};

export const selectPersona = async (userId, personaId) => {
    const persona = await personaRepo.getPersonaById(personaId);
    if (!persona) {
        throw { status: 404, message: 'Persona not found' };
    }

    await personaRepo.createUserAISettings(userId, { persona_id: personaId });
    return await personaRepo.getUserAISettings(userId);
};

// ========== RELATIONSHIP GROWTH ==========

const RELATIONSHIP_LEVELS = {
    1: { name: 'Làm quen', messages_required: 0 },
    2: { name: 'Thân thiết', messages_required: 50 },
    3: { name: 'Tin tưởng', messages_required: 150 },
    4: { name: 'Đồng hành sâu', messages_required: 300 }
};

export const checkRelationshipGrowth = async (userId, messageCount) => {
    const settings = await getUserSettings(userId);
    const currentLevel = settings.relationship_level || 1;

    // Check if should level up
    for (let level = 4; level > currentLevel; level--) {
        if (messageCount >= RELATIONSHIP_LEVELS[level].messages_required) {
            await personaRepo.incrementRelationshipLevel(userId);
            return {
                leveledUp: true,
                newLevel: Math.min(currentLevel + 1, 4),
                levelName: RELATIONSHIP_LEVELS[Math.min(currentLevel + 1, 4)].name
            };
        }
    }

    return { leveledUp: false, currentLevel };
};

// ========== CONTEXT MANAGEMENT ==========

export const saveUserContext = async (userId, contextType, key, value, importance = 1) => {
    return await personaRepo.saveContext(userId, contextType, key, value, importance);
};

export const getUserContext = async (userId) => {
    return await personaRepo.getAllUserContext(userId);
};

// ========== PROMPT BUILDING ==========

export const buildPersonaPrompt = (persona, settings, userContext = []) => {
    if (!persona) {
        return ''; // No persona selected, use default AI behavior
    }

    const relationshipDescriptions = {
        1: 'Bạn mới quen người dùng, hãy thân thiện nhưng giữ khoảng cách phù hợp.',
        2: 'Bạn đã quen người dùng một thời gian, có thể thân mật hơn.',
        3: 'Bạn và người dùng đã rất thân, có thể chia sẻ sâu hơn.',
        4: 'Bạn là người đồng hành thân thiết nhất của người dùng, hiểu họ rất rõ.'
    };

    const contextString = userContext.length > 0
        ? `\n📝 THÔNG TIN ĐÃ BIẾT VỀ NGƯỜI DÙNG:\n${userContext.map(c => `- ${c.context_key}: ${c.context_value}`).join('\n')}`
        : '';

    const nickname = settings?.custom_nickname
        ? `Gọi người dùng là "${settings.custom_nickname}".`
        : '';

    return `
🎭 PERSONA: ${persona.display_name}
- Giọng điệu: ${persona.tone}
- Mô tả: ${persona.description}
${nickname}

💬 CÁCH NÓI CHUYỆN:
- Sử dụng các câu đặc trưng: ${persona.signature_messages?.slice(0, 3).join(', ')}
- Phản ứng cảm xúc theo pattern: ${JSON.stringify(persona.emotion_pattern)}

🤝 MỨC ĐỘ THÂN THIẾT: Level ${settings?.relationship_level || 1}/4
${relationshipDescriptions[settings?.relationship_level || 1]}
${contextString}

⚠️ QUY TẮC:
- LUÔN giữ đúng persona và giọng điệu
- Phản hồi phù hợp với mức độ thân thiết
- Nhớ các thông tin đã biết về người dùng
`;
};

export const getRandomSignatureMessage = (persona) => {
    if (!persona?.signature_messages?.length) return null;
    const messages = persona.signature_messages;
    return messages[Math.floor(Math.random() * messages.length)];
};

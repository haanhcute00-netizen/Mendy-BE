import { handleChat } from './aiCore.js';

export const chat = async (req, res) => {
    const { userId, message } = req.body;
    if (!userId || !message) {
        return res.status(400).json({ error: 'userId and message are required' });
    }

    try {
        const response = await handleChat(userId, message);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).json({ error: 'An internal error occurred' });
    }
};
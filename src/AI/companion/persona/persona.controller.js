// =============================================
// AI COMPANION - PERSONA CONTROLLER
// =============================================

import * as personaService from './persona.service.js';

// GET /api/v1/ai-companion/personas
export const listPersonas = async (req, res, next) => {
    try {
        const personas = await personaService.listPersonas();
        res.json({
            success: true,
            data: personas
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/personas/:id
export const getPersona = async (req, res, next) => {
    try {
        const { id } = req.params;
        const persona = await personaService.getPersona(parseInt(id));
        res.json({
            success: true,
            data: persona
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/settings
export const getSettings = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const settings = await personaService.getUserSettings(userId);
        res.json({
            success: true,
            data: settings
        });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/settings
export const createOrUpdateSettings = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const updates = req.body;
        const settings = await personaService.updateUserSettings(userId, updates);
        res.json({
            success: true,
            message: 'Settings updated successfully',
            data: settings
        });
    } catch (error) {
        next(error);
    }
};

// PUT /api/v1/ai-companion/settings
export const updateSettings = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const updates = req.body;
        const settings = await personaService.updateUserSettings(userId, updates);
        res.json({
            success: true,
            message: 'Settings updated successfully',
            data: settings
        });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/persona/select
export const selectPersona = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { persona_id } = req.body;

        if (!persona_id) {
            return res.status(400).json({
                success: false,
                message: 'persona_id is required'
            });
        }

        const settings = await personaService.selectPersona(userId, parseInt(persona_id));
        res.json({
            success: true,
            message: 'Persona selected successfully',
            data: settings
        });
    } catch (error) {
        next(error);
    }
};

// GET /api/v1/ai-companion/context
export const getContext = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const context = await personaService.getUserContext(userId);
        res.json({
            success: true,
            data: context
        });
    } catch (error) {
        next(error);
    }
};

// POST /api/v1/ai-companion/context
export const saveContext = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { context_type, key, value, importance } = req.body;

        if (!context_type || !key || !value) {
            return res.status(400).json({
                success: false,
                message: 'context_type, key, and value are required'
            });
        }

        const context = await personaService.saveUserContext(
            userId, context_type, key, value, importance || 1
        );
        res.json({
            success: true,
            message: 'Context saved successfully',
            data: context
        });
    } catch (error) {
        next(error);
    }
};

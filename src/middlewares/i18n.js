// src/middlewares/i18n.js - Language detection middleware
import i18next from '../config/i18n.js';

/**
 * Middleware to detect and set language for each request
 * Priority:
 * 1. 'lang' query parameter (?lang=en)
 * 2. 'Accept-Language' HTTP header
 * 3. Default to Vietnamese (vi)
 */
export const i18nMiddleware = (req, res, next) => {
    // Detect language from query parameter first
    let language = req.query.lang;

    // If not in query, check Accept-Language header
    if (!language) {
        const acceptLanguage = req.headers['accept-language'];
        if (acceptLanguage) {
            // Parse Accept-Language header (e.g., "en-US,en;q=0.9,vi;q=0.8")
            const languages = acceptLanguage
                .split(',')
                .map(lang => {
                    const parts = lang.trim().split(';');
                    const code = parts[0].split('-')[0]; // Get language code only (en from en-US)
                    const quality = parts[1] ? parseFloat(parts[1].split('=')[1]) : 1.0;
                    return { code, quality };
                })
                .sort((a, b) => b.quality - a.quality); // Sort by quality

            // Find first supported language
            const supportedLangs = ['vi', 'en', 'zh'];
            const found = languages.find(lang => supportedLangs.includes(lang.code));
            language = found ? found.code : null;
        }
    }

    // Default to Vietnamese if no language detected
    if (!language || !['vi', 'en', 'zh'].includes(language)) {
        language = 'vi';
    }

    // Set language for this request
    req.language = language;

    // Create translation function for this request
    req.t = (key, options) => {
        return i18next.t(key, { ...options, lng: language });
    };

    // Also attach to res.req for response helpers
    res.req = req;

    next();
};

export default i18nMiddleware;

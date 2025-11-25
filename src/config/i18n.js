// src/config/i18n.js - i18next configuration for multi-language support
import i18next from 'i18next';
import Backend from 'i18next-fs-backend';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Initialize i18next
i18next
    .use(Backend)
    .init({
        // Supported languages
        supportedLngs: ['vi', 'en', 'zh'],

        // Default language (Vietnamese)
        fallbackLng: 'vi',

        // Default namespace
        ns: ['translation'],
        defaultNS: 'translation',

        // Backend configuration - load translation files from locales directory
        backend: {
            loadPath: join(__dirname, '../locales/{{lng}}/{{ns}}.json'),
        },

        // Interpolation settings
        interpolation: {
            escapeValue: false, // Not needed for server-side
        },

        // Debug in development
        debug: process.env.NODE_ENV === 'development',

        // Return null for missing keys instead of key itself
        returnNull: false,
        returnEmptyString: false,

        // Key separator
        keySeparator: '.',

        // Namespace separator
        nsSeparator: ':',

        // Preload languages for better performance
        preload: ['vi', 'en', 'zh'],

        // Cache configuration
        cache: {
            enabled: true,
        },
    });

export default i18next;

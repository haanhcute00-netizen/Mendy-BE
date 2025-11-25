// Vitest setup file
import { beforeAll } from 'vitest';

// Set test environment variables
beforeAll(() => {
    process.env.NODE_ENV = 'test';
    process.env.JWT_SECRET = 'test-secret-key-for-testing-purposes-only-min-32-chars';
    process.env.JWT_ISS = 'healing.api.test';
    process.env.JWT_AUD = 'healing.webapp.test';
    process.env.TOKEN_TTL = '1h';
    process.env.DATABASE_URL = process.env.TEST_DATABASE_URL || 'postgresql://localhost/healing_test';
});

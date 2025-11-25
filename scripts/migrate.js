#!/usr/bin/env node

import { readdir, readFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';
import dotenv from 'dotenv';

const { Pool } = pg;
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables
dotenv.config();

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

const MIGRATIONS_DIR = join(__dirname, '../src/migrations');

/**
 * Parse migration file to extract UP and DOWN sections
 */
function parseMigration(content) {
    const upMatch = content.match(/--\s*=+\s*UP\s*=+\s*\n([\s\S]*?)(?=--\s*=+\s*DOWN\s*=+|$)/i);
    const downMatch = content.match(/--\s*=+\s*DOWN\s*=+\s*\n([\s\S]*?)$/i);

    return {
        up: upMatch ? upMatch[1].trim() : content.trim(),
        down: downMatch ? downMatch[1].trim() : null
    };
}

/**
 * Get list of migration files sorted by version
 */
async function getMigrationFiles() {
    const files = await readdir(MIGRATIONS_DIR);

    return files
        .filter(f => f.endsWith('.sql') && !f.startsWith('.'))
        .sort()
        .map(file => ({
            file,
            version: file.replace('.sql', ''),
            path: join(MIGRATIONS_DIR, file)
        }));
}

/**
 * Get executed migrations from database
 */
async function getExecutedMigrations() {
    try {
        const result = await pool.query(
            'SELECT version FROM app.schema_migrations ORDER BY version'
        );
        return new Set(result.rows.map(r => r.version));
    } catch (err) {
        // Table doesn't exist yet, return empty set
        if (err.code === '42P01') {
            return new Set();
        }
        throw err;
    }
}

/**
 * Initialize migration tracking table
 */
async function initTracking() {
    const trackingFile = join(MIGRATIONS_DIR, '.tracking', 'schema_migrations.sql');
    try {
        const sql = await readFile(trackingFile, 'utf-8');
        await pool.query(sql);
        console.log('✓ Migration tracking table initialized');
    } catch (err) {
        console.error('✗ Failed to initialize tracking:', err.message);
        throw err;
    }
}

/**
 * Record migration as executed
 */
async function recordMigration(version, name) {
    await pool.query(
        'INSERT INTO app.schema_migrations (version, name) VALUES ($1, $2) ON CONFLICT (version) DO NOTHING',
        [version, name]
    );
}

/**
 * Remove migration record
 */
async function unrecordMigration(version) {
    await pool.query(
        'DELETE FROM app.schema_migrations WHERE version = $1',
        [version]
    );
}

/**
 * Run pending migrations
 */
async function migrateUp() {
    console.log('🔄 Running migrations...\n');

    await initTracking();

    const migrations = await getMigrationFiles();
    const executed = await getExecutedMigrations();

    const pending = migrations.filter(m => !executed.has(m.version));

    if (pending.length === 0) {
        console.log('✓ No pending migrations');
        return;
    }

    console.log(`Found ${pending.length} pending migration(s):\n`);

    for (const migration of pending) {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            console.log(`⏳ Running: ${migration.file}`);

            const content = await readFile(migration.path, 'utf-8');
            const { up } = parseMigration(content);

            if (!up) {
                throw new Error('No UP section found in migration');
            }

            await client.query(up);
            await client.query(
                'INSERT INTO app.schema_migrations (version, name) VALUES ($1, $2)',
                [migration.version, migration.file]
            );

            await client.query('COMMIT');

            console.log(`✓ Completed: ${migration.file}\n`);

        } catch (err) {
            await client.query('ROLLBACK');
            console.error(`✗ Failed: ${migration.file}`);
            console.error(`  Error: ${err.message}\n`);
            throw err;
        } finally {
            client.release();
        }
    }

    console.log('✓ All migrations completed successfully!');
}

/**
 * Rollback last migration
 */
async function migrateDown() {
    console.log('🔄 Rolling back last migration...\n');

    const migrations = await getMigrationFiles();
    const executed = await getExecutedMigrations();

    const executedMigrations = migrations.filter(m => executed.has(m.version));

    if (executedMigrations.length === 0) {
        console.log('✓ No migrations to rollback');
        return;
    }

    const last = executedMigrations[executedMigrations.length - 1];

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        console.log(`⏳ Rolling back: ${last.file}`);

        const content = await readFile(last.path, 'utf-8');
        const { down } = parseMigration(content);

        if (!down) {
            throw new Error('No DOWN section found in migration - cannot rollback');
        }

        await client.query(down);
        await client.query(
            'DELETE FROM app.schema_migrations WHERE version = $1',
            [last.version]
        );

        await client.query('COMMIT');

        console.log(`✓ Rolled back: ${last.file}\n`);

    } catch (err) {
        await client.query('ROLLBACK');
        console.error(`✗ Failed to rollback: ${last.file}`);
        console.error(`  Error: ${err.message}\n`);
        throw err;
    } finally {
        client.release();
    }
}

/**
 * Show migration status
 */
async function migrateStatus() {
    console.log('📊 Migration Status\n');

    try {
        await initTracking();

        const migrations = await getMigrationFiles();
        const executed = await getExecutedMigrations();

        console.log(`Total migrations: ${migrations.length}`);
        console.log(`Executed: ${executed.size}`);
        console.log(`Pending: ${migrations.length - executed.size}\n`);

        if (migrations.length === 0) {
            console.log('No migration files found');
            return;
        }

        console.log('Migration files:');
        console.log('─'.repeat(60));

        for (const migration of migrations) {
            const status = executed.has(migration.version) ? '✓' : '○';
            const label = executed.has(migration.version) ? 'EXECUTED' : 'PENDING';
            console.log(`${status} [${label}] ${migration.file}`);
        }

    } catch (err) {
        console.error('Error:', err.message);
        throw err;
    }
}

/**
 * Create new migration file
 */
async function createMigration(name) {
    if (!name) {
        console.error('✗ Migration name is required');
        console.log('Usage: npm run migrate:create <name>');
        process.exit(1);
    }

    const migrations = await getMigrationFiles();
    const lastVersion = migrations.length > 0
        ? parseInt(migrations[migrations.length - 1].version.split('_')[0])
        : 0;

    const newVersion = String(lastVersion + 1).padStart(3, '0');
    const fileName = `${newVersion}_${name.replace(/\s+/g, '_').toLowerCase()}.sql`;
    const filePath = join(MIGRATIONS_DIR, fileName);

    const template = `-- ===== UP =====

-- Write your migration here


-- ===== DOWN =====

-- Write rollback logic here

`;

    await writeFile(filePath, template);
    console.log(`✓ Created migration: ${fileName}`);
}

/**
 * Main CLI handler
 */
async function main() {
    const command = process.argv[2];
    const arg = process.argv[3];

    try {
        switch (command) {
            case 'up':
                await migrateUp();
                break;
            case 'down':
                await migrateDown();
                break;
            case 'status':
                await migrateStatus();
                break;
            case 'create':
                await createMigration(arg);
                break;
            default:
                console.log('Migration CLI');
                console.log('\nUsage:');
                console.log('  npm run migrate up      - Run pending migrations');
                console.log('  npm run migrate down    - Rollback last migration');
                console.log('  npm run migrate status  - Show migration status');
                console.log('  npm run migrate create <name> - Create new migration');
                process.exit(1);
        }

        await pool.end();
        process.exit(0);

    } catch (err) {
        console.error('\n❌ Migration failed:', err.message);
        await pool.end();
        process.exit(1);
    }
}

main();

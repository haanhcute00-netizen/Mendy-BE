import pg from "pg";
const { Pool } = pg;

// Debug: Log DATABASE_URL (masked)
const dbUrl = process.env.DATABASE_URL;
if (dbUrl) {
  console.log("📦 DATABASE_URL loaded:", dbUrl.substring(0, 30) + "...");
} else {
  console.error("❌ DATABASE_URL is not defined!");
}

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000, // Tăng lên 10 giây cho Neon cold start
  ssl: {
    rejectUnauthorized: false,
  }
});

export async function query(text, params) {
  const start = Date.now();
  const res = await pool.query(text, params);
  const ms = Date.now() - start;
  if (ms > 300) console.warn("⚠️ Slow query:", { text, ms });
  return res;
}


export async function getClient() {
  return await pool.connect();
}

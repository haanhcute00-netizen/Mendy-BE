// src/repositories/wallets.repo.js
import { query } from "../../config/db.js";

// Get wallet balance by user ID
export async function getBalance(userId) {
    const { rows } = await query(
        `SELECT balance FROM app.wallets WHERE owner_user_id = $1`,
        [userId]
    );
    return rows[0]?.balance ? Number(rows[0].balance) : 0;
}

// Ensure wallet exists for user
export async function ensureWalletExists(userId, client = null) {
    const q = `
    INSERT INTO app.wallets (owner_user_id, balance)
    VALUES ($1, 0)
    ON CONFLICT (owner_user_id) DO NOTHING
    RETURNING id
  `;

    if (client) {
        await client.query(q, [userId]);
    } else {
        await query(q, [userId]);
    }
}

// Credit wallet (add funds)
export async function creditWallet({ userId, amount, refType, refId, description }, client) {
    // 1. Update wallet balance
    const { rows } = await client.query(
        `UPDATE app.wallets
     SET balance = balance + $2
     WHERE owner_user_id = $1
     RETURNING id, balance`,
        [userId, amount]
    );

    if (rows.length === 0) {
        // Create wallet if not exists and retry (should be rare if ensureWalletExists is called)
        await ensureWalletExists(userId, client);
        const { rows: retryRows } = await client.query(
            `UPDATE app.wallets
       SET balance = balance + $2
       WHERE owner_user_id = $1
       RETURNING id, balance`,
            [userId, amount]
        );
        if (retryRows.length === 0) throw new Error("Wallet not found");

        // 2. Insert ledger entry
        await client.query(
            `INSERT INTO app.wallet_ledger (wallet_id, tx_type, amount, ref_table, ref_id, created_at)
       VALUES ($1, 'EARN', $2, $3, $4, now())`,
            [retryRows[0].id, amount, refType, refId]
        );

        return retryRows[0];
    }

    // 2. Insert ledger entry
    await client.query(
        `INSERT INTO app.wallet_ledger (wallet_id, tx_type, amount, ref_table, ref_id, created_at)
     VALUES ($1, 'EARN', $2, $3, $4, now())`,
        [rows[0].id, amount, refType, refId]
    );

    return rows[0];
}

// Debit wallet (deduct funds) - e.g. for Payout
export async function debitWallet({ userId, amount, refType, refId }, client) {
    // 1. Check balance and deduct
    const { rows } = await client.query(
        `UPDATE app.wallets
     SET balance = balance - $2
     WHERE owner_user_id = $1 AND balance >= $2
     RETURNING id, balance`,
        [userId, amount]
    );

    if (rows.length === 0) {
        throw new Error("Insufficient balance or wallet not found");
    }

    // 2. Insert ledger entry
    await client.query(
        `INSERT INTO app.wallet_ledger (wallet_id, tx_type, amount, ref_table, ref_id, created_at)
     VALUES ($1, 'WITHDRAW', $2, $3, $4, now())`,
        [rows[0].id, -amount, refType, refId] // Negative amount for ledger visual? Or keeping absolute? 
        // Schema check: amount <> 0. Usually ledger stores signed or unsigned + type. 
        // Let's store negative for consistency with "balance change" or positive with type?
        // Looking at schema: tx_type is enum. Let's store negative for debit to be safe if summing.
        // Wait, schema check says amount <> 0.
    );

    return rows[0];
}

// Get ledger history
export async function getLedger(userId, limit = 20, offset = 0) {
    const { rows } = await query(
        `SELECT l.* 
     FROM app.wallet_ledger l
     JOIN app.wallets w ON l.wallet_id = w.id
     WHERE w.owner_user_id = $1
     ORDER BY l.created_at DESC
     LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
    );
    return rows;
}

// src/services/payouts.service.js
import * as PayoutsRepo from "./payouts.repo.js";
import * as WalletsRepo from "../wallets/wallets.repo.js";
import * as PayoutAccountsRepo from "./payoutAccounts.repo.js";
import { getClient } from "../../config/db.js";

export async function requestPayout(userId, amount) {
    const client = await getClient();
    try {
        await client.query('BEGIN');

        // 1. Validate amount
        if (amount <= 0) throw new Error("Amount must be greater than 0");

        // 2. Get default payout account
        const defaultAccount = await PayoutAccountsRepo.getPayoutAccountByUserId(userId);

        if (!defaultAccount) {
            throw new Error("No payout account found. Please add a bank account first.");
        }

        // 3. Create payout request
        const request = await PayoutsRepo.createRequest({
            userId,
            amount,
            payoutAccountId: defaultAccount.id
        }, client);

        // 4. Debit Wallet
        await WalletsRepo.debitWallet({
            userId,
            amount,
            refType: 'PAYOUT_REQUEST',
            refId: request.id
        }, client);

        await client.query('COMMIT');
        return request;

    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

export async function listMyRequests(userId) {
    return await PayoutsRepo.listRequests({ userId });
}

export async function adminListRequests(filters) {
    return await PayoutsRepo.listRequests(filters);
}

export async function adminApproveRequest(requestId, adminNote) {
    const client = await getClient();
    try {
        await client.query('BEGIN');

        const request = await PayoutsRepo.getRequestById(requestId);
        if (!request) throw new Error("Request not found");
        if (request.status !== 'PENDING') throw new Error("Request is not pending");

        // Update status to APPROVED
        const updated = await PayoutsRepo.updateStatus({
            id: requestId,
            status: 'APPROVED',
            adminNote
        }, client);

        await client.query('COMMIT');
        return updated;
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

export async function adminRejectRequest(requestId, adminNote) {
    const client = await getClient();
    try {
        await client.query('BEGIN');

        const request = await PayoutsRepo.getRequestById(requestId);
        if (!request) throw new Error("Request not found");
        if (request.status !== 'PENDING') throw new Error("Request is not pending");

        // 1. Refund to wallet
        await WalletsRepo.creditWallet({
            userId: request.user_id,
            amount: request.amount,
            refType: 'PAYOUT_REFUND',
            refId: request.id,
            description: `Refund for rejected payout #${request.id}`
        }, client);

        // 2. Update status
        const updated = await PayoutsRepo.updateStatus({
            id: requestId,
            status: 'REJECTED',
            adminNote
        }, client);

        await client.query('COMMIT');
        return updated;
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

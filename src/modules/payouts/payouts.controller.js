// src/controllers/payouts.controller.js
import * as PayoutsService from "./payouts.service.js";
import { apiStatus } from "../../utils/response.js";
import { asyncHandler } from "../../utils/asyncHandler.js";

export const requestPayout = asyncHandler(async (req, res) => {
    const { amount } = req.body;
    const userId = req.user.id;

    const result = await PayoutsService.requestPayout(userId, amount);
    return apiStatus(res, true, "Payout requested successfully", result);
});

export const listMine = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const result = await PayoutsService.listMyRequests(userId);
    return apiStatus(res, true, "Payout history", result);
});

export const adminList = asyncHandler(async (req, res) => {
    const { status, userId } = req.query;
    const result = await PayoutsService.adminListRequests({ status, userId });
    return apiStatus(res, true, "Payout requests list", result);
});

export const adminApprove = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const { note } = req.body;
    const result = await PayoutsService.adminApproveRequest(id, note);
    return apiStatus(res, true, "Payout approved", result);
});

export const adminReject = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const { note } = req.body;
    const result = await PayoutsService.adminRejectRequest(id, note);
    return apiStatus(res, true, "Payout rejected", result);
});

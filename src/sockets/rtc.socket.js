import { Server } from "socket.io";
import jwt from "jsonwebtoken";
import * as Calls from "../modules/chat/calls.repo.js";
import { verifyJwt } from "../utils/verifyJwt.js";

// Load TURN configuration from environment
const iceServers = [];
if (process.env.TURN_URL) {
  iceServers.push({
    urls: process.env.TURN_URL,
    username: process.env.TURN_USERNAME,
    credential: process.env.TURN_PASSWORD,
  });
} else {
  iceServers.push({ urls: "stun:stun.l.google.com:19302" });
}


function ok(cb, data) { cb && cb({ ok: true, ...data }); }
function err(cb, msg) { cb && cb({ error: msg || "error" }); }
function toValidId(x) { const n = Number(x); return Number.isFinite(n) && n > 0 ? n : null; }





export function initRtcSocket(io) {
  // const io = new Server(server, ...); // Removed
  const rtc = io.of("/rtc");

  const buckets = new Map(); // key -> { tokens, ts }
  function allow(key, rate = 40, windowMs = 60_000) { // 40 events/min default
    const now = Date.now();
    let b = buckets.get(key) || { tokens: rate, ts: now };
    const refill = ((now - b.ts) / windowMs) * rate;
    b.tokens = Math.min(rate, b.tokens + refill);
    b.ts = now;
    if (b.tokens < 1) { buckets.set(key, b); return false; }
    b.tokens -= 1; buckets.set(key, b); return true;
  }

  // Helper to create PeerConnection with configured ICE servers
  function createPeerConnection() {
    return new (require("wrtc").RTCPeerConnection)({ iceServers });
  }

  rtc.use((socket, next) => {
    try {
      const token =
        socket.handshake.auth?.token ||
        socket.handshake.headers?.authorization?.replace("Bearer ", "");
      const payload = verifyJwt(token);         // ✅ dùng chung
      socket.userId = Number(payload.sub);
      socket.role = payload.role || "SEEKER";
      socket.join(`u:${socket.userId}`);
      next();
    } catch {
      next(new Error("Unauthorized"));
    }
  });

  rtc.on("connection", (socket) => {
    // Handle disconnect
    socket.on("disconnect", async () => {
      try {
        const endedCalls = await Calls.endCallsForUser(socket.userId, "disconnect");
        for (const call of endedCalls) {
          rtc.to(`call:${call.id}`).emit("call:ended", { callId: call.id, reason: "disconnect" });
        }
      } catch (e) {
        console.error("Error handling disconnect for user", socket.userId, e);
      }
    });


    socket.on("call:invite", async ({ threadId, peerId, kind = "AUDIO" }, cb) => {
      try {
        kind = String(kind || "AUDIO").toUpperCase();
        if (!["AUDIO", "VIDEO"].includes(kind)) return err(cb, "kind must be AUDIO or VIDEO");

        const tId = toValidId(threadId);
        const pId = toValidId(peerId);
        if (!tId || !pId) return err(cb, "invalid threadId/peerId");

        const okMembers = await Calls.isSameThreadMembers({ threadId: tId, userA: socket.userId, userB: pId });
        if (!okMembers) return err(cb, "not in same thread");

        // Check for existing active call
        const activeCall = await Calls.findActiveCallByUserId(socket.userId);
        if (activeCall) return err(cb, "You are already in a call");

        const call = await Calls.createInvite({ threadId: tId, callerId: socket.userId, calleeId: pId, kind });
        socket.join(`call:${call.id}`);


        rtc.to(`u:${pId}`).emit("call:incoming", { callId: call.id, from: socket.userId, threadId: tId, kind });
        ok(cb, { callId: call.id });
      } catch (e) { err(cb, e.message); }
    });

    socket.on("call:ringing", async ({ callId }, cb) => {
      const id = toValidId(callId);
      if (!id) return err(cb, "invalid callId");
      await Calls.updateStatus({ callId: id, status: "RINGING" });
      await Calls.insertEvent({ callId: id, byUser: socket.userId, type: "RINGING" });
      rtc.to(`call:${id}`).emit("call:ringing", { callId: id, by: socket.userId });
      ok(cb);
    });

    socket.on("call:accept", async ({ callId }, cb) => {
      const id = toValidId(callId);
      if (!id) return err(cb, "invalid callId");
      socket.join(`call:${id}`);
      await Calls.updateStatus({ callId: id, status: "CONNECTED", setConnected: true });
      await Calls.insertEvent({ callId: id, byUser: socket.userId, type: "ACCEPT" });
      rtc.to(`call:${id}`).emit("call:accepted", { callId: id, by: socket.userId });
      ok(cb);
    });

    socket.on("call:reject", async ({ callId, reason = "rejected" }, cb) => {
      const id = toValidId(callId);
      if (!id) return err(cb, "invalid callId");
      await Calls.updateStatus({ callId: id, status: "REJECTED", reason });
      await Calls.insertEvent({ callId: id, byUser: socket.userId, type: "REJECT" });
      rtc.to(`call:${id}`).emit("call:ended", { callId: id, reason: "rejected" });
      ok(cb);
    });

    socket.on("call:busy", async ({ callId }, cb) => {
      const id = toValidId(callId);
      if (!id) return err(cb, "invalid callId");
      await Calls.updateStatus({ callId: id, status: "BUSY", reason: "busy" });
      await Calls.insertEvent({ callId: id, byUser: socket.userId, type: "BUSY" });
      rtc.to(`call:${id}`).emit("call:ended", { callId: id, reason: "busy" });
      ok(cb);
    });

    socket.on("call:hangup", async ({ callId, reason = "hangup" }, cb) => {
      const id = toValidId(callId);
      if (!id) return err(cb, "invalid callId");
      await Calls.updateStatus({ callId: id, status: "ENDED", reason });
      await Calls.insertEvent({ callId: id, byUser: socket.userId, type: "HANGUP" });
      rtc.to(`call:${id}`).emit("call:ended", { callId: id, reason });
      ok(cb);
    });

    // Signaling — thêm validate + rate limit cho ICE (rtc:candidate)
    socket.on("rtc:offer", ({ callId, sdp }) => {
      const id = toValidId(callId);
      if (!id) return; // im lặng hoặc emit lỗi tùy bạn
      rtc.to(`call:${id}`).emit("rtc:offer", { sdp, from: socket.userId });
    });

    socket.on("rtc:answer", ({ callId, sdp }) => {
      const id = toValidId(callId);
      if (!id) return;
      rtc.to(`call:${id}`).emit("rtc:answer", { sdp, from: socket.userId });
    });

    socket.on("rtc:candidate", ({ callId, candidate }) => {
      const id = toValidId(callId);
      if (!id) return;
      const key = `ice:${socket.userId}:${id}`;
      if (!allow(key, 120, 60_000)) return; // 120 ICE/phút/người/cuộc gọi
      rtc.to(`call:${id}`).emit("rtc:candidate", { candidate, from: socket.userId });
    });

    // New events for message edit/delete via RTC (optional, can also use REST)
    socket.on("message:edit", async ({ messageId, content }, cb) => {
      try {
        const msg = await Calls.updateMessage(messageId, { content });
        // Assuming messageId is related to a thread or call for broadcasting
        // This might need adjustment based on how messages are grouped for real-time updates
        rtc.to(`u:${socket.userId}`).emit("message:edited", msg); // Or broadcast to thread/call participants
        cb?.({ ok: true, message: msg });
      } catch (e) { cb?.({ error: e.message }); }
    });

    socket.on("message:delete", async ({ messageId }, cb) => {
      try {
        const msg = await Calls.softDeleteMessage(messageId);
        // Assuming messageId is related to a thread or call for broadcasting
        rtc.to(`u:${socket.userId}`).emit("message:deleted", { id: messageId }); // Or broadcast to thread/call participants
        cb?.({ ok: true });
      } catch (e) { cb?.({ error: e.message }); }
    });

    // TURN token giữ nguyên (có thể nâng cấp sau)
  });

}

import * as Posts from "../posts/posts.repo.js";
import * as Follows from "../users/follows.repo.js";
import cloudinary from "../../config/cloudinary.js";
import path from "path";

const PRIV = new Set(["PUBLIC", "FRIENDS", "ONLY_ME", "CUSTOM"]);
const REACTIONS = new Set(["LIKE", "LOVE", "CARE", "HAHA", "WOW", "SAD", "ANGRY"]);
const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/gif", "image/webp"];
const ALLOWED_VIDEO_TYPES = ["video/mp4", "video/webm", "video/quicktime"];
const MAX_IMAGES = 10;
const MAX_VIDEO_SIZE = 100 * 1024 * 1024; // 100MB

/**
 * Tạo tên file chuẩn theo format:
 * {type}_{userId}_{timestamp}_{random}.{ext}
 * Ví dụ: img_21_1701234567890_a1b2c3.jpg
 */
function generateFileName(file, userId, type = "img") {
    const ext = path.extname(file.originalname).toLowerCase() || getExtFromMime(file.mimetype);
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 8);
    return `${type}_${userId}_${timestamp}_${random}${ext}`;
}

function getExtFromMime(mimetype) {
    const map = {
        "image/jpeg": ".jpg",
        "image/png": ".png",
        "image/gif": ".gif",
        "image/webp": ".webp",
        "video/mp4": ".mp4",
        "video/webm": ".webm",
        "video/quicktime": ".mov"
    };
    return map[mimetype] || "";
}

/**
 * Sanitize tên file gốc - loại bỏ ký tự đặc biệt
 */
function sanitizeOriginalName(filename) {
    if (!filename) return "unnamed";
    // Giữ lại tên file, loại bỏ path và ký tự nguy hiểm
    return path.basename(filename)
        .replace(/[<>:"/\\|?*\x00-\x1f]/g, "_")
        .substring(0, 255);
}

// Upload file lên Cloudinary với tên chuẩn
async function uploadToCloudinary(file, userId, resourceType = "image") {
    const type = resourceType === "video" ? "vid" : "img";
    const publicId = generateFileName(file, userId, type).replace(/\.[^.]+$/, ""); // Bỏ extension cho public_id

    return new Promise((resolve, reject) => {
        const options = {
            folder: "mendy/posts",
            resource_type: resourceType,
            public_id: publicId,
            // Giữ nguyên format gốc
            format: null
        };
        const stream = cloudinary.uploader.upload_stream(options, (error, result) => {
            if (result) resolve(result);
            else reject(error);
        });
        stream.end(file.buffer);
    });
}
function deriveTitle(raw) {
    const s = String(raw ?? "").trim();
    if (!s) return "Untitled";
    // Lấy dòng đầu tiên, tối đa 120 ký tự
    const firstLine = s.split(/\r?\n/)[0].replace(/\s+/g, " ").slice(0, 120);
    return firstLine || "Untitled";
}
export async function create({ me, title, content, privacy = "PUBLIC", fileIds, files = [] }) {
    privacy = privacy.toUpperCase();
    if (!PRIV.has(privacy)) throw Object.assign(new Error("Invalid privacy"), { status: 400 });

    // Validate files
    const images = files.filter(f => ALLOWED_IMAGE_TYPES.includes(f.mimetype));
    const videos = files.filter(f => ALLOWED_VIDEO_TYPES.includes(f.mimetype));

    if (images.length > MAX_IMAGES) {
        throw Object.assign(new Error(`Maximum ${MAX_IMAGES} images allowed`), { status: 400 });
    }
    if (videos.length > 1) {
        throw Object.assign(new Error("Only 1 video allowed per post"), { status: 400 });
    }
    for (const v of videos) {
        if (v.size > MAX_VIDEO_SIZE) {
            throw Object.assign(new Error("Video size must be under 100MB"), { status: 400 });
        }
    }

    const safeTitle = title === undefined ? deriveTitle(content) : (String(title).trim() || deriveTitle(content));

    // Create post
    const p = await Posts.createPost({
        authorId: me,
        title: safeTitle,
        content,
        privacy
    });

    // Attach existing files (from user_files)
    if (fileIds?.length) await Posts.attachFiles(p.id, fileIds);

    // Upload và lưu media mới
    const uploadedMedia = [];

    // Upload images
    for (const img of images) {
        try {
            const originalName = sanitizeOriginalName(img.originalname);
            const result = await uploadToCloudinary(img, me, "image");
            const media = await Posts.insertPostMedia({
                postId: p.id,
                kind: "IMAGE",
                url: result.secure_url,
                width: result.width,
                height: result.height,
                originalName,
                publicId: result.public_id
            });
            uploadedMedia.push(media);
        } catch (err) {
            console.error("Failed to upload image:", err.message);
        }
    }

    // Upload videos
    for (const vid of videos) {
        try {
            const originalName = sanitizeOriginalName(vid.originalname);
            const result = await uploadToCloudinary(vid, me, "video");
            const media = await Posts.insertPostMedia({
                postId: p.id,
                kind: "VIDEO",
                url: result.secure_url,
                width: result.width,
                height: result.height,
                durationMs: result.duration ? Math.round(result.duration * 1000) : null,
                originalName,
                publicId: result.public_id
            });
            uploadedMedia.push(media);
        } catch (err) {
            console.error("Failed to upload video:", err.message);
        }
    }

    return { ...p, media: uploadedMedia };
}

export async function update({ me, postId, title, content, privacy = "PUBLIC" }) {
    privacy = privacy.toUpperCase();
    if (!PRIV.has(privacy)) throw Object.assign(new Error("Invalid privacy"), { status: 400 });
    const safeTitle = title === undefined ? undefined : (String(title).trim() || deriveTitle(content));
    const p = await Posts.updatePost({ postId, authorId: me, title: safeTitle, content, privacy });
    if (!p) throw Object.assign(new Error("Not found or forbidden"), { status: 404 });
    return p;
}

export async function remove({ me, postId }) {
    const ok = await Posts.deletePost({ postId, authorId: me });
    if (!ok) throw Object.assign(new Error("Not found or forbidden"), { status: 404 });
    return { deleted: true };
}

export async function detail({ me, postId }) {
    const p = await Posts.getPostDetail(postId);
    if (!p) throw Object.assign(new Error("Post not found"), { status: 404 });

    const isOwner = p.author_id === Number(me);

    // check privacy
    if (p.privacy === "ONLY_ME" && !isOwner) {
        throw Object.assign(new Error("This post is private"), { status: 403 });
    }
    if (p.privacy === "FRIENDS" && !isOwner) {
        const isFollowing = await Follows.isFollower({ followerId: me, followeeId: p.author_id });
        if (!isFollowing) {
            throw Object.assign(new Error("This post is only visible to friends"), { status: 403 });
        }
    }

    const [files, media] = await Promise.all([
        Posts.listPostFiles(postId),
        Posts.listPostMedia(postId)
    ]);

    return {
        ...p,
        files,
        media,
        reaction_count: parseInt(p.reaction_count) || 0,
        comment_count: parseInt(p.comment_count) || 0
    };
}

export async function timeline({ me, ownerId, limit, before }) {
    // note: privacy sẽ được FE filter thêm nếu cần; ở BE, để đơn giản ta vẫn cho xem,
    // nhưng gọi detail khi cần bảo vệ nghiêm ngặt. Hoặc lọc ở query nâng cao.
    const rows = await Posts.listTimeline({ ownerId, limit, before });
    return rows;
}

export async function homeFeed({ me, limit, before }) {
    return Posts.listHomeFeed({ me, limit, before });
}

export async function react({ me, postId, reaction }) {
    reaction = String(reaction || "").toUpperCase();
    if (!REACTIONS.has(reaction)) throw Object.assign(new Error("Invalid reaction"), { status: 400 });
    return Posts.reactPost({ postId, userId: me, reaction });
}


export async function unreact({ me, postId }) {
    return { removed: await Posts.unreactPost({ postId, userId: me }) };
}

export async function save({ me, postId }) {
    const r = await Posts.savePost({ postId, userId: me });
    return { saved: !!r };
}
export async function unsave({ me, postId }) {
    return { removed: await Posts.unsavePost({ postId, userId: me }) };
}

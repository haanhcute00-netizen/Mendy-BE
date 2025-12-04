// routes/upload.route.js
import express from "express";
import upload from "../config/multer.js";
import cloudinary from "../config/cloudinary.js";

const router = express.Router();

router.post("/", upload.single("image"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder: "mendy",
        },
        (error, result) => {
          if (result) resolve(result);
          else reject(error);
        }
      );
      stream.end(req.file.buffer); // gửi buffer lên Cloudinary
    });

    res.json({
      url: result.secure_url,
      public_id: result.public_id,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;

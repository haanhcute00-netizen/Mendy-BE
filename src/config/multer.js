// config/multer.js
import multer from "multer";

const storage = multer.memoryStorage(); // không lưu file ra disk
const upload = multer({ storage });

export default upload;

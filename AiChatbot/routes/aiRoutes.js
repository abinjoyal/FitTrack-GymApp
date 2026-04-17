import express from "express";
import { chatController } from "../controllers/chatController.js";
import pool from "../config/db.js";

const router = express.Router();

router.post("/chat", chatController);

// 🔥 GET HISTORY
router.get("/history", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM chat_history ORDER BY created_at DESC"
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: "DB error" });
  }
});

export default router;
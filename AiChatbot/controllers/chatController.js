import { getAIResponse } from "../services/aiService.js";

export const chatController = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ error: "Message required" });
    }

    const reply = await getAIResponse(message);

    res.json({ reply });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Server error" });
  }
};
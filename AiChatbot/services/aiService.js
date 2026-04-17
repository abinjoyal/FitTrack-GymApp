import fetch from "node-fetch";
import { OPENROUTER_API_KEY } from "../config/openai.js";
import pool from "../config/db.js";

export const getAIResponse = async (message) => {
  try {
    const response = await fetch(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "openai/gpt-3.5-turbo",
          messages: [
            {
              role: "user",
              content: `
You are a friendly gym trainer and nutrition coach.

Talk like a real human (casual, simple, motivating,).

Rules:
- Keep answers very short (1-2 lines max)
- Only answer fitness, gym, diet, or health questions
- Food → give calories + protein + short tip
- If workout → give exercises with sets/reps
- Use easy words, avoid robotic tone
- Very short, clean format
- Add small motivation (like bro, keep going 💪)

Food Examples:
- Chicken 100g → 165 kcal, 31g protein
Egg → 70 kcal, 6g protein | good protein bro
Rice → 200 kcal, 4g protein | carbs energy 
- Chest workout → Bench press 4x10, pushups 3x15 

Smart behavior:
- Food input → nutrition output
- Workout input → training advice
- If unclear → ask short follow-up
- No long sentences
User: ${message}
`,
            },
          ],
        }),
      },
    );

    const data = await response.json();

    const reply = data.choices?.[0]?.message?.content || "AI error";

    console.log("AI TEXT 👉", reply);

    // 🔥 SAVE TO DATABASE
    await pool.query(
      "INSERT INTO chat_history(message, reply) VALUES($1, $2)",
      [message, reply],
    );

    return reply;
  } catch (error) {
    console.log("ERROR 👉", error);
    return "Server error";
  }
};

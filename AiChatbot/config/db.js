import pkg from "pg";
const { Pool } = pkg;

const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "gym_ai",
  password: "8520", // 🔥 change this
  port: 5432,
});

export default pool;
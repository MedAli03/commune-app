import "dotenv/config";
import mysql from "mysql2/promise";

const test = async () => {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
  });

  const [rows] = await conn.query("SELECT 1");
  console.log("DB OK:", rows);
  await conn.end();
};

test().catch(console.error);

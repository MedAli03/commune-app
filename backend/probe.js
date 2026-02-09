import mysql from "mysql2/promise";

const config = {
  host: "146.59.209.152",
  port: 3306,
  user: "noccstx2025",
  password: "YOUR_PASSWORD_HERE",
  database: "noccstx2025",
  connectTimeout: 10000,
};

(async () => {
  try {
    const conn = await mysql.createConnection(config);
    const [rows] = await conn.query("SELECT 1 AS ok");
    console.log(rows);
    await conn.end();
  } catch (e) {
    console.log("code:", e.code);
    console.log("errno:", e.errno);
    console.log("sqlState:", e.sqlState);
    console.log("message:", e.message);
  }
})();

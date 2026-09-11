// Runs seed.sql against the database using the same credentials as server.js.
// Use this instead of the `mysql` CLI if it's not installed / not on PATH.
//
// Usage:  node run-seed.js

require("dotenv").config();
const fs = require("fs");
const mysql = require("mysql2");

const connection = mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME || "cinemadb",
    multipleStatements: true // required to run a whole .sql file in one go
});

const sql = fs.readFileSync("./seed.sql", "utf8");

connection.connect((err) => {
    if (err) {
        console.error("Could not connect to MySQL:", err.message);
        process.exit(1);
    }

    console.log("Connected. Running seed.sql ...");

    connection.query(sql, (err, results) => {
        if (err) {
            console.error("Seeding failed:", err.message);
            connection.end();
            process.exit(1);
        }

        console.log("Seed data loaded successfully!");
        connection.end();
    });
});

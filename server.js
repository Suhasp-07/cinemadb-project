require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");
const multer = require("multer");
const bcrypt = require("bcrypt");
const path = require("path");
const fs = require("fs");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static("public"));

// Serve uploaded poster images at /uploads/posters/<filename>
const uploadDir = path.join(__dirname, "uploads", "posters");
fs.mkdirSync(uploadDir, { recursive: true });
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Multer config: saves poster files to disk with a unique filename
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const unique = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, unique + path.extname(file.originalname));
    }
});
const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
    fileFilter: (req, file, cb) => {
        const allowed = /jpeg|jpg|png|webp/;
        const ok = allowed.test(path.extname(file.originalname).toLowerCase());
        cb(ok ? null : new Error("Only .jpg, .jpeg, .png, .webp images are allowed"), ok);
    }
});

const db = mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME || "cinemadb"
});

db.connect((err) => {
    if (err) {
        console.log("MySQL connection failed:", err.message);
    } else {
        console.log("MySQL connected successfully!");
    }
});

// Home
app.get("/", (req, res) => {
    res.send("CinemaDB Server is Running!");
});

// Login
// Checks the submitted username/password against the `login` table.
// NOTE: this is a simple check for a college project — it does NOT issue a
// session/token, so the frontend just needs to know "success" or "failure".
app.post("/api/login", (req, res) => {
    const { Username, Password } = req.body;

    if (!Username || !Password) {
        return res.status(400).json({ error: "Username and password are required" });
    }

    const sql = "SELECT * FROM login WHERE Username = ?";
    db.query(sql, [Username], async (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Login failed due to a server error" });
        }

        if (results.length === 0) {
            return res.status(401).json({ error: "Invalid username or password" });
        }

        const match = await bcrypt.compare(Password, results[0].Password_Hash);
        if (!match) {
            return res.status(401).json({ error: "Invalid username or password" });
        }

        res.json({ message: "Login successful!", Username: results[0].Username });
    });
});

// Helper: insert a row into a table with an auto-generated ID
// (mirrors the MAX(ID)+1 pattern already used for bookings/payments,
// since these tables don't appear to use AUTO_INCREMENT)
function insertWithAutoId(table, idColumn, data, res, entityName) {
    const getIdSql = `SELECT COALESCE(MAX(${idColumn}), 0) + 1 AS Next_ID FROM ${table}`;

    db.query(getIdSql, (err, idResult) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: `Failed to generate ${entityName} ID` });
        }

        const nextId = idResult[0].Next_ID;
        const columns = [idColumn, ...Object.keys(data)];
        const values = [nextId, ...Object.values(data)];
        const placeholders = columns.map(() => "?").join(", ");

        const insertSql = `INSERT INTO ${table} (${columns.join(", ")}) VALUES (${placeholders})`;

        db.query(insertSql, values, (err, result) => {
            if (err) {
                console.log(err);
                return res.status(500).json({ error: `Failed to create ${entityName}` });
            }

            res.status(201).json({
                message: `${entityName} created successfully!`,
                [idColumn]: nextId
            });
        });
    });
}

// Get all movies
app.get("/api/movies", (req, res) => {
    const sql = "SELECT * FROM movie";

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to fetch movies"
            });
        }

        res.json(results);
    });
});

// Add a new movie
// Send as multipart/form-data (not JSON) so a poster image can be attached.
// Text fields: Title, Genre, Language, Duration, Release_Date, Budget, Box_Office_Collections
// File field: poster (jpg/png/webp, max 5MB)
// Do NOT send Movie_ID — it's generated automatically.
app.post("/api/movies", upload.single("poster"), (req, res) => {
    const data = { ...req.body };
    delete data.Movie_ID;

    if (req.file) {
        data.Poster = `/uploads/posters/${req.file.filename}`;
    }

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one movie field is required" });
    }

    insertWithAutoId("movie", "Movie_ID", data, res, "Movie");
});

// Get all theatres
app.get("/api/theatres", (req, res) => {
    const sql = "SELECT * FROM theatre";

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to fetch theatres"
            });
        }

        res.json(results);
    });
});

// Add a new theatre
// e.g. { "Theatre_Name": "PVR Forum", "Location": "Bengaluru" }
app.post("/api/theatres", (req, res) => {
    const data = { ...req.body };
    delete data.Theatre_ID;

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one theatre field is required" });
    }

    insertWithAutoId("theatre", "Theatre_ID", data, res, "Theatre");
});

// Get all movie shows with movie, screen and theatre details
app.get("/api/shows", (req, res) => {
    const sql = `
        SELECT
            ms.Show_ID,
            ms.Show_Date,
            ms.Show_Time,
            m.Title AS Movie_Title,
            s.Screen_ID,
            s.Screen_Name,
            t.Theatre_ID,
            t.Theatre_Name,
            t.Location
        FROM movie_show ms
        JOIN movie m ON ms.Movie_ID = m.Movie_ID
        JOIN screen s ON ms.Screen_ID = s.Screen_ID
        JOIN theatre t ON s.Theatre_ID = t.Theatre_ID
    `;

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to fetch shows"
            });
        }

        res.json(results);
    });
});

// Add a new show
// e.g. { "Show_Date": "2026-09-05", "Show_Time": "18:30:00", "Movie_ID": 1, "Screen_ID": 1 }
app.post("/api/shows", (req, res) => {
    const data = { ...req.body };
    delete data.Show_ID;

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one show field is required" });
    }

    insertWithAutoId("movie_show", "Show_ID", data, res, "Show");
});

// Get all customers
app.get("/api/customers", (req, res) => {
    const sql = "SELECT * FROM customer";

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to fetch customers"
            });
        }

        res.json(results);
    });
});

// Add a new customer
// e.g. { "Customer_Name": "Suhas", "Phone": "9876543210" }
app.post("/api/customers", (req, res) => {
    const data = { ...req.body };
    delete data.Customer_ID;

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one customer field is required" });
    }

    insertWithAutoId("customer", "Customer_ID", data, res, "Customer");
});

// Get all actors
app.get("/api/actors", (req, res) => {
    const sql = "SELECT * FROM actor";

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to fetch actors" });
        }

        res.json(results);
    });
});

// Add a new actor
// e.g. { "Actor_Name": "Rajkumar", "DOB": "1990-05-12", "Gender": "Male", "Nationality": "Indian" }
app.post("/api/actors", (req, res) => {
    const data = { ...req.body };
    delete data.Actor_ID;

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one actor field is required" });
    }

    insertWithAutoId("actor", "Actor_ID", data, res, "Actor");
});

// Get all directors
app.get("/api/directors", (req, res) => {
    const sql = "SELECT * FROM director";

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to fetch directors" });
        }

        res.json(results);
    });
});

// Add a new director
// e.g. { "Director_Name": "Rajamouli", "DOB": "1973-10-10", "Experience": 20 }
app.post("/api/directors", (req, res) => {
    const data = { ...req.body };
    delete data.Director_ID;

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one director field is required" });
    }

    insertWithAutoId("director", "Director_ID", data, res, "Director");
});

// Get all producers
app.get("/api/producers", (req, res) => {
    const sql = "SELECT * FROM producer";

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to fetch producers" });
        }

        res.json(results);
    });
});

// Add a new producer
// e.g. { "Producer_Name": "Karan Johar", "Production_House": "Dharma Productions" }
app.post("/api/producers", (req, res) => {
    const data = { ...req.body };
    delete data.Producer_ID;

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one producer field is required" });
    }

    insertWithAutoId("producer", "Producer_ID", data, res, "Producer");
});

// Get all screens
app.get("/api/screens", (req, res) => {
    const sql = "SELECT * FROM screen";

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to fetch screens" });
        }

        res.json(results);
    });
});

// Add a new screen
// e.g. { "Screen_Name": "Screen 1", "Capacity": 150, "Theatre_ID": 1 }
app.post("/api/screens", (req, res) => {
    const data = { ...req.body };
    delete data.Screen_ID;

    if (Object.keys(data).length === 0) {
        return res.status(400).json({ error: "At least one screen field is required" });
    }

    insertWithAutoId("screen", "Screen_ID", data, res, "Screen");
});

// Create a new booking
app.post("/api/bookings", (req, res) => {
    const { Booking_Date, Seats_Booked, Customer_ID, Show_ID } = req.body;

    if (!Booking_Date || !Seats_Booked || !Customer_ID || !Show_ID) {
        return res.status(400).json({
            error: "All booking fields are required"
        });
    }

    const getIdSql = `
        SELECT COALESCE(MAX(Booking_ID), 0) + 1 AS Next_ID
        FROM booking
    `;

    db.query(getIdSql, (err, idResult) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to generate booking ID"
            });
        }

        const nextId = idResult[0].Next_ID;

        const insertSql = `
            INSERT INTO booking
            (Booking_ID, Booking_Date, Seats_Booked, Customer_ID, Show_ID)
            VALUES (?, ?, ?, ?, ?)
        `;

        db.query(
            insertSql,
            [nextId, Booking_Date, Seats_Booked, Customer_ID, Show_ID],
            (err, result) => {
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                        error: "Failed to create booking"
                    });
                }

                res.status(201).json({
                    message: "Booking created successfully!",
                    Booking_ID: nextId
                });
            }
        );
    });
});
// Get all bookings with customer, movie and theatre details
app.get("/api/bookings", (req, res) => {
    const sql = `
        SELECT
            b.Booking_ID,
            b.Booking_Date,
            b.Seats_Booked,
            c.Customer_Name,
            c.Phone,
            m.Title AS Movie_Title,
            ms.Show_Date,
            ms.Show_Time,
            t.Theatre_Name,
            t.Location,
            s.Screen_Name
        FROM booking b
        JOIN customer c ON b.Customer_ID = c.Customer_ID
        JOIN movie_show ms ON b.Show_ID = ms.Show_ID
        JOIN movie m ON ms.Movie_ID = m.Movie_ID
        JOIN screen s ON ms.Screen_ID = s.Screen_ID
        JOIN theatre t ON s.Theatre_ID = t.Theatre_ID
        ORDER BY b.Booking_ID;
    `;

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to fetch bookings"
            });
        }

        res.json(results);
    });
});
// Get all payments
app.get("/api/payments", (req, res) => {
    const sql = `
        SELECT
            p.Payment_ID,
            p.Amount,
            p.Payment_Mode,
            p.Payment_Date,
            p.Booking_ID,
            c.Customer_Name,
            m.Title AS Movie_Title
        FROM payment p
        JOIN booking b ON p.Booking_ID = b.Booking_ID
        JOIN customer c ON b.Customer_ID = c.Customer_ID
        JOIN movie_show ms ON b.Show_ID = ms.Show_ID
        JOIN movie m ON ms.Movie_ID = m.Movie_ID
        ORDER BY p.Payment_ID;
    `;

    db.query(sql, (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to fetch payments"
            });
        }

        res.json(results);
    });
});

// Create a new payment
app.post("/api/payments", (req, res) => {
    const { Amount, Payment_Mode, Payment_Date, Booking_ID } = req.body;

    if (!Amount || !Payment_Mode || !Payment_Date || !Booking_ID) {
        return res.status(400).json({
            error: "All payment fields are required"
        });
    }

    const getIdSql = `
        SELECT COALESCE(MAX(Payment_ID), 0) + 1 AS Next_ID
        FROM payment
    `;

    db.query(getIdSql, (err, idResult) => {
        if (err) {
            console.log(err);
            return res.status(500).json({
                error: "Failed to generate payment ID"
            });
        }

        const nextId = idResult[0].Next_ID;

        const insertSql = `
            INSERT INTO payment
            (Payment_ID, Amount, Payment_Mode, Payment_Date, Booking_ID)
            VALUES (?, ?, ?, ?, ?)
        `;

        db.query(
            insertSql,
            [nextId, Amount, Payment_Mode, Payment_Date, Booking_ID],
            (err, result) => {
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                        error: "Failed to create payment"
                    });
                }

                res.status(201).json({
                    message: "Payment created successfully!",
                    Payment_ID: nextId
                });
            }
        );
    });
});

// ===== Movie <-> Actor/Director/Producer relationships (M:N junction tables) =====

// Get the full cast (actors + role) for a specific movie
app.get("/api/movies/:id/cast", (req, res) => {
    const sql = `
        SELECT c.Movie_ID, c.Actor_ID, c.Role_Name, a.Actor_Name, a.Nationality
        FROM \`cast\` c
        JOIN actor a ON c.Actor_ID = a.Actor_ID
        WHERE c.Movie_ID = ?
    `;
    db.query(sql, [req.params.id], (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to fetch cast" });
        }
        res.json(results);
    });
});

// Add an actor to a movie's cast
// e.g. { "Actor_ID": 5, "Role_Name": "Joseph Cooper" }
app.post("/api/movies/:id/cast", (req, res) => {
    const { Actor_ID, Role_Name } = req.body;
    if (!Actor_ID) {
        return res.status(400).json({ error: "Actor_ID is required" });
    }
    const sql = "INSERT INTO `cast` (Movie_ID, Actor_ID, Role_Name) VALUES (?, ?, ?)";
    db.query(sql, [req.params.id, Actor_ID, Role_Name || null], (err) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to add cast member" });
        }
        res.status(201).json({ message: "Cast member added successfully!" });
    });
});

// Get the director(s) for a specific movie
app.get("/api/movies/:id/directors", (req, res) => {
    const sql = `
        SELECT md.Movie_ID, md.Director_ID, d.Director_Name, d.Experience
        FROM movie_direction md
        JOIN director d ON md.Director_ID = d.Director_ID
        WHERE md.Movie_ID = ?
    `;
    db.query(sql, [req.params.id], (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to fetch directors" });
        }
        res.json(results);
    });
});

// Link a director to a movie
// e.g. { "Director_ID": 2 }
app.post("/api/movies/:id/directors", (req, res) => {
    const { Director_ID } = req.body;
    if (!Director_ID) {
        return res.status(400).json({ error: "Director_ID is required" });
    }
    const sql = "INSERT INTO movie_direction (Movie_ID, Director_ID) VALUES (?, ?)";
    db.query(sql, [req.params.id, Director_ID], (err) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to link director" });
        }
        res.status(201).json({ message: "Director linked successfully!" });
    });
});

// Get the producer(s) for a specific movie
app.get("/api/movies/:id/producers", (req, res) => {
    const sql = `
        SELECT mp.Movie_ID, mp.Producer_ID, p.Producer_Name, p.Production_House
        FROM movie_production mp
        JOIN producer p ON mp.Producer_ID = p.Producer_ID
        WHERE mp.Movie_ID = ?
    `;
    db.query(sql, [req.params.id], (err, results) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to fetch producers" });
        }
        res.json(results);
    });
});

// Link a producer to a movie
// e.g. { "Producer_ID": 2 }
app.post("/api/movies/:id/producers", (req, res) => {
    const { Producer_ID } = req.body;
    if (!Producer_ID) {
        return res.status(400).json({ error: "Producer_ID is required" });
    }
    const sql = "INSERT INTO movie_production (Movie_ID, Producer_ID) VALUES (?, ?)";
    db.query(sql, [req.params.id, Producer_ID], (err) => {
        if (err) {
            console.log(err);
            return res.status(500).json({ error: "Failed to link producer" });
        }
        res.status(201).json({ message: "Producer linked successfully!" });
    });
});

// Handle multer errors (bad file type, file too large, etc.) with a clean JSON response
app.use((err, req, res, next) => {
    if (err instanceof multer.MulterError || err.message.includes("images are allowed")) {
        return res.status(400).json({ error: err.message });
    }
    next(err);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
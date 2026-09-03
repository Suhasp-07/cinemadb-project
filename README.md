# CinemaDB Backend

## 1. Technology used
- **Node.js + Express** for the server
- **mysql2** as the MySQL driver
- **cors** and **dotenv** (just added) for cross-origin requests and config

## 2. How to run it (from scratch)
1. Install [Node.js](https://nodejs.org) if not already installed.
2. Install MySQL Server and make sure it's running.
3. Extract this ZIP anywhere on your laptop.
4. Open Command Prompt in that folder and run:
   ```
   npm install
   ```
5. Copy `.env.example` to a new file named `.env`, and fill in **your own** MySQL username/password:
   ```
   copy .env.example .env
   ```
   Then edit `.env` with a text editor.
6. Make sure the `cinemadb` database and its tables exist on your MySQL server (see #4 below).
7. Start the server:
   ```
   node server.js
   ```
8. You should see:
   ```
   MySQL connected successfully!
   Server running at http://localhost:3000
   ```

## 3. Database
**MySQL**. Database name: `cinemadb`.

## 4. Database setup / SQL script
There isn't a `.sql` schema file in this project — the database was created directly
in MySQL (not via a script we have a copy of). Known tables, based on what the code
queries:

- `movie` (has at least `Movie_ID`, `Title`)
- `theatre` (`Theatre_ID`, `Theatre_Name`, `Location`)
- `screen` (`Screen_ID`, `Screen_Name`, `Theatre_ID`)
- `movie_show` (`Show_ID`, `Show_Date`, `Show_Time`, `Movie_ID`, `Screen_ID`)
- `customer` (`Customer_ID`, `Customer_Name`, `Phone`)
- `booking` (`Booking_ID`, `Booking_Date`, `Seats_Booked`, `Customer_ID`, `Show_ID`)
- `payment` (`Payment_ID`, `Amount`, `Payment_Mode`, `Payment_Date`, `Booking_ID`)

**There are no `actor`, `director`, or `producer` tables or endpoints yet** — if your
project needs those, that's new work, not something already built.

**Recommended:** on the machine where the database currently lives, export the actual
schema so it can be recreated elsewhere:
```
mysqldump -u root -p --no-data cinemadb > cinemadb_schema.sql
```
(add `--routines --triggers` if you use those). Share that file so anyone else can
run `mysql -u root -p cinemadb < cinemadb_schema.sql` to recreate the exact structure.

## 5. API endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/` | GET | Health check — confirms server is running |
| `/api/movies` | GET | List all movies |
| `/api/movies` | POST | Add a new movie *(just added)* |
| `/api/theatres` | GET | List all theatres |
| `/api/theatres` | POST | Add a new theatre *(just added)* |
| `/api/shows` | GET | List all shows with movie/screen/theatre details |
| `/api/shows` | POST | Add a new show *(just added)* |
| `/api/customers` | GET | List all customers |
| `/api/customers` | POST | Add a new customer *(just added)* |
| `/api/actors` | GET | List all actors *(just added)* |
| `/api/actors` | POST | Add a new actor *(just added)* |
| `/api/directors` | GET | List all directors *(just added)* |
| `/api/directors` | POST | Add a new director *(just added)* |
| `/api/producers` | GET | List all producers *(just added)* |
| `/api/producers` | POST | Add a new producer *(just added)* |
| `/api/screens` | GET | List all screens *(just added)* |
| `/api/screens` | POST | Add a new screen *(just added)* |
| `/api/bookings` | GET | List all bookings with customer/movie/theatre details |
| `/api/bookings` | POST | Create a booking |
| `/api/payments` | GET | List all payments |
| `/api/payments` | POST | Record a payment |

**Not implemented:** Login/auth. Everything else you listed (Movies, Actors, Directors,
Producers, Shows, Theatres, Customers, Bookings, Payments) now has working GET/POST
endpoints, matching your actual `cinemadb_schema.sql` column names.

### POST body examples
```
POST /api/movies       multipart/form-data — see section 11 (Movie posters) below, since it now accepts an image file
POST /api/theatres     { "Theatre_Name": "PVR Forum", "Location": "Bengaluru", "Contact_No": "080123456" }
POST /api/screens      { "Screen_Name": "Screen 1", "Capacity": 150, "Theatre_ID": 1 }
POST /api/shows        { "Show_Date": "2026-09-05", "Show_Time": "18:30:00", "Movie_ID": 1, "Screen_ID": 1 }
POST /api/customers    { "Customer_Name": "Suhas", "Phone": "9876543210", "Email": "suhas@example.com" }
POST /api/actors       { "Actor_Name": "Rajkumar", "DOB": "1990-05-12", "Gender": "Male", "Nationality": "Indian" }
POST /api/directors    { "Director_Name": "Rajamouli", "DOB": "1973-10-10", "Experience": 20 }
POST /api/producers    { "Producer_Name": "Karan Johar", "Production_House": "Dharma Productions" }
POST /api/bookings     { "Booking_Date": "2026-09-05", "Seats_Booked": 2, "Customer_ID": 1, "Show_ID": 1 }
POST /api/payments     { "Amount": 500, "Payment_Mode": "Card", "Payment_Date": "2026-09-05", "Booking_ID": 1 }
```
These field names are taken directly from your real `cinemadb_schema.sql` export, so
they should match your actual database without needing adjustment.

## 6. Port
`localhost:3000` by default. Configurable via `PORT` in `.env`.

## 7. Environment variables
Create a `.env` file (see `.env.example`) with:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=<your own MySQL password>
DB_NAME=cinemadb
PORT=3000
```
Each person running this locally uses their **own** MySQL password here — that's
the whole point of moving it out of `server.js`.

## 8. Login / authentication
**Not implemented.** There is no login endpoint and no user/auth table in this
project currently. If your assignment requires login, that needs to be built —
happy to help with that separately if you want.

## 9. Booking and payment
**Yes, both are implemented** (see the table in #5). Booking requires an existing
`Customer_ID` and `Show_ID`; payment requires an existing `Booking_ID` — both are
foreign keys, so trying to book with an ID that doesn't exist in the database will
fail with a MySQL foreign key error.

## 10. CORS
**Just added.** The server now has `cors()` enabled for all origins, so a frontend
running on a different port (e.g. a React dev server on `localhost:5173`) can call
this API without being blocked by the browser. If you later want to restrict it to
just your frontend's origin, that's a one-line change in `server.js`.

## 11. Movie posters
Posters are uploaded as image files, not just JSON, since they're actual pictures.

**One-time setup — run this in MySQL first** (I can't reach your database from here,
so you need to run it yourself):
```sql
ALTER TABLE movie ADD COLUMN Poster VARCHAR(255) DEFAULT NULL;
```

**How it works:**
- `POST /api/movies` now accepts `multipart/form-data` instead of plain JSON, so it can
  carry both text fields and an image file in one request.
- The image field must be named `poster` (jpg/jpeg/png/webp, max 5MB).
- Uploaded files are saved to `backend/uploads/posters/` and served at
  `http://localhost:3000/uploads/posters/<filename>`.
- The `movie` table stores just the path (e.g. `/uploads/posters/1725270000-123.jpg`)
  in the new `Poster` column — the actual image file lives on disk, not in the database.

**Testing with curl** (note `-F` for form fields instead of `-d` with JSON):
```
curl -X POST http://localhost:3000/api/movies ^
  -F "Title=Interstellar" ^
  -F "Genre=Sci-Fi" ^
  -F "poster=@C:\Users\Suhas\Pictures\interstellar.jpg"
```

**From a frontend form**, use a `<form>` with `enctype="multipart/form-data"` or, in
JavaScript, a `FormData` object:
```js
const formData = new FormData();
formData.append("Title", "Interstellar");
formData.append("Genre", "Sci-Fi");
formData.append("poster", fileInputElement.files[0]);

fetch("http://localhost:3000/api/movies", {
  method: "POST",
  body: formData // don't set Content-Type manually — the browser sets it with the boundary
});
```

**Displaying a poster** once a movie has one — `GET /api/movies` will now include a
`Poster` field like `/uploads/posters/xxx.jpg`; prefix it with your server's address:
```html
<img src="http://localhost:3000/uploads/posters/xxx.jpg">
```

**Note:** the `uploads/posters` folder is created automatically the first time the
server starts, and isn't included in the ZIP (it starts empty on each machine).

**Sample data:** `seed.sql` (see below) includes 15 movies, each with a `Poster` path
already set, pointing to placeholder poster art bundled in `uploads/posters/`. These
are original graphics generated for this project — not real movie posters, since
actual poster artwork is copyrighted and can't be redistributed. Swap them for your
own images any time via `POST /api/movies` with a real poster file, or by replacing
the files in `uploads/posters/` directly and updating the `Poster` column.

## 13. Login page
A login page now exists at `public/login.html`, served automatically once the
server is running — open `http://localhost:3000/login.html`.

**How it works:**
- New `login` table (not in the original ER diagram — added for authentication),
  with `Username` and a bcrypt-hashed `Password_Hash`.
- `POST /api/login` checks the submitted username/password against that table.
- This is a simple check for a college project — it returns success/failure only,
  it does **not** issue a session or token. If you need protected pages later
  (only viewable after login), that's a separate step we can add.

**Seed login (from seed.sql):**
```
Username: admin
Password: admin123
```
Change this before actually presenting the project, or add more accounts via:
```sql
-- generate a hash first (Node): 
-- node -e "require('bcrypt').hash('yourpassword', 10).then(console.log)"
INSERT INTO login (Login_ID, Username, Password_Hash) VALUES (2, 'yourname', '<hash>');
```

## 14. Frontend
A complete frontend now lives in `public/` and is served automatically by
`server.js` (via `express.static`) — no separate frontend server needed.

**Pages:** `login.html`, `index.html` (home), `movies.html` (poster grid — click
a movie to see its cast/director/producer, plus an "Add movie" form with poster
upload), `theatres.html`, `screens.html`, `shows.html`, `actors.html`,
`directors.html`, `producers.html`, `customers.html` — every one of these now has
its own "Add" form at the bottom of the page — plus `bookings.html` and
`payments.html` (which already had forms).

**To use it:** start the server, then open `http://localhost:3000/login.html`.
Log in with the seed account (Username `admin`, Password `admin123`) — you'll be
redirected to the home page, and every other page becomes reachable via the nav bar.

**Note on the login gate:** this is a simple client-side check for the demo
(`sessionStorage`), not real server-side session security — anyone who directly
opens e.g. `movies.html` without logging in gets redirected back to `login.html`,
but this isn't a substitute for real auth in a production app.

## 12. Sample data (seed.sql)
`seed.sql` fills every table with realistic sample rows so you have something to
demo immediately: 10 theatres, 15 screens, 15 movies (with posters), 12 actors,
10 directors, 10 producers, 12 customers, 15 shows, 12 bookings, 12 payments — all
correctly linked through foreign keys.

**To load it:**
```
mysql -u root -p cinemadb < seed.sql
```
(or use the full path to `mysql.exe` if it's not in your PATH)

**Warning:** this script starts with `TRUNCATE TABLE` on all affected tables, so it
wipes any existing rows in them first. Don't run it if you have real data you want
to keep.

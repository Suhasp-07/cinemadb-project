-- CinemaDB sample data (expanded)
-- Run this AFTER your tables already exist (from cinemadb_schema.sql)
-- Safe to re-run: it clears existing rows in these tables first.

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `cast`;
TRUNCATE TABLE movie_direction;
TRUNCATE TABLE movie_production;
TRUNCATE TABLE payment;
TRUNCATE TABLE booking;
TRUNCATE TABLE movie_show;
TRUNCATE TABLE screen;
TRUNCATE TABLE customer;
TRUNCATE TABLE movie;
TRUNCATE TABLE theatre;
TRUNCATE TABLE actor;
TRUNCATE TABLE director;
TRUNCATE TABLE producer;
TRUNCATE TABLE login;

SET FOREIGN_KEY_CHECKS = 1;

-- ============ THEATRES (10) ============
INSERT INTO theatre (Theatre_ID, Theatre_Name, Location, Contact_No) VALUES
(1, 'PVR Forum Mall', 'Koramangala, Bengaluru', '08041234561'),
(2, 'INOX Garuda Mall', 'Magrath Road, Bengaluru', '08041234562'),
(3, 'Cinepolis Nexus', 'Whitefield, Bengaluru', '08041234563'),
(4, 'PVR Orion Mall', 'Rajajinagar, Bengaluru', '08041234564'),
(5, 'INOX Mantri Square', 'Malleshwaram, Bengaluru', '08041234565'),
(6, 'Cinepolis Royal Meenakshi', 'Bannerghatta Road, Bengaluru', '08041234566'),
(7, 'PVR Vega City', 'Bannerghatta Road, Bengaluru', '08041234567'),
(8, 'INOX Bangalore Central', 'Residency Road, Bengaluru', '08041234568'),
(9, 'Urvashi Theatre', 'Lalbagh Road, Bengaluru', '08041234569'),
(10, 'Gopalan Cinemas', 'Mysore Road, Bengaluru', '08041234570');

-- ============ SCREENS (15) ============
INSERT INTO screen (Screen_ID, Screen_Name, Capacity, Theatre_ID) VALUES
(1, 'Screen 1', 180, 1),
(2, 'Screen 2 (IMAX)', 220, 1),
(3, 'Screen 1', 150, 2),
(4, 'Screen 2', 150, 2),
(5, 'Screen 1', 200, 3),
(6, 'Screen 2', 160, 3),
(7, 'Screen 1', 170, 4),
(8, 'Screen 1', 140, 5),
(9, 'Screen 2', 140, 5),
(10, 'Screen 1', 190, 6),
(11, 'Screen 1', 165, 7),
(12, 'Screen 2', 165, 7),
(13, 'Screen 1', 130, 8),
(14, 'Screen 1', 300, 9),
(15, 'Screen 1', 175, 10);

-- ============ MOVIES (15) ============
-- Poster column points to placeholder art in uploads/posters/ — original
-- graphics generated for this project, not real movie posters (copyrighted).
-- Replace with real poster files any time via POST /api/movies (see README).
INSERT INTO movie (Movie_ID, Title, Genre, Language, Duration, Release_Date, Budget, Box_Office_Collections, Poster) VALUES
(1, 'Interstellar', 'Sci-Fi', 'English', 169, '2014-11-07', 1650000000.00, 6770000000.00, '/uploads/posters/movie-1.jpg'),
(2, 'RRR', 'Action', 'Telugu', 182, '2022-03-25', 5500000000.00, 12000000000.00, '/uploads/posters/movie-2.jpg'),
(3, 'The Dark Knight', 'Action', 'English', 152, '2008-07-18', 1850000000.00, 10000000000.00, '/uploads/posters/movie-3.jpg'),
(4, 'Kantara', 'Thriller', 'Kannada', 150, '2022-09-30', 160000000.00, 4000000000.00, '/uploads/posters/movie-4.jpg'),
(5, 'Inception', 'Sci-Fi', 'English', 148, '2010-07-16', 1600000000.00, 8300000000.00, '/uploads/posters/movie-5.jpg'),
(6, 'KGF Chapter 2', 'Action', 'Kannada', 168, '2022-04-14', 1000000000.00, 12000000000.00, '/uploads/posters/movie-6.jpg'),
(7, 'Pushpa: The Rise', 'Action', 'Telugu', 179, '2021-12-17', 1300000000.00, 3600000000.00, '/uploads/posters/movie-7.jpg'),
(8, 'Baahubali 2', 'Fantasy', 'Telugu', 167, '2017-04-28', 2500000000.00, 17000000000.00, '/uploads/posters/movie-8.jpg'),
(9, 'Vikram', 'Action', 'Tamil', 174, '2022-06-03', 1000000000.00, 4400000000.00, '/uploads/posters/movie-9.jpg'),
(10, '3 Idiots', 'Comedy-Drama', 'Hindi', 170, '2009-12-25', 550000000.00, 4000000000.00, '/uploads/posters/movie-10.jpg'),
(11, 'Dangal', 'Sports-Drama', 'Hindi', 161, '2016-12-23', 700000000.00, 20000000000.00, '/uploads/posters/movie-11.jpg'),
(12, 'Jawan', 'Action', 'Hindi', 169, '2023-09-07', 3000000000.00, 12500000000.00, '/uploads/posters/movie-12.jpg'),
(13, 'Drishyam', 'Thriller', 'Malayalam', 160, '2013-02-15', 60000000.00, 500000000.00, '/uploads/posters/movie-13.jpg'),
(14, '777 Charlie', 'Drama', 'Kannada', 164, '2022-06-10', 160000000.00, 850000000.00, '/uploads/posters/movie-14.jpg'),
(15, 'Avengers: Endgame', 'Action', 'English', 181, '2019-04-26', 35600000000.00, 279000000000.00, '/uploads/posters/movie-15.jpg');

-- ============ ACTORS (12) ============
INSERT INTO actor (Actor_ID, Actor_Name, DOB, Gender, Nationality) VALUES
(1, 'N.T. Rama Rao Jr.', '1983-05-20', 'Male', 'Indian'),
(2, 'Ram Charan', '1985-03-27', 'Male', 'Indian'),
(3, 'Christian Bale', '1974-01-30', 'Male', 'British'),
(4, 'Rishab Shetty', '1983-04-06', 'Male', 'Indian'),
(5, 'Matthew McConaughey', '1969-11-04', 'Male', 'American'),
(6, 'Yash', '1986-01-08', 'Male', 'Indian'),
(7, 'Allu Arjun', '1983-04-08', 'Male', 'Indian'),
(8, 'Prabhas', '1979-10-23', 'Male', 'Indian'),
(9, 'Kamal Haasan', '1954-11-07', 'Male', 'Indian'),
(10, 'Aamir Khan', '1965-03-14', 'Male', 'Indian'),
(11, 'Shah Rukh Khan', '1965-11-02', 'Male', 'Indian'),
(12, 'Robert Downey Jr.', '1965-04-04', 'Male', 'American');

-- ============ DIRECTORS (10) ============
INSERT INTO director (Director_ID, Director_Name, DOB, Experience) VALUES
(1, 'S.S. Rajamouli', '1973-10-10', 25),
(2, 'Christopher Nolan', '1970-07-30', 28),
(3, 'Rishab Shetty', '1983-04-06', 12),
(4, 'Prashanth Neel', '1980-08-06', 10),
(5, 'Sukumar', '1970-01-15', 18),
(6, 'Lokesh Kanagaraj', '1986-05-24', 9),
(7, 'Rajkumar Hirani', '1962-11-08', 22),
(8, 'Nitesh Tiwari', '1973-11-11', 15),
(9, 'Atlee', '1986-09-20', 11),
(10, 'Jeethu Joseph', '1968-08-24', 20);

-- ============ PRODUCERS (10) ============
INSERT INTO producer (Producer_ID, Producer_Name, Production_House) VALUES
(1, 'D.V.V. Danayya', 'DVV Entertainment'),
(2, 'Emma Thomas', 'Syncopy'),
(3, 'Vijay Kiragandur', 'Hombale Films'),
(4, 'Naveen Yerneni', 'Mythri Movie Makers'),
(5, 'Shobu Yarlagadda', 'Arka Media Works'),
(6, 'Kevin Feige', 'Marvel Studios'),
(7, 'Aamir Khan', 'Aamir Khan Productions'),
(8, 'Gauri Khan', 'Red Chillies Entertainment'),
(9, 'Antony Perumbavoor', 'Aashirvad Cinemas'),
(10, 'Vidhu Vinod Chopra', 'VVC Films');

-- ============ CUSTOMERS (12) ============
INSERT INTO customer (Customer_ID, Customer_Name, Phone, Email) VALUES
(1, 'Ananya Reddy', '9876543211', 'ananya.reddy@example.com'),
(2, 'Rahul Verma', '9876543212', 'rahul.verma@example.com'),
(3, 'Priya Sharma', '9876543213', 'priya.sharma@example.com'),
(4, 'Karthik Iyer', '9876543214', 'karthik.iyer@example.com'),
(5, 'Divya Nair', '9876543215', 'divya.nair@example.com'),
(6, 'Arjun Menon', '9876543216', 'arjun.menon@example.com'),
(7, 'Sneha Kulkarni', '9876543217', 'sneha.kulkarni@example.com'),
(8, 'Vikram Rao', '9876543218', 'vikram.rao@example.com'),
(9, 'Meera Pillai', '9876543219', 'meera.pillai@example.com'),
(10, 'Aditya Joshi', '9876543220', 'aditya.joshi@example.com'),
(11, 'Kavya Krishnan', '9876543221', 'kavya.krishnan@example.com'),
(12, 'Nikhil Bhat', '9876543222', 'nikhil.bhat@example.com');

-- ============ SHOWS (15) ============
INSERT INTO movie_show (Show_ID, Show_Date, Show_Time, Movie_ID, Screen_ID) VALUES
(1, '2026-09-05', '18:30:00', 1, 1),
(2, '2026-09-05', '21:00:00', 2, 2),
(3, '2026-09-06', '15:00:00', 3, 3),
(4, '2026-09-06', '19:00:00', 4, 4),
(5, '2026-09-07', '17:30:00', 5, 5),
(6, '2026-09-07', '20:00:00', 6, 6),
(7, '2026-09-08', '14:00:00', 7, 7),
(8, '2026-09-08', '18:00:00', 8, 8),
(9, '2026-09-09', '16:30:00', 9, 9),
(10, '2026-09-09', '20:30:00', 10, 10),
(11, '2026-09-10', '15:30:00', 11, 11),
(12, '2026-09-10', '19:30:00', 12, 12),
(13, '2026-09-11', '17:00:00', 13, 13),
(14, '2026-09-11', '21:00:00', 14, 14),
(15, '2026-09-12', '18:30:00', 15, 15);

-- ============ BOOKINGS (12) ============
INSERT INTO booking (Booking_ID, Booking_Date, Seats_Booked, Customer_ID, Show_ID) VALUES
(1, '2026-09-04', 2, 1, 1),
(2, '2026-09-04', 4, 2, 2),
(3, '2026-09-05', 3, 3, 3),
(4, '2026-09-05', 1, 4, 4),
(5, '2026-09-06', 2, 5, 5),
(6, '2026-09-06', 5, 6, 6),
(7, '2026-09-07', 2, 7, 7),
(8, '2026-09-07', 3, 8, 8),
(9, '2026-09-08', 4, 9, 9),
(10, '2026-09-08', 1, 10, 10),
(11, '2026-09-09', 2, 11, 11),
(12, '2026-09-09', 6, 12, 12);

-- ============ PAYMENTS (12) ============
INSERT INTO payment (Payment_ID, Amount, Payment_Mode, Payment_Date, Booking_ID) VALUES
(1, 500.00, 'Card', '2026-09-04', 1),
(2, 1000.00, 'UPI', '2026-09-04', 2),
(3, 750.00, 'Card', '2026-09-05', 3),
(4, 250.00, 'Cash', '2026-09-05', 4),
(5, 500.00, 'UPI', '2026-09-06', 5),
(6, 1250.00, 'Card', '2026-09-06', 6),
(7, 500.00, 'UPI', '2026-09-07', 7),
(8, 750.00, 'Cash', '2026-09-07', 8),
(9, 1000.00, 'Card', '2026-09-08', 9),
(10, 250.00, 'UPI', '2026-09-08', 10),
(11, 500.00, 'Card', '2026-09-09', 11),
(12, 1500.00, 'UPI', '2026-09-09', 12);

-- ============ CAST — Movie <-> Actor (M:N) ============
INSERT INTO `cast` (Movie_ID, Actor_ID, Role_Name) VALUES
(1, 5, 'Joseph Cooper'),
(2, 1, 'Komaram Bheem'),
(2, 2, 'Alluri Sitarama Raju'),
(3, 3, 'Bruce Wayne / Batman'),
(4, 4, 'Shiva'),
(6, 6, 'Rocky'),
(7, 7, 'Pushpa Raj'),
(8, 8, 'Amarendra Baahubali'),
(9, 9, 'Vikram'),
(10, 10, 'Rancho'),
(11, 10, 'Mahavir Singh Phogat'),
(12, 11, 'Azad'),
(15, 12, 'Tony Stark / Iron Man');

-- ============ MOVIE_DIRECTION — Movie <-> Director (M:N) ============
INSERT INTO movie_direction (Movie_ID, Director_ID) VALUES
(1, 2),
(2, 1),
(3, 2),
(4, 3),
(5, 2),
(6, 4),
(7, 5),
(8, 1),
(9, 6),
(10, 7),
(11, 8),
(12, 9),
(13, 10);

-- ============ MOVIE_PRODUCTION — Movie <-> Producer (M:N) ============
INSERT INTO movie_production (Movie_ID, Producer_ID) VALUES
(1, 2),
(2, 1),
(3, 2),
(4, 3),
(5, 2),
(6, 3),
(7, 4),
(8, 5),
(10, 10),
(11, 7),
(12, 8),
(15, 6);

-- ============ LOGIN ============
-- Sample login: username "admin", password "admin123" (change after testing!)
INSERT INTO login (Login_ID, Username, Password_Hash) VALUES
(1, 'admin', '$2b$10$16otD7MeuyFPiU0SsDQCBOXFEFIyOI.IZgBCQmPC/W3.wvoe.YPR2');

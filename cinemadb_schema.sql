-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: cinemadb
-- ------------------------------------------------------
-- Server version	8.0.46
--
-- This is the FULL schema: your original tables (from mysqldump) plus the
-- three M:N junction tables from the ER diagram (cast, movie_direction,
-- movie_production), which were missing from the original database.

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `login`
-- NOTE: not part of the original ER diagram — added for authentication.
--

DROP TABLE IF EXISTS `login`;
CREATE TABLE `login` (
  `Login_ID` int NOT NULL,
  `Username` varchar(50) NOT NULL,
  `Password_Hash` varchar(255) NOT NULL,
  PRIMARY KEY (`Login_ID`),
  UNIQUE KEY `Username` (`Username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `actor`
--

DROP TABLE IF EXISTS `actor`;
CREATE TABLE `actor` (
  `Actor_ID` int NOT NULL,
  `Actor_Name` varchar(100) NOT NULL,
  `DOB` date DEFAULT NULL,
  `Gender` varchar(20) DEFAULT NULL,
  `Nationality` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Actor_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `director`
--

DROP TABLE IF EXISTS `director`;
CREATE TABLE `director` (
  `Director_ID` int NOT NULL,
  `Director_Name` varchar(100) NOT NULL,
  `DOB` date DEFAULT NULL,
  `Experience` int DEFAULT NULL,
  PRIMARY KEY (`Director_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `producer`
--

DROP TABLE IF EXISTS `producer`;
CREATE TABLE `producer` (
  `Producer_ID` int NOT NULL,
  `Producer_Name` varchar(100) NOT NULL,
  `Production_House` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Producer_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `movie`
--

DROP TABLE IF EXISTS `movie`;
CREATE TABLE `movie` (
  `Movie_ID` int NOT NULL,
  `Title` varchar(100) NOT NULL,
  `Genre` varchar(50) DEFAULT NULL,
  `Language` varchar(50) DEFAULT NULL,
  `Duration` int DEFAULT NULL,
  `Release_Date` date DEFAULT NULL,
  `Budget` decimal(15,2) DEFAULT NULL,
  `Box_Office_Collections` decimal(15,2) DEFAULT NULL,
  `Poster` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Movie_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `theatre`
--

DROP TABLE IF EXISTS `theatre`;
CREATE TABLE `theatre` (
  `Theatre_ID` int NOT NULL,
  `Theatre_Name` varchar(100) NOT NULL,
  `Location` varchar(150) DEFAULT NULL,
  `Contact_No` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`Theatre_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `screen`
--

DROP TABLE IF EXISTS `screen`;
CREATE TABLE `screen` (
  `Screen_ID` int NOT NULL,
  `Screen_Name` varchar(100) NOT NULL,
  `Capacity` int DEFAULT NULL,
  `Theatre_ID` int DEFAULT NULL,
  PRIMARY KEY (`Screen_ID`),
  KEY `Theatre_ID` (`Theatre_ID`),
  CONSTRAINT `screen_ibfk_1` FOREIGN KEY (`Theatre_ID`) REFERENCES `theatre` (`Theatre_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `movie_show`
--

DROP TABLE IF EXISTS `movie_show`;
CREATE TABLE `movie_show` (
  `Show_ID` int NOT NULL,
  `Show_Date` date NOT NULL,
  `Show_Time` time NOT NULL,
  `Movie_ID` int DEFAULT NULL,
  `Screen_ID` int DEFAULT NULL,
  PRIMARY KEY (`Show_ID`),
  KEY `Movie_ID` (`Movie_ID`),
  KEY `Screen_ID` (`Screen_ID`),
  CONSTRAINT `movie_show_ibfk_1` FOREIGN KEY (`Movie_ID`) REFERENCES `movie` (`Movie_ID`),
  CONSTRAINT `movie_show_ibfk_2` FOREIGN KEY (`Screen_ID`) REFERENCES `screen` (`Screen_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `Customer_ID` int NOT NULL,
  `Customer_Name` varchar(100) NOT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Customer_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `booking`
--

DROP TABLE IF EXISTS `booking`;
CREATE TABLE `booking` (
  `Booking_ID` int NOT NULL,
  `Booking_Date` date NOT NULL,
  `Seats_Booked` int NOT NULL,
  `Customer_ID` int DEFAULT NULL,
  `Show_ID` int DEFAULT NULL,
  PRIMARY KEY (`Booking_ID`),
  KEY `Customer_ID` (`Customer_ID`),
  KEY `Show_ID` (`Show_ID`),
  CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`Customer_ID`) REFERENCES `customer` (`Customer_ID`),
  CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`Show_ID`) REFERENCES `movie_show` (`Show_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment` (
  `Payment_ID` int NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `Payment_Mode` varchar(30) DEFAULT NULL,
  `Payment_Date` date DEFAULT NULL,
  `Booking_ID` int DEFAULT NULL,
  PRIMARY KEY (`Payment_ID`),
  UNIQUE KEY `Booking_ID` (`Booking_ID`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`Booking_ID`) REFERENCES `booking` (`Booking_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `cast` (M:N Movie <-> Actor, with Role_Name)
-- Note: CAST is a reserved SQL keyword, so it's always backtick-quoted.
--

DROP TABLE IF EXISTS `cast`;
CREATE TABLE `cast` (
  `Movie_ID` int NOT NULL,
  `Actor_ID` int NOT NULL,
  `Role_Name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Movie_ID`,`Actor_ID`),
  KEY `Actor_ID` (`Actor_ID`),
  CONSTRAINT `cast_ibfk_1` FOREIGN KEY (`Movie_ID`) REFERENCES `movie` (`Movie_ID`),
  CONSTRAINT `cast_ibfk_2` FOREIGN KEY (`Actor_ID`) REFERENCES `actor` (`Actor_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `movie_direction` (M:N Movie <-> Director)
--

DROP TABLE IF EXISTS `movie_direction`;
CREATE TABLE `movie_direction` (
  `Movie_ID` int NOT NULL,
  `Director_ID` int NOT NULL,
  PRIMARY KEY (`Movie_ID`,`Director_ID`),
  KEY `Director_ID` (`Director_ID`),
  CONSTRAINT `movie_direction_ibfk_1` FOREIGN KEY (`Movie_ID`) REFERENCES `movie` (`Movie_ID`),
  CONSTRAINT `movie_direction_ibfk_2` FOREIGN KEY (`Director_ID`) REFERENCES `director` (`Director_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `movie_production` (M:N Movie <-> Producer)
--

DROP TABLE IF EXISTS `movie_production`;
CREATE TABLE `movie_production` (
  `Movie_ID` int NOT NULL,
  `Producer_ID` int NOT NULL,
  PRIMARY KEY (`Movie_ID`,`Producer_ID`),
  KEY `Producer_ID` (`Producer_ID`),
  CONSTRAINT `movie_production_ibfk_1` FOREIGN KEY (`Movie_ID`) REFERENCES `movie` (`Movie_ID`),
  CONSTRAINT `movie_production_ibfk_2` FOREIGN KEY (`Producer_ID`) REFERENCES `producer` (`Producer_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed (schema + junction tables combined)

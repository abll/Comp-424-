-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 28, 2015 at 03:11 AM
-- Server version: 5.6.21
-- PHP Version: 5.6.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `userdatabase`
--

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
`UserID` int(11) NOT NULL COMMENT 'The column holds the userIDs. Need to add validation to make sure that the userID is unique. ',
  `user_name` varchar(100) NOT NULL COMMENT 'The column that holds Username',
  `first_name` varchar(255) NOT NULL COMMENT 'Holds the First Name Of the User',
  `last_name` varchar(255) NOT NULL COMMENT 'Holds the users last name',
  `Date_of_Birth` varchar(100) NOT NULL COMMENT 'The Column to hold date of birth. I am just doing it as text.',
  `user_email` varchar(255) NOT NULL COMMENT 'This the column for email. Need to add validation to make sure no duplicate emails (Real Time).',
  `password` varchar(20) NOT NULL COMMENT 'This will hold the pass word for the user. Make this max 20 chars'
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='This the table that will hold the user information. ';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`UserID`, `user_name`, `first_name`, `last_name`, `Date_of_Birth`, `user_email`, `password`) VALUES
(1, 'admin', 'Abel', 'Lawal', '01/01/1900', 'a@a.com', 'password'),
(2, 'mod', 'Hector', 'Bonilla', '02/01/1900', 'b@b.com', 'password');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
 ADD PRIMARY KEY (`UserID`), ADD UNIQUE KEY `user_name_UNIQUE` (`user_name`), ADD UNIQUE KEY `user_email_UNIQUE` (`user_email`), ADD UNIQUE KEY `UserID_UNIQUE` (`UserID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The column holds the userIDs. Need to add validation to make sure that the userID is unique. ',AUTO_INCREMENT=3;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

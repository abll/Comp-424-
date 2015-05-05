-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: May 04, 2015 at 06:16 AM
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
CREATE DATABASE IF NOT EXISTS `userdatabase` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `userdatabase`;

-- --------------------------------------------------------

--
-- Table structure for table `seceret question 1 table`
--

DROP TABLE IF EXISTS `seceret question 1 table`;
CREATE TABLE IF NOT EXISTS `seceret question 1 table` (
  `sq_1_ID` int(11) NOT NULL COMMENT 'The Secret Question 1 ID',
  `secret_Question` varchar(500) NOT NULL COMMENT 'The Actual Secret Questuin'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `seceret question 1 table`
--

INSERT INTO `seceret question 1 table` (`sq_1_ID`, `secret_Question`) VALUES
(1, '>Where were you when you had your first kiss?'),
(2, 'What was the last name of your third grade teacher?'),
(3, 'Where were you when you had your first alcoholic drink (or cigarette)?');

-- --------------------------------------------------------

--
-- Table structure for table `secret question 2`
--

DROP TABLE IF EXISTS `secret question 2`;
CREATE TABLE IF NOT EXISTS `secret question 2` (
  `sq_2_ID` int(11) NOT NULL COMMENT 'The ID for secret Question 2',
  `sq_2_question` varchar(500) NOT NULL COMMENT 'The Actual Question for Secret Question 2'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='The table for the secret question 2 ';

--
-- Dumping data for table `secret question 2`
--

INSERT INTO `secret question 2` (`sq_2_ID`, `sq_2_question`) VALUES
(3, 'What is the name of the first movie you saw in the theater?'),
(2, 'What is the name of the hospital you were born?'),
(1, 'Who was your childhood hero?');

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
  `password` varchar(20) NOT NULL COMMENT 'This will hold the pass word for the user. Make this max 20 chars',
  `sq_1_ID` int(11) NOT NULL COMMENT 'The Secret Question 1 ID',
  `sq_1_Answer` varchar(500) NOT NULL COMMENT 'The Answer to the secret question 1 ',
  `sq_2_ID` int(11) NOT NULL COMMENT 'The Secret Question 2 ID',
  `sq_2_answer` varchar(500) NOT NULL COMMENT 'The Answer to secret question 2 ',
  `temp_Password` varchar(45) DEFAULT NULL COMMENT 'The column that hold the temp code for email validation'
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COMMENT='This the table that will hold the user information. ';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`UserID`, `user_name`, `first_name`, `last_name`, `Date_of_Birth`, `user_email`, `password`, `sq_1_ID`, `sq_1_Answer`, `sq_2_ID`, `sq_2_answer`, `temp_Password`) VALUES
(1, 'admin', 'Abel', 'Lawal', '01/01/1900', 'a@a.com', 'password', 1, 'The Pyramid', 3, 'Toy Story', NULL),
(2, 'mod', 'Hector', 'Bonilla', '02/01/1900', 'b@b.com', '123456', 2, 'Rogers', 2, 'Guys Hospital', NULL),
(3, 'test', 'Testee', 'McGee', '03/01/1990', 'c@c.com', 'helloworld', 3, 'Hello', 3, 'World', NULL),
(4, 'AbeLinc', 'Abe', 'Lincoln', '11/15/1800', 'd@d.com', 'liberty', 0, 'Gettsyburg', 0, 'John Adams', NULL),
(5, 'abellaw', 'Abel', 'Lawal', '07/13/1988', 'e@e.com', 'abel', 0, 'The Pyramid', 0, 'Chris Haffey', NULL),
(6, 'Supd', 'Ben', 'Lawal', '05/28/1990', 'f@f.com', 'skate', 0, 'Rogers', 0, 'Guys Hospital', NULL),
(9, 'abellawasy', 'Abel', 'Lawal', '01/01/1988', 'abellawal@yahoo.com', 'salo', 0, 'The Pyramid', 0, 'Chris Haffey', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `seceret question 1 table`
--
ALTER TABLE `seceret question 1 table`
 ADD PRIMARY KEY (`sq_1_ID`), ADD UNIQUE KEY `sq_1_ID_UNIQUE` (`sq_1_ID`), ADD UNIQUE KEY `secret_Question_UNIQUE` (`secret_Question`);

--
-- Indexes for table `secret question 2`
--
ALTER TABLE `secret question 2`
 ADD PRIMARY KEY (`sq_2_ID`), ADD UNIQUE KEY `sq_2_ID_UNIQUE` (`sq_2_ID`), ADD UNIQUE KEY `sq_2_answer_UNIQUE` (`sq_2_question`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
 ADD PRIMARY KEY (`UserID`), ADD UNIQUE KEY `user_name_UNIQUE` (`user_name`), ADD UNIQUE KEY `user_email_UNIQUE` (`user_email`), ADD UNIQUE KEY `UserID_UNIQUE` (`UserID`), ADD UNIQUE KEY `temp_Password_UNIQUE` (`temp_Password`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The column holds the userIDs. Need to add validation to make sure that the userID is unique. ',AUTO_INCREMENT=10;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

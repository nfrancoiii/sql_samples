/* SQL Foundations */
/* Treehouse Database Foundations */
--PASSWORD FOR MYSQL COMMUNITY SERVER
-- V,qo)DF&d979
--FULL MESSAGE
/*
2016-02-11T05:42:47.913676Z 1 [Note] A temporary password 
is generated for root@localhost: V,qo)DF&d979
If you lose this password, please consult the section 
How to Reset the Root Password in the MySQL reference manual.
*/

--This line SELECTS (ALL*COLUMNS) FROM the table actors
SELECT*FROM actors;

CREATE TABLE actors (name VARCHAR(50));
/* 	CREATE is the command
	TABLE tells the command what object to CREATE
	actors is the name of the table
	name is the title of the first column
	VARCHAR specifies the data type of the column
	50 specifies the number of characters limit
*/

CREATE TABLE movies (title VARCHAR(200), year INTEGER);
--Command above shows that we can create multiple columns separated by commas

--ADD Data
INSERT INTO movies VALUES("Avatar", 2009);
/* 	INSERT is a keyword (command)
	INTO is a keyword directing the command
	movies is the name of the table we want to perform the operation on
	VALUES is a keyword that indicates we want to add values to the DB
	The arguments of VALUES are the data
	*/


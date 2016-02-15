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

-- Find all emails from the patrons table

-- SELECT <column name> FROM <table>;

SELECT email FROM patrons;

-- Find the first name and email from the patrons table

-- SELECT <column 1>, <column 2>, <column 3>, ... FROM <table>;

SELECT first_name, email FROM patrons;

-- Alias the first_published column with the words, "First Published"

-- SELECT <column> AS "<alias>" FROM <table>; Where "Title" becomes the
-- new header for the title data. We need to use quotes for headers of
-- multiple words.

SELECT title AS Title, first_published AS "First Published" FROM books;

-- What are the titles and authors of the books in the library published in 1997?

--- SELECT <columns> FROM <table> WHERE <column> <operator> <value>;

SELECT title, author FROM books WHERE first_published = 1997;

-- What are all the books authored by J.K. Rowling and what year were they first published?

--- SELECT <columns> FROM <table> WHERE <column> <operator> <value>;

SELECT title, first_published FROM books WHERE author = "J.K. Rowling";

-- What books were not authored by J.K. Rowling?

--- SELECT <columns> FROM <table> WHERE <column> <operator> <value>;

SELECT title, author, first_published FROM books WHERE author != "J.K. Rowling";

-- What books were loaned on the 10th of December 2015?

SELECT book_id FROM loans WHERE loaned_on = "2015-12-10";

-- Which book is book 15?

SELECT title FROM books WHERE id = 15;

--  What books are in the library that were first published after the year 2005?

SELECT * FROM books WHERE first_published > 2005;

--  What books are in the library that were first published in 2005 or later?

SELECT * FROM books WHERE first_published >= 2005;                                                                   

-- What are all books released before the 20th century?

SELECT * FROM books where first_published < 1900;      

-- SELECT <columns> FROM <table> WHERE <condition 1> AND/OR <condition 2>;

-- What books in our library were authored by J.K. Rowling before the year 2000?

SELECT title FROM books WHERE author = "J.K. Rowling" AND first_published < 2000;

-- SELECT <columns> FROM <table> WHERE <condition 1> AND/OR <condition 2>;

-- What books were either authored by J.K. Rowling or published before thr year 2000?

SELECT title FROM books WHERE author = "J.K. Rowling" OR first_published < 2000;

-- SELECT <columns> FROM <table> WHERE <condition 1> AND/OR <condition 2>;

-- What books do we have in the library authored by "Ernest Cline" or "Andy Weir"?

SELECT title FROM books WHERE author = "Ernest Cline" OR author = "Andy Weir";    

-- SELECT * FROM <table> WHERE <column> <operator> <value>;

-- What are all the loans that happened before December 13th 2015?

SELECT * FROM loans WHERE loaned_on <  "2015-12-13";

-- SELECT * FROM <table> WHERE <column> <operator> <value>;

-- What are all the loans that happened before December 13th 2015?

SELECT * FROM loans WHERE loaned_on <  "2015-12-13";

-- Who are the people with the Library IDs of MCL1001, MCL1100 or MCL1011?

-- SELECT <columns> FROM <table> WHERE <condition 1> OR <condition 2> OR <condition 3>;

SELECT first_name, email FROM patrons WHERE library_id = "MCL1001" OR library_id = "MCL1100" OR library_id = "MCL1011";

-- Who are the people with the Library IDs of MCL1001, MCL1100 or MCL1011?

-- SELECT <columns> FROM <table> WHERE <column> IN (<value 1>, <value 2>, <value …>);

SELECT first_name, email FROM patrons WHERE library_id IN ("MCL1001", "MCL1100", "MCL1011");
SELECT first_name, email FROM patrons WHERE library_id NOT IN ("MCL1001", "MCL1100", "MCL1011");

--- What are the book in the library from the 19th century?

SELECT title, author FROM books WHERE first_published >= 1800 AND first_published <= 1899;

-- SELECT <columns> FROM <table> WHERE <column> BETWEEN <value 1> AND <value 2>;

--- What are the book in the library from the 19th century?

SELECT title, author FROM books WHERE first_published BETWEEN 1800 AND 1899;

-- SELECT <columns> FROM <table> WHERE <column> BETWEEN <value 1> AND <value 2>;

-- What are the loans from week commencing Sunday 13th December 2015?

SELECT * FROM loans WHERE loaned_on BETWEEN "2015-12-13" AND "2015-12-19";

-- What are all Harry Potter books in the library?

SELECT title FROM books WHERE title = "Harry Potter";
-- 0 results

SELECT title FROM books WHERE title LIKE "Harry Potter"; 
-- 0 results

SELECT title FROM books WHERE title LIKE "Harry Potter%"; 
-- 7 results

-- Is the book by Andy Weir called "The Martian" or "Martian"?

SELECT title FROM books WHERE title LIKE "%Martian";

-- What non fiction books do we have with the "universe" anywhere in the title?

SELECT title FROM books WHERE title LIKE "%universe%" AND genre = "Non Fiction";                       

--- What are the loans that are due back after December 18th 2015?

SELECT * FROM loans WHERE return_by > "2015-12-18" AND returned_on IS NULL;

--- What are the loans that have been returned already?

SELECT * FROM loans WHERE return_by > "2015-12-18" AND returned_on IS NOT NULL;

-- Who is user 4?

SELECT first_name, email FROM patrons WHERE id = 4;
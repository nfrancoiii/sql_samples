/* Modifying Data with SQL */

/* CRUD -- Four Main Data Operations
	CREATE: INSERT
	READ: SELECT
	UPDATE: UPDATE
	DELETE: DELETE
*/

--- INSERT INTO <table> VALUES (<value 1>, <value 2>...);

INSERT INTO books VALUES (16, "1984", "George Orwell", "Fiction", 1949);

--- INSERT INTO <table> VALUES (<value 1>, <value 2>...);

INSERT INTO books VALUES (NULL, "Dune", "Frank Herbert", "Science Fiction", 1965);

-- INSERT INTO <table> (<column 1>, <column 2>...) VALUES (<value 1>, <value 2>...);

INSERT INTO loans (NULL, 2, 4, "2015-12-14", "2015-12-21", NULL);


-- INSERT INTO <table> (<column 1>, <column 2>...) VALUES (<value 1>, <value 2>...);

INSERT INTO loans (patron_id, loaned_on, return_by) 
VALUES (4, "2015-12-14", "2015-12-21");

-- Insert multiple rows

INSERT INTO books (title, author, genre, first_published) VALUES ("The Circle", "Dave Eggers", "Science Fiction", 2013);
INSERT INTO books (title, author, genre, first_published) VALUES ("Contact", "Carl Sagan", "Science Fiction", 1985);
INSERT INTO books (title, author, genre, first_published) VALUES ("Animal Farm", "George Orwell", NULL, 1945);

--BETTER ALTERNATIVE

INSERT INTO books (title, author, genre, first_published) VALUES 
  ("The Circle", "Dave Eggers", "Science Fiction", 2013),
  ("Contact", "Carl Sagan", "Science Fiction", 1985),
  ("Animal Farm", "George Orwell", NULL, 1945);


--UPDATE--

-- UPDATE <table> SET <column>=<value>;

UPDATE patrons SET last_name = "anonymous";

-- UPDATE <table> SET <column 1>=<value 1>, <column 2>=<value 2>;

UPDATE patrons SET email = "anon@email.com", zip_code = 55555;

-- UPDATE <table> SET <column> = <value> WHERE <condition>;

-- Example of how you would simply SELECT this row
SELECT * FROM books WHERE id = 20;

-- Example of how you would SELECT and UPDATE this row
UPDATE books SET genre = "Classic" WHERE id = 20;

UPDATE loans SET returned_on = "2015-12-18" WHERE patron_id = 1 
	AND returned_on IS NULL 
	AND book_id IN (4, 8);

-- Update the movie "The Ewok Adventure" to have the genre of "Sci Fi"

UPDATE movies SET genre = "Sci Fi" WHERE title LIKE "%Ewok%"; 

SELECT*FROM movies WHERE title LIKE "%Ewok%";

-- Update the movie with "Starfighter" in the title to be from the year 1984

UPDATE movies SET year_released = 1984 WHERE title LIKE "%Starfighter%";

-- Update all reviews with a negative rating to be 0.

UPDATE reviews SET rating = 0 WHERE rating < 0;

-- Update all review usernames to "Anonymous"

UPDATE reviews SET username = "Anonymous";

-- DELETE FROM <table>;

--DELETES ALL VALUES FROM books TABLE
DELETE FROM books;

-- DELETE FROM <table>;

--DELETES ALL ROWS FROM patrons TABLE
DELETE FROM patrons;

-- DELETE FROM <table> WHERE <condition>;

--REMOVES ALL HARRY POTTER BOOKS
DELETE FROM books WHERE title LIKE "Harry Potter%";

-- DELETE FROM <table> WHERE <condition>;

DELETE FROM patrons WHERE id = 4;

DELETE FROM loans WHERE patron_id = 4;


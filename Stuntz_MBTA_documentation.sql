-------------------
-- DOCUMENTATION --
-------------------

-- PostgreSQL Documentation:
http://www.postgresql.org/docs/9.3/static/

------------
-- TABLES --
------------

-- Create an empty table
DROP TABLE IF EXISTS [table];
CREATE TABLE [table]
	(
	[variable] character varying,
	[variable] smallint,
	...
	)
WITH (OIDS=FALSE);

-- Import CSV into a table in pgAdmin
	-- Click on destination table
	-- Tools --> Import... 
	-- File Options: Format=csv 
	-- Misc Options: Header

-- Create a sequence of tables

	-- Option A: Create Temporary Tables
	DROP TABLE IF EXISTS [table1];
	CREATE TEMPORARY TABLE [table1] AS 
		SELECT ...
	;
	ANALYZE [table1];
	CREATE TEMPORARY TABLE [table2] AS
		SELECT ...
	;
	ANALYZE [table1];
	SELECT ...

	-- Option B: Common Table Expressions
	WITH [tablename1] AS (
		[Query]
	) [t1],
	[tablename2] AS (
		[Query]
	) [t2]
	SELECT ...

	-- Option C: Subqueries
	SELECT *
	FROM (
		SELECT v1, v2
		FROM (
			SELECT v1, v2, v3
			FROM [table]
			)
		)

-- Update a table
UPDATE [table]
SET [variable] = 1
WHERE 1=1
	AND [condition]
;

-- Insert a row into a table
INSERT INTO [table] ([colname1], [colname2]) 
VALUES ([col1value], [col2value]);

-------------
-- QUERIES --
-------------

-- Create a general query
SELECT 
	[t.]*, -- all variables in table with alias t
	t.v1, -- variable v1 from table with alias t
	j.x1, -- variable w2 from table with alias j, renamed as v2
	SUM(v2)*2 AS sumx2,
	MAX(v2) AS max,
	MIN(v2) AS min,
	ROUND(AVG(v2),2) AS avg,
	COUNT(*) AS count, -- count # of transactions by group based on GROUP BY variables below
	CASE WHEN [condition] THEN [value or variable]
		WHEN [condition] THEN [value or variable]
		[ELSE [value or variable]]
	END AS new1,
	COALESCE(v3,v4) AS new2, -- Returns first non-null argument
	NULLIF(v3,v4) AS new3, -- Returns NULL if values are equal, otherwise returns first value (v3)
	GREATEST(v3,v4) AS new4, -- Returns maximum, ignoring nulls
	LEAST(v3,v4) AS new5, -- Returns minimum, ignoring nulls
	lag(v5) OVER windowname AS v5lag1 -- lagged variable over window defined in WINDOW clause below (default lag = 1)
	lead(v5,3) OVER (PARTITION BY t.v1, j.x1 ORDER BY timevar) AS v5lead3 -- lead variable (3 ahead) over window defined by PARTITION BY statement
[INTO [schema].[table]] -- Save results into a table
FROM 
	[schema].[table] t -- t is alias used to reference table
	LEFT JOIN jointable j ON t.v1 = j.x2 AND v3 > 5 -- join, keeping all rows in the original table (t)
WHERE 1=1
	AND t.v1 IN ([comma-separated list of values, or subquery])
	AND j.x1 BETWEEN [lower bound inclusive] AND [upper bound inclusive]
	AND timevar - interval '10 minutes' > '2015-07-08 03:00:00'
GROUP BY v4, v5
WINDOW windowname AS 
	(PARTITION BY t.v1, j.x1 ORDER BY timevar)
ORDER BY 
	t.v1 ASC, -- default sort order is ASC, can be omitted 
	j.x2 DESC
LIMIT 100 -- return first 100 resulting rows
	

-- Window functions
http://www.postgresql.org/docs/8.4/static/functions-window.html
http://www.besttechtools.com/articles/article/sql-rank-functions
-- NOTE: The window frame, if not specified, is from the first observation in the window up to the current observation
SELECT
	row_number() 	OVER windowname AS rownum,
	rank() 		OVER windowname AS rank,
	dense_rank() 	OVER windowname AS denserank,
	percent_rank()	OVER windowname AS pctrank,
	cume_dist()	OVER windowname AS cumdist,
	lead(v4) 		OVER windowname AS lead1,
	lag(v4,3)		OVER windowname AS lag3,
	firstrow(v4)	OVER (PARTITION BY v1, v2 ORDER BY v3 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS firstval, -- returns first value within each group for the whole group (i.e. value of v4 for the first row in each window)
	last_value(v4) OVER (PARTITION BY v1, v2 ORDER BY v3 ROWS BETWEEN 2 PRECEDING AND UNBOUNDED FOLLOWING) AS lastval, -- Need to pick up the whole window to get last value
	nth_value(v4,7) OVER (PARTITION BY v1, v2 ORDER BY v3 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastval, -- Probably need to pick up the whole window to ensure you get nth value
	SUM(v4) 		OVER windowname AS runsum, -- running sum (window frame is from the first row in the window to the current row)
	SUM(v4)		OVER (PARTITION BY v1, v2 ORDER BY v3 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS sumtotal1, -- total sum, achieved by explicitly including entire window
	SUM(v4)		OVER (PARTITION BY v1, v2) -- total sum, achieved by not sorting within the window
WINDOW windowname AS (PARTITION BY v1, v2 ORDER BY v3)


-- Select only first record in each group (e.g. first weather report in each month by location)
SELECT DISTINCT ON (location) 
	location, time, report
FROM weather_reports
ORDER BY location, time DESC;

0 SQL Notes and Examples.sql
Mostrando Single Ride Equivalent Value_2016_02_09_No Comments.sql.
-- Andrew Stuntz
-- MIT Transit Lab
-- Updated 2-9-2016

-----------
-- NOTES --
-----------

-- FUNCTION
-- This program estimates the single-ride-equivalent fares for Link Pass usage on the AFC system

-- USER INPUTS
-- List of monthly LinkPass card IDs (Part I, stuntz.testcards)
-- Date range (Part I)
-- Mode to fare service relationship (Part V, stuntz.modetoservice)
-- Fares by service, including transfers (Part V, stuntz.fares)

----------------------------------
-- PART 0: Create Lookup Tables --
----------------------------------
/*
DROP TABLE IF EXISTS stuntz.deviceclasstype;
CREATE TABLE stuntz.deviceclasstype
	(deviceclasstype smallint,
	shortdesc character varying,
	longdesc character varying)
WITH (OIDS=FALSE);

DROP TABLE IF EXISTS stuntz.deviceclasstoagency;
CREATE TABLE stuntz.deviceclasstoagency
	(deviceclassid integer,
	agency character varying,
	notes character varying)
WITH (OIDS=FALSE);

DROP TABLE IF EXISTS stuntz.modetoservice;
CREATE TABLE stuntz.modetoservice
	(mode character varying,
	busroute smallint,
	service character varying)
WITH (OIDS=FALSE);

DROP TABLE IF EXISTS stuntz.fares;
CREATE TABLE stuntz.fares
	(service character varying,
	prev_service character varying,
	fare integer)
WITH (OIDS=FALSE);

DROP TABLE IF EXISTS stuntz.testcards;
CREATE TABLE stuntz.testcards (ticketserial bigint) WITH (OIDS=FALSE);
*/

-- Then import contents from csv files
	-- Tools --> Import... 
	-- File Options: Format=csv 
	-- Misc Options: Header


-----------------------------------
-- PART I: Clean and Filter Data --
-----------------------------------

-- A. Identify cancelled transactions and filter observations
	DROP TABLE IF EXISTS faretransaction1a;
	CREATE TEMPORARY TABLE faretransaction1a AS 
		SELECT 
			ticketserial,			-- Card number
			ticketstocktype,		-- Ticket stock type
			tickettypeversion,		-- Fare product version
			tickettypeid,			-- Fare product type ID
			f.deviceclassid,		-- Device class
			trxtime,				-- Transaction time
			amount,				-- AFC transaction amount (for checking)
			locationid,			-- Location (for window in next step)
			cardmovementseqno,		-- Event sequence (for window in next step)
			signcodeid,			-- Signcode (for Part II)
			-- 1. Identify cancelled transactions
			CASE WHEN 
				-- Cancellation
				bookcanc = -1
				-- Transaction corresponding to cancellation (same salestransactionno as cancellation, but lower cardmovementseqno)
				OR (	lead(salestransactionno)	OVER w1a = salestransactionno 
					AND 	lead(bookcanc) 	OVER w1a = -1)  
				THEN 1 ELSE 0
			END AS flag_cancellation
		FROM 
			afc.faretransaction f
			LEFT JOIN stuntz.deviceclasstoagency a ON f.deviceclassid = a.deviceclassid -- Agency
		WHERE 1=1
			-- Cards from list
				AND f.ticketserial IN (SELECT ticketserial FROM stuntz.testcards) 
			-- Validations
				AND movementtype IN (7, 20) -- 7=Validation, 20=Cash and Go
			-- Only MBTA devices (exclude other regional transit authorities, which have separate pass products)
				AND a.agency = 'MBTA'
			-- Transactions within time period
				AND trxtime >= '2015-07-01 00:00:00' AND trxtime < '2015-08-01 00:00:00'
			-- Only Monthly Link Passes
				AND tickettypeid = 602800100
		WINDOW w1a AS 
			-- Partition by card (serial and stocktype)
			-- Order by both time and cardmovementseqno because cancelled transactions have the same time but ordered cardmovementseqno's
			(PARTITION BY f.ticketserial, f.ticketstocktype ORDER BY trxtime, cardmovementseqno)
	;
	ANALYZE faretransaction1a;
	-- SELECT * FROM faretransaction1a LIMIT 100

-- B. Drop cancelled transactions and identify "multitaps"
	DROP TABLE IF EXISTS faretransaction1b;
	CREATE TEMPORARY TABLE faretransaction1b AS 
		SELECT f1a.*,
			-- 2. Identify "multitaps" (after an initial tap with a pass, subsequent taps would be paid out of stored value)
			-- NOTE: This must be performed after dropping cancelled transactions for the window lag functions to correctly identify multitaps
			CASE WHEN (	
				-- Multiple taps at the same location within 10 minutes of each other (excluding the initial tap)
				lag(locationid) OVER w1b = locationid
				AND lag(trxtime) OVER w1b > (trxtime - interval '10 minutes'))
				THEN 1 ELSE 0
			END AS flag_multitap
		FROM faretransaction1a f1a
		WHERE flag_cancellation=0 	-- Drop cancelled transactions
		WINDOW w1b AS 
			-- Partition by card (serial and stocktype), order by time and cardmovementseqno (same as previous step)
			(PARTITION BY f1a.ticketserial, f1a.ticketstocktype ORDER BY trxtime, cardmovementseqno)
	;
	ANALYZE faretransaction1b;
-- 	SELECT * FROM faretransaction1b LIMIT 100

-- C. Drop "multitaps"
	DROP TABLE IF EXISTS faretransaction1;
	CREATE TEMPORARY TABLE faretransaction1 AS SELECT * FROM faretransaction1b WHERE flag_multitap=0;
	ANALYZE faretransaction1;
	-- SELECT * FROM faretransaction1 LIMIT 100


-----------------------------
-- PART II: Identify Trips --
-----------------------------

DROP TABLE IF EXISTS faretransaction2;
CREATE TEMPORARY TABLE faretransaction2 AS 
	SELECT
		ticketserial,			-- Card number
		ticketstocktype,		-- Ticket stock type
		tickettypeversion,		-- Fare product version
		tickettypeid,			-- Fare product type ID
		f1.deviceclassid,		-- Device class
		trxtime,				-- Transaction time
		-- Mode
		CASE WHEN dt.shortdesc IN ('GATE','FMV') 										THEN m1.nameshort	-- Gates and validators
			WHEN dt.shortdesc = 'FBX' AND b2.namelong IS NULL 							THEN 'Bus' 		-- Fareboxes, not Silver / Green / Mattapan
			WHEN dt.shortdesc = 'FBX' AND b2.namelong IS NOT NULL 							THEN m2.nameshort	-- Fareboxes, Silver / Green / Mattapan
			WHEN dt.shortdesc = 'HHT' AND s.nameshort IN ('Riverside Garage','Reservoir Garage') THEN 'LR' 		-- Handheld Terminals on Green Line 
			END AS mode,																				
		-- Bus route
		CASE WHEN dt.shortdesc = 'FBX' AND (b2.namelong IS NULL OR b2.namelong = 'Silver Line') 	THEN sc.parentroute -- Fareboxes, bus including Silver
			END AS busroute,
		-- Line
		CASE WHEN dt.shortdesc IN ('GATE','FMV') 										THEN L1.nameshort 	-- Gates, validators
			WHEN dt.shortdesc = 'FBX' AND b2.namelong IS NOT NULL 							THEN L2.nameshort 	-- Fareboxes, Silver / Green / Mattapan
			WHEN dt.shortdesc = 'HHT' AND s.nameshort IN ('Riverside Garage','Reservoir Garage') THEN 'Green' 		-- Handheld Terminals on Green Line 
			END AS line,				
		-- Branch
		CASE WHEN dt.shortdesc IN ('GATE','FMV') 										THEN b1.nameshort 	-- Gates, validators
			WHEN dt.shortdesc = 'FBX' AND b2.namelong IS NOT NULL 							THEN b2.nameshort	-- Fareboxes, Silver / Green / Mattapan
			END AS branch, 
		-- Station
		CASE WHEN dt.shortdesc IN ('GATE','FMV')										THEN s.nameshort	-- Gates, validators
			END AS station, 
		amount				-- AFC transaction amount (for checking)
	FROM
		faretransaction1 f1
		-- Get device class type
		LEFT JOIN afc.deviceclass dc 		ON f1.deviceclassid = dc.deviceclassid
		LEFT JOIN stuntz.deviceclasstype dt ON dc.deviceclasstype = dt.deviceclasstype
		-- Get mode / line / branch / station for gates, fare media validators, and handheld terminals
		LEFT JOIN afc.station s 			ON f1.locationid = s.stationid	-- Get station
		LEFT JOIN rpt.stationToBranch sb 	ON sb.stationid = s.stationid		-- Get branchid
		LEFT JOIN rpt.branch b1 			ON b1.branchid = sb.branchid		-- Get branch
		LEFT JOIN rpt.line L1 			ON L1.lineid = b1.lineid			-- Get line
		LEFT JOIN rpt.mode m1 			ON m1.modeid = L1.modeid			-- Get mode
		-- Get mode / line / branch for fareboxes
		LEFT JOIN afc.signcode sc 		ON f1.signcodeid = sc.signcodeid	-- Get route
		LEFT JOIN rpt.routetobranch rb 	on rb.routeid = sc.parentroute	-- Get branchid
		LEFT JOIN rpt.branch b2 			on b2.branchid = rb.branchid		-- Get branch
		LEFT JOIN rpt.line L2 			on L2.lineid = b2.lineid			-- Get line
		LEFT JOIN rpt.mode m2 			on m2.modeid = L2.modeid			-- Get mode
;
ANALYZE faretransaction2;
-- SELECT * FROM faretransaction2 LIMIT 100


---------------------------------------
-- PART III: Identify Previous Trips --
---------------------------------------

DROP TABLE IF EXISTS faretransaction3;
CREATE TEMPORARY TABLE faretransaction3 AS
	SELECT 
		ticketserial,							-- Card number 
		ticketstocktype,						-- Ticket stock type
		tickettypeversion,						-- Fare product version
		tickettypeid,							-- Fare product type ID
		deviceclassid,							-- Device class
		trxtime, 								-- Transaction time
		mode, 								-- Mode
		busroute, 							-- Bus route
		line, 								-- Line
		branch, 								-- Branch
		station, 								-- Station
		lag(mode) OVER w3 AS prev_mode, 			-- Previous mode
		lag(busroute) OVER w3 AS prev_busroute,		-- Previous bus route
		lag(line) OVER w3 AS prev_line,			-- Previous line
		lag(branch) OVER w3 AS prev_branch,		-- Previous branch
		lag(station) OVER w3 AS prev_station,		-- Previous station
		trxtime - lag(trxtime) OVER w3 AS time_lag,	-- Time since previous transaction
		amount								-- AFC transaction amount (for checking)
	FROM faretransaction2
	WINDOW w3 AS 
		-- Partition by card (serial and stocktype), ordered by time, to find identify previous trip
		(PARTITION BY ticketserial, ticketstocktype ORDER BY trxtime)
;
ANALYZE faretransaction3;
-- SELECT * FROM faretransaction3 -- LIMIT 100


--------------------------------------
-- PART IV: Idenfity Fare Transfers --
--------------------------------------

-- A. Identify fare transfers based on previous trip and transfer rules
	DROP TABLE IF EXISTS faretransaction4a;
	CREATE TEMPORARY TABLE faretransaction4a AS
		SELECT 
			f3.*,
			CASE WHEN 1=1
			-- RULE: Within 2 hours
				AND time_lag < interval '02:00:00'
			-- RULE: No tranfers along same bus route
				AND (busroute <> prev_busroute OR busroute IS NULL OR prev_busroute IS NULL)
			-- RULE: No transfers between rail lines, excluding Mattapan - Red Line transfers
				AND NOT ( 
						(mode IN ('HR','LR') AND branch <> 'Mattapan')
					AND 	(prev_mode IN ('HR','LR') AND branch <> 'Mattapan')
				)
				-- No transfers from Mattapan to Mattapan
				AND NOT (
						(branch = 'Mattapan' AND branch IS NOT NULL)
					AND 	(prev_branch = 'Mattapan' and prev_branch IS NOT NULL)
				)
				THEN 1 ELSE 0
			END AS transfertemp		-- Transfer indicator (0=non-transfer, 1=transfer)
		FROM faretransaction3 f3
	;
	ANALYZE faretransaction4a;
	-- SELECT * FROM faretransaction4a LIMIT 100

-- B. Create a journey (linked trip) index
	DROP TABLE IF EXISTS faretransaction4b;
	CREATE TEMPORARY TABLE faretransaction4b AS
		SELECT 
			f4a.*,
			SUM(1-transfertemp) OVER (PARTITION BY ticketserial, ticketstocktype ORDER BY trxtime) AS journeyindex
		FROM faretransaction4a f4a
	;
	ANALYZE faretransaction4b;
	-- SELECT * FROM faretransaction4b LIMIT 100

-- C. Create a transfer index within each journey (linked trip)
	DROP TABLE IF EXISTS faretransaction4c;
	CREATE TEMPORARY TABLE faretransaction4c AS
		SELECT 
			f4b.*,
			SUM(transfertemp) OVER (PARTITION BY ticketserial, ticketstocktype, journeyindex ORDER BY trxtime) AS runtransfer
		FROM faretransaction4b f4b
	;
	ANALYZE faretransaction4c;
	-- SELECT * FROM faretransaction4c LIMIT 100
	
-- D. Create a final transfer indicator
	DROP TABLE IF EXISTS faretransaction4;
	CREATE TEMPORARY TABLE faretransaction4 AS
		SELECT 
			ticketserial,							-- Card number 
			ticketstocktype,						-- Ticket stock type
			tickettypeversion,						-- Fare product version
			tickettypeid,							-- Fare product type ID
			deviceclassid,							-- Device class
			trxtime, 								-- Transaction time
			mode, 								-- Mode
			busroute, 							-- Bus route
			line, 								-- Line
			branch, 								-- Branch
			station, 								-- Station
			prev_mode, 							-- Previous mode
			prev_busroute,							-- Previous bus route
			prev_line,							-- Previous line
			prev_branch,							-- Previous branch
			prev_station,							-- Previous station
			time_lag,								-- Time since previous transaction
			amount,								-- AFC transaction amount (for checking)
			-- RULE: Only 1 free/discounted transfer is earned per tap
				CASE WHEN runtransfer % 2 = 0 THEN 0 ELSE 1 	-- For 2nd and 4th transfers, have to pay full fare (transfer = 0)
				END AS transfer 						-- Transfer indicator (0=non-transfer, 1=transfer)
		FROM faretransaction4c f4c
	;
	ANALYZE faretransaction4;

-- SELECT * FROM faretransaction4 LIMIT 100


----------------------------------------
-- PART V: Look up services and fares --
----------------------------------------

-- NOTE: All express bus routes are assumed to charge local bus fares (see stuntz.fares)

-- Find service from NTD mode and look up fares
DROP TABLE IF EXISTS faretransaction5;
CREATE TEMPORARY TABLE faretransaction5 AS
	SELECT 
		-- Transaction
			ticketserial,					-- Card number 
			ticketstocktype,				-- Ticket stock type
			tickettypeversion,				-- Fare product version
			tickettypeid,					-- Fare product type ID
			f4.deviceclassid,					-- Device class ID
			trxtime, 						-- Transaction time
		-- Fare Service
			f4.mode, 						-- Mode
			f4.busroute, 					-- Bus route
			line, 						-- Line
			branch, 						-- Branch
			station, 						-- Station
			ms1.service,					-- Fare service
		-- Previous Fare Service
			prev_mode, 					-- Previous mode
			prev_busroute,					-- Previous bus route
			prev_line,					-- Previous line
			prev_branch,					-- Previous branch
			prev_station,					-- Previous station
			ms2.service AS prev_service,		-- Previous fare service
			time_lag,						-- Time since previous transaction
		-- Transfer
			transfer,						-- Transfer indicator (0=non-transfer, 1=transfer)
		-- Fare
			COALESCE(p1.fare,p2.fare) AS fare,	-- Predicted fare
		-- Checking
			amount,								-- AFC transaction amount (for validating against SV transacations)
			COALESCE(p1.fare,p2.fare) - amount AS diff	-- Difference between predicted fare and AFC transaction amount
	FROM 
		faretransaction4 f4
		-- Join fare service 
			-- For current trip
			LEFT JOIN stuntz.modetoservice ms1 ON f4.mode = ms1.mode AND (f4.busroute = ms1.busroute OR (f4.busroute IS NULL AND ms1.busroute IS NULL))
			-- For previous trip
			LEFT JOIN stuntz.modetoservice ms2 ON f4.prev_mode = ms2.mode AND (f4.prev_busroute = ms2.busroute OR (f4.prev_busroute IS NULL AND ms2.busroute IS NULL))
		-- Join fares 
			-- Join for non-transfers based on the current fare service
			LEFT JOIN stuntz.fares p1 ON (ms1.service = p1.service) AND (transfer = 0 AND p1.prev_service IS NULL)
			-- Join for transfers based on the current fare service and the previous fare service
			LEFT JOIN stuntz.fares p2 ON (ms1.service = p2.service) AND (transfer = 1 AND ms2.service = p2.prev_service)
	ORDER BY ticketserial, trxtime
;
ANALYZE faretransaction5;
-- SELECT * FROM faretransaction5




------------------------
-- PART VI: Summarize --
------------------------

SELECT ticketserial, SUM(fare) AS totalfare
FROM faretransaction5
GROUP BY ticketserial
ORDER BY ticketserial


Single Ride Equivalent Value_2016_02_09_No Comments.sql
Mostrando Single Ride Equivalent Value_2016_02_09_No Comments.sql.
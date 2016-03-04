/*	
	Nicholas Franco III
	DPL ELECTRIC 2015 (107561)
	AURORA Model Outputs
	February 24, 2016
*/

/* 	This Query extracts unit-level detail for the
	DP&L units that are at-risk of retiring without
	the subsidies in the Electric Security Plan. This
	query select the columns required for the 
	financial analysis
*/

SELECT  -- Columns needed for financial analysis
	 	Run_ID AS "Scenario",  
		Time_Period AS "Year_Month", 	
		Zone, 
		Name AS "Unit",
		Output_MWH AS "Generation (MWh)",
		Revenue AS "Gross Energy Revenues ($000)",
		Total_Fuel_Cost AS "Total Fuel Cost ($000)",
		Variable_OM_Cost AS "Total VOM Cost ($000)",
		Total_Emission_Cost AS "Total Emission Cost ($000)"
FROM 	-- Table with Monthly Unit Operation
		ResourceMonth1
WHERE	-- Select "Average" as opposed to "On/Off Peak"
		Condition = "Average" AND 
		-- We do not need to report 2016 values
		Time_Period NOT LIKE "%2016%" AND
		-- Select all of the DP&L Units
		Name IN ("Conesville #4",
				 "JM Stuart #1 EIA2850",
				 "JM Stuart #2 EIA2850",
				 "JM Stuart #3 EIA2850",
				 "JM Stuart #4 EIA2850",
				 "Killen Stuart #2",
				 "WH Zimmer #ST1",
				 "Clifty Creek #1",
				 "Clifty Creek #2",
				 "Clifty Creek #3",
				 "Clifty Creek #4",
				 "Clifty Creek #5",
				 "Clifty Creek #6",
				 "Kyger Creek #1",
				 "Kyger Creek #2",
				 "Kyger Creek #3",
				 "Kyger Creek #4",
				 "Kyger Creek #5",
				 "Miami Fort #7",
				 "Miami Fort #8")

/* 	This query selects the relevant information 
	from the emissions table for the DP&L units
	at-risk of retirement.
*/

SELECT 	Run_ID AS "Scenario",
		Time_Period AS "Year_Month",
		Resource_Name AS "Unit",
		Type AS "Emission",
		Cost AS "Emission Cost ($000)"
FROM
		ResourceEmissionsMonth1
WHERE
		Condition = "Average" AND
		Type != "HG" AND
		Resource_Name IN ("Conesville #4",
				 "JM Stuart #1 EIA2850",
				 "JM Stuart #2 EIA2850",
				 "JM Stuart #3 EIA2850",
				 "JM Stuart #4 EIA2850",
				 "Killen Stuart #2",
				 "WH Zimmer #ST1",
				 "Clifty Creek #1",
				 "Clifty Creek #2",
				 "Clifty Creek #3",
				 "Clifty Creek #4",
				 "Clifty Creek #5",
				 "Clifty Creek #6",
				 "Kyger Creek #1",
				 "Kyger Creek #2",
				 "Kyger Creek #3",
				 "Kyger Creek #4",
				 "Kyger Creek #5",
				 "Miami Fort #7",
				 "Miami Fort #8")
/* 	Create a Table that Merges the two tables */

/********************************************************/
/**IN MS ACCESS**/
/********************************************************/

/*	Create MASTER Table */
CREATE TABLE DPL_Resources(
	Run_ID VARCHAR(200),
	Time_Period VARCHAR(200),
	Name VARCHAR(50),
	Output_MWH INT,
	Revenue DOUBLE,
	Total_Fuel_Cost DOUBLE,
	Variable_OM_Cost DOUBLE,
	Total_Emission_Cost DOUBLE,
	CO2_Cost DOUBLE,
	NOX_Cost DOUBLE,
	SO2_Cost DOUBLE)

/* 	Create Empty Unit Operation Table */
CREATE TABLE DPL_Resources_Operations(
	Run_ID VARCHAR(200),
	Time_Period VARCHAR(200),
	Zone VARCHAR(20),
	Name VARCHAR(50),
	Output_MWH DOUBLE,
	Revenue DOUBLE,
	Total_Fuel_Cost DOUBLE,
	Variable_OM_Cost DOUBLE,
	Total_Emission_Cost DOUBLE)

/*	Create Empty Unit Emission Table */
CREATE TABLE DPL_Resources_Emissions(
	Run_ID VARCHAR(200),
	Time_Period VARCHAR(200),
	Resource_Name VARCHAR(50),
	Type VARCHAR(10),
	Cost DOUBLE)

/* 	Insert the data from the operation table into
	the master table.
*/

INSERT INTO DPL_Resources
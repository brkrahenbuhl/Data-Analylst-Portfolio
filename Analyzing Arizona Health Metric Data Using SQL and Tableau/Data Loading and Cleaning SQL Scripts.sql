/* Insert data into each table from the relevant locally-saved csv file and move it into an Arizona-specific table
one year/census entity level at a time. I used the import flat file wizard for 2022 files to figure out the column
headers and datatypes, then copied those tables for the other years before importing. */

DECLARE @year nvarchar(4) = '2022' -- 2020, 2021, or 2022
DECLARE @census_table nvarchar(20) = 'Place_Data' -- Census_Tract_Data, Place_Data, or County_Data
DECLARE @loaddatafromcsvquery nvarchar(1000)
DECLARE @movedataintoAZtablequery2022 nvarchar(1000)
DECLARE @movedataintoAZtablequerynon2022 nvarchar(1000)

SET @loaddatafromcsvquery = 
	'BULK INSERT ' + QUOTENAME(@census_table + '_' + @year) + '
	FROM ' + QUOTENAME('C:\Users\brkra\Documents\Healthcare Data Projects\PLACES__Local_Data_for_Better_Health__' + @census_table + '_' + @year + '_release.csv') + '
	WITH (
		FORMAT = ''csv'',
		FIRSTROW = 2, -- no need to include header row
		ROWTERMINATOR = ''0x0a'' -- handles end of line characters
		)'

EXEC sp_executesql @loaddatafromcsvquery;

--------------------------------------------------------------
-- For the 2020 census tract files removed a leading zero from LocationName and LocationID to match it with the other files
IF @year = '2020' AND @census_table = 'Census_Tract_Data'
BEGIN
UPDATE Census_Tract_Data_2020
SET LocationName = RIGHT(LocationName, LEN(LocationName) - 1),
LocationID = RIGHT(LocationID, LEN(LocationID) - 1)
END

--------------------------------------------------------------
--Load in data from each year into one overall table for each census level. Use this script for the first year of data you're loading (2022)
IF @year = '2022'
BEGIN
SET @movedataintoAZtablequery2022 =
'INSERT INTO ' + QUOTENAME('AZ_' + @census_table) + '
SELECT *
  FROM ' + QUOTENAME(@census_table + '_' + @year) + '
 WHERE StateAbbr = ''AZ''
	AND DataValueTypeID = ''CrdPrv'''

EXEC sp_executesql @movedataintoAZtablequery2022
END
--------------------------------------------------------------
---- Load in data from each year into one overall table for each census level. Assumes at least one year of data is already populated
---- CTE is to determine which measures are only refreshed every other year to avoid loading duplicates. Did a CTE instead of a subquery for performance reasons
ELSE
BEGIN
SET @movedataintoAZtablequerynon2022 =
'WITH measurestoavoid AS (
		 SELECT DISTINCT az.MeasureId
		   FROM ' + QUOTENAME(@census_table + '_' + @year) + ' usa
		  INNER JOIN ' + QUOTENAME('AZ_' + @census_table) + ' az
				ON usa.LocationName = az.LocationName
				AND usa.MeasureId = az.MeasureId
				AND usa.Year = az.Year
				)

INSERT INTO ' + QUOTENAME('AZ_' + @census_table) + '
SELECT DISTINCT usadata.*
  FROM ' + QUOTENAME(@census_table + '_' + @year) + ' usadata
 INNER JOIN ' + QUOTENAME('AZ_' + @census_table) + ' azdata
	ON usadata.LocationName = azdata.LocationName
	AND usadata.MeasureId = azdata.MeasureId
	AND usadata.Year != azdata.Year
	AND usadata.DataValueTypeID = azdata.DataValueTypeID
 LEFT HASH JOIN measurestoavoid mta -- force hash join for performance
	ON mta.MeasureId = usadata.MeasureId
 WHERE usadata.StateAbbr = ''AZ''
	AND usadata.DataValueTypeID = ''CrdPrv''
	AND mta.MeasureId IS NULL'

EXEC sp_executesql @movedataintoAZtablequerynon2022
END
--------------------------------------------------------------
-- If you want to truncate the table afterwards to make space for the next one
--DECLARE @truncatetablequery nvarchar(100)
--SET @truncatetablequery =
--'TRUNCATE TABLE ' + QUOTENAME(@census_table + '_' + @year)

--EXEC sp_executesql @truncatetablequery
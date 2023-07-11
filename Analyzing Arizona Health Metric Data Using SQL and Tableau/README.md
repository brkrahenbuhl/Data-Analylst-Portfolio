**[Start Here - Tableau Workbook Link](https://public.tableau.com/app/profile/ben.krahenbuhl/viz/ArizonaPublicHealthMeasureExplorationWorkbook/Dashboard1)**

This project aims to provide visualizations for publicly available data from the PLACES project by the United States Centers for Disease Control (CDC). Specifically, I focused on the state of Arizona to narrow down the volume of data and because I am moving to the Phoenix area and wanted to learn about the public health disparities across the metro area and the state as a whole.

# Introduction
## PLACES Background
The Population Level Analysis and Community Estimates (PLACES) program , home webpage linked [here](https://www.cdc.gov/places/index.html), is a collaboration between the CDC, the Robert Wood Johnson Foundation, and the CDC Foundation that provides estimates for a list of health measures across the United States. They provide data at the county, place (incorporated and census-designated place), census tract, and Zip Code Tabulation Area (ZCTA) entities. THe PLACES project started in 2020, although the precursor to PLACES, the 500 Cities Project, has been gathering data since 2015.

As there is no nationwide-survey or data to precisely track these public health measures, especially at the more granular census measures, PLACES has innovated by using a statistical modeling framework to provide both crude and age-adjusted estimates. The primary data sources are the CDC’s Behavioral Risk Factor Surveillance System (BRFSS), Census 2010 population counts, annual Census county population estimates, and American Community Survey (ACS) estimates. The CDC has published info on their methodology [here](https://www.cdc.gov/places/methodology/index.html). Measures are broken down into four categories: Health Status, Health Risk Behaviors, Health Outcomes, and Prevention. Although the data files have descriptions on what each measure entails, more detailed info can be found on the [PLACES website](https://www.cdc.gov/places/measure-definitions/index.html). Some measures are recorded every year, while others are only recorded every other year.

## Dataset
While PLACES data is published nationally, for this project we are only using Arizona data (State FIPS Code = 04) as discussed in the introduction. Additionally, while PLACES publishes both crude prevalance and age-adjusted prevalance values for many of its measures, we choose to only use crude prevalance values. While both methods have merit, we are most interested in potential health interventions to be done in the near future so the number of people with a given condition is the more important number to understand. Plus, the data for any given measure spans three years so the risk of misunderstanding data due to shifting age demographics is low. 

PLACES publishes data for four census entities: county, place, census tract, and ZCTA. It is important to understand the relationships between these concepts to properly drill down  into the data. Here are the definitions per [this census.gov article](https://www.census.gov/newsroom/blogs/random-samplings/2014/07/understanding-geographic-relationships-counties-places-tracts-and-more.html):
* Counties stay within state boundaries and have different county-level governments.
* Places stay within state boundaries, but a single place can lie in multiple counties.
* Census tracts must stay within a county, and therefore a state.
* ZCTAs are based on U.S. Postal Services ZIP Codes, but are a census-defined entity. They must fall within the national boundary only.

For this analysis we decided to not use ZCTA data as they don't cleanly fit within the other entities and census tract data is more detailed than ZCTA data. For the remaining entities, there are two key relationships that emerge, seen below.

State > County > Census Tract <br>
State > Place

Last, since we plan to use maps to help visualize measure values across Arizona, we uploaded publicly available shapefiles from the 2010 US Census. The files are published on the [census.gov site](https://www.census.gov/cgi-bin/geo/shapefiles/index.php).

# SQL Data Loading and Cleaning
We began with nine csv files representing the 2020, 2021, and 2022 PLACES releases for each of the county, place, and census tract levels. As we'd like to minimize the amount of raw data processing we ask Tableau to perform and the place and census tract files were too large to be properly displayed and editied in Excel, we loaded the raw data into a Microsoft SQL Server database we created for this purpose. For the inital 2022 file loads we used the SQL Server Flat File Import Wizard to help define column datatypes, then used a dynamic T-SQL statement for the remaining loads (and any subsequent re-loads).

From the raw data tables, we filtered the data down to only Arizona and crude prevalnce values and moved it to aggregated tables containing all years for each census entities. We needed to take care to avoid loading duplicate rows since measures that are only recorded every other year are still included in each annual PLACES release with duplicate values.

From there, we exported each of the Arizona-specific tables into Excel files, then loading those files in Tableau Public. We used Excel files instead of csvs to make any further needed edits easier and to handle a few commas that existed in the data that would throw off a comma-delimited file. 

# Tableau Data Cleaning and Preparation
## Tableau Workbook Link
[https://public.tableau.com/app/profile/ben.krahenbuhl/viz/ArizonaPublicHealthMeasureExplorationWorkbook/Dashboard1](https://public.tableau.com/app/profile/ben.krahenbuhl/viz/ArizonaPublicHealthMeasureExplorationWorkbook/Dashboard1)
## Cleaning
Once the data was in Tableau we changed a number of datatypes, column names, and dimension or measure info to align with the intended data.

## Calculated Fields
We created a handful of calculated fields to help derive insights from this dataset. We also created additional fields not listed below for specific visualizations (e.g. to make axis names more appealing) that can be seen in the Tableau workbook.
1. Value (Percent): the initial data values were numbers 1-100, meant to be interpreted as percents, but there was no metadata communicating this so we needed to manually create a field to show the data properly.
2. Value (State Level): we used county-level measure and population data to create a state-wide data value for each measure and year that we could benchmark more granular data against.
3. Lower is Better?: 21 of the 30 measures are on an inverted scale where a lower value is interpreted as better. We needed to understand which measures fit into this category to properly interpret data values, so we manually read each measure description and populated this field accordingly.
4. Quartile Value: First/Median/Third: We stored the value of the 25th, 50th and 75th percentile for each census entity, measure, and year to serve as a benchmark for individual data points.
5. Quartile: Using the Lower is Better? and Quartile Value fields, we calculated which quartile each data point resided in within its census entity, year, and measure.
6. MeasureID + Name: We concatenated the MeasureID and Measure fields to create one string that sorts the measure list in an understandable way while still fully explaining the measure. This is used in user-facing dashboard filters.

# Conclusion
From playing around with this dashboard, a user obtains a familiarity with the variance in health measures across Arizona. This set of dashboards can be used for high-level education or to drill into a specific measure and region to determine how to prioritize potential public health interventions. For example, looking across the Phoenix metro area at the census tract entity level you can see potential targets for intervention such as low rates of people visiting the dentist in South Phoenix, West Phoenix, and the Mesa area or Scottsdale having a high blood pressure rate that's not as well performing as most of its other health measures. That being said, these dashboards are only a starting point; once we have ideas on where to futher investigate, next steps would be to join the health measure data with demographic data to better target potential interventions and build a visualization to explore correlations between the measures to help group what outcomes a potential intervention should track.

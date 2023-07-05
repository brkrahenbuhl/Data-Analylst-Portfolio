# Introduction
This project aims to provide visualizations for publicly available data from the PLACES project by the United States Centers for Disease Control (CDC). Specifically, I focused on the state of Arizona to narrow down the volume of data and because I recently moved to the Phoenix area and wanted to learn about the public health disparities across the metro area and the state as a whole.

## PLACES Background
The Population Level Analysis and Community Estimates (PLACES) program , home webpage linked [here](https://www.cdc.gov/places/index.html), is a collaboration between the CDC, the Robert Wood Johnson Foundation, and the CDC Foundation that provides estimates for a list of health measures across the United States. They provide data at the county, place (incorporated and census-designated place), census tract, and Zip Code Tabulation Area (ZCTA) levels. THe PLACES project started in 2020, although the precursor to PLACES, the 500 Cities Project, has been gathering data since 2015.

As there is no nationwide-survey or data to precisely track these public health measures, especially at the more granular census measures, PLACES has innovated by using a statistical modeling framework to provide both crude and age-adjusted estimates. The primary data sources are the CDC’s Behavioral Risk Factor Surveillance System (BRFSS), Census 2010 population counts, annual Census county population estimates, and American Community Survey (ACS) estimates. The CDC has published info on their methodology [here](https://www.cdc.gov/places/methodology/index.html). Measures are broken down into four categories: Health Status, Health Risk Behaviors, Health Outcomes, and Prevention. Although the data files have descriptions on what each measure entails, more detailed info can be found on the [PLACES website](https://www.cdc.gov/places/measure-definitions/index.html). Some measures are recorded every year, while others are only recorded every other year.

## Dataset
While PLACES data is published nationally, for this project we are only using Arizona data (State FIPS Code = 04) as discussed in the introduction. Additionally, while PLACES publishes both crude prevalance and age-adjusted prevalance values for many of its measures, we choose to only use crude prevalance values. While both methods have merit, we are most interested in potential health interventions to be done in the near future so the number of people with a given condition is the more important number to understand. Plus, the data for any given measure spans three years so the risk of misunderstanding data due to shifting age demographics is low. 

PLACES publishes data for four census levels: county, place, census tract, and ZCTA. It is important to understand the relationships between these concepts to properly drill down  into the data. Here are the definitions per [this census.gov article](https://www.census.gov/newsroom/blogs/random-samplings/2014/07/understanding-geographic-relationships-counties-places-tracts-and-more.html):
* Counties stay within state boundaries and have different county-level governments
* Places stay within state boundaries, but a single place can lie in multiple counties.
* Census tracts must stay within a county, and therefore a state.
* ZCTAs are based on U.S. Postal Services ZIP Codes, but are a census-defined entity. They must fall within the national boundary only.

For this analysis we decided to not use ZCTA data as they don't cleanly fit within the other levels and census tract data is more detailed than ZCTA data. For the remaining levels, there are two key relationships that emerge, seen below.

State > County > Census Tract
State > Place

Last, since we plan to use maps to help visualize measure values across Arizona, we uploaded publicly available shapefiles from the 2010 US Census. The files are published on the [census.gov site](https://www.census.gov/cgi-bin/geo/shapefiles/index.php).

# Initial Data Loading and Filtering

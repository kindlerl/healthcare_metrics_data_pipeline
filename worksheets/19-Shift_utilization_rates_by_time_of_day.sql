USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Shift Utilization Rates by Time of Day (Morning, Afternoon, Night)

-- Not feasible – The dataset does not contain any shift-level information 
-- or timestamps that distinguish nurse hours by time of day. All staffing 
-- data is aggregated at the daily level, so no breakdown by morning, 
-- afternoon, or night shifts is possible.







USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Correlation Between Nurse Staffing Levels and Readmission Rates

-- This analysis is not possible with the current dataset due to key limitations:

-- Nurse staffing data exists only for a single snapshot date (1970-08-23)

-- Readmission rates are pre-aggregated CMS metrics across fiscal years

-- There is no time-aligned or patient-level data to establish correlation
-- As such, no statistical or proxy-based analysis is feasible.



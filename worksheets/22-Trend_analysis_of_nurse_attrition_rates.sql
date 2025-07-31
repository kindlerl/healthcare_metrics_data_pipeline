USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Trend Analysis of Nurse Attrition Rates (if applicable data exists)
-- Not feasible – There is no employment history or staff-level tracking 
-- in the dataset. Nurse identifiers, hire dates, termination dates, and 
-- other employment status changes are not captured, making it impossible 
-- to perform attrition or turnover trend analysis.







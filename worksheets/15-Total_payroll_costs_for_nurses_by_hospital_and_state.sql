USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Total Payroll Costs for Nurses By Hospital and State

-- This metric cannot be calculated due to lack of financial data. 
-- The dataset includes nurse staffing hours by role, but no wage, 
-- salary, or payroll information is present. As such, total payroll 
-- costs cannot be computed or estimated without introducing external 
-- assumptions.














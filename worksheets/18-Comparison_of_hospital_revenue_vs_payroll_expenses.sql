USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Comparison of Hospital Revenue vs. Payroll Expenses

-- This KPI cannot be computed due to the complete absence of 
-- financial data. The dataset contains no revenue, salary, or 
-- payroll expense fields at either the provider or system level.



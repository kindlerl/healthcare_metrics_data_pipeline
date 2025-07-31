USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Average Cost per Patient Stay by Hospital and State

-- This KPI cannot be calculated due to lack of cost and 
-- patient-level data. The dataset does not include admissions, 
-- discharges, or any financial or billing information. As a 
-- result, no proxy for cost per stay can be derived.







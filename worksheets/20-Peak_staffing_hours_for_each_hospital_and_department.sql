USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Peak Staffing Hours for Each Hospital and Department

-- Not feasible – The dataset lacks both shift timestamps and 
-- departmental identifiers. Nurse hours are provided only as 
-- daily aggregates by role (e.g., RN, LPN, CNA), without any 
-- hourly or departmental granularity. As a result, peak staffing 
-- periods cannot be determined.






USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Cost of Overtime Hours as a Percentage of Total Payroll Costs

-- While proxy values for overtime hours can be calculated from nurse shift 
-- data, this KPI requires wage or cost information, which is not present in 
-- the dataset. As a result, the cost of overtime hours cannot be computed.







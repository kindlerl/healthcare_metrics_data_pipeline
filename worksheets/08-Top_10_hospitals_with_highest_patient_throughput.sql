USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();

USE DATABASE HEALTHCARE_DB;
USE SCHEMA SILVER;

-- KPI: Top 10 Hospitals With The Highest Patient Throughput

-- NOTE: Throughput requires a date range to track patient movement over time.

SELECT
    dp.provider_id,
    dp.provider_name,
    dp.state,
    SUM(fpds.mds_census) AS patient_count
FROM
    HEALTHCARE_DB.SILVER.dim_provider dp
JOIN
    HEALTHCARE_DB.SILVER.fact_provider_daily_staffing fpds ON dp.provider_id = fpds.provider_id
GROUP BY
    dp.provider_id, dp.provider_name, dp.state
ORDER BY
    patient_count DESC
LIMIT
    10;
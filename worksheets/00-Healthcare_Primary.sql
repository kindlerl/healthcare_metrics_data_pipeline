USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

SELECT CURRENT_ACCOUNT(), CURRENT_REGION();
SHOW WAREHOUSES;
-- ALTER WAREHOUSE COMPUTE_WH RESUME;

-- =========================================
-- ==  CREATE THE DATABASE & SCHEMA       ==
-- =========================================
-- All activity for this project will reside within a database,
-- so create the main database.
CREATE OR REPLACE DATABASE HEALTHCARE_DB;

-- Create the schema
CREATE OR REPLACE SCHEMA HEALTHCARE_DB.BRONZE;

-- Set the Bronze schema as active
USE SCHEMA HEALTHCARE_DB.BRONZE;

-- =============================================
-- ==  CREATE THE SNOWFLAKE -> S3 INTEGRATION ==
-- =============================================
-- Next, we need to create the integration between Snowflake and AWS S3
CREATE OR REPLACE STORAGE INTEGRATION HEALTHCARE_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  -- STORAGE_AWS_ROLE_ARN = 'Your_scd2_role_arn_from_aws'
  -- STORAGE_ALLOWED_LOCATIONS = ('Your_S3_URI_of_data_bucket_with_folder');
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::881128007058:role/healthcare-project-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://rlk-healthcare-project/bronze/');

-- Now, we need to pull information from the HEALTHCARE_INTEGRATION
-- configuration to update the configuration for our S3 bucket
-- to complete the Trust handshake between AWS and Snowflake
DESC INTEGRATION HEALTHCARE_INTEGRATION;

-- STORAGE_AWS_IAM_USER_ARN = arn:aws:iam::285641111216:user/baa41000-s
-- STORAGE_AWS_EXTERNAL_ID = FUC49552_SFCRole=3_gPQcfWzxXK0dZt5gu9MQTlPf+ko=

-- These were copied into the "Trust relationships" tab for the "HEALTHCARE-e2d-project-role"
-- The resulting JSON:
-- {
--     "Version": "2012-10-17",
--     "Statement": [
--         {
--             "Effect": "Allow",
--             "Principal": {
--                 "AWS": "arn:aws:iam::409763989324:user/npj21000-s"
--             },
--             "Action": "sts:AssumeRole",
--             "Condition": {
--                 "StringEquals": {
--                     "sts:ExternalId": "SQC50361_SFCRole=3_rdFWK/PWI9nnbiIxS6Ah0Vgn2ZY="
--                 }
--             }
--         }
--     ]
-- }

-- =============================================
-- ==  CREATE THE CSV FILE FORMAT             ==
-- =============================================
-- Next, we need to define a FILE FORMAT that we'll be using to copy the data into the
-- STAGE area within Snowflake.
CREATE OR REPLACE FILE FORMAT HEALTHCARE_STAGE_CSV_FORMAT
  TYPE = CSV
  FIELD_DELIMITER = ','
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', 'NA', 'na')  -- Had to add 'NA', 'na' to handle the MardownX fields
  EMPTY_FIELD_AS_NULL = true
  ERROR_ON_COLUMN_COUNT_MISMATCH = false
  ENCODING = 'WINDOWS1252';

-- =============================================
-- ==  CREATE THE SNOWFLAKE STAGE AREA        ==
-- =============================================
-- Next, let's create the STAGE
CREATE OR REPLACE STAGE HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
  STORAGE_INTEGRATION = HEALTHCARE_INTEGRATION
  URL = 's3://rlk-healthcare-project/bronze/'
  FILE_FORMAT = HEALTHCARE_STAGE_CSV_FORMAT;

-- Confirm the link between Snowflake and AWS S3 is setup
ls @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE

-- All 21 data files were viewable!

-- =============================================
-- ==  CREATE THE BRONZE TABLES               ==
-- =============================================
-- We are now ready to copy the data from S3 into the RAW
-- tables in Snowflake (Bronze layer)

-- Create the tables first
CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.PBJ_DAILY_NURSE_STAFFING_MAIN (
    PROVNUM STRING,
    PROVNAME STRING,
    CITY STRING,
    STATE STRING,
    COUNTY_NAME STRING,
    COUNTY_FIPS STRING,
    CY_Qtr STRING,
    WorkDate STRING,
    MDScensus STRING,
    Hrs_RNDON STRING,
    Hrs_RNDON_emp STRING,
    Hrs_RNDON_ctr STRING,
    Hrs_RNadmin STRING,
    Hrs_RNadmin_emp STRING,
    Hrs_RNadmin_ctr STRING,
    Hrs_RN STRING,
    Hrs_RN_emp STRING,
    Hrs_RN_ctr STRING,
    Hrs_LPNadmin STRING,
    Hrs_LPNadmin_emp STRING,
    Hrs_LPNadmin_ctr STRING,
    Hrs_LPN STRING,
    Hrs_LPN_emp STRING,
    Hrs_LPN_ctr STRING,
    Hrs_CNA STRING,
    Hrs_CNA_emp STRING,
    Hrs_CNA_ctr STRING,
    Hrs_NAtrn STRING,
    Hrs_NAtrn_emp STRING,
    Hrs_NAtrn_ctr STRING,
    Hrs_MedAide STRING,
    Hrs_MedAide_emp STRING,
    Hrs_MedAide_ctr STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_CITATION_DESCRIPTIONS (
    Deficiency_Prefix	STRING,
    Deficiency_Tag_Number	STRING,
    Deficiency_Prefix_and_Number STRING,
    Deficiency_Description STRING,
    Deficiency_Category STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_COVID_VAX_AVERAGES (
    State STRING,
    Percent_of_residents_who_are_up_to_date_on_their_vaccine STRING,
    Percent_of_staff_who_are_up_to_date_on_their_vaccines STRING,
    Date_vaccination_data_last_updated STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_COVID_VAX_PROVIDER (
    CMS_Certification_Number STRING,
    State STRING,
    Percent_of_residents_who_are_up_to_date_on_their_vaccines STRING,
    Percent_of_staff_who_are_up_to_date_on_their_vaccines STRING,
    Date_vaccination_data_last_updated STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_DATA_COLLECTION_INTERVALS (
    Measure_Code STRING,
    Measure_Description STRING,
    Data_Collection_Period_From_Date STRING,
    Data_Collection_Period_Through_Date STRING,
    Measure_Date_Range STRING,
    Processing_Date STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_FIRE_SAFETY_CITATIONS (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Survey_Date STRING,
    Survey_Type STRING,
    Deficiency_Prefix STRING,
    Deficiency_Category STRING,
    Deficiency_Tag_Number STRING,
    Tag_Version STRING,
    Deficiency_Description STRING,
    Scope_Severity_Code STRING,
    Deficiency_Corrected STRING,
    Correction_Date STRING,
    Inspection_Cycle STRING,
    Standard_Deficiency STRING,
    Complaint_Deficiency STRING,
    Infection_Control_Inspection_Deficiency STRING,
    Citation_under_IDR STRING,
    Citation_under_IIDR STRING,
    Location STRING,
    Processing_Date date,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_HEALTH_CITATIONS (	
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Survey_Date STRING,
    Survey_Type STRING,
    Deficiency_Prefix STRING,
    Deficiency_Category STRING,
    Deficiency_Tag_Number STRING,
    Deficiency_Description STRING,
    Scope_Severity_Code STRING,
    Deficiency_Corrected STRING,
    Correction_Date STRING,
    Inspection_Cycle STRING,
    Standard_Deficiency STRING,
    Complaint_Deficiency STRING,
    Infection_Control_Inspection_Deficiency STRING,
    Citation_under_IDR STRING,
    Citation_under_IIDR STRING,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_HEALTH_INSPEC_CUTPOINTS_STATE (
    State STRING,
    Five_Stars STRING,
    Four_Stars STRING,
    Three_Stars STRING,
    Two_Stars STRING,
    One_Star STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_OWNERSHIP (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Role_played_by_Owner_or_Manager_in_Facility STRING,
    Owner_Type STRING,
    Owner_Name STRING,
    Ownership_Percentage STRING,
    Association_Date STRING,
    Location STRING,
    Processing_Date STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_PENALTIES (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Penalty_Date STRING,
    Penalty_Type STRING,
    Fine_Amount STRING,
    Payment_Denial_Start_Date STRING,
    Payment_Denial_Length_in_Days STRING,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_PROVIDER_INFO (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Telephone_Number STRING,
    Provider_SSA_County_Code STRING,
    County_Parish STRING,
    Ownership_Type STRING,
    Number_of_Certified_Beds STRING,
    Average_Number_of_Residents_per_Day STRING,
    Average_Number_of_Residents_per_Day_Footnote STRING,
    Provider_Type STRING,
    Provider_Resides_in_Hospital STRING,
    Legal_Business_Name STRING,
    Date_First_Approved_to_Provide_Medicare_and_Medicaid_Services STRING,
    Affiliated_Entity_Name STRING,
    Affiliated_Entity_ID STRING,
    Continuing_Care_Retirement_Community STRING,
    Special_Focus_Status STRING,
    Abuse_Icon STRING,
    Most_Recent_Health_Inspection_More_Than_2_Years_Ago STRING,
    Provider_Changed_Ownership_in_Last_12_Months STRING,
    With_a_Resident_and_Family_Council STRING,
    Automatic_Sprinkler_Systems_in_All_Required_Areas STRING,
    Overall_Rating STRING,
    Overall_Rating_Footnote STRING,
    Health_Inspection_Rating STRING,
    Health_Inspection_Rating_Footnote STRING,
    QM_Rating STRING,
    QM_Rating_Footnote STRING,
    Long_Stay_QM_Rating STRING,
    Long_Stay_QM_Rating_Footnote STRING,
    Short_Stay_QM_Rating STRING,
    Short_Stay_QM_Rating_Footnote STRING,
    Staffing_Rating STRING,
    Staffing_Rating_Footnote STRING,
    Reported_Staffing_Footnote STRING,
    Physical_Therapist_Staffing_Footnote STRING,
    Reported_Nurse_Aide_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_LPN_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_RN_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_Licensed_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Total_number_of_nurse_staff_hours_per_resident_per_day_on_the_weekend STRING,
    Registered_Nurse_hours_per_resident_per_day_on_the_weekend STRING,
    Reported_Physical_Therapist_Staffing_Hours_per_Resident_Per_Day STRING,
    Total_nursing_staff_turnover STRING,
    Total_nursing_staff_turnover_footnote STRING,
    Registered_Nurse_turnover STRING,
    Registered_Nurse_turnover_footnote STRING,
    Number_of_administrators_who_have_left_the_nursing_home STRING,
    Administrator_turnover_footnote STRING,
    Nursing_Case_Mix_Index STRING,
    Nursing_Case_Mix_Index_Ratio STRING,
    Case_Mix_Nurse_Aide_Staffing_Hours_per_Resident_per_Day STRING,
    Case_Mix_LPN_Staffing_Hours_per_Resident_per_Day STRING,
    Case_Mix_RN_Staffing_Hours_per_Resident_per_Day STRING,
    Case_Mix_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Case_Mix_Weekend_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Adjusted_Nurse_Aide_Staffing_Hours_per_Resident_per_Day STRING,
    Adjusted_LPN_Staffing_Hours_per_Resident_per_Day STRING,
    Adjusted_RN_Staffing_Hours_per_Resident_per_Day STRING,
    Adjusted_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Adjusted_Weekend_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Rating_Cycle_1_Standard_Survey_Health_Date STRING,
    Rating_Cycle_1_Total_Number_of_Health_Deficiencies STRING,
    Rating_Cycle_1_Number_of_Standard_Health_Deficiencies STRING,
    Rating_Cycle_1_Number_of_Complaint_Health_Deficiencies STRING,
    Rating_Cycle_1_Health_Deficiency_Score STRING,
    Rating_Cycle_1_Number_of_Health_Revisits STRING,
    Rating_Cycle_1_Health_Revisit_Score STRING,
    Rating_Cycle_1_Total_Health_Score STRING,
    Rating_Cycle_2_Standard_Health_Survey_Date STRING,
    Rating_Cycle_2_Total_Number_of_Health_Deficiencies STRING,
    Rating_Cycle_2_Number_of_Standard_Health_Deficiencies STRING,
    Rating_Cycle_2_Number_of_Complaint_Health_Deficiencies STRING,
    Rating_Cycle_2_Health_Deficiency_Score STRING,
    Rating_Cycle_2_Number_of_Health_Revisits STRING,
    Rating_Cycle_2_Health_Revisit_Score STRING,
    Rating_Cycle_2_Total_Health_Score STRING,
    Rating_Cycle_3_Standard_Health_Survey_Date STRING,
    Rating_Cycle_3_Total_Number_of_Health_Deficiencies STRING,
    Rating_Cycle_3_Number_of_Standard_Health_Deficiencies STRING,
    Rating_Cycle_3_Number_of_Complaint_Health_Deficiencies STRING,
    Rating_Cycle_3_Health_Deficiency_Score STRING,
    Rating_Cycle_3_Number_of_Health_Revisits STRING,
    Rating_Cycle_3_Health_Revisit_Score STRING,
    Rating_Cycle_3_Total_Health_Score STRING,
    Total_Weighted_Health_Survey_Score STRING,
    Number_of_Facility_Reported_Incidents STRING,
    Number_of_Substantiated_Complaints STRING,
    Number_of_Citations_from_Infection_Control_Inspections STRING,
    Number_of_Fines STRING,
    Total_Amount_of_Fines_in_Dollars STRING,
    Number_of_Payment_Denials STRING,
    Total_Number_of_Penalties STRING,
    Location STRING,
    Latitude STRING,
    Longitude STRING,
    Geocoding_Footnote STRING,
    Processing_Date STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_QUALITY_MSR_CLAIMS (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Measure_Code STRING,
    Measure_Description STRING,
    Resident_type STRING,
    Adjusted_Score NUMBER,
    Observed_Score NUMBER,
    Expected_Score NUMBER,
    Footnote_for_Score NUMBER,
    Used_in_Quality_Measure_Five_Star_Rating STRING,
    Measure_Period STRING,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_QUALITY_MSR_MDS (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Measure_Code STRING,
    Measure_Description STRING,
    Resident_type STRING,
    Q1_Measure_Score NUMBER,
    Footnote_for_Q1_Measure_Score NUMBER,
    Q2_Measure_Score NUMBER,
    Footnote_for_Q2_Measure_Score NUMBER,
    Q3_Measure_Score NUMBER,
    Footnote_for_Q3_Measure_Score NUMBER,
    Q4_Measure_Score NUMBER,
    Footnote_for_Q4_Measure_Score NUMBER,
    Four_Quarter_Average_Score NUMBER,
    Footnote_for_Four_Quarter_Average_Score NUMBER,
    Used_in_Quality_Measure_Five_Star_Rating STRING,
    Measure_Period STRING,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_STATE_US_AVERAGES (
    State_or_Nation STRING,
    Cycle_1_Total_Number_of_Health_Deficiencies STRING,
    Cycle_1_Total_Number_of_Fire_Safety_Deficiencies STRING,
    Cycle_2_Total_Number_of_Health_Deficiencies STRING,
    Cycle_2_Total_Number_of_Fire_Safety_Deficiencies STRING,
    Cycle_3_Total_Number_of_Health_Deficiencies STRING,
    Cycle_3_Total_Number_of_Fire_Safety_Deficiencies STRING,
    Average_Number_of_Residents_per_Day STRING,
    Reported_Nurse_Aide_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_LPN_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_RN_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_Licensed_Staffing_Hours_per_Resident_per_Day STRING,
    Reported_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Total_number_of_nurse_staff_hours_per_resident_per_day_on_the_weekend STRING,
    Registered_Nurse_hours_per_resident_per_day_on_the_weekend STRING,
    Reported_Physical_Therapist_Staffing_Hours_per_Resident_Per_Day STRING,
    Total_nursing_staff_turnover STRING,
    Registered_Nurse_turnover STRING,
    Number_of_administrators_who_have_left_the_nursing_home STRING,
    Nursing_Case_Mix_Index STRING,
    Case_Mix_RN_Staffing_Hours_per_Resident_per_Day STRING,
    Case_Mix_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Case_Mix_Weekend_Total_Nurse_Staffing_Hours_per_Resident_per_Day STRING,
    Number_of_Fines STRING,
    Fine_Amount_in_Dollars STRING,
    Percentage_of_long_stay_residents_whose_need_for_help_with_daily_activities_has_increased STRING,
    Percentage_of_long_stay_residents_who_lose_too_much_weight STRING,
    Percentage_of_low_risk_long_stay_residents_who_lose_control_of_their_bowels_or_bladder STRING,
    Percentage_of_long_stay_residents_with_a_catheter_inserted_and_left_in_their_bladder STRING,
    Percentage_of_long_stay_residents_with_a_urinary_tract_infection STRING,
    Percentage_of_long_stay_residents_who_have_depressive_symptoms STRING,
    Percentage_of_long_stay_residents_who_were_physically_restrained STRING,
    Percentage_of_long_stay_residents_experiencing_one_or_more_falls_with_major_injury STRING,
    Percentage_of_long_stay_residents_assessed_and_appropriately_given_the_pneumococcal_vaccine STRING,
    Percentage_of_long_stay_residents_who_received_an_antipsychotic_medication STRING,
    Percentage_of_short_stay_residents_assessed_and_appropriately_given_the_pneumococcal_vaccine STRING,
    Percentage_of_short_stay_residents_who_newly_received_an_antipsychotic_medication STRING,
    Percentage_of_long_stay_residents_whose_ability_to_move_independently_worsened STRING,
    Percentage_of_long_stay_residents_who_received_an_antianxiety_or_hypnotic_medication STRING,
    Percentage_of_high_risk_long_stay_residents_with_pressure_ulcers STRING,
    Percentage_of_long_stay_residents_assessed_and_appropriately_given_the_seasonal_influenza_vaccine STRING,
    Percentage_of_short_stay_residents_who_made_improvements_in_function STRING,
    Percentage_of_short_stay_residents_who_were_assessed_and_appropriately_given_the_seasonal_influenza_vaccine STRING,
    Percentage_of_short_stay_residents_who_were_rehospitalized_after_a_nursing_home_admission STRING,
    Percentage_of_short_stay_residents_who_had_an_outpatient_emergency_department_visit STRING,
    Number_of_hospitalizations_per_1000_long_stay_resident_days STRING,
    Number_of_outpatient_emergency_department_visits_per_1000_long_stay_resident_days STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_SURVEY_DATES (
    CMS_Certification_Number STRING,
    Survey_Date DATE,
    Type_of_Survey STRING,
    Survey_Cycle NUMBER,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.NH_SURVEY_SUMMARY (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Inspection_Cycle STRING,
    Health_Survey_Date STRING,
    Fire_Safety_Survey_Date STRING,
    Total_Number_of_Health_Deficiencies STRING,
    Total_Number_of_Fire_Safety_Deficiencies STRING,
    Count_of_Freedom_from_Abuse_and_Neglect_and_Exploitation_Deficiencies STRING,
    Count_of_Quality_of_Life_and_Care_Deficiencies STRING,
    Count_of_Resident_Assessment_and_Care_Planning_Deficiencies STRING,
    Count_of_Nursing_and_Physician_Services_Deficiencies STRING,
    Count_of_Resident_Rights_Deficiencies STRING,
    Count_of_Nutrition_and_Dietary_Deficiencies STRING,
    Count_of_Pharmacy_Service_Deficiencies STRING,
    Count_of_Environmental_Deficiencies STRING,
    Count_of_Administration_Deficiencies STRING,
    Count_of_Infection_Control_Deficiencies STRING,
    Count_of_Emergency_Preparedness_Deficiencies STRING,
    Count_of_Automatic_Sprinkler_Systems_Deficiencies STRING,
    Count_of_Construction_Deficiencies STRING,
    Count_of_Services_Deficiencies STRING,
    Count_of_Corridor_Walls_and_Doors_Deficiencies STRING,
    Count_of_Egress_Deficiencies STRING,
    Count_of_Electrical_Deficiencies STRING,
    Count_of_Emergency_Plans_and_Fire_Drills_Deficiencies STRING,
    Count_of_Fire_Alarm_Systems_Deficiencies STRING,
    Count_of_Smoke_Deficiencies STRING,
    Count_of_Interior_Deficiencies STRING,
    Count_of_Gas_and_Vacuum_and_Electrical_Systems_Deficiencies STRING,
    Count_of_Hazardous_Area_Deficiencies STRING,
    Count_of_Illumination_and_Emergency_Power_Deficiencies STRING,
    Count_of_Laboratories_Deficiencies STRING,
    Count_of_Medical_Gases_and_Anaesthetizing_Areas_Deficiencies STRING,
    Count_of_Smoking_Regulations_Deficiencies STRING,
    Count_of_Miscellaneous_Deficiencies STRING,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- DROP TABLE HEALTHCARE_DB.BRONZE.fy_2024_snf_vbp_aggregate_performance
CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE (
    Baseline_Period_FY_2019_National_Average_Readmission_Rate STRING,
    Performance_Period_FY_2022_National_Average_Readmission_Rate STRING,
    FY_2024_Achievement_Threshold STRING,
    FY_2024_Benchmark STRING,
    Range_of_Performance_Scores STRING,
    Total_Number_of_SNFs_Receiving_Value_Based_Incentive_Payments STRING,
    Range_of_Incentive_Payment_Multipliers STRING,
    Range_of_Value_Based_Incentive_Payments STRING,
    Total_Amount_of_Value_Based_Incentive_Payments STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_FACILITY_PERFORMANCE (
    SNF_VBP_Program_Ranking STRING,
    Footnote_SNF_VBP_Program_Ranking STRING,
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Baseline_Period_FY_2019_Risk_Standardized_Readmission_Rate STRING,
    Footnote_Baseline_Period_FY_2019_Risk_Standardized_Readmission_Rate STRING,
    Performance_Period_FY_2022_Risk_Standardized_Readmission_Rate STRING,
    Footnote_Performance_Period_FY_2022_Risk_Standardized_Readmission_Rate STRING,
    Achievement_Score STRING,
    Footnote_Achievement_Score STRING,
    Improvement_Score STRING,
    Footnote_Improvement_Score STRING,
    Performance_Score STRING,
    Footnote_Performance_Score STRING,
    Incentive_Payment_Multiplier STRING,
    Footnote_Incentive_Payment_Multiplier STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.SKILLED_NURSING_FACILITY_QUALITY_REPORTING_PROGRAM_NATIONAL_DATA (
    CMS_Certification_Number STRING,
    Measure_Code STRING,
    Score STRING,
    Footnote STRING,
    Start_Date STRING,
    End_Date STRING,
    Measure_Date_Range STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.SKILLED_NURSING_FACILITY_QUALITY_REPORTING_PROGRAM_PROVIDER_DATA (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Address_Line_1 STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    County_Parish STRING,
    Telephone_Number STRING,
    CMS_Region STRING,
    Measure_Code STRING,
    Score STRING,
    Footnote STRING,
    Start_Date STRING,
    End_Date STRING,
    Measure_Date_Range STRING,
    LOCATION1 STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.SWING_BED_SNF_DATA (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Address_Line_1 STRING,
    Address_Line_2 STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    County_Parish STRING,
    Telephone_Number STRING,
    CMS_Region STRING,
    Measure_Code STRING,
    Score STRING,
    Footnote STRING,
    Start_Date STRING,
    End_Date STRING,
    MeasureDateRange STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);



-- =============================================
-- ==  COPY THE DATA FROM THE STAGE AREA TO   ==
-- ==  THE TABLES IN THE BRONZE SCHEMA        ==
-- =============================================
-- Now, copy the data from the CSV files into each table using the COPY INTO command.
-- COPY INTO HEALTHCARE_DB.BRONZE.RAW_DEPARTMENT 
-- FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE/department.csv
-- FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
-- ON_ERROR = 'CONTINUE';




COPY INTO HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_Aggregate_Performance
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_FY_2024_SNF_VBP_Aggregate_Performance.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_Facility_Performance
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_FY_2024_SNF_VBP_Facility_Performance.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Citation_Descriptions
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_CitationDescriptions.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Covid_Vax_Averages
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_CovidVaxAverages.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Covid_Vax_Provider
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_CovidVaxProvider.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Data_Collection_Intervals
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_DataCollectionIntervals.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Fire_Safety_Citations
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_FireSafetyCitations.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Health_Citations
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_HealthCitations.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Health_Inspec_Cutpoints_State
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_HlthInspecCutpointsState.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Ownership
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_Ownership.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Penalties
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_Penalties.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Provider_Info
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_ProviderInfo.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Quality_Msr_Claims
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_QualityMsr_Claims.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Quality_Msr_MDS
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_QualityMsr_MDS.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_State_US_Averages
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_StateUSAverages.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Survey_Dates
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_SurveyDates.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.NH_Survey_Summary
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_NH_SurveySummary.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.PBJ_Daily_Nurse_Staffing_Main
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_PBJ_Daily_Nurse_Staffing.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.Skilled_Nursing_Facility_Quality_Reporting_Program_National_Data
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_Skilled_Nursing_Facility_Quality_Reporting_Program_National_Data.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.Skilled_Nursing_Facility_Quality_Reporting_Program_Provider_Data
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_Skilled_Nursing_Facility_Quality_Reporting_Program_Provider_Data.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

COPY INTO HEALTHCARE_DB.BRONZE.Swing_Bed_SNF_data
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_Swing_Bed_SNF_data.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

USE SCHEMA HEALTHCARE_DB.BRONZE;
SHOW TABLES;

select to_boolean(count(1)) from information_schema.tables where table_schema = 'BRONZE' and table_name = 'NH_PROVIDER_INFO';

SELECT LOAD_TIMESTAMP FROM HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'BRONZE' 
                 AND  TABLE_NAME = 'NH_PROVIDER_INFO'))
BEGIN
    SELECT provider_id FROM HEALTHCARE_DB.BRONZE.NH_PROVIDER_INFO
END




SELECT COUNT(*) FROM FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE;
SELECT COUNT(*) FROM FY_2024_SNF_VBP_FACILITY_PERFORMANCE;
SELECT COUNT(*) FROM NH_CITATION_DESCRIPTIONS;
SELECT COUNT(*) FROM NH_COVID_VAX_AVERAGES;
SELECT COUNT(*) FROM NH_COVID_VAX_PROVIDER;
SELECT COUNT(*) FROM NH_DATA_COLLECTION_INTERVALS;
SELECT COUNT(*) FROM NH_FIRE_SAFETY_CITATIONS;
SELECT COUNT(*) FROM NH_HEALTH_CITATIONS;
SELECT COUNT(*) FROM NH_HEALTH_INSPEC_CUTPOINTS_STATE;
SELECT COUNT(*) FROM NH_OWNERSHIP;
SELECT COUNT(*) FROM NH_PENALTIES;
SELECT COUNT(*) FROM NH_PROVIDER_INFO;
SELECT COUNT(*) FROM NH_QUALITY_MSR_CLAIMS;
SELECT COUNT(*) FROM NH_QUALITY_MSR_MDS;
SELECT COUNT(*) FROM NH_STATE_US_AVERAGES;
SELECT COUNT(*) FROM NH_SURVEY_DATES;
SELECT COUNT(*) FROM NH_SURVEY_SUMMARY;
SELECT COUNT(*) FROM PBJ_DAILY_NURSE_STAFFING_MAIN;
SELECT COUNT(*) FROM SKILLED_NURSING_FACILITY_QUALITY_REPORTING_PROGRAM_NATIONAL_DATA;
SELECT COUNT(*) FROM SKILLED_NURSING_FACILITY_QUALITY_REPORTING_PROGRAM_PROVIDER_DATA;
SELECT COUNT(*) FROM SWING_BED_SNF_DATA;

SELECT * FROM FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE LIMIT 10;
SELECT * FROM FY_2024_SNF_VBP_FACILITY_PERFORMANCE LIMIT 10;
SELECT * FROM NH_CITATION_DESCRIPTIONS LIMIT 10;
SELECT * FROM NH_COVID_VAX_AVERAGES LIMIT 10;
SELECT * FROM NH_COVID_VAX_PROVIDER LIMIT 10;
SELECT * FROM NH_DATA_COLLECTION_INTERVALS LIMIT 10;
SELECT * FROM NH_FIRE_SAFETY_CITATIONS LIMIT 10;
SELECT * FROM NH_HEALTH_CITATIONS LIMIT 10;
SELECT * FROM NH_HEALTH_INSPEC_CUTPOINTS_STATE LIMIT 10;
SELECT * FROM NH_OWNERSHIP LIMIT 10;
SELECT * FROM NH_PENALTIES LIMIT 10;
SELECT * FROM NH_PROVIDER_INFO LIMIT 10;
DESC TABLE NH_PROVIDER_INFO;
SELECT * FROM NH_QUALITY_MSR_CLAIMS LIMIT 10;
SELECT * FROM NH_QUALITY_MSR_MDS LIMIT 10;
SELECT * FROM NH_STATE_US_AVERAGES LIMIT 10;
SELECT * FROM NH_SURVEY_DATES LIMIT 10;
SELECT * FROM NH_SURVEY_SUMMARY LIMIT 10;
SELECT * FROM PBJ_DAILY_NURSE_STAFFING_MAIN LIMIT 10;
SELECT * FROM SKILLED_NURSING_FACILITY_QUALITY_REPORTING_PROGRAM_NATIONAL_DATA LIMIT 10;
SELECT * FROM SKILLED_NURSING_FACILITY_QUALITY_REPORTING_PROGRAM_PROVIDER_DATA LIMIT 10;
SELECT * FROM SWING_BED_SNF_DATA LIMIT 10;


with source_data as (

    select
        *
    from 
        HEALTHCARE_DB.BRONZE.nh_provider_info
),
deduplicate AS (
    select
        cms_certification_number AS provider_id,
        trim(provider_name) as provider_name,
        trim(provider_address) as provider_address,
        trim(city_town) as city_town,
        trim(state) as state,
        trim(zip_code) as zip_code,
        trim(county_parish) as county_name,
        trim(ownership_type) as ownership_type,
        trim(provider_type) as provider_type,
        trim(overall_rating) as overall_rating,
        trim(provider_resides_in_hospital) as resides_in_hospital_flag,
        trim(legal_business_name) as legal_business_name,
        row_number() over (partition by provider_id order by load_timestamp desc nulls last) as rn
    from source_data
)
SELECT
    *
FROM
    deduplicate
WHERE
    rn = 1



WITH source_data AS (
    SELECT
        *
    FROM
        HEALTHCARE_DB.BRONZE.nh_provider_info
),
deduplicated AS (
    SELECT
        trim(cms_certification_number) AS provider_id,
        trim(provider_name) AS provider_name,
        trim(provider_address) AS provider_address,
        trim(city_town) AS city_town,
        trim(state) AS state,
        trim(zip_code) AS zip_code,
        trim(telephone_number) AS telephone_number,
        trim(county_parish) AS county_name,
        trim(provider_ssa_county_code) AS provider_ssa_county_code,
        trim(ownership_type) AS ownership_type,
        trim(provider_type) AS provider_type,
        trim(legal_business_name) AS legal_business_name,
        trim(provider_resides_in_hospital) AS provider_resides_in_hospital,
        trim(date_first_approved_to_provide_medicare_and_medicaid_services) AS date_first_approved_to_provide_medicare_and_medicaid_services,
        trim(continuing_care_retirement_community) AS continuing_care_retirement_community,
        trim(with_a_resident_and_family_council) AS with_a_resident_and_family_council,
        trim(automatic_sprinkler_systems_in_all_required_areas) AS automatic_sprinkler_systems_in_all_required_areas,
        trim(provider_changed_ownership_in_last_12_months) AS provider_changed_ownership_in_last_12_months,
        trim(location) AS location,
        trim(latitude) AS latitude,
        trim(longitude) AS longitude,
        row_number() OVER(PARTITION BY provider_id ORDER BY load_timestamp DESC NULLS LAST) AS rn
    FROM
        source_data
),
final AS (
    SELECT
        provider_id,
        provider_name,
        provider_address,
        city_town,
        state,
        zip_code,
        telephone_number,
        county_name,
        provider_ssa_county_code,
        ownership_type,
        provider_type,
        legal_business_name,
        provider_resides_in_hospital,
        date_first_approved_to_provide_medicare_and_medicaid_services,
        continuing_care_retirement_community,
        with_a_resident_and_family_council,
        automatic_sprinkler_systems_in_all_required_areas,
        provider_changed_ownership_in_last_12_months,
        location,
        latitude,
        longitude
    FROM
        deduplicated
    WHERE
        rn = 1
)
SELECT
    *
FROM
    final;

{{ 
    config(
        database='HEALTHCARE_DB',
        schema='SILVER',
        materialized='table',
        tags=['silver', 'healthcare']
    )
}}


SELECT COUNT(*) FROM HEALTHCARE_DB.BRONZE.nh_provider_info;
SELECT COUNT(*) FROM HEALTHCARE_DB.SILVER.DIM_PROVIDER_RAW;

SELECT COUNT(*) FROM HEALTHCARE_DB.SILVER.DIM_PROVIDER;

SELECT COUNT(*) FROM HEALTHCARE_DB.SILVER.DIM_PROVIDER_RATINGS;

-- First, grab all the data from our source
WITH source_data AS (
    SELECT
        *
    FROM
        HEALTHCARE_DB.BRONZE.nh_provider_info
         -- {{ source('bronze', 'nh_provider_info') }}
),
-- Next, try to remove duplicates.  This is achieved by selecting the fields
-- we want to retain, applying a trim() function to them to remove leading/traling
-- spacces, then applying a "row_number()" aggregator function to apply a 
-- numeric row number to each unique row.  Duplicate rows will have a row number
-- greater than 1, so we can filter those out in the next CTE.
deduplicated AS (
    SELECT
        TRIM(CMS_CERTIFICATION_NUMBER) AS provider_id,
        CAST(TRIM(reported_nurse_aide_staffing_hours_per_resident_per_day) AS float) AS reported_nurse_aide_staffing_hours_per_resident_per_day,
        CAST(TRIM(reported_lpn_staffing_hours_per_resident_per_day) AS float) AS reported_lpn_staffing_hours_per_resident_per_day,
        CAST(TRIM(reported_rn_staffing_hours_per_resident_per_day) AS float) AS reported_rn_staffing_hours_per_resident_per_day,
        CAST(TRIM(reported_licensed_staffing_hours_per_resident_per_day) AS float) AS reported_licensed_staffing_hours_per_resident_per_day,
        CAST(TRIM(reported_total_nurse_staffing_hours_per_resident_per_day) AS float) AS reported_total_nurse_staffing_hours_per_resident_per_day,
        row_number() OVER(PARTITION BY provider_id ORDER BY load_timestamp DESC NULLS LAST) AS rn
    FROM
        source_data
),
-- Select the fields we want to retain and only retain rows with a rn (row_number() in previous CTE)
-- value of "1" to filter out any duplicated rows.
final AS (
    SELECT
        provider_id,
        reported_nurse_aide_staffing_hours_per_resident_per_day,
        reported_lpn_staffing_hours_per_resident_per_day,
        reported_rn_staffing_hours_per_resident_per_day,
        reported_licensed_staffing_hours_per_resident_per_day,
        reported_total_nurse_staffing_hours_per_resident_per_day
    FROM
        deduplicated
    WHERE
        rn = 1
)
-- Select all the retained rows.
SELECT
    -- {{ dbt_utils.generate_surrogate_key(['provider_id']) }} as provider_sk,
    provider_id,
    reported_nurse_aide_staffing_hours_per_resident_per_day,
    reported_lpn_staffing_hours_per_resident_per_day,
    reported_rn_staffing_hours_per_resident_per_day,
    reported_licensed_staffing_hours_per_resident_per_day,
    reported_total_nurse_staffing_hours_per_resident_per_day
FROM
    final
    
DESC TABLE HEALTHCARE_DB.BRONZE.NH_OWNERSHIP;

USE SCHEMA HEALTHCARE_DB.SILVER;
SHOW TABLES;

SELECT
    provider_sk,
    provider_id,
    owner_name,
    owner_role
FROM
    HEALTHCARE_DB.SILVER.DIM_OWNERSHIP
WHERE
    provider_sk IS NULL
OR
    provider_id IS NULL
OR
    owner_name IS NULL
OR
    owner_role IS NULL;



DESC TABLE HEALTHCARE_DB.BRONZE.NH_HEALTH_CITATIONS;
SELECT * FROM HEALTHCARE_DB.BRONZE.NH_HEALTH_CITATIONS LIMIT 50;

SELECT DISTINCT MEASURE_PERIOD_END_QTR FROM HEALTHCARE_DB.SILVER.fact_quality_measure_mds;

SELECT DISTINCT survey_cycle FROM HEALTHCARE_DB.BRONZE.NH_SURVEY_DATES;

DESC TABLE HEALTHCARE_DB.SILVER.DIM_CITATION_DESCRIPTIONS;

SELECT DISTINCT survey_cycle FROM HEALTHCARE_DB.SILVER.DIM_CITATION_DESCRIPTIONS;

DESC SCHEMA HEALTHCARE_DB.BRONZE;

SELECT * FROM HEALTHCARE_DB.SILVER.fact_quality_measure_claims ORDER BY provider_id ASC LIMIT 30;
DESC TABLE HEALTHCARE_DB.SILVER.fact_quality_measure_claims;

SELECT DISTINCT used_in_quality_measure_five_star_rating
FROM healthcare_db.silver.fact_quality_measure_claims;

DROP TABLE healthcare_db.silver.fact_quality_measure_claims;

SELECT DISTINCT MEASURE_PERIOD
FROM HEALTHCARE_DB.bronze.nh_quality_msr_claims
WHERE MEASURE_PERIOD IS NOT NULL
LIMIT 20;

SELECT DISTINCT debug_measure_period_start, debug_measure_period_end
FROM HEALTHCARE_DB.SILVER.FACT_QUALITY_MEASURE_CLAIMS
WHERE debug_measure_period_start IS NOT NULL;

WITH source_data AS (
    SELECT
        *
    FROM
         -- {{ source('bronze', 'nh_health_citations') }}
        HEALTHCARE_DB.BRONZE.NH_HEALTH_CITATIONS
),
-- Next, try to remove duplicates.  This is achieved by selecting the fields
-- we want to retain, applying a trim() function to them to remove leading/traling
-- spacces, then applying a "row_number()" aggregator function to apply a 
-- numeric row number to each unique row.  Duplicate rows will have a row number
-- greater than 1, so we can filter those out in the next CTE.
deduplicated AS (
    SELECT
        TRIM(CMS_CERTIFICATION_NUMBER) AS provider_id,
        TO_DATE(TRIM(SURVEY_DATE), 'YYYY-MM-DD') AS survey_date,
        CAST(TRIM(SURVEY_TYPE) AS VARCHAR) AS survey_type,
        CONCAT(TRIM(DEFICIENCY_PREFIX), '-', TRIM(DEFICIENCY_TAG_NUMBER)) AS deficiency_id,
        TRIM(DEFICIENCY_PREFIX) AS deficiency_prefix,
        TRIM(DEFICIENCY_TAG_NUMBER) AS deficiency_tag_number,
        TRIM(DEFICIENCY_CATEGORY) AS deficiency_category,
        TRIM(DEFICIENCY_DESCRIPTION) AS deficiency_description,
        TRIM(SCOPE_SEVERITY_CODE) AS scope_severity_code,
        TRIM(DEFICIENCY_CORRECTED) AS deficiency_corrected,
        TO_DATE(TRIM(CORRECTION_DATE), 'YYYY-MM-DD') AS correction_date,
        TRIM(INSPECTION_CYCLE) AS inspection_cycle,
        CAST(
            CASE 
                WHEN TRIM(STANDARD_DEFICIENCY) = 'Y' THEN TRUE
                WHEN TRIM(STANDARD_DEFICIENCY) = 'N' THEN FALSE
                ELSE NULL
            END AS BOOLEAN
        ) AS standard_deficiency,
        CAST(
            CASE 
                WHEN TRIM(COMPLAINT_DEFICIENCY) = 'Y' THEN TRUE
                WHEN TRIM(COMPLAINT_DEFICIENCY) = 'N' THEN FALSE
                ELSE NULL
            END AS BOOLEAN
        ) AS complaint_deficiency,
        CAST(
            CASE 
                WHEN TRIM(INFECTION_CONTROL_INSPECTION_DEFICIENCY) = 'Y' THEN TRUE
                WHEN TRIM(INFECTION_CONTROL_INSPECTION_DEFICIENCY) = 'N' THEN FALSE
                ELSE NULL
            END AS BOOLEAN
        ) AS infection_control_inspection_deficiency,
        CAST(
            CASE 
                WHEN TRIM(CITATION_UNDER_IDR) = 'Y' THEN TRUE
                WHEN TRIM(CITATION_UNDER_IDR) = 'N' THEN FALSE
                ELSE NULL
            END AS BOOLEAN
        ) AS citation_under_idr,
        CAST(
            CASE 
                WHEN TRIM(CITATION_UNDER_IIDR) = 'Y' THEN TRUE
                WHEN TRIM(CITATION_UNDER_IIDR) = 'N' THEN FALSE
                ELSE NULL
            END AS BOOLEAN
        ) AS citation_under_iidr,
        row_number() OVER(PARTITION BY provider_id, survey_date, deficiency_id ORDER BY load_timestamp DESC NULLS LAST) AS rn
    FROM
        source_data
),
-- Select the fields we want to retain and only retain rows with a rn (row_number() in previous CTE)
-- value of "1" to filter out any duplicated rows.
final AS (
    SELECT
        provider_id,
        survey_date,
        survey_type,
        deficiency_id,
        deficiency_prefix,
        deficiency_tag_number,
        deficiency_category,
        deficiency_description,
        scope_severity_code,
        deficiency_corrected,
        correction_date,
        inspection_cycle,
        standard_deficiency,
        complaint_deficiency,
        infection_control_inspection_deficiency,
        citation_under_idr,
        citation_under_iidr
    FROM
        deduplicated
    WHERE
        rn = 1
)
SELECT
    -- Generate a surrogate key from natural key(s)
    -- {{ dbt_utils.generate_surrogate_key(['provider_id', 'survey_date', 'deficiency_id']) }} as citation_sk,
    provider_id,
    survey_date,
    survey_type,
    deficiency_id,
    deficiency_prefix,
    deficiency_tag_number,
    deficiency_category,
    deficiency_description,
    scope_severity_code,
    deficiency_corrected,
    correction_date,
    inspection_cycle,
    standard_deficiency,
    complaint_deficiency,
    infection_control_inspection_deficiency,
    citation_under_idr,
    citation_under_iidr
FROM
    final


SELECT REGEXP_LIKE('2024-12-15', '[0-9]{4}-[0-9]{2}-[0-9]{2}')
SELECT REGEXP_LIKE('10/01/2023-10/31/2023', '[0-9]{2}/[0-9]{2}/[0-9]{4}-[0-9]{2}/[0-9]{2}/[0-9]{4}')

SELECT REGEXP_LIKE(TRIM('a64.36'), '^[0-9].*?$')


SELECT REGEXP_LIKE('0.9802538758-1.0176785153', '\d+\.\d+\-\d+\.\d+')
SELECT REGEXP_LIKE('0.9802538758-1.0176785153', '^[0-9]\.[0-9]+\-[0-9]+\.[0-9]+$')

SELECT 
    SURVEY_DATE, 
    CORRECTION_DATE 
FROM 
    HEALTHCARE_DB.BRONZE.NH_HEALTH_CITATIONS
WHERE
    SURVEY_DATE IS NULL
OR
    CORRECTION_DATE IS NULL
OR
    NOT REGEXP_LIKE(SURVEY_DATE, '[0-9]{4}-[0-9]{2}-[0-9]{2}')
OR
    NOT REGEXP_LIKE(CORRECTION_DATE, '[0-9]{4}-[0-9]{2}-[0-9]{2}')

WITH source_data AS (
    SELECT
        *
    FROM
         HEALTHCARE_DB.BRONZE.NH_COVID_VAX_AVERAGES
        
),
-- Next, try to remove duplicates.  This is achieved by selecting the fields
-- we want to retain, applying a trim() function to them to remove leading/traling
-- spacces, then applying a "row_number()" aggregator function to apply a 
-- numeric row number to each unique row.  Duplicate rows will have a row number
-- greater than 1, so we can filter those out in the next CTE.
deduplicated AS (
    SELECT
        TRIM(STATE) AS state,
        CASE
            WHEN TRIM(PERCENT_OF_RESIDENTS_WHO_ARE_UP_TO_DATE_ON_THEIR_VACCINE) = 'Not Available' THEN NULL
            ELSE CAST(TRIM(PERCENT_OF_RESIDENTS_WHO_ARE_UP_TO_DATE_ON_THEIR_VACCINE) AS FLOAT)
        END AS percent_of_residents_who_are_up_to_date_on_their_vaccines,
        CASE
            WHEN TRIM(PERCENT_OF_STAFF_WHO_ARE_UP_TO_DATE_ON_THEIR_VACCINES) = 'Not Available' THEN NULL
            ELSE CAST(TRIM(PERCENT_OF_STAFF_WHO_ARE_UP_TO_DATE_ON_THEIR_VACCINES) AS FLOAT)
        END AS percent_of_staff_who_are_up_to_date_on_their_vaccines,
        TO_DATE(TRIM(DATE_VACCINATION_DATA_LAST_UPDATED), 'mm/dd/yyyy') AS date_vaccination_data_last_updated,
        row_number() OVER(PARTITION BY state ORDER BY load_timestamp DESC NULLS LAST) AS rn
    FROM
        source_data
),
-- Select the fields we want to retain and only retain rows with a rn (row_number() in previous CTE)
-- value of "1" to filter out any duplicated rows.
final AS (
    SELECT
        state,
        percent_of_residents_who_are_up_to_date_on_their_vaccines,
        percent_of_staff_who_are_up_to_date_on_their_vaccines,
        date_vaccination_data_last_updated
    FROM
        deduplicated
    WHERE
        rn = 1
)
SELECT
        state,
        percent_of_residents_who_are_up_to_date_on_their_vaccines,
        percent_of_staff_who_are_up_to_date_on_their_vaccines,
        date_vaccination_data_last_updated
FROM
    final


    
DESC TABLE HEALTHCARE_DB.BRONZE.NH_FIRE_SAFETY_CITATIONS

DESC TABLE HEALTHCARE_DB.SILVER.FACT_HEALTH_CITATIONS


SELECT
    DISTINCT  INSPECTION_CYCLE
FROM
    -- HEALTHCARE_DB.SILVER.FACT_FIRE_SAFETY_CITATIONS
    HEALTHCARE_DB.SILVER.FACT_HEALTH_CITATIONS

SELECT
    *
FROM 
    -- HEALTHCARE_DB.SILVER.FACT_HEALTH_CITATIONS
    HEALTHCARE_DB.SILVER.DIM_PROVIDER
    -- HEALTHCARE_DB.BRONZE.SKILLED_NURSING_FACILITY_QUALITY_REPORTING_PROGRAM_NATIONAL_DATA
LIMIT
    200

SELECT DISTINCT CONTINUING_CARE_RETIREMENT_COMMUNITY FROM HEALTHCARE_DB.BRONZE.NH_PROVIDER_INFO


DESC TABLE HEALTHCARE_DB.SILVER.FACT_PROVIDER_DAILY_STAFFING
DESC TABLE HEALTHCARE_DB.SILVER.DIM_PROVIDER

DESC TABLE HEALTHCARE_DB.SILVER.FACT_SNF_QUALITY_REPORTING_PROGRAM_PROVIDER_DATA


SELECT * FROM HEALTHCARE_DB.SILVER.DIM_PROVIDER WHERE PROVIDER_ID = '10007'


SELECT COUNT(*) FROM HEALTHCARE_DB.SILVER.DIM_PROVIDER_RAW

SELECT DISTINCT MEASURE_DATE_RANGE FROM HEALTHCARE_DB.BRONZE.skilled_nursing_facility_quality_reporting_program_provider_data


SELECT * FROM HEALTHCARE_DB.BRONZE.NH_PROVIDER_INFO WHERE CMS_CERTIFICATION_NUMBER = '010159'

SELECT COUNT(*) FROM HEALTHCARE_DB.BRONZE.SWING_BED_SNF_DATA

SELECT MAX(LENGTH(CMS_CERTIFICATION_NUMBER)) FROM HEALTHCARE_DB.BRONZE.NH_PROVIDER_INFO
SELECT MIN(LENGTH(CMS_CERTIFICATION_NUMBER)) FROM HEALTHCARE_DB.BRONZE.SWING_BED_SNF_DATA

SELECT
    COUNT(percent_of_residents_who_are_up_to_date_on_their_vaccines)
FROM
    HEALTHCARE_DB.SILVER.fact_covid_vax_provider
WHERE
    percent_of_residents_who_are_up_to_date_on_their_vaccines IS NULL

LIST @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE PATTERN = '.*_FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE.*?\.csv';

LIST @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE PATTERN = '.*_FY_2024_SNF_VBP_Aggregate_Performance.*?\.csv'

SELECT * FROM HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE

DELETE FROM HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE

COPY INTO HEALTHCARE_DB.BRONZE.FY_2024_SNF_VBP_AGGREGATE_PERFORMANCE
FROM @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE
PATTERN = '.*_FY_2024_SNF_VBP_Aggregate_Performance.*?\.csv'
FILE_FORMAT = (FORMAT_NAME = HEALTHCARE_STAGE_CSV_FORMAT)
ON_ERROR = 'CONTINUE';

SHOW FILE FORMATS IN SCHEMA HEALTHCARE_DB.BRONZE;

LIST @HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE 
PATTERN = '.*_FY_2024_SNF_VBP_Aggregate_Performance.*?\.csv';

SHOW GRANTS ON STAGE HEALTHCARE_DB.BRONZE.HEALTHCARE_S3_STAGE;

SHOW FILE FORMATS IN SCHEMA HEALTHCARE_DB.BRONZE;

DESCRIBE FILE FORMAT HEALTHCARE_DB.BRONZE.HEALTHCARE_STAGE_CSV_FORMAT;

SELECT * FROM HEALTHCARE_DB.SILVER.FACT_PROVIDER_DAILY_STAFFING;

DESC TABLE HEALTHCARE_DB.SILVER.DIM_PROVIDER_INCIDENTS

SELECT
    provider_name,
    number_of_certified_beds,
    average_number_of_residents_per_day,
    reported_nurse_aide_staffing_hours_per_resident_per_day,
    reported_lpn_staffing_hours_per_resident_per_day,
    reported_rn_staffing_hours_per_resident_per_day,
    reported_licensed_staffing_hours_per_resident_per_day,
    reported_total_nurse_staffing_hours_per_resident_per_day
FROM
    HEALTHCARE_DB.BRONZE.NH_PROVIDER_INFO
LIMIT
    50;

DESC TABLE HEALTHCARE_DB.SILVER.FACT_QUALITY_MEASURE_CLAIMS
DESC TABLE HEALTHCARE_DB.SILVER.FACT_SNF_VBP_FACILITY_PERFORMANCE
DESC TABLE HEALTHCARE_DB.SILVER.FACT_QUALITY_MEASURE_MDS
DESC TABLE HEALTHCARE_DB.SILVER.DIM_DATA_COLLECTION_INTERVALS
DESC TABLE HEALTHCARE_DB.GOLD.KPI_30_DAY_READMISSION_RATE_BY_DIAGNOSIS


SELECT
    *
    -- STATE_OR_NATION,
    -- NUMBER_OF_HOSPITALIZATIONS_PER_1000_LONG_STAY_RESIDENT_DAYS
    -- DISTINCT MEASURE_DESCRIPTION
FROM
    HEALTHCARE_DB.GOLD.KPI_30_DAY_READMISSION_RATE_BY_DIAGNOSIS
    -- HEALTHCARE_DB.SILVER.FACT_QUALITY_MEASURE_MDS
    -- HEALTHCARE_DB.BRONZE.NH_DATA_COLLECTION_INTERVALS
    -- HEALTHCARE_DB.SILVER.DIM_DATA_COLLECTION_INTERVALS
    -- HEALTHCARE_DB.SILVER.FACT_STATE_US_AVERAGES
WHERE
    MEASURE_DESCRIPTION LIKE 'Number of hospitalizations per 1000%'


SELECT DISTINCT OWNERSHIP_TYPE FROM HEALTHCARE_DB.BRONZE.NH_PROVIDER_INFO LIMIT 10


WITH states AS (
    SELECT 
        STATE,
        CASE
           WHEN STATE = 'AK' THEN 'Alaska'
           WHEN STATE = 'AL' THEN 'Alabama'
           WHEN STATE = 'AR' THEN 'Arkansas'
           WHEN STATE = 'AZ' THEN 'Arizona'
           WHEN STATE = 'CA' THEN 'California'
           WHEN STATE = 'CO' THEN 'Colorado'
           WHEN STATE = 'CT' THEN 'Connecticut'
           WHEN STATE = 'DC' THEN 'District of Columbia'
           WHEN STATE = 'DE' THEN 'Delaware'
           WHEN STATE = 'FL' THEN 'Florida'
           WHEN STATE = 'GA' THEN 'Georgia'
           WHEN STATE = 'HI' THEN 'Hawaii'
           WHEN STATE = 'IA' THEN 'Iowa'
           WHEN STATE = 'ID' THEN 'Idaho'
           WHEN STATE = 'IL' THEN 'Illinois'
           WHEN STATE = 'IN' THEN 'Indiana'
           WHEN STATE = 'KS' THEN 'Kansas'
           WHEN STATE = 'KY' THEN 'Kentucky'
           WHEN STATE = 'LA' THEN 'Louisiana'
           WHEN STATE = 'MA' THEN 'Massachusetts'
           WHEN STATE = 'MD' THEN 'Maryland'
           WHEN STATE = 'ME' THEN 'Maine'
           WHEN STATE = 'MI' THEN 'Michigan'
           WHEN STATE = 'MN' THEN 'Minnesota'
           WHEN STATE = 'MO' THEN 'Missouri'
           WHEN STATE = 'MS' THEN 'Mississippi'
           WHEN STATE = 'MT' THEN 'Montana'
           WHEN STATE = 'NC' THEN 'North Carolina'
           WHEN STATE = 'ND' THEN 'North Dakota'
           WHEN STATE = 'NE' THEN 'Nebraska'
           WHEN STATE = 'NH' THEN 'New Hampshire'
           WHEN STATE = 'NJ' THEN 'New Jersey'
           WHEN STATE = 'NM' THEN 'New Mexico'
           WHEN STATE = 'NV' THEN 'Nevada'
           WHEN STATE = 'NY' THEN 'New York'
           WHEN STATE = 'OH' THEN 'Ohio'
           WHEN STATE = 'OK' THEN 'Oklahoma'
           WHEN STATE = 'OR' THEN 'Oregon'
           WHEN STATE = 'PA' THEN 'Pennsylvania'
           WHEN STATE = 'RI' THEN 'Rhode Island'
           WHEN STATE = 'SC' THEN 'South Carolina'
           WHEN STATE = 'SD' THEN 'South Dakota'
           WHEN STATE = 'TN' THEN 'Tennessee'
           WHEN STATE = 'TX' THEN 'Texas'
           WHEN STATE = 'UT' THEN 'Utah'
           WHEN STATE = 'VA' THEN 'Virginia'
           WHEN STATE = 'VT' THEN 'Vermont'
           WHEN STATE = 'WA' THEN 'Washington'
           WHEN STATE = 'WI' THEN 'Wisconsin'
           WHEN STATE = 'WV' THEN 'West Virginia'
           WHEN STATE = 'WY' THEN 'Wyoming'
           WHEN STATE = 'PR' THEN 'Puerto Rico'
           WHEN STATE = 'VI' THEN 'Virigin Islands'
        END AS STATE_NAME,
        NURSE_HOURS_TO_PATIENT_RATIO AS HPPD
    FROM 
        HEALTHCARE_DB.GOLD.KPI_AVERAGE_NURSE_TO_PATIENT_RATIO
),
regions AS (
    SELECT
        STATE_NAME,
        HPPD,
        CASE
            WHEN STATE_NAME IN ('Connecticut', 'Maine', 'Massachusetts', 'New Hampshire', 'Rhode Island', 'Vermont', 'New Jersey', 'New York', 'Pennsylvania') THEN 'Northeast'
            WHEN STATE_NAME IN ('Illinois', 'Indiana', 'Michigan', 'Ohio', 'Wisconsin', 'Iowa', 'Kansas', 'Minnesota', 'Missouri', 'Nebraska', 'North Dakota', 'South Dakota') THEN 'Midwest'
            WHEN STATE_NAME IN ('Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Maryland', 'North Carolina', 'South Carolina', 'Virginia', 'West Virginia', 'Alabama', 'Kentucky', 'Mississippi', 'Tennessee', 'Arkansas', 'Louisiana', 'Oklahoma', 'Texas') THEN 'South'
            WHEN STATE_NAME IN ('Arizona', 'Colorado', 'Idaho', 'Montana', 'Nevada', 'New Mexico', 'Utah', 'Wyoming', 'Alaska', 'California', 'Hawaii', 'Oregon', 'Washington') THEN 'West'
            ELSE STATE_NAME
        END AS REGION
    FROM
        states
)
SELECT
    REGION,
    AVG(HPPD) AS AVG_HPPD
FROM
    regions
GROUP BY
    REGION














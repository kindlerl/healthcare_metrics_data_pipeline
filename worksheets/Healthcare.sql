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
-- STORAGE_AWS_EXTERNAL_ID = FUC49552_SFCRole=3_R37dhH9hd9/rtw9DA+XPVpSxWPI=

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
CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.pbj_daily_nurse_staffing_main (
    PROVNUM STRING,
    PROVNAME STRING,
    CITY STRING,
    STATE STRING,
    COUNTY_NAME STRING,
    COUNTY_FIPS STRING,
    CY_Qtr STRING,
    WorkDate DATE,
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

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_citation_descriptions (
    Deficiency_Prefix	STRING,
    Deficiency_Tag_Number	STRING,
    Deficiency_Prefix_and_Number STRING,
    Deficiency_Description STRING,
    Deficiency_Category STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_covid_vax_averages (
    State STRING,
    Percent_of_residents_who_are_up_to_date_on_their_vaccine STRING,
    Percent_of_staff_who_are_up_to_date_on_their_vaccines STRING,
    Date_vaccination_data_last_updated DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_covid_vax_provider (
    CMS_Certification_Number STRING,
    State STRING,
    Percent_of_residents_who_are_up_to_date_on_their_vaccines STRING,
    Percent_of_staff_who_are_up_to_date_on_their_vaccines STRING,
    Date_vaccination_data_last_updated DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_data_collection_intervals (
    Measure_Code STRING,
    Measure_Description STRING,
    Data_Collection_Period_From_Date DATE,
    Data_Collection_Period_Through_Date DATE,
    Measure_Date_Range NUMBER,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_fire_safety_citations (
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
    Correction_Date DATE,
    Inspection_Cycle NUMBER,
    Standard_Deficiency BOOLEAN,
    Complaint_Deficiency BOOLEAN,
    Infection_Control_Inspection_Deficiency BOOLEAN,
    Citation_under_IDR BOOLEAN,
    Citation_under_IIDR BOOLEAN,
    Location STRING,
    Processing_Date date,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_health_citations (	
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Survey_Date DATE,
    Survey_Type STRING,
    Deficiency_Prefix STRING,
    Deficiency_Category STRING,
    Deficiency_Tag_Number STRING,
    Deficiency_Description STRING,
    Scope_Severity_Code STRING,
    Deficiency_Corrected STRING,
    Correction_Date DATE,
    Inspection_Cycle STRING,
    Standard_Deficiency BOOLEAN,
    Complaint_Deficiency BOOLEAN,
    Infection_Control_Inspection_Deficiency BOOLEAN,
    Citation_under_IDR BOOLEAN,
    Citation_under_IIDR BOOLEAN,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_health_inspec_cutpoints_state (
    State STRING,
    Five_Stars STRING,
    Four_Stars STRING,
    Three_Stars STRING,
    Two_Stars STRING,
    One_Star STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_ownership (
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

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_penalties (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Penalty_Date DATE,
    Penalty_Type STRING,
    Fine_Amount NUMBER,
    Payment_Denial_Start_Date DATE,
    Payment_Denial_Length_in_Days NUMBER,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_provider_info (
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
    Number_of_Certified_Beds NUMBER,
    Average_Number_of_Residents_per_Day NUMBER,
    Average_Number_of_Residents_per_Day_Footnote NUMBER,
    Provider_Type STRING,
    Provider_Resides_in_Hospital STRING,
    Legal_Business_Name STRING,
    Date_First_Approved_to_Provide_Medicare_and_Medicaid_Services DATE,
    Affiliated_Entity_Name STRING,
    Affiliated_Entity_ID STRING,
    Continuing_Care_Retirement_Community STRING,
    Special_Focus_Status STRING,
    Abuse_Icon STRING,
    Most_Recent_Health_Inspection_More_Than_2_Years_Ago STRING,
    Provider_Changed_Ownership_in_Last_12_Months STRING,
    With_a_Resident_and_Family_Council STRING,
    Automatic_Sprinkler_Systems_in_All_Required_Areas STRING,
    Overall_Rating NUMBER,
    Overall_Rating_Footnote NUMBER,
    Health_Inspection_Rating NUMBER,
    Health_Inspection_Rating_Footnote NUMBER,
    QM_Rating NUMBER,
    QM_Rating_Footnote NUMBER,
    Long_Stay_QM_Rating NUMBER,
    Long_Stay_QM_Rating_Footnote NUMBER,
    Short_Stay_QM_Rating NUMBER,
    Short_Stay_QM_Rating_Footnote NUMBER,
    Staffing_Rating NUMBER,
    Staffing_Rating_Footnote NUMBER,
    Reported_Staffing_Footnote NUMBER,
    Physical_Therapist_Staffing_Footnote NUMBER,
    Reported_Nurse_Aide_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_LPN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_RN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_Licensed_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Total_number_of_nurse_staff_hours_per_resident_per_day_on_the_weekend NUMBER,
    Registered_Nurse_hours_per_resident_per_day_on_the_weekend NUMBER,
    Reported_Physical_Therapist_Staffing_Hours_per_Resident_Per_Day NUMBER,
    Total_nursing_staff_turnover NUMBER,
    Total_nursing_staff_turnover_footnote NUMBER,
    Registered_Nurse_turnover NUMBER,
    Registered_Nurse_turnover_footnote NUMBER,
    Number_of_administrators_who_have_left_the_nursing_home NUMBER,
    Administrator_turnover_footnote NUMBER,
    Nursing_Case_Mix_Index NUMBER,
    Nursing_Case_Mix_Index_Ratio NUMBER,
    Case_Mix_Nurse_Aide_Staffing_Hours_per_Resident_per_Day NUMBER,
    Case_Mix_LPN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Case_Mix_RN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Case_Mix_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Case_Mix_Weekend_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Adjusted_Nurse_Aide_Staffing_Hours_per_Resident_per_Day NUMBER,
    Adjusted_LPN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Adjusted_RN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Adjusted_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Adjusted_Weekend_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Rating_Cycle_1_Standard_Survey_Health_Date DATE,
    Rating_Cycle_1_Total_Number_of_Health_Deficiencies NUMBER,
    Rating_Cycle_1_Number_of_Standard_Health_Deficiencies NUMBER,
    Rating_Cycle_1_Number_of_Complaint_Health_Deficiencies NUMBER,
    Rating_Cycle_1_Health_Deficiency_Score NUMBER,
    Rating_Cycle_1_Number_of_Health_Revisits NUMBER,
    Rating_Cycle_1_Health_Revisit_Score NUMBER,
    Rating_Cycle_1_Total_Health_Score NUMBER,
    Rating_Cycle_2_Standard_Health_Survey_Date DATE,
    Rating_Cycle_2_Total_Number_of_Health_Deficiencies NUMBER,
    Rating_Cycle_2_Number_of_Standard_Health_Deficiencies NUMBER,
    Rating_Cycle_2_Number_of_Complaint_Health_Deficiencies NUMBER,
    Rating_Cycle_2_Health_Deficiency_Score NUMBER,
    Rating_Cycle_2_Number_of_Health_Revisits NUMBER,
    Rating_Cycle_2_Health_Revisit_Score NUMBER,
    Rating_Cycle_2_Total_Health_Score NUMBER,
    Rating_Cycle_3_Standard_Health_Survey_Date DATE,
    Rating_Cycle_3_Total_Number_of_Health_Deficiencies NUMBER,
    Rating_Cycle_3_Number_of_Standard_Health_Deficiencies NUMBER,
    Rating_Cycle_3_Number_of_Complaint_Health_Deficiencies NUMBER,
    Rating_Cycle_3_Health_Deficiency_Score NUMBER,
    Rating_Cycle_3_Number_of_Health_Revisits NUMBER,
    Rating_Cycle_3_Health_Revisit_Score NUMBER,
    Rating_Cycle_3_Total_Health_Score NUMBER,
    Total_Weighted_Health_Survey_Score NUMBER,
    Number_of_Facility_Reported_Incidents NUMBER,
    Number_of_Substantiated_Complaints NUMBER,
    Number_of_Citations_from_Infection_Control_Inspections NUMBER,
    Number_of_Fines NUMBER,
    Total_Amount_of_Fines_in_Dollars NUMBER,
    Number_of_Payment_Denials NUMBER,
    Total_Number_of_Penalties NUMBER,
    Location STRING,
    Latitude NUMBER,
    Longitude NUMBER,
    Geocoding_Footnote NUMBER,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_quality_msr_claims (
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
    Used_in_Quality_Measure_Five_Star_Rating BOOLEAN,
    Measure_Period STRING,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_quality_msr_mds (
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
    Used_in_Quality_Measure_Five_Star_Rating BOOLEAN,
    Measure_Period STRING,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_state_us_averages (
    State_or_Nation STRING,
    Cycle_1_Total_Number_of_Health_Deficiencies NUMBER,
    Cycle_1_Total_Number_of_Fire_Safety_Deficiencies NUMBER,
    Cycle_2_Total_Number_of_Health_Deficiencies NUMBER,
    Cycle_2_Total_Number_of_Fire_Safety_Deficiencies NUMBER,
    Cycle_3_Total_Number_of_Health_Deficiencies NUMBER,
    Cycle_3_Total_Number_of_Fire_Safety_Deficiencies NUMBER,
    Average_Number_of_Residents_per_Day NUMBER,
    Reported_Nurse_Aide_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_LPN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_RN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_Licensed_Staffing_Hours_per_Resident_per_Day NUMBER,
    Reported_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Total_number_of_nurse_staff_hours_per_resident_per_day_on_the_weekend NUMBER,
    Registered_Nurse_hours_per_resident_per_day_on_the_weekend NUMBER,
    Reported_Physical_Therapist_Staffing_Hours_per_Resident_Per_Day NUMBER,
    Total_nursing_staff_turnover NUMBER,
    Registered_Nurse_turnover NUMBER,
    Number_of_administrators_who_have_left_the_nursing_home NUMBER,
    Nursing_Case_Mix_Index NUMBER,
    Case_Mix_RN_Staffing_Hours_per_Resident_per_Day NUMBER,
    Case_Mix_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Case_Mix_Weekend_Total_Nurse_Staffing_Hours_per_Resident_per_Day NUMBER,
    Number_of_Fines NUMBER,
    Fine_Amount_in_Dollars NUMBER,
    Percentage_of_long_stay_residents_whose_need_for_help_with_daily_activities_has_increased NUMBER,
    Percentage_of_long_stay_residents_who_lose_too_much_weight NUMBER,
    Percentage_of_low_risk_long_stay_residents_who_lose_control_of_their_bowels_or_bladder NUMBER,
    Percentage_of_long_stay_residents_with_a_catheter_inserted_and_left_in_their_bladder NUMBER,
    Percentage_of_long_stay_residents_with_a_urinary_tract_infection NUMBER,
    Percentage_of_long_stay_residents_who_have_depressive_symptoms NUMBER,
    Percentage_of_long_stay_residents_who_were_physically_restrained NUMBER,
    Percentage_of_long_stay_residents_experiencing_one_or_more_falls_with_major_injury NUMBER,
    Percentage_of_long_stay_residents_assessed_and_appropriately_given_the_pneumococcal_vaccine NUMBER,
    Percentage_of_long_stay_residents_who_received_an_antipsychotic_medication NUMBER,
    Percentage_of_short_stay_residents_assessed_and_appropriately_given_the_pneumococcal_vaccine NUMBER,
    Percentage_of_short_stay_residents_who_newly_received_an_antipsychotic_medication NUMBER,
    Percentage_of_long_stay_residents_whose_ability_to_move_independently_worsened NUMBER,
    Percentage_of_long_stay_residents_who_received_an_antianxiety_or_hypnotic_medication NUMBER,
    Percentage_of_high_risk_long_stay_residents_with_pressure_ulcers NUMBER,
    Percentage_of_long_stay_residents_assessed_and_appropriately_given_the_seasonal_influenza_vaccine NUMBER,
    Percentage_of_short_stay_residents_who_made_improvements_in_function NUMBER,
    Percentage_of_short_stay_residents_who_were_assessed_and_appropriately_given_the_seasonal_influenza_vaccine NUMBER,
    Percentage_of_short_stay_residents_who_were_rehospitalized_after_a_nursing_home_admission NUMBER,
    Percentage_of_short_stay_residents_who_had_an_outpatient_emergency_department_visit NUMBER,
    Number_of_hospitalizations_per_1000_long_stay_resident_days NUMBER,
    Number_of_outpatient_emergency_department_visits_per_1000_long_stay_resident_days NUMBER,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_survey_dates (
    CMS_Certification_Number STRING,
    Survey_Date DATE,
    Type_of_Survey STRING,
    Survey_Cycle NUMBER,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.nh_survey_summary (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Provider_Address STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    Inspection_Cycle STRING,
    Health_Survey_Date DATE,
    Fire_Safety_Survey_Date DATE,
    Total_Number_of_Health_Deficiencies NUMBER,
    Total_Number_of_Fire_Safety_Deficiencies NUMBER,
    Count_of_Freedom_from_Abuse_and_Neglect_and_Exploitation_Deficiencies NUMBER,
    Count_of_Quality_of_Life_and_Care_Deficiencies NUMBER,
    Count_of_Resident_Assessment_and_Care_Planning_Deficiencies NUMBER,
    Count_of_Nursing_and_Physician_Services_Deficiencies NUMBER,
    Count_of_Resident_Rights_Deficiencies NUMBER,
    Count_of_Nutrition_and_Dietary_Deficiencies NUMBER,
    Count_of_Pharmacy_Service_Deficiencies NUMBER,
    Count_of_Environmental_Deficiencies NUMBER,
    Count_of_Administration_Deficiencies NUMBER,
    Count_of_Infection_Control_Deficiencies NUMBER,
    Count_of_Emergency_Preparedness_Deficiencies NUMBER,
    Count_of_Automatic_Sprinkler_Systems_Deficiencies NUMBER,
    Count_of_Construction_Deficiencies NUMBER,
    Count_of_Services_Deficiencies NUMBER,
    Count_of_Corridor_Walls_and_Doors_Deficiencies NUMBER,
    Count_of_Egress_Deficiencies NUMBER,
    Count_of_Electrical_Deficiencies NUMBER,
    Count_of_Emergency_Plans_and_Fire_Drills_Deficiencies NUMBER,
    Count_of_Fire_Alarm_Systems_Deficiencies NUMBER,
    Count_of_Smoke_Deficiencies NUMBER,
    Count_of_Interior_Deficiencies NUMBER,
    Count_of_Gas_and_Vacuum_and_Electrical_Systems_Deficiencies NUMBER,
    Count_of_Hazardous_Area_Deficiencies NUMBER,
    Count_of_Illumination_and_Emergency_Power_Deficiencies NUMBER,
    Count_of_Laboratories_Deficiencies NUMBER,
    Count_of_Medical_Gases_and_Anaesthetizing_Areas_Deficiencies NUMBER,
    Count_of_Smoking_Regulations_Deficiencies NUMBER,
    Count_of_Miscellaneous_Deficiencies NUMBER,
    Location STRING,
    Processing_Date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.fy_2024_snf_vbp_aggregate_performance (
    Baseline_Period_FY_2019_National_Average_Readmission_Rate NUMBER,
    Performance_Period_FY_2022_National_Average_Readmission_Rate NUMBER,
    FY_2024_Achievement_Threshold NUMBER,
    FY_2024_Benchmark NUMBER,
    Range_of_Performance_Scores STRING,
    Total_Number_of_SNFs_Receiving_Value_Based_Incentive_Payments NUMBER,
    Range_of_Incentive_Payment_Multipliers STRING,
    Range_of_Value_Based_Incentive_Payments STRING,
    Total_Amount_of_Value_Based_Incentive_Payments STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.fy_2024_snf_vbp_facility_performance (
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

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.skilled_nursing_facility_quality_reporting_program_national_data (
    CMS_Certification_Number STRING,
    Measure_Code STRING,
    Score NUMBER,
    Footnote STRING,
    Start_Date DATE,
    End_Date DATE,
    Measure_Date_Range STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.skilled_nursing_facility_quality_reporting_program_provider_data (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Address_Line_1 STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    County_Parish STRING,
    Telephone_Number STRING,
    CMS_Region NUMBER,
    Measure_Code STRING,
    Score STRING,
    Footnote STRING,
    Start_Date DATE,
    End_Date DATE,
    Measure_Date_Range STRING,
    LOCATION1 STRING,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE HEALTHCARE_DB.BRONZE.swing_bed_snf_data (
    CMS_Certification_Number STRING,
    Provider_Name STRING,
    Address_Line_1 STRING,
    Address_Line_2 STRING,
    City_Town STRING,
    State STRING,
    ZIP_Code STRING,
    County_Parish STRING,
    Telephone_Number STRING,
    CMS_Region NUMBER,
    Measure_Code STRING,
    Score STRING,
    Footnote STRING,
    Start_Date DATE,
    End_Date DATE,
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















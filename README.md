# Healthcare Data Engineering Project

## 🔍 Overview

This project analyzes U.S. nursing home staffing and quality metrics using modern data engineering practices. It combines real-world CMS datasets, cloud infrastructure, dbt transformations, and an interactive Streamlit dashboard to surface insights that support better patient outcomes, staffing management, and operational efficiency.

## 📊 Project Architecture

- **Data Sources:** 15+ raw CMS CSV files from Google Drive
- **Ingestion Pipeline:**
  - AWS Lambda to incrementally move files from Google Drive → S3
  - DynamoDB used for ingestion metadata tracking
  - AWS EventBridge used to automatically execute AWS Lambda script on a schedule
- **Bronze Layer:** Raw data loaded from S3 to Snowflake using dbt macro (`copy_all_bronze_tables`)
- **Silver Layer:** dbt models for cleaned fact/dim tables (SCD1/SCD2 handling)
- **Gold Layer:** dbt models that calculate 10 KPIs across staffing, quality, cost, and throughput
- **Reporting:** Streamlit dashboard with interactive filters, charts (Plotly), and dark/light themes

## 📓 KPIs Tracked

1. Total Hours Worked (State & Month)
2. Average Nurse-to-Patient Ratio (HPPD)
3. Percentage of Contractor Staffing
4. Nurse Overtime Hours (Proxy: Contractor %)
5. Nurse Turnover by State
6. COVID-19 Staff Vaccination Rates
7. Patient Throughput (MDS Census Proxy)
8. Readmission Rates Within 30 Days (by Diagnosis)
9. Provider Quality Rating Trends
10. Incident Counts (Falls, Infections, etc.)

## 💡 Project Structure
[![Report 1](reports/thumbnails/Report_1_Weekly_Sales_by_Store_and_Holiday_thumb.png)](reports/Report_1_Weekly_Sales_by_Store_and_Holiday.png)
```bash
.
├── [dbt_healthcare/](https://github.com/kindlerl/dbt_healthcare)         # dbt models, snapshots, and macros used for transforming raw data 
├── dbt_healthcare/         # dbt models and macros (separate repo)
├── streamlit_dashboard/    # Streamlit app and visualization code
├── ingestion/              # Python + Lambda scripts for ingesting from Google Drive
├── rawdata/                # Raw CMS CSVs (local copy)
├── analysis/               # Text-based profiling of incoming datasets
├── worksheets/             # Snowflake SQL exports (used to create Gold models)
├── assets/                 # Architecture diagram and ERD (PDF and drawio)
├── Project_Documentation/  # Project summary, data dictionary, screenshots
├── README.md               # This file
```

## 🔗 How to Run the Dashboard Locally

```bash
# 1. Clone the repo
$ git clone https://github.com/your-username/healthcare-project.git
$ cd healthcare-project

# 2. (Optional) Create a virtual environment
$ python -m venv venv
$ source venv/bin/activate  # or venv\Scripts\activate on Windows

# 3. Install dependencies
$ pip install -r requirements.txt

# 4. Run the Streamlit app
$ streamlit run streamlit_dashboard/app.py
```

## 🎥 Video Walkthrough

[Link to video walkthrough]\
Covers the architecture, tech stack, and dashboard demo.

## 🔎 Insights from the Data

See the `project_summary.md` file for a detailed explanation of each question below:

- What is the relationship between nurse staffing and hospital occupancy?
- Which hospitals have the highest overtime hours for nurses?
- What are the average staffing levels by state and hospital type?
- What trends can you identify in patient length of stay over time?

## 🚀 Tech Stack

- **Google Drive API** for source data access
- **AWS S3 + Lambda + DynamoDB + AWS EventBridge** for ingestion and tracking
- **Snowflake** as cloud data warehouse
- **dbt** for transformation, testing, and layering
- **Streamlit + Plotly** for final reporting/dashboarding

## 📅 Deliverables

-

---

> Built as part of a portfolio data engineering project. This project simulates an end-to-end healthcare data pipeline using real-world public datasets.


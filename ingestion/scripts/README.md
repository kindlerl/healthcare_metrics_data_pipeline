# Ingestion Notebooks

This folder contains Jupyter notebooks used during the ingestion and data exploration phase of the Healthcare Data Engineering project. These tools assist in validating raw datasets, profiling data quality, and identifying candidate keys before building Silver-layer transformations.

## 📁 Contents

### 1. `inspect_csv_schemas.ipynb`
Scans all CSV files in the `rawdata/` folder and reports:
- File name
- Number of rows and columns
- Column names and inferred data types
- Percentage of missing values per column

Useful for gaining a quick overview of raw schema structures.

---

### 2. `detect_primary_keys.ipynb`
Explores potential primary keys for each CSV by:
- Testing column uniqueness
- Trying combinations of 2–3 fields for composite keys
- Reporting which fields can be used for joins or deduplication

Helpful for ERD planning and identifying natural keys.

---

### 3. `generate_profile_reports.ipynb`
Profiles each dataset and saves summary text files, including:
- Descriptive statistics (`.describe()`)
- Missing value analysis
- Data type distributions

Reports are saved to the `profiling_reports/` folder.

---

## 🔧 Usage

All notebooks expect the raw CSV files to be in a folder named `rawdata/` in the project root. Outputs (e.g., profile text files) are saved in `profiling_reports/`.

> 📌 If you're using a different directory layout, adjust the paths in each notebook accordingly.



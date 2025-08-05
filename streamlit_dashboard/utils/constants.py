# Themes
AUTO_THEME = "auto"
DARK_THEME = 'dark'
LIGHT_THEME = 'light'
THEME_SESSION_KEY = 'system_theme'
INITIAL_THEME_SET_KEY = 'initial_theme_set'
ATT_BG_COLOR = 'bg_color'
ATT_FONT_COLOR = 'font_color'
ATT_MARKER_LINE_COLOR = 'marker_line_color'
ATT_COLORSCALE = 'colorscale'
ATT_MARKER_BAR_COLOR = 'color'
ATT_FONT_FAMILY = 'family'
BASE_THEMES = {
    DARK_THEME: {
        ATT_BG_COLOR: "#0e1117",
        ATT_FONT_COLOR: "#d0d0d0",
        ATT_FONT_FAMILY: "Verdana",
        ATT_MARKER_LINE_COLOR: "#606060",
        ATT_COLORSCALE: "icefire",
        ATT_MARKER_BAR_COLOR: "#336699"
    },
    LIGHT_THEME: {
        ATT_BG_COLOR: "#e0e0e0",
        ATT_FONT_COLOR: "#333333",
        ATT_FONT_FAMILY: "Verdana",
        ATT_MARKER_LINE_COLOR: "#202020",
        ATT_COLORSCALE: "blues",
        ATT_MARKER_BAR_COLOR: "#336699"
    }
}

# HOVER CARD FORMATTING
HOVER_BGCOLOR = "#181818"
HOVER_FONT_SIZE = 14
HOVER_FONT_FAMILY = "Verdana"
HOVER_FONT_COLOR = "#dfdfdf"

# SNOWFLAKE
SNOW_CONN = 'snow_conn'
SNOW_CONNECTED = 'is_snowflake_connected'

# NAVIGATION
TOTAL_HOURS_WORKED_BY_NURSES = "Total Hours Worked by Nurses"
AVERAGE_NURSING_HOURS_PER_PATIENT_DAY = "Average Nursing Hours per Patient Day (HPPD)"
READMISSION_RATES_BY_DIAGNOSIS = "Readmission Rates by Diagnosis"

# DATABASE
DB_NAME = "HEALTHCARE_DB"
DB_SCHEMA = "GOLD"

# Column Names
COL_TOTAL_HOURS_WORKED = "TOTAL_HOURS_WORKED"
COL_PROVIDER_NAME = "PROVIDER_NAME"
COL_STATE = "STATE"
COL_STATE_NAME = "STATE_NAME"
COL_MONTH = "MONTH"
COL_MONTH_NAME = "MONTH_NAME"
COL_NURSE_HOURS_TO_PATIENT_RATIO = "NURSE_HOURS_TO_PATIENT_RATIO"
COL_TOTAL_NURSE_HOURS = "TOTAL_NURSE_HOURS"
COL_TOTAL_PATIENT_DAYS = "TOTAL_PATIENT_DAYS"
COL_METRIC_NAME = "METRIC_NAME"
COL_METRIC_SOURCE = "METRIC_SOURCE"
COL_AVG_SCORE = "AVG_SCORE"
COL_LAST_UPDATED = "LAST_UPDATED"

# Row Filter Values
TOP_10_ROWS = "Top 10"
TOP_20_ROWS = "Top 20"
TOP_50_ROWS = "Top 50" 
ALL_ROWS = "All rows"

# Staffing Hours KPI Breakdown
BY_HOSPITAL = "By Hospital"
BY_STATE = "By State"
BY_MONTH = "By Month"
BY_HOSPITAL_STATE_MONTH = "By Hospital, State, and Month"

# Readmission Rates KPI Metrics
PCT_SSR_HOSP_AFTER_NURSING_HOME = "Percentage of short-stay residents who were rehospitalized after a nursing home admission"
PCT_SSR_OUTPATIENT_EMER_DEPT_VISIT = "Percentage of short-stay residents who had an outpatient emergency department visit"
NUM_OUTPATIENT_EMER_VISITS_PER_1000_LSRD = "Number of outpatient emergency department visits per 1000 long-stay resident days"
NUM_HOSP_PER_1000_LSRD = "Number of hospitalizations per 1000 long-stay resident days"
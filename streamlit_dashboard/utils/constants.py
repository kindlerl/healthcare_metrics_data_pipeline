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
BASE_THEMES = {
    DARK_THEME: {
        ATT_BG_COLOR: "#0e1117",
        ATT_FONT_COLOR: "#d0d0d0",
        ATT_MARKER_LINE_COLOR: "#808080",
        ATT_COLORSCALE: "icefire"
    },
    LIGHT_THEME: {
        ATT_BG_COLOR: "#e0e0e0",
        ATT_FONT_COLOR: "#333333",
        ATT_MARKER_LINE_COLOR: "#333333",
        ATT_COLORSCALE: "blues"
    }
}

# SNOWFLAKE
SNOW_CONN = 'snow_conn'
SNOW_CONNECTED = 'is_snowflake_connected'

# NAVIGATION
TOTAL_HOURS_WORKED_BY_NURSES = "Total Hours Worked by Nurses"
AVERAGE_NURSING_HOURS_PER_PATIENT_DAY = "Average Nursing Hours per Patient Day (HPPD)"
READMISSION_RATES_BY_DIAGNOSIS = "Readmission Rates by Diagnosis"

# Column Names
COL_TOTAL_HOURS = "TOTAL_HOURS_WORKED"
COL_PROVIDER_NAME = "PROVIDER_NAME"
COL_STATE = "STATE"
COL_STATE_NAME = "STATE_NAME"
COL_MONTH = "MONTH"

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


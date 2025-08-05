import streamlit as st
import pandas as pd
from utils.snowflake_connection import establish_snowflake_connection
# from utils.themes import get_base_theme, show_theme_selector
from utils.us_states import get_state
from utils.db import get_data_as_dataframe
from kpis.staffing_hours import render_staffing_hours
from kpis.hppd_metrics import render_hppd_metrics
from kpis.readmission_metrics import render_readmission_metrics
import plotly.express as px
import calendar
from dotenv import load_dotenv
from utils.constants import THEME_SESSION_KEY, BASE_THEMES, AUTO_THEME, DARK_THEME, LIGHT_THEME
from utils.constants import TOTAL_HOURS_WORKED_BY_NURSES, AVERAGE_NURSING_HOURS_PER_PATIENT_DAY, READMISSION_RATES_BY_DIAGNOSIS

def detect_theme(theme_option: str) -> str:
    """Determine the effective theme based on user selection or system setting."""
    # print(f"Entering detect_theme with theme_option = {theme_option}")
    if theme_option.lower() == AUTO_THEME:
        # print(f"theme_option looks to be equal to {AUTO_THEME}")
        system_theme = st.get_option("theme.base")
        # print(f"Just fetched the theme.base = {system_theme}")
        if system_theme not in [DARK_THEME, LIGHT_THEME]:
            # print(f"Forcing the system_theme to {DARK_THEME}")
            system_theme = DARK_THEME  # fallback
        return system_theme
    else:
        # print(f"theme_option not equal to {AUTO_THEME}, returning {theme_option.lower()}")
        return theme_option.lower()

# Establish a snowflake connection.  The connection will be
# stored in st.sesstion_state['cs']
establish_snowflake_connection()

st.set_page_config(page_title="Healthcare Dashboard", layout="wide")
st.title("Healthcare Metrics Dashboard")

# =======================
# SIDEBAR CONTENT BEGIN
# =======================

# Application settings
st.sidebar.markdown("### App Settings")

theme_option = st.sidebar.radio(
    "Select Theme",
    options=["Auto", "Light", "Dark"],
    index=0
)

# Set theme once in session
if THEME_SESSION_KEY not in st.session_state:
    theme_option = "auto"  # maybe load from user preferences, config, etc.

st.session_state[THEME_SESSION_KEY] = detect_theme(theme_option)

# Key Performance Indicators Selection
st.sidebar.markdown("### Key Performance Indicators")

kpi_option = st.sidebar.selectbox(
    "Choose a KPI to view",
    [
        TOTAL_HOURS_WORKED_BY_NURSES,
        AVERAGE_NURSING_HOURS_PER_PATIENT_DAY,
        READMISSION_RATES_BY_DIAGNOSIS
    ]
)

if kpi_option == TOTAL_HOURS_WORKED_BY_NURSES:
    render_staffing_hours()
elif kpi_option == AVERAGE_NURSING_HOURS_PER_PATIENT_DAY:
    render_hppd_metrics()
    # print("HPPD Placeholder")
    # cost_metrics.render()
elif kpi_option == READMISSION_RATES_BY_DIAGNOSIS:
    render_readmission_metrics()
    # print("Readmission Rates Placeholder")
    # facility_metrics.render()



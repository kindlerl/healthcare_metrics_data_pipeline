import streamlit as st
import pandas as pd
# from utils.snowflake_connection import establish_snowflake_connection
from utils.us_states import get_state
# from utils.db import get_data_as_dataframe
import plotly.express as px
import calendar
# from dotenv import load_dotenv
# import os

def render_staffing_hours_combined(df):
    print("Render staffing_hours_combined")
    sql = """
        SELECT PROVIDER_NAME, STATE, MONTH, TOTAL_HOURS_WORKED
        FROM KPI_STAFFING_TOTAL_HOURS_BY_MONTH
        ORDER BY PROVIDER_NAME, STATE, MONTH
    """

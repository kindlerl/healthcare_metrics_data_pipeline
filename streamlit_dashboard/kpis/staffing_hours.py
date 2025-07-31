import streamlit as st
import pandas as pd
from utils.snowflake_connection import establish_snowflake_connection
from utils.us_states import get_state
from utils.db import get_data_as_dataframe
import plotly.express as px
import calendar
from dotenv import load_dotenv
# import os
from utils.constants import BY_HOSPITAL, BY_MONTH, BY_STATE, BY_HOSPITAL_STATE_MONTH
from kpis.staffing_hours_breakdown.staffing_hours_by_hospital import render_by_hospital
from kpis.staffing_hours_breakdown.staffing_hours_by_month import render_by_month
from kpis.staffing_hours_breakdown.staffing_hours_by_state import render_by_state
from kpis.staffing_hours_breakdown.staffing_hours_combined import render_staffing_hours_combined

def render_staffing_hours():

    # Get the base Gold data for staffing hours dynamic queries using pandas
    sql = "SELECT * FROM HEALTHCARE_DB.GOLD.KPI_STAFFING_TOTAL_HOURS_BY_MONTH"
    df = get_data_as_dataframe(sql)

    # Subheader
    st.subheader("Total Hours Worked by Nurses")
    # Title
    # st.title("Total Nurse Hours Worked")

    # Dropdown
    grouping = st.selectbox("Group KPI by:", [
        BY_HOSPITAL,
        BY_STATE,
        BY_MONTH,
        BY_HOSPITAL_STATE_MONTH
    ])

    # Base query
    base_query = "SELECT PROVIDER_NAME, STATE, MONTH, TOTAL_HOURS_WORKED FROM KPI_STAFFING_TOTAL_HOURS_BY_MONTH"

    # Determine SQL based on selection

    #=====================================================#
    #  Total Hours Worked By Nurses, Grouped By Hospital  #
    #=====================================================#
    if grouping == BY_HOSPITAL:
        render_by_hospital(df)
    #==================================================#
    #  Total Hours Worked By Nurses, Grouped By State  #
    #==================================================#
    elif grouping == BY_STATE:
        render_by_state(df)
    #==================================================#
    #  Total Hours Worked By Nurses, Grouped By Month  #
    #==================================================#
    elif grouping == BY_MONTH:
        render_by_month(df)
    #==========================================#
    #  Total Hours Worked By Nurses, Combined  #
    #==========================================#
    else:  # "By Hospital, State, and Month"
        render_staffing_hours_combined(df)


    

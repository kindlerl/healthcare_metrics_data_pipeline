import streamlit as st
import pandas as pd
from utils.db import get_data_as_dataframe
import plotly.express as px
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

    # Setup the derived KPI options for staffing hours
    kpi_staffing_options = [
        BY_HOSPITAL,
        BY_STATE,
        BY_MONTH,
        BY_HOSPITAL_STATE_MONTH
    ]

    # Dropdown
    selected_kpi = st.selectbox(
        "Choose how to view staffing hours:", 
        kpi_staffing_options, 
        key="kpi_staffing_view"
    )


    # Create a placeholder container to be used as our
    # rewritable canvas.  This provides control to clear the
    # container prior to new, dynamic renderings.
    view_container = st.container()

    with view_container:
        #=====================================================#
        #  Total Hours Worked By Nurses, Grouped By Hospital  #
        #=====================================================#
        if selected_kpi == BY_HOSPITAL:
            render_by_hospital(df)
        #==================================================#
        #  Total Hours Worked By Nurses, Grouped By State  #
        #==================================================#
        elif selected_kpi == BY_STATE:
            render_by_state(df)
        #==================================================#
        #  Total Hours Worked By Nurses, Grouped By Month  #
        #==================================================#
        elif selected_kpi == BY_MONTH:
            render_by_month(df)
        #==========================================#
        #  Total Hours Worked By Nurses, Combined  #
        #==========================================#
        else:  # "By Hospital, State, and Month"
            render_staffing_hours_combined(df)


    

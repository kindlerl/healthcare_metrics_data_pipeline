import streamlit as st
import pandas as pd
# from utils.snowflake_connection import establish_snowflake_connection
from utils.us_states import get_state
# from utils.db import get_data_as_dataframe
import plotly.express as px
import calendar
# from dotenv import load_dotenv
# import os

def render_by_month(df):
    # Get the data, grouped by state
    df_month = df.groupby(['MONTH']).agg({'TOTAL_HOURS_WORKED':'sum'}).reset_index()

    # Get the full month name from the date
    df_month['MONTH_NAME'] = pd.to_datetime(df_month['MONTH']).dt.month_name()
    df_month = df_month[['MONTH_NAME', 'TOTAL_HOURS_WORKED']]

    # Preserve the calendar order
    df_month["MONTH_NAME"] = pd.Categorical(df_month["MONTH_NAME"], categories=calendar.month_name[1:], ordered=True)
    df_month = df_month.sort_values("MONTH_NAME")

    fig = px.bar(
        df_month,
        x="MONTH_NAME",
        y="TOTAL_HOURS_WORKED",
        labels={"MONTH_NAME": "Month", "TOTAL_HOURS_WORKED": "Total Nurse Hours Worked"},
        title="Total Nurse Hours Worked by Month"
    )

    fig.update_traces(
        hovertemplate='<b>%{x}</b><br>Total Hours: %{y:,.0f}<extra></extra>'
    )
    st.plotly_chart(fig, use_container_width=True)

    # Optional: show raw data
    with st.expander("See Raw Data"):
        st.dataframe(df_month)


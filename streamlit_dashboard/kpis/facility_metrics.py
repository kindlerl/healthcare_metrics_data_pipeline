import streamlit as st
import pandas as pd
from utils.db import get_data_as_dataframe
import plotly.express as px

def render_facility_metrics():
    st.markdown("### Readmission Rates by Diagnosis")




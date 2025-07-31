import streamlit as st
from utils.constants import SNOW_CONN

@st.cache_data
def get_data_as_dataframe(sql):
    results = st.session_state[SNOW_CONN].execute(sql)
    results = st.session_state[SNOW_CONN].fetch_pandas_all()
    return results
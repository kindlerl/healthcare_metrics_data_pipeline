import streamlit as st
from utils.constants import BASE_THEMES, THEME_SESSION_KEY

def get_base_theme():
    return BASE_THEMES[st.session_state[THEME_SESSION_KEY]]


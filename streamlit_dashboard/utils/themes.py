import streamlit as st
from utils.constants import BASE_THEMES, DARK_THEME, LIGHT_THEME, THEME_SESSION_KEY, INITIAL_THEME_SET_KEY

def get_base_theme():
    return BASE_THEMES[st.session_state[THEME_SESSION_KEY]]

def show_theme_selector():
    theme_options=["Dark", "Light"]

    if INITIAL_THEME_SET_KEY not in st.session_state:
        st.session_state[INITIAL_THEME_SET_KEY] = True
        if st.session_state[THEME_SESSION_KEY] == LIGHT_THEME:
            theme_options.reverse()

    theme_mode = st.selectbox(
       "Select Theme Mode", 
       options = theme_options
    )

    if theme_mode in theme_options:
        st.session_state[THEME_SESSION_KEY] = theme_mode.lower()

# def set_app_theme(thm):
#     print(f"in set_app_theme, setting theme to {thm}")
#     if thm.lower() in [DARK_THEME, LIGHT_THEME]:
#         st.session_state[THEME_SESSION_KEY] = thm.lower()

import streamlit as st
import pandas as pd
import plotly.express as px
from utils.db import get_data_as_dataframe

from utils.themes import get_base_theme
from utils.us_states import get_state
from utils.constants import DB_NAME, DB_SCHEMA
from utils.constants import COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_MONTH, COL_NURSE_HOURS_TO_PATIENT_RATIO, COL_TOTAL_NURSE_HOURS, COL_TOTAL_PATIENT_DAYS
from utils.constants import HOVER_BGCOLOR, HOVER_FONT_FAMILY, HOVER_FONT_COLOR, HOVER_FONT_SIZE
from utils.constants import ATT_BG_COLOR, ATT_COLORSCALE, ATT_FONT_FAMILY, ATT_FONT_COLOR, ATT_MARKER_BAR_COLOR, ATT_MARKER_LINE_COLOR
import time

def render_hppd_metrics():
    # --- Early exit if Reset Filters was clicked ---
    if "reset_filters_triggered" in st.session_state and st.session_state.reset_filters_triggered:
        st.session_state.update({
            "hppd_state_filter": [],
            "hppd_hospital_filter": [],
            "reset_filters_triggered": False
        })
        st.rerun()
    
    st.markdown("### Average Nursing Hours Per Patient Day (HPPD)")

    if "apply_filters_triggered" not in st.session_state:
        st.session_state.apply_filters_triggered = False

    # Get the current theme
    theme = get_base_theme()

    # Get the base Gold data for staffing hours dynamic queries using pandas
    sql = "SELECT * FROM " + DB_NAME + "." + DB_SCHEMA + ".KPI_AVERAGE_NURSE_TO_PATIENT_RATIO"
    df = get_data_as_dataframe(sql)

    # --- FILTER: STATE ---
    # Add the state name to the dataframe and move it next to the state abbreviation
    # COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_MONTH, COL_NURSE_HOURS_TO_PATIENT_RATIO, COL_TOTAL_NURSE_HOURS, COL_TOTAL_PATIENT_DAYS
    df[COL_STATE_NAME] = df[COL_STATE].apply(get_state)
    df = df[[COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_MONTH, COL_TOTAL_NURSE_HOURS, COL_TOTAL_PATIENT_DAYS, COL_NURSE_HOURS_TO_PATIENT_RATIO]]

    states = sorted(df[COL_STATE_NAME].unique())  # Get a simple, sorted list of the state names

    try:
        selected_states = st.multiselect("Select one or more states (Optional, to filter providers):", states, key="hppd_state_filter")
    except Exception as e:
        st.error("Something went wrong loading state filters. Please reload the app.")
        st.stop()

    # --- FILTER: HOSPITAL (Only show after state is picked) ---
    if selected_states:
        st.markdown('<br style="line-height:6px;">', unsafe_allow_html=True)

        filtered_state_df = df[df[COL_STATE_NAME].isin(selected_states)]
        hospital_options = sorted(filtered_state_df[COL_PROVIDER_NAME].unique())
        try:
            selected_hospitals = st.multiselect("Select one or more providers:", hospital_options, key="hppd_hospital_filter")
        except Exception as e:
            st.error("Something went wrong loading hospital filters. Please reload the app.")
            st.stop()
    else:
        selected_hospitals = []
        # try:
        #     selected_hospitals = st.multiselect("Select one or more providers:", df, key="hppd_hospital_filter")
        # except Exception as e:
        #     st.error("Something went wrong loading hospital filters. Please reload the app.")
        #     st.stop()


    num_providers_selected = len(selected_hospitals)
    if num_providers_selected > 15:
        st.write(f"WARNING: {num_providers_selected} selected - selecting any more providers will make the chart less usable")
    elif num_providers_selected > 10:
        st.write(f"WARNING: {num_providers_selected} selected - selecting more than 10 providers makes the chart more difficult to view")

    # --- SHOW ACTION BUTTONS TO RESET OR CREATE CHART
    if selected_states and selected_hospitals:
    # if selected_hospitals:
        # Add a little white space
        st.markdown("<br>", unsafe_allow_html=True)
        st.markdown('<hr style="line-height:6px;margin-bottom:7px;">', unsafe_allow_html=True)

        # Action buttons
        col1, col2, _ = st.columns([0.15, 0.15, 0.7])
        with col1:
            if st.button("Apply Filters", key="combined_apply_filters"):
                st.session_state.apply_filters_triggered = True
                st.rerun()

        with col2:
            if st.button("Reset Filters", key="combined_reset_filters"):
                # st.session_state.reset_filters_triggered = True
                st.session_state.update({
                    "apply_filters_triggered": False,
                    "reset_filters_triggered": True
                })
                st.rerun()
    
        # Add a little white space
        st.markdown('<hr style="line-height:6px;margin-top:-6px;">', unsafe_allow_html=True)
        # st.markdown("<br><br>", unsafe_allow_html=True)

    # Check to see if any one of the filters has been cleared.  If so,
    # reset the apply_filters_triggered flag in session_state
    # --- Check if any filter was cleared manually ---
    filters = [
        st.session_state.get("hppd_state_filter", []),
        st.session_state.get("hppd_hospital_filter", []),
    ]

    if any(len(f) == 0 for f in filters):
        st.session_state["apply_filters_triggered"] = False


    if st.session_state.apply_filters_triggered: # type: ignore
        # st.markdown("## Create chart!")
        with st.spinner("Applying filters..."):
            time.sleep(1)  # simulate processing delay

        # --- BUILD FILTERED DATASET: Filter the the baseline dataset based on user filter selections

        # Make a copy of the baseline dataset
        filtered_df = df.copy()

        # Start with the states filter and only select rows that match the states selected by the user
        if selected_states:
            filtered_df = filtered_df[filtered_df[COL_STATE_NAME].isin(selected_states)]

        # Next, filter the state-filtered dataset by the hospitals chosen by the user
        if selected_hospitals:
            filtered_df = filtered_df[filtered_df[COL_PROVIDER_NAME].isin(selected_hospitals)]

        # --- DISPLAY THE FILTERED DATASET:  Display as a table; Include a Total Hours summary

        if not filtered_df.empty:
            filtered_df[COL_MONTH] = pd.to_datetime(df[COL_MONTH])
            filtered_df["YEAR_MONTH"] = filtered_df[COL_MONTH].dt.strftime("%Y-%m")
            filtered_df = filtered_df.sort_values(by=[COL_STATE, COL_PROVIDER_NAME, "YEAR_MONTH"])

            st.markdown("### Filtered Results")
            # filtered_df = filtered_df.sort_values(by=[COL_STATE, COL_PROVIDER_NAME, COL_MONTH])
        #     st.dataframe(filtered_df.sort_values(by=[COL_STATE, COL_PROVIDER_NAME, COL_MONTH]))

        #     # Optional summary
        #     st.markdown(f"**Total Hours Worked:** {filtered_df[COL_TOTAL_HOURS].sum():,.2f}")

        # --- VISUALIZATION: Show a chart to represent the filtered data
            fig = px.line(
                filtered_df,
                x="YEAR_MONTH",
                y=COL_NURSE_HOURS_TO_PATIENT_RATIO,
                color=COL_PROVIDER_NAME,
                title="Monthly Hours Per Patient Day Ratio",
                markers=True
            )

            fig.update_layout(
                height=800,
                plot_bgcolor=theme[ATT_BG_COLOR],
                paper_bgcolor=theme[ATT_BG_COLOR],
                font=dict(
                    color=theme[ATT_FONT_COLOR],
                    family=theme[ATT_FONT_FAMILY]
                ),
                title_font=dict(
                    color=theme[ATT_FONT_COLOR]
                ),
                xaxis=dict(
                    title=dict(
                       text="Month",
                       font=dict(color=theme[ATT_FONT_COLOR])
                    ),
                    gridcolor=theme[ATT_MARKER_LINE_COLOR],
                    tickfont=dict(color=theme[ATT_FONT_COLOR])
                ),
                yaxis=dict(
                    title=dict(
                       text="Nurse Hours to Patient Ratio",
                       font=dict(color=theme[ATT_FONT_COLOR])
                    ),
                    gridcolor=theme[ATT_MARKER_LINE_COLOR],
                    tickfont=dict(color=theme[ATT_FONT_COLOR])
                ),
                legend=dict(
                    title=dict(
                        text="<b>Provider Name</b>",
                        font=dict(
                            size=14,
                            color=theme[ATT_FONT_COLOR]
                        )
                        ,
                    ),
                    font=dict(
                        color=theme[ATT_FONT_COLOR],
                        family=theme[ATT_FONT_FAMILY]
                        # size=12                       # Optional
                    )
                ),
                legend_tracegroupgap = 4, # Space between entries in legend
                hovermode="x unified",
                hoverlabel=dict(
                    bgcolor=HOVER_BGCOLOR,
                    font_color=HOVER_FONT_COLOR,
                    font_size=HOVER_FONT_SIZE,
                    font_family=HOVER_FONT_FAMILY
                )
            )

            # Customize the hover card layout
            fig.update_traces(
                customdata=filtered_df[[COL_PROVIDER_NAME, COL_TOTAL_NURSE_HOURS, COL_TOTAL_PATIENT_DAYS]],
                hovertemplate=(
                    "<b>%{customdata[0]}</b><br>" +
                    "Month: %{x|%b %Y}<br>" +
                    "Nurse Hours: %{customdata[1]:,.0f}<br>" +
                    "Patient Days: %{customdata[2]:,.0f}<br>" +
                    "HPPD Ratio: %{y:.2f}<extra></extra>"
                )
            )
            
            st.plotly_chart(fig, use_container_width=True)

        if not filtered_df.empty:
            # Show the raw data
            numrows = len(filtered_df)
            with st.expander(f"See Raw Data ({numrows:,.0f} rows)"):
                raw_data_df = filtered_df[[COL_PROVIDER_NAME, COL_STATE_NAME, "YEAR_MONTH", COL_TOTAL_NURSE_HOURS, COL_TOTAL_PATIENT_DAYS, COL_NURSE_HOURS_TO_PATIENT_RATIO]]
                # Format the float values for consistency
                raw_data_df = raw_data_df.style.format({COL_TOTAL_NURSE_HOURS: '{:,.2f}', COL_NURSE_HOURS_TO_PATIENT_RATIO: '{:.2f}'})
                
                st.dataframe(raw_data_df, use_container_width=True, height=600)

                # Overall summary
                st.markdown(f"**Average HPPD Across Selection:** {filtered_df[COL_NURSE_HOURS_TO_PATIENT_RATIO].mean():,.2f}")








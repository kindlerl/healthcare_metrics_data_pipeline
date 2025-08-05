import streamlit as st
import pandas as pd
import plotly.express as px
from utils.us_states import get_state
from utils.themes import get_base_theme
from utils.constants import COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_MONTH, COL_TOTAL_HOURS_WORKED
from utils.constants import HOVER_BGCOLOR, HOVER_FONT_FAMILY, HOVER_FONT_COLOR, HOVER_FONT_SIZE
from utils.constants import ATT_BG_COLOR, ATT_FONT_FAMILY, ATT_FONT_COLOR, ATT_MARKER_LINE_COLOR
import time

def render_staffing_hours_combined(df):

    # --- Early exit if Reset Filters was clicked ---
    if "reset_filters_triggered" in st.session_state and st.session_state.reset_filters_triggered:
        st.session_state.update({
            "combined_state_filter": [],
            "combined_hospital_filter": [],
            "combined_month_filter": [],
            "reset_filters_triggered": False
        })
        st.rerun()

    st.markdown("### Combined View: Set Filters")
    
    if "apply_filters_triggered" not in st.session_state:
        st.session_state.apply_filters_triggered = False

    # show_theme_selector()
    theme = get_base_theme()

    # --- FILTER: STATE ---
    df[COL_STATE_NAME] = df[COL_STATE].apply(get_state)
    df = df[[COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_MONTH, COL_TOTAL_HOURS_WORKED]]

    states = sorted(df[COL_STATE_NAME].unique())  # Get a simple, sorted list of the state names
    try:
        selected_states = st.multiselect("Select State(s):", states, key="combined_state_filter")
    except Exception as e:
        st.error("Something went wrong loading state filters. Please reload the app.")
        st.stop()

    # --- FILTER: HOSPITAL (Only show after state is picked) ---
    if selected_states:
        st.markdown('<br style="line-height:6px;">', unsafe_allow_html=True)

        filtered_state_df = df[df[COL_STATE_NAME].isin(selected_states)]
        hospital_options = sorted(filtered_state_df[COL_PROVIDER_NAME].unique())
        try:
            selected_hospitals = st.multiselect("Select Hospital(s):", hospital_options, key="combined_hospital_filter")
        except Exception as e:
            st.error("Something went wrong loading hospital filters. Please reload the app.")
            st.stop()
    else:
        selected_hospitals = []

    # --- FILTER: MONTH (Only show after hospital is picked) ---
    if selected_hospitals:
        st.markdown('<br style="line-height:6px;">', unsafe_allow_html=True)

        filtered_hospital_df = filtered_state_df[filtered_state_df[COL_PROVIDER_NAME].isin(selected_hospitals)] # type: ignore
        month_options = sorted(filtered_hospital_df[COL_MONTH].unique())
        try:
            selected_months = st.multiselect("Select Month(s):", month_options, key="combined_month_filter")
        except:
            st.error("Something went wrong loading month filters. Please reload the app.")
            st.stop()
    else:
        selected_months = []


    if selected_states and selected_hospitals and selected_months:

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
        st.session_state.get("combined_state_filter", []),
        st.session_state.get("combined_hospital_filter", []),
        st.session_state.get("combined_month_filter", []),
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

        # Finally, filter the state-hospital-filtered dataset by the months chosen by the user
        if selected_months:
            filtered_df = filtered_df[filtered_df[COL_MONTH].isin(selected_months)]

        # --- DISPLAY THE FILTERED DATASET:  Display as a table; Include a Total Hours summary

        if not filtered_df.empty:
            st.markdown("### Filtered Results")

            # Convert the months to a date data type to ensure proper sort order
            # in the line chart
            filtered_df[COL_MONTH] = pd.to_datetime(filtered_df[COL_MONTH])
            filtered_df["YEAR_MONTH"] = filtered_df[COL_MONTH].dt.strftime("%Y-%m")

            # Ensure the proper sort order
            filtered_df = filtered_df.sort_values(by=[COL_PROVIDER_NAME, COL_STATE_NAME, "YEAR_MONTH"])

        # --- VISUALIZATION: Show a chart to represent the filtered data
            fig = px.line(
                filtered_df,
                x="YEAR_MONTH",
                y=COL_TOTAL_HOURS_WORKED,
                color=COL_PROVIDER_NAME,
                title="Monthly Nurse Hours by Hospital",
                markers=True
            )

            fig.update_layout(
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
                       text="Total Hours Worked",
                       font=dict(color=theme[ATT_FONT_COLOR])
                    ),
                    gridcolor=theme[ATT_MARKER_LINE_COLOR],
                    tickfont=dict(color=theme[ATT_FONT_COLOR])
                ),
                legend=dict(
                    title=dict(
                        text="<b>Provider Name</b>",
                        font=dict(color=theme[ATT_FONT_COLOR])
                    ),
                    font=dict(
                        color=theme[ATT_FONT_COLOR],
                        family=theme[ATT_FONT_FAMILY]
                        # size=12 
                    )
                ),
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
                hovertemplate=(
                    "<b>%{customdata[0]}</b><br>" +
                    "Month: %{x|%B %Y}<br>" +
                    "Total Hours Worked: %{y:,.2f}"
                ),
                customdata=filtered_df[[COL_PROVIDER_NAME]]
            )
            
            st.plotly_chart(fig, use_container_width=True)

        if not filtered_df.empty:
            # Show the raw data
            numrows = len(filtered_df)
            with st.expander(f"See Raw Data ({numrows:,.0f} rows)"):
                raw_data_df = filtered_df[[COL_PROVIDER_NAME, COL_STATE_NAME, "YEAR_MONTH", COL_TOTAL_HOURS_WORKED]]

                styled_df = (
                    raw_data_df.style
                        .format({COL_TOTAL_HOURS_WORKED: "{:,.2f}"})  # Format with commas + 2 decimals
                        .set_properties(subset=[COL_TOTAL_HOURS_WORKED], **{'text-align': 'right'})  # Align data
                        .set_table_styles(
                          [{'selector': f'th.col{i}', 'props': [('text-align', 'right')]}
                           for i, col in enumerate(raw_data_df.columns) if col == COL_TOTAL_HOURS_WORKED]  # Align header
                        )
                    )

                st.table(styled_df)

                # Optional summary
                st.markdown(f"**Total Hours Worked:** {filtered_df[COL_TOTAL_HOURS_WORKED].sum():,.2f}")



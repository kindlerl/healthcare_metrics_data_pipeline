import streamlit as st
import pandas as pd
# from utils.us_states import get_state
import plotly.express as px
import calendar
from utils.themes import get_base_theme
from utils.constants import ATT_BG_COLOR, ATT_COLORSCALE, ATT_FONT_COLOR, ATT_MARKER_LINE_COLOR

def render_by_month(df):

    # Set the theme
    theme = get_base_theme()

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

    fig.update_layout(
        title_font=dict(size=18, color=theme[ATT_FONT_COLOR]),
        paper_bgcolor=theme[ATT_BG_COLOR],
        plot_bgcolor=theme[ATT_BG_COLOR],
        font=dict(color=theme[ATT_FONT_COLOR]),
        margin=dict(l=0, r=0, t=40, b=40),
        xaxis=dict(
            title=dict(
               text="Month Name",
               font=dict(color=theme[ATT_FONT_COLOR])
            ),
            tickfont=dict(color=theme[ATT_FONT_COLOR]),
            gridcolor=theme[ATT_MARKER_LINE_COLOR],
            zerolinecolor=theme[ATT_MARKER_LINE_COLOR]
        ),
        yaxis=dict(
            title=dict(
               text="Total Hours Worked",
               font=dict(color=theme[ATT_FONT_COLOR])
            ),
            tickfont=dict(color=theme[ATT_FONT_COLOR]),
            gridcolor=theme[ATT_MARKER_LINE_COLOR],
            zerolinecolor=theme[ATT_MARKER_LINE_COLOR]
        )
    )
    
    # Update the colors in the hover balloon
    fig.update_layout(
        hoverlabel=dict(
            bgcolor="black",      # Background color
            font_size=14,
            font_family="Verdana",
            font_color="#e0e0e0"    # Text color (newer Plotly versions)
        )
    )

    fig.update_traces(
        hovertemplate='<b>%{x}</b><br>Total Hours: %{y:,.0f}<extra></extra>'
    )
    st.plotly_chart(fig, use_container_width=True)

    # Show the raw data
    numrows = len(df_month)
    with st.expander(f"See Raw Data ({numrows:,.0f} rows)"):
        st.dataframe(df_month)


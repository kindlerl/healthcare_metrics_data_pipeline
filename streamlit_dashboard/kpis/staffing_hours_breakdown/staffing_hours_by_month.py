import streamlit as st
import pandas as pd
# from utils.us_states import get_state
import plotly.express as px
import calendar
from utils.themes import get_base_theme
from utils.constants import ATT_BG_COLOR, ATT_COLORSCALE, ATT_FONT_COLOR, ATT_MARKER_LINE_COLOR
from utils.constants import COL_TOTAL_HOURS_WORKED, COL_MONTH, COL_MONTH_NAME

def render_by_month(df):

    # Set the theme
    theme = get_base_theme()

    # Get the data, grouped by state
    df_month = df.groupby([COL_MONTH]).agg({COL_TOTAL_HOURS_WORKED:'sum'}).reset_index()

    # Get the full month name from the date
    df_month[COL_MONTH_NAME] = pd.to_datetime(df_month[COL_MONTH]).dt.month_name()
    df_month = df_month[[COL_MONTH_NAME, COL_TOTAL_HOURS_WORKED]]

    # Preserve the calendar order
    df_month[COL_MONTH_NAME] = pd.Categorical(df_month[COL_MONTH_NAME], categories=calendar.month_name[1:], ordered=True)
    df_month = df_month.sort_values(COL_MONTH_NAME)

    fig = px.bar(
        df_month,
        x=COL_MONTH_NAME,
        y=COL_TOTAL_HOURS_WORKED,
        labels={COL_MONTH_NAME: "Month", COL_TOTAL_HOURS_WORKED: "Total Nurse Hours Worked"},
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
        styled_df = (
            df_month.style
            .format({COL_TOTAL_HOURS_WORKED: "{:,.2f}"})  # Format with commas + 2 decimals
            .set_properties(subset=[COL_TOTAL_HOURS_WORKED], **{'text-align': 'right'})  # Align data
            .set_table_styles(
                [{'selector': f'th.col{i}', 'props': [('text-align', 'right')]}
                 for i, col in enumerate(df_month.columns) if col == COL_TOTAL_HOURS_WORKED]  # Align header
            )
        )

        st.table(styled_df)


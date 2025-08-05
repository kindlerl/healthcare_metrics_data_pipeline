import streamlit as st
import pandas as pd
import plotly.express as px
from utils.db import get_data_as_dataframe
from utils.themes import get_base_theme
from utils.constants import DB_NAME, DB_SCHEMA
from utils.constants import COL_METRIC_NAME, COL_METRIC_SOURCE, COL_AVG_SCORE, COL_LAST_UPDATED
from utils.constants import PCT_SSR_HOSP_AFTER_NURSING_HOME, PCT_SSR_OUTPATIENT_EMER_DEPT_VISIT, NUM_HOSP_PER_1000_LSRD, NUM_OUTPATIENT_EMER_VISITS_PER_1000_LSRD
from utils.constants import ATT_BG_COLOR, ATT_COLORSCALE, ATT_FONT_COLOR, ATT_FONT_FAMILY, ATT_MARKER_LINE_COLOR

def wrap_bar_labels(str):
    charwidth = 30
    words = str.split()
    str_out = ''
    phrase = ''

    for word in words:
        if len(phrase) + len(word) >= charwidth:
            str_out += phrase.strip() + '<br>'
            phrase = word + ' '
        else:
            phrase += word + ' '

    if len(phrase) > 0:
        str_out += phrase

    return str_out


def render_readmission_metrics():

     # Get the base Gold data for readmission rates
    sql = "SELECT * FROM " + DB_NAME + "." + DB_SCHEMA + ".KPI_30_DAY_READMISSION_RATE_BY_DIAGNOSIS"
    df = get_data_as_dataframe(sql)
   
    st.markdown("### Readmission Rates by Diagnosis")

    # Set the theme
    theme = get_base_theme()

    # Round the averages to 2 decimals
    df[COL_AVG_SCORE] = df[COL_AVG_SCORE].round(2)

    # Sort the rows by increasing risk score
    df = df.sort_values(by=COL_AVG_SCORE, ascending=True)

    # Try to wrap the x-axis labels
    df['WRAPPED_METRIC_NAME'] = df[COL_METRIC_NAME].apply(wrap_bar_labels)

    # Define a custom color pallette
    # custom_colors = ["#4E79A7", "#A0CBE8", "#F28E2B", "#FFBE7D"]  # Blue → Orange
    custom_colors = ["#EEC9E5", "#CE9CBC", "#A5729B", "#7D4D7A"]

    fig = px.bar(
        df,
        x="WRAPPED_METRIC_NAME",
        y=COL_AVG_SCORE,
        color="METRIC_NAME",  # 👈 Each bar gets a unique trace & color
        text=df["AVG_SCORE"].apply(lambda x: f"{x:.2f}"),
        # text=COL_AVG_SCORE,
        # labels={COL_AVG_SCORE: "Average Readmission Rates"},
        title="Readmission Rates Within 30 Days by Diagnosis Category",
        color_discrete_sequence=custom_colors 
    )

    fig.update_layout(
        height = 800,
        title_font=dict(size=18, color=theme[ATT_FONT_COLOR]),
        paper_bgcolor=theme[ATT_BG_COLOR],
        plot_bgcolor=theme[ATT_BG_COLOR],
        font=dict(color=theme[ATT_FONT_COLOR]),
        margin=dict(l=0, r=0, t=40, b=40),
        xaxis=dict(
            title=None,
            # title=dict(
            #    text="Month Name",
            #    font=dict(color=theme[ATT_FONT_COLOR])
            # ),
            tickangle=0,
            tickfont=dict(
                size=14,
                family="Verdana",
                color=theme[ATT_FONT_COLOR]
            ),
            gridcolor=theme[ATT_MARKER_LINE_COLOR],
            zerolinecolor=theme[ATT_MARKER_LINE_COLOR]
        ),
        yaxis=dict(
            title=dict(
               text="Average Readmission Rates",
               font=dict(
                   family="Verdana",
                   size=14,
                   color=theme[ATT_FONT_COLOR]
               )
            ),
            tickfont=dict(
                size=14,
                family="Verdana",
                color=theme[ATT_FONT_COLOR]
            ),
            gridcolor=theme[ATT_MARKER_LINE_COLOR],
            zerolinecolor=theme[ATT_MARKER_LINE_COLOR]
        ),
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=-0.3,
            xanchor="center",
            x=0.5,
            title=None,
            font=dict(
                color=theme[ATT_FONT_COLOR],
                family=theme[ATT_FONT_FAMILY]
                # size=12                       # Optional
            )
        )
    )

    # Format
    fig.update_traces(
        textposition='outside',
        textfont=dict(
            size=14,
            family="Verdana"
        ),
        hovertemplate="<b>%{x}</b><br>Avg. Rate: %{y:.2f}<extra></extra>"
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

    st.plotly_chart(fig, use_container_width=True)

    # Show the raw data
    st.markdown("<br>", unsafe_allow_html=True)
    with st.expander(f"See Raw Data"):
        st.dataframe(df)









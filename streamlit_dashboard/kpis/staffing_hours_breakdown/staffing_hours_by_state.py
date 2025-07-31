import streamlit as st
import pandas as pd
from utils.us_states import get_state
from utils.themes import get_base_theme, show_theme_selector
import plotly.express as px
from utils.constants import COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_MONTH, COL_TOTAL_HOURS

def render_by_state(df):
    # Get the data, grouped by state
    df_state = df.groupby([COL_STATE]).agg({COL_TOTAL_HOURS:'sum', COL_PROVIDER_NAME:'first'}).reset_index()
    df_state[COL_STATE_NAME] = df_state[COL_STATE].apply(lambda x: get_state(x))

    # Shift the column order to move the STATE_NAME next to the STATE for the 
    # raw data table visualization
    new_col_order = [COL_STATE, COL_STATE_NAME, COL_PROVIDER_NAME, COL_TOTAL_HOURS]
    df_state = df_state[new_col_order]

    # Allow the user to display the US States map at different sizes
    map_size = st.selectbox("Select Map Display Size", ["Small", "Medium", "Large"])
    size_dict = {
       "Small": (600,400),
       "Medium": (900, 600),
       "Large": (1200, 800)
    }
    mapwidth, mapheight = size_dict[map_size]

    # show_theme_selector()
    theme = get_base_theme()
    
    # Build choropleth map
    fig = px.choropleth(
        df_state,
        locations=COL_STATE,  # Column with state abbreviations
        locationmode='USA-states',
        color=COL_TOTAL_HOURS,
        color_continuous_scale='Blues',
        scope='usa',
        labels={COL_TOTAL_HOURS: 'Total Hours'},
        hover_name=COL_STATE_NAME,
        title='Total Nurse Hours Worked by State',
    )

    # Create a nicely formatted hover template
    fig.update_traces(
       hovertemplate='<b>%{customdata[0]}</b><br>' +
       'State Abbreviation: %{location}<br>'+
       'Total Hours: %{z:,.0f}<extra></extra>',
       customdata=df_state[[COL_STATE_NAME]]
    )

    # Apply layout and color to your figure
    fig.update_layout(
        title_font=dict(size=18, color=theme['font_color']),
        geo=dict(bgcolor=theme['bg_color']),
        paper_bgcolor=theme['bg_color'],
        plot_bgcolor=theme['bg_color'],
        font=dict(color=theme['font_color']),
        coloraxis_colorbar=dict(
            title=dict(
               text="Total Hours",
               font=dict(color=theme['font_color'])
            ),
            tickfont=dict(color=theme['font_color'])
        ),
        margin=dict(l=0, r=0, t=0, b=0)

    )

    fig.update_traces(
        colorscale=theme['colorscale'],
        marker_line_color=theme['marker_line_color'],
        marker_line_width=0.5,
        colorbar_title="Total Hours"
    )

    # Configure the plotly canvas size for the US map
    fig.update_layout(
        width = mapwidth,
        height = mapheight,
       margin={"r":0, "t":50, "l":0, "b":0}
    )

    st.plotly_chart(fig, use_container_width=True)

    # Optional: show raw data
    with st.expander("See Raw Data"):
        st.dataframe(df_state)

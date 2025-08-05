import streamlit as st
import pandas as pd
import plotly.express as px
from utils.us_states import get_state
from utils.themes import get_base_theme
from utils.constants import COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_TOTAL_HOURS_WORKED
from utils.constants import TOP_10_ROWS, TOP_20_ROWS, TOP_50_ROWS, ALL_ROWS
from utils.constants import ATT_BG_COLOR, ATT_COLORSCALE, ATT_FONT_COLOR, ATT_MARKER_LINE_COLOR, ATT_MARKER_BAR_COLOR
from utils.constants import HOVER_BGCOLOR, HOVER_FONT_FAMILY, HOVER_FONT_COLOR, HOVER_FONT_SIZE


def render_by_hospital(df):

    # Set the theme
    theme = get_base_theme()

    # Fetch the min/max hours worked to establish enpoints for our slider
    hours_worked = df[COL_TOTAL_HOURS_WORKED].agg(['min', 'max'])
    min,max = st.slider("Select Total Hours Worked Range", \
                  min_value = float(hours_worked['min']), \
                  max_value = float(hours_worked['max']), \
                  value = [float(hours_worked['min']), float(hours_worked['max'])]) # Starting values

    sort_order = st.radio("Sort Order", ["Descending", "Ascending"])
    asc = True if sort_order == "Ascending" else False

    # Allow the user to filter the number of rows shown in the visualization
    RowLimit = st.selectbox("Limit rows:", [
        TOP_10_ROWS,
        TOP_20_ROWS,
        TOP_50_ROWS,
        ALL_ROWS
    ])

    numrows = 10. # Default
    if RowLimit == TOP_10_ROWS:
        numrows = 10
    elif RowLimit == TOP_20_ROWS:
      numrows = 20
    elif RowLimit == TOP_50_ROWS:
      numrows = 50
    elif RowLimit == ALL_ROWS:
      numrows = 0  # Just a marker to pivot on

    # Filter the data to aggregate the TOTAL_HOURS_WORKED for this visualization
    df_grouped = df.groupby([COL_PROVIDER_NAME]).agg({COL_TOTAL_HOURS_WORKED:'sum', COL_STATE:'first'}).reset_index()
    df_grouped[COL_STATE_NAME] = df_grouped[COL_STATE].apply(lambda x: get_state(x))

    # Shift the column order to move the STATE_NAME next to the STATE for the 
    # raw data table visualization
    new_col_order = [COL_PROVIDER_NAME, COL_STATE, COL_STATE_NAME, COL_TOTAL_HOURS_WORKED]
    df_grouped = df_grouped[new_col_order]

    # Filter the providers using the min,max values from the input slider
    df_filtered = df_grouped.loc[df_grouped[COL_TOTAL_HOURS_WORKED].between(min,max)]

    # Trim down the results to the user's preference
    if numrows == 0:
        df_filtered = df_filtered.sort_values(by=COL_TOTAL_HOURS_WORKED, ascending=asc)
    else:
        df_filtered = df_filtered.sort_values(by=COL_TOTAL_HOURS_WORKED, ascending=asc).head(numrows)

    # Calculate ranking for each row, to be shown in the hover by adding a RANK column
    df_filtered = df_filtered.reset_index(drop=True)
    df_filtered['RANK'] = df_filtered.index + 1
    df_filtered['MAX_RANK'] = len(df_filtered)

    # Visualization
    st.subheader("Visualization")

    # Build the chart
    fig = px.bar(df_filtered, 
                 x=COL_TOTAL_HOURS_WORKED, 
                 y=COL_PROVIDER_NAME, 
                 hover_data=[COL_STATE],
                 orientation="h", 
                 title="Total Hours by Hospital",
                 labels={
                    COL_TOTAL_HOURS_WORKED: "Total Nurse Hours Worked",
                    COL_PROVIDER_NAME: "Hospital Name (Top 50)"
                    }
                 )

    # Reverse the order in which Plotly charts the bars to match 
    # the natural user expectation
    fig.update_layout(yaxis=dict(autorange="reversed"))

    # Create a nicely formatted hover template
    fig.update_traces(
       hovertemplate='<b>%{y}</b><br>' +
       'State Abbreviation: %{customdata[0]}<br>'+
       'State Name: %{customdata[1]}<br>'+
       'Total Hours: %{x:,.0f}<br>' + 
       'Ranking: %{customdata[2]} of %{customdata[3]}<extra></extra>',
       customdata=df_filtered[[COL_STATE, COL_STATE_NAME, 'RANK', 'MAX_RANK']]
    )

    y_axis_text = f" (Top {numrows})" if numrows > 0 else ""

    fig.update_layout(
        title_font=dict(size=18, color=theme[ATT_FONT_COLOR]),
        paper_bgcolor=theme[ATT_BG_COLOR],
        plot_bgcolor=theme[ATT_BG_COLOR],
        font=dict(color=theme[ATT_FONT_COLOR]),
        margin=dict(l=0, r=0, t=40, b=40),
        xaxis=dict(
            title=dict(
               text="Total Nurse Hours Worked",
               font=dict(color=theme[ATT_FONT_COLOR])
            ),
            tickfont=dict(color=theme[ATT_FONT_COLOR]),
            gridcolor=theme[ATT_MARKER_LINE_COLOR],
            zerolinecolor=theme[ATT_MARKER_LINE_COLOR]
        ),
        yaxis=dict(
            title=dict(
               text="Hospital Name" + y_axis_text,
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
            bgcolor=HOVER_BGCOLOR,
            font_size=HOVER_FONT_SIZE,
            font_family=HOVER_FONT_FAMILY,
            font_color=HOVER_FONT_COLOR
        )
    )

    fig.update_traces(
        marker=dict(
            color=theme[ATT_MARKER_BAR_COLOR],
            line=dict(
                color=theme[ATT_MARKER_LINE_COLOR],
                width=1.5
            )
        )
    )


    # Show the chart
    st.plotly_chart(fig, use_container_width=True)

    # Show the raw data
    # Only show the relevant columns
    df_filtered = df_filtered[[COL_PROVIDER_NAME, COL_STATE_NAME, COL_TOTAL_HOURS_WORKED]]

    numrows = len(df_filtered)
    with st.expander(f"See Raw Data ({numrows:,.0f} rows)"):
        styled_df = (
            df_filtered.style
            .format({COL_TOTAL_HOURS_WORKED: "{:,.2f}"})  # Format with commas + 2 decimals
            .set_properties(subset=[COL_TOTAL_HOURS_WORKED], **{'text-align': 'right'})  # Align data
            .set_table_styles(
                [{'selector': f'th.col{i}', 'props': [('text-align', 'right')]}
                 for i, col in enumerate(df_filtered.columns) if col == COL_TOTAL_HOURS_WORKED]  # Align header
            )
        )

        st.table(styled_df)
        

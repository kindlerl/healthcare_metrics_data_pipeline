import streamlit as st
import os
import snowflake.connector
from dotenv import load_dotenv
from utils.constants import SNOW_CONN, SNOW_CONNECTED

load_dotenv()

@st.cache_resource
def connect_to_snowflake():
  print(f"Establishing Snowflake connection")
  ctx = snowflake.connector.connect(
    user=os.getenv("SNOWFLAKE_USER"),
    password=os.getenv("SNOWFLAKE_PASSWORD"),
    account=os.getenv("SNOWFLAKE_ACCOUNT"),
    warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
    database=os.getenv("SNOWFLAKE_DATABASE"),
    schema=os.getenv("SNOWFLAKE_SCHEMA"),
    role=os.getenv("SNOWFLAKE_ROLE")
  )
  cs = ctx.cursor()
  st.session_state[SNOW_CONN] = cs
  st.session_state[SNOW_CONNECTED] = True
  return cs

def establish_snowflake_connection():
    # Since this same code will get executed multiple times based on state,
    # initialize the sessioon_state to detemrine if we've established a
    # Snowflake connection yet.
    if SNOW_CONNECTED not in st.session_state:
      st.session_state[SNOW_CONNECTED] = False

    if SNOW_CONNECTED in st.session_state:
      print(f"Session state: {st.session_state}")
    else:
      print(f"st.session_state[{SNOW_CONNECTED}] does not exist")

    # Connect to Snowflake
    if not st.session_state[SNOW_CONNECTED]:
      connect_to_snowflake()

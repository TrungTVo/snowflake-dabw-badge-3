# Import python packages
import streamlit as st
import os
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col

# Write directly to the app
st.title(f"Pending Smoothie Order :cup_with_straw:")

session = get_active_session()
pending_orders_df = session.table("SMOOTHIES.PUBLIC.ORDERS") \
    .filter(col("ORDER_FILLED") == 'FALSE') \
    .collect()

editable_pending_orders_df = st.data_editor(pending_orders_df)

# non-editable
# st.dataframe(data=editable_pending_orders_df, width='stretch')

if len(editable_pending_orders_df) > 0:
    submitted = st.button('Submit')
    if submitted:
        for idx, row in editable_pending_orders_df.iterrows():
            # st.write(row)
            update_stmt = """
                UPDATE SMOOTHIES.PUBLIC.ORDERS
                SET ORDER_FILLED = ?
                WHERE ORDER_UID = ?
            """
    
            session.sql(update_stmt, params=[
                bool(row["ORDER_FILLED"]),
                str(row["ORDER_UID"])
            ]).collect()
            
        st.success('Someone clicked button', icon="👍")
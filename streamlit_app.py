# Import python packages
import streamlit as st
import os
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col

# Write directly to the app
st.title(f"Customize Your Smoothie :cup_with_straw:")
st.write(
  """
  Choose the fruits you want in your custom Smoothie
  """
)

session = get_active_session()
fruits_dataframe = session.table("SMOOTHIES.PUBLIC.FRUIT_OPTIONS").select(col("FRUIT_NAME"))
# st.dataframe(data=fruits_dataframe, width='stretch')
# fruits_dataframe.show()
selected_ingredients = st.multiselect('Choose up to 5 ingredients:', fruits_dataframe)
if selected_ingredients:
    ingredients_str = ''
    for fruit_chosen in selected_ingredients:
        ingredients_str += fruit_chosen + ' '
    # st.write(ingredients_str)
    if ingredients_str:
        insert_stmt = """INSERT INTO SMOOTHIES.PUBLIC.ORDERS(ingredients)
                    values ('""" + ingredients_str + """')"""
        submit_order = st.button("Submit Order")
        if submit_order:
            session.sql(insert_stmt).collect()
            st.success('Your Smoothie is ordered!', icon="✅")


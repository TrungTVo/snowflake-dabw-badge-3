-- 1. Switch to SYSADMIN role
USE ROLE SYSADMIN;

-- 2. Create the database
CREATE DATABASE SMOOTHIES;

-- 3. Set the active database
USE DATABASE SMOOTHIES;
USE SCHEMA PUBLIC;

-- 4. Verify database ownership
SHOW DATABASES LIKE 'SMOOTHIES';

-- 5. Verify PUBLIC schema ownership
SHOW SCHEMAS LIKE 'PUBLIC' IN DATABASE SMOOTHIES;

-- auth setup config
ALTER API INTEGRATION GITHUB_API_INTEGRATION
SET ALLOWED_AUTHENTICATION_SECRETS = ( SMOOTHIES.PUBLIC.GITHUB_SECRET );

-- create git repo in snowflake
CREATE GIT REPOSITORY "snowflake-dabw-badge-3" 
	ORIGIN = 'https://github.com/TrungTVo/snowflake-dabw-badge-3' 
	API_INTEGRATION = 'GITHUB_API_INTEGRATION' 
	GIT_CREDENTIALS = 'SMOOTHIES.PUBLIC.GITHUB_SECRET';

-- create streamlit app from snowflake repo
CREATE STREAMLIT snowflake_dabw_badge_3
  FROM @SMOOTHIES.PUBLIC."snowflake-dabw-badge-3"/branches/master/
  MAIN_FILE = 'streamlit_app.py'
  QUERY_WAREHOUSE = 'COMPUTE_WH';

-- create fruit table
create or replace table SMOOTHIES.PUBLIC.FRUIT_OPTIONS (
    FRUIT_ID INTEGER,
    FRUIT_NAME VARCHAR(25)
) 
comment = 'fruits table';
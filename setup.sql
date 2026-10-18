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
CREATE OR REPLACE TABLE SMOOTHIES.PUBLIC.FRUIT_OPTIONS (
    FRUIT_ID INTEGER,
    FRUIT_NAME VARCHAR(25)
) 
comment = 'fruits table';

-- create file format
CREATE FILE FORMAT SMOOTHIES.PUBLIC.two_headerrow_pct_delim
  type = CSV,
  skip_header = 2,
  field_delimiter = '%',
  trim_space = TRUE;

-- create internal stage to store files
CREATE STAGE SMOOTHIES.PUBLIC.my_uploaded_files
	DIRECTORY = ( ENABLE = true ) 
	ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' ) 
	COMMENT = 'stage to store uploaded files';

-- upload the data file from local to the stage
/*
PUT file:///Users/trung/data/posts.json
    @SMOOTHIES.PUBLIC.my_uploaded_files
    AUTO_COMPRESS = TRUE
    OVERWRITE = TRUE;
*/

-- upload the data file from a folder in snowflake workspace to the stage
COPY FILES INTO @SMOOTHIES.PUBLIC.my_uploaded_files
FROM 'snow://workspace/USER$TRUNGVO.PUBLIC."snowflake-dabw-badge-3"/versions/head/data/'
FILES = ('fruits_available_for_smoothies.txt');

-- upload and sync the data file into the table
/*
COPY INTO SMOOTHIES.PUBLIC.FRUIT_OPTIONS
FROM @SMOOTHIES.PUBLIC.MY_UPLOADED_FILES
FILES = ('fruits_available_for_smoothies.txt')
FILE_FORMAT = (FORMAT_NAME = SMOOTHIES.PUBLIC.TWO_HEADERROW_PCT_DELIM)
ON_ERROR = ABORT_STATEMENT
VALIDATION_MODE = RETURN_ERRORS;
*/
COPY INTO SMOOTHIES.PUBLIC.FRUIT_OPTIONS
FROM (
    SELECT $2 as FRUIT_ID, $1 as FRUIT_NAME
    FROM @SMOOTHIES.PUBLIC.MY_UPLOADED_FILES/fruits_available_for_smoothies.txt
    (file_format => SMOOTHIES.PUBLIC.TWO_HEADERROW_PCT_DELIM)
)
ON_ERROR = ABORT_STATEMENT;
# UK Road Safety Data - Project Log

## Steps Completed

### 1. Extracted and organized raw data
- **Script**: `extract_data.py`
- Extracted 12 CSV files from zip archives into organized subfolders:
  - `data/accidents/` — accidents_2015.csv through accidents_2018.csv
  - `data/casualties/` — casualties_2015.csv through casualties_2018.csv
  - `data/vehicles/` — vehicles_2015.csv through vehicles_2018.csv
- Extracted 45 lookup CSVs from `variable lookup.xls` into `data/lookup/`

### 2. Created Python virtual environment and installed dependencies
- **File**: `requirements.txt`
- Virtual environment at `.venv/`
- Installed: pandas, xlrd, openpyxl, dbt-snowflake, snowflake-connector-python, duckdb

### 3. Initialized dbt project
- **Project folder**: `uk_road_safety_dbt/`
- Profile: `BTC` (configured in `~/.dbt/profiles.yml`)
- Connected to Snowflake:
  - Account: VODXNZD-WA49949
  - Database: UKROADSAFETYDATA
  - Schema: DBT_HNEMRAWI
  - Warehouse: LARGE_WH
- Connection verified with `dbt debug` — all checks passed

### 4. Created Snowflake infrastructure (SQL in Snowflake worksheet)
- Database: `UKROADSAFETYDATA`
- Schema: `UKROADSAFETY_SCHEMA`
- Internal stage: `UKROADSAFETY_STAGE`
- Warehouse: `LARGE_WH` (auto-suspend 60s, auto-resume)

### 5. Loaded all raw data into Snowflake
- **Script**: `load_to_snowflake.py`
- Created `RAW` schema with auto-typed tables via `INFER_SCHEMA`
- Stripped UTF-8 BOM from 2017/2018 files before upload
- PUT files to internal stage, then COPY INTO tables
- **57 tables loaded — 2,204,957 total rows**:
  - `RAW.ACCIDENTS_2015` ... `RAW.ACCIDENTS_2018` (529,294 rows)
  - `RAW.CASUALTIES_2015` ... `RAW.CASUALTIES_2018` (699,163 rows)
  - `RAW.VEHICLES_2015` ... `RAW.VEHICLES_2018` (975,680 rows)
  - `RAW.LOOKUP_*` — 45 lookup/reference tables (820 rows)

### 6. Built dbt staging layer (sources + staging models + tests)
- **Folder**: `uk_road_safety_dbt/models/staging/`
- Created `_sources.yml` defining all 57 RAW tables as dbt sources
- Created 3 fact staging models:
  - `stg_accidents.sql` — unions 4 years, 32 columns renamed to snake_case, date/time parsed, sentinel -1 → NULL
  - `stg_casualties.sql` — unions 4 years, generates `casualty_id` surrogate key
  - `stg_vehicles.sql` — unions 4 years, generates `vehicle_id` surrogate key, `propulsion_code` kept as VARCHAR (has code 'M')
- Created 45 lookup staging models (`stg_lookup_*.sql`) — consistent code/label interface
- Created `_stg_models.yml` with full documentation and 182 data tests:
  - unique, not_null, accepted_values, relationships (casualties→accidents, vehicles→accidents, police_force)
- Updated `dbt_project.yml`: staging models materialized as views in `DBT_HNEMRAWI_STAGING` schema
- **dbt run**: 48/48 models built successfully
- **dbt test**: 182/182 tests passed

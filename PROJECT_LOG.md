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
- Created 3 fact staging models (Jinja-looped UNION ALL with `try_cast` for safe type handling):
  - `stg_accidents.sql` — unions 4 years, 32 columns renamed to snake_case, date/time parsed, sentinel -1 → NULL
  - `stg_casualties.sql` — unions 4 years, generates `casualty_id` surrogate key
  - `stg_vehicles.sql` — unions 4 years, generates `vehicle_id` surrogate key, `propulsion_code` kept as VARCHAR (has code 'M')
- Created 45 lookup staging models (`stg_lookup_*.sql`) — consistent code/label interface
- Created `_stg_models.yml` with full documentation and 182 data tests:
  - unique, not_null, accepted_values, relationships (casualties→accidents, vehicles→accidents, police_force)
- Updated `dbt_project.yml`: staging models materialized as views in `DBT_HNEMRAWI_STAGING` schema
- **dbt run**: 48/48 models built successfully
- **dbt test**: 182/182 tests passed

### 7. Pushed to GitHub
- **Repo**: https://github.com/Hasnem/UKRoadSafetyData-.git
- Initial commit to `main` branch (76 files)
- `.gitignore` excludes: `.venv/`, `data/`, `*.duckdb`, dbt `target/`/`logs/`, `.claude/`
- Source `zip_archive/` included for reproducibility (32MB total)

### 8. Built dbt marts layer (analysis-ready tables for Looker Studio)
- **Folder**: `uk_road_safety_dbt/models/marts/`
- Architecture: Staging → Marts (no intermediate layer — joins are straightforward)
- Created 3 denormalized mart tables (materialized as tables in `DBT_HNEMRAWI_MARTS` schema):
  - `mart_accidents.sql` — 529,294 rows, accident-level table enriched with 18 lookup labels + derived columns (`is_fatal`, `is_weekend`, `accident_year`, `accident_month`)
  - `mart_casualties.sql` — 699,163 rows, casualty-level table with accident context, vehicle type, and 12 casualty lookup labels
  - `mart_vehicles.sql` — 975,680 rows, vehicle-level table with accident context and 16 vehicle lookup labels
- Each mart table is self-contained (all codes resolved to human-readable labels) — no joins needed in Looker Studio
- Both codes (for ordering/filtering) and labels (for display) included in every table
- Created `_marts_models.yml` with full documentation and 27 data tests:
  - unique + not_null on primary keys, relationships (casualties→accidents, vehicles→accidents)
  - accepted_values on severity labels (`Fatal`, `Serious`, `Slight`)
- Updated staging models to use Jinja loops + `try_cast` for robust type handling across years
- Updated `dbt_project.yml`: marts materialized as tables with `+schema: marts`
- **dbt run**: 51/51 models built successfully (48 staging views + 3 mart tables)
- **dbt test**: 209/209 tests passed (182 staging + 27 marts)

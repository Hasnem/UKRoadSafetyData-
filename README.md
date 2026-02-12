# UK Road Safety Data (2015-2018)

End-to-end data pipeline analyzing UK road accidents, casualties, and vehicles using Python, Snowflake, dbt, and Tableau.

**Dashboard:** [UK Road Safety 2015-2018 on Tableau Public](https://public.tableau.com/app/profile/hassan.al.nemrawi5474/viz/UKRoadSafety2015-2018/UKRoadSafety2015-2018)

---

## Architecture

```
ZIP Archives → Python (extract) → CSV Files → Python (load) → Snowflake RAW
    → dbt Staging (views) → dbt Marts (tables) → dbt Analysis (tables) → Tableau
```

## Data Sources

12 fact CSVs extracted from UK Department for Transport ZIP archives:

| Dataset    | Files              | Total Rows |
|------------|--------------------|------------|
| Accidents  | 4 (2015-2018)      | 529,294    |
| Casualties | 4 (2015-2018)      | 699,163    |
| Vehicles   | 4 (2015-2018)      | 975,680    |

Plus 45 lookup/reference tables extracted from `variable_lookup.xls`.

**Excluded files:**
- `RoadSafetyData_2015.zip` - duplicate of existing 2015 data
- `BloodAlcoholContent-CoronersMatchedData2009.zip` - unrelated to 2015-2018 scope, missing key columns for categories and vehicles

## Pipeline Steps

### 1. Extract Raw Data

**Script:** `extract_data.py`

- Extracts 12 CSVs from ZIP archives into `data/accidents/`, `data/casualties/`, `data/vehicles/`
- Converts 45 sheets from `variable_lookup.xls` into individual CSVs in `data/lookup/`

### 2. Snowflake Infrastructure

- **Database:** `UKROADSAFETYDATA`
- **Schema:** `UKROADSAFETY_SCHEMA`
- **Stage:** `UKROADSAFETY_STAGE` (internal)
- **Warehouse:** `LARGE_WH`

### 3. Load to Snowflake

**Script:** `load_to_snowflake.py`

- Creates `RAW` schema with auto-typed tables via `INFER_SCHEMA`
- Uploads files with `PUT`, loads with `COPY INTO`
- 57 tables loaded (12 fact + 45 lookup), 2,204,957 total rows

### 4. dbt Staging Layer

**Path:** `uk_road_safety_dbt/models/staging/`
**Schema:** `DBT_HNEMRAWI_STAGING` | **Materialization:** views

48 models (3 fact + 45 lookup):

- **stg_accidents** - Unions 4 yearly tables, 32 columns renamed to snake_case, date/time parsed, sentinel `-1` converted to NULL
- **stg_casualties** - Unions 4 yearly tables, generates `casualty_id` surrogate key
- **stg_vehicles** - Unions 4 yearly tables, generates `vehicle_id` surrogate key
- **45 stg_lookup_\*** - Standardized code/label pairs for all reference data

Uses Jinja-looped `UNION ALL` with `try_cast` and `nullif` for safe type handling across years with inconsistent column types.

### 5. dbt Marts Layer

**Path:** `uk_road_safety_dbt/models/marts/`
**Schema:** `DBT_HNEMRAWI_MARTS` | **Materialization:** tables

3 denormalized, analysis-ready tables with both codes and labels:

| Model            | Rows    | Description                                              |
|------------------|---------|----------------------------------------------------------|
| mart_accidents   | 529,294 | Accident-level, enriched with 18 lookup labels + derived columns (is_fatal, is_weekend) |
| mart_casualties  | 699,163 | Casualty-level with accident context, vehicle type, 12 casualty lookup labels |
| mart_vehicles    | 975,680 | Vehicle-level with accident context, 16 vehicle lookup labels |

### 6. dbt Analysis Layer

**Path:** `uk_road_safety_dbt/models/analysis/`
**Schema:** `DBT_HNEMRAWI_ANALYSIS` | **Materialization:** tables

9 pre-aggregated summary tables optimized for dashboard consumption (labels only, no codes):

| Model | Purpose |
|-------|---------|
| summary_yearly_kpis | Yearly scorecards with YoY changes |
| summary_temporal | Patterns by year/month/day/hour |
| summary_geographic | Police force area comparisons |
| dashboard_trend_ksi_paradox | Indexed trend: accidents down, severity up |
| dashboard_heatmap_hour_day | Fatality rate by hour and day of week |
| dashboard_conditions_multiplier | How risk compounds across conditions |
| dashboard_vulnerability_profile | Fatality rates by road user type and age |
| dashboard_deprivation_child | Child pedestrian casualties by deprivation |
| dashboard_police_force_map | Geographic bubble map with KSI trends |

### 7. Testing

230 dbt tests across all layers:

- **Staging (182):** unique, not_null, accepted_values, relationships
- **Marts (27):** primary keys, foreign keys, severity label validation
- **Analysis (21):** dimension uniqueness, not_null on key fields

### 8. Dashboard

Connected Snowflake to Tableau Desktop and published to [Tableau Public](https://public.tableau.com/app/profile/hassan.al.nemrawi5474/viz/UKRoadSafety2015-2018/UKRoadSafety2015-2018).

## Project Structure

```
├── extract_data.py              # Extracts CSVs from ZIP archives
├── load_to_snowflake.py         # Loads CSVs into Snowflake RAW schema
├── requirements.txt             # Python dependencies
├── data/                        # Extracted CSVs (not in git)
│   ├── accidents/
│   ├── casualties/
│   ├── vehicles/
│   └── lookup/
└── uk_road_safety_dbt/
    ├── dbt_project.yml
    └── models/
        ├── staging/             # 48 views + source/test definitions
        ├── marts/               # 3 denormalized tables + tests
        └── analysis/            # 9 pre-aggregated tables + tests
```

## Setup

### Prerequisites

- Python 3.x
- Snowflake account
- dbt-snowflake

### Install

```bash
pip install -r requirements.txt
```

### Configure

Create `~/.dbt/profiles.yml` with a `BTC` profile pointing to your Snowflake account and `UKROADSAFETYDATA` database.

### Run

```bash
# 1. Extract data from ZIP archives
python extract_data.py

# 2. Load into Snowflake
python load_to_snowflake.py

# 3. Build dbt models
cd uk_road_safety_dbt
dbt run

# 4. Run tests
dbt test
```

## Tech Stack

- **Extract & Load:** Python (pandas, snowflake-connector-python, xlrd)
- **Transform:** dbt-snowflake
- **Warehouse:** Snowflake
- **Visualization:** Tableau

"""
UK Road Safety Data - Load to Snowflake

Uploads extracted CSV files to the Snowflake internal stage, creates
tables in a RAW schema using INFER_SCHEMA, and loads the data.

Output tables (in UKROADSAFETYDATA.RAW):
    ACCIDENTS_2015 ... ACCIDENTS_2018
    CASUALTIES_2015 ... CASUALTIES_2018
    VEHICLES_2015 ... VEHICLES_2018
    LOOKUP_POLICE_FORCE, LOOKUP_ACCIDENT_SEVERITY, ... (45 lookup tables)

Usage: python load_to_snowflake.py
Prerequisites: pip install snowflake-connector-python pyyaml
"""

import snowflake.connector
import yaml
import tempfile
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
PROFILES_PATH = Path.home() / ".dbt" / "profiles.yml"

STAGE = "RAW.UKROADSAFETY_STAGE"
RAW_SCHEMA = "RAW"

# (subfolder, table_name_prefix)
CATEGORIES = [
    ("accidents",   ""),
    ("casualties",  ""),
    ("vehicles",    ""),
    ("lookup",      "lookup_"),
]


def get_connection():
    """Read credentials from dbt profiles.yml and connect to Snowflake."""
    with open(PROFILES_PATH) as f:
        config = yaml.safe_load(f)["BTC"]["outputs"]["dev"]
    return snowflake.connector.connect(
        account=config["account"],
        user=config["user"],
        password=config["password"],
        database=config["database"],
        warehouse=config["warehouse"],
        role=config["role"],
    )


def prepare_file(csv_path, temp_dir):
    """Copy CSV to temp dir, stripping UTF-8 BOM if present."""
    dest = Path(temp_dir) / csv_path.name
    with open(csv_path, "rb") as f:
        data = f.read()
    if data.startswith(b"\xef\xbb\xbf"):
        data = data[3:]
    with open(dest, "wb") as f:
        f.write(data)
    return dest


def setup_raw_schema(cur):
    """Create RAW schema and file formats."""
    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {RAW_SCHEMA}")
    cur.execute(f"CREATE STAGE IF NOT EXISTS {STAGE}")

    # File format for INFER_SCHEMA (needs PARSE_HEADER)
    cur.execute(f"""
        CREATE OR REPLACE FILE FORMAT {RAW_SCHEMA}.CSV_INFER
            TYPE = 'CSV'
            PARSE_HEADER = TRUE
            FIELD_OPTIONALLY_ENCLOSED_BY = '"'
            TRIM_SPACE = TRUE
    """)

    # File format for COPY INTO (PARSE_HEADER required for MATCH_BY_COLUMN_NAME)
    cur.execute(f"""
        CREATE OR REPLACE FILE FORMAT {RAW_SCHEMA}.CSV_LOAD
            TYPE = 'CSV'
            PARSE_HEADER = TRUE
            FIELD_OPTIONALLY_ENCLOSED_BY = '"'
            TRIM_SPACE = TRUE
    """)

    print("  RAW schema and file formats created.\n")


def load_file(cur, csv_path, category, table_name, temp_dir):
    """PUT a single CSV to stage, create table via INFER_SCHEMA, and COPY INTO."""
    clean_path = prepare_file(csv_path, temp_dir)
    put_path = str(clean_path).replace("\\", "/")

    # PUT to stage
    cur.execute(
        f"PUT 'file://{put_path}' @{STAGE}/{category}/ "
        f"AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
    )

    staged = f"@{STAGE}/{category}/{clean_path.name}.gz"

    # Create table with auto-detected schema
    cur.execute(f"""
        CREATE OR REPLACE TABLE {RAW_SCHEMA}.{table_name}
        USING TEMPLATE (
            SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
            FROM TABLE(INFER_SCHEMA(
                LOCATION => '{staged}',
                FILE_FORMAT => '{RAW_SCHEMA}.CSV_INFER'
            ))
        )
    """)

    # Load data
    cur.execute(f"""
        COPY INTO {RAW_SCHEMA}.{table_name}
        FROM {staged}
        FILE_FORMAT = '{RAW_SCHEMA}.CSV_LOAD'
        MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    """)

    # Row count
    cur.execute(f"SELECT COUNT(*) FROM {RAW_SCHEMA}.{table_name}")
    return cur.fetchone()[0]


def main():
    conn = get_connection()
    cur = conn.cursor()

    print(f"\nUK Road Safety Data - Load to Snowflake")
    print("=" * 60)

    print("\nSetting up RAW schema...")
    setup_raw_schema(cur)

    total_tables = 0
    total_rows = 0

    with tempfile.TemporaryDirectory() as tmp_dir:
        for category, prefix in CATEGORIES:
            folder = DATA_DIR / category
            if not folder.exists():
                print(f"WARNING: {folder} not found - skipping\n")
                continue

            csv_files = sorted(folder.glob("*.csv"))
            if not csv_files:
                continue

            print(f"Loading {category}/ ({len(csv_files)} files)...")

            for csv_path in csv_files:
                table_name = f"{prefix}{csv_path.stem}".upper()

                rows = load_file(cur, csv_path, category, table_name, tmp_dir)
                total_rows += rows
                total_tables += 1
                print(f"  RAW.{table_name:<45s} {rows:>10,} rows")

            print()

    print("=" * 60)
    print(f"DONE: {total_tables} tables | {total_rows:,} total rows")
    print(f"Schema: UKROADSAFETYDATA.RAW")
    print("=" * 60)

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()

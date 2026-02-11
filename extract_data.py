"""
UK Road Safety Data - Extraction Script

Extracts all CSV files from zip archives into organized subfolders under data/,
and exports each sheet from variable_lookup.xls as a separate CSV.

Output structure:
    data/
        accidents/      accidents_2015.csv ... accidents_2018.csv
        casualties/     casualties_2015.csv ... casualties_2018.csv
        vehicles/       vehicles_2015.csv ... vehicles_2018.csv
        lookup/         one CSV per XLS sheet (e.g. police_force.csv)

Usage: python extract_data.py
Prerequisites: pip install pandas xlrd
"""

import zipfile
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
ZIP_DIR = BASE_DIR / "zip_archive"
DATA_DIR = BASE_DIR / "data"

# Maps zip filename (stem) -> (subfolder, output csv name)
CSV_ZIP_MAP = {
    "RoadSafetyData_Accidents_2015":       ("accidents",   "accidents_2015.csv"),
    "dftRoadSafety_Accidents_2016":        ("accidents",   "accidents_2016.csv"),
    "dftRoadSafetyData_Accidents_2017":    ("accidents",   "accidents_2017.csv"),
    "dftRoadSafetyData_Accidents_2018":    ("accidents",   "accidents_2018.csv"),
    "RoadSafetyData_Casualties_2015":      ("casualties",  "casualties_2015.csv"),
    "dftRoadSafetyData_Casualties_2016":   ("casualties",  "casualties_2016.csv"),
    "dftRoadSafetyData_Casualties_2017":   ("casualties",  "casualties_2017.csv"),
    "dftRoadSafetyData_Casualties_2018":   ("casualties",  "casualties_2018.csv"),
    "RoadSafetyData_Vehicles_2015":        ("vehicles",    "vehicles_2015.csv"),
    "dftRoadSafetyData_Vehicles_2016":     ("vehicles",    "vehicles_2016.csv"),
    "dftRoadSafetyData_Vehicles_2017":     ("vehicles",    "vehicles_2017.csv"),
    "dftRoadSafetyData_Vehicles_2018":     ("vehicles",    "vehicles_2018.csv"),
}

# XLS sheet name -> output csv name (written to data/lookup/)
LOOKUP_SHEET_MAP = {
    "Police Force":                "police_force.csv",
    "Accident Severity":           "accident_severity.csv",
    "Day of Week":                 "day_of_week.csv",
    "Local Authority (District)":  "local_authority_district.csv",
    "1st Road Class":              "road_class.csv",
    "Road Type":                   "road_type.csv",
    "Speed Limit":                 "speed_limit.csv",
    "Junction Detail":             "junction_detail.csv",
    "Junction Control":            "junction_control.csv",
    "2nd Road Class":              "second_road_class.csv",
    "Ped Cross - Human":           "ped_crossing_human.csv",
    "Ped Cross - Physical":        "ped_crossing_physical.csv",
    "Light Conditions":            "light_conditions.csv",
    "Weather":                     "weather_conditions.csv",
    "Road Surface":                "road_surface.csv",
    "Special Conditions at Site":  "special_conditions.csv",
    "Carriageway Hazards":         "carriageway_hazards.csv",
    "Urban Rural":                 "urban_rural.csv",
    "Police Officer Attend":       "police_officer_attend.csv",
    "Vehicle Type":                "vehicle_type.csv",
    "Towing and Articulation":     "towing_articulation.csv",
    "Vehicle Manoeuvre":           "vehicle_manoeuvre.csv",
    "Vehicle Location":            "vehicle_location.csv",
    "Junction Location":           "junction_location.csv",
    "Skidding and Overturning":    "skidding_overturning.csv",
    "Hit Object in Carriageway":   "hit_object_carriageway.csv",
    "Veh Leaving Carriageway":     "vehicle_leaving_carriageway.csv",
    "Hit Object Off Carriageway":  "hit_object_off_carriageway.csv",
    "1st Point of Impact":         "first_point_of_impact.csv",
    "Was Vehicle Left Hand Drive": "left_hand_drive.csv",
    "Journey Purpose":             "journey_purpose.csv",
    "Sex of Driver":               "sex_of_driver.csv",
    "Age Band":                    "age_band.csv",
    "Vehicle Propulsion Code":     "propulsion_code.csv",
    "Casualty Class":              "casualty_class.csv",
    "Sex of Casualty":             "sex_of_casualty.csv",
    "Casualty Severity":           "casualty_severity.csv",
    "Ped Location":                "ped_location.csv",
    "Ped Movement":                "ped_movement.csv",
    "Car Passenger":               "car_passenger.csv",
    "Bus Passenger":               "bus_passenger.csv",
    "Ped Road Maintenance Worker": "ped_road_maintenance.csv",
    "Casualty Type":               "casualty_type.csv",
    "IMD Decile":                  "imd_decile.csv",
    "Home Area Type":              "home_area_type.csv",
}


def extract_csvs():
    """Extract all CSV zip archives into organized subfolders under data/."""
    print("=" * 60)
    print("STEP 1: Extracting CSVs from zip archives")
    print("=" * 60)

    file_count = 0
    for zip_stem, (subfolder, out_name) in CSV_ZIP_MAP.items():
        zip_path = ZIP_DIR / f"{zip_stem}.zip"
        if not zip_path.exists():
            print(f"  WARNING: {zip_path.name} not found - skipping")
            continue

        out_dir = DATA_DIR / subfolder
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / out_name

        with zipfile.ZipFile(zip_path, "r") as zf:
            csv_file = [f for f in zf.namelist() if f.lower().endswith(".csv")][0]
            with zf.open(csv_file) as src, open(out_path, "wb") as dst:
                dst.write(src.read())

        file_count += 1
        print(f"  {subfolder + '/' + out_name:<45s} OK")

    print(f"\n  Extracted {file_count} CSV files.")


def extract_lookup_sheets():
    """Extract variable_lookup.xls from its zip and export each sheet as CSV."""
    print("\n" + "=" * 60)
    print("STEP 2: Extracting lookup CSVs from variable lookup.xls")
    print("=" * 60)

    lookup_zip = ZIP_DIR / "variable lookup.zip"
    if not lookup_zip.exists():
        print(f"  ERROR: {lookup_zip.name} not found!")
        return

    lookup_dir = DATA_DIR / "lookup"
    lookup_dir.mkdir(parents=True, exist_ok=True)

    # Extract the XLS to a temp location
    with zipfile.ZipFile(lookup_zip, "r") as zf:
        xls_name = [f for f in zf.namelist() if f.lower().endswith((".xls", ".xlsx"))][0]
        zf.extract(xls_name, lookup_dir)
    xls_path = lookup_dir / xls_name

    xls = pd.ExcelFile(str(xls_path))
    sheet_count = 0

    for sheet_name, csv_name in LOOKUP_SHEET_MAP.items():
        if sheet_name not in xls.sheet_names:
            print(f"  WARNING: Sheet '{sheet_name}' not found - skipping")
            continue

        df = pd.read_excel(xls, sheet_name)
        df.columns = [c.strip().lower() for c in df.columns]

        if "code" not in df.columns or "label" not in df.columns:
            print(f"  WARNING: Sheet '{sheet_name}' missing code/label columns - skipping")
            continue

        df = df[["code", "label"]].copy()
        df["label"] = df["label"].fillna("None").astype(str).str.strip()

        try:
            df["code"] = df["code"].astype(int)
        except (ValueError, TypeError):
            df["code"] = df["code"].astype(str).str.strip()

        csv_path = lookup_dir / csv_name
        df.to_csv(csv_path, index=False)
        sheet_count += 1
        print(f"  lookup/{csv_name:<40s} {len(df):>4} rows")

    # Close the ExcelFile handle before deleting
    xls.close()
    xls_path.unlink()
    print(f"\n  Extracted {sheet_count} lookup CSVs.")


if __name__ == "__main__":
    print(f"\nUK Road Safety Data - Extraction Script")
    print(f"Working directory: {BASE_DIR}\n")

    extract_csvs()
    extract_lookup_sheets()

    print("\n" + "=" * 60)
    print("DONE. All data extracted to: data/")
    print("=" * 60)

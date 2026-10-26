import pandas as pd  # pyright: ignore[reportMissingModuleSource]
from pathlib import Path

# Find the project folder
project_folder = Path(__file__).resolve().parent.parent
data_folder = project_folder / "data" / "raw" / "sales_data"

# Find the CSV file
csv_files = list(data_folder.glob("*.csv"))

if not csv_files:
    print("No CSV file found in data/raw. Please check the file location.")
else:
    file_path = csv_files[0]
    df = pd.read_csv(file_path)

    print("\n--- First 5 Rows ---")
    print(df.head())

    print("\n--- Dataset Shape (Rows, Columns) ---")
    print(df.shape)

    print("\n--- Column Names ---")
    print(df.columns.tolist())

    print("\n--- Data Types ---")
    print(df.dtypes)

    print("\n--- Missing Values ---")
    print(df.isnull().sum())

    print("\n--- Duplicate Rows ---")
    print(df.duplicated().sum())

    print("\n--- Statistical Summary ---")
    print(df.describe(include="all"))
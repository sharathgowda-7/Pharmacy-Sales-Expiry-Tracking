# pyright: reportMissingModuleSource=false
import pandas as pd
from pathlib import Path

# Set project paths
project_folder = Path(__file__).resolve().parent.parent
raw_folder = project_folder / "data" / "raw" / "sales_data"
processed_folder = project_folder / "data" / "processed"

processed_folder.mkdir(parents=True, exist_ok=True)

# Load the CSV file
csv_files = list(raw_folder.glob("*.csv"))

if not csv_files:
    raise FileNotFoundError("Place your CSV file inside data/raw/")

df = pd.read_csv(csv_files[0])

print("Original shape:", df.shape)

# 1. Remove duplicate rows
duplicates = df.duplicated().sum()
df = df.drop_duplicates()
print("Duplicate rows removed:", duplicates)

# 2. Clean column names
df.columns = (
    df.columns.astype(str)
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
)

# 3. Handle missing values
print("\nMissing values before cleaning:")
print(df.isnull().sum())

# 4. Convert the date column, if present
if "datum" in df.columns:
    df["datum"] = pd.to_datetime(df["datum"], errors="coerce")
elif "date" in df.columns:
    df["date"] = pd.to_datetime(df["date"], errors="coerce")

# 5. Check for invalid numeric values
numeric_columns = df.select_dtypes(include="number").columns

for column in numeric_columns:
    print(f"{column}: negative values =", (df[column] < 0).sum())

# Do not automatically replace missing sales values with zero.
# First inspect them and decide how to handle them.

# 6. Save the cleaned dataset
output_path = processed_folder / "sales_cleaned.csv"
df.to_csv(output_path, index=False)

print("\nCleaned shape:", df.shape)
print("Saved cleaned dataset to:", output_path)
print("\nCleaning completed!")
import pandas as pd  # type: ignore[reportMissingModuleSource]
from pathlib import Path

project_folder = Path(__file__).resolve().parent.parent

input_path = (
    project_folder / "data" / "processed" / "sales_cleaned.csv"
)

output_path = (
    project_folder / "data" / "processed" / "sales_long.csv"
)

df = pd.read_csv(input_path)

# Convert the wide dataset into a long dataset
medicine_columns = [
    "m01ab", "m01ae", "n02ba", "n02be",
    "n05b", "n05c", "r03", "r06"
]

sales_long = df.melt(
    id_vars=["datum"],
    value_vars=medicine_columns,
    var_name="medicine_category",
    value_name="sales"
)

sales_long["datum"] = pd.to_datetime(
    sales_long["datum"], errors="coerce"
)

sales_long["sales"] = pd.to_numeric(
    sales_long["sales"], errors="coerce"
)

sales_long = sales_long.dropna(
    subset=["datum", "medicine_category", "sales"]
)

sales_long.to_csv(output_path, index=False)

print("Original rows:", len(df))
print("Rows after transformation:", len(sales_long))
print("\nFirst 10 rows:")
print(sales_long.head(10))

print("\nSales by category:")
print(
    sales_long.groupby("medicine_category")["sales"]
    .sum()
    .sort_values(ascending=False)
)

print("\nSaved to:", output_path)
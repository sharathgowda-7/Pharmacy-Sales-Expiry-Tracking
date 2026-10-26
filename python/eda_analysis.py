import pandas as pd  # type: ignore[reportMissingModuleSource]
import matplotlib.pyplot as plt  # type: ignore[reportMissingModuleSource]
import seaborn as sns  # type: ignore[reportMissingModuleSource]
from pathlib import Path

# Project paths
project_folder = Path(__file__).resolve().parent.parent
data_path = project_folder / "data" / "processed" / "sales_cleaned.csv"
charts_folder = project_folder / "reports" / "charts"
charts_folder.mkdir(parents=True, exist_ok=True)

# Load cleaned data
df = pd.read_csv(data_path)
df["datum"] = pd.to_datetime(df["datum"], errors="coerce")

# Medicine category columns in the dataset
medicine_columns = [
    "m01ab", "m01ae", "n02ba", "n02be",
    "n05b", "n05c", "r03", "r06"
]

# Calculate total daily sales across the categories
df["total_sales"] = df[medicine_columns].sum(axis=1)

print("\n--- DATASET SUMMARY ---")
print("Rows and columns:", df.shape)
print("Date range:", df["datum"].min(), "to", df["datum"].max())
print("Total recorded sales across categories:", df["total_sales"].sum())

# 1. Total sales by medicine category
category_sales = df[medicine_columns].sum().sort_values(ascending=False)

print("\n--- SALES BY CATEGORY ---")
print(category_sales)

plt.figure(figsize=(10, 6))
category_sales.plot(kind="bar")
plt.title("Total Sales by Medicine Category")
plt.xlabel("Medicine Category")
plt.ylabel("Recorded Sales")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(charts_folder / "01_category_sales.png")
plt.show()

# 2. Daily total sales trend
daily_sales = df.groupby("datum")["total_sales"].sum().sort_index()

plt.figure(figsize=(12, 5))
plt.plot(daily_sales.index, daily_sales.values)
plt.title("Daily Sales Trend")
plt.xlabel("Date")
plt.ylabel("Recorded Sales")
plt.tight_layout()
plt.savefig(charts_folder / "02_daily_sales_trend.png")
plt.show()

# 3. Monthly sales trend
monthly_sales = (
    df.set_index("datum")["total_sales"]
    .resample("MS")
    .sum()
)

plt.figure(figsize=(12, 5))
plt.plot(monthly_sales.index, monthly_sales.values, marker="o")
plt.title("Monthly Sales Trend")
plt.xlabel("Month")
plt.ylabel("Recorded Sales")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(charts_folder / "03_monthly_sales_trend.png")
plt.show()

# 4. Sales by weekday
weekday_sales = (
    df.groupby("weekday_name")["total_sales"]
    .mean()
    .sort_values(ascending=False)
)

plt.figure(figsize=(9, 5))
weekday_sales.plot(kind="bar")
plt.title("Average Sales by Weekday")
plt.xlabel("Weekday")
plt.ylabel("Average Recorded Sales")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(charts_folder / "04_weekday_sales.png")
plt.show()

# 5. Correlation between medicine categories
correlation = df[medicine_columns].corr()

plt.figure(figsize=(9, 7))
sns.heatmap(correlation, annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Correlation Between Medicine Categories")
plt.tight_layout()
plt.savefig(charts_folder / "05_category_correlation.png")
plt.show()

print("\nEDA completed! Charts saved in:", charts_folder)
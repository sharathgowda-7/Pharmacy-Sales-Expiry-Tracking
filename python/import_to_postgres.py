import pandas as pd  # type: ignore[reportMissingModuleSource]
from pathlib import Path
from sqlalchemy import create_engine, text  # type: ignore[reportMissingImports]
from getpass import getpass

project_folder = Path(__file__).resolve().parent.parent
csv_path = project_folder / "data" / "processed" / "sales_long.csv"

if not csv_path.exists():
    raise FileNotFoundError(f"CSV file not found: {csv_path}")

df = pd.read_csv(csv_path)
df["datum"] = pd.to_datetime(df["datum"], errors="raise").dt.date

print("CSV rows:", len(df))
print("Columns:", df.columns.tolist())

password = getpass("Enter your PostgreSQL password: ")

# Change localhost/5432 only if your PostgreSQL uses different settings.
engine = create_engine(
    "postgresql+psycopg2://postgres:"
    + password.replace("@", "%40").replace("/", "%2F")
    + "@localhost:5432/pharmacy_analytics"
)

with engine.begin() as connection:
    connection.execute(text("""
        CREATE TABLE IF NOT EXISTS public.pharmacy_sales (
            datum DATE NOT NULL,
            medicine_category VARCHAR(20) NOT NULL,
            sales NUMERIC(12, 4) NOT NULL
        )
    """))

    count = connection.execute(
        text("SELECT COUNT(*) FROM public.pharmacy_sales")
    ).scalar_one()

    if count > 0:
        print("Table already contains", count, "rows. No import performed.")
    else:
        df.to_sql(
            "pharmacy_sales",
            engine,
            schema="public",
            if_exists="append",
            index=False,
            method="multi",
            chunksize=1000
        )
        print("Import completed.")

with engine.connect() as connection:
    count = connection.execute(
        text("SELECT COUNT(*) FROM public.pharmacy_sales")
    ).scalar_one()
    print("Records now in PostgreSQL:", count)
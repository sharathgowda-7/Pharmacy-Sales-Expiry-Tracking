Pharmacy Sales & Expiry Tracking

Overview

A data analytics project focused on analyzing historical pharmacy sales and monitoring medicine inventory expiry risk. The project uses Python for data cleaning and exploratory data analysis, PostgreSQL for SQL-based analysis, and Power BI for interactive dashboards.

Business question: Which medicine batches have expired or are approaching expiry while stock remains?

Objectives

* Analyze historical sales trends by medicine category.
* Identify high-performing categories and monthly sales patterns.
* Track batch expiry dates and remaining inventory.
* Estimate the purchase cost of expired and soon-to-expire stock.
* Present insights through Power BI dashboards.

Dataset

Source: Kaggle — Pharma Sales Data (salesdaily.csv)

The original dataset contains historical daily sales by medicine category. It does not include individual medicine names, inventory quantities, batch numbers, or expiry dates.

Separate illustrative inventory records were created for demonstrating batch and expiry tracking. These records are sample data, not verified pharmacy inventory.

Tools Used

* Python
* Pandas and NumPy
* Matplotlib and Seaborn
* PostgreSQL and pgAdmin
* Power BI
* Git and GitHub

Project Workflow

1. Loaded and inspected the Kaggle dataset.
2. Checked missing values, duplicates, and numeric data.
3. Cleaned and transformed the sales data using Python.
4. Performed exploratory data analysis and created charts.
5. Imported transformed sales data into PostgreSQL.
6. Wrote SQL queries for category totals, monthly trends, and yearly rankings.
7. Created medicine, supplier, and batch tables using illustrative sample records.
8. Analyzed expired stock, upcoming expiry, and estimated stock cost at risk.
9. Created Power BI dashboards for historical sales and expiry monitoring.

Key Findings

* N02BE recorded the highest total sales among the categories in the analyzed dataset.
* Monthly and yearly SQL queries were used to examine sales patterns.
* The expiry analysis identifies batches with remaining stock that are expired or nearing expiry, using illustrative inventory data.

Dashboards

The Power BI report contains:

* Historical sales by medicine category
* Sales trends over time
* Batches by expiry status
* Remaining stock by expiry date
* Estimated stock cost at risk
* Batch-level expiry details

Project Structure

* data/ — Raw and processed datasets
* python/ — Data cleaning and analysis scripts
* sql/ — PostgreSQL analysis queries
* powerbi/ — Power BI report
* reports/ — Charts and project outputs
* docs/ — Project documentation

How to Run

1. Download the dataset from Kaggle.
2. Run the Python scripts to clean and transform the data.
3. Create the PostgreSQL database and required tables.
4. Import the processed sales CSV into PostgreSQL.
5. Run the SQL analysis queries.
6. Insert the illustrative inventory records for expiry analysis.
7. Open the Power BI report and connect it to the required data sources.

Update file paths and database connection settings for your own environment.

Limitations

The Kaggle dataset contains category-level sales rather than batch-level inventory. Consequently, the project cannot establish actual unsold quantities or real medicine expiry losses from sales data alone. Expiry findings use illustrative inventory records to demonstrate the analysis process.

Author
sharath j
CSE Graduate | Aspiring Data Analyst

Skills demonstrated: Python, SQL, PostgreSQL, Data Cleaning, Exploratory Data Analysis, Data Visualization, and Power BI.
---creation of sales table
CREATE TABLE pharmacy_sales (
    sale_date DATE NOT NULL,
    medicine_category VARCHAR(20) NOT NULL,
    sales NUMERIC(12, 4) NOT NULL
);

------------------------------------------------------------------------
---column name matches csv header
ALTER TABLE pharmacy_sales
RENAME COLUMN sale_date TO datum;

------------------------------------------------------------------------

---checking  column names after import
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'pharmacy_sales'
ORDER BY ordinal_position;

------------------------------------------------------------------------
---verfifying import
select count(*) as total_records
from public.pharmacy_sales;

------------------------------------------------------------------------
---1.checking first 10 records
select * 
from pharmacy_sales
limit 10;
------------------------------------------------------------------------
---2.count all records
SELECT COUNT(*) AS total_records
FROM pharmacy_sales;

------------------------------------------------------------------------
---3.calculate total sales by category
SELECT medicine_category,ROUND(SUM(sales), 2) AS total_sales
FROM pharmacy_sales
GROUP BY medicine_category
ORDER BY total_sales DESC;

------------------------------------------------------------------------
----4.find monthly sales
SELECT DATE_TRUNC('month', datum)::DATE AS sales_month,ROUND(SUM(sales), 2) AS monthly_sales
FROM pharmacy_sales
GROUP BY DATE_TRUNC('month', datum)
ORDER BY sales_month;


------------------------------------------------------------------------
---5.find total sales
SELECT DATE_TRUNC('month', datum)::DATE AS sales_month,ROUND(SUM(sales), 2) AS total_sales
FROM public.pharmacy_sales
GROUP BY DATE_TRUNC('month', datum)
ORDER BY sales_month;

------------------------------------------------------------------------
---6.month with the highest total record sales
SELECT DATE_TRUNC('month', datum)::DATE AS sales_month,ROUND(SUM(sales), 2) AS total_sales
FROM public.pharmacy_sales
GROUP BY DATE_TRUNC('month', datum)
ORDER BY SUM(sales) DESC
LIMIT 1;


------------------------------------------------------------------------
---7.compare medicine category by year
WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM datum)::INT AS sales_year,
        medicine_category,
        SUM(sales) AS total_sales
    FROM public.pharmacy_sales
    GROUP BY
        EXTRACT(YEAR FROM datum),
        medicine_category
),
ranked_sales AS (
    SELECT
        sales_year,
        medicine_category,
        ROUND(total_sales, 2) AS total_sales,
        RANK() OVER (
            PARTITION BY sales_year
            ORDER BY total_sales DESC
        ) AS category_rank
    FROM yearly_sales
)
SELECT *
FROM ranked_sales
WHERE category_rank = 1
ORDER BY sales_year;

------------------------------------------------------------------------
---8.monthly category analsis
SELECT
    DATE_TRUNC('month', datum)::DATE AS sales_month,
    medicine_category,
    ROUND(SUM(sales), 2) AS total_sales
FROM public.pharmacy_sales
GROUP BY
    DATE_TRUNC('month', datum),
    medicine_category
ORDER BY
    sales_month,
    total_sales DESC;

------------------------------------------------------------------------
---9.find top 5 categories overall
	SELECT
    medicine_category,
    ROUND(SUM(sales), 2) AS total_sales
FROM public.pharmacy_sales
GROUP BY medicine_category
ORDER BY SUM(sales) DESC
LIMIT 5;

------------------------------------------------------------------------
---10.creating the inventory data for the expiry analysis.
-- Table 1: Medicines
CREATE TABLE IF NOT EXISTS public.medicines (
    medicine_id SERIAL PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL,
    medicine_category VARCHAR(20),
    unit_price NUMERIC(10,2) NOT NULL
);

-- Table 2: Suppliers
CREATE TABLE IF NOT EXISTS public.suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20)
);

-- Table 3: Medicine batches and expiry tracking
CREATE TABLE IF NOT EXISTS public.batches (
    batch_id SERIAL PRIMARY KEY,
    medicine_id INT NOT NULL REFERENCES public.medicines(medicine_id),
    supplier_id INT REFERENCES public.suppliers(supplier_id),
    batch_number VARCHAR(50) UNIQUE NOT NULL,
    purchase_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    quantity_received INT NOT NULL CHECK (quantity_received >= 0),
    quantity_remaining INT NOT NULL CHECK (
        quantity_remaining >= 0
        AND quantity_remaining <= quantity_received
    ),
    unit_cost NUMERIC(10,2) NOT NULL CHECK (unit_cost >= 0),
    CHECK (expiry_date > purchase_date)
);

------------------------------------------------------------------------
----11.checking whether the tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('medicines', 'suppliers', 'batches')
ORDER BY table_name;

----------------------------------------------------------------------	
---12. insert medicines.
INSERT INTO public.medicines
    (medicine_name, medicine_category, unit_price)
VALUES
    ('Paracetamol 500mg', 'N02BE', 2.50),
    ('Ibuprofen 200mg', 'M01AE', 4.00),
    ('Diclofenac 50mg', 'M01AB', 3.50),
    ('Aspirin 75mg', 'N02BA', 2.00),
    ('Cough Syrup', 'R05', 85.00),
    ('Allergy Tablets', 'R06', 5.00)
ON CONFLICT DO NOTHING;

------------------------------------------------------------------------
---13.inserting suppliers.
INSERT INTO public.suppliers
    (supplier_name, contact_number)
VALUES
    ('HealthCare Distributors', '9000000001'),
    ('MedPlus Wholesale', '9000000002'),
    ('City Pharma Suppliers', '9000000003')
ON CONFLICT DO NOTHING;

------------------------------------------------------------------------
---14.verify the data
SELECT * FROM public.medicines
ORDER BY medicine_id;

SELECT * FROM public.suppliers
ORDER BY supplier_id;

------------------------------------------------------------------------
---15.adding batches and expiry information
INSERT INTO public.batches
    (medicine_id, supplier_id, batch_number,
     purchase_date, expiry_date,
     quantity_received, quantity_remaining, unit_cost)
VALUES
    (1, 1, 'PAR-B001', '2026-01-10', '2026-11-15', 500, 120, 1.20),
    (1, 2, 'PAR-B002', '2026-02-01', '2027-06-30', 400, 300, 1.10),
    (2, 1, 'IBU-B001', '2026-03-05', '2026-10-20', 200, 80, 2.00),
    (3, 3, 'DIC-B001', '2026-04-12', '2026-12-15', 300, 210, 1.75),
    (4, 2, 'ASP-B001', '2026-05-01', '2026-10-30', 250, 150, 0.90),
    (5, 3, 'COU-B001', '2026-02-15', '2027-02-28', 100, 20, 50.00),
    (6, 1, 'ALL-B001', '2026-01-20', '2026-11-05', 350, 200, 2.50)
ON CONFLICT (batch_number) DO NOTHING;

------------------------------------------------------------------------
---16.verifying the record
SELECT
    b.batch_number,
    m.medicine_name,
    s.supplier_name,
    b.expiry_date,
    b.quantity_received,
    b.quantity_remaining
FROM public.batches b
JOIN public.medicines m
    ON b.medicine_id = m.medicine_id
LEFT JOIN public.suppliers s
    ON b.supplier_id = s.supplier_id
ORDER BY b.expiry_date;

------------------------------------------------------------------------
---17.identify expired meicines with remaining stock
SELECT
    m.medicine_name,
    b.batch_number,
    b.expiry_date,
    b.quantity_remaining,
    b.unit_cost,
    (b.quantity_remaining * b.unit_cost) AS stock_cost_at_risk
FROM public.batches b
JOIN public.medicines m
    ON b.medicine_id = m.medicine_id
WHERE b.expiry_date < CURRENT_DATE
  AND b.quantity_remaining > 0
ORDER BY b.expiry_date;

------------------------------------------------------------------------
----18.find medicines expiring within the next 30 days
SELECT
    m.medicine_name,
    b.batch_number,
    b.expiry_date,
    b.quantity_remaining,
    (b.quantity_remaining * b.unit_cost) AS stock_cost_at_risk,
    b.expiry_date - CURRENT_DATE AS days_until_expiry
FROM public.batches b
JOIN public.medicines m
    ON b.medicine_id = m.medicine_id
WHERE b.expiry_date >= CURRENT_DATE
  AND b.expiry_date <= CURRENT_DATE + 30
  AND b.quantity_remaining > 0
ORDER BY b.expiry_date;

------------------------------------------------------------------------
----19.calculate total stock value at risk
SELECT
    COUNT(*) AS batches_at_risk,
    COALESCE(SUM(quantity_remaining), 0) AS units_at_risk,
    ROUND(
        COALESCE(
            SUM(quantity_remaining * unit_cost), 0
        ), 2
    ) AS total_stock_cost_at_risk
FROM public.batches
WHERE expiry_date <= CURRENT_DATE + 30
  AND quantity_remaining > 0;
  
------------------------------------------------------------------------
---20.create a batch status report
  SELECT
    m.medicine_name,
    b.batch_number,
    b.expiry_date,
    b.quantity_remaining,
    CASE
        WHEN b.quantity_remaining = 0
            THEN 'No Stock Remaining'
        WHEN b.expiry_date < CURRENT_DATE
            THEN 'Expired'
        WHEN b.expiry_date <= CURRENT_DATE + 30
            THEN 'Expiring Soon'
        ELSE 'Safe'
    END AS expiry_status
FROM public.batches b
JOIN public.medicines m
    ON b.medicine_id = m.medicine_id
ORDER BY b.expiry_date;
-------------------------------------------------------------------------
------------------------------------------------------------------------
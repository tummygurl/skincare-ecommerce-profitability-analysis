import pandas as pd
import sqlite3

# File names (both files should be in the same folder as this script)
xlsx_path = "Global skincare and Beauty e-store_E-commerce Analysis_English.xlsx"
db_path   = "E-commerce.db"

# 1. Read the 'data' sheet from the Excel file
df = pd.read_excel(xlsx_path, sheet_name="data")

# 2. Make column names SQL-friendly: "Order Date" -> "order_date"
df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

# 3. Store dates as text in YYYY-MM-DD format (works best in SQLite)
df["order_date"] = df["order_date"].dt.strftime("%Y-%m-%d")

# 4. Write the data to SQLite as a table called raw_orders
conn = sqlite3.connect(db_path)
df.to_sql("raw_orders", conn, if_exists="replace", index=False)
conn.close()

print("Done. Rows loaded:", len(df))
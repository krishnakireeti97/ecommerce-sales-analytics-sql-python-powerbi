import pandas as pd
from pathlib import Path

DATA_DIR = Path("data")
OUTPUT_DIR = Path("outputs")

RAW_FILE = DATA_DIR / "raw_sales_data.csv"
CLEAN_FILE = OUTPUT_DIR / "cleaned_sales_data.csv"

def load_data():
    print(f"Loading data from {RAW_FILE}...")
    df = pd.read_csv(RAW_FILE)
    return df

def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    # Convert dates
    df["order_date"] = pd.to_datetime(df["order_date"], errors="coerce")

    # Remove rows with no order_id or product_id
    df = df.dropna(subset=["order_id", "product_id"])

    # Standardize text columns
    text_cols = ["customer_name", "city", "state", "country",
                 "product_name", "category", "sub_category",
                 "payment_method", "order_status"]
    for col in text_cols:
        if col in df.columns:
            df[col] = (
                df[col]
                .astype(str)
                .str.strip()
                .str.title()
            )

    # Fill missing discounts with 0
    if "discount" in df.columns:
        df["discount"] = df["discount"].fillna(0)

    # Calculate derived metrics
    df["gross_amount"] = df["unit_price"] * df["quantity"]
    df["discount_amount"] = df["gross_amount"] * df["discount"]
    df["net_amount"] = df["gross_amount"] - df["discount_amount"]

    # Extract date parts
    df["order_year"] = df["order_date"].dt.year
    df["order_month"] = df["order_date"].dt.month
    df["order_month_name"] = df["order_date"].dt.strftime("%b")
    df["order_day"] = df["order_date"].dt.day

    return df

def save_data(df: pd.DataFrame):
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEAN_FILE, index=False)
    print(f"Cleaned data saved to {CLEAN_FILE}")

if __name__ == "__main__":
    df_raw = load_data()
    df_clean = clean_data(df_raw)
    save_data(df_clean)


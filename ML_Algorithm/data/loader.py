import pandas as pd
import numpy as np
from config import EXCEL_PATH, SHEET_NAMES

def load_and_clean_data():
    xlsx = pd.ExcelFile(EXCEL_PATH)
    dfs = []

    for sheet in SHEET_NAMES:
        df = pd.read_excel(xlsx, sheet_name=sheet)
        session_col = [col for col in df.columns if "Session" in col]
        if "statement" in df.columns and session_col:
            df = df[["statement", session_col[0]]].rename(columns={session_col[0]: "label"})
            df["source"] = sheet
            dfs.append(df)

    df = pd.concat(dfs, ignore_index=True)
    df.replace([" ", "", "N/a", "n/a", "NA", "na"], np.nan, inplace=True)
    df.dropna(inplace=True)
    df = df[df['statement'].str.strip().astype(bool)]
    df.drop_duplicates(subset='statement', inplace=True)
    return df

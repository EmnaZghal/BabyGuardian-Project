import pandas as pd

GENDER_MAP = {
    "m": 1, "male": 1, "boy": 1,
    "f": 0, "female": 0, "girl": 0
}

NUMERIC_COLS = [
    "gestational_age_weeks", "birth_weight_kg", "birth_length_cm", "birth_head_circumference_cm",
    "age_days", "weight_kg", "length_cm", "head_circumference_cm", "temperature_c", "heart_rate_bpm",
    "respiratory_rate_bpm", "oxygen_saturation", "feeding_frequency_per_day", "urine_output_count",
    "stool_count", "jaundice_level_mg_dl", "apgar_score"
]

def normalize_gender(series: pd.Series) -> pd.Series:
    s = series.astype(str).str.strip().str.lower()
    return s.map(GENDER_MAP).astype("Int64")  # garde NaN si inconnu

def clean_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    # date → datetime si existe
    if "date" in df.columns:
        df["date"] = pd.to_datetime(df["date"], errors="coerce")

    # gender binaire
    if "gender" in df.columns:
        df["gender"] = normalize_gender(df["gender"])

    # numeric cols
    for col in NUMERIC_COLS:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    return df

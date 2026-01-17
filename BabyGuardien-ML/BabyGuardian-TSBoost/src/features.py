import numpy as np
import pandas as pd

SIGNALS = ["temp", "spo2", "hr"]

def add_time_features_from_hour(df_hour: pd.DataFrame, ts_col="hour_ts") -> pd.DataFrame:
    hour = df_hour[ts_col].dt.hour + df_hour[ts_col].dt.minute / 60.0
    df_hour["hour_sin"] = np.sin(2*np.pi*hour/24.0)
    df_hour["hour_cos"] = np.cos(2*np.pi*hour/24.0)
    return df_hour

def make_hourly_features(df_1min: pd.DataFrame, freq="1h") -> pd.DataFrame:
    df = df_1min.copy()

    # timestamp -> datetime UTC
    df["timestamp"] = pd.to_datetime(df["timestamp"], utc=True, errors="coerce")
    df = df.dropna(subset=["timestamp"])

    # bucket heure (⚠️ "H" deprecated => utiliser "h")
    df["hour_ts"] = df["timestamp"].dt.floor(freq)

    # sexe -> sex_bin
    if "sex" in df.columns and "sex_bin" not in df.columns:
        df["sex_bin"] = df["sex"].map({"M": 1, "F": 0}).astype("Int64")

    # forcer numeric sur signaux
    for s in SIGNALS:
        if s in df.columns:
            df[s] = pd.to_numeric(df[s], errors="coerce")

    keys = ["subject_id", "hour_ts"]

    # colonnes statiques (si présentes)
    base_cols = [c for c in ["age", "sex_bin", "height_cm", "weight_kg"] if c in df.columns]

    agg_named = {}

    # stats 1h pour chaque signal
    stats = [("mean", "mean"), ("std", "std"), ("min", "min"), ("max", "max"), ("first", "first"), ("last", "last")]
    for s in SIGNALS:
        for stat_name, func in stats:
            agg_named[f"{s}_{stat_name}_1h"] = (s, func)

    # statiques = first
    for c in base_cols:
        agg_named[c] = (c, "first")

    # quality (ex: basé sur temp)
    agg_named["valid_count_1h"] = ("temp", lambda x: int(x.notna().sum()))
    agg_named["missing_ratio_1h"] = ("temp", lambda x: float(x.isna().mean()))

    out = df.groupby(keys).agg(**agg_named).reset_index()

    # slope = last - first
    for s in SIGNALS:
        out[f"{s}_slope_1h"] = out[f"{s}_last_1h"] - out[f"{s}_first_1h"]

    # time features
    out = add_time_features_from_hour(out, ts_col="hour_ts")

    return out.sort_values(["subject_id", "hour_ts"]).reset_index(drop=True)

def add_targets_next_hour(df_hour: pd.DataFrame, horizon_hours=1) -> pd.DataFrame:
    """
    Target = première valeur de l’heure suivante
    => shift(-1) sur *_first_1h
    """
    df = df_hour.copy()
    g = df.groupby("subject_id", group_keys=False)

    df["y_temp_1h"] = g["temp_first_1h"].shift(-horizon_hours)
    df["y_spo2_1h"] = g["spo2_first_1h"].shift(-horizon_hours)
    df["y_hr_1h"]   = g["hr_first_1h"].shift(-horizon_hours)

    return df

def get_feature_columns(df_hour: pd.DataFrame) -> list[str]:
    drop = {"subject_id", "hour_ts", "y_temp_1h", "y_spo2_1h", "y_hr_1h"}
    return [c for c in df_hour.columns if c not in drop]

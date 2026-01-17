import argparse
import joblib
import pandas as pd
from xgboost import XGBRegressor
from sklearn.metrics import mean_absolute_error

from src.features import make_hourly_features, add_targets_next_hour, get_feature_columns

def train_one(X_train, y_train, X_test, y_test):
    model = XGBRegressor(
        n_estimators=800,
        learning_rate=0.05,
        max_depth=6,
        subsample=0.8,
        colsample_bytree=0.8,
        reg_lambda=1.0,
        objective="reg:squarederror",
        random_state=42,
    )
    model.fit(X_train, y_train, eval_set=[(X_test, y_test)], verbose=False)
    pred = model.predict(X_test)
    return model, float(mean_absolute_error(y_test, pred))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", required=True, help="data 1min CSV")
    ap.add_argument("--outdir", default="models", help="output dir")
    args = ap.parse_args()

    df_1min = pd.read_csv(args.csv)
    df_hour = make_hourly_features(df_1min, freq="1h")
    df_hour = add_targets_next_hour(df_hour, horizon_hours=1)

    feat_cols = get_feature_columns(df_hour)
    targets = ["y_temp_1h","y_spo2_1h","y_hr_1h"]

    data = df_hour.dropna(subset=feat_cols + targets).copy()

    if len(data) == 0:
        raise RuntimeError(
            "Dataset vide après dropna. Cause la plus fréquente: pas assez d'heures par subject (>=2h requises)."
        )

    # split temporel par subject (80/20)
    data["rank"] = data.groupby("subject_id").cumcount()
    data["n"] = data.groupby("subject_id")["rank"].transform("max") + 1
    data["is_train"] = data["rank"] < (data["n"] * 0.8)

    train = data[data["is_train"]]
    test  = data[~data["is_train"]]

    X_train, X_test = train[feat_cols], test[feat_cols]

    m_temp, mae_temp = train_one(X_train, train["y_temp_1h"], X_test, test["y_temp_1h"])
    m_spo2, mae_spo2 = train_one(X_train, train["y_spo2_1h"], X_test, test["y_spo2_1h"])
    m_hr, mae_hr     = train_one(X_train, train["y_hr_1h"],   X_test, test["y_hr_1h"])

    print("MAE temp +1h =", mae_temp)
    print("MAE spo2 +1h =", mae_spo2)
    print("MAE hr   +1h =", mae_hr)

    joblib.dump((m_temp, feat_cols), f"{args.outdir}/xgb_temp_1h.joblib")
    joblib.dump((m_spo2, feat_cols), f"{args.outdir}/xgb_spo2_1h.joblib")
    joblib.dump((m_hr, feat_cols),   f"{args.outdir}/xgb_hr_1h.joblib")
    print("Saved models.")

if __name__ == "__main__":
    main()

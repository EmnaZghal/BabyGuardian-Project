import json
import os
import joblib
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

from .preprocessing import clean_dataframe
from config import (
    DATASET_PATH, ARTIFACTS_DIR,
    MODEL_PATH, SCALER_PATH, LE_PATH, META_PATH,
    DEFAULT_FEATURES, TARGET_COL
)

def train():
    df = pd.read_csv(DATASET_PATH, encoding="ascii")
    df = clean_dataframe(df)

    features = [f for f in DEFAULT_FEATURES if f in df.columns]
    if TARGET_COL not in df.columns:
        raise ValueError(f"Target column '{TARGET_COL}' not found in dataset.")

    # supprime lignes avec NaN sur features + target (MVP). Plus tard tu peux imputer.
    df_model = df.dropna(subset=features + [TARGET_COL]).copy()

    # LabelEncoder pour risk_level
    le = LabelEncoder()
    y = le.fit_transform(df_model[TARGET_COL])

    # scaler sur features
    scaler = StandardScaler()
    X = scaler.fit_transform(df_model[features])

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y if len(set(y)) > 1 else None
    )

    model = RandomForestClassifier(n_estimators=200, random_state=42)
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)

    os.makedirs(ARTIFACTS_DIR, exist_ok=True)
    joblib.dump(model, MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)
    joblib.dump(le, LE_PATH)

    meta = {
        "features": features,
        "target": TARGET_COL,
        "classes": list(le.classes_),
        "accuracy_test": float(acc),
        "model": "RandomForestClassifier(n_estimators=200)"
    }
    with open(META_PATH, "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2)

    print("✅ Training complete")
    print("Accuracy:", acc)
    print("Saved artifacts to:", ARTIFACTS_DIR)

if __name__ == "__main__":
    train()

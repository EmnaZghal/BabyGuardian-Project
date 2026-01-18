import os

ARTIFACTS_DIR = os.getenv("ARTIFACTS_DIR", "artifacts")
MODEL_PATH = os.path.join(ARTIFACTS_DIR, "model.joblib")
SCALER_PATH = os.path.join(ARTIFACTS_DIR, "scaler.joblib")
LE_PATH = os.path.join(ARTIFACTS_DIR, "label_encoder.joblib")
META_PATH = os.path.join(ARTIFACTS_DIR, "meta.json")

# Si tu veux entrainer depuis un chemin
DATASET_PATH = os.getenv("DATASET_PATH", "data/newborn_health_monitoring_with_risk.csv")

# Feature list par défaut (comme ton notebook)
DEFAULT_FEATURES = [
    "gestational_age_weeks",
    "gender",
    "age_days",
    "weight_kg",
    "temperature_c",
    "heart_rate_bpm",
    "oxygen_saturation"
]
TARGET_COL = "risk_level"

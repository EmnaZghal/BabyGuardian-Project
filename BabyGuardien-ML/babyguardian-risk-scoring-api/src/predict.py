import json
import joblib
import numpy as np

from config import MODEL_PATH, SCALER_PATH, LE_PATH, META_PATH

def load_artifacts():
    model = joblib.load(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)
    le = joblib.load(LE_PATH)
    with open(META_PATH, "r", encoding="utf-8") as f:
        meta = json.load(f)
    return model, scaler, le, meta

def compute_health_score(proba: np.ndarray, classes: list[str]) -> float:
    """
    Convertit proba multi-classe en score 0..100.
    Principe: on donne un "poids de risque" par classe (faible→0, moyen→0.5, élevé→1).
    Si tes classes sont différentes, adapte le mapping.
    """
    # mapping intelligent (MVP) selon noms fréquents
    risk_weight = {}
    for c in classes:
        cl = str(c).lower()
        if "high" in cl or "critical" in cl:
            risk_weight[c] = 1.0
        elif "medium" in cl or "moderate" in cl or "warn" in cl:
            risk_weight[c] = 0.5
        elif "low" in cl or "normal" in cl:
            risk_weight[c] = 0.0
        else:
            # si inconnu: le mettre au milieu
            risk_weight[c] = 0.5

    expected_risk = 0.0
    for p, c in zip(proba, classes):
        expected_risk += float(p) * risk_weight[c]

    score = 100.0 * (1.0 - expected_risk)
    return float(np.clip(score, 0, 100))

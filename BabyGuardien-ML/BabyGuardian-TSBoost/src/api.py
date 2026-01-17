from flask import Flask, request, jsonify
import pandas as pd
import joblib
from pathlib import Path

app = Flask(__name__)
MODEL_DIR = Path("models")

# load once
m_temp, FEATS = joblib.load(MODEL_DIR / "xgb_temp_1h.joblib")
m_spo2, _     = joblib.load(MODEL_DIR / "xgb_spo2_1h.joblib")
m_hr, _       = joblib.load(MODEL_DIR / "xgb_hr_1h.joblib")

# (optionnel) champs metadata que tu peux envoyer mais que le modèle ignore
META_KEYS = {"deviceId", "subject_id", "hour_ts"}

@app.get("/health")
def health():
    return jsonify({"ok": True})

@app.post("/predict")
def predict():
    payload = request.get_json(force=True) or {}

    # 1) On prend tout le JSON comme features, sauf metadata
    feats = {k: v for k, v in payload.items() if k not in META_KEYS}

    # 2) Vérifier features manquantes
    missing = [c for c in FEATS if c not in feats]
    if missing:
        return jsonify({"error": "missing features", "missing": missing}), 400

    # 3) Construire la ligne d'entrée dans le même ordre que FEATS
    X = pd.DataFrame([[feats[c] for c in FEATS]], columns=FEATS)

    # 4) Prédire
    pred = {
        "temp_1h": float(m_temp.predict(X)[0]),
        "spo2_1h": float(m_spo2.predict(X)[0]),
        "hr_1h":   float(m_hr.predict(X)[0]),
    }

    return jsonify({
        "ok": True,
        "deviceId": payload.get("deviceId"),
        "subject_id": payload.get("subject_id"),
        "hour_ts": payload.get("hour_ts"),
        "pred": pred
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

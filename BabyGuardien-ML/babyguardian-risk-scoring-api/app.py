from flask import Flask, request, jsonify
import numpy as np

from src.predict import load_artifacts, compute_health_score

app = Flask(__name__)

# Chargement au démarrage
MODEL, SCALER, LE, META = load_artifacts()
FEATURES = META["features"]
CLASSES = META["classes"]

@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": True, "classes": CLASSES}

@app.get("/metadata")
def metadata():
    return META

@app.post("/predict")
def predict():
    """
    Body JSON attendu:
    {
      "gestational_age_weeks": 38,
      "gender": 1,
      "age_days": 10,
      "weight_kg": 3.2,
      "temperature_c": 36.8,
      "heart_rate_bpm": 128,
      "oxygen_saturation": 97
    }
    """
    data = request.get_json(silent=True) or {}
    missing = [f for f in FEATURES if f not in data]
    if missing:
        return jsonify({"error": "missing_features", "missing": missing}), 400

    try:
        x = np.array([[float(data[f]) for f in FEATURES]], dtype=float)
    except Exception as e:
        return jsonify({"error": "invalid_input", "details": str(e)}), 400

    x_scaled = SCALER.transform(x)

    pred_idx = int(MODEL.predict(x_scaled)[0])
    pred_label = str(LE.inverse_transform([pred_idx])[0])

    # proba
    if hasattr(MODEL, "predict_proba"):
        proba = MODEL.predict_proba(x_scaled)[0].tolist()
        proba_by_class = {CLASSES[i]: float(proba[i]) for i in range(len(CLASSES))}
        score = compute_health_score(np.array(proba), CLASSES)
        confidence = float(max(proba))
    else:
        proba_by_class = None
        score = None
        confidence = None

    return jsonify({
        "risk_level": pred_label,
        "confidence": confidence,          # 0..1
        "health_score": score,             # 0..100
        "probabilities": proba_by_class,
        "features_used": FEATURES
    })

@app.post("/predict/batch")
def predict_batch():
    """
    Body:
    { "items": [ {...}, {...} ] }
    """
    body = request.get_json(silent=True) or {}
    items = body.get("items", [])
    if not isinstance(items, list) or len(items) == 0:
        return jsonify({"error": "items must be a non-empty list"}), 400

    results = []
    for i, data in enumerate(items):
        missing = [f for f in FEATURES if f not in data]
        if missing:
            results.append({"index": i, "error": "missing_features", "missing": missing})
            continue

        try:
            x = np.array([[float(data[f]) for f in FEATURES]], dtype=float)
            x_scaled = SCALER.transform(x)
            pred_idx = int(MODEL.predict(x_scaled)[0])
            pred_label = str(LE.inverse_transform([pred_idx])[0])

            if hasattr(MODEL, "predict_proba"):
                proba = MODEL.predict_proba(x_scaled)[0]
                score = compute_health_score(proba, CLASSES)
                confidence = float(np.max(proba))
                proba_by_class = {CLASSES[j]: float(proba[j]) for j in range(len(CLASSES))}
            else:
                score, confidence, proba_by_class = None, None, None

            results.append({
                "index": i,
                "risk_level": pred_label,
                "confidence": confidence,
                "health_score": score,
                "probabilities": proba_by_class
            })
        except Exception as e:
            results.append({"index": i, "error": "invalid_input", "details": str(e)})

    return jsonify({"results": results})

if __name__ == "__main__":
    # dev server
    app.run(host="0.0.0.0", port=5001, debug=True)

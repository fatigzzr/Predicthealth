import os
import joblib
import pandas as pd
from sklearn.metrics import confusion_matrix, roc_auc_score

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/diabetesv3/artifacts"
pipeline = joblib.load(os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))
scaler = pipeline["scaler"]
calibrated = pipeline["calibrated"]
FEATURES = pipeline["features"]

# --- Dataset setup ---
splits = {'test': 'test.parquet'}
df = pd.read_parquet("hf://datasets/Bena345/cdc-diabetes-health-indicators/" + splits["test"])

# --- Target encode ---
df["Diabetes_binary"] = df["Diabetes_binary"].map({"Diabetic": 1, "Non-Diabetic": 0})

def preprocess_patient(df_in):
    df = df_in.copy()

    used_feats = [
        "Sex",
        "Smoker",
        "Fruits",
        "Veggies",
        "HvyAlcoholConsump",
        "DiffWalk",
        "PhysActivity",
        "MentHlth",
        "PhysHlth"
    ]
    df = df[[c for c in used_feats if c in df.columns]].copy()

    # Fill missing and convert
    for col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)

    # Scale only numeric continuous columns without enforcing names
    cont_feats = ["PhysHlth", "MentHlth"]
    for c in cont_feats:
        if c not in df.columns:
            df[c] = 0

    df[cont_feats] = scaler.transform(df[cont_feats].values)

    # Ensure final feature alignment
    for c in FEATURES:
        if c not in df.columns:
            df[c] = 0
    df = df[FEATURES].copy()
    return df


# --- Prediction ---
X_test = preprocess_patient(df)
y_test = df["Diabetes_binary"].astype(int).values
y_prob = calibrated.predict_proba(X_test)[:, 1]

threshold = 0.2
y_pred = (y_prob >= threshold).astype(int)

# --- Metrics ---
correct = (y_pred == y_test).sum()
total = len(y_test)
accuracy = correct / total * 100
roc_auc = roc_auc_score(y_test, y_prob)
cm = confusion_matrix(y_test, y_pred)

print(f"Rows tested: {total}")
print(f"Correct predictions: {correct}")
print(f"Accuracy: {accuracy:.2f}%")
print(f"ROC-AUC: {roc_auc:.4f}")
print("Confusion matrix:")
print(cm)

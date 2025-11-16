import os
import joblib
import pandas as pd
from sklearn.metrics import confusion_matrix, roc_auc_score

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/Hypertension/artifacts"
pipeline = joblib.load(os.path.join(ARTIFACT_DIR, "hypertension_pipeline.joblib"))
scaler = pipeline["scaler"]
model = pipeline["model"]
calibrated = pipeline["calibrated"]
FEATURES = pipeline["feature_columns"]

# --- Load test CSV ---
df = pd.read_csv("Backend/AI/Hypertension/split/hypertension_test.csv")

# --- Target ---
df["Has_Hypertension"] = df["Has_Hypertension"].map({"Yes": 1, "No": 0})

NUMERIC = ["Age", "Salt_Intake", "Stress_Score", "Sleep_Duration", "BMI"]
CATEGORICAL = ["BP_History", "Medication", "Family_History", "Exercise_Level", "Smoking_Status"]

def preprocess_patient(df_in):
    df = df_in.copy()

    # numeric
    for c in NUMERIC:
        if c not in df:
            df[c] = 0
        df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0)
    df_num = pd.DataFrame(scaler.transform(df[NUMERIC]), columns=NUMERIC, index=df.index)

    # categorical
    for c in CATEGORICAL:
        if c not in df:
            df[c] = "Unknown"
        df[c] = df[c].astype(str)
    df_cat = pd.get_dummies(df[CATEGORICAL], drop_first=True)

    # align
    df_full = pd.concat([df_num, df_cat], axis=1)
    df_full = df_full.reindex(columns=FEATURES, fill_value=0)
    return df_full

# --- Prediction ---
X_test = preprocess_patient(df)
y_test = df["Has_Hypertension"].astype(int).values
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

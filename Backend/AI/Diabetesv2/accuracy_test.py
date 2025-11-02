# accuracy_test.py
import os
import joblib
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import confusion_matrix, roc_auc_score
from scipy import stats

# --- Load artifacts ---
ARTIFACT_DIR = "Backend/AI/diabetes2/artifacts"
pipeline = joblib.load(os.path.join(ARTIFACT_DIR, "diabetes_pipeline.joblib"))
scaler = pipeline["scaler"]
calibrated = pipeline["calibrated"]
FEATURES = pipeline["features"]

# --- Dataset setup ---
splits = {'train': 'train.parquet', 'test': 'test.parquet'}
df = pd.read_parquet("hf://datasets/Bena345/cdc-diabetes-health-indicators/" + splits["test"])

# --- Target encode ---
df["Diabetes_binary"] = df["Diabetes_binary"].map({"Diabetic": 1, "Non-Diabetic": 0})

# --- Preprocessing helper ---
def preprocess_patient(df_in):
    df = df_in.copy()
    age_order = [
        "18 to 24", "25 to 29", "30 to 34", "35 to 39", "40 to 44",
        "45 to 49", "50 to 54", "55 to 59", "60 to 64", "65 to 69",
        "70 to 74", "75 to 79", "80 or older"
    ]
    age_map = {v: i for i, v in enumerate(age_order)}
    gen_map = {"Poor": 1, "Fair": 2, "Good": 3, "Very good": 4, "Excellent": 5}
    num_for_scaler = ["BMI", "PhysHlth", "MentHlth", "Age_ord", "GenHlth_ord", "Education", "Income", "BMI_x_Age"]

    # Age ordinal
    if "Age" in df.columns:
        df["Age_ord"] = df["Age"].map(age_map).fillna(pd.Series(df["Age"].factorize()[0], index=df.index))
    # GenHlth ordinal
    if "GenHlth" in df.columns:
        df["GenHlth_ord"] = df["GenHlth"].map(gen_map).fillna(pd.to_numeric(df["GenHlth"], errors="coerce")).fillna(3)
    # Education & Income
    for col in ["Education", "Income"]:
        if col in df.columns and df[col].dtype == object:
            df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0).astype(int)
    # Binary columns
    bin_feats = [
        "HighBP", "HighChol", "CholCheck", "Smoker", "Stroke", "HeartDiseaseorAttack",
        "PhysActivity", "Fruits", "Veggies", "HvyAlcoholConsump", "AnyHealthcare",
        "NoDocbcCost", "DiffWalk", "Sex"
    ]
    for col in bin_feats:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0).astype(int)
    # Derived features
    if "BMI" in df.columns and "Age_ord" in df.columns:
        df["BMI_x_Age"] = df["BMI"] * df["Age_ord"]
    # Ensure all features
    for c in FEATURES:
        if c not in df.columns:
            df[c] = 0
    # Reorder and scale
    df = df[FEATURES].copy()
    df[num_for_scaler] = scaler.transform(df[num_for_scaler])
    return df

# --- Prediction ---
# X_test = preprocess_patient(df)
# y_test = df["Diabetes_binary"].astype(int).values
# y_pred = calibrated.predict(X_test)
# y_prob = calibrated.predict_proba(X_test)[:, 1]

# --- Prediction with custom threshold ---
X_test = preprocess_patient(df)
y_test = df["Diabetes_binary"].astype(int).values
y_prob = calibrated.predict_proba(X_test)[:, 1]

threshold = 0.2
y_pred = (y_prob >= threshold).astype(int)


# --- Accuracy ---
correct = (y_pred == y_test).sum()
total = len(y_test)
accuracy = correct / total * 100

# --- ROC-AUC ---
roc_auc = roc_auc_score(y_test, y_prob)

# --- Confusion matrix ---
cm = confusion_matrix(y_test, y_pred)

print(f"Rows tested: {total}")
print(f"Correct predictions: {correct}")
print(f"Accuracy: {accuracy:.2f}%")
print(f"ROC-AUC: {roc_auc:.4f}")
print("Confusion matrix:")
print(cm)

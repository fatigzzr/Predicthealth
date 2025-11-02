# app_diabetes.py
from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import pandas as pd
import os

app = FastAPI(title="Predicción de Diabetes")

# === Cargar modelo, scaler y features ===
models_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'ml_models'))
model = joblib.load(os.path.join(models_dir, "modelo_diabetes.pkl"))
scaler = joblib.load(os.path.join(models_dir, "scaler_diabetes.pkl"))
features = joblib.load(os.path.join(models_dir, "features_diabetes.pkl"))

# === Crear un modelo Pydantic dinámicamente con esas features ===
from typing import Optional

class DiabetesInput(BaseModel):
    sexo: str
    edad: float
    colesterol_alto: int
    presion_arterial_alta: int
    bmi: float
    problemas_corazon: int
    actividad_fisica: int
    fumador: int
    dificultad_caminar: int
    salud_mental: float
    salud_fisica: float


@app.post("/predict")
async def predict_diabetes(entradas: list[DiabetesInput]):
    # Convertir lista de objetos Pydantic → DataFrame
    df = pd.DataFrame([e.dict() for e in entradas])

    # Reordenar columnas y asegurar compatibilidad con el modelo
    df = df.reindex(columns=features)

    # Preprocesar 'sexo'
    df['sexo'] = df['sexo'].map({'M': 1, 'F': 0})

    # Escalar
    X_scaled = scaler.transform(df)

    # Predicciones
    predicciones = model.predict(X_scaled)
    probabilidades = model.predict_proba(X_scaled)[:, 1]

    # Respuesta
    resultados = []
    for i in range(len(predicciones)):
        resultados.append({
            "prediccion": int(predicciones[i]),
            "probabilidad": float(probabilidades[i])
        })

    return {"resultados": resultados}

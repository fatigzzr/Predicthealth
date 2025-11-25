import pandas as pd
import psycopg2
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score
from xgboost import XGBClassifier
import joblib
import os

# ======================================================
# 1️⃣ Conexión a la base de datos y carga de datos
# ======================================================
def cargar_datos_desde_bd():
    """
    Carga los datos de entrenamiento desde la base de datos PostgreSQL.
    """
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="predicthealth",
            user="predicthealth_user",
            password="666",
            port="5432"
        )

        query = """
        SELECT 
            p.sexo,
            EXTRACT(YEAR FROM AGE(p.fecha_nacimiento)) as edad,
            
            CASE WHEN EXISTS (
                SELECT 1 FROM Historial_Medico hm 
                JOIN Tipo_Medicion tm ON hm.id_medicion = tm.id_medicion 
                WHERE hm.id_usuario = u.id_usuario 
                AND tm.nombre = 'colesterol alto'
                AND hm.valor = 'True'
            ) THEN 1 ELSE 0 END as colesterol_alto,
            
            CASE WHEN EXISTS (
                SELECT 1 FROM Historial_Medico hm 
                JOIN Tipo_Medicion tm ON hm.id_medicion = tm.id_medicion 
                WHERE hm.id_usuario = u.id_usuario 
                AND tm.nombre = 'presión arterial'
                AND hm.valor = 'Alta'
            ) THEN 1 ELSE 0 END as presion_arterial_alta,
            
            CAST(
                COALESCE(
                    (SELECT hm.valor FROM Historial_Medico hm 
                     JOIN Tipo_Medicion tm ON hm.id_medicion = tm.id_medicion 
                     WHERE hm.id_usuario = u.id_usuario 
                     AND tm.nombre = 'bmi'
                     AND hm.valor ~ '^[0-9]+\\.?[0-9]*$'
                     LIMIT 1),
                    '25'
                ) AS NUMERIC
            ) as bmi,
            
            CASE WHEN EXISTS (
                SELECT 1 FROM Historial_Medico hm 
                JOIN Tipo_Medicion tm ON hm.id_medicion = tm.id_medicion 
                WHERE hm.id_usuario = u.id_usuario 
                AND tm.nombre = 'problemas_corazon'
                AND hm.valor = 'True'
            ) THEN 1 ELSE 0 END as problemas_corazon,
            
            CASE WHEN EXISTS (
                SELECT 1 FROM Respuesta_Estilo_Vida rv
                JOIN Pregunta p2 ON rv.id_pregunta = p2.id_pregunta
                WHERE rv.id_usuario = u.id_usuario 
                AND p2.pregunta LIKE '%actividad física%'
                AND rv.valor = 'True'
            ) THEN 1 ELSE 0 END as actividad_fisica,
            
            CASE WHEN EXISTS (
                SELECT 1 FROM Respuesta_Estilo_Vida rv
                JOIN Pregunta p2 ON rv.id_pregunta = p2.id_pregunta
                WHERE rv.id_usuario = u.id_usuario 
                AND p2.pregunta LIKE '%Fuma%'
                AND rv.valor = 'True'
            ) THEN 1 ELSE 0 END as fumador,
            
            CASE WHEN EXISTS (
                SELECT 1 FROM Respuesta_Estilo_Vida rv
                JOIN Pregunta p2 ON rv.id_pregunta = p2.id_pregunta
                WHERE rv.id_usuario = u.id_usuario 
                AND p2.pregunta LIKE '%dificultades para caminar%'
                AND rv.valor = 'True'
            ) THEN 1 ELSE 0 END as dificultad_caminar,
            
            COALESCE(
                (SELECT CAST(rv.valor AS NUMERIC) 
                 FROM Respuesta_Estilo_Vida rv
                 JOIN Pregunta p2 ON rv.id_pregunta = p2.id_pregunta
                 WHERE rv.id_usuario = u.id_usuario 
                 AND p2.pregunta LIKE '%salud mental%'
                 AND rv.valor ~ '^[0-9]+\\.?[0-9]*$'
                 LIMIT 1), 0
            ) as salud_mental,
            
            COALESCE(
                (SELECT CAST(rv.valor AS NUMERIC) 
                 FROM Respuesta_Estilo_Vida rv
                 JOIN Pregunta p2 ON rv.id_pregunta = p2.id_pregunta
                 WHERE rv.id_usuario = u.id_usuario 
                 AND p2.pregunta LIKE '%salud física%'
                 AND rv.valor ~ '^[0-9]+\\.?[0-9]*$'
                 LIMIT 1), 0
            ) as salud_fisica,
            
            CASE WHEN EXISTS (
                SELECT 1 FROM Prediccion p2
                JOIN Enfermedad e ON p2.id_enfermedad = e.id_enfermedad
                WHERE p2.id_usuario = u.id_usuario 
                AND e.nombre = 'Diabetes'
                AND p2.prediccion = True
            ) OR EXISTS (
                SELECT 1 FROM Historial_Enfermedad he
                JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
                JOIN Historial_Medico hm ON he.id_historial = hm.id_historial
                WHERE hm.id_usuario = u.id_usuario 
                AND e.nombre = 'Diabetes'
            ) THEN 1 ELSE 0 END as diabetes
            
        FROM Usuario u
        JOIN Paciente p ON u.id_usuario = p.id_usuario
        WHERE u.id_rol = 1
        AND p.fecha_nacimiento IS NOT NULL
        """

        df = pd.read_sql_query(query, conn)
        conn.close()

        print(f"✅ Datos cargados desde BD: {df.shape[0]} registros, {df.shape[1]} columnas")
        return df

    except Exception as e:
        print(f"❌ Error al cargar datos desde BD: {e}")
        return None


# ======================================================
# 2️⃣ Preprocesamiento
# ======================================================
def preprocesar_datos(df):
    features = [
        'sexo', 'edad', 'colesterol_alto', 'presion_arterial_alta',
        'bmi', 'problemas_corazon', 'actividad_fisica', 'fumador',
        'dificultad_caminar', 'salud_mental', 'salud_fisica'
    ]
    target = 'diabetes'

    df['sexo'] = df['sexo'].map({'M': 1, 'F': 0})
    df = df.fillna({
        'sexo': 0,
        'edad': df['edad'].median(),
        'bmi': df['bmi'].median(),
        'salud_mental': 0,
        'salud_fisica': 0
    })

    df_clean = df.dropna(subset=[target])

    print(f"📊 Distribución de diabetes:\n{df_clean[target].value_counts(normalize=True)}")
    return df_clean[features], df_clean[target], features


# ======================================================
# 3️⃣ Entrenamiento con XGBoost
# ======================================================
def entrenar_modelo_xgb(X, y, features):
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    X_train, X_test, y_train, y_test = train_test_split(
        X_scaled, y, test_size=0.2, random_state=42, stratify=y
    )

    model = XGBClassifier(
        n_estimators=400,
        max_depth=6,
        learning_rate=0.05,
        subsample=0.8,
        colsample_bytree=0.8,
        eval_metric='logloss',
        scale_pos_weight=3.0,
        random_state=42,
        use_label_encoder=False
    )

    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    y_pred_proba = model.predict_proba(X_test)[:, 1]

    print("\n📊 MATRIZ DE CONFUSIÓN:")
    print(confusion_matrix(y_test, y_pred))
    print("\n📋 REPORTE DE CLASIFICACIÓN:")
    print(classification_report(y_test, y_pred))
    print("\n📈 ROC-AUC:", roc_auc_score(y_test, y_pred_proba))

    importance = pd.DataFrame({
        'feature': features,
        'importance': model.feature_importances_
    }).sort_values('importance', ascending=False)

    print("\n⭐ IMPORTANCIA DE VARIABLES:")
    print(importance)

    return model, scaler, importance


# ======================================================
# 4️⃣ Guardado del modelo
# ======================================================
def _get_models_dir():
    services_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    models_dir = os.path.join(services_dir, 'ml_models')
    os.makedirs(models_dir, exist_ok=True)
    return models_dir


def guardar_modelo(model, scaler, features, importance):
    models_dir = _get_models_dir()
    joblib.dump(model, os.path.join(models_dir, "modelo_diabetes.pkl"))
    joblib.dump(scaler, os.path.join(models_dir, "scaler_diabetes.pkl"))
    joblib.dump(features, os.path.join(models_dir, "features_diabetes.pkl"))
    joblib.dump(importance, os.path.join(models_dir, "feature_importance.pkl"))
    print("✅ Modelo XGBoost guardado exitosamente en ml_models/")


# ======================================================
# 5️⃣ Predicción con nuevos datos
# ======================================================
def predecir_diabetes(nuevos_datos):
    try:
        models_dir = _get_models_dir()
        model = joblib.load(os.path.join(models_dir, "modelo_diabetes.pkl"))
        scaler = joblib.load(os.path.join(models_dir, "scaler_diabetes.pkl"))
        features = joblib.load(os.path.join(models_dir, "features_diabetes.pkl"))

        df = pd.DataFrame(nuevos_datos)
        df['sexo'] = df['sexo'].map({'M': 1, 'F': 0})

        X_scaled = scaler.transform(df[features])
        predicciones = model.predict(X_scaled)
        probabilidades = model.predict_proba(X_scaled)[:, 1]

        resultados = []
        for pred, prob in zip(predicciones, probabilidades):
            resultados.append({
                "prediccion": int(pred),
                "probabilidad": float(round(prob, 3))
            })
        return resultados

    except Exception as e:
        print(f"❌ Error al predecir: {e}")
        return None


# ======================================================
# 6️⃣ Ejecución principal
# ======================================================
def main():
    print("🚀 Entrenando modelo de diabetes (XGBoost)...")
    df = cargar_datos_desde_bd()
    if df is None:
        print("❌ No se pudieron cargar los datos.")
        return

    X, y, features = preprocesar_datos(df)
    model, scaler, importance = entrenar_modelo_xgb(X, y, features)
    guardar_modelo(model, scaler, features, importance)
    print("✅ Entrenamiento completo.")


if __name__ == "__main__":
    main()
"""
Script para cargar y explorar datos de Kaggle - Hypertension Risk Prediction Dataset
"""

# Install dependencies as needed:
# pip install kagglehub[pandas-datasets]
import kagglehub
from kagglehub import KaggleDatasetAdapter
import pandas as pd
import random
from werkzeug.security import generate_password_hash

def generate_random_email():
    """Generar email aleatorio"""
    return f"user_{random.randint(1000, 9999)}@hypertension-risk.com"

def hash_password(password):
    """Cifrar contraseña usando Werkzeug PBKDF2"""
    # Usar PBKDF2 con salt automático y 100,000 iteraciones por defecto
    return generate_password_hash(password, method='pbkdf2:sha256')

def generate_sql_commands(df):
    """Generar comandos SQL de inserción para el dataset de hipertensión"""
    
    sql_commands = []
    
    # Agregar comentario
    sql_commands.append("-- Comandos SQL generados automáticamente del dataset Hypertension Risk Prediction")
    sql_commands.append("-- Copia estos comandos y pégalos al final de tu init.sql")
    sql_commands.append("")
    
    # Limitar a 1000 registros para un archivo SQL manejable
    sample_size = min(1000, len(df))
    df_sample = df.head(sample_size)
    
    print(f"Generando comandos SQL para {sample_size} registros...")
    
    # Insertar medicamentos
    sql_commands.append("-- Insertar medicamentos")
    medications = [
        "Ninguna",
        "Otro", 
        "Beta Blocker",
        "Diurético",
        "ACE Inhibitor"
    ]
    
    for medication in medications:
        sql_commands.append(f"INSERT INTO Medicamento (nombre) VALUES ('{medication}');")
    
    sql_commands.append("")
    
    # Ahora procesar cada registro del dataset
    sql_commands.append("-- Insertar datos de usuarios del dataset Hypertension")
    for i in range(sample_size):
        row = df_sample.iloc[i]
        
        # Generar email único para este registro
        email = f"user_{i+1}@hypertension-risk.com"
        
        # 1. Insertar usuario con contraseña hasheada
        sql_commands.append(f"-- Usuario {i+1}")
        # Generar contraseña hasheada para este usuario
        plain_password = "password123"
        hashed_password = hash_password(plain_password)
        sql_commands.append(f"INSERT INTO Usuario (email, contraseña) VALUES ('{email}', '{hashed_password}');")
        
        # 2. Insertar datos personales
        age = row.get('Age', None)
        sex = row.get('Sex', None)
        
        # Convertir age a entero si es string
        if age is not None:
            try:
                age = int(age)
                # Generar fecha de nacimiento aproximada basada en la edad
                birth_year = 2024 - age
                birth_date = f"{birth_year}-01-01"
            except (ValueError, TypeError):
                age = None
                birth_date = "NULL"
        else:
            birth_date = "NULL"
        
        # Mapear sexo (asumiendo 1=Masculino, 0=Femenino)
        gender_boolean = sex == 1 if sex is not None else None
        
        first_name = f"Usuario_{i+1}"
        last_name = f"Hypertension_{i+1}"
        
        # Manejar valores NULL correctamente en SQL
        birth_date_sql = f"'{birth_date}'" if birth_date != "NULL" else "NULL"
        age_sql = str(age) if age is not None else "NULL"
        sex_sql = str(gender_boolean) if gender_boolean is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Datos_Personales (nombre, apellido, fecha_nacimiento, sexo, id_usuario)
VALUES ('{first_name}', '{last_name}', {birth_date_sql}, {sex_sql}, (SELECT id_usuario FROM Usuario WHERE email = '{email}'));""")
        
        # 3. Insertar historial médico
        bmi = row.get('BMI', None)
        smoking_status = row.get('Smoking_Status', None)
        bp_history = row.get('BP_History', None)
        has_hypertension = row.get('Has_Hypertension', None)
        
        # Mapear hipertensión basada en Has_Hypertension
        # Yes = true, No = false
        hipertension = has_hypertension == 'Yes' if has_hypertension is not None else None
        
        # Mapear presión arterial basada en BP_History
        presion_arterial = bp_history if bp_history is not None else None
        
        # Mapear tabaco basado en Smoking_Status
        tabaco = smoking_status == 'Smoker' if smoking_status is not None else None
        
        # Convertir valores a SQL apropiado
        tabaco_sql = str(bool(tabaco)) if tabaco is not None else "NULL"
        bmi_sql = str(bmi) if bmi is not None else "NULL"
        presion_arterial_sql = f"'{presion_arterial}'" if presion_arterial is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Historial_Medico (bmi, presion_arterial, id_usuario)
SELECT {bmi_sql}, {presion_arterial_sql}, id_usuario 
FROM Usuario 
WHERE email = '{email}';""")
        
        # Insertar relación con hipertensión si aplica
        if hipertension:
            sql_commands.append(f"""
INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = '{email}';""")
        
        # 4. Insertar estilo de vida
        salt_intake = row.get('Salt_Intake', None)  # -> consumo_sal
        stress_score = row.get('Stress_Score', None)  # -> nivel_estres
        sleep_duration = row.get('Sleep_Duration', None)  # -> horas_dormir
        exercise_level = row.get('Exercise_Level', None)  # -> nivel_actividad_fisica
        
        # Mapear nivel de actividad física
        nivel_actividad_map = {
            'Low': 'Bajo',
            'Moderate': 'Moderado', 
            'High': 'Alto'
        }
        nivel_actividad = nivel_actividad_map.get(exercise_level, None)
        
        # Convertir valores de estilo de vida a SQL apropiado
        salt_intake_sql = str(salt_intake) if salt_intake is not None else "NULL"
        stress_score_sql = str(stress_score) if stress_score is not None else "NULL"
        sleep_duration_sql = str(sleep_duration) if sleep_duration is not None else "NULL"
        nivel_actividad_sql = f"'{nivel_actividad}'" if nivel_actividad is not None else "NULL"
        tabaco_sql = str(bool(tabaco)) if tabaco is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Estilo_Vida (consumo_sal, nivel_estres, horas_dormir, nivel_actividad_fisica, tabaco, id_usuario)
SELECT {salt_intake_sql}, {stress_score_sql}, {sleep_duration_sql}, {nivel_actividad_sql}, {tabaco_sql}, id_usuario 
FROM Usuario 
WHERE email = '{email}';""")
        
        # 5. Insertar medicación
        medication = row.get('Medication', None)
        
        # Mapear medicación
        medication_map = {
            'None': 'Ninguna',
            'Other': 'Otro',
            'Beta Blocker': 'Beta Blocker',
            'Diuretic': 'Diurético',
            'ACE Inhibitor': 'ACE Inhibitor'
        }
        medication_name = medication_map.get(medication, 'Ninguna')
        
        sql_commands.append(f"""
INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = '{medication_name}')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = '{email}';""")
        
        # 6. Insertar predicción basada en los datos
        prediccion_boolean = has_hypertension == 'Yes' if has_hypertension is not None else None
        
        prediccion_sql = str(prediccion_boolean) if prediccion_boolean is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Prediccion (prediccion, fecha, id_enfermedad, id_usuario)
VALUES ({prediccion_sql}, CURRENT_TIMESTAMP, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), (SELECT id_usuario FROM Usuario WHERE email = '{email}'));""")
        
        sql_commands.append("")
    
    # Escribir a archivo
    with open('hypertension_sql_commands.txt', 'w', encoding='utf-8') as f:
        for command in sql_commands:
            f.write(command + '\n')
    
    print(f"✅ Comandos SQL generados en 'hypertension_sql_commands.txt'")
    print(f"✅ Total de comandos: {len(sql_commands)}")
    print("✅ Copia el contenido de 'hypertension_sql_commands.txt' y pégalo al final de tu init.sql")

def explore_dataset():
    """Explorar el dataset de hipertensión"""
    print("=== EXPLORANDO DATASET DE HIPERTENSIÓN ===")
    
    # Cargar el dataset desde el archivo CSV descargado
    try:
        print("Cargando dataset desde hypertension_dataset.csv...")
        df = pd.read_csv('hypertension_dataset.csv')
        print("✅ Dataset cargado exitosamente desde CSV")
    except Exception as e:
        print(f"❌ Error al cargar el CSV: {e}")
        raise
    
    print("✅ Dataset cargado exitosamente")
    print(f"📊 Forma del dataset: {df.shape}")
    print(f"📋 Columnas: {list(df.columns)}")
    print(f"🔍 Tipos de datos:")
    print(df.dtypes)
    print("\n📈 Primeras 5 filas:")
    print(df.head())
    print("\n📊 Información del dataset:")
    print(df.info())
    print("\n📈 Estadísticas descriptivas:")
    print(df.describe())
    
    # Verificar valores nulos
    print("\n🔍 Valores nulos por columna:")
    null_counts = df.isnull().sum()
    print(null_counts[null_counts > 0])
    
    return df

def main():
    print("Cargando dataset de Hypertension Risk Prediction...")
    
    try:
        # Explorar el dataset
        df = explore_dataset()
        
        # Guardar el dataset
        print("\n=== GUARDANDO DATOS ===")
        df.to_csv('hypertension_dataset.csv', index=False)
        print("✅ Dataset guardado en 'hypertension_dataset.csv'")
        
        # Generar comandos SQL de inserción
        print("\n=== GENERANDO COMANDOS SQL ===")
        generate_sql_commands(df)
        
        print("\n✅ Procesamiento completado exitosamente")
        print("Los datos están disponibles en:")
        print("- hypertension_dataset.csv: dataset completo")
        print("- hypertension_sql_commands.txt: comandos SQL para insertar datos")
        
    except Exception as e:
        print(f"❌ Error al cargar el dataset: {e}")
        print("Asegúrate de tener kagglehub instalado: pip install kagglehub[pandas-datasets]")

if __name__ == "__main__":
    main()

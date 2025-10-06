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
    sql_commands.append("-- =====================================")
    sql_commands.append("-- COMANDOS SQL DATASET HIPERTENSIÓN")
    sql_commands.append("-- Compatible con init_new.sql")
    sql_commands.append("-- =====================================")
    sql_commands.append("")
    
    # Limitar a 100 registros para un archivo SQL manejable
    sample_size = min(100, len(df))
    df_sample = df.head(sample_size)
    
    print(f"Generando comandos SQL para {sample_size} registros...")
    
    # Insertar medicamentos (solo si no existen)
    sql_commands.append("-- Insertar medicamentos para hipertensión")
    medications = [
        "Ninguna",
        "Otro", 
        "Beta Blocker",
        "Diurético",
        "ACE Inhibitor"
    ]
    
    for medication in medications:
        sql_commands.append(f"INSERT INTO Medicamento (nombre) VALUES ('{medication}') ON CONFLICT (nombre) DO NOTHING;")
    
    sql_commands.append("")
    
    # Ahora procesar cada registro del dataset
    sql_commands.append("-- Insertar datos de usuarios del dataset Hypertension")
    for i in range(sample_size):
        row = df_sample.iloc[i]
        
        # Generar email único para este registro
        email = f"user_{i+1}@hypertension-risk.com"
        
        # 1. Insertar usuario con contraseña hasheada (nueva estructura)
        sql_commands.append(f"-- Usuario {i+1}")
        # Generar contraseña hasheada para este usuario
        plain_password = "password123"
        hashed_password = hash_password(plain_password)
        sql_commands.append(f"INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, '{email}', '{hashed_password}');")
        
        # 2. Insertar datos personales en tabla Paciente (nueva estructura)
        age = row.get('Age', None)
        sex = row.get('Sex', None)
        
        # Convertir age a entero si es string
        birth_date = None
        if age is not None:
            try:
                age = int(age)
                birth_year = 2024 - age
                birth_date = f"{birth_year}-01-01"
            except (ValueError, TypeError):
                age = None
                birth_date = None
        
        # Si no tenemos edad, generar una fecha de nacimiento por defecto (edad promedio 45 años)
        if birth_date is None:
            birth_year = 2024 - 45  # Edad promedio
            birth_date = f"{birth_year}-01-01"
        
        first_name = f"Usuario_{i+1}"
        last_name = f"Hypertension_{i+1}"
        
        # Mapear sexo a formato correcto (M/F)
        sexo_sql = "'M'" if sex == 1 else "'F'" if sex == 0 else "NULL"
        birth_date_sql = f"'{birth_date}'"  # Ahora siempre tenemos una fecha válida
        
        sql_commands.append(f"""
INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, '{first_name}', '{last_name}', {birth_date_sql}, {sexo_sql}
FROM Usuario 
WHERE email = '{email}';""")
        
        # 3. Insertar historial médico (nueva estructura)
        bmi = row.get('BMI', None)
        smoking_status = row.get('Smoking_Status', None)
        bp_history = row.get('BP_History', None)
        has_hypertension = row.get('Has_Hypertension', None)
        
        # Insertar BMI como medición
        if bmi is not None:
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '{bmi}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # Insertar presión arterial si está disponible
        if bp_history is not None:
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, '{bp_history}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # Insertar relación con hipertensión si aplica
        if has_hypertension == 'Yes':
            sql_commands.append(f"""
INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = '{email}';""")
        
        # 4. Insertar estilo de vida (nueva estructura con Respuesta_Estilo_Vida)
        salt_intake = row.get('Salt_Intake', None)
        stress_score = row.get('Stress_Score', None)
        sleep_duration = row.get('Sleep_Duration', None)
        exercise_level = row.get('Exercise_Level', None)
        smoking_status = row.get('Smoking_Status', None)
        
        # Insertar consumo de sal (pregunta 3)
        if salt_intake is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '{salt_intake}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # Insertar nivel de estrés (pregunta 8)
        if stress_score is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '{stress_score}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # Insertar horas de sueño (pregunta 7)
        if sleep_duration is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '{sleep_duration}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # Insertar nivel de actividad física (pregunta 10)
        if exercise_level is not None:
            nivel_actividad_map = {
                'Low': '1',
                'Moderate': '2', 
                'High': '3'
            }
            nivel_actividad = nivel_actividad_map.get(exercise_level, '1')
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '{nivel_actividad}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # Insertar estado de fumador (pregunta 4)
        if smoking_status is not None:
            fuma = 'TRUE' if smoking_status == 'Smoker' else 'FALSE'
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, '{fuma}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # 5. Insertar medicación (nueva estructura)
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
        
        # Solo insertar si no es "Ninguna"
        if medication_name != 'Ninguna':
            sql_commands.append(f"""
INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = '{medication_name}')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = '{email}';""")
        
        # 6. Insertar predicción basada en los datos (nueva estructura)
        prediccion_boolean = has_hypertension == 'Yes' if has_hypertension is not None else False
        probabilidad = 0.8 if prediccion_boolean else 0.2
        
        sql_commands.append(f"""
INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = '{email}'), 
       {prediccion_boolean}, 
       CURRENT_TIMESTAMP, 
       {probabilidad};""")
        
        sql_commands.append("")
    
    # Escribir a archivo
    with open('hypertension_sql_commands.sql', 'w', encoding='utf-8') as f:
        for command in sql_commands:
            f.write(command + '\n')
    
    print(f"✅ Comandos SQL generados en 'hypertension_sql_commands.sql'")
    print(f"✅ Total de comandos: {len(sql_commands)}")
    print("✅ Compatible con init_new.sql")
    print("✅ Ejecuta este archivo después de insert_data.sql")

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
        print("- hypertension_sql_commands.sql: comandos SQL para insertar datos")
        
    except Exception as e:
        print(f"❌ Error al cargar el dataset: {e}")
        print("Asegúrate de tener kagglehub instalado: pip install kagglehub[pandas-datasets]")

if __name__ == "__main__":
    main()

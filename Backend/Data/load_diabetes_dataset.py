"""
Script simple para cargar y explorar datos de Hugging Face
"""

from datasets import load_dataset
import pandas as pd
import random
import string
from werkzeug.security import generate_password_hash

def generate_random_email():
    """Generar email aleatorio"""
    return f"user_{random.randint(1000, 9999)}@cdc-diabetes.com"

def hash_password(password):
    """Cifrar contraseña usando Werkzeug PBKDF2"""
    # Usar PBKDF2 con salt automático y 100,000 iteraciones por defecto
    return generate_password_hash(password, method='pbkdf2:sha256')

def generate_sql_commands(df_combined):
    """Generar comandos SQL de inserción para la nueva estructura init_new.sql"""
    
    sql_commands = []
    
    # Agregar comentario
    sql_commands.append("-- Comandos SQL generados automáticamente del dataset CDC Diabetes")
    sql_commands.append("-- Compatible con init_new.sql")
    sql_commands.append("")
    
    # Limitar a 100 registros para un archivo SQL manejable
    sample_size = min(100, len(df_combined))
    df_sample = df_combined.head(sample_size)
    
    print(f"Generando comandos SQL para {sample_size} registros...")
    
    # Ahora procesar cada registro del dataset
    sql_commands.append("-- Insertar datos de usuarios del dataset CDC")
    for i in range(sample_size):
        row = df_sample.iloc[i]
        
        # Generar email único para este registro
        email = f"user_{i+1}@cdc-diabetes.com"
        
        # 1. Insertar usuario con contraseña hasheada (nueva estructura)
        sql_commands.append(f"-- Usuario {i+1}")
        plain_password = "password123"
        hashed_password = hash_password(plain_password)
        sql_commands.append(f"INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, '{email}', '{hashed_password}');")
        
        # 2. Insertar datos personales en tabla Paciente (nueva estructura)
        sex = row.get('Sex', None)
        age = row.get('Age', None)
        
        # Convertir age a entero si es string o rango
        birth_date = None
        if age is not None:
            try:
                # Si es un número directo
                if isinstance(age, (int, float)):
                    age = int(age)
                    birth_year = 2024 - age
                    birth_date = f"{birth_year}-01-01"
                # Si es un rango de texto (ej: "65 to 69", "80 or older")
                elif isinstance(age, str):
                    age_str = age.lower().strip()
                    if "80 or older" in age_str:
                        age = 85  # Usar 85 como edad representativa
                    elif "to" in age_str:
                        # Extraer el primer número del rango
                        age = int(age_str.split()[0])
                    else:
                        # Intentar convertir directamente
                        age = int(age_str)
                    
                    birth_year = 2024 - age
                    birth_date = f"{birth_year}-01-01"
            except (ValueError, TypeError, AttributeError):
                age = None
                birth_date = None
        
        # Si no tenemos edad, generar una fecha de nacimiento por defecto (edad promedio 45 años)
        if birth_date is None:
            birth_year = 2024 - 45  # Edad promedio
            birth_date = f"{birth_year}-01-01"
        
        first_name = f"Usuario_{i+1}"
        last_name = f"CDC_{i+1}"
        
        # Mapear sexo a formato correcto (M/F)
        sexo_sql = "'M'" if sex == 1 else "'F'" if sex == 0 else "NULL"
        birth_date_sql = f"'{birth_date}'"  # Ahora siempre tenemos una fecha válida
        
        sql_commands.append(f"""
INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, '{first_name}', '{last_name}', {birth_date_sql}, {sexo_sql}
FROM Usuario 
WHERE email = '{email}';""")
        
        # 3. Insertar historial médico usando Tipo_Medicion (nueva estructura)
        diabetes = row.get('Diabetes_binary', None)
        high_bp = row.get('HighBP', None)
        high_chol = row.get('HighChol', None)
        chol_check = row.get('CholCheck', None)
        bmi = row.get('BMI', None)
        stroke = row.get('Stroke', None)
        heart_disease = row.get('HeartDiseaseorAttack', None)
        gen_hlth = row.get('GenHlth', None)
        
        # Insertar mediciones individuales usando Historial_Medico
        if chol_check is not None:
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, '{bool(chol_check)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if high_chol is not None:
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, '{bool(high_chol)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if bmi is not None:
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '{bmi}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if high_bp is not None:
            presion_arterial = "Alta" if high_bp == 1 else "Normal"
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, '{presion_arterial}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if stroke is not None:
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, '{bool(stroke)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if heart_disease is not None:
            sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, '{bool(heart_disease)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if gen_hlth is not None:
            salud_general_map = {1: "Excelente", 2: "Muy bueno", 3: "Bueno", 4: "Regular", 5: "Malo"}
            salud_general = salud_general_map.get(gen_hlth, None)
            if salud_general:
                sql_commands.append(f"""
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 7, '{salud_general}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # Insertar relación con diabetes si aplica
        diabetes_binary = row.get('Diabetes_binary', None)
        if diabetes_binary == 'Diabetic':
            sql_commands.append(f"""
INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = '{email}';""")
        
        # 4. Insertar estilo de vida usando Respuesta_Estilo_Vida (nueva estructura)
        fruits = row.get('Fruits', None)
        vegetables = row.get('Veggies', None)
        heavy_drinker = row.get('HvyAlcoholConsump', None)
        smoker = row.get('Smoker', None)
        physical_activity = row.get('PhysActivity', None)
        diff_walk = row.get('DiffWalk', None)
        ment_hlth = row.get('MentHlth', None)
        phys_hlth = row.get('PhysHlth', None)
        
        # Insertar respuestas individuales usando Respuesta_Estilo_Vida
        if fruits is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, '{bool(fruits)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if vegetables is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, '{bool(vegetables)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if smoker is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, '{bool(smoker)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if heavy_drinker is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, '{bool(heavy_drinker)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if diff_walk is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, '{bool(diff_walk)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if ment_hlth is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '{ment_hlth}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if phys_hlth is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '{phys_hlth}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        if physical_activity is not None:
            sql_commands.append(f"""
INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, '{bool(physical_activity)}', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = '{email}';""")
        
        # 5. Insertar predicción basada en los datos
        diabetes_binary = row.get('Diabetes_binary', None)
        prediccion_boolean = diabetes_binary == 'Diabetic' if diabetes_binary is not None else None
        
        if prediccion_boolean is not None:
            sql_commands.append(f"""
INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = '{email}'),
       {prediccion_boolean}, 
       CURRENT_TIMESTAMP,
       {0.8 if prediccion_boolean else 0.2};""")
        
        sql_commands.append("")
    
    # Escribir a archivo SQL
    with open('diabetes_sql_commands.sql', 'w', encoding='utf-8') as f:
        for command in sql_commands:
            f.write(command + '\n')
    
    print(f"✅ Comandos SQL generados en 'diabetes_sql_commands.sql'")
    print(f"✅ Total de comandos: {len(sql_commands)}")
    print("✅ Compatible con init_new.sql")
    print("✅ Ejecuta este archivo después de insert_data.sql")

def main():
    import os
    
    # Verificar si ya existe el CSV combinado
    if os.path.exists('cdc_diabetes_combined.csv'):
        print("📁 Archivo CSV combinado encontrado, cargando desde archivo...")
        df_combined = pd.read_csv('cdc_diabetes_combined.csv')
        print(f"✅ Dataset cargado desde CSV:")
        print(f"   - Total: {len(df_combined)} registros")
        print(f"✅ Columnas: {list(df_combined.columns)}")
    else:
        print("📥 CSV combinado no encontrado, cargando dataset desde Hugging Face...")
        
        # Cargar dataset completo
        ds = load_dataset("Bena345/cdc-diabetes-health-indicators")
        
        # Convertir a DataFrames
        df_train = pd.DataFrame(ds['train'])
        df_test = pd.DataFrame(ds['test'])
        
        print(f"✅ Dataset cargado:")
        print(f"   - Train: {len(df_train)} registros")
        print(f"   - Test: {len(df_test)} registros")
        print(f"   - Total: {len(df_train) + len(df_test)} registros")
        print(f"✅ Columnas: {list(df_train.columns)}")
        
        # Guardar datos
        print("\n=== GUARDANDO DATOS ===")
        df_train.to_csv('cdc_diabetes_train.csv', index=False)
        df_test.to_csv('cdc_diabetes_test.csv', index=False)
        print("✅ Train guardado en 'cdc_diabetes_train.csv'")
        print("✅ Test guardado en 'cdc_diabetes_test.csv'")
        
        # Combinar train y test
        df_combined = pd.concat([df_train, df_test], ignore_index=True)
        df_combined.to_csv('cdc_diabetes_combined.csv', index=False)
        print("✅ Datos combinados guardados en 'cdc_diabetes_combined.csv'")
    
    # Generar comandos SQL de inserción
    print("\n=== GENERANDO COMANDOS SQL ===")
    generate_sql_commands(df_combined)
    
    print("\n✅ Datos cargados exitosamente")
    print("Los datos están disponibles en:")
    print("- df_combined: datos combinados")
    print("- diabetes_sql_commands.sql: comandos SQL para insertar datos")

if __name__ == "__main__":
    main()

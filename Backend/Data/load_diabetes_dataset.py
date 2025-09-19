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
    """Generar comandos SQL de inserción"""
    
    sql_commands = []
    
    # Agregar comentario
    sql_commands.append("-- Comandos SQL generados automáticamente del dataset CDC Diabetes")
    sql_commands.append("-- Copia estos comandos y pégalos al final de tu init.sql")
    sql_commands.append("")
    
    # Limitar a 1000 registros para un archivo SQL manejable
    sample_size = min(1000, len(df_combined))
    df_sample = df_combined.head(sample_size)
    
    print(f"Generando comandos SQL para {sample_size} registros...")
    
    # Ahora procesar cada registro del dataset
    sql_commands.append("-- Insertar datos de usuarios del dataset CDC")
    for i in range(sample_size):
        row = df_sample.iloc[i]
        
        # Generar email único para este registro
        email = f"user_{i+1}@cdc-diabetes.com"
        
        # 1. Insertar usuario con contraseña hasheada
        sql_commands.append(f"-- Usuario {i+1}")
        # Generar contraseña hasheada para este usuario
        plain_password = "password123"
        hashed_password = hash_password(plain_password)
        sql_commands.append(f"INSERT INTO Usuario (email, contraseña) VALUES ('{email}', '{hashed_password}');")
        
        # 2. Insertar datos personales
        sex = row.get('Sex', None)
        gender_boolean = sex == 1 if sex is not None else None  # True = Masculino, False = Femenino, None = NULL
        age = row.get('Age', None)
        
        # Convertir age a entero si es string
        if age is not None:
            try:
                age = int(age)
                # Generar fecha de nacimiento aproximada basada en la edad
                birth_year = 2024 - age
                birth_date = f"{birth_year}-01-01"
            except (ValueError, TypeError):
                age = None  # NULL si no se puede convertir
                birth_date = "NULL"
        else:
            birth_date = "NULL"
        
        first_name = f"Usuario_{i+1}"
        last_name = f"CDC_{i+1}"
        
        # Manejar valores NULL correctamente en SQL
        birth_date_sql = f"'{birth_date}'" if birth_date != "NULL" else "NULL"
        age_sql = str(age) if age is not None else "NULL"
        sex_sql = str(gender_boolean) if gender_boolean is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Datos_Personales (nombre, apellido, fecha_nacimiento, sexo, id_usuario)
VALUES ('{first_name}', '{last_name}', {birth_date_sql}, {sex_sql}, (SELECT id_usuario FROM Usuario WHERE email = '{email}'));""")
        
        # 3. Insertar historial médico
        diabetes = row.get('Diabetes_binary', None)
        high_bp = row.get('HighBP', None)
        high_chol = row.get('HighChol', None)  # -> colesterol_alto
        chol_check = row.get('CholCheck', None)  # -> colesterol
        bmi = row.get('BMI', None)
        stroke = row.get('Stroke', None)
        heart_disease = row.get('HeartDiseaseorAttack', None)
        gen_hlth = row.get('GenHlth', None)  # -> salud_general
        
        # Mapear presión arterial basada en HighBP
        presion_arterial = "Alta" if high_bp == 1 else "Normal" if high_bp == 0 else None
        
        # Mapear salud general basada en GenHlth (1=Excelente, 2=Muy bueno, 3=Bueno, 4=Regular, 5=Malo)
        salud_general_map = {
            1: "Excelente",
            2: "Muy bueno", 
            3: "Bueno",
            4: "Regular",
            5: "Malo"
        }
        salud_general = salud_general_map.get(gen_hlth, None) if gen_hlth is not None else None
        
        # Convertir valores a SQL apropiado
        chol_check_sql = str(bool(chol_check)) if chol_check is not None else "NULL"
        high_chol_sql = str(bool(high_chol)) if high_chol is not None else "NULL"
        bmi_sql = str(bmi) if bmi is not None else "NULL"
        presion_arterial_sql = f"'{presion_arterial}'" if presion_arterial is not None else "NULL"
        stroke_sql = str(bool(stroke)) if stroke is not None else "NULL"
        heart_disease_sql = str(bool(heart_disease)) if heart_disease is not None else "NULL"
        salud_general_sql = f"'{salud_general}'" if salud_general is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Historial_Medico (colesterol, colesterol_alto, bmi, presion_arterial, acv, problemas_corazon, salud_general, id_usuario)
SELECT {chol_check_sql}, {high_chol_sql}, {bmi_sql}, {presion_arterial_sql}, {stroke_sql}, {heart_disease_sql}, {salud_general_sql}, id_usuario 
FROM Usuario 
WHERE email = '{email}';""")
        
        # Insertar relación con diabetes si aplica
        diabetes_binary = row.get('Diabetes_binary', None)
        if diabetes_binary == 'Diabetic':
            sql_commands.append(f"""
INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = '{email}';""")
        
        # 4. Insertar estilo de vida
        fruits = row.get('Fruits', None)
        vegetables = row.get('Veggies', None)
        heavy_drinker = row.get('HvyAlcoholConsump', None)
        smoker = row.get('Smoker', None)
        physical_activity = row.get('PhysActivity', None)  # -> actividad_fisica
        diff_walk = row.get('DiffWalk', None)  # -> dificultad_caminar
        ment_hlth = row.get('MentHlth', None)  # -> dias_salud_mental
        phys_hlth = row.get('PhysHlth', None)  # -> dias_salud_fisica
        
        # Mapear nivel de actividad física
        nivel_actividad = "Alto" if physical_activity == 1 else "Bajo" if physical_activity == 0 else None
        
        # Generar datos de sueño y estrés basados en otros factores
        horas_dormir = 7.5 if (smoker == 0 and heavy_drinker == 0) else 6.0 if (smoker == 1 or heavy_drinker == 1) else None
        nivel_estres = 3 if physical_activity == 0 else 2 if physical_activity == 1 else None
        # Usar MentHlth directamente (días con buena salud mental en el último mes)
        dias_salud_mental = ment_hlth
        # Usar PhysHlth directamente (días con buena salud física en el último mes)
        dias_salud_fisica = phys_hlth
        
        # Convertir valores de estilo de vida a SQL apropiado
        fruits_sql = str(bool(fruits)) if fruits is not None else "NULL"
        vegetables_sql = str(bool(vegetables)) if vegetables is not None else "NULL"
        heavy_drinker_sql = str(bool(heavy_drinker)) if heavy_drinker is not None else "NULL"
        smoker_sql = str(bool(smoker)) if smoker is not None else "NULL"
        diff_walk_sql = str(bool(diff_walk)) if diff_walk is not None else "NULL"
        horas_dormir_sql = str(horas_dormir) if horas_dormir is not None else "NULL"
        nivel_estres_sql = str(nivel_estres) if nivel_estres is not None else "NULL"
        dias_salud_mental_sql = str(dias_salud_mental) if dias_salud_mental is not None else "NULL"
        nivel_actividad_sql = f"'{nivel_actividad}'" if nivel_actividad is not None else "NULL"
        physical_activity_sql = str(bool(physical_activity)) if physical_activity is not None else "NULL"
        dias_salud_fisica_sql = str(dias_salud_fisica) if dias_salud_fisica is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Estilo_Vida (frutas, verduras, alcohol, tabaco, dificultad_caminar, horas_dormir, nivel_estres, dias_salud_mental, nivel_actividad_fisica, actividad_fisica, dias_salud_fisica, id_usuario)
SELECT {fruits_sql}, {vegetables_sql}, {heavy_drinker_sql}, {smoker_sql}, {diff_walk_sql}, {horas_dormir_sql}, {nivel_estres_sql}, {dias_salud_mental_sql}, {nivel_actividad_sql}, {physical_activity_sql}, {dias_salud_fisica_sql}, id_usuario 
FROM Usuario 
WHERE email = '{email}';""")
        
        # 6. Insertar predicción basada en los datos
        # Mapear Diabetes_binary ('Diabetic'/'Non-Diabetic') a boolean
        diabetes_binary = row.get('Diabetes_binary', None)  # 'Diabetic' o 'Non-Diabetic' del dataset
        prediccion_boolean = diabetes_binary == 'Diabetic' if diabetes_binary is not None else None  # True si es 'Diabetic', False si es 'Non-Diabetic', None si es NULL
        
        prediccion_sql = str(prediccion_boolean) if prediccion_boolean is not None else "NULL"
        
        sql_commands.append(f"""
INSERT INTO Prediccion (prediccion, fecha, id_enfermedad, id_usuario)
VALUES ({prediccion_sql}, CURRENT_TIMESTAMP, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), (SELECT id_usuario FROM Usuario WHERE email = '{email}'));""")
        
        sql_commands.append("")
    
    # Escribir a archivo
    with open('diabetes_sql_commands.txt', 'w', encoding='utf-8') as f:
        for command in sql_commands:
            f.write(command + '\n')
    
    print(f"✅ Comandos SQL generados en 'sql_commands.txt'")
    print(f"✅ Total de comandos: {len(sql_commands)}")
    print("✅ Copia el contenido de 'sql_commands.txt' y pégalo al final de tu init.sql")

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
    print("- diabetes_sql_commands.txt: comandos SQL para insertar datos")

if __name__ == "__main__":
    main()

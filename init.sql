-- Crear la base de datos solo si no existe
SELECT 'CREATE DATABASE Predicthealth'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'predicthealth')\gexec

-- Conectar a la base de datos
\c predicthealth;

-- Habilitar la extensión para UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla Usuario
CREATE TABLE IF NOT EXISTS Usuario (
    id_usuario UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    contraseña TEXT NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Refresh_Token
CREATE TABLE IF NOT EXISTS Refresh_Token (
    id_token UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    token TEXT UNIQUE NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiracion TIMESTAMP NOT NULL,
    revocado BOOLEAN DEFAULT FALSE,
    remplazado_por_token UUID,
    id_usuario UUID NOT NULL,
    FOREIGN KEY (remplazado_por_token) REFERENCES Refresh_Token(id_token),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Gps
CREATE TABLE IF NOT EXISTS Gps (
    id_gps UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    latitud DECIMAL(9,6) NOT NULL,
    longitud DECIMAL(9,6) NOT NULL,
    altitud DECIMAL(6,2),
    fecha_captura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario UUID NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Datos_Personales
CREATE TABLE IF NOT EXISTS Datos_Personales (
    id_datos UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(150),
    apellido VARCHAR(150),
    fecha_nacimiento DATE,
    sexo VARCHAR(20),
    id_usuario UUID UNIQUE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Historial_Medico
CREATE TABLE IF NOT EXISTS Historial_Medico (
    id_historial UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    diabetes BOOLEAN,
    hipertension BOOLEAN,
    colesterol BOOLEAN,
    colesterol_alto BOOLEAN,
    bmi NUMERIC(5,2),
    presion_arterial VARCHAR(50),
    acv BOOLEAN,
    problemas_corazon BOOLEAN,
    salud_general VARCHAR(100),
    id_usuario UUID UNIQUE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Medicamento
CREATE TABLE IF NOT EXISTS Medicamento (
    id_medicamento UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(150)
);

-- Tabla Historial_Medicamento
CREATE TABLE IF NOT EXISTS Historial_Medicamento (
    id_historial UUID,
    id_medicamento UUID,
    PRIMARY KEY (id_historial, id_medicamento),
    FOREIGN KEY (id_historial) REFERENCES Historial_Medico(id_historial) ON DELETE CASCADE,
    FOREIGN KEY (id_medicamento) REFERENCES Medicamento(id_medicamento) ON DELETE CASCADE
);

-- Tabla Estilo_Vida
CREATE TABLE IF NOT EXISTS Estilo_Vida (
    id_estilo UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    frutas BOOLEAN,
    verduras BOOLEAN,
    consumo_sal NUMERIC(5,2),
    tabaco BOOLEAN,
    alcohol BOOLEAN,
    dificultad_caminar BOOLEAN,
    horas_dormir NUMERIC(3,1),
    nivel_estres INT,
    dias_salud_mental INT,
    nivel_actividad_fisica VARCHAR(50),
    actividad_fisica BOOLEAN,
    dias_salud_fisica INT,
    id_usuario UUID UNIQUE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Enfermedad
CREATE TABLE IF NOT EXISTS Enfermedad (
    id_enfermedad UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(150)
);

-- Tabla Prediccion
CREATE TABLE IF NOT EXISTS Prediccion (
    id_prediccion UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    prediccion VARCHAR(100),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_enfermedad UUID,
    id_usuario UUID NOT NULL,
    FOREIGN KEY (id_enfermedad) REFERENCES Enfermedad(id_enfermedad) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Recomendacion
CREATE TABLE IF NOT EXISTS Recomendacion (
    id_recomendacion UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    titulo VARCHAR(150),
    descripcion TEXT
);

-- Tabla Enfermedad_Recomendacion
CREATE TABLE IF NOT EXISTS Enfermedad_Recomendacion (
    id_enfermedad UUID,
    id_recomendacion UUID,
    PRIMARY KEY (id_enfermedad, id_recomendacion),
    FOREIGN KEY (id_enfermedad) REFERENCES Enfermedad(id_enfermedad) ON DELETE CASCADE,
    FOREIGN KEY (id_recomendacion) REFERENCES Recomendacion(id_recomendacion) ON DELETE CASCADE
);

-- Tabla Documento
CREATE TABLE IF NOT EXISTS Documento (
    id_documento UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(255)
);

-- Tabla Documento_Subido
CREATE TABLE IF NOT EXISTS Documento_Subido (
    id_subido UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    fecha_subido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    texto_raw TEXT,
    id_documento UUID,
    id_usuario UUID NOT NULL,
    FOREIGN KEY (id_documento) REFERENCES Documento(id_documento) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Documento_Enfermedad
CREATE TABLE IF NOT EXISTS Documento_Enfermedad (
    id_documento UUID,
    id_enfermedad UUID,
    PRIMARY KEY (id_documento, id_enfermedad),
    FOREIGN KEY (id_documento) REFERENCES Documento(id_documento) ON DELETE CASCADE,
    FOREIGN KEY (id_enfermedad) REFERENCES Enfermedad(id_enfermedad) ON DELETE CASCADE
);

-- Tabla Hemoglobina_Glicada
CREATE TABLE IF NOT EXISTS Hemoglobina_Glicada (
    id_subido UUID PRIMARY KEY,
    hba1c NUMERIC(4,2),
    FOREIGN KEY (id_subido) REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE
);

-- Tabla Curva_Tolerancia
CREATE TABLE IF NOT EXISTS Curva_Tolerancia (
    id_subido UUID PRIMARY KEY,
    glucosa_ayunas NUMERIC(5,2),
    FOREIGN KEY (id_subido) REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE
);

-- Tabla Perfil_Lipidico
CREATE TABLE IF NOT EXISTS Perfil_Lipidico (
    id_subido UUID PRIMARY KEY,
    colesterol_LDL NUMERIC(5,2),
    colesterol_HDL NUMERIC(5,2),
    triglicéridos NUMERIC(5,2),
    FOREIGN KEY (id_subido) REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE
);

-- Tabla Panel_Metabolico
CREATE TABLE IF NOT EXISTS Panel_Metabolico (
    id_subido UUID PRIMARY KEY,
    glucosa_ayunas NUMERIC(5,2),
    creatinina NUMERIC(5,2),
    filtrado_glomerular NUMERIC(5,2),
    FOREIGN KEY (id_subido) REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE
);

-- Tabla Monitoreo_PA
CREATE TABLE IF NOT EXISTS Monitoreo_PA (
    id_subido UUID PRIMARY KEY,
    PA_sistólica_promedio NUMERIC(5,2),
    PA_diastolica_promedio NUMERIC(5,2),
    FOREIGN KEY (id_subido) REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE
);

-- Tabla Consulta
CREATE TABLE IF NOT EXISTS Consulta (
    id_subido UUID PRIMARY KEY,
    diabtes_confirmada BOOLEAN,
    hipertencion_confirmada BOOLEAN,
    tratamiento_metformina BOOLEAN,
    tratamiento_insulina BOOLEAN,
    tratamiento_losartan BOOLEAN,
    tratamiento_amlodipino BOOLEAN,
    complicacion_retinopatia BOOLEAN,
    complicacion_neuropatia BOOLEAN,
    complicion_nefropatia BOOLEAN,
    FOREIGN KEY (id_subido) REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE
);

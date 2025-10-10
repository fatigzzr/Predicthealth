-- =====================================
-- SCRIPT DE INICIALIZACIÓN DE BASE DE DATOS PREDICTHEALTH
-- Compatible con cualquier usuario con permisos de superusuario o CREATEDB
-- =====================================

-- Conectarse a la base principal
\connect postgres

-- =====================================
-- Cerrar conexiones y eliminar base existente
-- =====================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'predicthealth') THEN
        RAISE NOTICE 'Cerrando conexiones activas de predicthealth...';
        PERFORM pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname = 'predicthealth'
        AND pid <> pg_backend_pid();
    END IF;
END$$;

-- Eliminar base de datos si existe (fuera del bloque DO)
DROP DATABASE IF EXISTS predicthealth;

-- =====================================
-- Crear base de datos con el usuario actual como propietario
-- =====================================

CREATE DATABASE predicthealth
    WITH ENCODING = 'UTF8'
    LC_COLLATE = 'es_MX.UTF-8'
    LC_CTYPE = 'es_MX.UTF-8'
    TEMPLATE = template0;

COMMENT ON DATABASE predicthealth IS 'Base de datos principal del sistema PredictHealth';

-- =====================================
-- Crear usuario de aplicación si no existe
-- =====================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'predicthealth_user'
    ) THEN
        CREATE ROLE predicthealth_user LOGIN PASSWORD '666';
        RAISE NOTICE 'Usuario predicthealth_user creado.';
    ELSE
        RAISE NOTICE 'Usuario predicthealth_user ya existe.';
    END IF;
END$$;

-- Otorgar permisos de conexión
GRANT CONNECT ON DATABASE predicthealth TO predicthealth_user;

-- =====================================
-- Conectarse a la nueva base
-- =====================================

\connect predicthealth

-- =====================================
-- Crear extensiones
-- =====================================

-- CREATE EXTENSION IF NOT EXISTS postgis;  -- Comentado: PostGIS no está instalado
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================
-- Tabla: Rol
-- =====================================
CREATE TABLE Rol (
    id_rol SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- =====================================
-- Tabla: Usuario
-- =====================================
CREATE TABLE Usuario (
    id_usuario SERIAL PRIMARY KEY,
    id_rol INT NOT NULL REFERENCES Rol(id_rol) ON DELETE RESTRICT,
    email VARCHAR(255) UNIQUE NOT NULL,
    contraseña_hash VARCHAR(255) NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================
-- Tabla: Paciente
-- =====================================
CREATE TABLE Paciente (
    id_datos SERIAL PRIMARY KEY,
    id_usuario INT UNIQUE NOT NULL REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo CHAR(1) CHECK (sexo IN ('M','F')),
    fecha TIMESTAMP NOT NULL DEFAULT now()
);

-- =====================================
-- Tabla: Entidad
-- =====================================
CREATE TABLE Entidad (
    id_entidad SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL
);

-- =====================================
-- Tabla: Registro_Auditoria
-- =====================================
CREATE TABLE Registro_Auditoria (
    id_registro SERIAL PRIMARY KEY,
    id_usuario INT REFERENCES Usuario(id_usuario) ON DELETE SET NULL,
    id_entidad INT REFERENCES Entidad(id_entidad) ON DELETE SET NULL,
    accion VARCHAR(20) NOT NULL CHECK (accion IN ('CREATE','UPDATE','DELETE','LOGIN')),
    fecha_hora TIMESTAMP NOT NULL DEFAULT now(),
    detalles JSONB
);

-- =====================================
-- Tabla: Refresh_Token
-- =====================================
CREATE TABLE Refresh_Token (
    id_token SERIAL PRIMARY KEY,
    token UUID NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT now(),
    expiracion TIMESTAMP NOT NULL,
    revocado BOOLEAN NOT NULL DEFAULT FALSE,
    remplazado_por_token INT UNIQUE REFERENCES Refresh_Token(id_token) ON DELETE SET NULL,
    id_usuario INT NOT NULL REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- =====================================
-- Tabla: Fuente_GPS
-- =====================================
CREATE TABLE Fuente_GPS (
    id_fuente SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- =====================================
-- Tabla: Registros_GPS
-- =====================================
CREATE TABLE Registros_GPS (
    id_gps SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    id_fuente INT NOT NULL REFERENCES Fuente_GPS(id_fuente) ON DELETE CASCADE,
    ubicacion POINT,  -- Cambiado de GEOMETRY a POINT básico
    altitud REAL,
    precision REAL CHECK (precision >= 0),
    fecha_captura TIMESTAMP NOT NULL
);

-- =====================================
-- Tabla: Unidad
-- =====================================
CREATE TABLE Unidad (
    id_unidad SERIAL PRIMARY KEY,
    unidad VARCHAR(20) UNIQUE NOT NULL
);

-- =====================================
-- Tabla: Tipo_Medicion
-- =====================================
CREATE TABLE Tipo_Medicion (
    id_medicion SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    id_unidad INT REFERENCES Unidad(id_unidad) ON DELETE RESTRICT
);

-- =====================================
-- Tabla: Historial_Medico
-- =====================================
CREATE TABLE Historial_Medico (
    id_historial SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    id_medicion INT NOT NULL REFERENCES Tipo_Medicion(id_medicion) ON DELETE CASCADE,
    valor VARCHAR(50) NOT NULL,
    fecha TIMESTAMP NOT NULL
);

-- =====================================
-- Tabla: Pregunta
-- =====================================
CREATE TABLE Pregunta (
    id_pregunta SERIAL PRIMARY KEY,
    id_unidad INT NOT NULL REFERENCES Unidad(id_unidad) ON DELETE RESTRICT,
    pregunta VARCHAR(255) NOT NULL UNIQUE
);

-- =====================================
-- Tabla: Respuesta_Estilo_Vida
-- =====================================
CREATE TABLE Respuesta_Estilo_Vida (
    id_respuesta SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    id_pregunta INT NOT NULL REFERENCES Pregunta(id_pregunta) ON DELETE CASCADE,
    valor VARCHAR(50) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT now()
);

-- =====================================
-- Tabla: Analito
-- =====================================
CREATE TABLE Analito (
    analito_codigo VARCHAR(10) PRIMARY KEY,
    id_unidad INT REFERENCES Unidad(id_unidad) ON DELETE RESTRICT,
    nombre VARCHAR(100) NOT NULL,
    referencia VARCHAR(20)
);

-- =====================================
-- Tabla: Resultado_Lab (movida después de Documento_Subido)
-- =====================================

-- =====================================
-- Tabla: Tipo_Signo_Vital
-- =====================================
CREATE TABLE Tipo_Signo_Vital (
    id_tipo SERIAL PRIMARY KEY,
    id_unidad INT REFERENCES Unidad(id_unidad) ON DELETE RESTRICT,
    nombre VARCHAR(50) NOT NULL
);

-- =====================================
-- Tabla: Postura
-- =====================================
CREATE TABLE Postura (
    id_postura SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- =====================================
-- Tabla: Dispositivo
-- =====================================
CREATE TABLE Dispositivo (
    id_dispositivo SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- =====================================
-- Tabla: Signo_Vital
-- =====================================
CREATE TABLE Signo_Vital (
    id_vital SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    id_tipo INT NOT NULL REFERENCES Tipo_Signo_Vital(id_tipo),
    id_dispositivo INT NOT NULL REFERENCES Dispositivo(id_dispositivo),
    id_postura INT NOT NULL REFERENCES Postura(id_postura),
    valor REAL NOT NULL,
    timestamp TIMESTAMP NOT NULL
);

-- =====================================
-- Tabla: Enfermedad
-- =====================================
CREATE TABLE Enfermedad (
    id_enfermedad SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL
);

-- =====================================
-- Tabla: Modelo
-- =====================================
CREATE TABLE Modelo (
    id_modelo SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    version VARCHAR(20) NOT NULL,
    umbral REAL NOT NULL CHECK (umbral >= 0 AND umbral <= 1),
    descripcion TEXT,
    referencia_entrada TEXT
);

-- =====================================
-- Tabla: Prediccion
-- =====================================
CREATE TABLE Prediccion (
    id_prediccion SERIAL PRIMARY KEY,
    id_enfermedad INT REFERENCES Enfermedad(id_enfermedad) ON DELETE CASCADE,
    id_usuario INT REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    id_modelo INT REFERENCES Modelo(id_modelo),
    prediccion BOOLEAN NOT NULL,
    fecha TIMESTAMP NOT NULL,
    probabilidad REAL CHECK (probabilidad >= 0 AND probabilidad <= 1),
    explicabilidad JSONB
);

-- =====================================
-- Tabla: Recomendacion
-- =====================================
CREATE TABLE Recomendacion (
    id_recomendacion SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT
);

-- =====================================
-- Tabla: Documento
-- =====================================
CREATE TABLE Documento (
    id_documento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL
);

-- =====================================
-- Tabla: Documento_Subido
-- =====================================
CREATE TABLE Documento_Subido (
    id_subido SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    id_documento INT NOT NULL REFERENCES Documento(id_documento),
    fecha_subido TIMESTAMP NOT NULL,
    texto_raw TEXT
);

-- =====================================
-- Tabla: Resultado_Lab
-- =====================================
CREATE TABLE Resultado_Lab (
    id_resultado SERIAL PRIMARY KEY,
    id_subido INT NOT NULL REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE,
    analito_codigo VARCHAR(10) NOT NULL REFERENCES Analito(analito_codigo) ON DELETE RESTRICT,
    valor REAL NOT NULL
);

-- =====================================
-- Tabla: Consulta
-- =====================================
CREATE TABLE Consulta (
    id_consulta SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tipo_dato INT NOT NULL REFERENCES Unidad(id_unidad)
);

-- =====================================
-- Tabla: Extracciones_Nlp
-- =====================================
CREATE TABLE Extracciones_Nlp (
    id_extraccion SERIAL PRIMARY KEY,
    id_subido INT NOT NULL REFERENCES Documento_Subido(id_subido) ON DELETE CASCADE,
    id_consulta INT NOT NULL REFERENCES Consulta(id_consulta),
    valor VARCHAR(50) NOT NULL,
    confianza REAL CHECK (confianza >= 0 AND confianza <= 100),
    procedencia TEXT
);

-- =====================================
-- Tabla: Historial_Enfermedad
-- =====================================
CREATE TABLE Historial_Enfermedad (
    id_historial INT NOT NULL REFERENCES Historial_Medico(id_historial) ON DELETE CASCADE,
    id_enfermedad INT NOT NULL REFERENCES Enfermedad(id_enfermedad) ON DELETE CASCADE,
    PRIMARY KEY (id_historial, id_enfermedad)
);

-- =====================================
-- Tabla: Medicamento
-- =====================================
CREATE TABLE Medicamento (
    id_medicamento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL
);

-- =====================================
-- Tabla: Historial_Medicamento
-- =====================================
CREATE TABLE Historial_Medicamento (
    id_historial INT NOT NULL REFERENCES Historial_Medico(id_historial) ON DELETE CASCADE,
    id_medicamento INT NOT NULL REFERENCES Medicamento(id_medicamento) ON DELETE CASCADE,
    PRIMARY KEY (id_historial, id_medicamento)
);

-- =====================================
-- Tabla: Enfermedad_Recomendacion
-- =====================================
CREATE TABLE Enfermedad_Recomendacion (
    id_enfermedad INT NOT NULL REFERENCES Enfermedad(id_enfermedad) ON DELETE CASCADE,
    id_recomendacion INT NOT NULL REFERENCES Recomendacion(id_recomendacion) ON DELETE CASCADE,
    PRIMARY KEY (id_enfermedad, id_recomendacion)
);

-- =====================================
-- Tabla: Documento_Enfermedad
-- =====================================
CREATE TABLE Documento_Enfermedad (
    id_documento INT NOT NULL REFERENCES Documento(id_documento) ON DELETE CASCADE,
    id_enfermedad INT NOT NULL REFERENCES Enfermedad(id_enfermedad) ON DELETE CASCADE,
    PRIMARY KEY (id_documento, id_enfermedad)
);

-- =====================================
-- Permisos y usuario de prueba para login
-- =====================================

-- Asegurar contraseña del rol de aplicación si ya existía
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'predicthealth_user') THEN
        ALTER ROLE predicthealth_user LOGIN PASSWORD '666';
    END IF;
END$$;

-- Otorgar permisos sobre el esquema y tablas existentes
GRANT USAGE ON SCHEMA public TO predicthealth_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO predicthealth_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO predicthealth_user;

-- Otorgar privilegios por defecto para futuras tablas/secuencias
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO predicthealth_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO predicthealth_user;

-- Asegurar permisos sobre tablas existentes (ejecutar después de crear todas las tablas)
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO predicthealth_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO predicthealth_user;

-- =====================================
-- ÍNDICES POR TIEMPO - ESQUEMA PREDICTHEALTH
-- =====================================

-- Signo_Vital: índice por usuario y timestamp
CREATE INDEX idx_signo_vital_usuario_timestamp
ON Signo_Vital(id_usuario, timestamp);

-- Historial_Medico: índice por usuario y fecha de medición
CREATE INDEX idx_historial_medico_usuario_fecha
ON Historial_Medico(id_usuario, fecha);

-- Prediccion: índice por usuario y fecha de predicción
CREATE INDEX idx_prediccion_usuario_fecha
ON Prediccion(id_usuario, fecha);

-- Registro_Auditoria: índice por fecha_hora
CREATE INDEX idx_registro_auditoria_fecha
ON Registro_Auditoria(fecha_hora);

-- Documento_Subido: índice por fecha_subido
CREATE INDEX idx_documento_subido_fecha
ON Documento_Subido(fecha_subido);

-- Respuesta_Estilo_Vida: índice por usuario y fecha
CREATE INDEX idx_respuesta_estilo_vida_usuario_fecha
ON Respuesta_Estilo_Vida(id_usuario, fecha);

-- Registros_GPS: índice por usuario y fecha_captura
CREATE INDEX idx_registros_gps_usuario_fecha
ON Registros_GPS(id_usuario, fecha_captura);

-- Refresh_Token: índice por expiración
CREATE INDEX idx_refresh_token_expiracion
ON Refresh_Token(expiracion);

-- Historial_Enfermedad: índice por id_historial (FK a Historial_Medico)
CREATE INDEX idx_historial_enfermedad_historial
ON Historial_Enfermedad(id_historial);

-- Historial_Medicamento: índice por id_historial (FK a Historial_Medico)
CREATE INDEX idx_historial_medicamento_historial
ON Historial_Medicamento(id_historial);

-- Extracciones_Nlp: índice por id_subido y confianza (útil para filtrar extracciones recientes)
CREATE INDEX idx_extracciones_nlp_subido
ON Extracciones_Nlp(id_subido, confianza);

-- Documento_Enfermedad: índice por id_documento (FK a Documento_Subido)
CREATE INDEX idx_documento_enfermedad_documento
ON Documento_Enfermedad(id_documento);

-- Opcional: índices espaciales para Registros_GPS
CREATE INDEX idx_registros_gps_ubicacion
ON Registros_GPS USING GIST(ubicacion);

-- =====================================
-- VISTAS COMPLETAS PARA DASHBOARD PREDICTHEALTH
-- Incluye Monitoreo de PA detallado
-- =====================================

-- Monitoreo de PA completo: promedio, mínimo y máximo, por postura y dispositivo
CREATE OR REPLACE VIEW Monitoreo_PA_Completo AS
SELECT
    sv.id_usuario,
    DATE_TRUNC('day', sv.timestamp) AS fecha,
    sv.id_postura,
    sv.id_dispositivo,
    AVG(CASE WHEN t.nombre = 'BP_sistolica' THEN sv.valor END) AS BP_sistolica_promedio,
    MIN(CASE WHEN t.nombre = 'BP_sistolica' THEN sv.valor END) AS BP_sistolica_min,
    MAX(CASE WHEN t.nombre = 'BP_sistolica' THEN sv.valor END) AS BP_sistolica_max,
    AVG(CASE WHEN t.nombre = 'BP_diastolica' THEN sv.valor END) AS BP_diastolica_promedio,
    MIN(CASE WHEN t.nombre = 'BP_diastolica' THEN sv.valor END) AS BP_diastolica_min,
    MAX(CASE WHEN t.nombre = 'BP_diastolica' THEN sv.valor END) AS BP_diastolica_max
FROM
    Signo_Vital sv
JOIN
    Tipo_Signo_Vital t ON sv.id_tipo = t.id_tipo
WHERE
    t.nombre IN ('BP_sistolica','BP_diastolica')
GROUP BY
    sv.id_usuario,
    DATE_TRUNC('day', sv.timestamp),
    sv.id_postura,
    sv.id_dispositivo
ORDER BY
    sv.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 1 - Monitoreo PA Completo
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_monitoreo_pa(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Monitoreo_PA_Completo;
END;
$$;

-- Signos Vitales generales: HR, SpO2 y otros
CREATE OR REPLACE VIEW Dashboard_Signos_Vitales AS
SELECT
    sv.id_usuario,
    DATE_TRUNC('day', sv.timestamp) AS fecha,
    sv.id_postura,
    AVG(CASE WHEN t.nombre = 'HR' THEN sv.valor END) AS frecuencia_cardiaca_promedio_diario,
    AVG(CASE WHEN t.nombre = 'SpO2' THEN sv.valor END) AS saturacion_oxigeno_promedio_diario,
    COUNT(CASE WHEN t.nombre = 'HR' THEN 1 END) AS mediciones_hr_dia,
    COUNT(CASE WHEN t.nombre = 'SpO2' THEN 1 END) AS mediciones_spo2_dia
FROM
    Signo_Vital sv
JOIN
    Tipo_Signo_Vital t ON sv.id_tipo = t.id_tipo
WHERE
    t.nombre IN ('HR', 'SpO2')
GROUP BY
    sv.id_usuario,
    DATE_TRUNC('day', sv.timestamp),
    sv.id_postura
ORDER BY
    sv.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 2 - Signos Vitales
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_signos_vitales(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Signos_Vitales;
END;
$$;

-- Laboratorio / Analitos
CREATE OR REPLACE VIEW Dashboard_Lab AS
SELECT
    hm.id_usuario,
    DATE_TRUNC('day', hm.fecha) AS fecha,
    tm.nombre AS analito,
    -- Para valores numéricos
    MIN(CASE WHEN hm.valor ~ '^[0-9]+\.?[0-9]*$' THEN hm.valor::NUMERIC END) AS valor_min,
    MAX(CASE WHEN hm.valor ~ '^[0-9]+\.?[0-9]*$' THEN hm.valor::NUMERIC END) AS valor_max,
    AVG(CASE WHEN hm.valor ~ '^[0-9]+\.?[0-9]*$' THEN hm.valor::NUMERIC END) AS valor_promedio,
    -- Para valores de texto (presión arterial, colesterol, etc.)
    STRING_AGG(DISTINCT hm.valor, ', ') AS valores_texto,
    COUNT(hm.id_historial) AS total_mediciones
FROM
    Historial_Medico hm
JOIN
    Tipo_Medicion tm ON hm.id_medicion = tm.id_medicion
GROUP BY
    hm.id_usuario,
    DATE_TRUNC('day', hm.fecha),
    tm.nombre
ORDER BY
    hm.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 3 - Laboratorio
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_lab(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Lab;
END;
$$;

-- Estilo de vida
CREATE OR REPLACE VIEW Dashboard_Estilo_Vida AS
SELECT
    rv.id_usuario,
    DATE_TRUNC('day', rv.fecha) AS fecha,
    COUNT(rv.id_respuesta) AS total_respuestas,
    SUM(CASE WHEN u.unidad = 'si/no' AND rv.valor = 'TRUE' THEN 1 ELSE 0 END) AS respuestas_si,
    SUM(CASE WHEN u.unidad = 'si/no' AND rv.valor = 'FALSE' THEN 1 ELSE 0 END) AS respuestas_no,
    AVG(CASE WHEN u.unidad = 'número' THEN rv.valor::NUMERIC END) AS promedio_numero,
    AVG(CASE WHEN u.unidad = 'escala' THEN rv.valor::NUMERIC END) AS promedio_escala
FROM
    Respuesta_Estilo_Vida rv
JOIN
    Pregunta p ON rv.id_pregunta = p.id_pregunta
JOIN
    Unidad u ON p.id_unidad = u.id_unidad
GROUP BY
    rv.id_usuario,
    DATE_TRUNC('day', rv.fecha)
ORDER BY
    rv.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 4 - Estilo de Vida
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_estilo_vida(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Estilo_Vida;
END;
$$;

-- Predicciones de IA
CREATE OR REPLACE VIEW Dashboard_Predicciones AS
SELECT
    p.id_usuario,
    DATE_TRUNC('day', p.fecha) AS fecha,
    e.nombre AS enfermedad,
    AVG(p.probabilidad) AS probabilidad_promedio,
    AVG(CASE WHEN p.prediccion THEN 1 ELSE 0 END) AS prediccion_promedio
FROM
    Prediccion p
JOIN
    Enfermedad e ON p.id_enfermedad = e.id_enfermedad
GROUP BY
    p.id_usuario,
    DATE_TRUNC('day', p.fecha),
    e.nombre
ORDER BY
    p.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 5 - Predicciones
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_predicciones(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Predicciones;
END;
$$;

-- Medicación
CREATE OR REPLACE VIEW Dashboard_Medicacion AS
SELECT
    hm.id_usuario,
    DATE_TRUNC('day', hm.fecha) AS fecha,
    m.nombre AS medicamento,
    COUNT(*) AS total_historial
FROM
    Historial_Medicamento hmed
JOIN
    Medicamento m ON hmed.id_medicamento = m.id_medicamento
JOIN
    Historial_Medico hm ON hmed.id_historial = hm.id_historial
GROUP BY
    hm.id_usuario,
    DATE_TRUNC('day', hm.fecha),
    m.nombre
ORDER BY
    hm.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 6 - Medicación
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_medicacion(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Medicacion;
END;
$$;

-- Documentos y Reportes
CREATE OR REPLACE VIEW Dashboard_Documentos AS
SELECT
    ds.id_usuario,
    DATE_TRUNC('day', ds.fecha_subido) AS fecha,
    COUNT(DISTINCT ds.id_subido) AS total_documentos,
    COUNT(DISTINCT de.id_enfermedad) AS total_enfermedades_mencionadas
FROM
    Documento_Subido ds
LEFT JOIN
    Documento_Enfermedad de ON ds.id_subido = de.id_documento
GROUP BY
    ds.id_usuario,
    DATE_TRUNC('day', ds.fecha_subido)
ORDER BY
    ds.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 7 - Documentos
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_documentos(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Documentos;
END;
$$;

-- Auditoría / Alertas
CREATE OR REPLACE VIEW Dashboard_Auditoria AS
SELECT
    ra.id_usuario,
    DATE_TRUNC('day', ra.fecha_hora) AS fecha,
    COUNT(*) AS total_acciones,
    SUM(CASE WHEN ra.accion = 'CREATE' THEN 1 ELSE 0 END) AS total_create,
    SUM(CASE WHEN ra.accion = 'UPDATE' THEN 1 ELSE 0 END) AS total_update,
    SUM(CASE WHEN ra.accion = 'DELETE' THEN 1 ELSE 0 END) AS total_delete,
    SUM(CASE WHEN ra.accion = 'LOGIN' THEN 1 ELSE 0 END) AS total_login,
    SUM(CASE WHEN ra.accion = 'LOGOUT' THEN 1 ELSE 0 END) AS total_logout
FROM
    Registro_Auditoria ra
GROUP BY
    ra.id_usuario,
    DATE_TRUNC('day', ra.fecha_hora)
ORDER BY
    ra.id_usuario,
    fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 8 - Auditoría
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_auditoria(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Auditoria;
END;
$$;

-- Vista combinada completa para dashboard
CREATE OR REPLACE VIEW Dashboard_Completo AS
WITH
-- Promedios diarios de Signos Vitales por usuario y tipo
vital_agg AS (
    SELECT
        sv.id_usuario,
        DATE_TRUNC('day', sv.timestamp) AS fecha,
        sv.id_postura,
        sv.id_dispositivo,
        AVG(CASE WHEN t.nombre = 'BP_sistolica' THEN sv.valor END) AS BP_sistolica_promedio,
        MIN(CASE WHEN t.nombre = 'BP_sistolica' THEN sv.valor END) AS BP_sistolica_min,
        MAX(CASE WHEN t.nombre = 'BP_sistolica' THEN sv.valor END) AS BP_sistolica_max,
        AVG(CASE WHEN t.nombre = 'BP_diastolica' THEN sv.valor END) AS BP_diastolica_promedio,
        MIN(CASE WHEN t.nombre = 'BP_diastolica' THEN sv.valor END) AS BP_diastolica_min,
        MAX(CASE WHEN t.nombre = 'BP_diastolica' THEN sv.valor END) AS BP_diastolica_max,
        AVG(CASE WHEN t.nombre NOT IN ('BP_sistolica','BP_diastolica') THEN sv.valor END) AS otros_signos_promedio
    FROM Signo_Vital sv
    JOIN Tipo_Signo_Vital t ON sv.id_tipo = t.id_tipo
    GROUP BY sv.id_usuario, DATE_TRUNC('day', sv.timestamp), sv.id_postura, sv.id_dispositivo
),
-- Promedios diarios de Historial Médico / Laboratorios (solo valores numéricos)
lab_agg AS (
    SELECT
        hm.id_usuario,
        DATE_TRUNC('day', hm.fecha) AS fecha,
        AVG(CASE WHEN hm.valor ~ '^[0-9]+\.?[0-9]*$' THEN hm.valor::NUMERIC END) AS lab_promedio
    FROM Historial_Medico hm
    GROUP BY hm.id_usuario, DATE_TRUNC('day', hm.fecha)
),
-- Promedios diarios de Estilo de Vida
estilo_agg AS (
    SELECT
        rv.id_usuario,
        DATE_TRUNC('day', rv.fecha) AS fecha,
        COUNT(rv.id_respuesta) AS total_respuestas,
        SUM(CASE WHEN u.unidad = 'si/no' AND rv.valor = 'TRUE' THEN 1 ELSE 0 END) AS respuestas_si,
        SUM(CASE WHEN u.unidad = 'si/no' AND rv.valor = 'FALSE' THEN 1 ELSE 0 END) AS respuestas_no,
        AVG(CASE WHEN u.unidad = 'número' THEN rv.valor::NUMERIC END) AS promedio_numero,
        AVG(CASE WHEN u.unidad = 'escala' THEN rv.valor::NUMERIC END) AS promedio_escala
    FROM Respuesta_Estilo_Vida rv
    JOIN Pregunta p ON rv.id_pregunta = p.id_pregunta
    JOIN Unidad u ON p.id_unidad = u.id_unidad
    GROUP BY rv.id_usuario, DATE_TRUNC('day', rv.fecha)
),
-- Promedios diarios de Predicciones
prediccion_agg AS (
    SELECT
        p.id_usuario,
        DATE_TRUNC('day', p.fecha) AS fecha,
        AVG(p.probabilidad) AS probabilidad_promedio,
        AVG(CASE WHEN p.prediccion THEN 1 ELSE 0 END) AS prediccion_boolean_promedio
    FROM Prediccion p
    GROUP BY p.id_usuario, DATE_TRUNC('day', p.fecha)
),
-- Medicación diaria
medicacion_agg AS (
    SELECT
        hm.id_usuario,
        DATE_TRUNC('day', hm.fecha) AS fecha,
        COUNT(hmed.id_medicamento) AS total_medicamentos
    FROM Historial_Medicamento hmed
    JOIN Historial_Medico hm ON hmed.id_historial = hm.id_historial
    GROUP BY hm.id_usuario, DATE_TRUNC('day', hm.fecha)
),
-- Documentos diarios
documentos_agg AS (
    SELECT
        ds.id_usuario,
        DATE_TRUNC('day', ds.fecha_subido) AS fecha,
        COUNT(DISTINCT ds.id_subido) AS total_documentos,
        COUNT(DISTINCT de.id_enfermedad) AS total_enfermedades_mencionadas
    FROM Documento_Subido ds
    LEFT JOIN Documento_Enfermedad de ON ds.id_subido = de.id_documento
    GROUP BY ds.id_usuario, DATE_TRUNC('day', ds.fecha_subido)
)
-- Unión de todas las métricas por usuario y día
SELECT
    v.id_usuario,
    v.fecha,
    v.id_postura,
    v.id_dispositivo,
    v.BP_sistolica_promedio,
    v.BP_sistolica_min,
    v.BP_sistolica_max,
    v.BP_diastolica_promedio,
    v.BP_diastolica_min,
    v.BP_diastolica_max,
    v.otros_signos_promedio,
    l.lab_promedio,
    e.total_respuestas,
    e.respuestas_si,
    e.respuestas_no,
    e.promedio_numero,
    e.promedio_escala,
    p.probabilidad_promedio,
    p.prediccion_boolean_promedio,
    m.total_medicamentos,
    d.total_documentos,
    d.total_enfermedades_mencionadas
FROM vital_agg v
LEFT JOIN lab_agg l ON v.id_usuario = l.id_usuario AND v.fecha = l.fecha
LEFT JOIN estilo_agg e ON v.id_usuario = e.id_usuario AND v.fecha = e.fecha
LEFT JOIN prediccion_agg p ON v.id_usuario = p.id_usuario AND v.fecha = p.fecha
LEFT JOIN medicacion_agg m ON v.id_usuario = m.id_usuario AND v.fecha = m.fecha
LEFT JOIN documentos_agg d ON v.id_usuario = d.id_usuario AND v.fecha = d.fecha
ORDER BY v.id_usuario, v.fecha;

-- =====================================
-- STORED PROCEDURE: Dashboard 9 - Dashboard Completo
-- =====================================
CREATE OR REPLACE PROCEDURE sp_dashboard_completo(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM Dashboard_Completo;
END;
$$;

-- =====================================
-- VISTAS: Dashboard KPIs - Indicadores Clave de Rendimiento
-- =====================================

-- Vista consolidada de KPIs principales
CREATE OR REPLACE VIEW dashboard_kpis AS
SELECT 
    -- KPI 1: Total de contenidos publicados
    (SELECT COUNT(*) FROM Documento_Subido) as documentos_subidos,
    (SELECT COUNT(*) FROM Prediccion) as predicciones_generadas,
    (SELECT COUNT(*) FROM Historial_Medico) as registros_medicos,
    (SELECT COUNT(*) FROM Respuesta_Estilo_Vida) as respuestas_estilo_vida,
    (SELECT COUNT(*) FROM Signo_Vital) as signos_vitales_registrados,
    
    -- KPI 2: Número de usuarios activos
    (SELECT COUNT(*) FROM Usuario) as total_usuarios,
    (SELECT COUNT(*) FROM Usuario WHERE actualizado_en >= NOW() - INTERVAL '30 days') as usuarios_activos_30_dias,
    (SELECT COUNT(*) FROM Usuario WHERE actualizado_en >= NOW() - INTERVAL '7 days') as usuarios_activos_7_dias,
    (SELECT COUNT(*) FROM Usuario WHERE creado_en >= NOW() - INTERVAL '30 days') as usuarios_nuevos_30_dias,
    
    -- KPI 3: Frecuencia de actualización (últimos 7 días)
    (SELECT COUNT(*) FROM Documento_Subido WHERE fecha_subido >= NOW() - INTERVAL '7 days') as documentos_esta_semana,
    (SELECT COUNT(*) FROM Prediccion WHERE fecha >= NOW() - INTERVAL '7 days') as predicciones_esta_semana,
    (SELECT COUNT(*) FROM Historial_Medico WHERE fecha >= NOW() - INTERVAL '7 days') as registros_medicos_esta_semana,
    
    -- Fecha de actualización
    NOW() as fecha_actualizacion;

-- Vista de usuarios por rol
CREATE OR REPLACE VIEW dashboard_usuarios_por_rol AS
SELECT 
    r.nombre as rol, 
    COUNT(u.id_usuario) as cantidad,
    ROUND((COUNT(u.id_usuario) * 100.0 / (SELECT COUNT(*) FROM Usuario)), 2) as porcentaje
FROM Rol r 
LEFT JOIN Usuario u ON r.id_rol = u.id_rol 
GROUP BY r.id_rol, r.nombre
ORDER BY cantidad DESC;

-- Vista de frecuencia de actualización por día (últimos 30 días)
CREATE OR REPLACE VIEW dashboard_frecuencia_diaria AS
SELECT 
    DATE_TRUNC('day', fecha_subido) as fecha,
    COUNT(*) as documentos_subidos,
    'documentos' as tipo_contenido
FROM Documento_Subido 
WHERE fecha_subido >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', fecha_subido)

UNION ALL

SELECT 
    DATE_TRUNC('day', fecha) as fecha,
    COUNT(*) as predicciones_generadas,
    'predicciones' as tipo_contenido
FROM Prediccion 
WHERE fecha >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', fecha)

UNION ALL

SELECT 
    DATE_TRUNC('day', fecha) as fecha,
    COUNT(*) as registros_medicos,
    'registros_medicos' as tipo_contenido
FROM Historial_Medico 
WHERE fecha >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', fecha)

ORDER BY fecha DESC;

-- Vista de crecimiento semanal
CREATE OR REPLACE VIEW dashboard_crecimiento_semanal AS
SELECT 
    DATE_TRUNC('week', fecha_subido) as semana,
    COUNT(*) as documentos_semana,
    'documentos' as tipo_contenido
FROM Documento_Subido 
WHERE fecha_subido >= NOW() - INTERVAL '12 weeks'
GROUP BY DATE_TRUNC('week', fecha_subido)

UNION ALL

SELECT 
    DATE_TRUNC('week', fecha) as semana,
    COUNT(*) as predicciones_semana,
    'predicciones' as tipo_contenido
FROM Prediccion 
WHERE fecha >= NOW() - INTERVAL '12 weeks'
GROUP BY DATE_TRUNC('week', fecha)

ORDER BY semana DESC;

-- Vista de actividad de usuarios por día
CREATE OR REPLACE VIEW dashboard_actividad_usuarios AS
SELECT 
    DATE_TRUNC('day', actualizado_en) as fecha,
    COUNT(*) as usuarios_activos,
    COUNT(CASE WHEN creado_en >= DATE_TRUNC('day', actualizado_en) THEN 1 END) as usuarios_nuevos
FROM Usuario 
WHERE actualizado_en >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', actualizado_en)
ORDER BY fecha DESC;

-- Vista de resumen ejecutivo
CREATE OR REPLACE VIEW dashboard_resumen_ejecutivo AS
SELECT 
    -- Totales generales
    (SELECT COUNT(*) FROM Usuario) as total_usuarios,
    (SELECT COUNT(*) FROM Documento_Subido) as total_documentos,
    (SELECT COUNT(*) FROM Prediccion) as total_predicciones,
    (SELECT COUNT(*) FROM Historial_Medico) as total_registros_medicos,
    
    -- Actividad reciente
    (SELECT COUNT(*) FROM Usuario WHERE actualizado_en >= NOW() - INTERVAL '7 days') as usuarios_activos_semana,
    (SELECT COUNT(*) FROM Documento_Subido WHERE fecha_subido >= NOW() - INTERVAL '7 days') as documentos_semana,
    (SELECT COUNT(*) FROM Prediccion WHERE fecha >= NOW() - INTERVAL '7 days') as predicciones_semana,
    
    -- Tendencias
    ROUND(
        (SELECT COUNT(*) FROM Usuario WHERE creado_en >= NOW() - INTERVAL '30 days') * 100.0 / 
        NULLIF((SELECT COUNT(*) FROM Usuario WHERE creado_en >= NOW() - INTERVAL '60 days'), 0), 2
    ) as crecimiento_usuarios_porcentaje,
    
    ROUND(
        (SELECT COUNT(*) FROM Documento_Subido WHERE fecha_subido >= NOW() - INTERVAL '30 days') * 100.0 / 
        NULLIF((SELECT COUNT(*) FROM Documento_Subido WHERE fecha_subido >= NOW() - INTERVAL '60 days'), 0), 2
    ) as crecimiento_documentos_porcentaje,
    
    -- Fecha de actualización
    NOW() as fecha_actualizacion;

-- Comentarios de las vistas
COMMENT ON VIEW dashboard_kpis IS 'Vista consolidada de KPIs principales del sistema';
COMMENT ON VIEW dashboard_usuarios_por_rol IS 'Distribución de usuarios por rol con porcentajes';
COMMENT ON VIEW dashboard_frecuencia_diaria IS 'Frecuencia de actualización de contenido por día (últimos 30 días)';
COMMENT ON VIEW dashboard_crecimiento_semanal IS 'Crecimiento semanal de contenido (últimas 12 semanas)';
COMMENT ON VIEW dashboard_actividad_usuarios IS 'Actividad diaria de usuarios (últimos 30 días)';
COMMENT ON VIEW dashboard_resumen_ejecutivo IS 'Resumen ejecutivo con métricas clave y tendencias';

-- =====================================
-- VISTAS ADICIONALES PARA GRÁFICAS DEL DASHBOARD
-- =====================================

-- Vista 1: Predicciones por Mes (Líneas)
CREATE OR REPLACE VIEW vista_predicciones_por_mes AS
SELECT 
    DATE_TRUNC('month', fecha) as mes,
    COUNT(*) as total_predicciones,
    AVG(probabilidad) as probabilidad_promedio,
    COUNT(CASE WHEN prediccion = true THEN 1 END) as predicciones_positivas,
    COUNT(CASE WHEN prediccion = false THEN 1 END) as predicciones_negativas
FROM Prediccion 
GROUP BY DATE_TRUNC('month', fecha)
ORDER BY mes;

-- Vista 2: Distribución de Enfermedades (Pastel)
CREATE OR REPLACE VIEW vista_distribucion_enfermedades AS
SELECT 
    e.nombre as enfermedad,
    COUNT(he.id_enfermedad) as casos,
    ROUND(
        (COUNT(he.id_enfermedad) * 100.0 / 
         (SELECT COUNT(*) FROM Historial_Enfermedad)), 2
    ) as porcentaje
FROM Enfermedad e
LEFT JOIN Historial_Enfermedad he ON e.id_enfermedad = he.id_enfermedad
GROUP BY e.nombre, e.id_enfermedad
ORDER BY casos DESC;

-- Vista 3: Estado de Documentos (Barras Apiladas)
CREATE OR REPLACE VIEW vista_estado_documentos AS
SELECT 
    CASE 
        WHEN texto_raw IS NOT NULL THEN 'Procesado'
        ELSE 'Pendiente'
    END as estado,
    COUNT(*) as cantidad,
    ROUND(
        (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Documento_Subido)), 2
    ) as porcentaje
FROM Documento_Subido
GROUP BY estado
ORDER BY cantidad DESC;

-- Vista 4: Distribución Demográfica (Barras Horizontales)
CREATE OR REPLACE VIEW vista_distribucion_demografica AS
SELECT 
    COALESCE(sexo, 'No especificado') as sexo,
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(fecha_nacimiento)) < 30 THEN '< 30'
        WHEN EXTRACT(YEAR FROM AGE(fecha_nacimiento)) < 50 THEN '30-50'
        WHEN EXTRACT(YEAR FROM AGE(fecha_nacimiento)) < 70 THEN '50-70'
        ELSE '> 70'
    END as grupo_edad,
    COUNT(*) as cantidad
FROM Paciente 
GROUP BY sexo, grupo_edad
ORDER BY sexo, grupo_edad;

-- Vista 5: Crecimiento Acumulado de Usuarios (Área)
CREATE OR REPLACE VIEW vista_crecimiento_acumulado_usuarios AS
WITH usuarios_por_mes AS (
    SELECT 
        DATE_TRUNC('month', creado_en) as mes,
        COUNT(*) as usuarios_nuevos
    FROM Usuario 
    GROUP BY DATE_TRUNC('month', creado_en)
),
usuarios_acumulados AS (
    SELECT 
        mes,
        usuarios_nuevos,
        SUM(usuarios_nuevos) OVER (ORDER BY mes) as usuarios_acumulados
    FROM usuarios_por_mes
)
SELECT 
    mes,
    usuarios_nuevos,
    usuarios_acumulados,
    LAG(usuarios_acumulados, 1, 0) OVER (ORDER BY mes) as usuarios_anterior_mes
FROM usuarios_acumulados
ORDER BY mes;

-- Vista 6: Top 5 Usuarios Más Activos (Barras Verticales)
CREATE OR REPLACE VIEW vista_top_usuarios_activos AS
SELECT 
    u.id_usuario,
    CONCAT(p.nombre, ' ', p.apellido) as usuario,
    COUNT(ds.id_subido) as documentos_subidos,
    COUNT(pred.id_prediccion) as predicciones_realizadas,
    COUNT(sv.id_vital) as signos_vitales_registrados,
    (COUNT(ds.id_subido) + COUNT(pred.id_prediccion) + COUNT(sv.id_vital)) as actividad_total
FROM Usuario u
JOIN Paciente p ON u.id_usuario = p.id_usuario
LEFT JOIN Documento_Subido ds ON u.id_usuario = ds.id_usuario
LEFT JOIN Prediccion pred ON u.id_usuario = pred.id_usuario
LEFT JOIN Signo_Vital sv ON u.id_usuario = sv.id_usuario
GROUP BY u.id_usuario, p.nombre, p.apellido
ORDER BY actividad_total DESC
LIMIT 5;

-- Comentarios de las nuevas vistas
COMMENT ON VIEW vista_predicciones_por_mes IS 'Predicciones generadas por mes para gráficos de líneas';
COMMENT ON VIEW vista_distribucion_enfermedades IS 'Distribución de enfermedades para gráficos de pastel';
COMMENT ON VIEW vista_estado_documentos IS 'Estado de documentos (procesados vs pendientes) para gráficos de barras apiladas';
COMMENT ON VIEW vista_distribucion_demografica IS 'Distribución demográfica por edad y género para gráficos de barras horizontales';
COMMENT ON VIEW vista_crecimiento_acumulado_usuarios IS 'Crecimiento acumulado de usuarios para gráficos de área';
COMMENT ON VIEW vista_top_usuarios_activos IS 'Top 5 usuarios más activos para gráficos de barras verticales';

-- =====================================
-- STORED PROCEDURES: Dashboard KPIs - Indicadores Clave de Rendimiento
-- =====================================

-- SP 1: KPIs principales
CREATE OR REPLACE PROCEDURE sp_dashboard_kpis(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM dashboard_kpis;
END;
$$;

-- SP 2: Usuarios por rol
CREATE OR REPLACE PROCEDURE sp_dashboard_usuarios_por_rol(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM dashboard_usuarios_por_rol;
END;
$$;

-- SP 3: Frecuencia diaria
CREATE OR REPLACE PROCEDURE sp_dashboard_frecuencia_diaria(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM dashboard_frecuencia_diaria;
END;
$$;

-- SP 4: Crecimiento semanal
CREATE OR REPLACE PROCEDURE sp_dashboard_crecimiento_semanal(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM dashboard_crecimiento_semanal;
END;
$$;

-- SP 5: Actividad de usuarios
CREATE OR REPLACE PROCEDURE sp_dashboard_actividad_usuarios(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM dashboard_actividad_usuarios;
END;
$$;

-- SP 6: Resumen ejecutivo
CREATE OR REPLACE PROCEDURE sp_dashboard_resumen_ejecutivo(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM dashboard_resumen_ejecutivo;
END;
$$;

-- =====================================
-- STORED PROCEDURES: Nuevas Gráficas del Dashboard
-- =====================================

-- SP 7: Predicciones por Mes (Líneas)
CREATE OR REPLACE PROCEDURE sp_dashboard_predicciones_por_mes(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM vista_predicciones_por_mes;
END;
$$;

-- SP 8: Distribución de Enfermedades (Pastel)
CREATE OR REPLACE PROCEDURE sp_dashboard_distribucion_enfermedades(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM vista_distribucion_enfermedades;
END;
$$;

-- SP 9: Estado de Documentos (Barras Apiladas)
CREATE OR REPLACE PROCEDURE sp_dashboard_estado_documentos(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM vista_estado_documentos;
END;
$$;

-- SP 10: Distribución Demográfica (Barras Horizontales)
CREATE OR REPLACE PROCEDURE sp_dashboard_distribucion_demografica(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM vista_distribucion_demografica;
END;
$$;

-- SP 11: Crecimiento Acumulado de Usuarios (Área)
CREATE OR REPLACE PROCEDURE sp_dashboard_crecimiento_acumulado_usuarios(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM vista_crecimiento_acumulado_usuarios;
END;
$$;

-- SP 12: Top 5 Usuarios Más Activos (Barras Verticales)
CREATE OR REPLACE PROCEDURE sp_dashboard_top_usuarios_activos(
    INOUT p_result REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_result FOR
    SELECT * FROM vista_top_usuarios_activos;
END;
$$;


-- =====================================
-- Procedimiento: Insertar Signo Vital y alertas automáticas
-- =====================================
CREATE OR REPLACE PROCEDURE insertar_signo_vital(
    p_id_usuario INT,
    p_id_tipo INT,
    p_id_dispositivo INT,
    p_id_postura INT,
    p_valor REAL,
    p_timestamp TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo_nombre VARCHAR(50);
BEGIN
    -- Insertar el registro
    INSERT INTO Signo_Vital(id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp)
    VALUES (p_id_usuario, p_id_tipo, p_id_dispositivo, p_id_postura, p_valor, p_timestamp);

    -- Obtener nombre del tipo de signo vital
    SELECT nombre INTO v_tipo_nombre FROM Tipo_Signo_Vital WHERE id_tipo = p_id_tipo;

    -- Generar alerta si PA alta
    IF v_tipo_nombre = 'BP_sistolica' AND p_valor > 140 THEN
        INSERT INTO Registro_Auditoria(id_usuario, id_entidad, accion, fecha_hora, detalles)
        VALUES (p_id_usuario, 19, 'CREATE', NOW(),
                jsonb_build_object('mensaje', 'PA sistólica alta', 'valor', p_valor));
    END IF;

    -- Actualizar vista de Monitoreo PA (si es necesario)
    -- Como las vistas son dinámicas, PostgreSQL recalcula automáticamente
END;
$$;

-- =====================================
-- Procedimiento: Eliminar registro por PK compuesta (genérico)
-- =====================================
-- Recibe arrays alineados de columnas PK y valores (como texto), y elimina 1 fila.
CREATE OR REPLACE PROCEDURE sp_delete_by_pk_multi(
    p_table_name   TEXT,
    p_pk_columns   TEXT[],
    p_pk_values    TEXT[],
    OUT p_deleted_count INT,
    OUT p_success BOOLEAN,
    OUT p_error TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_where TEXT := '';
    v_i INT;
    v_col TEXT;
    v_col_type TEXT;
BEGIN
    p_deleted_count := 0;
    p_success := FALSE;
    p_error := NULL;

    IF p_pk_columns IS NULL OR p_pk_values IS NULL OR array_length(p_pk_columns,1) IS NULL OR array_length(p_pk_columns,1) <> array_length(p_pk_values,1) THEN
        p_error := 'pk_columns_and_values_must_be_same_size';
        RETURN;
    END IF;

    -- Construir cláusula WHERE tipando cada valor según su tipo real
    FOR v_i IN 1..array_length(p_pk_columns,1) LOOP
        v_col := p_pk_columns[v_i];
        -- tipo de la columna
        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_col_type
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = 'public'
          AND c.relname = p_table_name
          AND a.attname = v_col
          AND a.attnum > 0 AND NOT a.attisdropped
        LIMIT 1;
        IF v_col_type IS NULL THEN
            p_error := format('column_type_not_found_for_%s', v_col);
            RETURN;
        END IF;

        -- concatenar condición
        IF v_where <> '' THEN
            v_where := v_where || ' AND ';
        END IF;
        v_where := v_where || format('%I = $%s::%s', v_col, v_i, v_col_type);
    END LOOP;

    v_sql := format('DELETE FROM %I WHERE %s', p_table_name, v_where);
    -- Incrustar los valores de forma segura ya que no podemos pasar USING dinámico; %L los cita correctamente
    -- v_where ya referencia $1,$2... pero en su lugar construimos con literales tipados arriba
    -- reconstruimos la sentencia final reemplazando $i con %L::tipo en v_where ya construido
    -- Para simplificar, volvemos a construir v_where incluyendo valores ya tipados
    v_where := '';
    FOR v_i IN 1..array_length(p_pk_columns,1) LOOP
        v_col := p_pk_columns[v_i];
        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_col_type
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = 'public'
          AND c.relname = p_table_name
          AND a.attname = v_col
          AND a.attnum > 0 AND NOT a.attisdropped
        LIMIT 1;
        IF v_i > 1 THEN v_where := v_where || ' AND '; END IF;
        v_where := v_where || format('%I = %L::%s', v_col, p_pk_values[v_i], v_col_type);
    END LOOP;
    v_sql := format('DELETE FROM %I WHERE %s', p_table_name, v_where);
    EXECUTE v_sql;

    GET DIAGNOSTICS p_deleted_count = ROW_COUNT;
    p_success := (p_deleted_count = 1);
EXCEPTION WHEN OTHERS THEN
    p_error := SQLERRM;
    p_success := FALSE;
    p_deleted_count := 0;
END;
$$;

-- =====================================
-- Procedimiento: Obtener todas las columnas PK de una tabla
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_primary_key_columns(
    p_schema TEXT,
    p_table_name TEXT,
    OUT p_pk_columns TEXT[]
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT ARRAY(
        SELECT a.attname
        FROM pg_index i
        JOIN pg_class c ON c.oid = i.indrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
        WHERE i.indisprimary = TRUE
          AND n.nspname = p_schema
          AND c.relname = p_table_name
        ORDER BY a.attnum
    ) INTO p_pk_columns;
END;
$$;

-- =====================================
-- Procedimiento: Obtener todas las entidades
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_entidades(
    INOUT p_entidades REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_entidades FOR
        SELECT id_entidad, nombre FROM Entidad ORDER BY nombre;
END;
$$;

-- =====================================
-- Procedimiento: Obtener datos de entidad específica
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_entidad_data(
    p_entidad_name VARCHAR(100),
    INOUT p_datos REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_datos FOR
        EXECUTE 'SELECT * FROM ' || p_entidad_name;
END;
$$;

-- =====================================
-- Procedimiento: Obtener datos de entidad con información de columnas
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_entidad_data_with_columns(
    p_entidad_name VARCHAR(100),
    INOUT p_datos REFCURSOR,
    INOUT p_columnas REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Obtener los datos de la tabla
    OPEN p_datos FOR
        EXECUTE 'SELECT * FROM ' || p_entidad_name;
    
    -- Obtener información de las columnas
    OPEN p_columnas FOR
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = p_entidad_name 
        ORDER BY ordinal_position;
END;
$$;

-- =====================================
-- Procedimiento: Resumen diario de usuario actualizado
-- =====================================
CREATE OR REPLACE PROCEDURE resumen_diario_usuario(
    p_id_usuario INT,
    p_fecha DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE 'Resumen diario para usuario % en fecha %', p_id_usuario, p_fecha;

    FOR rec IN
        SELECT * FROM Dashboard_Completo
        WHERE id_usuario = p_id_usuario AND fecha = p_fecha
    LOOP
        RAISE NOTICE 'BP sistólica: %, BP diastólica: %', rec.BP_sistolica_promedio, rec.BP_diastolica_promedio;
        RAISE NOTICE 'Otros signos promedio: %', rec.otros_signos_promedio;
        RAISE NOTICE 'Laboratorios promedio: %', rec.lab_promedio;
        RAISE NOTICE 'Respuestas estilo de vida: %', rec.total_respuestas;
        RAISE NOTICE 'Respuestas SI: %, Respuestas NO: %', rec.respuestas_si, rec.respuestas_no;
        RAISE NOTICE 'Promedio numérico: %, promedio escala: %', rec.promedio_numero, rec.promedio_escala;
        RAISE NOTICE 'Predicciones probabilidad: %', rec.probabilidad_promedio;
        RAISE NOTICE 'Total medicación: %', rec.total_medicamentos;
        RAISE NOTICE 'Documentos subidos: %, Enfermedades mencionadas: %', rec.total_documentos, rec.total_enfermedades_mencionadas;
    END LOOP;
END;
$$;

-- =====================================
-- Procedimiento: Login de personal autorizado (Administradores y Analistas)
-- =====================================
CREATE OR REPLACE PROCEDURE sp_login_staff(
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    p_ip_address VARCHAR(45),
    OUT p_user_id INTEGER,
    OUT p_user_email VARCHAR(255),
    OUT p_role_id INTEGER,
    OUT p_success BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Inicializar variables de salida
    p_user_id := NULL;
    p_user_email := NULL;
    p_role_id := NULL;
    p_success := FALSE;
    
    -- Buscar usuario, validar contraseña y verificar que sea Administrador o Analista
    SELECT u.id_usuario, u.email, u.id_rol
    INTO p_user_id, p_user_email, p_role_id
    FROM Usuario u
    JOIN Rol r ON r.id_rol = u.id_rol
    WHERE u.email = p_email
      AND u.contraseña_hash = crypt(p_password, u.contraseña_hash)
      AND r.nombre IN ('Administrador', 'Analista');
    
    -- Si se encontró el usuario autorizado, marcar como exitoso
    IF p_user_id IS NOT NULL THEN
        p_success := TRUE;
        
        -- Registrar login exitoso en auditoría
        INSERT INTO Registro_Auditoria (id_usuario, id_entidad, accion, fecha_hora, detalles)
        VALUES (
            p_user_id,
            (SELECT id_entidad FROM Entidad WHERE nombre = 'Usuario'),
            'LOGIN',
            NOW(),
            jsonb_build_object(
                'email', p_email,
                'ip_address', p_ip_address,
                'role', (SELECT nombre FROM Rol WHERE id_rol = p_role_id)
            )
        );
    END IF;
    
END;
$$;

-- =====================================
-- Procedimiento: Obtener datos del usuario autenticado
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_user_data(
    p_user_id INTEGER,
    OUT p_user_email VARCHAR(255),
    OUT p_role_id INTEGER,
    OUT p_role_name VARCHAR(50),
    OUT p_success BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Inicializar variables de salida
    p_user_email := NULL;
    p_role_id := NULL;
    p_role_name := NULL;
    p_success := FALSE;
    
    -- Buscar datos del usuario
    SELECT u.email, u.id_rol, r.nombre
    INTO p_user_email, p_role_id, p_role_name
    FROM Usuario u
    LEFT JOIN Rol r ON r.id_rol = u.id_rol
    WHERE u.id_usuario = p_user_id;
    
    -- Si se encontró el usuario, marcar como exitoso
    IF p_user_email IS NOT NULL THEN
        p_success := TRUE;
    END IF;
    
END;
$$;

-- =====================================
-- Procedimiento: Calcular riesgo de enfermedad para un usuario
-- =====================================
CREATE OR REPLACE PROCEDURE calcular_riesgo_enfermedad(
    p_id_usuario INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    v_riesgo REAL;
BEGIN
    FOR rec IN
        SELECT e.nombre AS enfermedad, AVG(p.probabilidad) AS probabilidad_promedio
        FROM Prediccion p
        JOIN Enfermedad e ON p.id_enfermedad = e.id_enfermedad
        WHERE p.id_usuario = p_id_usuario
        GROUP BY e.nombre
    LOOP
        v_riesgo := rec.probabilidad_promedio;
        RAISE NOTICE 'Usuario %: Riesgo de % = %', p_id_usuario, rec.enfermedad, v_riesgo;
    END LOOP;
END;
$$;

-- =====================================
-- Procedimiento: Obtener series de PA para análisis
-- =====================================
CREATE OR REPLACE PROCEDURE obtener_pa_usuario(
    p_id_usuario INT,
    p_inicio TIMESTAMP,
    p_fin TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT 
            sv.timestamp,
            t.nombre AS tipo,
            sv.valor,
            sv.id_postura,
            sv.id_dispositivo
        FROM Signo_Vital sv
        JOIN Tipo_Signo_Vital t ON sv.id_tipo = t.id_tipo
        WHERE sv.id_usuario = p_id_usuario
          AND sv.timestamp BETWEEN p_inicio AND p_fin
          AND t.nombre IN ('BP_sistolica','BP_diastolica')
        ORDER BY sv.timestamp
    LOOP
        RAISE NOTICE '[%] %: % (Postura: %, Dispositivo: %)', rec.timestamp, rec.tipo, rec.valor, rec.id_postura, rec.id_dispositivo;
    END LOOP;
END;
$$;

-- =====================================
-- Procedimiento: Eliminar registro por PK (genérico)
-- =====================================
-- Elimina un registro de una tabla dada usando su columna PK y valor.
-- Usa SQL dinámico seguro con quote-identifiers y tipado correcto del valor.
CREATE OR REPLACE PROCEDURE sp_delete_by_pk(
    p_table_name TEXT,
    p_pk_column  TEXT,
    p_pk_value   TEXT,
    OUT p_deleted_count INT,
    OUT p_success BOOLEAN,
    OUT p_error TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_col_type TEXT;
    v_sql TEXT;
BEGIN
    p_deleted_count := 0;
    p_success := FALSE;
    p_error := NULL;

    -- Obtener tipo de dato de la columna para castear el valor correctamente
    SELECT format_type(a.atttypid, a.atttypmod)
    INTO v_col_type
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_attribute a ON a.attrelid = c.oid
    WHERE n.nspname = 'public'
      AND c.relname = p_table_name
      AND a.attname = p_pk_column
      AND a.attnum > 0
      AND NOT a.attisdropped
    LIMIT 1;

    IF v_col_type IS NULL THEN
        p_error := 'pk_column_not_found';
        RETURN;
    END IF;

    -- Construir DELETE dinámico seguro
    v_sql := format('DELETE FROM %I WHERE %I = $1::%s', p_table_name, p_pk_column, v_col_type);
    EXECUTE v_sql USING p_pk_value;

    GET DIAGNOSTICS p_deleted_count = ROW_COUNT;
    p_success := (p_deleted_count > 0);
EXCEPTION WHEN OTHERS THEN
    p_error := SQLERRM;
    p_success := FALSE;
    p_deleted_count := 0;
END;
$$;

-- =====================================
-- Procedimiento: Verificar existencia de tabla
-- =====================================
CREATE OR REPLACE PROCEDURE sp_table_exists(
    p_schema TEXT,
    p_table_name TEXT,
    OUT p_exists BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = p_schema
          AND table_name = p_table_name
    ) INTO p_exists;
END;
$$;

-- =====================================
-- Procedimiento: Obtener columna PK de una tabla
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_primary_key_column(
    p_schema TEXT,
    p_table_name TEXT,
    OUT p_pk_column TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT a.attname AS pk_column
    INTO p_pk_column
    FROM pg_index i
    JOIN pg_class c ON c.oid = i.indrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
    WHERE i.indisprimary = TRUE
      AND n.nspname = p_schema
      AND c.relname = p_table_name
    LIMIT 1;
END;
$$;

-- =====================================
-- Procedimiento: Actualizar registro por PK (genérico)
-- =====================================
-- Actualiza un registro de una tabla dada usando su columna PK y valor.
-- p_columns y p_values deben tener el mismo tamaño y contendrán los pares columna=valor a actualizar.
CREATE OR REPLACE PROCEDURE sp_update_by_pk(
    p_table_name   TEXT,
    p_pk_column    TEXT,
    p_pk_value     TEXT,
    p_columns      TEXT[],
    p_values       TEXT[],
    OUT p_updated_count INT,
    OUT p_success  BOOLEAN,
    OUT p_error    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_pk_type TEXT;
    v_sql TEXT;
    v_set TEXT := '';
    v_where TEXT;
    v_i INT;
    v_col TEXT;
    v_col_type TEXT;
BEGIN
    p_updated_count := 0;
    p_success := FALSE;
    p_error := NULL;

    IF p_columns IS NULL OR p_values IS NULL OR array_length(p_columns,1) IS NULL OR array_length(p_columns,1) <> array_length(p_values,1) THEN
        p_error := 'columns_and_values_must_be_same_size';
        RETURN;
    END IF;

    IF array_length(p_columns,1) = 0 THEN
        p_error := 'no_columns_to_update';
        RETURN;
    END IF;

    -- Tipo de PK
    SELECT format_type(a.atttypid, a.atttypmod)
    INTO v_pk_type
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_attribute a ON a.attrelid = c.oid
    WHERE n.nspname = 'public'
      AND c.relname = p_table_name
      AND a.attname = p_pk_column
      AND a.attnum > 0 AND NOT a.attisdropped
    LIMIT 1;
    IF v_pk_type IS NULL THEN
        p_error := 'pk_column_not_found';
        RETURN;
    END IF;

    -- Construir SET tipando cada valor según su tipo real
    FOR v_i IN 1..array_length(p_columns,1) LOOP
        v_col := p_columns[v_i];
        -- Ignorar si intenta cambiar la PK
        IF v_col = p_pk_column THEN CONTINUE; END IF;

        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_col_type
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = 'public'
          AND c.relname = p_table_name
          AND a.attname = v_col
          AND a.attnum > 0 AND NOT a.attisdropped
        LIMIT 1;
        IF v_col_type IS NULL THEN
            p_error := format('column_type_not_found_for_%s', v_col);
            RETURN;
        END IF;

        IF v_set <> '' THEN v_set := v_set || ', '; END IF;
        v_set := v_set || format('%I = %L::%s', v_col, p_values[v_i], v_col_type);
    END LOOP;

    IF v_set = '' THEN
        p_error := 'no_updatable_fields';
        RETURN;
    END IF;

    v_where := format('%I = %L::%s', p_pk_column, p_pk_value, v_pk_type);
    v_sql := format('UPDATE %I SET %s WHERE %s', p_table_name, v_set, v_where);
    EXECUTE v_sql;

    GET DIAGNOSTICS p_updated_count = ROW_COUNT;
    p_success := (p_updated_count = 1);
EXCEPTION WHEN OTHERS THEN
    p_error := SQLERRM;
    p_success := FALSE;
    p_updated_count := 0;
END;
$$;

-- =====================================
-- Procedimiento: Actualizar registro por PK compuesta (genérico)
-- =====================================
-- Recibe arrays alineados de columnas PK y valores, más columnas/valores a actualizar.
CREATE OR REPLACE PROCEDURE sp_update_by_pk_multi(
    p_table_name   TEXT,
    p_pk_columns   TEXT[],
    p_pk_values    TEXT[],
    p_columns      TEXT[],
    p_values       TEXT[],
    OUT p_updated_count INT,
    OUT p_success  BOOLEAN,
    OUT p_error    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_set TEXT := '';
    v_where TEXT := '';
    v_i INT;
    v_col TEXT;
    v_col_type TEXT;
    v_pk_type TEXT;
BEGIN
    p_updated_count := 0;
    p_success := FALSE;
    p_error := NULL;

    IF p_pk_columns IS NULL OR p_pk_values IS NULL OR array_length(p_pk_columns,1) IS NULL OR array_length(p_pk_columns,1) <> array_length(p_pk_values,1) THEN
        p_error := 'pk_columns_and_values_must_be_same_size';
        RETURN;
    END IF;
    IF p_columns IS NULL OR p_values IS NULL OR array_length(p_columns,1) IS NULL OR array_length(p_columns,1) <> array_length(p_values,1) THEN
        p_error := 'columns_and_values_must_be_same_size';
        RETURN;
    END IF;
    IF array_length(p_columns,1) = 0 THEN
        p_error := 'no_columns_to_update';
        RETURN;
    END IF;

    -- SET
    FOR v_i IN 1..array_length(p_columns,1) LOOP
        v_col := p_columns[v_i];
        -- No permitir modificar cualquier columna PK
        IF v_col = ANY(p_pk_columns) THEN CONTINUE; END IF;

        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_col_type
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = 'public'
          AND c.relname = p_table_name
          AND a.attname = v_col
          AND a.attnum > 0 AND NOT a.attisdropped
        LIMIT 1;
        IF v_col_type IS NULL THEN
            p_error := format('column_type_not_found_for_%s', v_col);
            RETURN;
        END IF;

        IF v_set <> '' THEN v_set := v_set || ', '; END IF;
        v_set := v_set || format('%I = %L::%s', v_col, p_values[v_i], v_col_type);
    END LOOP;

    IF v_set = '' THEN
        p_error := 'no_updatable_fields';
        RETURN;
    END IF;

    -- WHERE compuesto
    FOR v_i IN 1..array_length(p_pk_columns,1) LOOP
        v_col := p_pk_columns[v_i];
        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_pk_type
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = 'public'
          AND c.relname = p_table_name
          AND a.attname = v_col
          AND a.attnum > 0 AND NOT a.attisdropped
        LIMIT 1;
        IF v_i > 1 THEN v_where := v_where || ' AND '; END IF;
        v_where := v_where || format('%I = %L::%s', v_col, p_pk_values[v_i], v_pk_type);
    END LOOP;

    v_sql := format('UPDATE %I SET %s WHERE %s', p_table_name, v_set, v_where);
    EXECUTE v_sql;

    GET DIAGNOSTICS p_updated_count = ROW_COUNT;
    p_success := (p_updated_count = 1);
EXCEPTION WHEN OTHERS THEN
    p_error := SQLERRM;
    p_success := FALSE;
    p_updated_count := 0;
END;
$$;

-- =====================================
-- Procedimiento: Obtener columnas de una tabla (ordenadas)
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_table_columns(
    p_schema TEXT,
    p_table_name TEXT,
    INOUT p_columns REFCURSOR
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_columns FOR
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = p_schema
          AND table_name = p_table_name
        ORDER BY ordinal_position;
END;
$$;

-- =====================================
-- Procedimiento: Insertar registro de auditoría
-- =====================================
CREATE OR REPLACE PROCEDURE sp_insert_audit_record(
    p_id_usuario INTEGER,
    p_id_entidad INTEGER,
    p_accion VARCHAR(20),
    p_detalles JSONB DEFAULT NULL
) AS $$
BEGIN
    INSERT INTO Registro_Auditoria (id_usuario, id_entidad, accion, detalles)
    VALUES (p_id_usuario, p_id_entidad, p_accion, p_detalles);
END;
$$ LANGUAGE plpgsql;

-- Stored procedure to get audit records
CREATE OR REPLACE PROCEDURE sp_get_audit_records(
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0,
    p_user_id INTEGER DEFAULT NULL,
    p_entity_id INTEGER DEFAULT NULL,
    p_action VARCHAR(20) DEFAULT NULL
) RETURNS TABLE (
    id_registro INTEGER,
    id_usuario INTEGER,
    id_entidad INTEGER,
    accion VARCHAR(20),
    fecha_hora TIMESTAMP,
    detalles JSONB,
    usuario_email VARCHAR(255),
    entidad_nombre VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ra.id_registro,
        ra.id_usuario,
        ra.id_entidad,
        ra.accion,
        ra.fecha_hora,
        ra.detalles,
        u.email as usuario_email,
        e.nombre as entidad_nombre
    FROM Registro_Auditoria ra
    LEFT JOIN Usuario u ON ra.id_usuario = u.id_usuario
    LEFT JOIN Entidad e ON ra.id_entidad = e.id_entidad
    WHERE 
        (p_user_id IS NULL OR ra.id_usuario = p_user_id)
        AND (p_entity_id IS NULL OR ra.id_entidad = p_entity_id)
        AND (p_action IS NULL OR ra.accion = p_action)
    ORDER BY ra.fecha_hora DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================
-- Procedimiento: Obtener estadísticas de auditoría
-- =====================================
CREATE OR REPLACE PROCEDURE sp_get_audit_stats(
    p_days INTEGER DEFAULT 30
) RETURNS TABLE (
    total_actions BIGINT,
    login_count BIGINT,
    create_count BIGINT,
    read_count BIGINT,
    update_count BIGINT,
    delete_count BIGINT,
    most_active_user VARCHAR(255),
    most_accessed_entity VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    WITH stats AS (
        SELECT 
            COUNT(*) as total,
            COUNT(*) FILTER (WHERE accion = 'LOGIN') as logins,
            COUNT(*) FILTER (WHERE accion = 'CREATE') as creates,
            COUNT(*) FILTER (WHERE accion = 'READ') as reads,
            COUNT(*) FILTER (WHERE accion = 'UPDATE') as updates,
            COUNT(*) FILTER (WHERE accion = 'DELETE') as deletes
        FROM Registro_Auditoria 
        WHERE fecha_hora >= NOW() - INTERVAL '1 day' * p_days
    ),
    user_stats AS (
        SELECT u.email, COUNT(*) as action_count
        FROM Registro_Auditoria ra
        JOIN Usuario u ON ra.id_usuario = u.id_usuario
        WHERE ra.fecha_hora >= NOW() - INTERVAL '1 day' * p_days
        GROUP BY u.id_usuario, u.email
        ORDER BY action_count DESC
        LIMIT 1
    ),
    entity_stats AS (
        SELECT e.nombre, COUNT(*) as access_count
        FROM Registro_Auditoria ra
        JOIN Entidad e ON ra.id_entidad = e.id_entidad
        WHERE ra.fecha_hora >= NOW() - INTERVAL '1 day' * p_days
        GROUP BY e.id_entidad, e.nombre
        ORDER BY access_count DESC
        LIMIT 1
    )
    SELECT 
        s.total,
        s.logins,
        s.creates,
        s.reads,
        s.updates,
        s.deletes,
        us.email,
        es.nombre
    FROM stats s
    CROSS JOIN user_stats us
    CROSS JOIN entity_stats es;
END;
$$ LANGUAGE plpgsql;

-- Stored procedure to get entity ID by name
CREATE OR REPLACE PROCEDURE sp_get_entity_id_by_name(
    p_entity_name VARCHAR(100),
    OUT p_entity_id INTEGER
) AS $$
BEGIN
    SELECT id_entidad INTO p_entity_id
    FROM Entidad 
    WHERE nombre = p_entity_name;
END;
$$ LANGUAGE plpgsql;

-- =====================================
-- Procedimiento: Insertar registro
-- =====================================
CREATE OR REPLACE PROCEDURE sp_insert_record(
    p_table_name   TEXT,
    p_columns      TEXT[],
    p_values       TEXT[],
    OUT p_inserted_id INT,
    OUT p_success  BOOLEAN,
    OUT p_error    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_columns_str TEXT := '';
    v_values_str TEXT := '';
    v_i INT;
    v_col TEXT;
    v_col_type TEXT;
    v_pk_column TEXT;
    v_pk_type TEXT;
BEGIN
    p_inserted_id := NULL;
    p_success := FALSE;
    p_error := NULL;

    -- Validar parámetros
    IF p_columns IS NULL OR p_values IS NULL OR array_length(p_columns,1) IS NULL OR array_length(p_columns,1) <> array_length(p_values,1) THEN
        p_error := 'columns_and_values_must_be_same_size';
        RETURN;
    END IF;

    IF array_length(p_columns,1) = 0 THEN
        p_error := 'no_columns_to_insert';
        RETURN;
    END IF;

    -- Verificar que la tabla existe
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relname = p_table_name
    ) THEN
        p_error := 'table_not_found';
        RETURN;
    END IF;

    -- Construir la consulta INSERT
    FOR v_i IN 1..array_length(p_columns,1) LOOP
        v_col := p_columns[v_i];
        
        -- Verificar que la columna existe en la tabla
        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_col_type
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = 'public'
          AND c.relname = p_table_name
          AND a.attname = v_col
          AND a.attnum > 0 AND NOT a.attisdropped
        LIMIT 1;
        
        IF v_col_type IS NULL THEN
            p_error := 'column_not_found: ' || v_col;
            RETURN;
        END IF;

        -- Agregar columna y valor
        IF v_i > 1 THEN
            v_columns_str := v_columns_str || ', ';
            v_values_str := v_values_str || ', ';
        END IF;
        
        v_columns_str := v_columns_str || quote_ident(v_col);
        
        -- Manejar diferentes tipos de datos
        IF v_col_type IN ('text', 'varchar', 'character varying', 'char', 'character') THEN
            v_values_str := v_values_str || quote_literal(p_values[v_i]);
        ELSIF v_col_type IN ('integer', 'int4', 'bigint', 'int8', 'smallint', 'int2') THEN
            v_values_str := v_values_str || COALESCE(p_values[v_i], 'NULL');
        ELSIF v_col_type IN ('boolean', 'bool') THEN
            v_values_str := v_values_str || COALESCE(p_values[v_i], 'NULL');
        ELSIF v_col_type IN ('timestamp', 'timestamptz', 'date', 'time') THEN
            v_values_str := v_values_str || quote_literal(p_values[v_i]);
        ELSIF v_col_type IN ('numeric', 'decimal', 'real', 'double precision', 'float4', 'float8') THEN
            v_values_str := v_values_str || COALESCE(p_values[v_i], 'NULL');
        ELSE
            v_values_str := v_values_str || quote_literal(p_values[v_i]);
        END IF;
    END LOOP;

    -- Construir la consulta SQL final
    v_sql := 'INSERT INTO ' || quote_ident(p_table_name) || ' (' || v_columns_str || ') VALUES (' || v_values_str || ')';
    
    -- Si la tabla tiene una clave primaria simple, intentar obtener el ID insertado
    SELECT a.attname
    INTO v_pk_column
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_attribute a ON a.attrelid = c.oid
    JOIN pg_constraint pk ON pk.conrelid = c.oid AND pk.contype = 'p'
    WHERE n.nspname = 'public'
      AND c.relname = p_table_name
      AND a.attnum = ANY(pk.conkey)
      AND pk.conkey[1] = a.attnum
    LIMIT 1;

    -- Si hay una PK simple, agregar RETURNING
    IF v_pk_column IS NOT NULL THEN
        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_pk_type
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = 'public'
          AND c.relname = p_table_name
          AND a.attname = v_pk_column
          AND a.attnum > 0 AND NOT a.attisdropped
        LIMIT 1;
        
        IF v_pk_type IN ('integer', 'int4', 'bigint', 'int8', 'smallint', 'int2') THEN
            v_sql := v_sql || ' RETURNING ' || quote_ident(v_pk_column);
        END IF;
    END IF;

    -- Ejecutar la inserción
    BEGIN
        IF v_pk_column IS NOT NULL AND v_pk_type IN ('integer', 'int4', 'bigint', 'int8', 'smallint', 'int2') THEN
            EXECUTE v_sql INTO p_inserted_id;
        ELSE
            EXECUTE v_sql;
            p_inserted_id := NULL;
        END IF;
        
        p_success := TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            p_error := SQLERRM;
            p_success := FALSE;
    END;
END;
$$;


-- =====================================
-- SCRIPT DE INSERCIÓN DE DATOS BÁSICOS
-- Solo con los datos específicos proporcionados
-- =====================================

-- Conectarse a la base de datos predicthealth
\c predicthealth

-- =====================================
-- INSERTAR ROLES
-- =====================================
INSERT INTO Rol (id_rol, nombre) VALUES 
(1, 'Paciente'),
(2, 'Doctor'),
(3, 'Administrador'),
(4, 'Analista');

-- =====================================
-- INSERTAR USUARIO DE PRUEBA
-- =====================================
INSERT INTO Usuario (id_rol, email, contraseña_hash) 
VALUES (3, 'admin@admin.com', crypt('admin', gen_salt('bf')))
ON CONFLICT (email) DO NOTHING;

-- =====================================
-- INSERTAR FUENTES GPS
-- =====================================
INSERT INTO Fuente_GPS (id_fuente, nombre) VALUES 
(1, 'GPS'),
(2, 'Wi-Fi'),
(3, 'Celular / GSM'),
(4, 'Bluetooth / Beacons'),
(5, 'Manual / Usuario');


-- =====================================
-- INSERTAR ENFERMEDADES DE EJEMPLO
-- =====================================
INSERT INTO Enfermedad (nombre) VALUES ('Diabetes');
INSERT INTO Enfermedad (nombre) VALUES ('Hipertensión');

-- =====================================
-- INSERTAR RECOMENDACIONES PARA DIABETES (BASADAS EN MAYO CLINIC)
-- =====================================
INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Comprométete a controlar tu diabetes',
    'Los miembros de tu equipo de atención de la diabetes pueden ayudarte a aprender los conceptos básicos de los cuidados para la diabetes y ofrecerte apoyo. Pero depende de ti tratar tu afección. Infórmate sobre todo lo que puedas acerca de la diabetes. Haz que la alimentación saludable y la actividad física sean parte de tu rutina diaria. Mantén un peso saludable. Mídete la glucosa en la sangre y sigue las indicaciones de tu proveedor de atención médica para controlar el nivel.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'No fumes',
    'Evita fumar o deja de fumar si lo haces. Fumar aumenta el riesgo de múltiples complicaciones de salud, incluyendo: reducción del flujo sanguíneo, enfermedades cardíacas, accidente cerebrovascular, enfermedades oculares, daño en los nervios, enfermedad renal y muerte prematura.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Mantén tu presión arterial y tu colesterol bajo control',
    'Al igual que la diabetes, la presión arterial alta (hipertensión arterial) puede dañar los vasos sanguíneos. El colesterol alto también es una preocupación, ya que el daño resultante suele ser peor y desarrollarse más rápido cuando se tiene diabetes. Cuando estos afecciones se combinan, pueden provocar un ataque cardíaco, un accidente cerebrovascular u otras afecciones que pueden poner en riesgo la vida.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Programa exámenes físicos y oculares regulares',
    'Programa de dos a cuatro consultas de control de la diabetes al año, además de los exámenes físicos y oculares regulares. Durante el examen físico, tu proveedor de atención médica te preguntará sobre tu alimentación y nivel de actividad, y buscará cualquier complicación relacionada con la diabetes, incluidos signos de daño renal, daño nervioso y enfermedad cardíaca.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Mantén al día tus vacunas',
    'La diabetes aumenta el riesgo de contraer ciertas enfermedades. Las vacunas de rutina pueden ayudar a prevenirlas. Pregúntale a tu proveedor de atención médica sobre las vacunas contra la influenza, la neumonía, la hepatitis B, el tétanos, la difteria y la tos ferina (Tdap).'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Cuida tus dientes',
    'La diabetes puede hacer que seas propenso a las infecciones de las encías. Cepíllate los dientes al menos dos veces al día con un cepillo de dientes de cerdas suaves, usa hilo dental una vez al día y programa exámenes dentales al menos dos veces al año. Consulta a tu dentista de inmediato si tus encías sangran o se ven rojas o hinchadas.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Presta atención a tus pies',
    'La diabetes puede dañar los nervios de los pies y reducir el flujo sanguíneo a los pies. Si no se tratan, los cortes y las ampollas pueden provocar infecciones graves. Para prevenir problemas en los pies: lávate los pies diariamente con agua tibia, sécalos suavemente, especialmente entre los dedos, y humecta los pies y los tobillos con loción o vaselina.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Considera tomar una aspirina diaria',
    'Si tienes diabetes y otros factores de riesgo cardiovascular, como fumar o hipertensión arterial, tu proveedor de atención médica puede recomendarte una terapia con aspirina en dosis bajas para ayudar a reducir el riesgo de ataque cardíaco y accidente cerebrovascular.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Si bebes alcohol, hazlo de manera responsable',
    'El alcohol puede afectar tu salud de múltiples maneras. Si decides beber, hazlo solo con moderación y siempre con una comida. El consumo excesivo de alcohol puede aumentar el riesgo de problemas de salud y complicaciones médicas.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Toma en serio el estrés',
    'El estrés prolongado puede afectar negativamente tu salud y bienestar general. Las hormonas del estrés pueden interferir con el funcionamiento normal del cuerpo y aumentar el riesgo de problemas de salud. Establece límites, prioriza tus tareas, aprende técnicas de relajación y duerme lo suficiente.'
);

-- =====================================
-- INSERTAR RECOMENDACIONES PARA HIPERTENSIÓN (BASADAS EN MAYO CLINIC)
-- =====================================
INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Baja el sobrepeso y cuida tu silueta',
    'La presión arterial suele subir cuando se aumenta de peso. Tener sobrepeso también puede causar una interrupción de la respiración al dormir, una afección que se llama apnea del sueño. La apnea del sueño además eleva la presión arterial. Una de las mejores formas de controlar la presión arterial es bajar de peso. Si eres una persona con sobrepeso u obesidad, bajar incluso una pequeña cantidad de peso puede ayudarte a reducir la presión arterial.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Haz ejercicio regularmente',
    'Si se practica con regularidad, la actividad aeróbica puede reducir la presión arterial alta aproximadamente de 5 mm Hg a 8 mm Hg. Es importante seguir haciendo ejercicio para evitar que la presión arterial vuelva a subir. Como meta general, procura hacer al menos 30 minutos de actividad física moderada todos los días.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Sigue una dieta saludable',
    'Comer una dieta rica en granos integrales, frutas, verduras y productos lácteos bajos en grasa y que reduzca las grasas saturadas y el colesterol puede reducir la presión arterial hasta 11 mm Hg. Este plan de alimentación se conoce como la dieta DASH (Enfoques Alimentarios para Detener la Hipertensión).'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Reduce el sodio en tu dieta',
    'Incluso una pequeña reducción del sodio en tu dieta puede mejorar la salud del corazón y reducir la presión arterial aproximadamente de 5 mm Hg a 6 mm Hg. El efecto de la ingesta de sodio en la presión arterial varía entre grupos de personas. En general, limita el sodio a 2,300 miligramos (mg) al día o menos.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Reduce el consumo de cafeína',
    'El papel que desempeña la cafeína en la presión arterial sigue siendo discutido. La cafeína puede elevar la presión arterial hasta 10 mm Hg en personas que rara vez la consumen. Pero las personas que beben café regularmente pueden experimentar poco o ningún efecto en la presión arterial.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Monitorea tu presión arterial en casa y ve al médico con regularidad',
    'El monitoreo en el hogar puede ayudarte a controlar tu presión arterial, asegurarte de que los cambios en tu estilo de vida funcionen y alertarte a ti y a tu médico sobre posibles complicaciones de salud. Los monitores de presión arterial están disponibles ampliamente y sin receta médica.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Busca apoyo',
    'La familia y los amigos comprensivos pueden ayudar a mejorar tu salud. Pueden alentarte a cuidarte, llevarte al consultorio del médico o embarcarse en un programa de ejercicios contigo para mantener tu presión arterial baja. Si encuentras que necesitas apoyo más allá de tu familia y amigos, considera unirte a un grupo de apoyo.'
);

-- =====================================
-- INSERTAR RELACIONES ENTRE DIABETES Y RECOMENDACIONES
-- =====================================
INSERT INTO Enfermedad_Recomendacion (id_enfermedad, id_recomendacion) 
SELECT e.id_enfermedad, r.id_recomendacion 
FROM Enfermedad e, Recomendacion r 
WHERE e.nombre = 'Diabetes' 
AND r.titulo IN (
    'Comprométete a controlar tu diabetes',
    'No fumes',
    'Mantén tu presión arterial y tu colesterol bajo control',
    'Programa exámenes físicos y oculares regulares',
    'Mantén al día tus vacunas',
    'Cuida tus dientes',
    'Presta atención a tus pies',
    'Considera tomar una aspirina diaria',
    'Si bebes alcohol, hazlo de manera responsable',
    'Toma en serio el estrés'
);

-- =====================================
-- INSERTAR RELACIONES ENTRE HIPERTENSIÓN Y RECOMENDACIONES ÚNICAS
-- =====================================
INSERT INTO Enfermedad_Recomendacion (id_enfermedad, id_recomendacion) 
SELECT e.id_enfermedad, r.id_recomendacion 
FROM Enfermedad e, Recomendacion r 
WHERE e.nombre = 'Hipertensión' 
AND r.titulo IN (
    'Baja el sobrepeso y cuida tu silueta',
    'Haz ejercicio regularmente',
    'Sigue una dieta saludable',
    'Reduce el sodio en tu dieta',
    'Reduce el consumo de cafeína',
    'Monitorea tu presión arterial en casa y ve al médico con regularidad',
    'Busca apoyo'
);

-- =====================================
-- INSERTAR RELACIONES ENTRE HIPERTENSIÓN Y RECOMENDACIONES SIMILARES (QUE YA EXISTEN PARA DIABETES)
-- =====================================
INSERT INTO Enfermedad_Recomendacion (id_enfermedad, id_recomendacion) 
SELECT e.id_enfermedad, r.id_recomendacion 
FROM Enfermedad e, Recomendacion r 
WHERE e.nombre = 'Hipertensión' 
AND r.titulo IN (
    'No fumes',
    'Si bebes alcohol, hazlo de manera responsable',
    'Toma en serio el estrés'
);

-- =====================================
-- INSERTAR TIPOS DE DOCUMENTOS
-- =====================================
INSERT INTO Documento (nombre) VALUES ('Hemoglobina Glicada (HbA1c)');
INSERT INTO Documento (nombre) VALUES ('Curva de Tolerancia a la Glucosa');
INSERT INTO Documento (nombre) VALUES ('Perfil Lipídico');
INSERT INTO Documento (nombre) VALUES ('Panel Metabólico');
INSERT INTO Documento (nombre) VALUES ('Registros de Monitoreo de Presión Arterial (PA)');
INSERT INTO Documento (nombre) VALUES ('Consulta');

-- =====================================
-- INSERTAR ENTIDADES DE LA BASE DE DATOS
-- =====================================
INSERT INTO Entidad (nombre) VALUES ('Paciente');
INSERT INTO Entidad (nombre) VALUES ('Registro_Auditoria');
INSERT INTO Entidad (nombre) VALUES ('Historial_Medico');
INSERT INTO Entidad (nombre) VALUES ('Resultado_Lab');
INSERT INTO Entidad (nombre) VALUES ('Usuario');
INSERT INTO Entidad (nombre) VALUES ('Rol');
INSERT INTO Entidad (nombre) VALUES ('Refresh_Token');
INSERT INTO Entidad (nombre) VALUES ('Fuente_GPS');
INSERT INTO Entidad (nombre) VALUES ('Registros_GPS');
INSERT INTO Entidad (nombre) VALUES ('Unidad');
INSERT INTO Entidad (nombre) VALUES ('Tipo_Medicion');
INSERT INTO Entidad (nombre) VALUES ('Pregunta');
INSERT INTO Entidad (nombre) VALUES ('Respuesta_Estilo_Vida');
INSERT INTO Entidad (nombre) VALUES ('Analito');
INSERT INTO Entidad (nombre) VALUES ('Tipo_Signo_Vital');
INSERT INTO Entidad (nombre) VALUES ('Postura');
INSERT INTO Entidad (nombre) VALUES ('Dispositivo');
INSERT INTO Entidad (nombre) VALUES ('Signo_Vital');
INSERT INTO Entidad (nombre) VALUES ('Enfermedad');
INSERT INTO Entidad (nombre) VALUES ('Modelo');
INSERT INTO Entidad (nombre) VALUES ('Prediccion');
INSERT INTO Entidad (nombre) VALUES ('Recomendacion');
INSERT INTO Entidad (nombre) VALUES ('Documento');
INSERT INTO Entidad (nombre) VALUES ('Documento_Subido');
INSERT INTO Entidad (nombre) VALUES ('Consulta');
INSERT INTO Entidad (nombre) VALUES ('Extracciones_Nlp');
INSERT INTO Entidad (nombre) VALUES ('Historial_Enfermedad');
INSERT INTO Entidad (nombre) VALUES ('Medicamento');
INSERT INTO Entidad (nombre) VALUES ('Historial_Medicamento');
INSERT INTO Entidad (nombre) VALUES ('Enfermedad_Recomendacion');
INSERT INTO Entidad (nombre) VALUES ('Documento_Enfermedad');
INSERT INTO Entidad (nombre) VALUES ('Entidad');

-- =====================================
-- INSERTAR UNIDADES
-- =====================================
INSERT INTO Unidad (unidad) VALUES ('%');
INSERT INTO Unidad (unidad) VALUES ('mg/dL');
INSERT INTO Unidad (unidad) VALUES ('mmHg');
INSERT INTO Unidad (unidad) VALUES ('bpm');
INSERT INTO Unidad (unidad) VALUES ('BOOLEAN');
INSERT INTO Unidad (unidad) VALUES ('si/no');
INSERT INTO Unidad (unidad) VALUES ('número');
INSERT INTO Unidad (unidad) VALUES ('escala');
INSERT INTO Unidad (unidad) VALUES ('texto');

-- =====================================
-- INSERTAR TIPOS DE SIGNOS VITALES
-- =====================================
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (3, 'BP_sistolica');
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (3, 'BP_diastolica');
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (4, 'HR');
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (1, 'SpO2');

-- =====================================
-- INSERTAR CONSULTAS
-- =====================================
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('diabetes_confirmada', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('hipertension_confirmada', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_metformina', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_insulina', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_losartan', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_amlodipino', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('complicacion_retinopatia', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('complicacion_neuropatia', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('complicacion_nefropatia', 5);

-- =====================================
-- INSERTAR POSTURAS
-- =====================================
INSERT INTO Postura (nombre) VALUES ('Sentado');

-- =====================================
-- INSERTAR ANALITOS
-- =====================================
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('HBA1C', 1, 'Hemoglobina Glicada', '4–6');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('GLU', 2, 'Glucosa en ayunas', '70–110');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('LDL', 2, 'Colesterol LDL', '<130');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('HDL', 2, 'Colesterol HDL', '>40');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('TRIG', 2, 'Triglicéridos', '<150');

-- =====================================
-- INSERTAR DISPOSITIVOS
-- =====================================
INSERT INTO Dispositivo (nombre) VALUES ('Tensiómetro Omron');
INSERT INTO Dispositivo (nombre) VALUES ('Pulsera Fitbit');

-- =====================================
-- INSERTAR TIPOS DE MEDICIÓN
-- =====================================
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('colesterol', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('colesterol alto', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('bmi', 7);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('presión arterial', 9);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('acv', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('problemas_corazon', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('salud general', 9);

-- =====================================
-- INSERTAR MEDICAMENTOS
-- =====================================
INSERT INTO Medicamento (nombre) VALUES ('Ninguna');
INSERT INTO Medicamento (nombre) VALUES ('Otro');
INSERT INTO Medicamento (nombre) VALUES ('Beta Blocker');
INSERT INTO Medicamento (nombre) VALUES ('Diurético');
INSERT INTO Medicamento (nombre) VALUES ('ACE Inhibitor');

-- =====================================
-- INSERTAR PREGUNTAS
-- =====================================
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Consume frutas diariamente?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Consume verduras diariamente?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Cuánta sal consumes diariamente (en gramos)?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Fuma actualmente?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Consume alcohol en exceso?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Tiene dificultades para caminar o desplazarse sin ayuda?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Cuántas horas duermes cada día en promedio?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Nivel de estrés actual (0–10)');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Número de días en los últimos 30 en que la salud mental fue mala');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (8, 'Cuál es tu nivel de actividad física?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Realiza actividad física al menos 3 veces por semana?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Número de días en los últimos 30 en que la salud física fue mala');
-- =====================================
-- INSERTAR RELACIONES DOCUMENTO-ENFERMEDAD
-- =====================================
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (1, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (2, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (3, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (3, 2);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (4, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (4, 2);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (5, 2);

-- Comandos SQL generados automáticamente del dataset CDC Diabetes
-- Compatible con init_new.sql

-- Insertar datos de usuarios del dataset CDC
-- Usuario 1
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_1@cdc-diabetes.com', 'pbkdf2:sha256:1000000$KI0ZQrdNc8sJRiLv$c3dac558034085d42e8372786df9805122803f2ed6bc7ac6575d270ac0b61f35');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_1', 'CDC_1', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_1@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 2
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_2@cdc-diabetes.com', 'pbkdf2:sha256:1000000$df4Z0SWiUEGnRV0J$b02e860117ed033cbe2ce562b54dcf01a128188fb4b6db3cbcdadbac9d64be5c');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_2', 'CDC_2', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_2@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 3
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_3@cdc-diabetes.com', 'pbkdf2:sha256:1000000$038MouvfqkprEC0a$608dde0739717e6dcb067fd2c4d018685a60eae202fa1eeb5d6be3e97c35fae9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_3', 'CDC_3', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_3@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 4
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_4@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Q7CBtcsEbhwudjcZ$38960af08e07e8e1efccc74f7df195f7d2036c6ba5fced639b2176d44a6c65b2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_4', 'CDC_4', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_4@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 5
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_5@cdc-diabetes.com', 'pbkdf2:sha256:1000000$x13nrwgb3Zg81CYK$f3f7f8f4f97d9f211741904454e6167ce9af58a96ae96a3b62e2e64f3b65c501');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_5', 'CDC_5', '1999-01-01', 'F'
FROM Usuario 
WHERE email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_5@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 6
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_6@cdc-diabetes.com', 'pbkdf2:sha256:1000000$La0HZWFLJjo7a8vs$efe8f2618c32b37e963e7d462d21bb07aa739b291b1a39c15e20729701e66135');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_6', 'CDC_6', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_6@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 7
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_7@cdc-diabetes.com', 'pbkdf2:sha256:1000000$tsX8lrfF3Oc6WpPP$5817a11d6cadc642c40edcca78ecfc8e481eaf186b4ca68e750e120d9de2a9fb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_7', 'CDC_7', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_7@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 8
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_8@cdc-diabetes.com', 'pbkdf2:sha256:1000000$FVek8NdNsya0uCLa$55a614c11e569b22cfc8f008e20f417e915556a3a2ab48c339d550c2f5fb1201');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_8', 'CDC_8', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_8@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 9
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_9@cdc-diabetes.com', 'pbkdf2:sha256:1000000$OcsU56pkQZT4cmT6$e786eea092d0865a041797f5296525b4baa3ba913e15195c48f4f331a1d2fa80');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_9', 'CDC_9', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_9@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 10
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_10@cdc-diabetes.com', 'pbkdf2:sha256:1000000$EoCmQlWsZ3BkDaUq$f7e11bd2899bb4550ca689898604fb5e0a94df439728c83f89957511293f1548');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_10', 'CDC_10', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_10@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 11
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_11@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ziwODDD2eK9j07Jv$658f401d73f31827c4d3206b677f0287b051ffcb499a3094030472686db354be');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_11', 'CDC_11', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_11@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 12
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_12@cdc-diabetes.com', 'pbkdf2:sha256:1000000$fp3lARqlwI093UFW$78f5995e6c4ea55987ea764473e120cba80f515acfa8762df2ecc479d62f2548');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_12', 'CDC_12', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_12@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 13
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_13@cdc-diabetes.com', 'pbkdf2:sha256:1000000$9QcQVSqCCDX3spWH$9ca6d6dde1df40603bd8cd1e80024c9d33c428cb621c45b24b7277f30b934427');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_13', 'CDC_13', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_13@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 14
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_14@cdc-diabetes.com', 'pbkdf2:sha256:1000000$t3VZ5N4w5NoWfKLQ$f823f68b9a67a4e36f660e8edb6694e301d043e6eb0794eaaa3dace42dab9c3c');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_14', 'CDC_14', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '3.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_14@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 15
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_15@cdc-diabetes.com', 'pbkdf2:sha256:1000000$yeC6gUDyZq2Uc0Dv$355d583cb5268aa1506b5af610a3ed7f8537ff16dbf442bba46564deee42ea32');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_15', 'CDC_15', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_15@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 16
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_16@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Z8tfeYNd7rUZbBox$ea397bf558472ba9c91b40cc2aa95a2e164cad84142256f63265516787efffaf');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_16', 'CDC_16', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_16@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 17
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_17@cdc-diabetes.com', 'pbkdf2:sha256:1000000$wAMycU2IS8ZdzqxB$49a2f90ae01175740c429e081bd639c2e93c1226c6ca505a80be4b14d9231162');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_17', 'CDC_17', '1989-01-01', 'M'
FROM Usuario 
WHERE email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_17@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 18
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_18@cdc-diabetes.com', 'pbkdf2:sha256:1000000$3poUq0d6MTvnntGl$4c63be0b3bf0a950d3623d82b0d9768d9784c7df9701550f47da746920a6b005');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_18', 'CDC_18', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_18@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 19
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_19@cdc-diabetes.com', 'pbkdf2:sha256:1000000$5UHU1XfjXlWROIf5$721b2c31ee6e2fa39bf9893c2bd423e71f3f9886dbdbb273abe1d72acc49e3f6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_19', 'CDC_19', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_19@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 20
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_20@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CtoQfO0kmuUpIBqX$ecb2c1c094ad3c5d7708c1407f8b9671f6b49cd913d11425f4f04b35498f4263');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_20', 'CDC_20', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_20@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 21
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_21@cdc-diabetes.com', 'pbkdf2:sha256:1000000$UTAKH1kl64frre0B$920d096225f1aa1e3659c3dd67685d0105e030f51afa792db4b75d9827b9f62e');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_21', 'CDC_21', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_21@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 22
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_22@cdc-diabetes.com', 'pbkdf2:sha256:1000000$DF5NUEeMXucAcISR$e2723ade914a2b0c2dbcf13d7fcb606dd7830243c9b3dc07d911171b2da98db7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_22', 'CDC_22', '1999-01-01', 'F'
FROM Usuario 
WHERE email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '79.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_22@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 23
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_23@cdc-diabetes.com', 'pbkdf2:sha256:1000000$PB7nyyBrFEehyB0v$7bcf019a12faa76d23162271fd2870c89000541dda6926202339780fa73df2d7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_23', 'CDC_23', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_23@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 24
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_24@cdc-diabetes.com', 'pbkdf2:sha256:1000000$bQCxu98bjjcstr0I$21371083a374fdfe47c005f920980f2831966bca75022b4f342d6564da98e60b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_24', 'CDC_24', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_24@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 25
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_25@cdc-diabetes.com', 'pbkdf2:sha256:1000000$hS7HNBG5NuwVFDuP$190cb0a5ea8bebde19446e1d9853f2d2db06ce965a2cff7cc66d415400b20f28');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_25', 'CDC_25', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '43.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_25@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 26
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_26@cdc-diabetes.com', 'pbkdf2:sha256:1000000$L90vX7cq9wRgp1Vm$8e82eee7f3e11835353d4fce43cfa1dab2487cd822532edd2d53cda9206cf4df');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_26', 'CDC_26', '1954-01-01', 'M'
FROM Usuario 
WHERE email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_26@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 27
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_27@cdc-diabetes.com', 'pbkdf2:sha256:1000000$QWWrHvIvJD21sYRs$ef38f975a192ed0b0570d4c880a0344a0429718d5eadead7a5c15ec2d8729933');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_27', 'CDC_27', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_27@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 28
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_28@cdc-diabetes.com', 'pbkdf2:sha256:1000000$S9Z6cyRH0QK0DBjI$2c6fde093d0ab6a318cfb1d617eff5e7d7310e8865a40482c276ec07c06bf4e3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_28', 'CDC_28', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_28@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 29
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_29@cdc-diabetes.com', 'pbkdf2:sha256:1000000$B36KkureDsWexwtb$14ae5d3918e8740cd5d0a460ee72f10aaa5a976e0bdaa85530be0d556015acb3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_29', 'CDC_29', '1999-01-01', 'F'
FROM Usuario 
WHERE email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_29@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 30
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_30@cdc-diabetes.com', 'pbkdf2:sha256:1000000$S8b0GhETRN2zo68H$50cb751e00689760c4c98def429c7b056e75d6d762be2fc72bd5a0173f153832');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_30', 'CDC_30', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_30@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 31
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_31@cdc-diabetes.com', 'pbkdf2:sha256:1000000$uH1Aabj3UYSuCWLt$c3fcdc800e54f69e5131bd3728fc10034c96a11ad71d2cc0d76cfd92d3c51a7a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_31', 'CDC_31', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_31@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 32
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_32@cdc-diabetes.com', 'pbkdf2:sha256:1000000$VfiuolIiAjc8bSuR$4a7fedf5ce5399bb9b0547649c9060de31f910fc73107302edf92bc87b359ed7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_32', 'CDC_32', '2006-01-01', 'F'
FROM Usuario 
WHERE email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '36.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_32@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 33
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_33@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ts6aJo5meS1KaJHL$6d4cd2ae2e47295dd6432f2a00d9a805cef87329f6072794487ed48141519630');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_33', 'CDC_33', '1989-01-01', 'F'
FROM Usuario 
WHERE email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_33@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 34
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_34@cdc-diabetes.com', 'pbkdf2:sha256:1000000$aG35pWvuuZ5YtnMC$e24108165d5e10655e52497cef6099c5bad8568c88a03c6fef2332be4fa2bb1b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_34', 'CDC_34', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '38.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_34@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 35
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_35@cdc-diabetes.com', 'pbkdf2:sha256:1000000$YYHclR4qh9sdJ5fb$b5559fa556dccc674a44ec6edfad3cf631a685723bd1e81b425f3c4378b5c7e2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_35', 'CDC_35', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '15', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_35@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 36
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_36@cdc-diabetes.com', 'pbkdf2:sha256:1000000$URrVVt1jbfGeLvvL$aa5384f85d025e18b703c3a4685c019e8ed1088e93046268cf0f3f3ed59b931f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_36', 'CDC_36', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '4.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_36@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 37
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_37@cdc-diabetes.com', 'pbkdf2:sha256:1000000$YbswxTY73jCIJUw5$d2925109c44c2e25dd27d2409ad6d78d4fabd81d22cf720076f89de9e871e1bb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_37', 'CDC_37', '1994-01-01', 'F'
FROM Usuario 
WHERE email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_37@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 38
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_38@cdc-diabetes.com', 'pbkdf2:sha256:1000000$1nsxQOLhef0I8YaC$269428d3ecdc11ea178de9bd3d6ce5f2b41b66608b5eca582893abb404f6e65f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_38', 'CDC_38', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_38@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 39
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_39@cdc-diabetes.com', 'pbkdf2:sha256:1000000$crpdX1WI2cJ0PtLY$d2a253451df18e5ae3ade2a7b082d42d5dd5b8c3d33078c689456c3f1a27d90b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_39', 'CDC_39', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_39@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 40
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_40@cdc-diabetes.com', 'pbkdf2:sha256:1000000$aG8HgQFdYHTRVnr1$5dd6db4682151c9834fe7f8e8ebfe9ac8a05c08f2df48b4705ea8edb8f5d4900');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_40', 'CDC_40', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_40@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 41
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_41@cdc-diabetes.com', 'pbkdf2:sha256:1000000$xGA2UFMnFNFC6ykj$5fd2503dbf7084550d6122c22359e90ed949d5ef7e98bc29e38b612ca03dd503');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_41', 'CDC_41', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_41@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 42
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_42@cdc-diabetes.com', 'pbkdf2:sha256:1000000$dAdxcdTeorm1lvkS$f116f57fb0c5cae38df6ddccf44833fa8234e0ca627d41aec4f2388f5cc08390');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_42', 'CDC_42', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '4.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_42@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 43
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_43@cdc-diabetes.com', 'pbkdf2:sha256:1000000$HladFhFOPnj54rLv$a8e3093ce22261f7ba6500f5ef842027116c529e14d856292555a037c216f077');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_43', 'CDC_43', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_43@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 44
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_44@cdc-diabetes.com', 'pbkdf2:sha256:1000000$btvZ1DFeT49fQZ1o$87fc9beea527b6979fd1299e8f414650008dcd89adbb8a2be0bc1fe511ad7656');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_44', 'CDC_44', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_44@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 45
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_45@cdc-diabetes.com', 'pbkdf2:sha256:1000000$PXPhRBSKsvRSm2rV$c686e2812f68922d3e3c740d1211b22dff68776cb3de81cc9a4f0206a8c67c9f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_45', 'CDC_45', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '15.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_45@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 46
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_46@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ZUgM3EXocpnzY2m0$c5296c690f5fa9488e0b07a960d7a2a0e5feb2e5d2f5bd3c935d5086152f74ad');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_46', 'CDC_46', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_46@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 47
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_47@cdc-diabetes.com', 'pbkdf2:sha256:1000000$y3QQDoUCnsItIB7s$c4e52f7e2a5e0bf2692265f51a7b83de819d2465b169938544b3d370688a3bc4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_47', 'CDC_47', '1989-01-01', 'M'
FROM Usuario 
WHERE email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_47@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 48
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_48@cdc-diabetes.com', 'pbkdf2:sha256:1000000$GxG9ETt0m9I9yGNN$087c9fffd18bc15745006cf55fc64212e2af8760918fa451edf435d17d899a32');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_48', 'CDC_48', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_48@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 49
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_49@cdc-diabetes.com', 'pbkdf2:sha256:1000000$oTSB5Jd2AKmkWm0S$d7259a3da1d5029a9d5b1ca5f0b3cee759041d531dd80cf9aa4bf878bb6bad2b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_49', 'CDC_49', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_49@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 50
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_50@cdc-diabetes.com', 'pbkdf2:sha256:1000000$TjcIfoVGpPTjqo6Y$86f2e0ff291a09a0b76abab2e65593af035723a551f67c5fe0e0681fea66abdc');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_50', 'CDC_50', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_50@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 51
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_51@cdc-diabetes.com', 'pbkdf2:sha256:1000000$K2z86uqdoCF3BWYo$b61f8286cfd3ce5c319065637553d36ab98bd7ec2f649a847d593b1f973e2db8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_51', 'CDC_51', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_51@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 52
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_52@cdc-diabetes.com', 'pbkdf2:sha256:1000000$54IXSMeq2SKlxRay$588911187b9313b93e2f0baea20e65079bb593e9f29f23a1f849d9b8dbb6bfc9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_52', 'CDC_52', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '1.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_52@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 53
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_53@cdc-diabetes.com', 'pbkdf2:sha256:1000000$OA9IflzCv2eN2AZn$a57aaa56bbd6a822444cf15418a2471a749a5387d99b6e94486c8f8277992aca');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_53', 'CDC_53', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_53@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 54
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_54@cdc-diabetes.com', 'pbkdf2:sha256:1000000$eqNYWAoNOcpjrAHD$52f7651491376c110c03ab791a789769a74d22bb8bd366036495104c48fe3e48');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_54', 'CDC_54', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '44.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_54@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 55
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_55@cdc-diabetes.com', 'pbkdf2:sha256:1000000$PbyMIL83BKVr40rZ$d61a65ebcdcff3bb19a15014e79ae0a9f87cf77900cafd9ccc9b26e3e277bc78');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_55', 'CDC_55', '1974-01-01', 'F'
FROM Usuario 
WHERE email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_55@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 56
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_56@cdc-diabetes.com', 'pbkdf2:sha256:1000000$GYQOhJTT4NQujRpp$ad9aaae48cf7bd8f758046d70d77fb683aebe91be124ad2bc176891c7059da00');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_56', 'CDC_56', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '14.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_56@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 57
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_57@cdc-diabetes.com', 'pbkdf2:sha256:1000000$EFRlcLbZCngj9pBq$dac6a4b8afb270f93b52ae1000c97a9dd8e79ccd7f33a349a1498c37a5a08447');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_57', 'CDC_57', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '36.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_57@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 58
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_58@cdc-diabetes.com', 'pbkdf2:sha256:1000000$mDDhFtYISOyfloQh$23e675a19b7b2ca1a89201644fd153a1a0dbc620099a2d58fbf7f9202c1b73ef');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_58', 'CDC_58', '1994-01-01', 'F'
FROM Usuario 
WHERE email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_58@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 59
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_59@cdc-diabetes.com', 'pbkdf2:sha256:1000000$56NO5Tykqzrp7wbJ$e3c338f54a71e3e7615c09b108060bd3c503e02bba2d7664135a7f834c93ba7a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_59', 'CDC_59', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '30', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_59@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 60
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_60@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Q0tU6GTNigvWHrQY$1814644453512f640a8bab7d2841ead208ecac82181c063ee9efa28fa40b87ad');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_60', 'CDC_60', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_60@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 61
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_61@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ZAiCCwZY8XQFzQJo$8cdb91d6855b2cb1ecf675541e667ffdc6d0c76e746dcff6db8f7d3040a047c1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_61', 'CDC_61', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '45.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_61@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 62
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_62@cdc-diabetes.com', 'pbkdf2:sha256:1000000$VhNOCxUK3RHd19Nv$2d44abfd613aca15785c06d11df975458cc5db9caa7e99b9634b66a5684ee937');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_62', 'CDC_62', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_62@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 63
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_63@cdc-diabetes.com', 'pbkdf2:sha256:1000000$KQtfFVgW1FEy9kYQ$9c934177a073a27d231cb44fbd965a1bb68cbb0d0bdd444d34744920af70c3b1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_63', 'CDC_63', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '49.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_63@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 64
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_64@cdc-diabetes.com', 'pbkdf2:sha256:1000000$EACeasErUzvG9Hhr$8541714687a1c9d44345cfefa01f88ff77fb9c853e6957a5a94ed5fc3fc390bb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_64', 'CDC_64', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_64@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 65
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_65@cdc-diabetes.com', 'pbkdf2:sha256:1000000$RWBQzLN46P5YzMfi$ae7f8507922d6160ffe686e9b0a718dd026e8744e3a8911624bcbd488c4b2662');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_65', 'CDC_65', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '14', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_65@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 66
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_66@cdc-diabetes.com', 'pbkdf2:sha256:1000000$7eYPG5iogMKz2Dxi$1b01be0d7bf54409e463826c9bd8b665fe18033c26bba3623a1a6b25ed91ad60');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_66', 'CDC_66', '1994-01-01', 'M'
FROM Usuario 
WHERE email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_66@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 67
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_67@cdc-diabetes.com', 'pbkdf2:sha256:1000000$BaZg4MjxUaNH1zbC$4e8870989b5bf26b6f5f3686f0774b75df9be9f0a2dbe8f2d3b0bcd3d71ebe88');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_67', 'CDC_67', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_67@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 68
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_68@cdc-diabetes.com', 'pbkdf2:sha256:1000000$J1NpOuw7cSICNInS$115c4bd46db3fe1649a52b22b78d88149394c5d818004d5cb5aa8e110cdd3278');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_68', 'CDC_68', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_68@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 69
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_69@cdc-diabetes.com', 'pbkdf2:sha256:1000000$YroLVVj7FJw4ev1F$d53f545bb3eafc3abfb64c9987e5652e08d288107c561646f9feaffb00571c24');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_69', 'CDC_69', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '39.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_69@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 70
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_70@cdc-diabetes.com', 'pbkdf2:sha256:1000000$0NQWBsF0CLWKwk4N$3976ca757ffab1cc984a248a701227640cbaf9d682eb0d663e45705d8ecf6e8f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_70', 'CDC_70', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_70@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 71
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_71@cdc-diabetes.com', 'pbkdf2:sha256:1000000$qnBZvtBrzebn5VBQ$39db72340d1d1e37ca1c310017ddfba5931f2a7f8f8f43384d5466afcda3a1c6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_71', 'CDC_71', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '41.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_71@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 72
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_72@cdc-diabetes.com', 'pbkdf2:sha256:1000000$MlHOlH1G0ZRcUF0a$16a251a1b5b7710244cdeaaf7cfdbbd0518594c8ad0b718422660c7169c443d1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_72', 'CDC_72', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '43.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '30', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_72@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 73
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_73@cdc-diabetes.com', 'pbkdf2:sha256:1000000$s3OOJKrxFJFsQgzi$0f93fd37d5e38eff62cc9a55ad475881cabf9105f9a2d7e0731e7b5be26c1d40');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_73', 'CDC_73', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '1.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_73@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 74
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_74@cdc-diabetes.com', 'pbkdf2:sha256:1000000$t96DJLzikhQ3qEEg$7057b63af91f71f8f58c22aae5b841c0b20c5a2d286de1778afd99c4757d455b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_74', 'CDC_74', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_74@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 75
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_75@cdc-diabetes.com', 'pbkdf2:sha256:1000000$HBcVqEuVw38FkNkc$fb40ef55112c999f4a6e29bc559e9b0c7fb91aceb0fab85d547b0ea98941d4fb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_75', 'CDC_75', '1949-01-01', 'M'
FROM Usuario 
WHERE email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_75@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 76
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_76@cdc-diabetes.com', 'pbkdf2:sha256:1000000$unmbCdt8fFH06wlT$081b477d90c99b9c1a6e59d85cd123024b8b4b0fdc90372a1dad8951af8d1553');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_76', 'CDC_76', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_76@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 77
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_77@cdc-diabetes.com', 'pbkdf2:sha256:1000000$olkPFhZdakpZ1HZZ$05434e863f4bbaadfe4e1082fa46ad393bf3408f958dbd5e494c34fd547c5eed');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_77', 'CDC_77', '2006-01-01', 'M'
FROM Usuario 
WHERE email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_77@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 78
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_78@cdc-diabetes.com', 'pbkdf2:sha256:1000000$JJh91P16fH8NGQoc$caeb256c09653798b18c3404d05908bf9eacb683824040e3adfc3d4775185134');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_78', 'CDC_78', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_78@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 79
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_79@cdc-diabetes.com', 'pbkdf2:sha256:1000000$retCID0llhK8myAL$75701d1330265d9e67d0840f12e2fc9363967b0ac186274b9514d2b0497e36ac');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_79', 'CDC_79', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '21', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_79@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 80
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_80@cdc-diabetes.com', 'pbkdf2:sha256:1000000$J5BRQLwI5y3Sf18C$42703db3def1142feccd63a5ebe774bbe785f3a0c46099bf770663c2c8eaf809');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_80', 'CDC_80', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_80@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 81
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_81@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Qs2AjlnMKXmXRyXJ$18bad50ce60e9a78dede4efb7f7680740ef893ae4d72f1cce2c6328b5225acf6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_81', 'CDC_81', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '73.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_81@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 82
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_82@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CCMwpoaQ2euPkqO8$299bc56418f2401d7b5fd3d9b29db9ee959736a4b67f67b808ce4a842dacae32');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_82', 'CDC_82', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_82@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 83
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_83@cdc-diabetes.com', 'pbkdf2:sha256:1000000$xUqvNF9fF153aCNJ$404437e4077dbc42184ac0f51620fe779b9c74034857817e80d608ca3799d7e2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_83', 'CDC_83', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_83@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 84
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_84@cdc-diabetes.com', 'pbkdf2:sha256:1000000$rjRh2YrkzQdex8GH$14d84ec6efae91b31c9d23317e218e68e121f8a879a305a6a2f8519bee5a6700');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_84', 'CDC_84', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_84@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 85
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_85@cdc-diabetes.com', 'pbkdf2:sha256:1000000$SKcAhhRHPOPWg8Vq$2b5172944c1475ab1e02c565406b6552f2712082950c6bae88241bcd7d9b19a0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_85', 'CDC_85', '1954-01-01', 'M'
FROM Usuario 
WHERE email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_85@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 86
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_86@cdc-diabetes.com', 'pbkdf2:sha256:1000000$HbMdEQ2hR1c7lglN$e4fb1fd6e95abd82424dfa7a675535af59f502c4faac17ad760cc1c2120734ce');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_86', 'CDC_86', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_86@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 87
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_87@cdc-diabetes.com', 'pbkdf2:sha256:1000000$3m7mrzpKvxhLh1i3$797ea8eb53a543c06dfcd5252a47367391eeb12721408eafae8ec4a3ad7adb84');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_87', 'CDC_87', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_87@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 88
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_88@cdc-diabetes.com', 'pbkdf2:sha256:1000000$5Q4t0u3KVjyzOr1g$f5794d43e75e64dee5a499bc9c7bb9d1c539f0a752eeda145b7cfc7a0965c128');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_88', 'CDC_88', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '37.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_88@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 89
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_89@cdc-diabetes.com', 'pbkdf2:sha256:1000000$TQfaIC10Z1P7IbhQ$a05bade8c1b1adb5105dfd48b6651d3f359f5fe60cedc8e4ed4ec13bd557e84f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_89', 'CDC_89', '1974-01-01', 'F'
FROM Usuario 
WHERE email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_89@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 90
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_90@cdc-diabetes.com', 'pbkdf2:sha256:1000000$tOY5AnUTylvKaMhS$2add02ab0155fe3d70b63ee7b10f95c1d463de2047fd242e3f52eddcb99b9db7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_90', 'CDC_90', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_90@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 91
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_91@cdc-diabetes.com', 'pbkdf2:sha256:1000000$j5gvhEyO2IHfLXQ9$64fb2dde7560e27684b84f6ee693099b81c00333e1b0307f04c720584b1bcf18');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_91', 'CDC_91', '1994-01-01', 'F'
FROM Usuario 
WHERE email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_91@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 92
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_92@cdc-diabetes.com', 'pbkdf2:sha256:1000000$yi2kZtLXBOuddP79$8525f6f50cf5828f009dcfdc1bfa9412a645252794f954ab23d1d25cfb786b24');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_92', 'CDC_92', '1999-01-01', 'M'
FROM Usuario 
WHERE email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_92@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 93
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_93@cdc-diabetes.com', 'pbkdf2:sha256:1000000$FyGQvFfPgcDdJfbL$ee5a26c8d65bf58a5176c1a534f499d7eb08e3477c6dfe60dc88f07ad97b30f2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_93', 'CDC_93', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_93@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 94
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_94@cdc-diabetes.com', 'pbkdf2:sha256:1000000$oDPl8FmTx15WCu7D$44e39fbede0a2ae8f8d433b10a9a34c359e12602adde2d283b815f09eda2bd1b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_94', 'CDC_94', '1949-01-01', 'M'
FROM Usuario 
WHERE email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_94@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 95
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_95@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CAGHIq3fiGOXqD4Y$f7efe04587926a0515416d63989586f199cef6f7dc1692c77d114620e0bd9a3d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_95', 'CDC_95', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_95@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 96
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_96@cdc-diabetes.com', 'pbkdf2:sha256:1000000$X2JYwYrJbqOhKCGo$e673d48ff110a2ecd264fe22a3c2c853225597821fa16a735de62ae24dadfc3f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_96', 'CDC_96', '1999-01-01', 'M'
FROM Usuario 
WHERE email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '1.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_96@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 97
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_97@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CEbJ48jFXOY7BpNz$6f2ff01ce63fa7b63967558ff1874fc252b93c6eb2169cffd6fd8924c9b10cac');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_97', 'CDC_97', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_97@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 98
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_98@cdc-diabetes.com', 'pbkdf2:sha256:1000000$0vL6W5LQBgsW2LVR$e0ab1daaf78a20b6e01cd4b8d5cf423cd06e2528652aa5689f6522a467c65ce4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_98', 'CDC_98', '1954-01-01', 'M'
FROM Usuario 
WHERE email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_98@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 99
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_99@cdc-diabetes.com', 'pbkdf2:sha256:1000000$GZRlaly1slM9Wnk2$4fec03e614662f962bf18c11b05af01c2d9317590c448f5634bb770bce64db78');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_99', 'CDC_99', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '38.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_99@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 100
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_100@cdc-diabetes.com', 'pbkdf2:sha256:1000000$llp4u1WOPLJkWEjW$36f87d59c29df8c5301aed5ff56525a2af9677a729c6c7434eb9261961b40685');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_100', 'CDC_100', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_100@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- =====================================
-- COMANDOS SQL DATASET HIPERTENSIÓN
-- Compatible con init_new.sql
-- =====================================

-- Insertar medicamentos para hipertensión
INSERT INTO Medicamento (nombre) VALUES ('Ninguna') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('Otro') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('Beta Blocker') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('Diurético') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('ACE Inhibitor') ON CONFLICT (nombre) DO NOTHING;

-- Insertar datos de usuarios del dataset Hypertension
-- Usuario 1
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_1@hypertension-risk.com', 'pbkdf2:sha256:1000000$dCrDZcRfk25VResT$6d480bc0f2fbfb6b144be3c7423d10f0b8daa053c2533aae0d82afea0d0591a3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_1', 'Hypertension_1', '1955-01-01', NULL
FROM Usuario 
WHERE email = 'user_1@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_1@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 2
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_2@hypertension-risk.com', 'pbkdf2:sha256:1000000$4RqozGnsfIDLu4nM$3b89722231e6bf50b79a64f016b35e11fe4c9323e0bdc6fc39ea77270b479c84');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_2', 'Hypertension_2', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_2@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_2@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 3
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_3@hypertension-risk.com', 'pbkdf2:sha256:1000000$Q2YSNtRla0tU6uUB$e70d846dd53d1b166f008c690b90b35d3e7bbce8ec8e96c4d2e291a1bb2a8194');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_3', 'Hypertension_3', '1946-01-01', NULL
FROM Usuario 
WHERE email = 'user_3@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_3@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 4
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_4@hypertension-risk.com', 'pbkdf2:sha256:1000000$8mTVMvv9yXFsQp2O$4b902bbe373ad26f364bba5745e2615d4ecc0f4d80d35e9d7730b44f856571ca');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_4', 'Hypertension_4', '1986-01-01', NULL
FROM Usuario 
WHERE email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_4@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 5
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_5@hypertension-risk.com', 'pbkdf2:sha256:1000000$9mB3I57NntiFlgJn$facb99585fd6c6420a558abc1299ba63c39c649a5e1b31dbdc5fab210afe066d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_5', 'Hypertension_5', '1983-01-01', NULL
FROM Usuario 
WHERE email = 'user_5@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '16.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_5@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 6
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_6@hypertension-risk.com', 'pbkdf2:sha256:1000000$e5L6aSYmQCV4Ezd6$75262cfc1e30bad61e81cfff84ecf535a19df651c906d84d1e42c16f90efbbfe');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_6', 'Hypertension_6', '2004-01-01', NULL
FROM Usuario 
WHERE email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_6@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 7
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_7@hypertension-risk.com', 'pbkdf2:sha256:1000000$rCne4ZJuqzGOqrWH$2c3d098f5673511130657fcfed53a71fe975b85eb10747c7904f23cdd4e56c30');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_7', 'Hypertension_7', '1985-01-01', NULL
FROM Usuario 
WHERE email = 'user_7@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_7@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 8
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_8@hypertension-risk.com', 'pbkdf2:sha256:1000000$o8h48QQP5dyQ58Rh$76c9f9db235adb47f3b014d2c9d31a1387a72b59fa831ea9c5fbf9a1038105e4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_8', 'Hypertension_8', '1954-01-01', NULL
FROM Usuario 
WHERE email = 'user_8@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_8@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 9
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_9@hypertension-risk.com', 'pbkdf2:sha256:1000000$RIY2oHpXmrQRTz7b$078f939e72bdef91360cb0a35524b3ac64ccfe6895d14bf7a8f2bbb849febe50');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_9', 'Hypertension_9', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '36.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_9@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 10
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_10@hypertension-risk.com', 'pbkdf2:sha256:1000000$X5hiOd3rRZZkHke8$cdb13d385e9255bdd0c21762afb988016d1e31ee3cafcf65e9a886773289efb3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_10', 'Hypertension_10', '1977-01-01', NULL
FROM Usuario 
WHERE email = 'user_10@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_10@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 11
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_11@hypertension-risk.com', 'pbkdf2:sha256:1000000$4xeIqFmoOaIqoeWm$d04b501795a5f81c039720094b49f16ccef69ce64057efb466b418ef3ddce434');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_11', 'Hypertension_11', '1969-01-01', NULL
FROM Usuario 
WHERE email = 'user_11@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_11@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 12
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_12@hypertension-risk.com', 'pbkdf2:sha256:1000000$ontMHJ93RZxlrWFo$2c16518f2c6f80674209ab2e06ef52bbc6e4e8e860d058bc74ea36dbbf5a6466');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_12', 'Hypertension_12', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_12@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_12@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 13
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_13@hypertension-risk.com', 'pbkdf2:sha256:1000000$1HFjOIsIEkbxNk8Z$286df2a296191cf5d600665ac44ce01859d484911d716efe459fbb612ee3750a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_13', 'Hypertension_13', '1943-01-01', NULL
FROM Usuario 
WHERE email = 'user_13@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '17.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_13@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 14
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_14@hypertension-risk.com', 'pbkdf2:sha256:1000000$yoTBvN5PGIj5GvgX$eaf45757b493f559b53becd599b0ee107ff7f89803f871ac0089afd365f59562');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_14', 'Hypertension_14', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '19.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_14@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 15
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_15@hypertension-risk.com', 'pbkdf2:sha256:1000000$E4iBZqeJPMz3VwMX$ee7990c4684f2263b15ec79aa4c463f8217f29066a8724d7d7d31c9668436720');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_15', 'Hypertension_15', '1986-01-01', NULL
FROM Usuario 
WHERE email = 'user_15@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_15@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 16
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_16@hypertension-risk.com', 'pbkdf2:sha256:1000000$3MOJomf7s8xXF739$21624636cf7a6066df860396853112ea3efc6a0d3dcd3812dc1ad987a4cf54c2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_16', 'Hypertension_16', '1974-01-01', NULL
FROM Usuario 
WHERE email = 'user_16@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_16@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 17
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_17@hypertension-risk.com', 'pbkdf2:sha256:1000000$fQBBOQZx6yhXg7hw$a33ca5ea97511e732f830a8cc6fe6ceee9a9142d7e7db8b031fbf060e1436bd2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_17', 'Hypertension_17', '1949-01-01', NULL
FROM Usuario 
WHERE email = 'user_17@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_17@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 18
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_18@hypertension-risk.com', 'pbkdf2:sha256:1000000$JF8xG7ruP5A4MIFN$8a63410aaa677b522b3703f30f7dc166133b26b536f3be3e103745afa13b2dfc');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_18', 'Hypertension_18', '1985-01-01', NULL
FROM Usuario 
WHERE email = 'user_18@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '13.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_18@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 19
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_19@hypertension-risk.com', 'pbkdf2:sha256:1000000$9j3iHcoAI1NUUtOR$b3343f10089b4b1ef975a5db8348adc636c3112db6bb89639315d17277bd6708');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_19', 'Hypertension_19', '1958-01-01', NULL
FROM Usuario 
WHERE email = 'user_19@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_19@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 20
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_20@hypertension-risk.com', 'pbkdf2:sha256:1000000$8X6QMgELty8FnZLp$a7d3325cb9c8194be6aaf394b70815c28718d16f68498c2509d16b62d31be3f7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_20', 'Hypertension_20', '1948-01-01', NULL
FROM Usuario 
WHERE email = 'user_20@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_20@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 21
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_21@hypertension-risk.com', 'pbkdf2:sha256:1000000$RGwkorU9R9e9Tbjc$78c0dbc9faae306fa7bb5a982b7e393c4cf6f1785c083e4720929ac8b482befc');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_21', 'Hypertension_21', '1965-01-01', NULL
FROM Usuario 
WHERE email = 'user_21@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_21@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 22
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_22@hypertension-risk.com', 'pbkdf2:sha256:1000000$hU2etDfRf8bF9xBn$85f05c5f74bdd21b04ac96cd2d44394811f57fa3d63601a8e186ce23a9a53853');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_22', 'Hypertension_22', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_22@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_22@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 23
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_23@hypertension-risk.com', 'pbkdf2:sha256:1000000$zarSiNLfrFAquf5w$4c9ab6dae1c6112c31c66f62e049f5b15125d9cd84074522b981d7b7daf96a7b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_23', 'Hypertension_23', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_23@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 24
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_24@hypertension-risk.com', 'pbkdf2:sha256:1000000$CKkZm3o35bycOP4j$99d313b08c8fd2605f0bb52bd9413690bc63238847153e4e21ec08d5f0dda1f2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_24', 'Hypertension_24', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_24@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 25
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_25@hypertension-risk.com', 'pbkdf2:sha256:1000000$Px4Zzs3zgCnFeOUA$d3ce46682e6ca75486b3afb2fed4053ddcd7691f2ea189ed1a4bbfe38e9c3b3e');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_25', 'Hypertension_25', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_25@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 26
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_26@hypertension-risk.com', 'pbkdf2:sha256:1000000$lo80C6OJfCdkcBdk$8bc75bde8371ea69bd1c2d5cdf2b304ea7947665586cf0dc1603f9a6f9564a88');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_26', 'Hypertension_26', '1960-01-01', NULL
FROM Usuario 
WHERE email = 'user_26@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '2.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_26@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 27
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_27@hypertension-risk.com', 'pbkdf2:sha256:1000000$RszhnHkMDQuH4neo$74dfb9ee6924b0826127e1187f56c352191d872df72f3515b1b2e6ebe2472755');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_27', 'Hypertension_27', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_27@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_27@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 28
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_28@hypertension-risk.com', 'pbkdf2:sha256:1000000$jSYRcI3RcdF7ofNv$955fbedb250b9042b42eb5f8d8ed3729a22732f2955982d2e5d27dfc38fda086');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_28', 'Hypertension_28', '1956-01-01', NULL
FROM Usuario 
WHERE email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_28@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 29
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_29@hypertension-risk.com', 'pbkdf2:sha256:1000000$QL6d9KdLuY4Ziv9a$5f827fc9f05251ddc6e5e9f277baeb3be4350671e846abae724a8862da4d48db');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_29', 'Hypertension_29', '1952-01-01', NULL
FROM Usuario 
WHERE email = 'user_29@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_29@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 30
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_30@hypertension-risk.com', 'pbkdf2:sha256:1000000$Q5zYFWLp7e0wfdCK$1eb5bf268051ffaec03a81b92d5f6f4665c07fe0e88e12cc7a1639d8714b70bb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_30', 'Hypertension_30', '1943-01-01', NULL
FROM Usuario 
WHERE email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_30@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 31
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_31@hypertension-risk.com', 'pbkdf2:sha256:1000000$q8rQOYduktbZDSL5$8f767f61a1ef0d6db0025d22edf6b73062e93d8f14c85c6e061658c718aa85a4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_31', 'Hypertension_31', '2004-01-01', NULL
FROM Usuario 
WHERE email = 'user_31@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_31@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 32
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_32@hypertension-risk.com', 'pbkdf2:sha256:1000000$zwJjCvlgyX9ljoi7$4284d32740c6a599168a12eb724f6eb6b1358f1ff9a5e30a0ee605ce8420f552');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_32', 'Hypertension_32', '1956-01-01', NULL
FROM Usuario 
WHERE email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_32@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 33
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_33@hypertension-risk.com', 'pbkdf2:sha256:1000000$RRVBqLArXV8muivQ$bd7f7e4daf4ea332e904871fa78f76924ab5a57e6360127159b4c803d511e4b9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_33', 'Hypertension_33', '2000-01-01', NULL
FROM Usuario 
WHERE email = 'user_33@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_33@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 34
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_34@hypertension-risk.com', 'pbkdf2:sha256:1000000$IIzjyi6VK8jIblBn$1584abd28c24c56b3e505bcf9e2d4431380e317aa116aed4d1bcbae21581042d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_34', 'Hypertension_34', '1986-01-01', NULL
FROM Usuario 
WHERE email = 'user_34@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_34@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 35
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_35@hypertension-risk.com', 'pbkdf2:sha256:1000000$RVmzlFbzcfvKQkZf$2103c18fa55e24921172d6a90c266fd7b50249c9017b3e4049a067e81760cb21');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_35', 'Hypertension_35', '1968-01-01', NULL
FROM Usuario 
WHERE email = 'user_35@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '17.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_35@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 36
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_36@hypertension-risk.com', 'pbkdf2:sha256:1000000$rjw5BhWvOTIswOwG$da68988c9e7604d3b55f67fa5dfeebf22ecaffbb2ce2e60d7859da5a36b97770');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_36', 'Hypertension_36', '1989-01-01', NULL
FROM Usuario 
WHERE email = 'user_36@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '37.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_36@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 37
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_37@hypertension-risk.com', 'pbkdf2:sha256:1000000$TLFthuU70Dxa7hmW$3aeda5ce8dfe8155d365ce5bb19f945070e5cd7aac8f9d8e54fe601916cebcda');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_37', 'Hypertension_37', '2003-01-01', NULL
FROM Usuario 
WHERE email = 'user_37@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_37@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 38
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_38@hypertension-risk.com', 'pbkdf2:sha256:1000000$zAs83mSEoraTMyui$1718664f0421d46f7b15882ba8d7982a479b8cb2feda63ed50f70a72d2b6d830');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_38', 'Hypertension_38', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_38@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_38@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 39
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_39@hypertension-risk.com', 'pbkdf2:sha256:1000000$kd2rpsq3rzDiITQo$c638b163e0ac09d70b6bab9b97527c8e39626f3df679df005b3126777fe36d8f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_39', 'Hypertension_39', '1993-01-01', NULL
FROM Usuario 
WHERE email = 'user_39@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_39@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 40
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_40@hypertension-risk.com', 'pbkdf2:sha256:1000000$gjcsOHc4qK6Jpa7v$256c42ea17b6aabadec2699f30b12f56c86ad2ce8f56839bbef717d37632fcd9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_40', 'Hypertension_40', '1998-01-01', NULL
FROM Usuario 
WHERE email = 'user_40@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '19.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_40@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 41
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_41@hypertension-risk.com', 'pbkdf2:sha256:1000000$7FGzWhRc72c85Cqm$2b835867e6ab9874d6879224327d1368c3c90adaf49ff759859c41b6caebdc88');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_41', 'Hypertension_41', '1954-01-01', NULL
FROM Usuario 
WHERE email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_41@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 42
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_42@hypertension-risk.com', 'pbkdf2:sha256:1000000$giY09xQFGolmBchb$0f07a989ff234d9559911d6bd5ddc84e237ae6467387fadbced0686ab75d9fd5');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_42', 'Hypertension_42', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_42@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '19.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_42@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 43
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_43@hypertension-risk.com', 'pbkdf2:sha256:1000000$hie7m6tD4r0RMr2E$65662679368ca5c1b96209be4ae472edea36c7076da1586565347e1b9801388d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_43', 'Hypertension_43', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_43@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_43@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 44
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_44@hypertension-risk.com', 'pbkdf2:sha256:1000000$2bEJnCHI8xGNLEHQ$5b55c26b7e1a887c503ba2ad9ee22e6dc2446c8332b00f4ac0c500462dc32bc0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_44', 'Hypertension_44', '1963-01-01', NULL
FROM Usuario 
WHERE email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_44@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 45
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_45@hypertension-risk.com', 'pbkdf2:sha256:1000000$OYTJQkoRZ9TBcEY1$64e86cd02f7a483f024c62e9790d2414ad683335d780d01264a55e670b2b50cd');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_45', 'Hypertension_45', '1999-01-01', NULL
FROM Usuario 
WHERE email = 'user_45@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_45@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 46
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_46@hypertension-risk.com', 'pbkdf2:sha256:1000000$klpKDVyjBLJNGQTJ$478a3024f0f891ba4a130e0d6bd98fd1bb5efda85238d8b4ca99b1956473ab10');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_46', 'Hypertension_46', '1960-01-01', NULL
FROM Usuario 
WHERE email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_46@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 47
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_47@hypertension-risk.com', 'pbkdf2:sha256:1000000$Zkv80TbIlcFBqstf$7104a77677e4cb57d450d022167ffd483c570db9c9b712ae8b878678508f1ba0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_47', 'Hypertension_47', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_47@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_47@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 48
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_48@hypertension-risk.com', 'pbkdf2:sha256:1000000$nj5tuk8kmOLPfsKx$376d67f134e56f61e87ec270b528444acc8e569f43ee770ee7ddd5d8190af1cf');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_48', 'Hypertension_48', '1971-01-01', NULL
FROM Usuario 
WHERE email = 'user_48@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_48@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 49
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_49@hypertension-risk.com', 'pbkdf2:sha256:1000000$2b1jRp3efgoXfqmc$da379eb4fadaddf24780a7b8c28c5e6c290f71a970790b8fe955ae8f16f4b100');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_49', 'Hypertension_49', '1957-01-01', NULL
FROM Usuario 
WHERE email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_49@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 50
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_50@hypertension-risk.com', 'pbkdf2:sha256:1000000$dezg35lY4ZGHRZ2p$649b10164564eae826a5a60975ee1c6e1b12ac8686e248a4dd81269a5a3b117b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_50', 'Hypertension_50', '2003-01-01', NULL
FROM Usuario 
WHERE email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_50@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 51
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_51@hypertension-risk.com', 'pbkdf2:sha256:1000000$QhKS0gB2eBbzr5Pz$35693ea76caec92a33f6177ab8f91bd90ca913904377d3d78477a45e9bffe9d0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_51', 'Hypertension_51', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_51@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_51@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 52
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_52@hypertension-risk.com', 'pbkdf2:sha256:1000000$H9Op3tCAmYrqbGRn$27ce684c6949a63263b76afaa6e19fc3da7c1b4fa179dcbf1fc19c8fe2e0bbfd');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_52', 'Hypertension_52', '2001-01-01', NULL
FROM Usuario 
WHERE email = 'user_52@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_52@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 53
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_53@hypertension-risk.com', 'pbkdf2:sha256:1000000$g72ONnrRk1hwH22q$ad062adefd79356e3a2ae01e67cdd4f82ad6541b4e6f397d0d4539091e3eed4e');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_53', 'Hypertension_53', '1953-01-01', NULL
FROM Usuario 
WHERE email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '17.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_53@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 54
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_54@hypertension-risk.com', 'pbkdf2:sha256:1000000$bIsK4MLO8YZ4SctD$8461600b3c5599f90cd8aa83809156af7f291db1ebd9b56e2248b4d194e3923a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_54', 'Hypertension_54', '2003-01-01', NULL
FROM Usuario 
WHERE email = 'user_54@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_54@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 55
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_55@hypertension-risk.com', 'pbkdf2:sha256:1000000$7EYliIvWrbOZLJ27$6e7805189dfd2de6454806caa00bf8573cca9ddcb5fc014c5f512e73c636caff');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_55', 'Hypertension_55', '1953-01-01', NULL
FROM Usuario 
WHERE email = 'user_55@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_55@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 56
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_56@hypertension-risk.com', 'pbkdf2:sha256:1000000$v7ismTKRYm3SMwpn$91dae60b33dfef7dbc957b276437242c946076a7621e66733851b18eb40eaef3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_56', 'Hypertension_56', '1944-01-01', NULL
FROM Usuario 
WHERE email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '13.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_56@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 57
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_57@hypertension-risk.com', 'pbkdf2:sha256:1000000$71ncnvjSHXvulP8q$4cad8c53c321abe50457a3ebd06656499c110849f79883d4f23e15a49227c479');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_57', 'Hypertension_57', '1989-01-01', NULL
FROM Usuario 
WHERE email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_57@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 58
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_58@hypertension-risk.com', 'pbkdf2:sha256:1000000$kDr2S3xFdb0s4YVQ$cdffeaac5045c793735340705dd5e4b3150dcba8a37fb1e7923b3c33537fd043');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_58', 'Hypertension_58', '1963-01-01', NULL
FROM Usuario 
WHERE email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_58@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 59
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_59@hypertension-risk.com', 'pbkdf2:sha256:1000000$N7DnSEdKhJ3czRNu$fa2e3dfa2278524c59c5eed5d3b14f5ea90e92648e0f25acea81e9d2b374c640');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_59', 'Hypertension_59', '1973-01-01', NULL
FROM Usuario 
WHERE email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_59@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 60
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_60@hypertension-risk.com', 'pbkdf2:sha256:1000000$qWuihd7CBQECVLCp$233e5ca2b6613b053f29c389910e78bad06ef4293543de507dac6d040f5f6ec6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_60', 'Hypertension_60', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_60@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '13.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_60@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 61
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_61@hypertension-risk.com', 'pbkdf2:sha256:1000000$0zjusRFzt2lCxW3s$2ab9e85662480c370a00f77113f652467a38b325c02a698e8c11656ff3afcccb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_61', 'Hypertension_61', '1993-01-01', NULL
FROM Usuario 
WHERE email = 'user_61@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_61@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 62
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_62@hypertension-risk.com', 'pbkdf2:sha256:1000000$KMpXfJrTpKJGVbtf$5126031eb5d862d6db6f7861a62bf58c34080ec1bf52ddbb09166955cbb2f3a0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_62', 'Hypertension_62', '1959-01-01', NULL
FROM Usuario 
WHERE email = 'user_62@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_62@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 63
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_63@hypertension-risk.com', 'pbkdf2:sha256:1000000$qVPT0g6rT8a0fFQu$dcef44c4640a2fe165698ce121da12d316c8b71934d8e40cee0ac004aeb14d9a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_63', 'Hypertension_63', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '38.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_63@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 64
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_64@hypertension-risk.com', 'pbkdf2:sha256:1000000$LTNZTWS0wYagD9Ie$eb5f0084e06fe5237c0cdc6523f5eec148725468740c9d81ee2f2b20c3d5bc91');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_64', 'Hypertension_64', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_64@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_64@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 65
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_65@hypertension-risk.com', 'pbkdf2:sha256:1000000$cRInwOfSi30aY8R4$2fde894079be0821b2aed0f8f420b70480786d787984188e22bc4c43aa8ef2ce');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_65', 'Hypertension_65', '1967-01-01', NULL
FROM Usuario 
WHERE email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_65@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 66
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_66@hypertension-risk.com', 'pbkdf2:sha256:1000000$Ej27GHXFBuUicqYi$3621ebf1cb4fef76628ea194dee49974a51a40d6ff1087d13a27f9081b0be35b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_66', 'Hypertension_66', '1954-01-01', NULL
FROM Usuario 
WHERE email = 'user_66@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_66@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 67
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_67@hypertension-risk.com', 'pbkdf2:sha256:1000000$3aANVr6uOfvKj56x$c2b33d6667ce164ed80ced069ad857a2f4a04d09e0657b4a111e3b44204e51ac');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_67', 'Hypertension_67', '1983-01-01', NULL
FROM Usuario 
WHERE email = 'user_67@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_67@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 68
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_68@hypertension-risk.com', 'pbkdf2:sha256:1000000$nPOhFkTJj5EJP175$19adde4d0440520a186e96294fedf8815dbd03e8e30d2a85b53a096ee101bad9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_68', 'Hypertension_68', '1981-01-01', NULL
FROM Usuario 
WHERE email = 'user_68@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_68@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 69
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_69@hypertension-risk.com', 'pbkdf2:sha256:1000000$DQK9jaHe2beKEgOE$2a82c013d702dfcfa2ad5bd72e5fd188afb48c4e5cb65a467b1427136e0dfae1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_69', 'Hypertension_69', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_69@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 70
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_70@hypertension-risk.com', 'pbkdf2:sha256:1000000$9FXpdC0wM8f2GnCq$91d8d54b119a131ca36714bc5962f13396e45cc011996449ead8c1ab119cb1a6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_70', 'Hypertension_70', '1966-01-01', NULL
FROM Usuario 
WHERE email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_70@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 71
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_71@hypertension-risk.com', 'pbkdf2:sha256:1000000$FYUEJNK9esJNuh4b$7deff7364d1a078c7cdfebf4205099a8a0fbb05a7dbb22086893347989a63d1f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_71', 'Hypertension_71', '1978-01-01', NULL
FROM Usuario 
WHERE email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_71@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 72
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_72@hypertension-risk.com', 'pbkdf2:sha256:1000000$HXzeUky0rT3RffT8$c03aef7839eb66cc73827709e1cce1489b47b0c1f02a0b3449bdbee64f4134d1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_72', 'Hypertension_72', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_72@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_72@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 73
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_73@hypertension-risk.com', 'pbkdf2:sha256:1000000$RNInt2LPJBlUlSvK$822315a9ecb2eac10f2057e3fe8c2d4590f5087fbae1e5961744628d776a4faa');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_73', 'Hypertension_73', '1962-01-01', NULL
FROM Usuario 
WHERE email = 'user_73@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_73@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 74
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_74@hypertension-risk.com', 'pbkdf2:sha256:1000000$ThfsPHPRdkGUx1to$4bac3e6d45447c58895727a098a74b3c0c689f189a21dffcd181cc286fe895ec');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_74', 'Hypertension_74', '1942-01-01', NULL
FROM Usuario 
WHERE email = 'user_74@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_74@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 75
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_75@hypertension-risk.com', 'pbkdf2:sha256:1000000$qnITD4ZxyV4nH1Ak$59b157b84d00814006fde23b6b2c44c12bed17c3b3e83b1209833526a2a5728c');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_75', 'Hypertension_75', '1998-01-01', NULL
FROM Usuario 
WHERE email = 'user_75@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_75@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 76
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_76@hypertension-risk.com', 'pbkdf2:sha256:1000000$iptHqqdTiPTlnsd1$585fbeb42601c88dbab43ae9df9fb49b5a4a8470b082ea844246f0277a908d4b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_76', 'Hypertension_76', '2006-01-01', NULL
FROM Usuario 
WHERE email = 'user_76@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_76@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 77
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_77@hypertension-risk.com', 'pbkdf2:sha256:1000000$vzaECZ0zf87Jw1xf$37e22073df120cc8e3a449e81b77a1166709cb157174abc7f79a0c94bc1d7875');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_77', 'Hypertension_77', '1999-01-01', NULL
FROM Usuario 
WHERE email = 'user_77@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_77@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 78
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_78@hypertension-risk.com', 'pbkdf2:sha256:1000000$DwWFldKiYkkWERho$67872b88b8281002cfe8660f7bff502c9924778a4e59972f566389475b1bb6ef');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_78', 'Hypertension_78', '1944-01-01', NULL
FROM Usuario 
WHERE email = 'user_78@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '4.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_78@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 79
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_79@hypertension-risk.com', 'pbkdf2:sha256:1000000$Eu1KWSl07hNSQiiE$9199cfe717a03fe02a471a62658537cb63f12e10c01194d9b68ef7335ea708f4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_79', 'Hypertension_79', '1996-01-01', NULL
FROM Usuario 
WHERE email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_79@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 80
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_80@hypertension-risk.com', 'pbkdf2:sha256:1000000$SbUIXZddPh8B95zz$0c9ca9271fa1f8148e8b12bce64658c6a6c657f6f785ce59c857cf2dd2850da1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_80', 'Hypertension_80', '1999-01-01', NULL
FROM Usuario 
WHERE email = 'user_80@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_80@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 81
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_81@hypertension-risk.com', 'pbkdf2:sha256:1000000$gQr9RKHtyzT2STCi$7cbbe35361922c227b416e033ce8f79af2c352b777b5f52fcb04b2ce7b651367');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_81', 'Hypertension_81', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_81@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 82
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_82@hypertension-risk.com', 'pbkdf2:sha256:1000000$MLvE0JTWsx4FRPcD$d0da3dc9ed0b43752907762cd1a0d3fa9ee0ff8b51b79f064e573f5f3218cc68');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_82', 'Hypertension_82', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_82@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_82@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 83
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_83@hypertension-risk.com', 'pbkdf2:sha256:1000000$8Utvf4I5BSJXpdq3$76f6521a65d365eea0da1f0a3f0528023d6d93df3fc12b2fffc71e09af7c5f39');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_83', 'Hypertension_83', '1974-01-01', NULL
FROM Usuario 
WHERE email = 'user_83@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_83@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 84
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_84@hypertension-risk.com', 'pbkdf2:sha256:1000000$p8Bes1GX9BND4tHE$5165631f77f55d3eca3c024e37607e7f4a0a7b2a58ff10c79a33a1d42d90fe9a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_84', 'Hypertension_84', '2002-01-01', NULL
FROM Usuario 
WHERE email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_84@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 85
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_85@hypertension-risk.com', 'pbkdf2:sha256:1000000$iJXHXWq8Sz70ZSc9$e8f167291d6777bf487d503b8108f37264f5a532cf243442f3c90d0f30386311');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_85', 'Hypertension_85', '1966-01-01', NULL
FROM Usuario 
WHERE email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_85@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 86
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_86@hypertension-risk.com', 'pbkdf2:sha256:1000000$rQlFIGC1FFlfr79R$8f49a3f2de95ccbae3b1d3f8a0ab90c00bbdc73f0aafce5f83adf0053e3ccc31');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_86', 'Hypertension_86', '1979-01-01', NULL
FROM Usuario 
WHERE email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_86@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 87
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_87@hypertension-risk.com', 'pbkdf2:sha256:1000000$9msTDeBt1kmcjeZI$ded2f30b027b9a854128efbeadfc57085a5cad48c5c7bac9a8365f5562f55bba');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_87', 'Hypertension_87', '2000-01-01', NULL
FROM Usuario 
WHERE email = 'user_87@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_87@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 88
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_88@hypertension-risk.com', 'pbkdf2:sha256:1000000$r49jg9ZEVQQ3RDKY$e960833d1bf0457a23444f7f6f59fdd3f7c7452393b891e70d249f35688bd4e8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_88', 'Hypertension_88', '1995-01-01', NULL
FROM Usuario 
WHERE email = 'user_88@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_88@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 89
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_89@hypertension-risk.com', 'pbkdf2:sha256:1000000$fKln3ENpeAk6taQR$fb3bc05398616b7c5406a84bb6492c3f0b322d368a0632b9132825a494af1ab3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_89', 'Hypertension_89', '1973-01-01', NULL
FROM Usuario 
WHERE email = 'user_89@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_89@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 90
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_90@hypertension-risk.com', 'pbkdf2:sha256:1000000$Cq3uib3o1Arp5B0e$0fd6cdd68daff552e3027d7cb64f1835713bebd5fe975eaabf90228095b6360d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_90', 'Hypertension_90', '1974-01-01', NULL
FROM Usuario 
WHERE email = 'user_90@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_90@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 91
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_91@hypertension-risk.com', 'pbkdf2:sha256:1000000$vIUfifDRCCG18ICc$d5dc5f2a1385de3a520d37303eaef229387ccd36581a1fad5fc9a479512db794');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_91', 'Hypertension_91', '1959-01-01', NULL
FROM Usuario 
WHERE email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_91@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 92
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_92@hypertension-risk.com', 'pbkdf2:sha256:1000000$KW71KVKXch8dviCD$8ea6d6e8558c0b89e9c63be2be1cb8ead0f9e4d7abde3edca6a56921a265b2a9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_92', 'Hypertension_92', '1984-01-01', NULL
FROM Usuario 
WHERE email = 'user_92@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_92@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 93
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_93@hypertension-risk.com', 'pbkdf2:sha256:1000000$AHVjUO0OsHVDJCjZ$621ac834749b439fab3ff2f779c613acdbb88d1bdae0a3f60bee7a08eb26c809');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_93', 'Hypertension_93', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_93@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 94
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_94@hypertension-risk.com', 'pbkdf2:sha256:1000000$XnRHiHChUSlCaqH1$c784a6e3199874ab071eefdd771a55412ae717b3c31ac111d77b8137452f0012');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_94', 'Hypertension_94', '1970-01-01', NULL
FROM Usuario 
WHERE email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_94@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 95
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_95@hypertension-risk.com', 'pbkdf2:sha256:1000000$EIvgnTfeYYGp7GG0$a2e6af352a4750507ae3c812faefbea36ebc914e71b9e189f07f41a603751e7f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_95', 'Hypertension_95', '1963-01-01', NULL
FROM Usuario 
WHERE email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_95@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 96
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_96@hypertension-risk.com', 'pbkdf2:sha256:1000000$t96EwICtToxkKI5e$58badef6db62f4b0c816e57201668a89a0f1fd8ae48d3b254cd7339462f91bbe');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_96', 'Hypertension_96', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_96@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 97
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_97@hypertension-risk.com', 'pbkdf2:sha256:1000000$Qv4HYT8LN0MPuiwB$3cb066a40621e3ec4bfbc59ced63c7b007985c8d68314fcbfcd55012cf4688d8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_97', 'Hypertension_97', '1942-01-01', NULL
FROM Usuario 
WHERE email = 'user_97@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_97@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 98
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_98@hypertension-risk.com', 'pbkdf2:sha256:1000000$Y0EK0s7suZNHVf4i$1f3dfc925017d091f439253ea4dd06193e75f13f9b6ae1e651d2d6b508a088a8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_98', 'Hypertension_98', '1960-01-01', NULL
FROM Usuario 
WHERE email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_98@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 99
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_99@hypertension-risk.com', 'pbkdf2:sha256:1000000$F8kkJiANT92cGDck$6ce04a4cbaba1cdc2ea0c55b6c7703ae1d92fe7c2ab3a00648c85de58aea9857');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_99', 'Hypertension_99', '2004-01-01', NULL
FROM Usuario 
WHERE email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_99@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 100
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_100@hypertension-risk.com', 'pbkdf2:sha256:1000000$pzSjZXpFAYJiI6E0$7d958be84095f4e0cd696f3e17a7b99b5de1a6ba40428c9ed08d2495a4e3e8a9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_100', 'Hypertension_100', '2006-01-01', NULL
FROM Usuario 
WHERE email = 'user_100@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_100@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;


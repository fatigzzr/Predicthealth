# PredictHealth - Sistema de Salud Predictiva

## 📋 Descripción

PredictHealth es un sistema integral de salud predictiva que combina datos biométricos, historial médico, estilo de vida y análisis de documentos para generar predicciones de riesgo de enfermedades utilizando inteligencia artificial.

## 🏗️ Arquitectura de Base de Datos

### Características Principales

- **32 tablas** organizadas en un modelo relacional completo
- **Extensiones PostgreSQL**: uuid-ossp, pgcrypto
- **Vistas especializadas** para dashboards y monitoreo
- **Procedimientos almacenados** para automatización
- **Auditoría completa** de todas las operaciones
- **Soporte para datos geográficos** (GPS)
- **Sistema de alertas automáticas** para valores anómalos
- **Integración con datasets reales** (CDC Diabetes, Kaggle Hypertension)

### Entidades del Sistema (32 tablas)

#### 👤 Gestión de Usuarios (3 tablas)
- **Usuario**: Sistema de autenticación con roles
- **Paciente**: Información demográfica y médica
- **Rol**: Control de acceso (admin, médico, paciente)

#### 🏥 Datos Médicos (8 tablas)
- **Historial_Medico**: Registros médicos históricos
- **Signo_Vital**: Monitoreo en tiempo real (PA, HR, SpO2)
- **Tipo_Signo_Vital**: Tipos de signos vitales
- **Enfermedad**: Catálogo de enfermedades
- **Historial_Enfermedad**: Relación historial-enfermedad
- **Medicamento**: Base de datos de medicamentos
- **Historial_Medicamento**: Relación historial-medicamento
- **Analito**: Parámetros de laboratorio

#### 🤖 Inteligencia Artificial (3 tablas)
- **Prediccion**: Resultados de modelos de IA
- **Modelo**: Metadatos de modelos de ML
- **Recomendacion**: Sugerencias personalizadas

#### 📄 Gestión de Documentos (4 tablas)
- **Documento**: Tipos de documentos médicos
- **Documento_Subido**: Archivos médicos procesados
- **Extracciones_Nlp**: Datos extraídos por NLP
- **Resultado_Lab**: Valores de laboratorio extraídos

#### 📍 Geolocalización (2 tablas)
- **Registros_GPS**: Ubicaciones del usuario
- **Fuente_GPS**: Origen de datos GPS

#### 🔍 Auditoría y Seguridad (2 tablas)
- **Registro_Auditoria**: Logs de auditoría del sistema
- **Refresh_Token**: Tokens de autenticación

#### 📊 Catálogos y Referencias (10 tablas)
- **Entidad**: Catálogo de entidades del sistema
- **Unidad**: Unidades de medida médicas
- **Tipo_Medicion**: Tipos de mediciones médicas
- **Postura**: Posturas para mediciones
- **Dispositivo**: Dispositivos de medición
- **Pregunta**: Preguntas de estilo de vida
- **Respuesta_Estilo_Vida**: Respuestas de cuestionarios
- **Consulta**: Tipos de consultas médicas
- **Enfermedad_Recomendacion**: Relación enfermedad-recomendación
- **Documento_Enfermedad**: Relación documento-enfermedad

## 🚀 Instalación

### Prerrequisitos

- **PostgreSQL 12+** con extensiones uuid-ossp y pgcrypto
- **Usuario con permisos** de superusuario o CREATEDB
- **Python 3.8+** (para scripts de datos)
- **Dependencias Python** (ver requirements.txt)

### Instalación de Dependencias Python

```bash
cd "Base de Datos/Data"
pip install -r requirements.txt
```

### Configuración Completa

1. **Conectarse a PostgreSQL**:
```bash
psql -U postgres
```

2. **Ejecutar el script de inicialización completo**:
```bash
\i "Base de Datos/init.sql"
```

3. **Cargar datos de diabetes** (opcional):
```bash
cd "Base de Datos/Data"
python load_diabetes_dataset.py
psql -d predicthealth -f diabetes_sql_commands.sql
```

4. **Cargar datos de hipertensión** (opcional):
```bash
cd "Base de Datos/Data"
python load_hypertension_dataset.py
psql -d predicthealth -f hypertension_sql_commands.sql
```

5. **Verificar la instalación**:
```bash
\c predicthealth
\dt
SELECT COUNT(*) FROM Usuario;
```

### Estructura de Archivos

```
Base de Datos/
├── init.sql                    # Script principal de inicialización
├── README.md                   # Este archivo
└── Data/
    ├── requirements.txt        # Dependencias Python
    ├── load_diabetes_dataset.py    # Script para cargar datos CDC
    ├── load_hypertension_dataset.py # Script para cargar datos Kaggle
    ├── cdc_diabetes_combined.csv    # Dataset CDC (243,532 registros)
    ├── hypertension_dataset.csv     # Dataset Kaggle (1,985 registros)
    ├── diabetes_sql_commands.sql    # Comandos SQL generados
    └── hypertension_sql_commands.sql # Comandos SQL generados
```

## 📊 Vistas de Dashboard

### Monitoreo de Presión Arterial
```sql
-- Vista completa de PA con min/max/promedio
SELECT * FROM Monitoreo_PA_Completo 
WHERE id_usuario = 1 AND fecha >= '2024-01-01';
```

### Dashboard de Signos Vitales
```sql
-- Resumen de todos los signos vitales
SELECT * FROM Dashboard_Signos_Vitales 
WHERE id_usuario = 1;
```

### Análisis de Laboratorios
```sql
-- Valores de laboratorio con estadísticas
SELECT * FROM Dashboard_Lab 
WHERE id_usuario = 1;
```

### Predicciones de IA
```sql
-- Probabilidades de enfermedades
SELECT * FROM Dashboard_Predicciones 
WHERE id_usuario = 1;
```

### Vista Completa del Dashboard
```sql
-- Vista unificada con todas las métricas
SELECT * FROM Dashboard_Completo 
WHERE id_usuario = 1 AND fecha >= '2024-01-01';
```

## 🔧 Procedimientos Almacenados

### Insertar Signo Vital con Alertas
```sql
CALL insertar_signo_vital(
    p_id_usuario := 1,
    p_id_tipo := 1,
    p_id_dispositivo := 1,
    p_id_postura := 1,
    p_valor := 150.0,
    p_timestamp := NOW()
);
```

### Generar Resumen Diario
```sql
CALL resumen_diario_usuario(1, '2024-01-15');
```

### Calcular Riesgo de Enfermedad
```sql
CALL calcular_riesgo_enfermedad(1);
```

### Obtener Series de Presión Arterial
```sql
CALL obtener_pa_usuario(1, '2024-01-01', '2024-01-31');
```

### Insertar Resultados de Laboratorio
```sql
CALL insertar_resultado_lab(1, 'GLUC', 95.5);
```

## 📈 Casos de Uso

### 1. Monitoreo Continuo
- Registro automático de signos vitales
- Alertas por valores anómalos
- Seguimiento de tendencias

### 2. Análisis Predictivo
- Evaluación de riesgo de enfermedades
- Recomendaciones personalizadas
- Seguimiento de progreso

### 3. Gestión de Documentos
- Procesamiento de reportes médicos
- Extracción automática de datos
- Integración con laboratorios

### 4. Dashboard Clínico
- Visualización unificada de datos
- Métricas de salud en tiempo real
- Reportes automáticos

## 🔐 Seguridad

### Auditoría
- Registro completo de todas las operaciones
- Trazabilidad de cambios
- Logs de acceso y modificaciones

### Autenticación
- Sistema de tokens de actualización
- Hash seguro de contraseñas
- Control de sesiones

### Integridad de Datos
- Restricciones de integridad referencial
- Validaciones de tipos de datos
- Constraints de dominio

## 📊 Scripts de Carga de Datos

### Dataset de Diabetes (CDC)
- **📁 Archivo**: `Data/cdc_diabetes_combined.csv`
- **📊 Registros**: 243,532 pacientes
- **🐍 Script**: `load_diabetes_dataset.py`
- **📄 Salida**: `diabetes_sql_commands.sql`
- **👥 Usuarios generados**: 100 (muestra representativa)
- **🎯 Enfermedad**: Diabetes tipo 2
- **📅 Período**: Datos del CDC 2020-2022

### Dataset de Hipertensión (Kaggle)
- **📁 Archivo**: `Data/hypertension_dataset.csv`
- **📊 Registros**: 1,985 pacientes
- **🐍 Script**: `load_hypertension_dataset.py`
- **📄 Salida**: `hypertension_sql_commands.sql`
- **👥 Usuarios generados**: 100 (muestra representativa)
- **🎯 Enfermedad**: Hipertensión arterial
- **📅 Período**: Datos de Kaggle 2023

### Características de los Scripts

#### ✅ **Compatibilidad Total**
- **init.sql**: Completamente compatible con la estructura de base de datos
- **Relaciones**: Todas las foreign keys respetadas
- **Tipos de datos**: Mapeo correcto de tipos PostgreSQL

#### ✅ **Procesamiento de Datos**
- **Fechas reales**: Calcula fechas de nacimiento basadas en edad actual
- **Contraseñas seguras**: Hash PBKDF2 con Werkzeug (mismo que el sistema)
- **Datos realistas**: Mapeo correcto de valores del dataset original
- **Manejo de NULL**: Valores faltantes manejados apropiadamente

#### ✅ **Datos Generados**
- **Usuarios**: 200 usuarios con credenciales válidas
- **Pacientes**: Información demográfica completa
- **Historial médico**: Registros médicos históricos
- **Estilo de vida**: Respuestas a cuestionarios de salud
- **Predicciones**: Probabilidades de riesgo calculadas

### Uso de los Scripts

```bash
# 1. Instalar dependencias
cd "Base de Datos/Data"
pip install -r requirements.txt

# 2. Cargar datos de diabetes
python load_diabetes_dataset.py
psql -d predicthealth -f diabetes_sql_commands.sql

# 3. Cargar datos de hipertensión
python load_hypertension_dataset.py
psql -d predicthealth -f hypertension_sql_commands.sql

# 4. Verificar carga
psql -d predicthealth -c "SELECT COUNT(*) FROM Usuario;"
```

## ✅ Sistema Completamente Funcional

### 🎯 **Estado Actual**
- ✅ **init.sql**: Incluye todas las correcciones aplicadas
- ✅ **Vistas**: Dashboard_Lab y Dashboard_Completo funcionando correctamente
- ✅ **Procedimientos**: insertar_signo_vital con alertas automáticas
- ✅ **Datos**: 200 usuarios con datos reales de diabetes e hipertensión
- ✅ **Sistema de alertas**: Funcionando con registros de auditoría

## 📋 Estructura de Tablas

### Estructura de Tablas (32 total)

| Categoría | Tablas | Descripción |
|-----------|--------|-------------|
| **👤 Usuarios (3)** | Usuario, Paciente, Rol | Sistema de autenticación y perfiles |
| **🏥 Médicas (8)** | Historial_Medico, Signo_Vital, Tipo_Signo_Vital, Enfermedad, Historial_Enfermedad, Medicamento, Historial_Medicamento, Analito | Datos médicos y farmacológicos |
| **🤖 IA/ML (3)** | Prediccion, Modelo, Recomendacion | Inteligencia artificial y predicciones |
| **📄 Documentos (4)** | Documento, Documento_Subido, Extracciones_Nlp, Resultado_Lab | Procesamiento de documentos médicos |
| **📍 Geolocalización (2)** | Registros_GPS, Fuente_GPS | Datos de ubicación del usuario |
| **🔍 Auditoría (2)** | Registro_Auditoria, Refresh_Token | Seguridad y trazabilidad |
| **📊 Catálogos (10)** | Entidad, Unidad, Tipo_Medicion, Postura, Dispositivo, Pregunta, Respuesta_Estilo_Vida, Consulta, Enfermedad_Recomendacion, Documento_Enfermedad | Datos de referencia del sistema |

### Datos de Prueba Disponibles

| Tabla | Registros | Fuente | Descripción |
|-------|-----------|--------|-------------|
| **Rol** | 2 | Manual | Admin, Paciente |
| **Usuario** | 200 | CDC + Kaggle | 100 diabetes + 100 hipertensión |
| **Paciente** | 200 | CDC + Kaggle | Datos demográficos reales |
| **Enfermedad** | 2 | Manual | Diabetes, Hipertensión |
| **Recomendacion** | 17 | Manual | Sugerencias de salud personalizadas |
| **Documento** | 6 | Manual | Tipos de documentos médicos |
| **Entidad** | 32 | Manual | Catálogo de entidades del sistema |
| **Unidad** | 9 | Manual | Unidades de medida médicas |
| **Tipo_Medicion** | 7 | Manual | Tipos de mediciones médicas |
| **Consulta** | 9 | Manual | Tipos de consultas médicas |
| **Postura** | 1 | Manual | Postura para mediciones |
| **Analito** | 5 | Manual | Parámetros de laboratorio |
| **Dispositivo** | 2 | Manual | Omron, Fitbit |
| **Medicamento** | 5 | Manual | Medicamentos comunes |
| **Pregunta** | 12 | Manual | Preguntas de estilo de vida |
| **Documento_Enfermedad** | 7 | Manual | Relaciones documento-enfermedad |

### Características de los Datos

- **✅ Datos reales**: Basados en datasets CDC y Kaggle
- **✅ Fechas calculadas**: Edades convertidas a fechas de nacimiento reales
- **✅ Contraseñas seguras**: Hash PBKDF2 con Werkzeug
- **✅ Integridad referencial**: Todas las relaciones respetadas
- **✅ Datos médicos**: Historial médico y respuestas de estilo de vida
- **✅ Predicciones**: Probabilidades de riesgo calculadas

## 🛠️ Mantenimiento

### Limpieza de Datos
```sql
-- Limpiar tokens expirados
DELETE FROM Refresh_Token 
WHERE expiracion < NOW() AND revocado = TRUE;
```

### Optimización
```sql
-- Analizar estadísticas de tablas
ANALYZE;

-- Reindexar si es necesario
REINDEX DATABASE predicthealth;
```

### Backup
```bash
# Backup completo
pg_dump predicthealth > backup_predicthealth.sql

# Restaurar
psql predicthealth < backup_predicthealth.sql
```

## 🎯 Estado Actual del Sistema

### ✅ Funcionalidades Completamente Operativas

#### 📊 **Dashboards y Vistas**
- **Dashboard_Completo**: Vista principal con todas las métricas
- **Dashboard_Predicciones**: Predicciones de IA por usuario
- **Dashboard_Lab**: Análisis de laboratorios (corregida)
- **Dashboard_Estilo_Vida**: Respuestas de estilo de vida
- **Monitoreo_PA_Completo**: Monitoreo de presión arterial

#### ⚕️ **Procedimientos Automatizados**
- **insertar_signo_vital**: Con alertas automáticas para PA alta
- **resumen_diario_usuario**: Resumen completo de salud
- **calcular_riesgo_enfermedad**: Cálculo de riesgo de enfermedades
- **obtener_pa_usuario**: Series temporales de presión arterial
- **insertar_resultado_lab**: Inserción de resultados de laboratorio

#### 🚨 **Sistema de Alertas**
- **Detección automática**: PA sistólica > 140 mmHg
- **Registro de auditoría**: Entidad "Signo_Vital", acción "CREATE"
- **Detalles JSON**: `{"valor": 150, "mensaje": "PA sistólica alta"}`

### 📈 **Datos de Prueba Disponibles**

#### 👥 **Usuarios (200 total)**
- **100 usuarios diabetes**: Datos reales del CDC
- **100 usuarios hipertensión**: Datos reales de Kaggle
- **Edades**: 19-86 años (diabetes), 19-83 años (hipertensión)
- **Fechas de nacimiento**: Calculadas correctamente

#### 📊 **Datos Médicos**
- **Historial_Medico**: 800 registros (4 por usuario diabetes + 2 por usuario hipertensión)
- **Respuesta_Estilo_Vida**: 1,300 registros (8 por usuario diabetes + 5 por usuario hipertensión)
- **Prediccion**: 200 registros (1 por usuario)
- **Signo_Vital**: Datos de prueba con alertas automáticas

---

**Versión**: 2.0  
**Última actualización**: Octubre 2025
**Compatibilidad**: PostgreSQL 12+  
**Estado**: ✅ Completamente Funcional
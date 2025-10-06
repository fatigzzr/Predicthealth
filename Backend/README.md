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

### Entidades Principales

#### 👤 Gestión de Usuarios
- **Usuario**: Sistema de autenticación con roles
- **Paciente**: Información demográfica y médica
- **Rol**: Control de acceso (admin, médico, paciente)

#### 🏥 Datos Médicos
- **Historial_Medico**: Registros médicos históricos
- **Signo_Vital**: Monitoreo en tiempo real (PA, HR, SpO2)
- **Enfermedad**: Catálogo de enfermedades
- **Medicamento**: Base de datos de medicamentos
- **Analito**: Parámetros de laboratorio

#### 🤖 Inteligencia Artificial
- **Prediccion**: Resultados de modelos de IA
- **Modelo**: Metadatos de modelos de ML
- **Recomendacion**: Sugerencias personalizadas

#### 📄 Gestión de Documentos
- **Documento_Subido**: Archivos médicos procesados
- **Extracciones_Nlp**: Datos extraídos por NLP
- **Resultado_Lab**: Valores de laboratorio extraídos

#### 📍 Geolocalización
- **Registros_GPS**: Ubicaciones del usuario
- **Fuente_GPS**: Origen de datos GPS

## 🚀 Instalación

### Prerrequisitos

- PostgreSQL 12+ 
- Usuario con permisos de superusuario o CREATEDB
- Python 3.8+ (para scripts de datos)
- Werkzeug (para hash de contraseñas)

### Configuración Completa

1. **Conectarse a PostgreSQL**:
```bash
psql -U postgres
```

2. **Ejecutar el script de inicialización completo**:
```bash
\i Backend/init.sql
```

3. **Cargar datos de diabetes** (opcional):
```bash
cd Backend/Data
python load_diabetes_dataset.py
psql -d predicthealth -f diabetes_sql_commands.sql
```

4. **Cargar datos de hipertensión** (opcional):
```bash
cd Backend/Data
python load_hypertension_dataset.py
psql -d predicthealth -f hypertension_sql_commands.sql
```

5. **Verificar la instalación**:
```bash
\c predicthealth
\dt
SELECT COUNT(*) FROM Usuario;
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

## 📊 Scripts de Datos

### Dataset de Diabetes (CDC)
- **Archivo**: `Data/cdc_diabetes_combined.csv`
- **Registros**: 243,532 pacientes
- **Script**: `load_diabetes_dataset.py`
- **Salida**: `diabetes_sql_commands.sql`
- **Usuarios generados**: 100 (muestra representativa)

### Dataset de Hipertensión
- **Archivo**: `Data/hypertension_dataset.csv`
- **Registros**: 1,985 pacientes
- **Script**: `load_hypertension_dataset.py`
- **Salida**: `hypertension_sql_commands.sql`
- **Usuarios generados**: 100 (muestra representativa)

### Características de los Scripts
- ✅ **Compatibilidad**: Totalmente compatibles con `init.sql`
- ✅ **Fechas reales**: Calcula fechas de nacimiento basadas en edad
- ✅ **Contraseñas seguras**: Hash PBKDF2 con Werkzeug
- ✅ **Datos realistas**: Mapeo correcto de valores del dataset
- ✅ **Integridad**: Manejo correcto de valores NULL y tipos de datos

## ✅ Sistema Completamente Funcional

### 🎯 **Estado Actual**
- ✅ **init.sql**: Incluye todas las correcciones aplicadas
- ✅ **Vistas**: Dashboard_Lab y Dashboard_Completo funcionando correctamente
- ✅ **Procedimientos**: insertar_signo_vital con alertas automáticas
- ✅ **Datos**: 200 usuarios con datos reales de diabetes e hipertensión
- ✅ **Sistema de alertas**: Funcionando con registros de auditoría

## 📋 Estructura de Tablas

### Tablas Principales (32 total)

| Categoría | Tablas |
|-----------|--------|
| **Usuarios** | Usuario, Paciente, Rol |
| **Médicas** | Historial_Medico, Signo_Vital, Enfermedad, Medicamento |
| **IA/ML** | Prediccion, Modelo, Recomendacion |
| **Documentos** | Documento_Subido, Extracciones_Nlp, Resultado_Lab |
| **Geolocalización** | Registros_GPS, Fuente_GPS |
| **Auditoría** | Registro_Auditoria, Refresh_Token |
| **Catálogos** | Unidad, Tipo_Medicion, Analito, etc. |

### Datos Insertados (17 tablas con contenido)

| Tabla | Registros | Descripción |
|-------|-----------|-------------|
| **Rol** | 2 | Admin, Paciente |
| **Usuario** | 200 | 100 diabetes + 100 hipertensión |
| **Paciente** | 200 | Datos demográficos completos |
| **Enfermedad** | 2 | Diabetes, Hipertensión |
| **Recomendacion** | 17 | Sugerencias de salud |
| **Documento** | 6 | Tipos de documentos médicos |
| **Entidad** | 32 | Catálogo de entidades del sistema |
| **Unidad** | 9 | Unidades de medida |
| **Tipo_Medicion** | 7 | Tipos de mediciones médicas |
| **Consulta** | 9 | Tipos de consultas |
| **Postura** | 1 | Postura para mediciones |
| **Analito** | 5 | Parámetros de laboratorio |
| **Dispositivo** | 2 | Omron, Fitbit |
| **Tipo_Medicion** | 7 | Tipos de mediciones |
| **Medicamento** | 5 | Medicamentos comunes |
| **Pregunta** | 12 | Preguntas de estilo de vida |
| **Documento_Enfermedad** | 7 | Relaciones documento-enfermedad |

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

## 🔍 Ejemplos de Consultas Útiles

### Verificar Estado del Sistema
```sql
-- Conteo de usuarios por tipo
SELECT 
    CASE 
        WHEN email LIKE '%diabetes%' THEN 'Diabetes'
        WHEN email LIKE '%hypertension%' THEN 'Hipertensión'
        ELSE 'Otro'
    END as tipo,
    COUNT(*) as usuarios
FROM Usuario 
GROUP BY tipo;

-- Verificar alertas generadas
SELECT * FROM Registro_Auditoria 
WHERE accion = 'CREATE' 
ORDER BY fecha_hora DESC;
```

### Análisis de Salud
```sql
-- Usuarios con mayor riesgo de diabetes
SELECT u.email, p.nombre, pr.probabilidad
FROM Usuario u
JOIN Paciente p ON u.id_usuario = p.id_usuario
JOIN Prediccion pr ON u.id_usuario = pr.id_usuario
WHERE pr.probabilidad > 0.5
ORDER BY pr.probabilidad DESC;

-- Resumen de presión arterial por usuario
SELECT 
    u.email,
    AVG(sv.valor) as pa_promedio,
    MIN(sv.valor) as pa_min,
    MAX(sv.valor) as pa_max
FROM Usuario u
JOIN Signo_Vital sv ON u.id_usuario = sv.id_usuario
JOIN Tipo_Signo_Vital t ON sv.id_tipo = t.id_tipo
WHERE t.nombre = 'BP_sistolica'
GROUP BY u.email;
```

### Monitoreo de Alertas
```sql
-- Alertas de PA alta en las últimas 24 horas
SELECT 
    u.email,
    ra.fecha_hora,
    ra.detalles->>'valor' as valor_pa,
    ra.detalles->>'mensaje' as mensaje
FROM Registro_Auditoria ra
JOIN Usuario u ON ra.id_usuario = u.id_usuario
WHERE ra.accion = 'CREATE'
  AND ra.fecha_hora >= NOW() - INTERVAL '24 hours'
ORDER BY ra.fecha_hora DESC;
```

## 🚀 Próximos Pasos

### Integración con Frontend
- API REST para consultar dashboards
- WebSocket para alertas en tiempo real
- Autenticación JWT con tokens de actualización

### Machine Learning
- Entrenamiento de modelos con datos reales
- Predicciones automáticas basadas en historial
- Recomendaciones personalizadas

### Monitoreo Avanzado
- Alertas por email/SMS
- Notificaciones push
- Reportes automáticos

## 📞 Soporte

Para soporte técnico o consultas sobre la implementación, contactar al equipo de desarrollo.

---

**Versión**: 2.0  
**Última actualización**: Octubre 2025  
**Compatibilidad**: PostgreSQL 12+  
**Estado**: ✅ Completamente Funcional
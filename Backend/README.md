# PredictHealth - Backend API

## 📋 Descripción

Backend API desarrollado en Flask (Python) para el sistema PredictHealth. Proporciona endpoints REST para autenticación, gestión de datos médicos, dashboards y predicciones de salud.

## 🏗️ Arquitectura

### Tecnologías Utilizadas
- **Framework**: Flask 2.3.3
- **Base de Datos**: PostgreSQL con psycopg2
- **Autenticación**: JWT (PyJWT)
- **CORS**: Flask-CORS para comunicación frontend
- **Pool de Conexiones**: psycopg2.pool para gestión eficiente de BD

### Estructura del Backend
```
Backend/
├── app.py                    # Aplicación principal Flask
├── requirements.txt          # Dependencias Python
└── README.md               # Este archivo
```

## 🚀 Instalación

### Prerrequisitos
- Python 3.8+
- PostgreSQL 12+
- pip3

### Instalación Automática
```bash
# Ejecutar desde la raíz del proyecto
./setup.sh
```

### Instalación Manual
```bash
# 1. Instalar dependencias
pip3 install -r requirements.txt

# 2. Configurar variables de entorno
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=predicthealth
export PGUSER=predicthealth_user
export PGPASSWORD=666
export JWT_SECRET=dev-secret-change-me
export JWT_EXPIRES_MIN=60

# 3. Ejecutar aplicación
python3 app.py
```

## 🔧 Configuración

### Variables de Entorno
| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `PGHOST` | Host de PostgreSQL | localhost |
| `PGPORT` | Puerto de PostgreSQL | 5432 |
| `PGDATABASE` | Nombre de la base de datos | predicthealth |
| `PGUSER` | Usuario de PostgreSQL | predicthealth_user |
| `PGPASSWORD` | Contraseña de PostgreSQL | 666 |
| `JWT_SECRET` | Clave secreta para JWT | dev-secret-change-me |
| `JWT_EXPIRES_MIN` | Tiempo de expiración JWT (min) | 60 |

### Pool de Conexiones
- **Mínimo**: 1 conexión
- **Máximo**: 5 conexiones
- **Gestión**: Automática con psycopg2.pool

## 📡 API Endpoints

### Autenticación
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/login` | Iniciar sesión |
| `GET` | `/api/me` | Obtener datos del usuario actual |

### Gestión de Entidades
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/entidades` | Listar todas las entidades |
| `GET` | `/api/entidades/<nombre>` | Obtener datos de una entidad |
| `POST` | `/api/entidades/<nombre>` | Crear registro |
| `PUT` | `/api/entidades/<nombre>/<id>` | Actualizar registro |
| `DELETE` | `/api/entidades/<nombre>/<id>` | Eliminar registro |

### Dashboards
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/dashboard/monitoreo-pa` | Dashboard de presión arterial |
| `GET` | `/api/dashboard/signos-vitales` | Dashboard de signos vitales |
| `GET` | `/api/dashboard/lab` | Dashboard de laboratorio |
| `GET` | `/api/dashboard/estilo-vida` | Dashboard de estilo de vida |
| `GET` | `/api/dashboard/predicciones` | Dashboard de predicciones |
| `GET` | `/api/dashboard/medicacion` | Dashboard de medicación |
| `GET` | `/api/dashboard/documentos` | Dashboard de documentos |
| `GET` | `/api/dashboard/auditoria` | Dashboard de auditoría |

### KPIs y Métricas
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/dashboard/kpis` | Indicadores clave |
| `GET` | `/api/dashboard/kpis/usuarios-por-rol` | Usuarios por rol |
| `GET` | `/api/dashboard/kpis/frecuencia-diaria` | Frecuencia diaria |
| `GET` | `/api/dashboard/kpis/crecimiento-semanal` | Crecimiento semanal |
| `GET` | `/api/dashboard/kpis/actividad-usuarios` | Actividad de usuarios |
| `GET` | `/api/dashboard/kpis/resumen-ejecutivo` | Resumen ejecutivo |

### Gráficos
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/dashboard/graficos/predicciones-por-mes` | Predicciones por mes |
| `GET` | `/api/dashboard/graficos/distribucion-enfermedades` | Distribución de enfermedades |
| `GET` | `/api/dashboard/graficos/estado-documentos` | Estado de documentos |
| `GET` | `/api/dashboard/graficos/distribucion-demografica` | Distribución demográfica |
| `GET` | `/api/dashboard/graficos/crecimiento-acumulado-usuarios` | Crecimiento acumulado |
| `GET` | `/api/dashboard/graficos/top-usuarios-activos` | Top usuarios activos |

## 🔐 Autenticación

### JWT Token
- **Algoritmo**: HS256
- **Expiración**: 60 minutos (configurable)
- **Header**: `Authorization: Bearer <token>`

### Ejemplo de Uso
```bash
# Login
curl -X POST http://localhost:5001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@admin.com", "password": "admin"}'

# Usar token
curl -X GET http://localhost:5001/api/me \
  -H "Authorization: Bearer <token>"
```

## 🗄️ Base de Datos

### Conexión
- **Driver**: psycopg2
- **Pool**: SimpleConnectionPool (1-5 conexiones)
- **Transacciones**: Automáticas con BEGIN/COMMIT/ROLLBACK

### Stored Procedures
El backend utiliza stored procedures de PostgreSQL para:
- **Autenticación**: `sp_login_staff()`
- **Gestión de datos**: `sp_get_entidades()`, `sp_get_entidad_data()`
- **Dashboards**: `sp_dashboard_*()`
- **CRUD**: `sp_insert_record()`, `sp_update_by_pk()`, `sp_delete_by_pk()`

## 📊 Características

### Seguridad
- ✅ **Autenticación JWT** con expiración
- ✅ **Validación de tokens** en cada request
- ✅ **Sanitización de inputs** con regex
- ✅ **Auditoría completa** de operaciones
- ✅ **Manejo seguro de errores**

### Performance
- ✅ **Pool de conexiones** para eficiencia
- ✅ **Stored procedures** para consultas optimizadas
- ✅ **Transacciones** para consistencia
- ✅ **Caching** de conexiones

### Monitoreo
- ✅ **Health check** endpoint (`/api/health`)
- ✅ **Logging de auditoría** automático
- ✅ **Manejo de errores** estructurado
- ✅ **Métricas de rendimiento**

## 🚨 Manejo de Errores

### Códigos de Estado
- **200**: Éxito
- **400**: Error de validación
- **401**: No autenticado
- **404**: Recurso no encontrado
- **500**: Error interno del servidor

### Formato de Error
```json
{
  "error": "tipo_error",
  "message": "Descripción del error"
}
```

## 🔧 Desarrollo

### Estructura del Código
- **Configuración**: Variables de entorno y pool de conexiones
- **Autenticación**: JWT helpers y middleware
- **Endpoints**: Organizados por funcionalidad
- **Base de datos**: Helpers para conexiones y stored procedures

### Debugging
```bash
# Ejecutar en modo debug
export FLASK_ENV=development
python3 app.py
```

### Logs
- **Auditoría**: Registro automático en `Registro_Auditoria`
- **Errores**: Logs en consola con timestamps
- **Debug**: Información detallada en modo desarrollo

## 📈 Métricas

### Endpoints Disponibles
- **50+ endpoints** REST
- **8 dashboards** especializados
- **6 tipos de gráficos** para visualización
- **Sistema de KPIs** completo

### Datos Soportados
- **32+ tablas** de base de datos
- **Stored procedures** para todas las operaciones
- **Vistas especializadas** para dashboards
- **Sistema de alertas** automáticas

## 🛠️ Mantenimiento

### Backup
```bash
# Backup de base de datos
pg_dump predicthealth > backup.sql

# Restaurar
psql predicthealth < backup.sql
```

### Monitoreo
```bash
# Verificar estado
curl http://localhost:5001/api/health

# Verificar conexión BD
psql -U predicthealth_user -d predicthealth -c "SELECT version();"
```

### Actualización
```bash
# Actualizar dependencias
pip3 install -r requirements.txt --upgrade

# Reiniciar servicio
pkill -f "python3 app.py"
python3 app.py &
```

---

**Versión**: 2.0  
**Última actualización**: Diciembre 2024  
**Estado**: ✅ Funcional  
**Puerto**: 5001  
**Base de datos**: PostgreSQL

# PredictHealth - README de Instalación y Puesta en Marcha

## 📋 Requisitos Previos

### Versiones de Software
- **Python 3.8+** (para backend Flask)
- **Node.js 16+** (para aplicación web React)
- **PostgreSQL 12+** (para base de datos)
- **npm** (gestor de paquetes Node.js)
- **pip** (gestor de paquetes Python)

### Dependencias del Sistema
- **PostgreSQL** con extensiones `uuid-ossp` y `pgcrypto`
- **Usuario PostgreSQL** con permisos de superusuario o CREATEDB
- **Puerto 5001** disponible para backend
- **Puerto 3000** disponible para frontend
- **Puerto 5432** disponible para PostgreSQL

## 🚀 Instalación Paso a Paso

### 1. Configurar Base de Datos

#### 1.1 Instalar PostgreSQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# macOS (con Homebrew)
brew install postgresql
brew services start postgresql

# Windows
# Descargar desde: https://www.postgresql.org/download/windows/
```

#### 1.2 Configurar PostgreSQL
```bash
# Conectarse a PostgreSQL como superusuario
sudo -u postgres psql

# Crear usuario y base de datos
CREATE USER predicthealth_user WITH PASSWORD '666';
CREATE DATABASE predicthealth OWNER predicthealth_user;
GRANT ALL PRIVILEGES ON DATABASE predicthealth TO predicthealth_user;
\q
```

#### 1.3 Ejecutar Script de Inicialización
```bash
# Ejecutar script principal de base de datos
psql -U postgres -d predicthealth -f "Base de Datos/init.sql"
```

#### 1.4 Cargar Datos de Prueba (Opcional)
```bash
# Navegar a carpeta de datos
cd "Base de Datos/Data"

# Instalar dependencias Python para scripts
pip install -r requirements.txt

# Cargar datos de diabetes (CDC)
python load_diabetes_dataset.py
psql -d predicthealth -f diabetes_sql_commands.sql

# Cargar datos de hipertensión (Kaggle)
python load_hypertension_dataset.py
psql -d predicthealth -f hypertension_sql_commands.sql
```

### 2. Configurar Backend (Flask)

#### 2.1 Instalar Dependencias
```bash
# Navegar a carpeta backend
cd Backend

# Instalar dependencias Python
pip install -r requirements.txt
```

#### 2.2 Configurar Variables de Entorno
```bash
# Configurar variables de entorno
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=predicthealth
export PGUSER=predicthealth_user
export PGPASSWORD=666
export JWT_SECRET=dev-secret-change-me
export JWT_EXPIRES_MIN=60
export FLASK_APP=app.py
export FLASK_ENV=development
```

#### 2.3 Ejecutar Backend
```bash
# Ejecutar servidor Flask
flask run --host=0.0.0.0 --port=5001

# O alternativamente:
python app.py
```

### 3. Configurar Frontend (React)

#### 3.1 Instalar Dependencias
```bash
# Navegar a carpeta web
cd app/web

# Instalar dependencias Node.js
npm install
```

#### 3.2 Ejecutar Frontend
```bash
# Ejecutar servidor de desarrollo
npm start
```

## 🔧 Verificación de Instalación

### 1. Verificar Backend
```bash
# Probar endpoint de salud
curl http://localhost:5001/api/health

# Respuesta esperada:
# {"status": "ok"}
```

### 2. Verificar Base de Datos
```bash
# Conectarse a PostgreSQL
psql -U predicthealth_user -d predicthealth

# Verificar tablas
\dt

# Verificar datos
SELECT COUNT(*) FROM Usuario;
SELECT COUNT(*) FROM Paciente;

# Salir
\q
```

### 3. Verificar Frontend
- Abrir navegador en: `http://localhost:3000`
- Debería cargar la interfaz de PredictHealth

## 🔐 Credenciales de Acceso

### Credenciales del Sistema
- **Usuario Administrador:** `admin@admin.com`
- **Contraseña:** `admin`
- **Rol:** Administrador

### Credenciales de Base de Datos
- **Usuario:** `predicthealth_user`
- **Contraseña:** `666`
- **Base de datos:** `predicthealth`
- **Puerto:** `5432`

### Credenciales de Desarrollo
- **Backend API:** `http://localhost:5001`
- **Frontend Web:** `http://localhost:3000`
- **Base de datos:** `localhost:5432`

## 🌐 Acceso al Sistema

### URLs de Acceso
- **Aplicación Web:** http://localhost:3000
- **API Backend:** http://localhost:5001
- **Documentación API:** http://localhost:5001/api/health

### Flujo de Acceso
1. **Abrir navegador** en `http://localhost:3000`
2. **Iniciar sesión** con credenciales de administrador
3. **Explorar dashboards** y funcionalidades
4. **Verificar datos** en las diferentes secciones

## 🛠️ Solución de Problemas

### Error de Conexión a Base de Datos
```bash
# Verificar que PostgreSQL esté ejecutándose
sudo systemctl status postgresql

# Verificar credenciales
psql -U predicthealth_user -d predicthealth -h localhost
```

### Error de Puerto en Uso
```bash
# Verificar puertos en uso
netstat -tulpn | grep :5001
netstat -tulpn | grep :3000

# Matar proceso si es necesario
sudo kill -9 <PID>
```

### Error de Dependencias Python
```bash
# Reinstalar dependencias
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall
```

### Error de Dependencias Node.js
```bash
# Limpiar cache y reinstalar
rm -rf node_modules package-lock.json
npm install
```

## 📊 Datos de Prueba Disponibles

### Usuarios Generados
- **200 usuarios** con datos reales
- **100 usuarios diabetes** (dataset CDC)
- **100 usuarios hipertensión** (dataset Kaggle)

### Datos Médicos
- **Historial médico** completo
- **Signos vitales** con alertas automáticas
- **Predicciones de IA** calculadas
- **Respuestas de estilo de vida**

### Dashboards Funcionales
- **Monitoreo de Presión Arterial**
- **Signos Vitales**
- **Análisis de Laboratorio**
- **Estilo de Vida**
- **Predicciones de IA**
- **KPIs y Métricas**

## 🎯 Estado del Sistema

### ✅ Componentes Funcionales
- **Backend API:** Flask con 50+ endpoints
- **Frontend Web:** React con dashboards
- **Base de Datos:** PostgreSQL con 32+ tablas
- **Autenticación:** JWT con roles
- **Auditoría:** Sistema completo de logs

### 📈 Métricas del Sistema
- **32+ tablas** en base de datos
- **50+ endpoints** API REST
- **8 dashboards** especializados
- **6 tipos de gráficos** para visualización
- **Sistema de alertas** automáticas

---

**Versión:** 2.0  
**Última actualización:** Diciembre 2024  
**Estado:** ✅ Completamente Funcional  
**Compatibilidad:** Python 3.8+, Node.js 16+, PostgreSQL 12+

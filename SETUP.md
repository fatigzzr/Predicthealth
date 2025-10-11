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

### 0. Configuración Previa (Google Cloud)

#### 0.1 Configurar Permisos de Archivos
```bash
# Dar permisos de lectura al directorio home para otros usuarios
sudo chmod 755 /home/fati
sudo chmod 755 /home/fati/Predicthealth
sudo chmod 755 "/home/fati/Predicthealth/Base de Datos"
sudo chmod 644 "/home/fati/Predicthealth/Base de Datos/init.sql"
```

#### 0.2 Configurar Firewall (Google Cloud)
```bash
# Configurar reglas de firewall para Google Cloud
gcloud compute firewall-rules create allow-predicthealth-frontend --allow tcp:3000 --source-ranges 0.0.0.0/0
gcloud compute firewall-rules create allow-predicthealth-backend --allow tcp:5001 --source-ranges 0.0.0.0/0
```

**O desde Google Cloud Console:**
1. Ve a **VPC Network > Firewall**
2. Crea regla para puerto **3000** (frontend)
3. Crea regla para puerto **5001** (backend)
4. Aplica a **todas las instancias**

**⚠️ Importante para Google Cloud:**
- Los puertos 3000 y 5001 deben estar abiertos en el firewall de Google Cloud
- Sin estas reglas, no podrás acceder desde IPs externas
- Las reglas se aplican a todas las instancias de la red

### 1. Configurar Base de Datos

#### 1.1 Instalar PostgreSQL

**Instalación Estándar:**
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

**Instalación PostgreSQL 14 (Google Cloud/CentOS/RHEL):**
```bash
# 1. Detener PostgreSQL actual
sudo systemctl stop postgresql

# 2. Instalar PostgreSQL 14 con repositorio oficial
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# 3. Instalar PostgreSQL 14 (bypass GPG signature)
sudo yum install -y postgresql14-server postgresql14 postgresql14-contrib --nogpgcheck

# 4. Inicializar base de datos
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb

# 5. Iniciar y habilitar PostgreSQL 14
sudo systemctl start postgresql-14
sudo systemctl enable postgresql-14

# 6. Verificar instalación
psql-14 --version
```

**📋 Notas Importantes para PostgreSQL 14:**
- `--nogpgcheck` evita errores de verificación GPG
- PostgreSQL 14 se instala en `/usr/pgsql-14/`
- El servicio se llama `postgresql-14` (no `postgresql`)
- Usar `psql-14` en lugar de `psql` para evitar warnings de versión

**🔧 Solución de Problemas PostgreSQL 14:**
Si PostgreSQL 14 falla al iniciar, ejecuta estos pasos:

```bash
# 1. Detener todos los servicios PostgreSQL
sudo systemctl stop postgresql
sudo systemctl stop postgresql-14

# 2. Limpiar directorio corrupto
sudo rm -rf /var/lib/pgsql/14/data

# 3. Crear directorio limpio
sudo mkdir -p /var/lib/pgsql/14/data
sudo chown postgres:postgres /var/lib/pgsql/14/data
sudo chmod 700 /var/lib/pgsql/14/data

# 4. Reinicializar PostgreSQL 14
sudo -u postgres /usr/pgsql-14/bin/initdb -D /var/lib/pgsql/14/data

# 5. Iniciar el servicio
sudo systemctl start postgresql-14
sudo systemctl enable postgresql-14
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

**Para PostgreSQL estándar:**
```bash
# Ejecutar script principal de base de datos
psql -U postgres -d predicthealth -f "Base de Datos/init.sql"
```

**Para PostgreSQL 14 (Google Cloud):**
```bash
# Usar psql-14 para evitar warnings de versión
sudo -u postgres psql-14 -d predicthealth -f "Base de Datos/init.sql"
```

#### 1.4 Cargar Datos de Prueba (Opcional)

**Para PostgreSQL estándar:**
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

**Para PostgreSQL 14 (Google Cloud):**
```bash
# Navegar a carpeta de datos
cd "Base de Datos/Data"

# Instalar dependencias Python para scripts
pip install -r requirements.txt

# Cargar datos de diabetes (CDC)
python load_diabetes_dataset.py
sudo -u postgres psql-14 -d predicthealth -f diabetes_sql_commands.sql

# Cargar datos de hipertensión (Kaggle)
python load_hypertension_dataset.py
sudo -u postgres psql-14 -d predicthealth -f hypertension_sql_commands.sql
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

**Para PostgreSQL estándar:**
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

**Para PostgreSQL 14 (Google Cloud):**
```bash
# Conectarse a PostgreSQL 14
sudo -u postgres psql-14 -U predicthealth_user -d predicthealth

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

### Error de Permisos de Archivos
```bash
# Si encuentras errores de "Permission denied" al ejecutar scripts
sudo chmod 755 /home/fati
sudo chmod 755 /home/fati/Predicthealth
sudo chmod 755 "/home/fati/Predicthealth/Base de Datos"
sudo chmod 644 "/home/fati/Predicthealth/Base de Datos/init.sql"
```

### Error de Firewall (Google Cloud)
```bash
# Verificar reglas de firewall existentes
gcloud compute firewall-rules list

# Crear reglas si no existen
gcloud compute firewall-rules create allow-predicthealth-frontend --allow tcp:3000 --source-ranges 0.0.0.0/0
gcloud compute firewall-rules create allow-predicthealth-backend --allow tcp:5001 --source-ranges 0.0.0.0/0

# Verificar que las reglas estén activas
gcloud compute firewall-rules describe allow-predicthealth-frontend
gcloud compute firewall-rules describe allow-predicthealth-backend
```

### Error de Conexión a Base de Datos
```bash
# Verificar que PostgreSQL esté ejecutándose
sudo systemctl status postgresql

# Para PostgreSQL 14
sudo systemctl status postgresql-14

# Verificar credenciales
psql -U predicthealth_user -d predicthealth -h localhost

# Para PostgreSQL 14
sudo -u postgres psql-14 -U predicthealth_user -d predicthealth
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

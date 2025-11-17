# PredictHealth - Sistema de Salud Predictiva

Plataforma integral de IA para predicción de enfermedades crónicas (diabetes e hipertensión) con análisis de datos biométricos, historial médico y estilo de vida.

## 🏗️ Arquitectura del Sistema

### Componentes Principales
- **🌐 Frontend Web**: React.js con dashboard administrativo
- **📱 App Móvil**: Android nativo (Kotlin)
- **⚙️ Backend**: Flask (Python) con API REST
- **🗄️ Base de Datos**: PostgreSQL con 32+ tablas
- **🤖 IA/ML**: Modelos predictivos para diabetes e hipertensión

### Estructura del Proyecto
```
Predicthealth/
├── app/
│   ├── web/          # Frontend React
│   ├── java/          # App Java
│   └── android/       # App Android
├── Backend/           # API Flask
├── Base de Datos/     # PostgreSQL + Scripts
└── services/          # Microservicios
```

## 🚀 Instalación Rápida

### Instalación Automática (Recomendada)

Primero, deben habilitarse las siguientes reglas de firewall para GCP:

```
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

Después, se debe correr el siguiente código dentro del folder Predicthealth. Cumple con 4 pasos:

1. Da permisos para ejecutar el script setup.sh.
2. Da permisos para acceder a archivos del repositorio.
3. Instala y habilita postgresql-14
4. Corre el archivo de instalación.

```
chmod +x setup.sh

sudo chmod 755 ~
sudo chmod 755 .
sudo chmod 755 "Base de Datos"
sudo chmod 644 "Base de Datos/init.sql"

sudo systemctl stop postgresql
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y postgresql14-server postgresql14 postgresql14-contrib --nogpgcheck
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl start postgresql-14
sudo systemctl enable postgresql-14

./setup.sh
```

**📋 Notas Importantes:**
- `--nogpgcheck` evita errores de verificación GPG
- PostgreSQL 14 se instala en `/usr/pgsql-14/`
- El servicio se llama `postgresql-14` (no `postgresql`)
- Usar `psql-14` en lugar de `psql` para evitar warnings de versión

El script `setup.sh` se encarga automáticamente de:
- ✅ **Instalar dependencias** (PostgreSQL, Python, Node.js)
- ✅ **Configurar base de datos** (crear usuario, BD, ejecutar init.sql)
- ✅ **Instalar dependencias** (pip install, npm install)
- ✅ **Configurar variables** de entorno
- ✅ **Ejecutar servicios** (backend + frontend)

### Instalación Manual

#### Prerrequisitos
- PostgreSQL 12+
- Python 3.8+
- Node.js 16+
- Android Studio (para app móvil)

#### Configuración Base de Datos
```bash
# 1. Inicializar base de datos
psql -U postgres -f "Base de Datos/init.sql"

# 2. Cargar datos de prueba (opcional)
psql -U predicthealth_user -d predicthealth -f "Base de Datos/prueba.sql"
```

#### Configuración Backend
```bash
cd Backend
pip install -r requirements.txt
export PGHOST=localhost PGPORT=5432 PGDATABASE=predicthealth PGUSER=predicthealth_user PGPASSWORD=666
python app.py
```

Debe tenerse, en el directorio root, un archivo .env definiendo las siguientes variables:

DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, REDIS_HOST, REDIS_PORT, REDIS_DB, JWT_SECRET, JWT_ALG, JWT_AUD, ACCESS_TTL_MIN, REFRESH_TTL_DAYS, AUTH_PORT, REGISTER_PORT, PACIENTE_PORT, HEALTH_PORT, DATA_SERVICE_PORT, RECOMMENDATIONS_SERVICE_PORT, HYPERTENSION_SCALE, HYPERTENSION_THRESHOLD, HYPERTENSION_GAMMA

#### Configuración Frontend
```bash
cd app/web
npm install
npm start
```

## 📊 Características Principales

- **👥 Gestión de Usuarios**: Sistema de autenticación con roles
- **📈 Dashboards**: Visualización de métricas de salud en tiempo real
- **🚨 Alertas Automáticas**: Detección de valores anómalos
- **📄 Procesamiento de Documentos**: NLP para extracción de datos médicos
- **📍 Geolocalización**: Seguimiento de ubicación del usuario
- **🔍 Auditoría Completa**: Trazabilidad de todas las operaciones

## 🎨 Paleta de Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Midnight Blue | #132232 | Fondo principal |
| Snow White | #FFFFFF | Texto en fondos oscuros |
| Sky Blue | #ADC7EA | Botones y enlaces |
| Success Green | #4CAF50 | Confirmaciones |
| Warning Amber | #FFC107 | Alertas |
| Error Red | #F44336 | Errores |

## 📚 Documentación

- [Arquitectura del Sistema](https://lucid.app/lucidchart/b11164f2-5065-4e16-93d7-896f577da5a0/edit?viewport_loc=-121%2C-1769%2C3720%2C4084%2C0_0&invitationId=inv_19597c7c-3cb5-4324-98f9-66e21398ef79)
- [Modelo E-R](https://docs.google.com/document/d/15vsShOtpazZ2pWJg4mOqwK3ftXY6GBit0u_iRQ_oVrg/edit?usp=sharing)
- [Base de Datos](Base%20de%20Datos/README.md) - Documentación completa de BD
- [Backend API](Backend/README.md) - Documentación del backend Flask

## 📊 Datasets Utilizados

- **CDC Diabetes**: 243,532 registros de indicadores de salud
- **Kaggle Hypertension**: 1,985 registros de predicción de hipertensión

## 🔧 Acceso de Desarrollo

### Credenciales del Sistema
- **👤 Usuario Admin**: `admin@admin.com` / `admin`
- **🗄️ Base de Datos**: `predicthealth_user` / `666`

### Puertos
- **Puerto Backend**: 5001
- **Puerto Frontend**: 3000

### URLs de Acceso
- **Aplicación Web**: http://localhost:3000
- **API Backend**: http://localhost:5001
- **Health Check**: http://localhost:5001/api/health

---

**Versión**: 2.0 | **Estado**: ✅ Funcional | **Última actualización**: Diciembre 2024


## Microservicios: Instrucciones

Para utilizar los microservicios, deben lanzarse utilizando los siguientes comandos:

# auth_service: 8001

python -m services.auth_service.main 

# register_service: 8002

python -m services.register_service.main 

# patient_service: 8003

python -m services.patient_service.main 

# health_service: 8004

python -m services.health_service.main 

# diabetes_service: 8008

python -m services.diabetes_service.main 

# diabetes_service: 8009

python -m services.hypertension_service.main 

# data_service: 8010

python -m services.data_service.main 

# recommendations_service: 8011

python -m services.recommendations_service.main 


## Java app: Instrucciones

Antes de lanzar la Java App, debe modificarse el archivo config.properties para utilizar la ip correcta según la dirección donde se estén hosteando los microservicios.

Para compilar y lanzar la app, debe correrse el archivo run.bat.
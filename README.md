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
│   └── android/       # App Android
├── Backend/           # API Flask
└── Base de Datos/     # PostgreSQL + Scripts
```

## 🚀 Instalación Rápida

### Instalación Automática (Recomendada)
```bash
# Ejecutar script de instalación automática
chmod +x setup.sh
./setup.sh
```

**⚠️ Solución de Problemas de Permisos (Linux/Google Cloud)**
Si encuentras errores de "Permission denied" al ejecutar el script, ejecuta estos comandos antes:

```bash
# Dar permisos de lectura al directorio home para otros usuarios
sudo chmod 755 /home/fati
sudo chmod 755 /home/fati/Predicthealth
sudo chmod 755 "/home/fati/Predicthealth/Base de Datos"
sudo chmod 644 "/home/fati/Predicthealth/Base de Datos/init.sql"
```

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

- [Arquitectura del Sistema](https://lucid.app/lucidchart/e8a4c780-8b4f-4ca2-8605-5b6e3927194d/edit?invitationId=inv_925c84d6-c21d-43af-ba4d-35265cca643f)
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

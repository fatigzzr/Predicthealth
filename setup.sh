#!/bin/bash

# =============================================================================
# PredictHealth - Script de Instalación Automática
# =============================================================================

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar si un puerto está en uso
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# =============================================================================
# 1. VERIFICACIÓN DE DEPENDENCIAS
# =============================================================================

print_status "🔍 Verificando dependencias del sistema..."

# Verificar Python
if ! command_exists python3; then
    print_error "Python 3 no está instalado. Por favor instala Python 3.8+"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
print_success "Python $PYTHON_VERSION encontrado"

# Verificar Node.js
if ! command_exists node; then
    print_error "Node.js no está instalado. Por favor instala Node.js 16+"
    exit 1
fi

NODE_VERSION=$(node --version)
print_success "Node.js $NODE_VERSION encontrado"

# Verificar npm
if ! command_exists npm; then
    print_error "npm no está instalado"
    exit 1
fi

print_success "npm $(npm --version) encontrado"

# Verificar PostgreSQL
if ! command_exists psql; then
    print_error "PostgreSQL no está instalado. Por favor instala PostgreSQL 12+"
    exit 1
fi

PSQL_VERSION=$(psql --version | awk '{print $3}')
print_success "PostgreSQL $PSQL_VERSION encontrado"

# Verificar pip
if ! command_exists pip3; then
    print_error "pip3 no está instalado"
    exit 1
fi

print_success "pip3 $(pip3 --version | awk '{print $2}') encontrado"

# =============================================================================
# 2. CONFIGURACIÓN DE POSTGRESQL
# =============================================================================

print_status "🗄️ Configurando base de datos PostgreSQL..."

# Verificar si PostgreSQL está inicializado (macOS con Homebrew)
if command_exists brew; then
    if [ ! -d "/usr/local/var/postgres" ] && [ ! -d "/opt/homebrew/var/postgres" ]; then
        print_status "Inicializando PostgreSQL..."
        if [ -d "/opt/homebrew" ]; then
            # Apple Silicon Mac
            initdb /opt/homebrew/var/postgres
        else
            # Intel Mac
            initdb /usr/local/var/postgres
        fi
        print_success "PostgreSQL inicializado"
    fi
fi

# Verificar si PostgreSQL está ejecutándose
if ! pg_isready -q; then
    print_warning "PostgreSQL no está ejecutándose. Intentando iniciar..."
    
    # Intentar iniciar PostgreSQL (diferentes sistemas)
    if command_exists systemctl; then
        sudo systemctl start postgresql
    elif command_exists brew; then
        brew services start postgresql
    else
        print_error "No se pudo iniciar PostgreSQL automáticamente"
        exit 1
    fi
    
    sleep 3
    
    if ! pg_isready -q; then
        print_error "PostgreSQL no se pudo iniciar"
        exit 1
    fi
fi

print_success "PostgreSQL está ejecutándose"

# El usuario y base de datos se crean automáticamente en init.sql

# =============================================================================
# 3. EJECUTAR SCRIPTS SQL
# =============================================================================

print_status "📊 Ejecutando scripts de inicialización de base de datos..."

# Verificar si el archivo init.sql existe
if [ ! -f "Base de Datos/init.sql" ]; then
    print_error "Archivo 'Base de Datos/init.sql' no encontrado"
    exit 1
fi

# Ejecutar script principal (necesita superusuario)
psql -U $(whoami) -d postgres -f "Base de Datos/init.sql"
print_success "Script principal ejecutado"

# Cargar datos de prueba (opcional)
read -p "¿Deseas cargar datos de prueba? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Cargando datos de prueba..."
    
    # Verificar si el archivo prueba.sql existe
    if [ -f "Base de Datos/prueba.sql" ]; then
        psql -U predicthealth_user -d predicthealth -f "Base de Datos/prueba.sql"
        print_success "Datos de prueba cargados"
    else
        print_warning "Archivo 'Base de Datos/prueba.sql' no encontrado"
    fi
fi

# =============================================================================
# 4. INSTALAR DEPENDENCIAS BACKEND
# =============================================================================

print_status "🐍 Instalando dependencias del backend..."

if [ ! -f "Backend/requirements.txt" ]; then
    print_error "Archivo 'Backend/requirements.txt' no encontrado"
    exit 1
fi

cd Backend
pip3 install -r requirements.txt
print_success "Dependencias del backend instaladas"

# =============================================================================
# 5. INSTALAR DEPENDENCIAS FRONTEND
# =============================================================================

print_status "📦 Instalando dependencias del frontend..."

cd ../app/web
if [ ! -f "package.json" ]; then
    print_error "Archivo 'package.json' no encontrado"
    exit 1
fi

npm install
print_success "Dependencias del frontend instaladas"

# =============================================================================
# 6. CONFIGURAR VARIABLES DE ENTORNO
# =============================================================================

print_status "⚙️ Configurando variables de entorno..."

# Configurar variables de entorno para la sesión actual
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=predicthealth
export PGUSER=predicthealth_user
export PGPASSWORD=666
export JWT_SECRET=dev-secret-change-me
export JWT_EXPIRES_MIN=60
export FLASK_APP=app.py
export FLASK_ENV=development

print_success "Variables de entorno configuradas"

# =============================================================================
# 7. VERIFICAR PUERTOS
# =============================================================================

print_status "🔍 Verificando puertos disponibles..."

if port_in_use 5001; then
    print_warning "Puerto 5001 está en uso. El backend podría no iniciarse correctamente"
fi

if port_in_use 3000; then
    print_warning "Puerto 3000 está en uso. El frontend podría no iniciarse correctamente"
fi

# =============================================================================
# 8. EJECUTAR SERVICIOS
# =============================================================================

print_status "🚀 Iniciando servicios..."

# Función para ejecutar backend en background
start_backend() {
    print_status "Iniciando backend en puerto 5001..."
    cd ../../Backend
    export $(cat .env | xargs)
    python3 app.py &
    BACKEND_PID=$!
    echo $BACKEND_PID > backend.pid
    print_success "Backend iniciado (PID: $BACKEND_PID)"
}

# Función para ejecutar frontend en background
start_frontend() {
    print_status "Iniciando frontend en puerto 3000..."
    cd ../app/web
    npm start &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > frontend.pid
    print_success "Frontend iniciado (PID: $FRONTEND_PID)"
}

# Preguntar si ejecutar servicios automáticamente
read -p "¿Deseas iniciar los servicios automáticamente? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    start_backend
    sleep 5
    start_frontend
    
    print_success "🎉 ¡Instalación completada!"
    print_status "Servicios ejecutándose:"
    print_status "- Backend: http://localhost:5001"
    print_status "- Frontend: http://localhost:3000"
    print_status "- Base de datos: localhost:5432"
    print_status ""
    print_status "Credenciales:"
    print_status "- Usuario: admin@admin.com"
    print_status "- Contraseña: admin"
    print_status ""
    print_status "Para detener los servicios:"
    print_status "- Backend: kill \$(cat Backend/backend.pid)"
    print_status "- Frontend: kill \$(cat app/web/frontend.pid)"
else
    print_success "🎉 ¡Instalación completada!"
    print_status "Para iniciar los servicios manualmente:"
    print_status "1. Backend: cd Backend && python3 app.py"
    print_status "2. Frontend: cd app/web && npm start"
fi

# =============================================================================
# 9. VERIFICACIÓN FINAL
# =============================================================================

print_status "🔍 Verificando instalación..."

# Verificar backend
sleep 3
if curl -s http://localhost:5001/api/health > /dev/null; then
    print_success "Backend funcionando correctamente"
else
    print_warning "Backend no responde (puede estar iniciando)"
fi

# Verificar base de datos
if psql -U predicthealth_user -d predicthealth -c "SELECT COUNT(*) FROM Usuario;" > /dev/null 2>&1; then
    print_success "Base de datos funcionando correctamente"
else
    print_warning "No se pudo verificar la base de datos"
fi

print_success "✅ Instalación completada exitosamente!"
print_status "📖 Para más información, consulta README_INSTALACION.md"

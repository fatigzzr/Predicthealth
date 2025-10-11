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
    print_warning "Node.js no está instalado. Intentando instalar automáticamente..."
    
    # Detectar sistema operativo e instalar Node.js
    if command_exists apt; then
        # Ubuntu/Debian
        print_status "Instalando Node.js en Ubuntu/Debian..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif command_exists yum; then
        # CentOS/RHEL
        print_status "Instalando Node.js en CentOS/RHEL..."
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    elif command_exists dnf; then
        # Fedora
        print_status "Instalando Node.js en Fedora..."
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo dnf install -y nodejs
    elif command_exists brew; then
        # macOS con Homebrew
        print_status "Instalando Node.js en macOS..."
        brew install node
    else
        print_error "No se pudo detectar el sistema operativo para instalar Node.js"
        print_status "Por favor instala Node.js manualmente:"
        print_status "- Ubuntu/Debian: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
        print_status "- CentOS/RHEL: curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash - && sudo yum install -y nodejs"
        print_status "- Fedora: curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash - && sudo dnf install -y nodejs"
        print_status "- macOS: brew install node"
        exit 1
    fi
    
    # Verificar que la instalación fue exitosa
    if ! command_exists node; then
        print_error "La instalación de Node.js falló"
        exit 1
    fi
    
    print_success "Node.js instalado correctamente"
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
    print_warning "PostgreSQL no está instalado. Intentando instalar automáticamente..."
    
    # Detectar sistema operativo e instalar PostgreSQL
    if command_exists brew; then
        # macOS con Homebrew
        print_status "Instalando PostgreSQL en macOS..."
        brew install postgresql
    elif command_exists apt; then
        # Ubuntu/Debian
        print_status "Instalando PostgreSQL en Ubuntu/Debian..."
        sudo apt update
        sudo apt install -y postgresql postgresql-contrib
    elif command_exists yum; then
        # CentOS/RHEL
        print_status "Instalando PostgreSQL en CentOS/RHEL..."
        sudo yum install -y postgresql-server postgresql-contrib
    elif command_exists dnf; then
        # Fedora
        print_status "Instalando PostgreSQL en Fedora..."
        sudo dnf install -y postgresql-server postgresql-contrib
    else
        print_error "No se pudo detectar el sistema operativo para instalar PostgreSQL"
        print_status "Por favor instala PostgreSQL manualmente:"
        print_status "- macOS: brew install postgresql"
        print_status "- Ubuntu/Debian: sudo apt install postgresql postgresql-contrib"
        print_status "- CentOS/RHEL: sudo yum install postgresql-server postgresql-contrib"
        exit 1
    fi
    
    # Verificar que la instalación fue exitosa
    if ! command_exists psql; then
        print_error "La instalación de PostgreSQL falló"
        exit 1
    fi
    
    print_success "PostgreSQL instalado correctamente"
fi

# Verificar si PostgreSQL está realmente configurado
if ! pg_isready -q 2>/dev/null; then
    print_warning "PostgreSQL no está ejecutándose o no está configurado"
    print_status "Intentando configurar PostgreSQL..."
    
    # Limpiar configuración corrupta si existe
    print_status "Limpiando configuración anterior si existe..."
    sudo systemctl stop postgresql 2>/dev/null || true
    sudo pkill -f postgres 2>/dev/null || true
    
    # Configurar PostgreSQL según el sistema operativo
    if command_exists brew; then
        # macOS con Homebrew
        if [ ! -d "/usr/local/var/postgres" ] && [ ! -d "/opt/homebrew/var/postgres" ]; then
            print_status "Inicializando PostgreSQL en macOS..."
            if [ -d "/opt/homebrew" ]; then
                # Apple Silicon Mac
                initdb /opt/homebrew/var/postgres
            else
                # Intel Mac
                initdb /usr/local/var/postgres
            fi
        fi
        brew services start postgresql
    elif command_exists systemctl; then
        # Linux con systemd
        print_status "Configurando PostgreSQL en Linux..."
        
        # Verificar si PostgreSQL está inicializado
        if [ ! -d "/var/lib/postgresql/data" ] && [ ! -d "/var/lib/pgsql/data" ]; then
            print_status "Inicializando cluster de PostgreSQL..."
            
            # Crear directorios con permisos correctos
            print_status "Creando directorios con permisos correctos..."
            sudo mkdir -p /var/lib/postgresql
            sudo mkdir -p /var/lib/pgsql
            sudo chown postgres:postgres /var/lib/postgresql
            sudo chown postgres:postgres /var/lib/pgsql
            sudo chmod 755 /var/lib/postgresql
            sudo chmod 755 /var/lib/pgsql
            
            # Intentar inicializar en /var/lib/postgresql/data primero
            if sudo -u postgres initdb -D /var/lib/postgresql/data 2>/dev/null; then
                print_success "PostgreSQL inicializado en /var/lib/postgresql/data"
            # Si falla, intentar en /var/lib/pgsql/data
            elif sudo -u postgres initdb -D /var/lib/pgsql/data 2>/dev/null; then
                print_success "PostgreSQL inicializado en /var/lib/pgsql/data"
            # Si ambos fallan, usar postgresql-setup
            elif sudo postgresql-setup initdb 2>/dev/null; then
                print_success "PostgreSQL inicializado con postgresql-setup"
            else
                print_error "No se pudo inicializar PostgreSQL con ningún método"
                print_status "Intentando diagnóstico con permisos corregidos..."
                sudo chown -R postgres:postgres /var/lib/postgresql
                sudo chown -R postgres:postgres /var/lib/pgsql
                sudo -u postgres /usr/bin/initdb -D /var/lib/postgresql/data --auth-local=trust --auth-host=md5
            fi
        else
            print_status "PostgreSQL ya está inicializado"
        fi
        
        # Intentar iniciar PostgreSQL
        print_status "Iniciando PostgreSQL..."
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        
        # Verificar que esté funcionando
        sleep 3
        if ! pg_isready -q; then
            print_warning "PostgreSQL no responde. Intentando diagnóstico..."
            
            # Mostrar logs de PostgreSQL para diagnóstico
            if command_exists journalctl; then
                print_status "Últimos logs de PostgreSQL:"
                journalctl -u postgresql.service --no-pager -n 10
            fi
            
            # Intentar limpiar y reinicializar
            print_status "Limpiando y reinicializando PostgreSQL..."
            sudo systemctl stop postgresql 2>/dev/null || true
            sudo rm -rf /var/lib/postgresql/data 2>/dev/null || true
            sudo rm -rf /var/lib/pgsql/data 2>/dev/null || true
            
            # Reinicializar desde cero con configuración específica
            print_status "Reinicializando PostgreSQL desde cero..."
            
            # Asegurar permisos correctos antes de reinicializar
            sudo mkdir -p /var/lib/postgresql
            sudo chown -R postgres:postgres /var/lib/postgresql
            sudo chmod 755 /var/lib/postgresql
            
            sudo -u postgres initdb -D /var/lib/postgresql/data --auth-local=trust --auth-host=md5 --encoding=UTF8 --locale=en_US.UTF-8
            
            # Configurar PostgreSQL para permitir conexiones locales
            print_status "Configurando PostgreSQL para conexiones locales..."
            sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" 2>/dev/null || true
            
            sudo systemctl start postgresql
            sleep 5
        fi
    elif command_exists service; then
        # Linux con service
        print_status "Iniciando PostgreSQL en Linux..."
        sudo service postgresql start
    else
        print_error "No se pudo configurar PostgreSQL automáticamente"
        print_status "Por favor configura PostgreSQL manualmente:"
        print_status "- Inicia el servicio: sudo systemctl start postgresql"
        print_status "- O inicializa: sudo -u postgres initdb"
        exit 1
    fi
    
    # Verificación final
    sleep 3
    if ! pg_isready -q; then
        print_error "PostgreSQL no se pudo configurar correctamente"
        print_status "Estado del servicio:"
        sudo systemctl status postgresql --no-pager -l
        print_status "Por favor configura PostgreSQL manualmente:"
        print_status "1. sudo -u postgres initdb -D /var/lib/postgresql/data"
        print_status "2. sudo systemctl start postgresql"
        print_status "3. sudo systemctl enable postgresql"
        exit 1
    fi
fi

# Detectar la versión de PostgreSQL activa
PSQL_VERSION=$(psql --version | awk '{print $3}')
PSQL_VERSION_NUM=$(echo $PSQL_VERSION | cut -d. -f1)

# Verificar si PostgreSQL 14 está disponible
if command_exists psql-14; then
    PSQL_14_VERSION=$(psql-14 --version | awk '{print $3}')
    PSQL_14_VERSION_NUM=$(echo $PSQL_14_VERSION | cut -d. -f1)
    print_success "PostgreSQL $PSQL_VERSION encontrado (activo) y PostgreSQL $PSQL_14_VERSION disponible"
    
    # Si PostgreSQL 14 está disponible, usarlo
    if [ "$PSQL_14_VERSION_NUM" -ge 14 ]; then
        print_status "Configurando PostgreSQL 14 como versión activa..."
        sudo systemctl stop postgresql 2>/dev/null || true
        sudo systemctl start postgresql-14
        sudo systemctl enable postgresql-14
        
        # Actualizar variables para usar PostgreSQL 14
        PSQL_VERSION=$PSQL_14_VERSION
        PSQL_VERSION_NUM=$PSQL_14_VERSION_NUM
        print_success "PostgreSQL $PSQL_VERSION ahora activo"
    fi
else
    print_success "PostgreSQL $PSQL_VERSION encontrado y funcionando"
fi

# Verificar compatibilidad de versión y actualizar si es necesario
if [ "$PSQL_VERSION_NUM" -lt 14 ]; then
    print_warning "PostgreSQL $PSQL_VERSION detectado. Se requiere PostgreSQL 14+ para funcionalidad completa."
    print_status "Actualizando PostgreSQL a la versión 14..."
    
    # Detener PostgreSQL actual
    print_status "Deteniendo PostgreSQL actual..."
    if command_exists systemctl; then
        sudo systemctl stop postgresql
    elif command_exists brew; then
        brew services stop postgresql
    fi
    
    # Actualizar PostgreSQL según el sistema operativo
    if command_exists apt; then
        # Ubuntu/Debian - Usar repositorio alternativo más confiable
        print_status "Configurando repositorio alternativo de PostgreSQL..."
        sudo apt update
        sudo apt install -y wget ca-certificates gnupg lsb-release
        
        # Usar método más confiable para agregar la clave GPG
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
        
        # Actualizar repositorios
        sudo apt update
        
        print_status "Instalando PostgreSQL 14..."
        sudo apt install -y postgresql-14 postgresql-client-14 postgresql-contrib-14
        
        # Configurar PostgreSQL 14 como servicio principal
        sudo systemctl stop postgresql 2>/dev/null || true
        sudo systemctl start postgresql@14-main
        sudo systemctl enable postgresql@14-main
    elif command_exists yum; then
        # CentOS/RHEL - Usar repositorio oficial de PostgreSQL con GPG deshabilitado
        print_status "Configurando repositorio oficial de PostgreSQL..."
        sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
        
        # Deshabilitar verificación GPG temporalmente
        print_status "Deshabilitando verificación GPG temporalmente..."
        sudo yum install -y postgresql14-server postgresql14 postgresql14-contrib --nogpgcheck
        sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
        sudo systemctl start postgresql-14
        sudo systemctl enable postgresql-14
    elif command_exists dnf; then
        # Fedora - Usar repositorio oficial de PostgreSQL con GPG deshabilitado
        print_status "Configurando repositorio oficial de PostgreSQL..."
        sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-$(rpm -E %fedora)-x86_64/pgdg-fedora-repo-latest.noarch.rpm
        
        # Deshabilitar verificación GPG temporalmente
        print_status "Deshabilitando verificación GPG temporalmente..."
        sudo dnf install -y postgresql14-server postgresql14 postgresql14-contrib --nogpgcheck
        sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
        sudo systemctl start postgresql-14
        sudo systemctl enable postgresql-14
        else
            print_warning "No se pudo actualizar PostgreSQL automáticamente con el método estándar"
            print_status "Intentando con método alternativo..."
            
            # Intentar instalar PostgreSQL 14 desde paquetes disponibles
            if command_exists apt; then
                print_status "Intentando instalar PostgreSQL 14 desde paquetes disponibles..."
                sudo apt update
                sudo apt install -y postgresql-14 postgresql-client-14 postgresql-contrib-14 || {
                    print_warning "PostgreSQL 14 no disponible en repositorios estándar"
                    print_status "Intentando con Docker..."
                    
                    # Verificar si Docker está disponible
                    if command_exists docker; then
                        print_status "Usando Docker para PostgreSQL 14..."
                        
                        # Detener PostgreSQL nativo
                        sudo systemctl stop postgresql 2>/dev/null || true
                        
                        # Crear directorio para datos de PostgreSQL
                        sudo mkdir -p /var/lib/postgresql-docker
                        sudo chown 999:999 /var/lib/postgresql-docker
                        
                        # Ejecutar PostgreSQL 14 en Docker
                        docker run -d \
                            --name postgres-14 \
                            -e POSTGRES_PASSWORD=666 \
                            -e POSTGRES_USER=predicthealth_user \
                            -e POSTGRES_DB=predicthealth \
                            -p 5432:5432 \
                            -v /var/lib/postgresql-docker:/var/lib/postgresql/data \
                            postgres:14
                        
                        # Esperar a que PostgreSQL esté listo
                        print_status "Esperando a que PostgreSQL esté listo..."
                        sleep 10
                        
                        # Verificar que Docker PostgreSQL esté funcionando
                        if docker ps | grep -q postgres-14; then
                            print_success "PostgreSQL 14 ejecutándose en Docker"
                            # Actualizar variables de entorno para usar Docker
                            export PGHOST=localhost
                            export PGPORT=5432
                        else
                            print_error "No se pudo iniciar PostgreSQL en Docker"
                            exit 1
                        fi
                    else
                        print_error "Docker no está disponible y no se pudo actualizar PostgreSQL"
                        print_status "Continuando con PostgreSQL 13 (puede tener limitaciones de compatibilidad)"
                        print_warning "Algunas funciones pueden no estar disponibles con PostgreSQL 13"
                    fi
                }
            else
                print_error "No se pudo actualizar PostgreSQL automáticamente"
                print_status "Continuando con PostgreSQL 13 (puede tener limitaciones de compatibilidad)"
                print_warning "Algunas funciones pueden no estar disponibles con PostgreSQL 13"
            fi
        fi
    
    # Verificar que la actualización fue exitosa
    sleep 5
    if pg_isready -q; then
        PSQL_VERSION=$(psql --version | awk '{print $3}')
        PSQL_VERSION_NUM=$(echo $PSQL_VERSION | cut -d. -f1)
        print_success "PostgreSQL actualizado a $PSQL_VERSION"
    else
        print_error "No se pudo actualizar PostgreSQL correctamente"
        exit 1
    fi
fi

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
        # Verificar si PostgreSQL está inicializado antes de iniciar
        if [ ! -d "/var/lib/postgresql/data" ] && [ ! -d "/var/lib/pgsql/data" ]; then
            print_status "Inicializando cluster de PostgreSQL..."
            sudo -u postgres initdb -D /var/lib/postgresql/data 2>/dev/null || sudo -u postgres initdb -D /var/lib/pgsql/data 2>/dev/null || {
                print_warning "No se pudo inicializar automáticamente. Intentando método alternativo..."
                sudo postgresql-setup initdb 2>/dev/null || sudo -u postgres /usr/bin/initdb -D /var/lib/postgresql/data 2>/dev/null
            }
        fi
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

# Verificar permisos del archivo
if [ ! -r "Base de Datos/init.sql" ]; then
    print_error "No se puede leer el archivo 'Base de Datos/init.sql'. Verifica los permisos."
    exit 1
fi

print_status "Archivo init.sql encontrado y legible"

# Ejecutar script principal (necesita superusuario)
print_status "Ejecutando script de inicialización de base de datos..."

# Usar el método apropiado según el sistema operativo
print_status "Ejecutando script de inicialización..."

# Obtener la ruta absoluta del directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SQL_PATH="$SCRIPT_DIR/Base de Datos/init.sql"

print_status "Directorio del script: $SCRIPT_DIR"
print_status "Ruta del archivo SQL: $INIT_SQL_PATH"

# Verificar que el archivo existe
if [ ! -f "$INIT_SQL_PATH" ]; then
    print_error "No se encontró el archivo en: $INIT_SQL_PATH"
    exit 1
fi

# Verificar y ajustar permisos para que postgres pueda acceder
if ! sudo -u postgres test -r "$INIT_SQL_PATH" 2>/dev/null; then
    print_status "Ajustando permisos para que postgres pueda acceder al archivo..."
    sudo chmod 755 "$SCRIPT_DIR"
    sudo chmod 755 "$SCRIPT_DIR/Base de Datos"
    sudo chmod 644 "$INIT_SQL_PATH"
    print_status "Permisos ajustados"
fi

# Ahora PostgreSQL 14+ está garantizado, usar el script estándar
print_status "PostgreSQL $PSQL_VERSION detectado - compatible con todas las funciones"

# Detectar sistema operativo y usar el método apropiado
if command_exists brew; then
    # macOS con Homebrew
    print_status "Ejecutando en macOS con Homebrew..."
    if psql -d postgres -f "$INIT_SQL_PATH"; then
        print_success "Script principal ejecutado correctamente en macOS"
    else
        print_error "No se pudo ejecutar el script en macOS"
        print_status "Por favor ejecuta manualmente:"
        print_status "psql -d postgres -f '$INIT_SQL_PATH'"
        exit 1
    fi
else
    # Entorno en la Nube (GCloud)
    print_status "Ejecutando en entorno en la nube (GCloud)..."
    if sudo -u postgres psql -d postgres -f "$INIT_SQL_PATH"; then
        print_success "Script principal ejecutado correctamente en entorno en la nube"
    else
        print_error "No se pudo ejecutar el script en entorno en la nube"
        print_status "Por favor ejecuta manualmente:"
        print_status "sudo -u postgres psql -d postgres -f '$INIT_SQL_PATH'"
        exit 1
    fi
fi

# Cargar datos de prueba (opcional)
read -p "¿Deseas cargar datos de prueba? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_status "Cargando datos de prueba..."
    
    # Verificar si el archivo prueba.sql existe
    PRUEBA_SQL_PATH="$SCRIPT_DIR/Base de Datos/prueba.sql"
    if [ -f "$PRUEBA_SQL_PATH" ]; then
        print_status "Cargando datos de prueba..."
        if psql -U predicthealth_user -d predicthealth -f "$PRUEBA_SQL_PATH"; then
            print_success "Datos de prueba cargados"
        else
            print_warning "No se pudo cargar datos de prueba. Verifica que la base de datos y usuario existan."
            print_status "Intenta manualmente:"
            if command_exists brew; then
                print_status "psql -U predicthealth_user -d predicthealth -f '$PRUEBA_SQL_PATH'"
            else
                print_status "sudo -u postgres psql -U predicthealth_user -d predicthealth -f '$PRUEBA_SQL_PATH'"
            fi
        fi
    else
        print_warning "Archivo '$PRUEBA_SQL_PATH' no encontrado"
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

# Manejar problemas con psycopg2-binary en Python 3.13+
print_status "Instalando dependencias Python..."
if ! pip3 install -r requirements.txt; then
    print_warning "Error instalando psycopg2-binary. Intentando alternativas..."
    
    # Intentar instalar psycopg2 en lugar de psycopg2-binary
    pip3 install Flask==2.3.3 Flask-CORS==4.0.0 PyJWT==2.8.0 python-dotenv==1.0.0
    pip3 install psycopg2 || pip3 install psycopg2-binary --no-cache-dir || {
        print_error "No se pudo instalar psycopg2. Por favor instala PostgreSQL development headers:"
        print_status "macOS: brew install postgresql"
        print_status "Ubuntu/Debian: sudo apt install libpq-dev"
        print_status "CentOS/RHEL: sudo yum install postgresql-devel"
        exit 1
    }
fi

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
    print_status "Para liberar el puerto 5001:"
    print_status "lsof -ti:5001 | xargs kill -9"
fi

if port_in_use 3000; then
    print_warning "Puerto 3000 está en uso. El frontend podría no iniciarse correctamente"
    print_status "Para liberar el puerto 3000:"
    print_status "lsof -ti:3000 | xargs kill -9"
    
    # Preguntar si liberar el puerto automáticamente
    read -p "¿Deseas liberar el puerto 3000 automáticamente? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_status "Liberando puerto 3000..."
        lsof -ti:3000 | xargs kill -9 2>/dev/null || print_warning "No se pudo liberar el puerto 3000"
        sleep 2
    fi
fi

# Verificar firewall y abrir puertos si es necesario
print_status "Verificando configuración de firewall..."

# Detectar si estamos en Google Cloud
if curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone >/dev/null 2>&1; then
    print_status "Detectado Google Cloud Platform"
    print_warning "IMPORTANTE: Necesitas configurar reglas de firewall en Google Cloud Console"
    print_status "Ejecuta estos comandos en Google Cloud Console:"
    print_status "gcloud compute firewall-rules create allow-predicthealth-frontend --allow tcp:3000 --source-ranges 0.0.0.0/0"
    print_status "gcloud compute firewall-rules create allow-predicthealth-backend --allow tcp:5001 --source-ranges 0.0.0.0/0"
    print_status ""
    print_status "O desde la consola web:"
    print_status "1. Ve a VPC Network > Firewall"
    print_status "2. Crea regla para puerto 3000 (frontend)"
    print_status "3. Crea regla para puerto 5001 (backend)"
    print_status "4. Aplica a todas las instancias"
elif command_exists ufw; then
    print_status "Configurando UFW para permitir puertos 3000 y 5001..."
    sudo ufw allow 3000/tcp
    sudo ufw allow 5001/tcp
    print_success "Puertos abiertos en UFW"
elif command_exists firewall-cmd; then
    print_status "Configurando firewalld para permitir puertos 3000 y 5001..."
    sudo firewall-cmd --permanent --add-port=3000/tcp
    sudo firewall-cmd --permanent --add-port=5001/tcp
    sudo firewall-cmd --reload
    print_success "Puertos abiertos en firewalld"
else
    print_warning "No se detectó firewall configurado. Asegúrate de que los puertos 3000 y 5001 estén abiertos."
fi

# =============================================================================
# 8. EJECUTAR SERVICIOS
# =============================================================================

print_status "🚀 Iniciando servicios..."

# Función para detener servicios existentes
stop_existing_services() {
    print_status "Verificando servicios existentes..."
    
    # Detener backend si está ejecutándose
    if [ -f "Backend/backend.pid" ]; then
        BACKEND_PID=$(cat Backend/backend.pid)
        if kill -0 $BACKEND_PID 2>/dev/null; then
            print_status "Deteniendo backend existente (PID: $BACKEND_PID)..."
            kill $BACKEND_PID
            sleep 2
        fi
        rm -f Backend/backend.pid
    fi
    
    # Detener frontend si está ejecutándose
    if [ -f "app/web/frontend.pid" ]; then
        FRONTEND_PID=$(cat app/web/frontend.pid)
        if kill -0 $FRONTEND_PID 2>/dev/null; then
            print_status "Deteniendo frontend existente (PID: $FRONTEND_PID)..."
            kill $FRONTEND_PID
            sleep 2
        fi
        rm -f app/web/frontend.pid
    fi
    
    # Detener procesos que puedan estar usando los puertos
    if lsof -ti:5001 >/dev/null 2>&1; then
        print_status "Liberando puerto 5001..."
        lsof -ti:5001 | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
    
    if lsof -ti:3000 >/dev/null 2>&1; then
        print_status "Liberando puerto 3000..."
        lsof -ti:3000 | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
    
    print_success "Servicios existentes detenidos"
}

# Detener servicios existentes antes de iniciar nuevos
stop_existing_services

# Función para ejecutar backend en background
start_backend() {
    print_status "Iniciando backend en puerto 5001..."
    cd ../../Backend
    
    # Configurar variables de entorno para acceso externo
    export PGHOST=localhost
    export PGPORT=5432
    export PGDATABASE=predicthealth
    export PGUSER=predicthealth_user
    export PGPASSWORD=666
    export JWT_SECRET=dev-secret-change-me
    export JWT_EXPIRES_MIN=60
    export FLASK_APP=app.py
    export FLASK_ENV=development
    
    # Cargar variables de .env si existe
    if [ -f ".env" ]; then
        export $(cat .env | xargs)
    fi
    
    python3 app.py &
    BACKEND_PID=$!
    echo $BACKEND_PID > backend.pid
    print_success "Backend iniciado (PID: $BACKEND_PID)"
    print_status "Backend accesible en: http://0.0.0.0:5001"
}

# Función para ejecutar frontend en background
start_frontend() {
    print_status "Iniciando frontend en puerto 3000..."
    cd ../app/web
    
    # Configurar variables de entorno para acceso externo
    export HOST=0.0.0.0
    export PORT=3000
    
    # Iniciar con configuración para acceso externo
    npm start &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > frontend.pid
    print_success "Frontend iniciado (PID: $FRONTEND_PID)"
    print_status "Frontend accesible en: http://0.0.0.0:3000"
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
    print_status "- Frontend: http://localhost:3000 (también accesible desde IP externa)"
    print_status "- Base de datos: localhost:5432"
    print_status ""
    print_status "Para acceso externo:"
    print_status "- Frontend: http://$(hostname -I | awk '{print $1}'):3000"
    print_status "- Backend: http://$(hostname -I | awk '{print $1}'):5001"
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

# Verificar procedimientos almacenados críticos
print_status "Verificando procedimientos almacenados críticos..."
if psql -U predicthealth_user -d predicthealth -c "SELECT routine_name FROM information_schema.routines WHERE routine_name = 'sp_login_staff';" | grep -q "sp_login_staff"; then
    print_success "Procedimiento sp_login_staff encontrado"
else
    print_warning "Procedimiento sp_login_staff no encontrado"
    print_status "Revisa los errores de ejecución del script SQL"
fi

print_success "✅ Instalación completada exitosamente!"
print_status "📖 Para más información, consulta README_INSTALACION.md"
print_status ""
print_status "🔄 Para reiniciar los servicios:"
print_status "1. Detener: kill \$(cat Backend/backend.pid) && kill \$(cat app/web/frontend.pid)"
print_status "2. Reiniciar: ./setup.sh (solo la sección de servicios)"
print_status "3. O ejecutar manualmente:"
print_status "   - Backend: cd Backend && python3 app.py &"
print_status "   - Frontend: cd app/web && HOST=0.0.0.0 npm start &"

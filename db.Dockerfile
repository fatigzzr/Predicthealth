FROM postgres:15

# Bundle the initialization script into the image to avoid host FS quirks during startup
COPY ["Base de Datos/init.sql", "/docker-entrypoint-initdb.d/01-init.sql"]

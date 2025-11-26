# PredictHealth - Sistema de Salud Predictiva

Plataforma integral de IA para predicción de enfermedades crónicas (diabetes e hipertensión) con análisis de datos biométricos, historial médico y estilo de vida.

## Instrucciones

1) **Requisitos previos**
   - Docker + Docker Compose v2 instalados.
   - Puertos libres: 5432 (Postgres), 6379 (Redis), 5001 (backend monolito), 8001/8002/8003/8004/8008/8009/8010/8011 (microservicios), 3000 (frontend).

2) **Levantar todo con Docker**
   ```bash
   docker-compose up --build
   ```
   - Servicios levantados: Postgres (5432), Redis (6379), backend monolito (5001), auth (8001), register (8002), patient (8003), health (8004), diabetes (8008), hypertension (8009), data (8010), recommendations (8011), frontend (3000).
   - La base se inicializa con `Base de Datos/init.sql` y persiste en el volumen `predicthealth-db-data`.

3) **Frontend**
   - Navega a http://localhost:3000.
   - Para desarrollo con hot reload (sin contenedor):
     ```bash
     cd app/web
     npm install
     npm start
     ```

4) **Java (Swing)**
   - No está en el compose. Ejecuta en el host con GUI:
     ```bash
     cd app/java
     java -cp "PredictHealthJava.jar:lib/*" PredictHealthJava
     ```
   - Edita `app/java/config.properties` si cambias endpoints.

5) **Detener**
   ```bash
   docker-compose down
   ```

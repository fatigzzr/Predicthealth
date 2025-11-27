# PredictHealth - Sistema de Salud Predictiva

Plataforma integral de IA para predicción de enfermedades crónicas (diabetes e hipertensión) con análisis de datos biométricos, historial médico y estilo de vida.

## Instrucciones

1) **Requisitos previos (CentOS Stream 9 / RHEL-like)**
   - VM en GCP (ejemplo con 200GB recomendado para builds de Docker):
     ```bash
     gcloud compute instances create maquina01 \
       --machine-type=e2-standard-2 \
       --zone=us-central1-f \
       --image-family=centos-stream-9 \
       --image-project=centos-cloud \
       --boot-disk-size=200GB \
       --boot-disk-type=pd-standard
     ```
   - Docker + Docker Compose v2:
     ```bash
     sudo dnf -y update
     sudo dnf -y install dnf-plugins-core
     sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
     sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin 
     sudo systemctl enable --now docker
     rpm -q docker-compose-plugin
     docker compose version
     ```
   - Git:
     ```bash
     sudo dnf -y install git
     ```
   - Firewall GCP (ejemplo):
     ```bash
     gcloud compute firewall-rules create predicthealth-allow \
       --allow=tcp:5432,tcp:6379,tcp:5001,tcp:8001-8004,tcp:8008-8011,tcp:3000 \
       --network=default \
       --direction=INGRESS
     ```
    Ajusta red/regla/puertos según tu despliegue.
   - Puertos libres en la VM: 5432 (Postgres), 6379 (Redis), 5001 (backend monolito), 8001/8002/8003/8004/8008/8009/8010/8011 (microservicios), 3000 (frontend).

2) **Clonar este repositorio o Subir la carpeta**
   ```bash
   git clone https://github.com/fatigzzr/Predicthealth.git
   cd Predicthealth
   ```

3) **Levantar todo con Docker**
   ```bash
   docker compose up --build
   ```
   - Servicios levantados: Postgres (5432), Redis (6379), backend monolito (5001), auth (8001), register (8002), patient (8003), health (8004), diabetes (8008), hypertension (8009), data (8010), recommendations (8011), frontend (3000).
   - La base se inicializa con `Base de Datos/init.sql` y persiste en el volumen `predicthealth-db-data`.

3) **Frontend**
   - Navega a `http://<IP>:3000`.
   - Para desarrollo con hot reload (sin contenedor):
     ```bash
     cd app/web
     npm install
     npm start
     ```

4) **Java (Swing)**
   - No está en el compose. Ejecuta en una máquina con GUI (no en la VM headless):
     ```bash
     cd app/java
     java -cp "PredictHealthJava.jar:lib/*" PredictHealthJava
     ```
   - Edita `app/java/config.properties` con la IP/puertos de tu despliegue si cambias endpoints:
     ```properties
     login.url=http://<IP_VM>:8001/auth/login
     register.url=http://<IP_VM>:8002/register
     auth.me.url=http://<IP_VM>:8001/auth/me
     paciente.url=http://<IP_VM>:8003/paciente
     estilo_vida.url=http://<IP_VM>:8004/estilo_vida
     diabetes.url=http://<IP_VM>:8008/predict_diabetes
     hypertension.url=http://<IP_VM>:8009/predict_hypertension
     data_service.url=http://<IP_VM>:8010/guardar_historial
     recommendations.url=http://<IP_VM>:8011/recommendations
     ```

5) **Cargar datos de prueba adicionales (opcional)**
   - Ejecuta el script `Base de Datos/prueba.sql` sobre la base `predicthealth`:
     ```bash
     psql -h localhost -U predicthealth_user -d predicthealth -f "Base de Datos/prueba.sql"
     ```
     (La contraseña por defecto del usuario es `666`).

6) **Detener**
   ```bash
   docker compose down
   ```

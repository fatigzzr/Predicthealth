import csv
import hashlib
import psycopg2
from werkzeug.security import generate_password_hash

# Conexión a PostgreSQL
conn = psycopg2.connect(
    host="localhost",
    dbname="predicthealth",
    user="predicthealth_user",
    password="666"
)
cur = conn.cursor()

with open("usuarios.csv", "r", encoding="utf-8") as file:
    reader = csv.DictReader(file)
    for row in reader:
        id_rol = row["id_rol"]
        email = row["email"]
        password = row["contraseña"]
        password_hash = generate_password_hash(password, method='pbkdf2:sha256')
        cur.execute(
            "INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (%s, %s, %s)",
            (id_rol, email, password_hash)
        )

conn.commit()
cur.close()
conn.close()

-- =====================================
-- COMANDOS SQL DATASET HIPERTENSIÓN
-- Compatible con init_new.sql
-- =====================================

-- Insertar medicamentos para hipertensión
INSERT INTO Medicamento (nombre) VALUES ('Ninguna') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('Otro') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('Beta Blocker') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('Diurético') ON CONFLICT (nombre) DO NOTHING;
INSERT INTO Medicamento (nombre) VALUES ('ACE Inhibitor') ON CONFLICT (nombre) DO NOTHING;

-- Insertar datos de usuarios del dataset Hypertension
-- Usuario 1
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_1@hypertension-risk.com', 'pbkdf2:sha256:1000000$dCrDZcRfk25VResT$6d480bc0f2fbfb6b144be3c7423d10f0b8daa053c2533aae0d82afea0d0591a3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_1', 'Hypertension_1', '1955-01-01', NULL
FROM Usuario 
WHERE email = 'user_1@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_1@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 2
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_2@hypertension-risk.com', 'pbkdf2:sha256:1000000$4RqozGnsfIDLu4nM$3b89722231e6bf50b79a64f016b35e11fe4c9323e0bdc6fc39ea77270b479c84');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_2', 'Hypertension_2', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_2@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_2@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 3
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_3@hypertension-risk.com', 'pbkdf2:sha256:1000000$Q2YSNtRla0tU6uUB$e70d846dd53d1b166f008c690b90b35d3e7bbce8ec8e96c4d2e291a1bb2a8194');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_3', 'Hypertension_3', '1946-01-01', NULL
FROM Usuario 
WHERE email = 'user_3@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_3@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 4
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_4@hypertension-risk.com', 'pbkdf2:sha256:1000000$8mTVMvv9yXFsQp2O$4b902bbe373ad26f364bba5745e2615d4ecc0f4d80d35e9d7730b44f856571ca');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_4', 'Hypertension_4', '1986-01-01', NULL
FROM Usuario 
WHERE email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_4@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_4@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 5
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_5@hypertension-risk.com', 'pbkdf2:sha256:1000000$9mB3I57NntiFlgJn$facb99585fd6c6420a558abc1299ba63c39c649a5e1b31dbdc5fab210afe066d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_5', 'Hypertension_5', '1983-01-01', NULL
FROM Usuario 
WHERE email = 'user_5@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '16.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_5@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_5@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 6
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_6@hypertension-risk.com', 'pbkdf2:sha256:1000000$e5L6aSYmQCV4Ezd6$75262cfc1e30bad61e81cfff84ecf535a19df651c906d84d1e42c16f90efbbfe');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_6', 'Hypertension_6', '2004-01-01', NULL
FROM Usuario 
WHERE email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_6@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_6@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 7
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_7@hypertension-risk.com', 'pbkdf2:sha256:1000000$rCne4ZJuqzGOqrWH$2c3d098f5673511130657fcfed53a71fe975b85eb10747c7904f23cdd4e56c30');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_7', 'Hypertension_7', '1985-01-01', NULL
FROM Usuario 
WHERE email = 'user_7@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_7@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_7@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 8
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_8@hypertension-risk.com', 'pbkdf2:sha256:1000000$o8h48QQP5dyQ58Rh$76c9f9db235adb47f3b014d2c9d31a1387a72b59fa831ea9c5fbf9a1038105e4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_8', 'Hypertension_8', '1954-01-01', NULL
FROM Usuario 
WHERE email = 'user_8@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_8@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 9
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_9@hypertension-risk.com', 'pbkdf2:sha256:1000000$RIY2oHpXmrQRTz7b$078f939e72bdef91360cb0a35524b3ac64ccfe6895d14bf7a8f2bbb849febe50');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_9', 'Hypertension_9', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '36.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_9@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_9@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 10
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_10@hypertension-risk.com', 'pbkdf2:sha256:1000000$X5hiOd3rRZZkHke8$cdb13d385e9255bdd0c21762afb988016d1e31ee3cafcf65e9a886773289efb3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_10', 'Hypertension_10', '1977-01-01', NULL
FROM Usuario 
WHERE email = 'user_10@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_10@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 11
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_11@hypertension-risk.com', 'pbkdf2:sha256:1000000$4xeIqFmoOaIqoeWm$d04b501795a5f81c039720094b49f16ccef69ce64057efb466b418ef3ddce434');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_11', 'Hypertension_11', '1969-01-01', NULL
FROM Usuario 
WHERE email = 'user_11@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_11@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_11@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 12
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_12@hypertension-risk.com', 'pbkdf2:sha256:1000000$ontMHJ93RZxlrWFo$2c16518f2c6f80674209ab2e06ef52bbc6e4e8e860d058bc74ea36dbbf5a6466');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_12', 'Hypertension_12', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_12@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_12@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_12@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 13
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_13@hypertension-risk.com', 'pbkdf2:sha256:1000000$1HFjOIsIEkbxNk8Z$286df2a296191cf5d600665ac44ce01859d484911d716efe459fbb612ee3750a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_13', 'Hypertension_13', '1943-01-01', NULL
FROM Usuario 
WHERE email = 'user_13@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '17.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_13@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 14
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_14@hypertension-risk.com', 'pbkdf2:sha256:1000000$yoTBvN5PGIj5GvgX$eaf45757b493f559b53becd599b0ee107ff7f89803f871ac0089afd365f59562');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_14', 'Hypertension_14', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '19.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_14@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_14@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 15
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_15@hypertension-risk.com', 'pbkdf2:sha256:1000000$E4iBZqeJPMz3VwMX$ee7990c4684f2263b15ec79aa4c463f8217f29066a8724d7d7d31c9668436720');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_15', 'Hypertension_15', '1986-01-01', NULL
FROM Usuario 
WHERE email = 'user_15@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_15@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 16
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_16@hypertension-risk.com', 'pbkdf2:sha256:1000000$3MOJomf7s8xXF739$21624636cf7a6066df860396853112ea3efc6a0d3dcd3812dc1ad987a4cf54c2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_16', 'Hypertension_16', '1974-01-01', NULL
FROM Usuario 
WHERE email = 'user_16@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_16@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 17
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_17@hypertension-risk.com', 'pbkdf2:sha256:1000000$fQBBOQZx6yhXg7hw$a33ca5ea97511e732f830a8cc6fe6ceee9a9142d7e7db8b031fbf060e1436bd2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_17', 'Hypertension_17', '1949-01-01', NULL
FROM Usuario 
WHERE email = 'user_17@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_17@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 18
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_18@hypertension-risk.com', 'pbkdf2:sha256:1000000$JF8xG7ruP5A4MIFN$8a63410aaa677b522b3703f30f7dc166133b26b536f3be3e103745afa13b2dfc');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_18', 'Hypertension_18', '1985-01-01', NULL
FROM Usuario 
WHERE email = 'user_18@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '13.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_18@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 19
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_19@hypertension-risk.com', 'pbkdf2:sha256:1000000$9j3iHcoAI1NUUtOR$b3343f10089b4b1ef975a5db8348adc636c3112db6bb89639315d17277bd6708');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_19', 'Hypertension_19', '1958-01-01', NULL
FROM Usuario 
WHERE email = 'user_19@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_19@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 20
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_20@hypertension-risk.com', 'pbkdf2:sha256:1000000$8X6QMgELty8FnZLp$a7d3325cb9c8194be6aaf394b70815c28718d16f68498c2509d16b62d31be3f7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_20', 'Hypertension_20', '1948-01-01', NULL
FROM Usuario 
WHERE email = 'user_20@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_20@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 21
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_21@hypertension-risk.com', 'pbkdf2:sha256:1000000$RGwkorU9R9e9Tbjc$78c0dbc9faae306fa7bb5a982b7e393c4cf6f1785c083e4720929ac8b482befc');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_21', 'Hypertension_21', '1965-01-01', NULL
FROM Usuario 
WHERE email = 'user_21@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_21@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_21@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 22
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_22@hypertension-risk.com', 'pbkdf2:sha256:1000000$hU2etDfRf8bF9xBn$85f05c5f74bdd21b04ac96cd2d44394811f57fa3d63601a8e186ce23a9a53853');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_22', 'Hypertension_22', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_22@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_22@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 23
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_23@hypertension-risk.com', 'pbkdf2:sha256:1000000$zarSiNLfrFAquf5w$4c9ab6dae1c6112c31c66f62e049f5b15125d9cd84074522b981d7b7daf96a7b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_23', 'Hypertension_23', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_23@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_23@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 24
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_24@hypertension-risk.com', 'pbkdf2:sha256:1000000$CKkZm3o35bycOP4j$99d313b08c8fd2605f0bb52bd9413690bc63238847153e4e21ec08d5f0dda1f2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_24', 'Hypertension_24', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_24@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_24@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 25
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_25@hypertension-risk.com', 'pbkdf2:sha256:1000000$Px4Zzs3zgCnFeOUA$d3ce46682e6ca75486b3afb2fed4053ddcd7691f2ea189ed1a4bbfe38e9c3b3e');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_25', 'Hypertension_25', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_25@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_25@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 26
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_26@hypertension-risk.com', 'pbkdf2:sha256:1000000$lo80C6OJfCdkcBdk$8bc75bde8371ea69bd1c2d5cdf2b304ea7947665586cf0dc1603f9a6f9564a88');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_26', 'Hypertension_26', '1960-01-01', NULL
FROM Usuario 
WHERE email = 'user_26@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '2.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_26@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 27
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_27@hypertension-risk.com', 'pbkdf2:sha256:1000000$RszhnHkMDQuH4neo$74dfb9ee6924b0826127e1187f56c352191d872df72f3515b1b2e6ebe2472755');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_27', 'Hypertension_27', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_27@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_27@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 28
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_28@hypertension-risk.com', 'pbkdf2:sha256:1000000$jSYRcI3RcdF7ofNv$955fbedb250b9042b42eb5f8d8ed3729a22732f2955982d2e5d27dfc38fda086');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_28', 'Hypertension_28', '1956-01-01', NULL
FROM Usuario 
WHERE email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_28@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_28@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 29
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_29@hypertension-risk.com', 'pbkdf2:sha256:1000000$QL6d9KdLuY4Ziv9a$5f827fc9f05251ddc6e5e9f277baeb3be4350671e846abae724a8862da4d48db');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_29', 'Hypertension_29', '1952-01-01', NULL
FROM Usuario 
WHERE email = 'user_29@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_29@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_29@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 30
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_30@hypertension-risk.com', 'pbkdf2:sha256:1000000$Q5zYFWLp7e0wfdCK$1eb5bf268051ffaec03a81b92d5f6f4665c07fe0e88e12cc7a1639d8714b70bb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_30', 'Hypertension_30', '1943-01-01', NULL
FROM Usuario 
WHERE email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_30@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_30@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 31
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_31@hypertension-risk.com', 'pbkdf2:sha256:1000000$q8rQOYduktbZDSL5$8f767f61a1ef0d6db0025d22edf6b73062e93d8f14c85c6e061658c718aa85a4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_31', 'Hypertension_31', '2004-01-01', NULL
FROM Usuario 
WHERE email = 'user_31@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_31@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 32
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_32@hypertension-risk.com', 'pbkdf2:sha256:1000000$zwJjCvlgyX9ljoi7$4284d32740c6a599168a12eb724f6eb6b1358f1ff9a5e30a0ee605ce8420f552');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_32', 'Hypertension_32', '1956-01-01', NULL
FROM Usuario 
WHERE email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_32@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_32@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 33
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_33@hypertension-risk.com', 'pbkdf2:sha256:1000000$RRVBqLArXV8muivQ$bd7f7e4daf4ea332e904871fa78f76924ab5a57e6360127159b4c803d511e4b9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_33', 'Hypertension_33', '2000-01-01', NULL
FROM Usuario 
WHERE email = 'user_33@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_33@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 34
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_34@hypertension-risk.com', 'pbkdf2:sha256:1000000$IIzjyi6VK8jIblBn$1584abd28c24c56b3e505bcf9e2d4431380e317aa116aed4d1bcbae21581042d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_34', 'Hypertension_34', '1986-01-01', NULL
FROM Usuario 
WHERE email = 'user_34@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_34@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_34@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 35
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_35@hypertension-risk.com', 'pbkdf2:sha256:1000000$RVmzlFbzcfvKQkZf$2103c18fa55e24921172d6a90c266fd7b50249c9017b3e4049a067e81760cb21');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_35', 'Hypertension_35', '1968-01-01', NULL
FROM Usuario 
WHERE email = 'user_35@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '17.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_35@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_35@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 36
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_36@hypertension-risk.com', 'pbkdf2:sha256:1000000$rjw5BhWvOTIswOwG$da68988c9e7604d3b55f67fa5dfeebf22ecaffbb2ce2e60d7859da5a36b97770');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_36', 'Hypertension_36', '1989-01-01', NULL
FROM Usuario 
WHERE email = 'user_36@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '37.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_36@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 37
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_37@hypertension-risk.com', 'pbkdf2:sha256:1000000$TLFthuU70Dxa7hmW$3aeda5ce8dfe8155d365ce5bb19f945070e5cd7aac8f9d8e54fe601916cebcda');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_37', 'Hypertension_37', '2003-01-01', NULL
FROM Usuario 
WHERE email = 'user_37@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_37@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_37@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 38
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_38@hypertension-risk.com', 'pbkdf2:sha256:1000000$zAs83mSEoraTMyui$1718664f0421d46f7b15882ba8d7982a479b8cb2feda63ed50f70a72d2b6d830');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_38', 'Hypertension_38', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_38@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_38@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 39
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_39@hypertension-risk.com', 'pbkdf2:sha256:1000000$kd2rpsq3rzDiITQo$c638b163e0ac09d70b6bab9b97527c8e39626f3df679df005b3126777fe36d8f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_39', 'Hypertension_39', '1993-01-01', NULL
FROM Usuario 
WHERE email = 'user_39@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_39@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_39@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 40
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_40@hypertension-risk.com', 'pbkdf2:sha256:1000000$gjcsOHc4qK6Jpa7v$256c42ea17b6aabadec2699f30b12f56c86ad2ce8f56839bbef717d37632fcd9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_40', 'Hypertension_40', '1998-01-01', NULL
FROM Usuario 
WHERE email = 'user_40@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '19.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_40@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_40@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 41
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_41@hypertension-risk.com', 'pbkdf2:sha256:1000000$7FGzWhRc72c85Cqm$2b835867e6ab9874d6879224327d1368c3c90adaf49ff759859c41b6caebdc88');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_41', 'Hypertension_41', '1954-01-01', NULL
FROM Usuario 
WHERE email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_41@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_41@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 42
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_42@hypertension-risk.com', 'pbkdf2:sha256:1000000$giY09xQFGolmBchb$0f07a989ff234d9559911d6bd5ddc84e237ae6467387fadbced0686ab75d9fd5');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_42', 'Hypertension_42', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_42@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '19.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_42@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 43
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_43@hypertension-risk.com', 'pbkdf2:sha256:1000000$hie7m6tD4r0RMr2E$65662679368ca5c1b96209be4ae472edea36c7076da1586565347e1b9801388d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_43', 'Hypertension_43', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_43@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_43@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 44
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_44@hypertension-risk.com', 'pbkdf2:sha256:1000000$2bEJnCHI8xGNLEHQ$5b55c26b7e1a887c503ba2ad9ee22e6dc2446c8332b00f4ac0c500462dc32bc0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_44', 'Hypertension_44', '1963-01-01', NULL
FROM Usuario 
WHERE email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_44@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_44@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 45
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_45@hypertension-risk.com', 'pbkdf2:sha256:1000000$OYTJQkoRZ9TBcEY1$64e86cd02f7a483f024c62e9790d2414ad683335d780d01264a55e670b2b50cd');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_45', 'Hypertension_45', '1999-01-01', NULL
FROM Usuario 
WHERE email = 'user_45@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_45@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_45@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 46
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_46@hypertension-risk.com', 'pbkdf2:sha256:1000000$klpKDVyjBLJNGQTJ$478a3024f0f891ba4a130e0d6bd98fd1bb5efda85238d8b4ca99b1956473ab10');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_46', 'Hypertension_46', '1960-01-01', NULL
FROM Usuario 
WHERE email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_46@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_46@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 47
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_47@hypertension-risk.com', 'pbkdf2:sha256:1000000$Zkv80TbIlcFBqstf$7104a77677e4cb57d450d022167ffd483c570db9c9b712ae8b878678508f1ba0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_47', 'Hypertension_47', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_47@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_47@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 48
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_48@hypertension-risk.com', 'pbkdf2:sha256:1000000$nj5tuk8kmOLPfsKx$376d67f134e56f61e87ec270b528444acc8e569f43ee770ee7ddd5d8190af1cf');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_48', 'Hypertension_48', '1971-01-01', NULL
FROM Usuario 
WHERE email = 'user_48@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_48@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 49
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_49@hypertension-risk.com', 'pbkdf2:sha256:1000000$2b1jRp3efgoXfqmc$da379eb4fadaddf24780a7b8c28c5e6c290f71a970790b8fe955ae8f16f4b100');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_49', 'Hypertension_49', '1957-01-01', NULL
FROM Usuario 
WHERE email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_49@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_49@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 50
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_50@hypertension-risk.com', 'pbkdf2:sha256:1000000$dezg35lY4ZGHRZ2p$649b10164564eae826a5a60975ee1c6e1b12ac8686e248a4dd81269a5a3b117b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_50', 'Hypertension_50', '2003-01-01', NULL
FROM Usuario 
WHERE email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_50@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_50@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 51
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_51@hypertension-risk.com', 'pbkdf2:sha256:1000000$QhKS0gB2eBbzr5Pz$35693ea76caec92a33f6177ab8f91bd90ca913904377d3d78477a45e9bffe9d0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_51', 'Hypertension_51', '2005-01-01', NULL
FROM Usuario 
WHERE email = 'user_51@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_51@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_51@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 52
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_52@hypertension-risk.com', 'pbkdf2:sha256:1000000$H9Op3tCAmYrqbGRn$27ce684c6949a63263b76afaa6e19fc3da7c1b4fa179dcbf1fc19c8fe2e0bbfd');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_52', 'Hypertension_52', '2001-01-01', NULL
FROM Usuario 
WHERE email = 'user_52@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_52@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_52@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 53
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_53@hypertension-risk.com', 'pbkdf2:sha256:1000000$g72ONnrRk1hwH22q$ad062adefd79356e3a2ae01e67cdd4f82ad6541b4e6f397d0d4539091e3eed4e');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_53', 'Hypertension_53', '1953-01-01', NULL
FROM Usuario 
WHERE email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '17.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_53@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_53@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 54
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_54@hypertension-risk.com', 'pbkdf2:sha256:1000000$bIsK4MLO8YZ4SctD$8461600b3c5599f90cd8aa83809156af7f291db1ebd9b56e2248b4d194e3923a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_54', 'Hypertension_54', '2003-01-01', NULL
FROM Usuario 
WHERE email = 'user_54@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_54@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 55
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_55@hypertension-risk.com', 'pbkdf2:sha256:1000000$7EYliIvWrbOZLJ27$6e7805189dfd2de6454806caa00bf8573cca9ddcb5fc014c5f512e73c636caff');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_55', 'Hypertension_55', '1953-01-01', NULL
FROM Usuario 
WHERE email = 'user_55@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_55@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 56
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_56@hypertension-risk.com', 'pbkdf2:sha256:1000000$v7ismTKRYm3SMwpn$91dae60b33dfef7dbc957b276437242c946076a7621e66733851b18eb40eaef3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_56', 'Hypertension_56', '1944-01-01', NULL
FROM Usuario 
WHERE email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '13.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_56@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_56@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 57
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_57@hypertension-risk.com', 'pbkdf2:sha256:1000000$71ncnvjSHXvulP8q$4cad8c53c321abe50457a3ebd06656499c110849f79883d4f23e15a49227c479');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_57', 'Hypertension_57', '1989-01-01', NULL
FROM Usuario 
WHERE email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_57@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_57@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 58
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_58@hypertension-risk.com', 'pbkdf2:sha256:1000000$kDr2S3xFdb0s4YVQ$cdffeaac5045c793735340705dd5e4b3150dcba8a37fb1e7923b3c33537fd043');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_58', 'Hypertension_58', '1963-01-01', NULL
FROM Usuario 
WHERE email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_58@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_58@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 59
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_59@hypertension-risk.com', 'pbkdf2:sha256:1000000$N7DnSEdKhJ3czRNu$fa2e3dfa2278524c59c5eed5d3b14f5ea90e92648e0f25acea81e9d2b374c640');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_59', 'Hypertension_59', '1973-01-01', NULL
FROM Usuario 
WHERE email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_59@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_59@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 60
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_60@hypertension-risk.com', 'pbkdf2:sha256:1000000$qWuihd7CBQECVLCp$233e5ca2b6613b053f29c389910e78bad06ef4293543de507dac6d040f5f6ec6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_60', 'Hypertension_60', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_60@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '13.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_60@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 61
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_61@hypertension-risk.com', 'pbkdf2:sha256:1000000$0zjusRFzt2lCxW3s$2ab9e85662480c370a00f77113f652467a38b325c02a698e8c11656ff3afcccb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_61', 'Hypertension_61', '1993-01-01', NULL
FROM Usuario 
WHERE email = 'user_61@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_61@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 62
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_62@hypertension-risk.com', 'pbkdf2:sha256:1000000$KMpXfJrTpKJGVbtf$5126031eb5d862d6db6f7861a62bf58c34080ec1bf52ddbb09166955cbb2f3a0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_62', 'Hypertension_62', '1959-01-01', NULL
FROM Usuario 
WHERE email = 'user_62@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_62@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_62@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 63
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_63@hypertension-risk.com', 'pbkdf2:sha256:1000000$qVPT0g6rT8a0fFQu$dcef44c4640a2fe165698ce121da12d316c8b71934d8e40cee0ac004aeb14d9a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_63', 'Hypertension_63', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '38.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_63@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_63@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 64
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_64@hypertension-risk.com', 'pbkdf2:sha256:1000000$LTNZTWS0wYagD9Ie$eb5f0084e06fe5237c0cdc6523f5eec148725468740c9d81ee2f2b20c3d5bc91');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_64', 'Hypertension_64', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_64@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_64@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_64@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 65
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_65@hypertension-risk.com', 'pbkdf2:sha256:1000000$cRInwOfSi30aY8R4$2fde894079be0821b2aed0f8f420b70480786d787984188e22bc4c43aa8ef2ce');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_65', 'Hypertension_65', '1967-01-01', NULL
FROM Usuario 
WHERE email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_65@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_65@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 66
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_66@hypertension-risk.com', 'pbkdf2:sha256:1000000$Ej27GHXFBuUicqYi$3621ebf1cb4fef76628ea194dee49974a51a40d6ff1087d13a27f9081b0be35b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_66', 'Hypertension_66', '1954-01-01', NULL
FROM Usuario 
WHERE email = 'user_66@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_66@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_66@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 67
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_67@hypertension-risk.com', 'pbkdf2:sha256:1000000$3aANVr6uOfvKj56x$c2b33d6667ce164ed80ced069ad857a2f4a04d09e0657b4a111e3b44204e51ac');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_67', 'Hypertension_67', '1983-01-01', NULL
FROM Usuario 
WHERE email = 'user_67@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_67@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 68
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_68@hypertension-risk.com', 'pbkdf2:sha256:1000000$nPOhFkTJj5EJP175$19adde4d0440520a186e96294fedf8815dbd03e8e30d2a85b53a096ee101bad9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_68', 'Hypertension_68', '1981-01-01', NULL
FROM Usuario 
WHERE email = 'user_68@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_68@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_68@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 69
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_69@hypertension-risk.com', 'pbkdf2:sha256:1000000$DQK9jaHe2beKEgOE$2a82c013d702dfcfa2ad5bd72e5fd188afb48c4e5cb65a467b1427136e0dfae1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_69', 'Hypertension_69', '1947-01-01', NULL
FROM Usuario 
WHERE email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_69@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_69@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 70
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_70@hypertension-risk.com', 'pbkdf2:sha256:1000000$9FXpdC0wM8f2GnCq$91d8d54b119a131ca36714bc5962f13396e45cc011996449ead8c1ab119cb1a6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_70', 'Hypertension_70', '1966-01-01', NULL
FROM Usuario 
WHERE email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_70@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_70@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 71
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_71@hypertension-risk.com', 'pbkdf2:sha256:1000000$FYUEJNK9esJNuh4b$7deff7364d1a078c7cdfebf4205099a8a0fbb05a7dbb22086893347989a63d1f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_71', 'Hypertension_71', '1978-01-01', NULL
FROM Usuario 
WHERE email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_71@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_71@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 72
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_72@hypertension-risk.com', 'pbkdf2:sha256:1000000$HXzeUky0rT3RffT8$c03aef7839eb66cc73827709e1cce1489b47b0c1f02a0b3449bdbee64f4134d1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_72', 'Hypertension_72', '1992-01-01', NULL
FROM Usuario 
WHERE email = 'user_72@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_72@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 73
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_73@hypertension-risk.com', 'pbkdf2:sha256:1000000$RNInt2LPJBlUlSvK$822315a9ecb2eac10f2057e3fe8c2d4590f5087fbae1e5961744628d776a4faa');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_73', 'Hypertension_73', '1962-01-01', NULL
FROM Usuario 
WHERE email = 'user_73@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_73@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 74
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_74@hypertension-risk.com', 'pbkdf2:sha256:1000000$ThfsPHPRdkGUx1to$4bac3e6d45447c58895727a098a74b3c0c689f189a21dffcd181cc286fe895ec');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_74', 'Hypertension_74', '1942-01-01', NULL
FROM Usuario 
WHERE email = 'user_74@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_74@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 75
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_75@hypertension-risk.com', 'pbkdf2:sha256:1000000$qnITD4ZxyV4nH1Ak$59b157b84d00814006fde23b6b2c44c12bed17c3b3e83b1209833526a2a5728c');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_75', 'Hypertension_75', '1998-01-01', NULL
FROM Usuario 
WHERE email = 'user_75@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_75@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 76
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_76@hypertension-risk.com', 'pbkdf2:sha256:1000000$iptHqqdTiPTlnsd1$585fbeb42601c88dbab43ae9df9fb49b5a4a8470b082ea844246f0277a908d4b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_76', 'Hypertension_76', '2006-01-01', NULL
FROM Usuario 
WHERE email = 'user_76@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_76@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_76@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 77
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_77@hypertension-risk.com', 'pbkdf2:sha256:1000000$vzaECZ0zf87Jw1xf$37e22073df120cc8e3a449e81b77a1166709cb157174abc7f79a0c94bc1d7875');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_77', 'Hypertension_77', '1999-01-01', NULL
FROM Usuario 
WHERE email = 'user_77@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '18.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_77@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_77@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 78
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_78@hypertension-risk.com', 'pbkdf2:sha256:1000000$DwWFldKiYkkWERho$67872b88b8281002cfe8660f7bff502c9924778a4e59972f566389475b1bb6ef');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_78', 'Hypertension_78', '1944-01-01', NULL
FROM Usuario 
WHERE email = 'user_78@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '4.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Diurético')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_78@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_78@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 79
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_79@hypertension-risk.com', 'pbkdf2:sha256:1000000$Eu1KWSl07hNSQiiE$9199cfe717a03fe02a471a62658537cb63f12e10c01194d9b68ef7335ea708f4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_79', 'Hypertension_79', '1996-01-01', NULL
FROM Usuario 
WHERE email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_79@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_79@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 80
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_80@hypertension-risk.com', 'pbkdf2:sha256:1000000$SbUIXZddPh8B95zz$0c9ca9271fa1f8148e8b12bce64658c6a6c657f6f785ce59c857cf2dd2850da1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_80', 'Hypertension_80', '1999-01-01', NULL
FROM Usuario 
WHERE email = 'user_80@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_80@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 81
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_81@hypertension-risk.com', 'pbkdf2:sha256:1000000$gQr9RKHtyzT2STCi$7cbbe35361922c227b416e033ce8f79af2c352b777b5f52fcb04b2ce7b651367');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_81', 'Hypertension_81', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_81@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_81@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 82
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_82@hypertension-risk.com', 'pbkdf2:sha256:1000000$MLvE0JTWsx4FRPcD$d0da3dc9ed0b43752907762cd1a0d3fa9ee0ff8b51b79f064e573f5f3218cc68');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_82', 'Hypertension_82', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_82@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_82@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 83
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_83@hypertension-risk.com', 'pbkdf2:sha256:1000000$8Utvf4I5BSJXpdq3$76f6521a65d365eea0da1f0a3f0528023d6d93df3fc12b2fffc71e09af7c5f39');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_83', 'Hypertension_83', '1974-01-01', NULL
FROM Usuario 
WHERE email = 'user_83@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_83@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 84
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_84@hypertension-risk.com', 'pbkdf2:sha256:1000000$p8Bes1GX9BND4tHE$5165631f77f55d3eca3c024e37607e7f4a0a7b2a58ff10c79a33a1d42d90fe9a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_84', 'Hypertension_84', '2002-01-01', NULL
FROM Usuario 
WHERE email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_84@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_84@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 85
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_85@hypertension-risk.com', 'pbkdf2:sha256:1000000$iJXHXWq8Sz70ZSc9$e8f167291d6777bf487d503b8108f37264f5a532cf243442f3c90d0f30386311');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_85', 'Hypertension_85', '1966-01-01', NULL
FROM Usuario 
WHERE email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_85@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_85@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 86
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_86@hypertension-risk.com', 'pbkdf2:sha256:1000000$rQlFIGC1FFlfr79R$8f49a3f2de95ccbae3b1d3f8a0ab90c00bbdc73f0aafce5f83adf0053e3ccc31');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_86', 'Hypertension_86', '1979-01-01', NULL
FROM Usuario 
WHERE email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_86@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_86@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 87
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_87@hypertension-risk.com', 'pbkdf2:sha256:1000000$9msTDeBt1kmcjeZI$ded2f30b027b9a854128efbeadfc57085a5cad48c5c7bac9a8365f5562f55bba');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_87', 'Hypertension_87', '2000-01-01', NULL
FROM Usuario 
WHERE email = 'user_87@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_87@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 88
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_88@hypertension-risk.com', 'pbkdf2:sha256:1000000$r49jg9ZEVQQ3RDKY$e960833d1bf0457a23444f7f6f59fdd3f7c7452393b891e70d249f35688bd4e8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_88', 'Hypertension_88', '1995-01-01', NULL
FROM Usuario 
WHERE email = 'user_88@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_88@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_88@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 89
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_89@hypertension-risk.com', 'pbkdf2:sha256:1000000$fKln3ENpeAk6taQR$fb3bc05398616b7c5406a84bb6492c3f0b322d368a0632b9132825a494af1ab3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_89', 'Hypertension_89', '1973-01-01', NULL
FROM Usuario 
WHERE email = 'user_89@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_89@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 90
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_90@hypertension-risk.com', 'pbkdf2:sha256:1000000$Cq3uib3o1Arp5B0e$0fd6cdd68daff552e3027d7cb64f1835713bebd5fe975eaabf90228095b6360d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_90', 'Hypertension_90', '1974-01-01', NULL
FROM Usuario 
WHERE email = 'user_90@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '10.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '9.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_90@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 91
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_91@hypertension-risk.com', 'pbkdf2:sha256:1000000$vIUfifDRCCG18ICc$d5dc5f2a1385de3a520d37303eaef229387ccd36581a1fad5fc9a479512db794');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_91', 'Hypertension_91', '1959-01-01', NULL
FROM Usuario 
WHERE email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '12.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '3.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_91@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_91@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 92
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_92@hypertension-risk.com', 'pbkdf2:sha256:1000000$KW71KVKXch8dviCD$8ea6d6e8558c0b89e9c63be2be1cb8ead0f9e4d7abde3edca6a56921a265b2a9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_92', 'Hypertension_92', '1984-01-01', NULL
FROM Usuario 
WHERE email = 'user_92@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '11.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_92@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_92@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 93
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_93@hypertension-risk.com', 'pbkdf2:sha256:1000000$AHVjUO0OsHVDJCjZ$621ac834749b439fab3ff2f779c613acdbb88d1bdae0a3f60bee7a08eb26c809');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_93', 'Hypertension_93', '1945-01-01', NULL
FROM Usuario 
WHERE email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '7.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_93@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_93@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 94
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_94@hypertension-risk.com', 'pbkdf2:sha256:1000000$XnRHiHChUSlCaqH1$c784a6e3199874ab071eefdd771a55412ae717b3c31ac111d77b8137452f0012');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_94', 'Hypertension_94', '1970-01-01', NULL
FROM Usuario 
WHERE email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '6.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_94@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_94@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 95
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_95@hypertension-risk.com', 'pbkdf2:sha256:1000000$EIvgnTfeYYGp7GG0$a2e6af352a4750507ae3c812faefbea36ebc914e71b9e189f07f41a603751e7f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_95', 'Hypertension_95', '1963-01-01', NULL
FROM Usuario 
WHERE email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_95@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_95@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 96
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_96@hypertension-risk.com', 'pbkdf2:sha256:1000000$t96EwICtToxkKI5e$58badef6db62f4b0c816e57201668a89a0f1fd8ae48d3b254cd7339462f91bbe');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_96', 'Hypertension_96', '1972-01-01', NULL
FROM Usuario 
WHERE email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '4.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_96@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_96@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 97
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_97@hypertension-risk.com', 'pbkdf2:sha256:1000000$Qv4HYT8LN0MPuiwB$3cb066a40621e3ec4bfbc59ced63c7b007985c8d68314fcbfcd55012cf4688d8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_97', 'Hypertension_97', '1942-01-01', NULL
FROM Usuario 
WHERE email = 'user_97@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '9.1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'ACE Inhibitor')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_97@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_97@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;

-- Usuario 98
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_98@hypertension-risk.com', 'pbkdf2:sha256:1000000$Y0EK0s7suZNHVf4i$1f3dfc925017d091f439253ea4dd06193e75f13f9b6ae1e651d2d6b508a088a8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_98', 'Hypertension_98', '1960-01-01', NULL
FROM Usuario 
WHERE email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '8.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '8.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Beta Blocker')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_98@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_98@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 99
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_99@hypertension-risk.com', 'pbkdf2:sha256:1000000$F8kkJiANT92cGDck$6ce04a4cbaba1cdc2ea0c55b6c7703ae1d92fe7c2ab3a00648c85de58aea9857');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_99', 'Hypertension_99', '2004-01-01', NULL
FROM Usuario 
WHERE email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Hypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '7.6', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '6.5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'TRUE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_99@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_99@hypertension-risk.com'), 
       True, 
       CURRENT_TIMESTAMP, 
       0.8;

-- Usuario 100
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_100@hypertension-risk.com', 'pbkdf2:sha256:1000000$pzSjZXpFAYJiI6E0$7d958be84095f4e0cd696f3e17a7b99b5de1a6ba40428c9ed08d2495a4e3e8a9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_100', 'Hypertension_100', '2006-01-01', NULL
FROM Usuario 
WHERE email = 'user_100@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.9', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Prehypertension', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 3, '5.3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 8, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 7, '5.8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 10, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'FALSE', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Historial_Medicamento (id_historial, id_medicamento)
SELECT h.id_historial, (SELECT id_medicamento FROM Medicamento WHERE nombre = 'Otro')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_100@hypertension-risk.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Hipertensión'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_100@hypertension-risk.com'), 
       False, 
       CURRENT_TIMESTAMP, 
       0.2;


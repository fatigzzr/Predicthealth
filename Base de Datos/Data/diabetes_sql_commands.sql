-- Comandos SQL generados automáticamente del dataset CDC Diabetes
-- Compatible con init_new.sql

-- Insertar datos de usuarios del dataset CDC
-- Usuario 1
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_1@cdc-diabetes.com', 'pbkdf2:sha256:1000000$KI0ZQrdNc8sJRiLv$c3dac558034085d42e8372786df9805122803f2ed6bc7ac6575d270ac0b61f35');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_1', 'CDC_1', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_1@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_1@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 2
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_2@cdc-diabetes.com', 'pbkdf2:sha256:1000000$df4Z0SWiUEGnRV0J$b02e860117ed033cbe2ce562b54dcf01a128188fb4b6db3cbcdadbac9d64be5c');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_2', 'CDC_2', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_2@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_2@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 3
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_3@cdc-diabetes.com', 'pbkdf2:sha256:1000000$038MouvfqkprEC0a$608dde0739717e6dcb067fd2c4d018685a60eae202fa1eeb5d6be3e97c35fae9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_3', 'CDC_3', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_3@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_3@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 4
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_4@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Q7CBtcsEbhwudjcZ$38960af08e07e8e1efccc74f7df195f7d2036c6ba5fced639b2176d44a6c65b2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_4', 'CDC_4', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_4@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_4@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 5
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_5@cdc-diabetes.com', 'pbkdf2:sha256:1000000$x13nrwgb3Zg81CYK$f3f7f8f4f97d9f211741904454e6167ce9af58a96ae96a3b62e2e64f3b65c501');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_5', 'CDC_5', '1999-01-01', 'F'
FROM Usuario 
WHERE email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_5@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_5@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 6
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_6@cdc-diabetes.com', 'pbkdf2:sha256:1000000$La0HZWFLJjo7a8vs$efe8f2618c32b37e963e7d462d21bb07aa739b291b1a39c15e20729701e66135');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_6', 'CDC_6', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_6@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_6@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 7
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_7@cdc-diabetes.com', 'pbkdf2:sha256:1000000$tsX8lrfF3Oc6WpPP$5817a11d6cadc642c40edcca78ecfc8e481eaf186b4ca68e750e120d9de2a9fb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_7', 'CDC_7', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_7@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_7@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 8
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_8@cdc-diabetes.com', 'pbkdf2:sha256:1000000$FVek8NdNsya0uCLa$55a614c11e569b22cfc8f008e20f417e915556a3a2ab48c339d550c2f5fb1201');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_8', 'CDC_8', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_8@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_8@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 9
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_9@cdc-diabetes.com', 'pbkdf2:sha256:1000000$OcsU56pkQZT4cmT6$e786eea092d0865a041797f5296525b4baa3ba913e15195c48f4f331a1d2fa80');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_9', 'CDC_9', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_9@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_9@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 10
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_10@cdc-diabetes.com', 'pbkdf2:sha256:1000000$EoCmQlWsZ3BkDaUq$f7e11bd2899bb4550ca689898604fb5e0a94df439728c83f89957511293f1548');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_10', 'CDC_10', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_10@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_10@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 11
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_11@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ziwODDD2eK9j07Jv$658f401d73f31827c4d3206b677f0287b051ffcb499a3094030472686db354be');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_11', 'CDC_11', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_11@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_11@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 12
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_12@cdc-diabetes.com', 'pbkdf2:sha256:1000000$fp3lARqlwI093UFW$78f5995e6c4ea55987ea764473e120cba80f515acfa8762df2ecc479d62f2548');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_12', 'CDC_12', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_12@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_12@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 13
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_13@cdc-diabetes.com', 'pbkdf2:sha256:1000000$9QcQVSqCCDX3spWH$9ca6d6dde1df40603bd8cd1e80024c9d33c428cb621c45b24b7277f30b934427');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_13', 'CDC_13', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_13@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_13@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 14
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_14@cdc-diabetes.com', 'pbkdf2:sha256:1000000$t3VZ5N4w5NoWfKLQ$f823f68b9a67a4e36f660e8edb6694e301d043e6eb0794eaaa3dace42dab9c3c');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_14', 'CDC_14', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '3.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_14@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_14@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 15
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_15@cdc-diabetes.com', 'pbkdf2:sha256:1000000$yeC6gUDyZq2Uc0Dv$355d583cb5268aa1506b5af610a3ed7f8537ff16dbf442bba46564deee42ea32');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_15', 'CDC_15', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_15@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_15@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 16
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_16@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Z8tfeYNd7rUZbBox$ea397bf558472ba9c91b40cc2aa95a2e164cad84142256f63265516787efffaf');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_16', 'CDC_16', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_16@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_16@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 17
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_17@cdc-diabetes.com', 'pbkdf2:sha256:1000000$wAMycU2IS8ZdzqxB$49a2f90ae01175740c429e081bd639c2e93c1226c6ca505a80be4b14d9231162');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_17', 'CDC_17', '1989-01-01', 'M'
FROM Usuario 
WHERE email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_17@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_17@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 18
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_18@cdc-diabetes.com', 'pbkdf2:sha256:1000000$3poUq0d6MTvnntGl$4c63be0b3bf0a950d3623d82b0d9768d9784c7df9701550f47da746920a6b005');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_18', 'CDC_18', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_18@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_18@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 19
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_19@cdc-diabetes.com', 'pbkdf2:sha256:1000000$5UHU1XfjXlWROIf5$721b2c31ee6e2fa39bf9893c2bd423e71f3f9886dbdbb273abe1d72acc49e3f6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_19', 'CDC_19', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_19@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_19@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 20
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_20@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CtoQfO0kmuUpIBqX$ecb2c1c094ad3c5d7708c1407f8b9671f6b49cd913d11425f4f04b35498f4263');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_20', 'CDC_20', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_20@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_20@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 21
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_21@cdc-diabetes.com', 'pbkdf2:sha256:1000000$UTAKH1kl64frre0B$920d096225f1aa1e3659c3dd67685d0105e030f51afa792db4b75d9827b9f62e');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_21', 'CDC_21', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_21@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_21@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 22
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_22@cdc-diabetes.com', 'pbkdf2:sha256:1000000$DF5NUEeMXucAcISR$e2723ade914a2b0c2dbcf13d7fcb606dd7830243c9b3dc07d911171b2da98db7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_22', 'CDC_22', '1999-01-01', 'F'
FROM Usuario 
WHERE email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '79.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_22@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_22@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 23
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_23@cdc-diabetes.com', 'pbkdf2:sha256:1000000$PB7nyyBrFEehyB0v$7bcf019a12faa76d23162271fd2870c89000541dda6926202339780fa73df2d7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_23', 'CDC_23', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_23@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_23@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 24
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_24@cdc-diabetes.com', 'pbkdf2:sha256:1000000$bQCxu98bjjcstr0I$21371083a374fdfe47c005f920980f2831966bca75022b4f342d6564da98e60b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_24', 'CDC_24', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_24@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_24@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 25
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_25@cdc-diabetes.com', 'pbkdf2:sha256:1000000$hS7HNBG5NuwVFDuP$190cb0a5ea8bebde19446e1d9853f2d2db06ce965a2cff7cc66d415400b20f28');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_25', 'CDC_25', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '43.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_25@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_25@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 26
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_26@cdc-diabetes.com', 'pbkdf2:sha256:1000000$L90vX7cq9wRgp1Vm$8e82eee7f3e11835353d4fce43cfa1dab2487cd822532edd2d53cda9206cf4df');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_26', 'CDC_26', '1954-01-01', 'M'
FROM Usuario 
WHERE email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_26@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_26@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 27
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_27@cdc-diabetes.com', 'pbkdf2:sha256:1000000$QWWrHvIvJD21sYRs$ef38f975a192ed0b0570d4c880a0344a0429718d5eadead7a5c15ec2d8729933');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_27', 'CDC_27', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_27@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_27@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 28
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_28@cdc-diabetes.com', 'pbkdf2:sha256:1000000$S9Z6cyRH0QK0DBjI$2c6fde093d0ab6a318cfb1d617eff5e7d7310e8865a40482c276ec07c06bf4e3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_28', 'CDC_28', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_28@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_28@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 29
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_29@cdc-diabetes.com', 'pbkdf2:sha256:1000000$B36KkureDsWexwtb$14ae5d3918e8740cd5d0a460ee72f10aaa5a976e0bdaa85530be0d556015acb3');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_29', 'CDC_29', '1999-01-01', 'F'
FROM Usuario 
WHERE email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_29@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_29@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 30
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_30@cdc-diabetes.com', 'pbkdf2:sha256:1000000$S8b0GhETRN2zo68H$50cb751e00689760c4c98def429c7b056e75d6d762be2fc72bd5a0173f153832');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_30', 'CDC_30', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_30@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_30@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 31
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_31@cdc-diabetes.com', 'pbkdf2:sha256:1000000$uH1Aabj3UYSuCWLt$c3fcdc800e54f69e5131bd3728fc10034c96a11ad71d2cc0d76cfd92d3c51a7a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_31', 'CDC_31', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_31@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_31@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 32
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_32@cdc-diabetes.com', 'pbkdf2:sha256:1000000$VfiuolIiAjc8bSuR$4a7fedf5ce5399bb9b0547649c9060de31f910fc73107302edf92bc87b359ed7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_32', 'CDC_32', '2006-01-01', 'F'
FROM Usuario 
WHERE email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '36.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_32@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_32@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 33
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_33@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ts6aJo5meS1KaJHL$6d4cd2ae2e47295dd6432f2a00d9a805cef87329f6072794487ed48141519630');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_33', 'CDC_33', '1989-01-01', 'F'
FROM Usuario 
WHERE email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_33@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_33@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 34
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_34@cdc-diabetes.com', 'pbkdf2:sha256:1000000$aG35pWvuuZ5YtnMC$e24108165d5e10655e52497cef6099c5bad8568c88a03c6fef2332be4fa2bb1b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_34', 'CDC_34', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '38.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_34@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_34@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 35
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_35@cdc-diabetes.com', 'pbkdf2:sha256:1000000$YYHclR4qh9sdJ5fb$b5559fa556dccc674a44ec6edfad3cf631a685723bd1e81b425f3c4378b5c7e2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_35', 'CDC_35', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '15', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_35@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_35@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 36
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_36@cdc-diabetes.com', 'pbkdf2:sha256:1000000$URrVVt1jbfGeLvvL$aa5384f85d025e18b703c3a4685c019e8ed1088e93046268cf0f3f3ed59b931f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_36', 'CDC_36', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '4.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_36@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_36@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 37
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_37@cdc-diabetes.com', 'pbkdf2:sha256:1000000$YbswxTY73jCIJUw5$d2925109c44c2e25dd27d2409ad6d78d4fabd81d22cf720076f89de9e871e1bb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_37', 'CDC_37', '1994-01-01', 'F'
FROM Usuario 
WHERE email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_37@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_37@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 38
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_38@cdc-diabetes.com', 'pbkdf2:sha256:1000000$1nsxQOLhef0I8YaC$269428d3ecdc11ea178de9bd3d6ce5f2b41b66608b5eca582893abb404f6e65f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_38', 'CDC_38', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_38@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_38@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 39
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_39@cdc-diabetes.com', 'pbkdf2:sha256:1000000$crpdX1WI2cJ0PtLY$d2a253451df18e5ae3ade2a7b082d42d5dd5b8c3d33078c689456c3f1a27d90b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_39', 'CDC_39', '1959-01-01', 'M'
FROM Usuario 
WHERE email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_39@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_39@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 40
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_40@cdc-diabetes.com', 'pbkdf2:sha256:1000000$aG8HgQFdYHTRVnr1$5dd6db4682151c9834fe7f8e8ebfe9ac8a05c08f2df48b4705ea8edb8f5d4900');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_40', 'CDC_40', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_40@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_40@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 41
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_41@cdc-diabetes.com', 'pbkdf2:sha256:1000000$xGA2UFMnFNFC6ykj$5fd2503dbf7084550d6122c22359e90ed949d5ef7e98bc29e38b612ca03dd503');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_41', 'CDC_41', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_41@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_41@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 42
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_42@cdc-diabetes.com', 'pbkdf2:sha256:1000000$dAdxcdTeorm1lvkS$f116f57fb0c5cae38df6ddccf44833fa8234e0ca627d41aec4f2388f5cc08390');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_42', 'CDC_42', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '4.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_42@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_42@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 43
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_43@cdc-diabetes.com', 'pbkdf2:sha256:1000000$HladFhFOPnj54rLv$a8e3093ce22261f7ba6500f5ef842027116c529e14d856292555a037c216f077');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_43', 'CDC_43', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '10', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_43@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_43@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 44
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_44@cdc-diabetes.com', 'pbkdf2:sha256:1000000$btvZ1DFeT49fQZ1o$87fc9beea527b6979fd1299e8f414650008dcd89adbb8a2be0bc1fe511ad7656');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_44', 'CDC_44', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_44@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_44@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 45
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_45@cdc-diabetes.com', 'pbkdf2:sha256:1000000$PXPhRBSKsvRSm2rV$c686e2812f68922d3e3c740d1211b22dff68776cb3de81cc9a4f0206a8c67c9f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_45', 'CDC_45', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '15.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_45@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_45@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 46
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_46@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ZUgM3EXocpnzY2m0$c5296c690f5fa9488e0b07a960d7a2a0e5feb2e5d2f5bd3c935d5086152f74ad');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_46', 'CDC_46', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_46@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_46@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 47
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_47@cdc-diabetes.com', 'pbkdf2:sha256:1000000$y3QQDoUCnsItIB7s$c4e52f7e2a5e0bf2692265f51a7b83de819d2465b169938544b3d370688a3bc4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_47', 'CDC_47', '1989-01-01', 'M'
FROM Usuario 
WHERE email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_47@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_47@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 48
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_48@cdc-diabetes.com', 'pbkdf2:sha256:1000000$GxG9ETt0m9I9yGNN$087c9fffd18bc15745006cf55fc64212e2af8760918fa451edf435d17d899a32');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_48', 'CDC_48', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_48@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_48@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 49
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_49@cdc-diabetes.com', 'pbkdf2:sha256:1000000$oTSB5Jd2AKmkWm0S$d7259a3da1d5029a9d5b1ca5f0b3cee759041d531dd80cf9aa4bf878bb6bad2b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_49', 'CDC_49', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_49@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_49@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 50
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_50@cdc-diabetes.com', 'pbkdf2:sha256:1000000$TjcIfoVGpPTjqo6Y$86f2e0ff291a09a0b76abab2e65593af035723a551f67c5fe0e0681fea66abdc');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_50', 'CDC_50', '1939-01-01', 'M'
FROM Usuario 
WHERE email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '1', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_50@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_50@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 51
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_51@cdc-diabetes.com', 'pbkdf2:sha256:1000000$K2z86uqdoCF3BWYo$b61f8286cfd3ce5c319065637553d36ab98bd7ec2f649a847d593b1f973e2db8');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_51', 'CDC_51', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_51@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_51@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 52
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_52@cdc-diabetes.com', 'pbkdf2:sha256:1000000$54IXSMeq2SKlxRay$588911187b9313b93e2f0baea20e65079bb593e9f29f23a1f849d9b8dbb6bfc9');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_52', 'CDC_52', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '1.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_52@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_52@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 53
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_53@cdc-diabetes.com', 'pbkdf2:sha256:1000000$OA9IflzCv2eN2AZn$a57aaa56bbd6a822444cf15418a2471a749a5387d99b6e94486c8f8277992aca');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_53', 'CDC_53', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_53@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_53@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 54
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_54@cdc-diabetes.com', 'pbkdf2:sha256:1000000$eqNYWAoNOcpjrAHD$52f7651491376c110c03ab791a789769a74d22bb8bd366036495104c48fe3e48');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_54', 'CDC_54', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '44.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_54@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_54@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 55
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_55@cdc-diabetes.com', 'pbkdf2:sha256:1000000$PbyMIL83BKVr40rZ$d61a65ebcdcff3bb19a15014e79ae0a9f87cf77900cafd9ccc9b26e3e277bc78');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_55', 'CDC_55', '1974-01-01', 'F'
FROM Usuario 
WHERE email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_55@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_55@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 56
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_56@cdc-diabetes.com', 'pbkdf2:sha256:1000000$GYQOhJTT4NQujRpp$ad9aaae48cf7bd8f758046d70d77fb683aebe91be124ad2bc176891c7059da00');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_56', 'CDC_56', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '14.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_56@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_56@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 57
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_57@cdc-diabetes.com', 'pbkdf2:sha256:1000000$EFRlcLbZCngj9pBq$dac6a4b8afb270f93b52ae1000c97a9dd8e79ccd7f33a349a1498c37a5a08447');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_57', 'CDC_57', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '36.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_57@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_57@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 58
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_58@cdc-diabetes.com', 'pbkdf2:sha256:1000000$mDDhFtYISOyfloQh$23e675a19b7b2ca1a89201644fd153a1a0dbc620099a2d58fbf7f9202c1b73ef');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_58', 'CDC_58', '1994-01-01', 'F'
FROM Usuario 
WHERE email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_58@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_58@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 59
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_59@cdc-diabetes.com', 'pbkdf2:sha256:1000000$56NO5Tykqzrp7wbJ$e3c338f54a71e3e7615c09b108060bd3c503e02bba2d7664135a7f834c93ba7a');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_59', 'CDC_59', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '30', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_59@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_59@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 60
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_60@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Q0tU6GTNigvWHrQY$1814644453512f640a8bab7d2841ead208ecac82181c063ee9efa28fa40b87ad');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_60', 'CDC_60', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '35.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_60@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_60@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 61
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_61@cdc-diabetes.com', 'pbkdf2:sha256:1000000$ZAiCCwZY8XQFzQJo$8cdb91d6855b2cb1ecf675541e667ffdc6d0c76e746dcff6db8f7d3040a047c1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_61', 'CDC_61', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '45.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_61@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_61@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 62
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_62@cdc-diabetes.com', 'pbkdf2:sha256:1000000$VhNOCxUK3RHd19Nv$2d44abfd613aca15785c06d11df975458cc5db9caa7e99b9634b66a5684ee937');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_62', 'CDC_62', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_62@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_62@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 63
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_63@cdc-diabetes.com', 'pbkdf2:sha256:1000000$KQtfFVgW1FEy9kYQ$9c934177a073a27d231cb44fbd965a1bb68cbb0d0bdd444d34744920af70c3b1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_63', 'CDC_63', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '49.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_63@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_63@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 64
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_64@cdc-diabetes.com', 'pbkdf2:sha256:1000000$EACeasErUzvG9Hhr$8541714687a1c9d44345cfefa01f88ff77fb9c853e6957a5a94ed5fc3fc390bb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_64', 'CDC_64', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '8', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_64@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_64@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 65
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_65@cdc-diabetes.com', 'pbkdf2:sha256:1000000$RWBQzLN46P5YzMfi$ae7f8507922d6160ffe686e9b0a718dd026e8744e3a8911624bcbd488c4b2662');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_65', 'CDC_65', '1954-01-01', 'F'
FROM Usuario 
WHERE email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '14', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_65@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_65@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 66
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_66@cdc-diabetes.com', 'pbkdf2:sha256:1000000$7eYPG5iogMKz2Dxi$1b01be0d7bf54409e463826c9bd8b665fe18033c26bba3623a1a6b25ed91ad60');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_66', 'CDC_66', '1994-01-01', 'M'
FROM Usuario 
WHERE email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_66@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_66@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 67
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_67@cdc-diabetes.com', 'pbkdf2:sha256:1000000$BaZg4MjxUaNH1zbC$4e8870989b5bf26b6f5f3686f0774b75df9be9f0a2dbe8f2d3b0bcd3d71ebe88');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_67', 'CDC_67', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_67@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_67@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 68
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_68@cdc-diabetes.com', 'pbkdf2:sha256:1000000$J1NpOuw7cSICNInS$115c4bd46db3fe1649a52b22b78d88149394c5d818004d5cb5aa8e110cdd3278');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_68', 'CDC_68', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_68@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_68@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 69
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_69@cdc-diabetes.com', 'pbkdf2:sha256:1000000$YroLVVj7FJw4ev1F$d53f545bb3eafc3abfb64c9987e5652e08d288107c561646f9feaffb00571c24');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_69', 'CDC_69', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '39.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '4', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_69@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_69@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 70
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_70@cdc-diabetes.com', 'pbkdf2:sha256:1000000$0NQWBsF0CLWKwk4N$3976ca757ffab1cc984a248a701227640cbaf9d682eb0d663e45705d8ecf6e8f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_70', 'CDC_70', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '20.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_70@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_70@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 71
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_71@cdc-diabetes.com', 'pbkdf2:sha256:1000000$qnBZvtBrzebn5VBQ$39db72340d1d1e37ca1c310017ddfba5931f2a7f8f8f43384d5466afcda3a1c6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_71', 'CDC_71', '1939-01-01', 'F'
FROM Usuario 
WHERE email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '41.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '3', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_71@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_71@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 72
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_72@cdc-diabetes.com', 'pbkdf2:sha256:1000000$MlHOlH1G0ZRcUF0a$16a251a1b5b7710244cdeaaf7cfdbbd0518594c8ad0b718422660c7169c443d1');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_72', 'CDC_72', '1984-01-01', 'M'
FROM Usuario 
WHERE email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '43.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '30', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_72@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_72@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 73
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_73@cdc-diabetes.com', 'pbkdf2:sha256:1000000$s3OOJKrxFJFsQgzi$0f93fd37d5e38eff62cc9a55ad475881cabf9105f9a2d7e0731e7b5be26c1d40');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_73', 'CDC_73', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '1.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_73@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_73@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 74
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_74@cdc-diabetes.com', 'pbkdf2:sha256:1000000$t96DJLzikhQ3qEEg$7057b63af91f71f8f58c22aae5b841c0b20c5a2d286de1778afd99c4757d455b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_74', 'CDC_74', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_74@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_74@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 75
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_75@cdc-diabetes.com', 'pbkdf2:sha256:1000000$HBcVqEuVw38FkNkc$fb40ef55112c999f4a6e29bc559e9b0c7fb91aceb0fab85d547b0ea98941d4fb');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_75', 'CDC_75', '1949-01-01', 'M'
FROM Usuario 
WHERE email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_75@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_75@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 76
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_76@cdc-diabetes.com', 'pbkdf2:sha256:1000000$unmbCdt8fFH06wlT$081b477d90c99b9c1a6e59d85cd123024b8b4b0fdc90372a1dad8951af8d1553');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_76', 'CDC_76', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_76@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_76@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 77
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_77@cdc-diabetes.com', 'pbkdf2:sha256:1000000$olkPFhZdakpZ1HZZ$05434e863f4bbaadfe4e1082fa46ad393bf3408f958dbd5e494c34fd547c5eed');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_77', 'CDC_77', '2006-01-01', 'M'
FROM Usuario 
WHERE email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_77@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_77@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 78
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_78@cdc-diabetes.com', 'pbkdf2:sha256:1000000$JJh91P16fH8NGQoc$caeb256c09653798b18c3404d05908bf9eacb683824040e3adfc3d4775185134');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_78', 'CDC_78', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_78@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_78@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 79
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_79@cdc-diabetes.com', 'pbkdf2:sha256:1000000$retCID0llhK8myAL$75701d1330265d9e67d0840f12e2fc9363967b0ac186274b9514d2b0497e36ac');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_79', 'CDC_79', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '21', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_79@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_79@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 80
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_80@cdc-diabetes.com', 'pbkdf2:sha256:1000000$J5BRQLwI5y3Sf18C$42703db3def1142feccd63a5ebe774bbe785f3a0c46099bf770663c2c8eaf809');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_80', 'CDC_80', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '31.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_80@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_80@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 81
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_81@cdc-diabetes.com', 'pbkdf2:sha256:1000000$Qs2AjlnMKXmXRyXJ$18bad50ce60e9a78dede4efb7f7680740ef893ae4d72f1cce2c6328b5225acf6');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_81', 'CDC_81', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '73.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '7', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_81@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_81@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 82
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_82@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CCMwpoaQ2euPkqO8$299bc56418f2401d7b5fd3d9b29db9ee959736a4b67f67b808ce4a842dacae32');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_82', 'CDC_82', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_82@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_82@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 83
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_83@cdc-diabetes.com', 'pbkdf2:sha256:1000000$xUqvNF9fF153aCNJ$404437e4077dbc42184ac0f51620fe779b9c74034857817e80d608ca3799d7e2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_83', 'CDC_83', '1979-01-01', 'F'
FROM Usuario 
WHERE email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_83@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_83@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 84
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_84@cdc-diabetes.com', 'pbkdf2:sha256:1000000$rjRh2YrkzQdex8GH$14d84ec6efae91b31c9d23317e218e68e121f8a879a305a6a2f8519bee5a6700');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_84', 'CDC_84', '1964-01-01', 'M'
FROM Usuario 
WHERE email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '25.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '10.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_84@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_84@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 85
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_85@cdc-diabetes.com', 'pbkdf2:sha256:1000000$SKcAhhRHPOPWg8Vq$2b5172944c1475ab1e02c565406b6552f2712082950c6bae88241bcd7d9b19a0');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_85', 'CDC_85', '1954-01-01', 'M'
FROM Usuario 
WHERE email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '27.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_85@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_85@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 86
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_86@cdc-diabetes.com', 'pbkdf2:sha256:1000000$HbMdEQ2hR1c7lglN$e4fb1fd6e95abd82424dfa7a675535af59f502c4faac17ad760cc1c2120734ce');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_86', 'CDC_86', '1984-01-01', 'F'
FROM Usuario 
WHERE email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '22.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_86@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_86@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 87
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_87@cdc-diabetes.com', 'pbkdf2:sha256:1000000$3m7mrzpKvxhLh1i3$797ea8eb53a543c06dfcd5252a47367391eeb12721408eafae8ec4a3ad7adb84');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_87', 'CDC_87', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_87@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_87@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 88
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_88@cdc-diabetes.com', 'pbkdf2:sha256:1000000$5Q4t0u3KVjyzOr1g$f5794d43e75e64dee5a499bc9c7bb9d1c539f0a752eeda145b7cfc7a0965c128');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_88', 'CDC_88', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '37.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_88@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_88@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 89
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_89@cdc-diabetes.com', 'pbkdf2:sha256:1000000$TQfaIC10Z1P7IbhQ$a05bade8c1b1adb5105dfd48b6651d3f359f5fe60cedc8e4ed4ec13bd557e84f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_89', 'CDC_89', '1974-01-01', 'F'
FROM Usuario 
WHERE email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '29.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_89@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_89@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 90
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_90@cdc-diabetes.com', 'pbkdf2:sha256:1000000$tOY5AnUTylvKaMhS$2add02ab0155fe3d70b63ee7b10f95c1d463de2047fd242e3f52eddcb99b9db7');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_90', 'CDC_90', '1949-01-01', 'F'
FROM Usuario 
WHERE email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '26.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '5.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_90@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_90@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 91
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_91@cdc-diabetes.com', 'pbkdf2:sha256:1000000$j5gvhEyO2IHfLXQ9$64fb2dde7560e27684b84f6ee693099b81c00333e1b0307f04c720584b1bcf18');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_91', 'CDC_91', '1994-01-01', 'F'
FROM Usuario 
WHERE email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '2.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_91@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_91@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 92
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_92@cdc-diabetes.com', 'pbkdf2:sha256:1000000$yi2kZtLXBOuddP79$8525f6f50cf5828f009dcfdc1bfa9412a645252794f954ab23d1d25cfb786b24');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_92', 'CDC_92', '1999-01-01', 'M'
FROM Usuario 
WHERE email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_92@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_92@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 93
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_93@cdc-diabetes.com', 'pbkdf2:sha256:1000000$FyGQvFfPgcDdJfbL$ee5a26c8d65bf58a5176c1a534f499d7eb08e3477c6dfe60dc88f07ad97b30f2');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_93', 'CDC_93', '1974-01-01', 'M'
FROM Usuario 
WHERE email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '30.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_93@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_93@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 94
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_94@cdc-diabetes.com', 'pbkdf2:sha256:1000000$oDPl8FmTx15WCu7D$44e39fbede0a2ae8f8d433b10a9a34c359e12602adde2d283b815f09eda2bd1b');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_94', 'CDC_94', '1949-01-01', 'M'
FROM Usuario 
WHERE email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '33.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Historial_Enfermedad (id_historial, id_enfermedad)
SELECT h.id_historial, (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes')
FROM Historial_Medico h
JOIN Usuario u ON h.id_usuario = u.id_usuario
WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '7.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_94@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_94@cdc-diabetes.com'),
       True, 
       CURRENT_TIMESTAMP,
       0.8;

-- Usuario 95
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_95@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CAGHIq3fiGOXqD4Y$f7efe04587926a0515416d63989586f199cef6f7dc1692c77d114620e0bd9a3d');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_95', 'CDC_95', '1979-01-01', 'M'
FROM Usuario 
WHERE email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '32.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '5', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_95@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_95@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 96
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_96@cdc-diabetes.com', 'pbkdf2:sha256:1000000$X2JYwYrJbqOhKCGo$e673d48ff110a2ecd264fe22a3c2c853225597821fa16a735de62ae24dadfc3f');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_96', 'CDC_96', '1999-01-01', 'M'
FROM Usuario 
WHERE email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '28.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '2', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '1.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_96@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_96@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 97
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_97@cdc-diabetes.com', 'pbkdf2:sha256:1000000$CEbJ48jFXOY7BpNz$6f2ff01ce63fa7b63967558ff1874fc252b93c6eb2169cffd6fd8924c9b10cac');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_97', 'CDC_97', '1959-01-01', 'F'
FROM Usuario 
WHERE email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '21.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Normal', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_97@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_97@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 98
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_98@cdc-diabetes.com', 'pbkdf2:sha256:1000000$0vL6W5LQBgsW2LVR$e0ab1daaf78a20b6e01cd4b8d5cf423cd06e2528652aa5689f6522a467c65ce4');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_98', 'CDC_98', '1954-01-01', 'M'
FROM Usuario 
WHERE email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '23.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_98@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_98@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 99
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_99@cdc-diabetes.com', 'pbkdf2:sha256:1000000$GZRlaly1slM9Wnk2$4fec03e614662f962bf18c11b05af01c2d9317590c448f5634bb770bce64db78');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_99', 'CDC_99', '1969-01-01', 'F'
FROM Usuario 
WHERE email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '38.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_99@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_99@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;

-- Usuario 100
INSERT INTO Usuario (id_rol, email, contraseña_hash) VALUES (1, 'user_100@cdc-diabetes.com', 'pbkdf2:sha256:1000000$llp4u1WOPLJkWEjW$36f87d59c29df8c5301aed5ff56525a2af9677a729c6c7434eb9261961b40685');

INSERT INTO Paciente (id_usuario, nombre, apellido, fecha_nacimiento, sexo)
SELECT id_usuario, 'Usuario_100', 'CDC_100', '1969-01-01', 'M'
FROM Usuario 
WHERE email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 2, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 3, '24.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 4, 'Alta', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 1, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 2, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 4, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 5, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 6, 'False', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 9, '0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 12, '0.0', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Respuesta_Estilo_Vida (id_usuario, id_pregunta, valor, fecha)
SELECT u.id_usuario, 11, 'True', CURRENT_TIMESTAMP
FROM Usuario u WHERE u.email = 'user_100@cdc-diabetes.com';

INSERT INTO Prediccion (id_enfermedad, id_usuario, prediccion, fecha, probabilidad)
SELECT (SELECT id_enfermedad FROM Enfermedad WHERE nombre = 'Diabetes'), 
       (SELECT id_usuario FROM Usuario WHERE email = 'user_100@cdc-diabetes.com'),
       False, 
       CURRENT_TIMESTAMP,
       0.2;


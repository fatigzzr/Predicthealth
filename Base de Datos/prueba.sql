-- Insertar registros de presión arterial para usuario 1 (user_1@cdc-diabetes.com)
-- Día 1 - Múltiples mediciones
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 1, 1, 1, 120, '2024-01-15 08:00:00'),  -- BP_sistolica
(2, 2, 1, 1, 80, '2024-01-15 08:00:00'),   -- BP_diastolica
(2, 1, 1, 1, 125, '2024-01-15 14:00:00'), -- BP_sistolica
(2, 2, 1, 1, 82, '2024-01-15 14:00:00'),  -- BP_diastolica
(2, 1, 1, 1, 118, '2024-01-15 20:00:00'), -- BP_sistolica
(2, 2, 1, 1, 78, '2024-01-15 20:00:00');  -- BP_diastolica

-- Día 2 - Múltiples mediciones
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 1, 1, 1, 135, '2024-01-16 08:00:00'), -- BP_sistolica
(2, 2, 1, 1, 85, '2024-01-16 08:00:00'),   -- BP_diastolica
(2, 1, 1, 1, 130, '2024-01-16 14:00:00'), -- BP_sistolica
(2, 2, 1, 1, 88, '2024-01-16 14:00:00'),  -- BP_diastolica
(2, 1, 1, 1, 140, '2024-01-16 20:00:00'), -- BP_sistolica
(2, 2, 1, 1, 90, '2024-01-16 20:00:00');  -- BP_diastolica

-- Día 3 - Múltiples mediciones
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 1, 1, 1, 110, '2024-01-17 08:00:00'), -- BP_sistolica
(2, 2, 1, 1, 70, '2024-01-17 08:00:00'),  -- BP_diastolica
(2, 1, 1, 1, 115, '2024-01-17 14:00:00'), -- BP_sistolica
(2, 2, 1, 1, 75, '2024-01-17 14:00:00'),  -- BP_diastolica
(2, 1, 1, 1, 112, '2024-01-17 20:00:00'), -- BP_sistolica
(2, 2, 1, 1, 72, '2024-01-17 20:00:00');  -- BP_diastolica

-- Usuario 2 (user_2@cdc-diabetes.com) - ID 3
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(3, 1, 1, 1, 145, '2024-01-15 09:00:00'), -- BP_sistolica
(3, 2, 1, 1, 95, '2024-01-15 09:00:00'),  -- BP_diastolica
(3, 1, 1, 1, 150, '2024-01-15 15:00:00'), -- BP_sistolica
(3, 2, 1, 1, 98, '2024-01-15 15:00:00'), -- BP_diastolica
(3, 1, 1, 1, 142, '2024-01-15 21:00:00'), -- BP_sistolica
(3, 2, 1, 1, 92, '2024-01-15 21:00:00'); -- BP_diastolica

-- Usuario 3 (user_3@cdc-diabetes.com) - ID 4
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(4, 1, 1, 1, 105, '2024-01-16 10:00:00'), -- BP_sistolica
(4, 2, 1, 1, 65, '2024-01-16 10:00:00'),  -- BP_diastolica
(4, 1, 1, 1, 108, '2024-01-16 16:00:00'), -- BP_sistolica
(4, 2, 1, 1, 68, '2024-01-16 16:00:00'),  -- BP_diastolica
(4, 1, 1, 1, 102, '2024-01-16 22:00:00'), -- BP_sistolica
(4, 2, 1, 1, 63, '2024-01-16 22:00:00');  -- BP_diastolica

-- Usuario 4 con dispositivo 2 (Pulsera Fitbit)
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(5, 1, 2, 1, 128, '2024-01-17 07:00:00'), -- BP_sistolica
(5, 2, 2, 1, 82, '2024-01-17 07:00:00'),  -- BP_diastolica
(5, 1, 2, 1, 132, '2024-01-17 13:00:00'), -- BP_sistolica
(5, 2, 2, 1, 85, '2024-01-17 13:00:00'),  -- BP_diastolica
(5, 1, 2, 1, 125, '2024-01-17 19:00:00'), -- BP_sistolica
(5, 2, 2, 1, 80, '2024-01-17 19:00:00');  -- BP_diastolica

-- =====================================
-- DATOS MÁS RECIENTES PARA PROBAR FILTROS
-- =====================================

-- Datos de hace 3 días (para probar "Últimos 7 días")
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 1, 1, 1, 128, NOW() - INTERVAL '3 days' + INTERVAL '08:00:00'),
(2, 2, 1, 1, 85, NOW() - INTERVAL '3 days' + INTERVAL '08:00:00'),
(2, 1, 1, 1, 132, NOW() - INTERVAL '3 days' + INTERVAL '14:00:00'),
(2, 2, 1, 1, 88, NOW() - INTERVAL '3 days' + INTERVAL '14:00:00'),
(2, 1, 1, 1, 130, NOW() - INTERVAL '3 days' + INTERVAL '20:00:00'),
(2, 2, 1, 1, 86, NOW() - INTERVAL '3 days' + INTERVAL '20:00:00');

-- Datos de hace 2 días
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(3, 1, 1, 1, 138, NOW() - INTERVAL '2 days' + INTERVAL '09:00:00'),
(3, 2, 1, 1, 92, NOW() - INTERVAL '2 days' + INTERVAL '09:00:00'),
(3, 1, 1, 1, 142, NOW() - INTERVAL '2 days' + INTERVAL '15:00:00'),
(3, 2, 1, 1, 95, NOW() - INTERVAL '2 days' + INTERVAL '15:00:00'),
(3, 1, 1, 1, 140, NOW() - INTERVAL '2 days' + INTERVAL '21:00:00'),
(3, 2, 1, 1, 93, NOW() - INTERVAL '2 days' + INTERVAL '21:00:00');

-- Datos de ayer
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(4, 1, 1, 1, 115, NOW() - INTERVAL '1 day' + INTERVAL '07:00:00'),
(4, 2, 1, 1, 75, NOW() - INTERVAL '1 day' + INTERVAL '07:00:00'),
(4, 1, 1, 1, 118, NOW() - INTERVAL '1 day' + INTERVAL '13:00:00'),
(4, 2, 1, 1, 78, NOW() - INTERVAL '1 day' + INTERVAL '13:00:00'),
(4, 1, 1, 1, 120, NOW() - INTERVAL '1 day' + INTERVAL '19:00:00'),
(4, 2, 1, 1, 80, NOW() - INTERVAL '1 day' + INTERVAL '19:00:00');

-- Datos de hoy
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(5, 1, 2, 1, 122, NOW() - INTERVAL '2 hours'),
(5, 2, 2, 1, 82, NOW() - INTERVAL '2 hours'),
(5, 1, 2, 1, 125, NOW() - INTERVAL '1 hour'),
(5, 2, 2, 1, 85, NOW() - INTERVAL '1 hour');

-- Datos de hace 10 días (para probar "Últimos 14 días" pero no "Últimos 7 días")
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 1, 1, 1, 135, NOW() - INTERVAL '10 days' + INTERVAL '08:00:00'),
(2, 2, 1, 1, 88, NOW() - INTERVAL '10 days' + INTERVAL '08:00:00'),
(2, 1, 1, 1, 138, NOW() - INTERVAL '10 days' + INTERVAL '14:00:00'),
(2, 2, 1, 1, 90, NOW() - INTERVAL '10 days' + INTERVAL '14:00:00');

-- Datos de hace 20 días (para probar "Últimos 30 días" pero no "Últimos 14 días")
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(3, 1, 1, 1, 148, NOW() - INTERVAL '20 days' + INTERVAL '09:00:00'),
(3, 2, 1, 1, 96, NOW() - INTERVAL '20 days' + INTERVAL '09:00:00'),
(3, 1, 1, 1, 152, NOW() - INTERVAL '20 days' + INTERVAL '15:00:00'),
(3, 2, 1, 1, 98, NOW() - INTERVAL '20 days' + INTERVAL '15:00:00');

-- Datos de hace 35 días (para probar que no aparezcan en ningún filtro)
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(4, 1, 1, 1, 155, NOW() - INTERVAL '35 days' + INTERVAL '10:00:00'),
(4, 2, 1, 1, 100, NOW() - INTERVAL '35 days' + INTERVAL '10:00:00'),
(4, 1, 1, 1, 158, NOW() - INTERVAL '35 days' + INTERVAL '16:00:00'),
(4, 2, 1, 1, 102, NOW() - INTERVAL '35 days' + INTERVAL '16:00:00');

-- =====================================
-- DATOS DE SIGNOS VITALES (HR y SpO2)
-- =====================================

-- Usuario 2 - Frecuencia Cardíaca y Saturación Oxígeno
-- Día 1 - Múltiples mediciones
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 3, 1, 1, 72, '2024-01-15 08:00:00'),  -- HR
(2, 4, 1, 1, 98, '2024-01-15 08:00:00'),  -- SpO2
(2, 3, 1, 1, 75, '2024-01-15 14:00:00'),  -- HR
(2, 4, 1, 1, 97, '2024-01-15 14:00:00'),  -- SpO2
(2, 3, 1, 1, 70, '2024-01-15 20:00:00'),  -- HR
(2, 4, 1, 1, 99, '2024-01-15 20:00:00');  -- SpO2

-- Día 2 - Múltiples mediciones
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 3, 1, 1, 78, '2024-01-16 08:00:00'),  -- HR
(2, 4, 1, 1, 96, '2024-01-16 08:00:00'),  -- SpO2
(2, 3, 1, 1, 82, '2024-01-16 14:00:00'),  -- HR
(2, 4, 1, 1, 95, '2024-01-16 14:00:00'),  -- SpO2
(2, 3, 1, 1, 80, '2024-01-16 20:00:00'),  -- HR
(2, 4, 1, 1, 97, '2024-01-16 20:00:00');  -- SpO2

-- Día 3 - Múltiples mediciones
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 3, 1, 1, 68, '2024-01-17 08:00:00'),  -- HR
(2, 4, 1, 1, 99, '2024-01-17 08:00:00'),  -- SpO2
(2, 3, 1, 1, 72, '2024-01-17 14:00:00'),  -- HR
(2, 4, 1, 1, 98, '2024-01-17 14:00:00'),  -- SpO2
(2, 3, 1, 1, 69, '2024-01-17 20:00:00'),  -- HR
(2, 4, 1, 1, 100, '2024-01-17 20:00:00'); -- SpO2

-- Usuario 3 - Frecuencia Cardíaca y Saturación Oxígeno
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(3, 3, 1, 1, 85, '2024-01-15 09:00:00'),  -- HR
(3, 4, 1, 1, 94, '2024-01-15 09:00:00'),  -- SpO2
(3, 3, 1, 1, 88, '2024-01-15 15:00:00'),  -- HR
(3, 4, 1, 1, 93, '2024-01-15 15:00:00'),  -- SpO2
(3, 3, 1, 1, 82, '2024-01-15 21:00:00'),  -- HR
(3, 4, 1, 1, 95, '2024-01-15 21:00:00');  -- SpO2

-- Usuario 4 - Frecuencia Cardíaca y Saturación Oxígeno
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(4, 3, 1, 1, 65, '2024-01-16 10:00:00'),  -- HR
(4, 4, 1, 1, 98, '2024-01-16 10:00:00'),  -- SpO2
(4, 3, 1, 1, 68, '2024-01-16 16:00:00'),  -- HR
(4, 4, 1, 1, 97, '2024-01-16 16:00:00'),  -- SpO2
(4, 3, 1, 1, 63, '2024-01-16 22:00:00'),  -- HR
(4, 4, 1, 1, 99, '2024-01-16 22:00:00');  -- SpO2

-- Usuario 5 con dispositivo 2 (Pulsera Fitbit)
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(5, 3, 2, 1, 74, '2024-01-17 07:00:00'),  -- HR
(5, 4, 2, 1, 96, '2024-01-17 07:00:00'),  -- SpO2
(5, 3, 2, 1, 78, '2024-01-17 13:00:00'),  -- HR
(5, 4, 2, 1, 95, '2024-01-17 13:00:00'),  -- SpO2
(5, 3, 2, 1, 72, '2024-01-17 19:00:00'),  -- HR
(5, 4, 2, 1, 97, '2024-01-17 19:00:00');  -- SpO2

-- =====================================
-- DATOS RECIENTES PARA PROBAR FILTROS
-- =====================================

-- Datos de hace 3 días (para probar "Últimos 7 días")
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 3, 1, 1, 76, NOW() - INTERVAL '3 days' + INTERVAL '08:00:00'),
(2, 4, 1, 1, 97, NOW() - INTERVAL '3 days' + INTERVAL '08:00:00'),
(2, 3, 1, 1, 80, NOW() - INTERVAL '3 days' + INTERVAL '14:00:00'),
(2, 4, 1, 1, 96, NOW() - INTERVAL '3 days' + INTERVAL '14:00:00'),
(2, 3, 1, 1, 74, NOW() - INTERVAL '3 days' + INTERVAL '20:00:00'),
(2, 4, 1, 1, 98, NOW() - INTERVAL '3 days' + INTERVAL '20:00:00');

-- Datos de hace 2 días
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(3, 3, 1, 1, 90, NOW() - INTERVAL '2 days' + INTERVAL '09:00:00'),
(3, 4, 1, 1, 92, NOW() - INTERVAL '2 days' + INTERVAL '09:00:00'),
(3, 3, 1, 1, 95, NOW() - INTERVAL '2 days' + INTERVAL '15:00:00'),
(3, 4, 1, 1, 91, NOW() - INTERVAL '2 days' + INTERVAL '15:00:00'),
(3, 3, 1, 1, 88, NOW() - INTERVAL '2 days' + INTERVAL '21:00:00'),
(3, 4, 1, 1, 93, NOW() - INTERVAL '2 days' + INTERVAL '21:00:00');

-- Datos de ayer
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(4, 3, 1, 1, 70, NOW() - INTERVAL '1 day' + INTERVAL '07:00:00'),
(4, 4, 1, 1, 98, NOW() - INTERVAL '1 day' + INTERVAL '07:00:00'),
(4, 3, 1, 1, 73, NOW() - INTERVAL '1 day' + INTERVAL '13:00:00'),
(4, 4, 1, 1, 97, NOW() - INTERVAL '1 day' + INTERVAL '13:00:00'),
(4, 3, 1, 1, 68, NOW() - INTERVAL '1 day' + INTERVAL '19:00:00'),
(4, 4, 1, 1, 99, NOW() - INTERVAL '1 day' + INTERVAL '19:00:00');

-- Datos de hoy
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(5, 3, 2, 1, 75, NOW() - INTERVAL '2 hours'),
(5, 4, 2, 1, 96, NOW() - INTERVAL '2 hours'),
(5, 3, 2, 1, 78, NOW() - INTERVAL '1 hour'),
(5, 4, 2, 1, 95, NOW() - INTERVAL '1 hour');

-- Datos de hace 10 días (para probar "Últimos 14 días" pero no "Últimos 7 días")
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(2, 3, 1, 1, 82, NOW() - INTERVAL '10 days' + INTERVAL '08:00:00'),
(2, 4, 1, 1, 94, NOW() - INTERVAL '10 days' + INTERVAL '08:00:00'),
(2, 3, 1, 1, 85, NOW() - INTERVAL '10 days' + INTERVAL '14:00:00'),
(2, 4, 1, 1, 93, NOW() - INTERVAL '10 days' + INTERVAL '14:00:00');

-- Datos de hace 20 días (para probar "Últimos 30 días" pero no "Últimos 14 días")
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(3, 3, 1, 1, 92, NOW() - INTERVAL '20 days' + INTERVAL '09:00:00'),
(3, 4, 1, 1, 90, NOW() - INTERVAL '20 days' + INTERVAL '09:00:00'),
(3, 3, 1, 1, 96, NOW() - INTERVAL '20 days' + INTERVAL '15:00:00'),
(3, 4, 1, 1, 89, NOW() - INTERVAL '20 days' + INTERVAL '15:00:00');

-- Datos de hace 35 días (para probar que no aparezcan en ningún filtro)
INSERT INTO Signo_Vital (id_usuario, id_tipo, id_dispositivo, id_postura, valor, timestamp) VALUES
(4, 3, 1, 1, 88, NOW() - INTERVAL '35 days' + INTERVAL '10:00:00'),
(4, 4, 1, 1, 92, NOW() - INTERVAL '35 days' + INTERVAL '10:00:00'),
(4, 3, 1, 1, 91, NOW() - INTERVAL '35 days' + INTERVAL '16:00:00'),
(4, 4, 1, 1, 91, NOW() - INTERVAL '35 days' + INTERVAL '16:00:00');

-- ========================================
-- DATOS DE LABORATORIO CON FECHAS DIFERENTES
-- ========================================

-- Datos de laboratorio para usuario 2 (user_1@cdc-diabetes.com) - Últimos 3 días
-- Insertar datos de BMI (id_medicion = 3 según init.sql)
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha) VALUES
-- Día 1 (hoy) - BMI
(2, 3, '22.5', NOW() - INTERVAL '0 days'),
(2, 3, '22.8', NOW() - INTERVAL '0 days'),
(2, 3, '22.65', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - Presión arterial (id_medicion = 4)
(2, 4, 'Normal', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - Colesterol alto (id_medicion = 2)
(2, 2, 'False', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - Problemas corazón (id_medicion = 6)
(2, 6, 'False', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - ACV (id_medicion = 5)
(2, 5, 'False', NOW() - INTERVAL '0 days'),

-- Día 2 (ayer) - BMI
(2, 3, '23.1', NOW() - INTERVAL '1 days'),
(2, 3, '23.4', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - Presión arterial
(2, 4, 'Prehypertension', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - Colesterol alto
(2, 2, 'True', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - Problemas corazón
(2, 6, 'False', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - ACV
(2, 5, 'False', NOW() - INTERVAL '1 days'),

-- Día 3 (hace 2 días) - BMI
(2, 3, '24.2', NOW() - INTERVAL '2 days'),
(2, 3, '24.6', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - Presión arterial
(2, 4, 'Hypertension', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - Colesterol alto
(2, 2, 'True', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - Problemas corazón
(2, 6, 'True', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - ACV
(2, 5, 'False', NOW() - INTERVAL '2 days');

-- Datos de laboratorio para usuario 3 (user_2@cdc-diabetes.com) - Últimos 5 días
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha) VALUES
-- Día 1 (hoy) - BMI
(3, 3, '25.1', NOW() - INTERVAL '0 days'),
(3, 3, '25.3', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - Presión arterial
(3, 4, 'Normal', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - Colesterol alto
(3, 2, 'False', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - Problemas corazón
(3, 6, 'False', NOW() - INTERVAL '0 days'),
-- Día 1 (hoy) - ACV
(3, 5, 'False', NOW() - INTERVAL '0 days'),

-- Día 2 (ayer) - BMI
(3, 3, '25.8', NOW() - INTERVAL '1 days'),
(3, 3, '26.1', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - Presión arterial
(3, 4, 'Alta', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - Colesterol alto
(3, 2, 'True', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - Problemas corazón
(3, 6, 'False', NOW() - INTERVAL '1 days'),
-- Día 2 (ayer) - ACV
(3, 5, 'False', NOW() - INTERVAL '1 days'),

-- Día 3 (hace 2 días) - BMI
(3, 3, '26.5', NOW() - INTERVAL '2 days'),
(3, 3, '26.8', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - Presión arterial
(3, 4, 'Hypertension', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - Colesterol alto
(3, 2, 'True', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - Problemas corazón
(3, 6, 'True', NOW() - INTERVAL '2 days'),
-- Día 3 (hace 2 días) - ACV
(3, 5, 'False', NOW() - INTERVAL '2 days'),

-- Día 4 (hace 3 días) - BMI
(3, 3, '27.2', NOW() - INTERVAL '3 days'),
(3, 3, '27.5', NOW() - INTERVAL '3 days'),
-- Día 4 (hace 3 días) - Presión arterial
(3, 4, 'Prehypertension', NOW() - INTERVAL '3 days'),
-- Día 4 (hace 3 días) - Colesterol alto
(3, 2, 'True', NOW() - INTERVAL '3 days'),
-- Día 4 (hace 3 días) - Problemas corazón
(3, 6, 'True', NOW() - INTERVAL '3 days'),
-- Día 4 (hace 3 días) - ACV
(3, 5, 'True', NOW() - INTERVAL '3 days'),

-- Día 5 (hace 4 días) - BMI
(3, 3, '28.1', NOW() - INTERVAL '4 days'),
(3, 3, '28.4', NOW() - INTERVAL '4 days'),
-- Día 5 (hace 4 días) - Presión arterial
(3, 4, 'Hypertension', NOW() - INTERVAL '4 days'),
-- Día 5 (hace 4 días) - Colesterol alto
(3, 2, 'True', NOW() - INTERVAL '4 days'),
-- Día 5 (hace 4 días) - Problemas corazón
(3, 6, 'True', NOW() - INTERVAL '4 days'),
-- Día 5 (hace 4 días) - ACV
(3, 5, 'True', NOW() - INTERVAL '4 days');

-- Datos de laboratorio para usuario 4 (user_3@cdc-diabetes.com) - Más de 7 días (para probar filtros)
INSERT INTO Historial_Medico (id_usuario, id_medicion, valor, fecha) VALUES
-- Día 8 (hace 8 días) - NO debería aparecer en filtro de 7 días
(4, 3, '29.5', NOW() - INTERVAL '8 days'),
(4, 3, '29.8', NOW() - INTERVAL '8 days'),
(4, 4, 'Hypertension', NOW() - INTERVAL '8 days'),
(4, 2, 'True', NOW() - INTERVAL '8 days'),
(4, 6, 'True', NOW() - INTERVAL '8 days'),
(4, 5, 'True', NOW() - INTERVAL '8 days'),

-- Día 10 (hace 10 días) - NO debería aparecer en filtro de 7 días
(4, 3, '30.2', NOW() - INTERVAL '10 days'),
(4, 3, '30.5', NOW() - INTERVAL '10 days'),
(4, 4, 'Hypertension', NOW() - INTERVAL '10 days'),
(4, 2, 'True', NOW() - INTERVAL '10 days'),
(4, 6, 'True', NOW() - INTERVAL '10 days'),
(4, 5, 'True', NOW() - INTERVAL '10 days'),

-- Día 15 (hace 15 días) - NO debería aparecer en filtro de 7 días
(4, 3, '31.1', NOW() - INTERVAL '15 days'),
(4, 3, '31.4', NOW() - INTERVAL '15 days'),
(4, 4, 'Hypertension', NOW() - INTERVAL '15 days'),
(4, 2, 'True', NOW() - INTERVAL '15 days'),
(4, 6, 'True', NOW() - INTERVAL '15 days'),
(4, 5, 'True', NOW() - INTERVAL '15 days');
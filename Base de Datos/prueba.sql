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

-- =====================================
-- DATOS PARA DASHBOARD DE ACTIVIDAD DE USUARIOS
-- =====================================

-- Actualizar fechas de usuarios existentes para simular actividad diaria
-- Usuario 2 - Actividad reciente (últimos 7 días)
UPDATE Usuario SET 
    actualizado_en = NOW() - INTERVAL '1 day' + INTERVAL '14:30:00',
    creado_en = NOW() - INTERVAL '5 days' + INTERVAL '09:15:00'
WHERE id_usuario = 2;

-- Usuario 3 - Actividad hace 2 días
UPDATE Usuario SET 
    actualizado_en = NOW() - INTERVAL '2 days' + INTERVAL '16:45:00',
    creado_en = NOW() - INTERVAL '8 days' + INTERVAL '11:20:00'
WHERE id_usuario = 3;

-- Usuario 4 - Actividad hace 3 días
UPDATE Usuario SET 
    actualizado_en = NOW() - INTERVAL '3 days' + INTERVAL '10:15:00',
    creado_en = NOW() - INTERVAL '12 days' + INTERVAL '08:30:00'
WHERE id_usuario = 4;

-- Usuario 5 - Actividad hace 4 días
UPDATE Usuario SET 
    actualizado_en = NOW() - INTERVAL '4 days' + INTERVAL '13:20:00',
    creado_en = NOW() - INTERVAL '15 days' + INTERVAL '15:45:00'
WHERE id_usuario = 5;

-- Crear usuarios adicionales para simular actividad diaria variada
-- Usuario 6 - Actividad hace 5 días (Doctor)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'maria.gonzalez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '5 days' + INTERVAL '12:30:00', 
 NOW() - INTERVAL '5 days' + INTERVAL '12:30:00');

-- Usuario 7 - Actividad hace 6 días (Doctor)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'carlos.lopez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '6 days' + INTERVAL '14:15:00', 
 NOW() - INTERVAL '6 days' + INTERVAL '14:15:00');

-- Usuario 8 - Doctor (hace 7 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'ana.martinez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '7 days' + INTERVAL '16:45:00', 
 NOW() - INTERVAL '7 days' + INTERVAL '16:45:00');

-- Usuario 9 - Administrador (hace 10 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(3, 'roberto.hernandez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '10 days' + INTERVAL '09:30:00', 
 NOW() - INTERVAL '10 days' + INTERVAL '09:30:00');

-- Usuario 10 - Analista (hace 12 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(4, 'laura.sanchez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '12 days' + INTERVAL '11:45:00', 
 NOW() - INTERVAL '12 days' + INTERVAL '11:45:00');

-- Usuario 11 - Doctor (hace 15 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'diego.ramirez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '15 days' + INTERVAL '13:20:00', 
 NOW() - INTERVAL '15 days' + INTERVAL '13:20:00');

-- Usuario 12 - Doctor (hace 18 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'patricia.flores@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '18 days' + INTERVAL '15:10:00', 
 NOW() - INTERVAL '18 days' + INTERVAL '15:10:00');

-- Usuario 13 - Administrador (hace 20 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(3, 'miguel.torres@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '20 days' + INTERVAL '10:25:00', 
 NOW() - INTERVAL '20 days' + INTERVAL '10:25:00');

-- Usuario 14 - Analista (hace 25 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(4, 'sofia.vargas@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '25 days' + INTERVAL '14:50:00', 
 NOW() - INTERVAL '25 days' + INTERVAL '14:50:00');

-- Usuario 15 - Doctor (hace 28 días)
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'fernando.morales@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '28 days' + INTERVAL '12:15:00', 
 NOW() - INTERVAL '28 days' + INTERVAL '12:15:00');

-- Simular actividad adicional en días específicos
-- Día hace 1 día - Más usuarios activos
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'carmen.jimenez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '1 day' + INTERVAL '08:30:00', 
 NOW() - INTERVAL '1 day' + INTERVAL '08:30:00'),
(3, 'jorge.castro@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '1 day' + INTERVAL '10:45:00', 
 NOW() - INTERVAL '1 day' + INTERVAL '10:45:00');

-- Día hace 2 días - Pico de actividad
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'isabel.ruiz@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '2 days' + INTERVAL '09:15:00', 
 NOW() - INTERVAL '2 days' + INTERVAL '09:15:00'),
(2, 'antonio.mendoza@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '2 days' + INTERVAL '11:30:00', 
 NOW() - INTERVAL '2 days' + INTERVAL '11:30:00'),
(4, 'elena.silva@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '2 days' + INTERVAL '13:45:00', 
 NOW() - INTERVAL '2 days' + INTERVAL '13:45:00');

-- Día hace 3 días - Actividad moderada
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'ricardo.perez@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '3 days' + INTERVAL '14:20:00', 
 NOW() - INTERVAL '3 days' + INTERVAL '14:20:00'),
(3, 'valentina.rojas@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '3 days' + INTERVAL '16:35:00', 
 NOW() - INTERVAL '3 days' + INTERVAL '16:35:00');

-- Día hace 4 días - Actividad baja
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'gabriel.ortega@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '4 days' + INTERVAL '12:10:00', 
 NOW() - INTERVAL '4 days' + INTERVAL '12:10:00');

-- Día hace 5 días - Actividad moderada
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'natalia.guerrero@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '5 days' + INTERVAL '15:25:00', 
 NOW() - INTERVAL '5 days' + INTERVAL '15:25:00'),
(4, 'hector.vega@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '5 days' + INTERVAL '17:40:00', 
 NOW() - INTERVAL '5 days' + INTERVAL '17:40:00');

-- Día hace 6 días - Actividad alta
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'adriana.molina@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '6 days' + INTERVAL '10:15:00', 
 NOW() - INTERVAL '6 days' + INTERVAL '10:15:00'),
(2, 'oscar.herrera@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '6 days' + INTERVAL '12:30:00', 
 NOW() - INTERVAL '6 days' + INTERVAL '12:30:00'),
(3, 'claudia.reyes@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '6 days' + INTERVAL '14:45:00', 
 NOW() - INTERVAL '6 days' + INTERVAL '14:45:00');

-- Día hace 7 días - Actividad moderada
INSERT INTO Usuario (id_rol, email, contraseña_hash, creado_en, actualizado_en) VALUES
(2, 'raul.campos@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '7 days' + INTERVAL '11:20:00', 
 NOW() - INTERVAL '7 days' + INTERVAL '11:20:00'),
(4, 'monica.luna@test.com', crypt('password123', gen_salt('bf')), 
 NOW() - INTERVAL '7 days' + INTERVAL '13:35:00', 
 NOW() - INTERVAL '7 days' + INTERVAL '13:35:00');

-- Simular actualizaciones de usuarios existentes en diferentes días
-- Usuario 2 - Actualización hace 1 día
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '1 day' + INTERVAL '16:30:00' WHERE id_usuario = 2;

-- Usuario 3 - Actualización hace 2 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '2 days' + INTERVAL '18:15:00' WHERE id_usuario = 3;

-- Usuario 4 - Actualización hace 3 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '3 days' + INTERVAL '14:45:00' WHERE id_usuario = 4;

-- Usuario 5 - Actualización hace 4 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '4 days' + INTERVAL '12:20:00' WHERE id_usuario = 5;

-- Usuario 6 - Actualización hace 5 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '5 days' + INTERVAL '15:10:00' WHERE id_usuario = 6;

-- Usuario 7 - Actualización hace 6 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '6 days' + INTERVAL '17:25:00' WHERE id_usuario = 7;

-- Usuario 8 - Actualización hace 7 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '7 days' + INTERVAL '19:40:00' WHERE id_usuario = 8;

-- Usuario 9 - Actualización hace 10 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '10 days' + INTERVAL '11:15:00' WHERE id_usuario = 9;

-- Usuario 10 - Actualización hace 12 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '12 days' + INTERVAL '13:30:00' WHERE id_usuario = 10;

-- Usuario 11 - Actualización hace 15 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '15 days' + INTERVAL '15:45:00' WHERE id_usuario = 11;

-- Usuario 12 - Actualización hace 18 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '18 days' + INTERVAL '17:20:00' WHERE id_usuario = 12;

-- Usuario 13 - Actualización hace 20 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '20 days' + INTERVAL '12:35:00' WHERE id_usuario = 13;

-- Usuario 14 - Actualización hace 25 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '25 days' + INTERVAL '16:50:00' WHERE id_usuario = 14;

-- Usuario 15 - Actualización hace 28 días
UPDATE Usuario SET actualizado_en = NOW() - INTERVAL '28 days' + INTERVAL '14:25:00' WHERE id_usuario = 15;

-- =====================================
-- DATOS DUMMY PARA PREDICCIONES POR MES
-- =====================================

-- Insertar predicciones para diferentes meses
-- Enero 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-01-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 45;

-- Enero 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-01-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 45;

-- Febrero 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-02-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 52;

-- Febrero 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-02-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 52;

-- Marzo 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-03-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 38;

-- Marzo 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-03-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 38;

-- Abril 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-04-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 67;

-- Abril 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-04-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 67;

-- Mayo 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-05-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 73;

-- Mayo 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-05-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 73;

-- Junio 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-06-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 89;

-- Junio 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-06-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 89;

-- Julio 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-07-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 95;

-- Julio 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-07-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 95;

-- Agosto 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-08-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 112;

-- Agosto 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-08-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 112;

-- Septiembre 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-09-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 128;

-- Septiembre 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-09-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 128;

-- Octubre 2025 - Diabetes (datos adicionales)
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-10-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 25;

-- Octubre 2025 - Hipertensión (datos adicionales)
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-10-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 25;

-- Noviembre 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-11-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 142;

-- Noviembre 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-11-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 142;

-- Diciembre 2025 - Diabetes
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    1, -- Diabetes
    u.id_usuario,
    1, -- Modelo base
    CASE WHEN random() > 0.6 THEN true ELSE false END,
    '2025-12-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.3 + random() * 0.4
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 156;

-- Diciembre 2025 - Hipertensión
INSERT INTO Prediccion (id_enfermedad, id_usuario, id_modelo, prediccion, fecha, probabilidad)
SELECT 
    2, -- Hipertensión
    u.id_usuario,
    2, -- Modelo base hipertensión
    CASE WHEN random() > 0.7 THEN true ELSE false END,
    '2025-12-15'::timestamp + (random() * 15)::int * INTERVAL '1 day',
    0.2 + random() * 0.5
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 50
LIMIT 156;

-- =====================================
-- DATOS DUMMY PARA ESTADO DE DOCUMENTOS
-- =====================================

-- Primero necesitamos insertar algunos documentos base
INSERT INTO Documento (nombre)
VALUES 
    ('Laboratorio'),
    ('Radiología'),
    ('Historia Clínica'),
    ('Receta Médica')
ON CONFLICT DO NOTHING;

-- Insertar documentos subidos con diferentes estados
-- Documentos Procesados (150 registros) - CON texto_raw
INSERT INTO Documento_Subido (id_usuario, id_documento, fecha_subido, texto_raw)
SELECT 
    u.id_usuario,
    (SELECT id_documento FROM Documento ORDER BY random() LIMIT 1),
    NOW() - (random() * 30)::int * INTERVAL '1 day',
    'Contenido procesado del documento ' || generate_series(1, 3)
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 100
LIMIT 150;

-- Documentos Pendientes (80 registros) - SIN texto_raw (NULL)
INSERT INTO Documento_Subido (id_usuario, id_documento, fecha_subido, texto_raw)
SELECT 
    u.id_usuario,
    (SELECT id_documento FROM Documento ORDER BY random() LIMIT 1),
    NOW() - (random() * 7)::int * INTERVAL '1 day',
    NULL  -- Sin contenido = Pendiente
FROM Usuario u
WHERE u.id_usuario BETWEEN 1 AND 100
LIMIT 80;
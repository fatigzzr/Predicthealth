-- =====================================
-- SCRIPT DE INSERCIÓN DE DATOS BÁSICOS
-- Solo con los datos específicos proporcionados
-- =====================================

-- Conectarse a la base de datos predicthealth
\c predicthealth

-- =====================================
-- INSERTAR ROLES
-- =====================================
INSERT INTO Rol (id_rol, nombre) VALUES 
(1, 'Paciente'),
(2, 'Doctor'),
(3, 'Administrador'),
(4, 'Analista');

-- =====================================
-- INSERTAR FUENTES GPS
-- =====================================
INSERT INTO Fuente_GPS (id_fuente, nombre) VALUES 
(1, 'GPS'),
(2, 'Wi-Fi'),
(3, 'Celular / GSM'),
(4, 'Bluetooth / Beacons'),
(5, 'Manual / Usuario');


-- =====================================
-- INSERTAR ENFERMEDADES DE EJEMPLO
-- =====================================
INSERT INTO Enfermedad (nombre) VALUES ('Diabetes');
INSERT INTO Enfermedad (nombre) VALUES ('Hipertensión');

-- =====================================
-- INSERTAR RECOMENDACIONES PARA DIABETES (BASADAS EN MAYO CLINIC)
-- =====================================
INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Comprométete a controlar tu diabetes',
    'Los miembros de tu equipo de atención de la diabetes pueden ayudarte a aprender los conceptos básicos de los cuidados para la diabetes y ofrecerte apoyo. Pero depende de ti tratar tu afección. Infórmate sobre todo lo que puedas acerca de la diabetes. Haz que la alimentación saludable y la actividad física sean parte de tu rutina diaria. Mantén un peso saludable. Mídete la glucosa en la sangre y sigue las indicaciones de tu proveedor de atención médica para controlar el nivel.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'No fumes',
    'Evita fumar o deja de fumar si lo haces. Fumar aumenta el riesgo de múltiples complicaciones de salud, incluyendo: reducción del flujo sanguíneo, enfermedades cardíacas, accidente cerebrovascular, enfermedades oculares, daño en los nervios, enfermedad renal y muerte prematura.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Mantén tu presión arterial y tu colesterol bajo control',
    'Al igual que la diabetes, la presión arterial alta (hipertensión arterial) puede dañar los vasos sanguíneos. El colesterol alto también es una preocupación, ya que el daño resultante suele ser peor y desarrollarse más rápido cuando se tiene diabetes. Cuando estos afecciones se combinan, pueden provocar un ataque cardíaco, un accidente cerebrovascular u otras afecciones que pueden poner en riesgo la vida.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Programa exámenes físicos y oculares regulares',
    'Programa de dos a cuatro consultas de control de la diabetes al año, además de los exámenes físicos y oculares regulares. Durante el examen físico, tu proveedor de atención médica te preguntará sobre tu alimentación y nivel de actividad, y buscará cualquier complicación relacionada con la diabetes, incluidos signos de daño renal, daño nervioso y enfermedad cardíaca.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Mantén al día tus vacunas',
    'La diabetes aumenta el riesgo de contraer ciertas enfermedades. Las vacunas de rutina pueden ayudar a prevenirlas. Pregúntale a tu proveedor de atención médica sobre las vacunas contra la influenza, la neumonía, la hepatitis B, el tétanos, la difteria y la tos ferina (Tdap).'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Cuida tus dientes',
    'La diabetes puede hacer que seas propenso a las infecciones de las encías. Cepíllate los dientes al menos dos veces al día con un cepillo de dientes de cerdas suaves, usa hilo dental una vez al día y programa exámenes dentales al menos dos veces al año. Consulta a tu dentista de inmediato si tus encías sangran o se ven rojas o hinchadas.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Presta atención a tus pies',
    'La diabetes puede dañar los nervios de los pies y reducir el flujo sanguíneo a los pies. Si no se tratan, los cortes y las ampollas pueden provocar infecciones graves. Para prevenir problemas en los pies: lávate los pies diariamente con agua tibia, sécalos suavemente, especialmente entre los dedos, y humecta los pies y los tobillos con loción o vaselina.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Considera tomar una aspirina diaria',
    'Si tienes diabetes y otros factores de riesgo cardiovascular, como fumar o hipertensión arterial, tu proveedor de atención médica puede recomendarte una terapia con aspirina en dosis bajas para ayudar a reducir el riesgo de ataque cardíaco y accidente cerebrovascular.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Si bebes alcohol, hazlo de manera responsable',
    'El alcohol puede afectar tu salud de múltiples maneras. Si decides beber, hazlo solo con moderación y siempre con una comida. El consumo excesivo de alcohol puede aumentar el riesgo de problemas de salud y complicaciones médicas.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Toma en serio el estrés',
    'El estrés prolongado puede afectar negativamente tu salud y bienestar general. Las hormonas del estrés pueden interferir con el funcionamiento normal del cuerpo y aumentar el riesgo de problemas de salud. Establece límites, prioriza tus tareas, aprende técnicas de relajación y duerme lo suficiente.'
);

-- =====================================
-- INSERTAR RECOMENDACIONES PARA HIPERTENSIÓN (BASADAS EN MAYO CLINIC)
-- =====================================
INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Baja el sobrepeso y cuida tu silueta',
    'La presión arterial suele subir cuando se aumenta de peso. Tener sobrepeso también puede causar una interrupción de la respiración al dormir, una afección que se llama apnea del sueño. La apnea del sueño además eleva la presión arterial. Una de las mejores formas de controlar la presión arterial es bajar de peso. Si eres una persona con sobrepeso u obesidad, bajar incluso una pequeña cantidad de peso puede ayudarte a reducir la presión arterial.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Haz ejercicio regularmente',
    'Si se practica con regularidad, la actividad aeróbica puede reducir la presión arterial alta aproximadamente de 5 mm Hg a 8 mm Hg. Es importante seguir haciendo ejercicio para evitar que la presión arterial vuelva a subir. Como meta general, procura hacer al menos 30 minutos de actividad física moderada todos los días.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Sigue una dieta saludable',
    'Comer una dieta rica en granos integrales, frutas, verduras y productos lácteos bajos en grasa y que reduzca las grasas saturadas y el colesterol puede reducir la presión arterial hasta 11 mm Hg. Este plan de alimentación se conoce como la dieta DASH (Enfoques Alimentarios para Detener la Hipertensión).'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Reduce el sodio en tu dieta',
    'Incluso una pequeña reducción del sodio en tu dieta puede mejorar la salud del corazón y reducir la presión arterial aproximadamente de 5 mm Hg a 6 mm Hg. El efecto de la ingesta de sodio en la presión arterial varía entre grupos de personas. En general, limita el sodio a 2,300 miligramos (mg) al día o menos.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Reduce el consumo de cafeína',
    'El papel que desempeña la cafeína en la presión arterial sigue siendo discutido. La cafeína puede elevar la presión arterial hasta 10 mm Hg en personas que rara vez la consumen. Pero las personas que beben café regularmente pueden experimentar poco o ningún efecto en la presión arterial.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Monitorea tu presión arterial en casa y ve al médico con regularidad',
    'El monitoreo en el hogar puede ayudarte a controlar tu presión arterial, asegurarte de que los cambios en tu estilo de vida funcionen y alertarte a ti y a tu médico sobre posibles complicaciones de salud. Los monitores de presión arterial están disponibles ampliamente y sin receta médica.'
);

INSERT INTO Recomendacion (titulo, descripcion) VALUES (
    'Busca apoyo',
    'La familia y los amigos comprensivos pueden ayudar a mejorar tu salud. Pueden alentarte a cuidarte, llevarte al consultorio del médico o embarcarse en un programa de ejercicios contigo para mantener tu presión arterial baja. Si encuentras que necesitas apoyo más allá de tu familia y amigos, considera unirte a un grupo de apoyo.'
);

-- =====================================
-- INSERTAR RELACIONES ENTRE DIABETES Y RECOMENDACIONES
-- =====================================
INSERT INTO Enfermedad_Recomendacion (id_enfermedad, id_recomendacion) 
SELECT e.id_enfermedad, r.id_recomendacion 
FROM Enfermedad e, Recomendacion r 
WHERE e.nombre = 'Diabetes' 
AND r.titulo IN (
    'Comprométete a controlar tu diabetes',
    'No fumes',
    'Mantén tu presión arterial y tu colesterol bajo control',
    'Programa exámenes físicos y oculares regulares',
    'Mantén al día tus vacunas',
    'Cuida tus dientes',
    'Presta atención a tus pies',
    'Considera tomar una aspirina diaria',
    'Si bebes alcohol, hazlo de manera responsable',
    'Toma en serio el estrés'
);

-- =====================================
-- INSERTAR RELACIONES ENTRE HIPERTENSIÓN Y RECOMENDACIONES ÚNICAS
-- =====================================
INSERT INTO Enfermedad_Recomendacion (id_enfermedad, id_recomendacion) 
SELECT e.id_enfermedad, r.id_recomendacion 
FROM Enfermedad e, Recomendacion r 
WHERE e.nombre = 'Hipertensión' 
AND r.titulo IN (
    'Baja el sobrepeso y cuida tu silueta',
    'Haz ejercicio regularmente',
    'Sigue una dieta saludable',
    'Reduce el sodio en tu dieta',
    'Reduce el consumo de cafeína',
    'Monitorea tu presión arterial en casa y ve al médico con regularidad',
    'Busca apoyo'
);

-- =====================================
-- INSERTAR RELACIONES ENTRE HIPERTENSIÓN Y RECOMENDACIONES SIMILARES (QUE YA EXISTEN PARA DIABETES)
-- =====================================
INSERT INTO Enfermedad_Recomendacion (id_enfermedad, id_recomendacion) 
SELECT e.id_enfermedad, r.id_recomendacion 
FROM Enfermedad e, Recomendacion r 
WHERE e.nombre = 'Hipertensión' 
AND r.titulo IN (
    'No fumes',
    'Si bebes alcohol, hazlo de manera responsable',
    'Toma en serio el estrés'
);

-- =====================================
-- INSERTAR TIPOS DE DOCUMENTOS
-- =====================================
INSERT INTO Documento (nombre) VALUES ('Hemoglobina Glicada (HbA1c)');
INSERT INTO Documento (nombre) VALUES ('Curva de Tolerancia a la Glucosa');
INSERT INTO Documento (nombre) VALUES ('Perfil Lipídico');
INSERT INTO Documento (nombre) VALUES ('Panel Metabólico');
INSERT INTO Documento (nombre) VALUES ('Registros de Monitoreo de Presión Arterial (PA)');
INSERT INTO Documento (nombre) VALUES ('Consulta');

-- =====================================
-- INSERTAR ENTIDADES DE LA BASE DE DATOS
-- =====================================
INSERT INTO Entidad (nombre) VALUES ('Paciente');
INSERT INTO Entidad (nombre) VALUES ('Registro_Auditoria');
INSERT INTO Entidad (nombre) VALUES ('Gps');
INSERT INTO Entidad (nombre) VALUES ('Historial_Medico');
INSERT INTO Entidad (nombre) VALUES ('Resultado_Lab');
INSERT INTO Entidad (nombre) VALUES ('Usuario');
INSERT INTO Entidad (nombre) VALUES ('Rol');
INSERT INTO Entidad (nombre) VALUES ('Refresh_Token');
INSERT INTO Entidad (nombre) VALUES ('Fuente_GPS');
INSERT INTO Entidad (nombre) VALUES ('Registros_GPS');
INSERT INTO Entidad (nombre) VALUES ('Unidad');
INSERT INTO Entidad (nombre) VALUES ('Tipo_Medicion');
INSERT INTO Entidad (nombre) VALUES ('Pregunta');
INSERT INTO Entidad (nombre) VALUES ('Respuesta_Estilo_Vida');
INSERT INTO Entidad (nombre) VALUES ('Analito');
INSERT INTO Entidad (nombre) VALUES ('Tipo_Signo_Vital');
INSERT INTO Entidad (nombre) VALUES ('Postura');
INSERT INTO Entidad (nombre) VALUES ('Dispositivo');
INSERT INTO Entidad (nombre) VALUES ('Signo_Vital');
INSERT INTO Entidad (nombre) VALUES ('Enfermedad');
INSERT INTO Entidad (nombre) VALUES ('Modelo');
INSERT INTO Entidad (nombre) VALUES ('Prediccion');
INSERT INTO Entidad (nombre) VALUES ('Recomendacion');
INSERT INTO Entidad (nombre) VALUES ('Documento');
INSERT INTO Entidad (nombre) VALUES ('Documento_Subido');
INSERT INTO Entidad (nombre) VALUES ('Consulta');
INSERT INTO Entidad (nombre) VALUES ('Extracciones_Nlp');
INSERT INTO Entidad (nombre) VALUES ('Historial_Enfermedad');
INSERT INTO Entidad (nombre) VALUES ('Medicamento');
INSERT INTO Entidad (nombre) VALUES ('Historial_Medicamento');
INSERT INTO Entidad (nombre) VALUES ('Enfermedad_Recomendacion');
INSERT INTO Entidad (nombre) VALUES ('Documento_Enfermedad');

-- =====================================
-- INSERTAR UNIDADES
-- =====================================
INSERT INTO Unidad (unidad) VALUES ('%');
INSERT INTO Unidad (unidad) VALUES ('mg/dL');
INSERT INTO Unidad (unidad) VALUES ('mmHg');
INSERT INTO Unidad (unidad) VALUES ('bpm');
INSERT INTO Unidad (unidad) VALUES ('BOOLEAN');
INSERT INTO Unidad (unidad) VALUES ('si/no');
INSERT INTO Unidad (unidad) VALUES ('número');
INSERT INTO Unidad (unidad) VALUES ('escala');
INSERT INTO Unidad (unidad) VALUES ('texto');

-- =====================================
-- INSERTAR TIPOS DE SIGNOS VITALES
-- =====================================
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (3, 'BP_sistolica');
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (3, 'BP_diastolica');
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (4, 'HR');
INSERT INTO Tipo_Signo_Vital (id_unidad, nombre) VALUES (1, 'SpO2');

-- =====================================
-- INSERTAR CONSULTAS
-- =====================================
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('diabetes_confirmada', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('hipertension_confirmada', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_metformina', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_insulina', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_losartan', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('tratamiento_amlodipino', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('complicacion_retinopatia', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('complicacion_neuropatia', 5);
INSERT INTO Consulta (nombre, tipo_dato) VALUES ('complicacion_nefropatia', 5);

-- =====================================
-- INSERTAR POSTURAS
-- =====================================
INSERT INTO Postura (nombre) VALUES ('Sentado');

-- =====================================
-- INSERTAR ANALITOS
-- =====================================
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('HBA1C', 1, 'Hemoglobina Glicada', '4–6');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('GLU', 2, 'Glucosa en ayunas', '70–110');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('LDL', 2, 'Colesterol LDL', '<130');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('HDL', 2, 'Colesterol HDL', '>40');
INSERT INTO Analito (analito_codigo, id_unidad, nombre, referencia) VALUES ('TRIG', 2, 'Triglicéridos', '<150');

-- =====================================
-- INSERTAR DISPOSITIVOS
-- =====================================
INSERT INTO Dispositivo (nombre) VALUES ('Tensiómetro Omron');
INSERT INTO Dispositivo (nombre) VALUES ('Pulsera Fitbit');

-- =====================================
-- INSERTAR TIPOS DE MEDICIÓN
-- =====================================
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('colesterol', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('colesterol alto', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('bmi', 7);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('presión arterial', 9);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('acv', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('problemas_corazon', 5);
INSERT INTO Tipo_Medicion (nombre, id_unidad) VALUES ('salud general', 9);

-- =====================================
-- INSERTAR MEDICAMENTOS
-- =====================================
INSERT INTO Medicamento (nombre) VALUES ('Ninguna');
INSERT INTO Medicamento (nombre) VALUES ('Otro');
INSERT INTO Medicamento (nombre) VALUES ('Beta Blocker');
INSERT INTO Medicamento (nombre) VALUES ('Diurético');
INSERT INTO Medicamento (nombre) VALUES ('ACE Inhibitor');

-- =====================================
-- INSERTAR PREGUNTAS
-- =====================================
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Consume frutas diariamente?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Consume verduras diariamente?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Cuánta sal consumes diariamente (en gramos)?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Fuma actualmente?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Consume alcohol en exceso?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Tiene dificultades para caminar o desplazarse sin ayuda?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Cuántas horas duermes cada día en promedio?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Nivel de estrés actual (0–10)');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Número de días en los últimos 30 en que la salud mental fue mala');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (8, 'Cuál es tu nivel de actividad física?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (6, 'Realiza actividad física al menos 3 veces por semana?');
INSERT INTO Pregunta (id_unidad, pregunta) VALUES (7, 'Número de días en los últimos 30 en que la salud física fue mala');
-- =====================================
-- INSERTAR RELACIONES DOCUMENTO-ENFERMEDAD
-- =====================================
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (1, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (2, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (3, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (3, 2);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (4, 1);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (4, 2);
INSERT INTO Documento_Enfermedad (id_documento, id_enfermedad) VALUES (5, 2);

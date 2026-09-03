-- ============================================================
-- SIRA - Sistema de Información y Registro Académico
-- Script actualizado según MER_SIRA_2_ACTUALIZACION.drawio
-- Supuestos aplicados:
--   - Se mantienen Competencia y Resultado_Aprendizaje (no
--     aparecen en el nuevo diagrama, pero tampoco se contradicen)
--   - Repositorio: Enfoque A -> tabla única con FKs nulas a
--     Actividad y Entrega + CHECK de exclusividad
--   - Datos de ejemplo: 20 instructores + 20 fichas x 20
--     aprendices por ficha = 420 usuarios en total
-- ============================================================

CREATE DATABASE sira;
USE sira;

-- ------------------------------------------------------------
-- 1. USUARIO (superentidad)
-- ------------------------------------------------------------
CREATE TABLE Usuario (
    id_usuario     INT PRIMARY KEY AUTO_INCREMENT,
    num_documento  VARCHAR(20) UNIQUE NOT NULL,
    nombres        VARCHAR(100) NOT NULL,
    apellidos      VARCHAR(100) NOT NULL,
    email          VARCHAR(100) UNIQUE NOT NULL,
    
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 2. Especialización Instructor / Aprendiz (ISA)
-- ------------------------------------------------------------
CREATE TABLE Instructor (
    id_instructor    INT PRIMARY KEY,
    acred_lic        VARCHAR(50),
    telefono_celular VARCHAR(20),
    telefono_fijo    VARCHAR(20),
    FOREIGN KEY (id_instructor) REFERENCES Usuario(id_usuario)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 3. Programa de Formación y Ficha
-- ------------------------------------------------------------
CREATE TABLE Programa_Formacion (
    id_programa     INT PRIMARY KEY AUTO_INCREMENT,
    nombre_programa VARCHAR(150) NOT NULL
);

CREATE TABLE Ficha (
    id_ficha      INT PRIMARY KEY AUTO_INCREMENT,
    numero_ficha  VARCHAR(20) UNIQUE NOT NULL,
    jornada       VARCHAR(30) NOT NULL,
    fecha_inicio  DATE,
    fecha_fin     DATE,
    id_programa   INT NOT NULL,
    id_instructor INT NOT NULL,              -- instructor líder de la ficha
    FOREIGN KEY (id_programa) REFERENCES Programa_Formacion(id_programa),
    FOREIGN KEY (id_instructor) REFERENCES Instructor(id_instructor)
);

CREATE TABLE Aprendiz (
    id_aprendiz INT PRIMARY KEY,
    id_ficha    INT NOT NULL,
    celular     VARCHAR(20),
    FOREIGN KEY (id_aprendiz) REFERENCES Usuario(id_usuario)
        ON DELETE CASCADE,
    FOREIGN KEY (id_ficha) REFERENCES Ficha(id_ficha)
);

-- ------------------------------------------------------------
-- 4. Competencias y Resultados de Aprendizaje
-- ------------------------------------------------------------
CREATE TABLE Competencia (
    id_competencia     INT PRIMARY KEY AUTO_INCREMENT,
    nombre_competencia VARCHAR(150) NOT NULL,
    duracion_horas     INT
);

CREATE TABLE Resultado_Aprendizaje (
    id_resultado    INT PRIMARY KEY AUTO_INCREMENT,
    descripcion     TEXT NOT NULL,
    duracion_horas  INT,
    id_competencia  INT NOT NULL,
    FOREIGN KEY (id_competencia) REFERENCES Competencia(id_competencia)
);

-- ------------------------------------------------------------
-- 5. Actividad, Entrega y Retroalimentación
-- ------------------------------------------------------------
CREATE TABLE Actividad (
    id_actividad      INT PRIMARY KEY AUTO_INCREMENT,
    titulo            VARCHAR(150) NOT NULL,
    descripcion       TEXT,
    fecha_vencimiento DATETIME NOT NULL,
    tipo_actividad    VARCHAR(50),
    id_instructor     INT NOT NULL,
    id_ficha          INT NOT NULL,
    id_resultado      INT,
    FOREIGN KEY (id_instructor) REFERENCES Instructor(id_instructor),
    FOREIGN KEY (id_ficha) REFERENCES Ficha(id_ficha),
    FOREIGN KEY (id_resultado) REFERENCES Resultado_Aprendizaje(id_resultado)
);

CREATE TABLE Entrega (
    id_entrega    INT PRIMARY KEY AUTO_INCREMENT,
    id_actividad  INT NOT NULL,
    id_aprendiz   INT NOT NULL,
    fecha_entrega DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado        ENUM('ENVIADO', 'EVALUADO', 'CORREGIR') DEFAULT 'ENVIADO',
    FOREIGN KEY (id_actividad) REFERENCES Actividad(id_actividad),
    FOREIGN KEY (id_aprendiz) REFERENCES Aprendiz(id_aprendiz)
);

CREATE TABLE Retroalimentacion (
    id_retroalimentacion INT PRIMARY KEY AUTO_INCREMENT,
    id_entrega           INT UNIQUE NOT NULL,
    id_instructor        INT NOT NULL,
    nota                  DECIMAL(4,2) NOT NULL,
    descripcion           TEXT,
    fecha_calificacion    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_entrega) REFERENCES Entrega(id_entrega),
    FOREIGN KEY (id_instructor) REFERENCES Instructor(id_instructor)
);

-- ------------------------------------------------------------
-- 6. Comentario (hilo de mensajes sobre una retroalimentación)
-- ------------------------------------------------------------
CREATE TABLE Comentario (
    id_comentario         INT PRIMARY KEY AUTO_INCREMENT,
    id_retroalimentacion  INT NOT NULL,
    id_usuario            INT NOT NULL,     -- instructor o aprendiz
    texto_comentario      TEXT NOT NULL,
    fecha_comentario      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_retroalimentacion) REFERENCES Retroalimentacion(id_retroalimentacion),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- ------------------------------------------------------------
-- 7. Repositorio (archivos de Actividad O de Entrega)
--    Enfoque A: tabla única + CHECK de exclusividad
-- ------------------------------------------------------------
CREATE TABLE Repositorio (
    id_repositorio  INT PRIMARY KEY AUTO_INCREMENT,
    nombre_archivo  VARCHAR(150) NOT NULL,
    tipo_formato    VARCHAR(20),
    url_ubicacion   VARCHAR(255) NOT NULL,
    fecha_subida    DATETIME DEFAULT CURRENT_TIMESTAMP,
    tamanio         INT,                    -- tamaño en KB
    id_instructor   INT NULL,               -- quien sube el material (si aplica)
    id_actividad    INT NULL,               -- material de una actividad
    id_entrega      INT NULL UNIQUE,        -- archivo vinculado a una entrega
    FOREIGN KEY (id_instructor) REFERENCES Instructor(id_instructor),
    FOREIGN KEY (id_actividad) REFERENCES Actividad(id_actividad),
    FOREIGN KEY (id_entrega) REFERENCES Entrega(id_entrega),
    CONSTRAINT chk_repositorio_destino CHECK (
        (id_actividad IS NOT NULL AND id_entrega IS NULL) OR
        (id_actividad IS NULL AND id_entrega IS NOT NULL)
    )
);

-- ------------------------------------------------------------
-- 8. Notificación
-- ------------------------------------------------------------
CREATE TABLE Notificacion (
    id_notificacion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario      INT NOT NULL,
    mensaje         TEXT NOT NULL,
    tipo            VARCHAR(30),
    leida           BOOLEAN DEFAULT FALSE,
    fecha_envio     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- ------------------------------------------------------------
-- 1. USUARIO (1-20 instructores, 21-420 aprendices)
-- ------------------------------------------------------------
INSERT INTO Usuario (num_documento, nombres, apellidos, email, fecha_registro) VALUES
('20000001','Maria','Gomez','maria.gomez1@sena.edu.co','2025-03-01'),
('20000002','Pedro','Romero','pedro.romero2@sena.edu.co','2025-03-01'),
('20000003','Sofia','Castillo','sofia.castillo3@sena.edu.co','2025-03-01'),
('20000004','Diego','Pinzon','diego.pinzon4@sena.edu.co','2025-03-01'),
('20000005','Valeria','Mejia','valeria.mejia5@sena.edu.co','2025-03-01'),
('20000006','Santiago','Fernandez','santiago.fernandez6@sena.edu.co','2025-03-01'),
('20000007','Isabella','Reyes','isabella.reyes7@sena.edu.co','2025-03-01'),
('20000008','Mateo','Rojas','mateo.rojas8@sena.edu.co','2025-03-01'),
('20000009','Camila','Nino','camila.nino9@sena.edu.co','2025-03-01'),
('200000010','Nicolas','Guerrero','nicolas.guerrero10@sena.edu.co','2025-03-01'),
('200000011','Luciana','Zapata','luciana.zapata11@sena.edu.co','2025-03-01'),
('200000012','Samuel','Martinez','samuel.martinez12@sena.edu.co','2025-03-01'),
('200000013','Gabriela','Jimenez','gabriela.jimenez13@sena.edu.co','2025-03-01'),
('200000014','Emilio','Ortega','emilio.ortega14@sena.edu.co','2025-03-01'),
('200000015','Daniela','Cardenas','daniela.cardenas15@sena.edu.co','2025-03-01'),
('200000016','Tomas','Rincon','tomas.rincon16@sena.edu.co','2025-03-01'),
('200000017','Antonia','Cifuentes','antonia.cifuentes17@sena.edu.co','2025-03-01'),
('200000018','Alejandro','Perez','alejandro.perez18@sena.edu.co','2025-03-01'),
('200000019','Renata','Alvarez','renata.alvarez19@sena.edu.co','2025-03-01'),
('200000020','Sebastian','Vargas','sebastian.vargas20@sena.edu.co','2025-03-01'),
('200000021','Maria','Gomez','maria.gomez21@sena.edu.co','2025-03-01'),
('200000022','Pedro','Romero','pedro.romero22@sena.edu.co','2025-03-01'),
('200000023','Sofia','Castillo','sofia.castillo23@sena.edu.co','2025-03-01'),
('200000024','Diego','Pinzon','diego.pinzon24@sena.edu.co','2025-03-01'),
('200000025','Valeria','Mejia','valeria.mejia25@sena.edu.co','2025-03-01'),
('200000026','Santiago','Fernandez','santiago.fernandez26@sena.edu.co','2025-03-01'),
('200000027','Isabella','Reyes','isabella.reyes27@sena.edu.co','2025-03-01'),
('200000028','Mateo','Rojas','mateo.rojas28@sena.edu.co','2025-03-01'),
('200000029','Camila','Nino','camila.nino29@sena.edu.co','2025-03-01'),
('200000030','Nicolas','Guerrero','nicolas.guerrero30@sena.edu.co','2025-03-01'),
('200000031','Luciana','Zapata','luciana.zapata31@sena.edu.co','2025-03-01'),
('200000032','Samuel','Martinez','samuel.martinez32@sena.edu.co','2025-03-01'),
('200000033','Gabriela','Jimenez','gabriela.jimenez33@sena.edu.co','2025-03-01'),
('200000034','Emilio','Ortega','emilio.ortega34@sena.edu.co','2025-03-01'),
('200000035','Daniela','Cardenas','daniela.cardenas35@sena.edu.co','2025-03-01'),
('200000036','Tomas','Rincon','tomas.rincon36@sena.edu.co','2025-03-01'),
('200000037','Antonia','Cifuentes','antonia.cifuentes37@sena.edu.co','2025-03-01'),
('200000038','Alejandro','Perez','alejandro.perez38@sena.edu.co','2025-03-01'),
('200000039','Renata','Alvarez','renata.alvarez39@sena.edu.co','2025-03-01'),
('200000040','Sebastian','Vargas','sebastian.vargas40@sena.edu.co','2025-03-01'),
('200000041','Maria','Gomez','maria.gomez41@sena.edu.co','2025-03-01'),
('200000042','Pedro','Romero','pedro.romero42@sena.edu.co','2025-03-01'),
('200000043','Sofia','Castillo','sofia.castillo43@sena.edu.co','2025-03-01'),
('200000044','Diego','Pinzon','diego.pinzon44@sena.edu.co','2025-03-01'),
('200000045','Valeria','Mejia','valeria.mejia45@sena.edu.co','2025-03-01'),
('200000046','Santiago','Fernandez','santiago.fernandez46@sena.edu.co','2025-03-01'),
('200000047','Isabella','Reyes','isabella.reyes47@sena.edu.co','2025-03-01'),
('200000048','Mateo','Rojas','mateo.rojas48@sena.edu.co','2025-03-01'),
('200000049','Camila','Nino','camila.nino49@sena.edu.co','2025-03-01'),
('200000050','Nicolas','Guerrero','nicolas.guerrero50@sena.edu.co','2025-03-01'),
('200000051','Luciana','Zapata','luciana.zapata51@sena.edu.co','2025-03-01'),
('200000052','Samuel','Martinez','samuel.martinez52@sena.edu.co','2025-03-01'),
('200000053','Gabriela','Jimenez','gabriela.jimenez53@sena.edu.co','2025-03-01'),
('200000054','Emilio','Ortega','emilio.ortega54@sena.edu.co','2025-03-01'),
('200000055','Daniela','Cardenas','daniela.cardenas55@sena.edu.co','2025-03-01'),
('200000056','Tomas','Rincon','tomas.rincon56@sena.edu.co','2025-03-01'),
('200000057','Antonia','Cifuentes','antonia.cifuentes57@sena.edu.co','2025-03-01'),
('200000058','Alejandro','Perez','alejandro.perez58@sena.edu.co','2025-03-01'),
('200000059','Renata','Alvarez','renata.alvarez59@sena.edu.co','2025-03-01'),
('200000060','Sebastian','Vargas','sebastian.vargas60@sena.edu.co','2025-03-01'),
('200000061','Maria','Gomez','maria.gomez61@sena.edu.co','2025-03-01'),
('200000062','Pedro','Romero','pedro.romero62@sena.edu.co','2025-03-01'),
('200000063','Sofia','Castillo','sofia.castillo63@sena.edu.co','2025-03-01'),
('200000064','Diego','Pinzon','diego.pinzon64@sena.edu.co','2025-03-01'),
('200000065','Valeria','Mejia','valeria.mejia65@sena.edu.co','2025-03-01'),
('200000066','Santiago','Fernandez','santiago.fernandez66@sena.edu.co','2025-03-01'),
('200000067','Isabella','Reyes','isabella.reyes67@sena.edu.co','2025-03-01'),
('200000068','Mateo','Rojas','mateo.rojas68@sena.edu.co','2025-03-01'),
('200000069','Camila','Nino','camila.nino69@sena.edu.co','2025-03-01'),
('200000070','Nicolas','Guerrero','nicolas.guerrero70@sena.edu.co','2025-03-01'),
('200000071','Luciana','Zapata','luciana.zapata71@sena.edu.co','2025-03-01'),
('200000072','Samuel','Martinez','samuel.martinez72@sena.edu.co','2025-03-01'),
('200000073','Gabriela','Jimenez','gabriela.jimenez73@sena.edu.co','2025-03-01'),
('200000074','Emilio','Ortega','emilio.ortega74@sena.edu.co','2025-03-01'),
('200000075','Daniela','Cardenas','daniela.cardenas75@sena.edu.co','2025-03-01'),
('200000076','Tomas','Rincon','tomas.rincon76@sena.edu.co','2025-03-01'),
('200000077','Antonia','Cifuentes','antonia.cifuentes77@sena.edu.co','2025-03-01'),
('200000078','Alejandro','Perez','alejandro.perez78@sena.edu.co','2025-03-01'),
('200000079','Renata','Alvarez','renata.alvarez79@sena.edu.co','2025-03-01'),
('200000080','Sebastian','Vargas','sebastian.vargas80@sena.edu.co','2025-03-01'),
('200000081','Maria','Gomez','maria.gomez81@sena.edu.co','2025-03-01'),
('200000082','Pedro','Romero','pedro.romero82@sena.edu.co','2025-03-01'),
('200000083','Sofia','Castillo','sofia.castillo83@sena.edu.co','2025-03-01'),
('200000084','Diego','Pinzon','diego.pinzon84@sena.edu.co','2025-03-01'),
('200000085','Valeria','Mejia','valeria.mejia85@sena.edu.co','2025-03-01'),
('200000086','Santiago','Fernandez','santiago.fernandez86@sena.edu.co','2025-03-01'),
('200000087','Isabella','Reyes','isabella.reyes87@sena.edu.co','2025-03-01'),
('200000088','Mateo','Rojas','mateo.rojas88@sena.edu.co','2025-03-01'),
('200000089','Camila','Nino','camila.nino89@sena.edu.co','2025-03-01'),
('200000090','Nicolas','Guerrero','nicolas.guerrero90@sena.edu.co','2025-03-01'),
('200000091','Luciana','Zapata','luciana.zapata91@sena.edu.co','2025-03-01'),
('200000092','Samuel','Martinez','samuel.martinez92@sena.edu.co','2025-03-01'),
('200000093','Gabriela','Jimenez','gabriela.jimenez93@sena.edu.co','2025-03-01'),
('200000094','Emilio','Ortega','emilio.ortega94@sena.edu.co','2025-03-01'),
('200000095','Daniela','Cardenas','daniela.cardenas95@sena.edu.co','2025-03-01'),
('200000096','Tomas','Rincon','tomas.rincon96@sena.edu.co','2025-03-01'),
('200000097','Antonia','Cifuentes','antonia.cifuentes97@sena.edu.co','2025-03-01'),
('200000098','Alejandro','Perez','alejandro.perez98@sena.edu.co','2025-03-01'),
('200000099','Renata','Alvarez','renata.alvarez99@sena.edu.co','2025-03-01'),
('2000000100','Sebastian','Vargas','sebastian.vargas100@sena.edu.co','2025-03-01'),
('2000000101','Maria','Gomez','maria.gomez101@sena.edu.co','2025-03-01'),
('2000000102','Pedro','Romero','pedro.romero102@sena.edu.co','2025-03-01'),
('2000000103','Sofia','Castillo','sofia.castillo103@sena.edu.co','2025-03-01'),
('2000000104','Diego','Pinzon','diego.pinzon104@sena.edu.co','2025-03-01'),
('2000000105','Valeria','Mejia','valeria.mejia105@sena.edu.co','2025-03-01'),
('2000000106','Santiago','Fernandez','santiago.fernandez106@sena.edu.co','2025-03-01'),
('2000000107','Isabella','Reyes','isabella.reyes107@sena.edu.co','2025-03-01'),
('2000000108','Mateo','Rojas','mateo.rojas108@sena.edu.co','2025-03-01'),
('2000000109','Camila','Nino','camila.nino109@sena.edu.co','2025-03-01'),
('2000000110','Nicolas','Guerrero','nicolas.guerrero110@sena.edu.co','2025-03-01'),
('2000000111','Luciana','Zapata','luciana.zapata111@sena.edu.co','2025-03-01'),
('2000000112','Samuel','Martinez','samuel.martinez112@sena.edu.co','2025-03-01'),
('2000000113','Gabriela','Jimenez','gabriela.jimenez113@sena.edu.co','2025-03-01'),
('2000000114','Emilio','Ortega','emilio.ortega114@sena.edu.co','2025-03-01'),
('2000000115','Daniela','Cardenas','daniela.cardenas115@sena.edu.co','2025-03-01'),
('2000000116','Tomas','Rincon','tomas.rincon116@sena.edu.co','2025-03-01'),
('2000000117','Antonia','Cifuentes','antonia.cifuentes117@sena.edu.co','2025-03-01'),
('2000000118','Alejandro','Perez','alejandro.perez118@sena.edu.co','2025-03-01'),
('2000000119','Renata','Alvarez','renata.alvarez119@sena.edu.co','2025-03-01'),
('2000000120','Sebastian','Vargas','sebastian.vargas120@sena.edu.co','2025-03-01'),
('2000000121','Maria','Gomez','maria.gomez121@sena.edu.co','2025-03-01'),
('2000000122','Pedro','Romero','pedro.romero122@sena.edu.co','2025-03-01'),
('2000000123','Sofia','Castillo','sofia.castillo123@sena.edu.co','2025-03-01'),
('2000000124','Diego','Pinzon','diego.pinzon124@sena.edu.co','2025-03-01'),
('2000000125','Valeria','Mejia','valeria.mejia125@sena.edu.co','2025-03-01'),
('2000000126','Santiago','Fernandez','santiago.fernandez126@sena.edu.co','2025-03-01'),
('2000000127','Isabella','Reyes','isabella.reyes127@sena.edu.co','2025-03-01'),
('2000000128','Mateo','Rojas','mateo.rojas128@sena.edu.co','2025-03-01'),
('2000000129','Camila','Nino','camila.nino129@sena.edu.co','2025-03-01'),
('2000000130','Nicolas','Guerrero','nicolas.guerrero130@sena.edu.co','2025-03-01'),
('2000000131','Luciana','Zapata','luciana.zapata131@sena.edu.co','2025-03-01'),
('2000000132','Samuel','Martinez','samuel.martinez132@sena.edu.co','2025-03-01'),
('2000000133','Gabriela','Jimenez','gabriela.jimenez133@sena.edu.co','2025-03-01'),
('2000000134','Emilio','Ortega','emilio.ortega134@sena.edu.co','2025-03-01'),
('2000000135','Daniela','Cardenas','daniela.cardenas135@sena.edu.co','2025-03-01'),
('2000000136','Tomas','Rincon','tomas.rincon136@sena.edu.co','2025-03-01'),
('2000000137','Antonia','Cifuentes','antonia.cifuentes137@sena.edu.co','2025-03-01'),
('2000000138','Alejandro','Perez','alejandro.perez138@sena.edu.co','2025-03-01'),
('2000000139','Renata','Alvarez','renata.alvarez139@sena.edu.co','2025-03-01'),
('2000000140','Sebastian','Vargas','sebastian.vargas140@sena.edu.co','2025-03-01'),
('2000000141','Maria','Gomez','maria.gomez141@sena.edu.co','2025-03-01'),
('2000000142','Pedro','Romero','pedro.romero142@sena.edu.co','2025-03-01'),
('2000000143','Sofia','Castillo','sofia.castillo143@sena.edu.co','2025-03-01'),
('2000000144','Diego','Pinzon','diego.pinzon144@sena.edu.co','2025-03-01'),
('2000000145','Valeria','Mejia','valeria.mejia145@sena.edu.co','2025-03-01'),
('2000000146','Santiago','Fernandez','santiago.fernandez146@sena.edu.co','2025-03-01'),
('2000000147','Isabella','Reyes','isabella.reyes147@sena.edu.co','2025-03-01'),
('2000000148','Mateo','Rojas','mateo.rojas148@sena.edu.co','2025-03-01'),
('2000000149','Camila','Nino','camila.nino149@sena.edu.co','2025-03-01'),
('2000000150','Nicolas','Guerrero','nicolas.guerrero150@sena.edu.co','2025-03-01'),
('2000000151','Luciana','Zapata','luciana.zapata151@sena.edu.co','2025-03-01'),
('2000000152','Samuel','Martinez','samuel.martinez152@sena.edu.co','2025-03-01'),
('2000000153','Gabriela','Jimenez','gabriela.jimenez153@sena.edu.co','2025-03-01'),
('2000000154','Emilio','Ortega','emilio.ortega154@sena.edu.co','2025-03-01'),
('2000000155','Daniela','Cardenas','daniela.cardenas155@sena.edu.co','2025-03-01'),
('2000000156','Tomas','Rincon','tomas.rincon156@sena.edu.co','2025-03-01'),
('2000000157','Antonia','Cifuentes','antonia.cifuentes157@sena.edu.co','2025-03-01'),
('2000000158','Alejandro','Perez','alejandro.perez158@sena.edu.co','2025-03-01'),
('2000000159','Renata','Alvarez','renata.alvarez159@sena.edu.co','2025-03-01'),
('2000000160','Sebastian','Vargas','sebastian.vargas160@sena.edu.co','2025-03-01'),
('2000000161','Maria','Gomez','maria.gomez161@sena.edu.co','2025-03-01'),
('2000000162','Pedro','Romero','pedro.romero162@sena.edu.co','2025-03-01'),
('2000000163','Sofia','Castillo','sofia.castillo163@sena.edu.co','2025-03-01'),
('2000000164','Diego','Pinzon','diego.pinzon164@sena.edu.co','2025-03-01'),
('2000000165','Valeria','Mejia','valeria.mejia165@sena.edu.co','2025-03-01'),
('2000000166','Santiago','Fernandez','santiago.fernandez166@sena.edu.co','2025-03-01'),
('2000000167','Isabella','Reyes','isabella.reyes167@sena.edu.co','2025-03-01'),
('2000000168','Mateo','Rojas','mateo.rojas168@sena.edu.co','2025-03-01'),
('2000000169','Camila','Nino','camila.nino169@sena.edu.co','2025-03-01'),
('2000000170','Nicolas','Guerrero','nicolas.guerrero170@sena.edu.co','2025-03-01'),
('2000000171','Luciana','Zapata','luciana.zapata171@sena.edu.co','2025-03-01'),
('2000000172','Samuel','Martinez','samuel.martinez172@sena.edu.co','2025-03-01'),
('2000000173','Gabriela','Jimenez','gabriela.jimenez173@sena.edu.co','2025-03-01'),
('2000000174','Emilio','Ortega','emilio.ortega174@sena.edu.co','2025-03-01'),
('2000000175','Daniela','Cardenas','daniela.cardenas175@sena.edu.co','2025-03-01'),
('2000000176','Tomas','Rincon','tomas.rincon176@sena.edu.co','2025-03-01'),
('2000000177','Antonia','Cifuentes','antonia.cifuentes177@sena.edu.co','2025-03-01'),
('2000000178','Alejandro','Perez','alejandro.perez178@sena.edu.co','2025-03-01'),
('2000000179','Renata','Alvarez','renata.alvarez179@sena.edu.co','2025-03-01'),
('2000000180','Sebastian','Vargas','sebastian.vargas180@sena.edu.co','2025-03-01'),
('2000000181','Maria','Gomez','maria.gomez181@sena.edu.co','2025-03-01'),
('2000000182','Pedro','Romero','pedro.romero182@sena.edu.co','2025-03-01'),
('2000000183','Sofia','Castillo','sofia.castillo183@sena.edu.co','2025-03-01'),
('2000000184','Diego','Pinzon','diego.pinzon184@sena.edu.co','2025-03-01'),
('2000000185','Valeria','Mejia','valeria.mejia185@sena.edu.co','2025-03-01'),
('2000000186','Santiago','Fernandez','santiago.fernandez186@sena.edu.co','2025-03-01'),
('2000000187','Isabella','Reyes','isabella.reyes187@sena.edu.co','2025-03-01'),
('2000000188','Mateo','Rojas','mateo.rojas188@sena.edu.co','2025-03-01'),
('2000000189','Camila','Nino','camila.nino189@sena.edu.co','2025-03-01'),
('2000000190','Nicolas','Guerrero','nicolas.guerrero190@sena.edu.co','2025-03-01'),
('2000000191','Luciana','Zapata','luciana.zapata191@sena.edu.co','2025-03-01'),
('2000000192','Samuel','Martinez','samuel.martinez192@sena.edu.co','2025-03-01'),
('2000000193','Gabriela','Jimenez','gabriela.jimenez193@sena.edu.co','2025-03-01'),
('2000000194','Emilio','Ortega','emilio.ortega194@sena.edu.co','2025-03-01'),
('2000000195','Daniela','Cardenas','daniela.cardenas195@sena.edu.co','2025-03-01'),
('2000000196','Tomas','Rincon','tomas.rincon196@sena.edu.co','2025-03-01'),
('2000000197','Antonia','Cifuentes','antonia.cifuentes197@sena.edu.co','2025-03-01'),
('2000000198','Alejandro','Perez','alejandro.perez198@sena.edu.co','2025-03-01'),
('2000000199','Renata','Alvarez','renata.alvarez199@sena.edu.co','2025-03-01'),
('2000000200','Sebastian','Vargas','sebastian.vargas200@sena.edu.co','2025-03-01'),
('2000000201','Maria','Gomez','maria.gomez201@sena.edu.co','2025-03-01'),
('2000000202','Pedro','Romero','pedro.romero202@sena.edu.co','2025-03-01'),
('2000000203','Sofia','Castillo','sofia.castillo203@sena.edu.co','2025-03-01'),
('2000000204','Diego','Pinzon','diego.pinzon204@sena.edu.co','2025-03-01'),
('2000000205','Valeria','Mejia','valeria.mejia205@sena.edu.co','2025-03-01'),
('2000000206','Santiago','Fernandez','santiago.fernandez206@sena.edu.co','2025-03-01'),
('2000000207','Isabella','Reyes','isabella.reyes207@sena.edu.co','2025-03-01'),
('2000000208','Mateo','Rojas','mateo.rojas208@sena.edu.co','2025-03-01'),
('2000000209','Camila','Nino','camila.nino209@sena.edu.co','2025-03-01'),
('2000000210','Nicolas','Guerrero','nicolas.guerrero210@sena.edu.co','2025-03-01'),
('2000000211','Luciana','Zapata','luciana.zapata211@sena.edu.co','2025-03-01'),
('2000000212','Samuel','Martinez','samuel.martinez212@sena.edu.co','2025-03-01'),
('2000000213','Gabriela','Jimenez','gabriela.jimenez213@sena.edu.co','2025-03-01'),
('2000000214','Emilio','Ortega','emilio.ortega214@sena.edu.co','2025-03-01'),
('2000000215','Daniela','Cardenas','daniela.cardenas215@sena.edu.co','2025-03-01'),
('2000000216','Tomas','Rincon','tomas.rincon216@sena.edu.co','2025-03-01'),
('2000000217','Antonia','Cifuentes','antonia.cifuentes217@sena.edu.co','2025-03-01'),
('2000000218','Alejandro','Perez','alejandro.perez218@sena.edu.co','2025-03-01'),
('2000000219','Renata','Alvarez','renata.alvarez219@sena.edu.co','2025-03-01'),
('2000000220','Sebastian','Vargas','sebastian.vargas220@sena.edu.co','2025-03-01'),
('2000000221','Maria','Gomez','maria.gomez221@sena.edu.co','2025-03-01'),
('2000000222','Pedro','Romero','pedro.romero222@sena.edu.co','2025-03-01'),
('2000000223','Sofia','Castillo','sofia.castillo223@sena.edu.co','2025-03-01'),
('2000000224','Diego','Pinzon','diego.pinzon224@sena.edu.co','2025-03-01'),
('2000000225','Valeria','Mejia','valeria.mejia225@sena.edu.co','2025-03-01'),
('2000000226','Santiago','Fernandez','santiago.fernandez226@sena.edu.co','2025-03-01'),
('2000000227','Isabella','Reyes','isabella.reyes227@sena.edu.co','2025-03-01'),
('2000000228','Mateo','Rojas','mateo.rojas228@sena.edu.co','2025-03-01'),
('2000000229','Camila','Nino','camila.nino229@sena.edu.co','2025-03-01'),
('2000000230','Nicolas','Guerrero','nicolas.guerrero230@sena.edu.co','2025-03-01'),
('2000000231','Luciana','Zapata','luciana.zapata231@sena.edu.co','2025-03-01'),
('2000000232','Samuel','Martinez','samuel.martinez232@sena.edu.co','2025-03-01'),
('2000000233','Gabriela','Jimenez','gabriela.jimenez233@sena.edu.co','2025-03-01'),
('2000000234','Emilio','Ortega','emilio.ortega234@sena.edu.co','2025-03-01'),
('2000000235','Daniela','Cardenas','daniela.cardenas235@sena.edu.co','2025-03-01'),
('2000000236','Tomas','Rincon','tomas.rincon236@sena.edu.co','2025-03-01'),
('2000000237','Antonia','Cifuentes','antonia.cifuentes237@sena.edu.co','2025-03-01'),
('2000000238','Alejandro','Perez','alejandro.perez238@sena.edu.co','2025-03-01'),
('2000000239','Renata','Alvarez','renata.alvarez239@sena.edu.co','2025-03-01'),
('2000000240','Sebastian','Vargas','sebastian.vargas240@sena.edu.co','2025-03-01'),
('2000000241','Maria','Gomez','maria.gomez241@sena.edu.co','2025-03-01'),
('2000000242','Pedro','Romero','pedro.romero242@sena.edu.co','2025-03-01'),
('2000000243','Sofia','Castillo','sofia.castillo243@sena.edu.co','2025-03-01'),
('2000000244','Diego','Pinzon','diego.pinzon244@sena.edu.co','2025-03-01'),
('2000000245','Valeria','Mejia','valeria.mejia245@sena.edu.co','2025-03-01'),
('2000000246','Santiago','Fernandez','santiago.fernandez246@sena.edu.co','2025-03-01'),
('2000000247','Isabella','Reyes','isabella.reyes247@sena.edu.co','2025-03-01'),
('2000000248','Mateo','Rojas','mateo.rojas248@sena.edu.co','2025-03-01'),
('2000000249','Camila','Nino','camila.nino249@sena.edu.co','2025-03-01'),
('2000000250','Nicolas','Guerrero','nicolas.guerrero250@sena.edu.co','2025-03-01'),
('2000000251','Luciana','Zapata','luciana.zapata251@sena.edu.co','2025-03-01'),
('2000000252','Samuel','Martinez','samuel.martinez252@sena.edu.co','2025-03-01'),
('2000000253','Gabriela','Jimenez','gabriela.jimenez253@sena.edu.co','2025-03-01'),
('2000000254','Emilio','Ortega','emilio.ortega254@sena.edu.co','2025-03-01'),
('2000000255','Daniela','Cardenas','daniela.cardenas255@sena.edu.co','2025-03-01'),
('2000000256','Tomas','Rincon','tomas.rincon256@sena.edu.co','2025-03-01'),
('2000000257','Antonia','Cifuentes','antonia.cifuentes257@sena.edu.co','2025-03-01'),
('2000000258','Alejandro','Perez','alejandro.perez258@sena.edu.co','2025-03-01'),
('2000000259','Renata','Alvarez','renata.alvarez259@sena.edu.co','2025-03-01'),
('2000000260','Sebastian','Vargas','sebastian.vargas260@sena.edu.co','2025-03-01'),
('2000000261','Maria','Gomez','maria.gomez261@sena.edu.co','2025-03-01'),
('2000000262','Pedro','Romero','pedro.romero262@sena.edu.co','2025-03-01'),
('2000000263','Sofia','Castillo','sofia.castillo263@sena.edu.co','2025-03-01'),
('2000000264','Diego','Pinzon','diego.pinzon264@sena.edu.co','2025-03-01'),
('2000000265','Valeria','Mejia','valeria.mejia265@sena.edu.co','2025-03-01'),
('2000000266','Santiago','Fernandez','santiago.fernandez266@sena.edu.co','2025-03-01'),
('2000000267','Isabella','Reyes','isabella.reyes267@sena.edu.co','2025-03-01'),
('2000000268','Mateo','Rojas','mateo.rojas268@sena.edu.co','2025-03-01'),
('2000000269','Camila','Nino','camila.nino269@sena.edu.co','2025-03-01'),
('2000000270','Nicolas','Guerrero','nicolas.guerrero270@sena.edu.co','2025-03-01'),
('2000000271','Luciana','Zapata','luciana.zapata271@sena.edu.co','2025-03-01'),
('2000000272','Samuel','Martinez','samuel.martinez272@sena.edu.co','2025-03-01'),
('2000000273','Gabriela','Jimenez','gabriela.jimenez273@sena.edu.co','2025-03-01'),
('2000000274','Emilio','Ortega','emilio.ortega274@sena.edu.co','2025-03-01'),
('2000000275','Daniela','Cardenas','daniela.cardenas275@sena.edu.co','2025-03-01'),
('2000000276','Tomas','Rincon','tomas.rincon276@sena.edu.co','2025-03-01'),
('2000000277','Antonia','Cifuentes','antonia.cifuentes277@sena.edu.co','2025-03-01'),
('2000000278','Alejandro','Perez','alejandro.perez278@sena.edu.co','2025-03-01'),
('2000000279','Renata','Alvarez','renata.alvarez279@sena.edu.co','2025-03-01'),
('2000000280','Sebastian','Vargas','sebastian.vargas280@sena.edu.co','2025-03-01'),
('2000000281','Maria','Gomez','maria.gomez281@sena.edu.co','2025-03-01'),
('2000000282','Pedro','Romero','pedro.romero282@sena.edu.co','2025-03-01'),
('2000000283','Sofia','Castillo','sofia.castillo283@sena.edu.co','2025-03-01'),
('2000000284','Diego','Pinzon','diego.pinzon284@sena.edu.co','2025-03-01'),
('2000000285','Valeria','Mejia','valeria.mejia285@sena.edu.co','2025-03-01'),
('2000000286','Santiago','Fernandez','santiago.fernandez286@sena.edu.co','2025-03-01'),
('2000000287','Isabella','Reyes','isabella.reyes287@sena.edu.co','2025-03-01'),
('2000000288','Mateo','Rojas','mateo.rojas288@sena.edu.co','2025-03-01'),
('2000000289','Camila','Nino','camila.nino289@sena.edu.co','2025-03-01'),
('2000000290','Nicolas','Guerrero','nicolas.guerrero290@sena.edu.co','2025-03-01'),
('2000000291','Luciana','Zapata','luciana.zapata291@sena.edu.co','2025-03-01'),
('2000000292','Samuel','Martinez','samuel.martinez292@sena.edu.co','2025-03-01'),
('2000000293','Gabriela','Jimenez','gabriela.jimenez293@sena.edu.co','2025-03-01'),
('2000000294','Emilio','Ortega','emilio.ortega294@sena.edu.co','2025-03-01'),
('2000000295','Daniela','Cardenas','daniela.cardenas295@sena.edu.co','2025-03-01'),
('2000000296','Tomas','Rincon','tomas.rincon296@sena.edu.co','2025-03-01'),
('2000000297','Antonia','Cifuentes','antonia.cifuentes297@sena.edu.co','2025-03-01'),
('2000000298','Alejandro','Perez','alejandro.perez298@sena.edu.co','2025-03-01'),
('2000000299','Renata','Alvarez','renata.alvarez299@sena.edu.co','2025-03-01'),
('2000000300','Sebastian','Vargas','sebastian.vargas300@sena.edu.co','2025-03-01'),
('2000000301','Maria','Gomez','maria.gomez301@sena.edu.co','2025-03-01'),
('2000000302','Pedro','Romero','pedro.romero302@sena.edu.co','2025-03-01'),
('2000000303','Sofia','Castillo','sofia.castillo303@sena.edu.co','2025-03-01'),
('2000000304','Diego','Pinzon','diego.pinzon304@sena.edu.co','2025-03-01'),
('2000000305','Valeria','Mejia','valeria.mejia305@sena.edu.co','2025-03-01'),
('2000000306','Santiago','Fernandez','santiago.fernandez306@sena.edu.co','2025-03-01'),
('2000000307','Isabella','Reyes','isabella.reyes307@sena.edu.co','2025-03-01'),
('2000000308','Mateo','Rojas','mateo.rojas308@sena.edu.co','2025-03-01'),
('2000000309','Camila','Nino','camila.nino309@sena.edu.co','2025-03-01'),
('2000000310','Nicolas','Guerrero','nicolas.guerrero310@sena.edu.co','2025-03-01'),
('2000000311','Luciana','Zapata','luciana.zapata311@sena.edu.co','2025-03-01'),
('2000000312','Samuel','Martinez','samuel.martinez312@sena.edu.co','2025-03-01'),
('2000000313','Gabriela','Jimenez','gabriela.jimenez313@sena.edu.co','2025-03-01'),
('2000000314','Emilio','Ortega','emilio.ortega314@sena.edu.co','2025-03-01'),
('2000000315','Daniela','Cardenas','daniela.cardenas315@sena.edu.co','2025-03-01'),
('2000000316','Tomas','Rincon','tomas.rincon316@sena.edu.co','2025-03-01'),
('2000000317','Antonia','Cifuentes','antonia.cifuentes317@sena.edu.co','2025-03-01'),
('2000000318','Alejandro','Perez','alejandro.perez318@sena.edu.co','2025-03-01'),
('2000000319','Renata','Alvarez','renata.alvarez319@sena.edu.co','2025-03-01'),
('2000000320','Sebastian','Vargas','sebastian.vargas320@sena.edu.co','2025-03-01'),
('2000000321','Maria','Gomez','maria.gomez321@sena.edu.co','2025-03-01'),
('2000000322','Pedro','Romero','pedro.romero322@sena.edu.co','2025-03-01'),
('2000000323','Sofia','Castillo','sofia.castillo323@sena.edu.co','2025-03-01'),
('2000000324','Diego','Pinzon','diego.pinzon324@sena.edu.co','2025-03-01'),
('2000000325','Valeria','Mejia','valeria.mejia325@sena.edu.co','2025-03-01'),
('2000000326','Santiago','Fernandez','santiago.fernandez326@sena.edu.co','2025-03-01'),
('2000000327','Isabella','Reyes','isabella.reyes327@sena.edu.co','2025-03-01'),
('2000000328','Mateo','Rojas','mateo.rojas328@sena.edu.co','2025-03-01'),
('2000000329','Camila','Nino','camila.nino329@sena.edu.co','2025-03-01'),
('2000000330','Nicolas','Guerrero','nicolas.guerrero330@sena.edu.co','2025-03-01'),
('2000000331','Luciana','Zapata','luciana.zapata331@sena.edu.co','2025-03-01'),
('2000000332','Samuel','Martinez','samuel.martinez332@sena.edu.co','2025-03-01'),
('2000000333','Gabriela','Jimenez','gabriela.jimenez333@sena.edu.co','2025-03-01'),
('2000000334','Emilio','Ortega','emilio.ortega334@sena.edu.co','2025-03-01'),
('2000000335','Daniela','Cardenas','daniela.cardenas335@sena.edu.co','2025-03-01'),
('2000000336','Tomas','Rincon','tomas.rincon336@sena.edu.co','2025-03-01'),
('2000000337','Antonia','Cifuentes','antonia.cifuentes337@sena.edu.co','2025-03-01'),
('2000000338','Alejandro','Perez','alejandro.perez338@sena.edu.co','2025-03-01'),
('2000000339','Renata','Alvarez','renata.alvarez339@sena.edu.co','2025-03-01'),
('2000000340','Sebastian','Vargas','sebastian.vargas340@sena.edu.co','2025-03-01'),
('2000000341','Maria','Gomez','maria.gomez341@sena.edu.co','2025-03-01'),
('2000000342','Pedro','Romero','pedro.romero342@sena.edu.co','2025-03-01'),
('2000000343','Sofia','Castillo','sofia.castillo343@sena.edu.co','2025-03-01'),
('2000000344','Diego','Pinzon','diego.pinzon344@sena.edu.co','2025-03-01'),
('2000000345','Valeria','Mejia','valeria.mejia345@sena.edu.co','2025-03-01'),
('2000000346','Santiago','Fernandez','santiago.fernandez346@sena.edu.co','2025-03-01'),
('2000000347','Isabella','Reyes','isabella.reyes347@sena.edu.co','2025-03-01'),
('2000000348','Mateo','Rojas','mateo.rojas348@sena.edu.co','2025-03-01'),
('2000000349','Camila','Nino','camila.nino349@sena.edu.co','2025-03-01'),
('2000000350','Nicolas','Guerrero','nicolas.guerrero350@sena.edu.co','2025-03-01'),
('2000000351','Luciana','Zapata','luciana.zapata351@sena.edu.co','2025-03-01'),
('2000000352','Samuel','Martinez','samuel.martinez352@sena.edu.co','2025-03-01'),
('2000000353','Gabriela','Jimenez','gabriela.jimenez353@sena.edu.co','2025-03-01'),
('2000000354','Emilio','Ortega','emilio.ortega354@sena.edu.co','2025-03-01'),
('2000000355','Daniela','Cardenas','daniela.cardenas355@sena.edu.co','2025-03-01'),
('2000000356','Tomas','Rincon','tomas.rincon356@sena.edu.co','2025-03-01'),
('2000000357','Antonia','Cifuentes','antonia.cifuentes357@sena.edu.co','2025-03-01'),
('2000000358','Alejandro','Perez','alejandro.perez358@sena.edu.co','2025-03-01'),
('2000000359','Renata','Alvarez','renata.alvarez359@sena.edu.co','2025-03-01'),
('2000000360','Sebastian','Vargas','sebastian.vargas360@sena.edu.co','2025-03-01'),
('2000000361','Maria','Gomez','maria.gomez361@sena.edu.co','2025-03-01'),
('2000000362','Pedro','Romero','pedro.romero362@sena.edu.co','2025-03-01'),
('2000000363','Sofia','Castillo','sofia.castillo363@sena.edu.co','2025-03-01'),
('2000000364','Diego','Pinzon','diego.pinzon364@sena.edu.co','2025-03-01'),
('2000000365','Valeria','Mejia','valeria.mejia365@sena.edu.co','2025-03-01'),
('2000000366','Santiago','Fernandez','santiago.fernandez366@sena.edu.co','2025-03-01'),
('2000000367','Isabella','Reyes','isabella.reyes367@sena.edu.co','2025-03-01'),
('2000000368','Mateo','Rojas','mateo.rojas368@sena.edu.co','2025-03-01'),
('2000000369','Camila','Nino','camila.nino369@sena.edu.co','2025-03-01'),
('2000000370','Nicolas','Guerrero','nicolas.guerrero370@sena.edu.co','2025-03-01'),
('2000000371','Luciana','Zapata','luciana.zapata371@sena.edu.co','2025-03-01'),
('2000000372','Samuel','Martinez','samuel.martinez372@sena.edu.co','2025-03-01'),
('2000000373','Gabriela','Jimenez','gabriela.jimenez373@sena.edu.co','2025-03-01'),
('2000000374','Emilio','Ortega','emilio.ortega374@sena.edu.co','2025-03-01'),
('2000000375','Daniela','Cardenas','daniela.cardenas375@sena.edu.co','2025-03-01'),
('2000000376','Tomas','Rincon','tomas.rincon376@sena.edu.co','2025-03-01'),
('2000000377','Antonia','Cifuentes','antonia.cifuentes377@sena.edu.co','2025-03-01'),
('2000000378','Alejandro','Perez','alejandro.perez378@sena.edu.co','2025-03-01'),
('2000000379','Renata','Alvarez','renata.alvarez379@sena.edu.co','2025-03-01'),
('2000000380','Sebastian','Vargas','sebastian.vargas380@sena.edu.co','2025-03-01'),
('2000000381','Maria','Gomez','maria.gomez381@sena.edu.co','2025-03-01'),
('2000000382','Pedro','Romero','pedro.romero382@sena.edu.co','2025-03-01'),
('2000000383','Sofia','Castillo','sofia.castillo383@sena.edu.co','2025-03-01'),
('2000000384','Diego','Pinzon','diego.pinzon384@sena.edu.co','2025-03-01'),
('2000000385','Valeria','Mejia','valeria.mejia385@sena.edu.co','2025-03-01'),
('2000000386','Santiago','Fernandez','santiago.fernandez386@sena.edu.co','2025-03-01'),
('2000000387','Isabella','Reyes','isabella.reyes387@sena.edu.co','2025-03-01'),
('2000000388','Mateo','Rojas','mateo.rojas388@sena.edu.co','2025-03-01'),
('2000000389','Camila','Nino','camila.nino389@sena.edu.co','2025-03-01'),
('2000000390','Nicolas','Guerrero','nicolas.guerrero390@sena.edu.co','2025-03-01'),
('2000000391','Luciana','Zapata','luciana.zapata391@sena.edu.co','2025-03-01'),
('2000000392','Samuel','Martinez','samuel.martinez392@sena.edu.co','2025-03-01'),
('2000000393','Gabriela','Jimenez','gabriela.jimenez393@sena.edu.co','2025-03-01'),
('2000000394','Emilio','Ortega','emilio.ortega394@sena.edu.co','2025-03-01'),
('2000000395','Daniela','Cardenas','daniela.cardenas395@sena.edu.co','2025-03-01'),
('2000000396','Tomas','Rincon','tomas.rincon396@sena.edu.co','2025-03-01'),
('2000000397','Antonia','Cifuentes','antonia.cifuentes397@sena.edu.co','2025-03-01'),
('2000000398','Alejandro','Perez','alejandro.perez398@sena.edu.co','2025-03-01'),
('2000000399','Renata','Alvarez','renata.alvarez399@sena.edu.co','2025-03-01'),
('2000000400','Sebastian','Vargas','sebastian.vargas400@sena.edu.co','2025-03-01'),
('2000000401','Maria','Gomez','maria.gomez401@sena.edu.co','2025-03-01'),
('2000000402','Pedro','Romero','pedro.romero402@sena.edu.co','2025-03-01'),
('2000000403','Sofia','Castillo','sofia.castillo403@sena.edu.co','2025-03-01'),
('2000000404','Diego','Pinzon','diego.pinzon404@sena.edu.co','2025-03-01'),
('2000000405','Valeria','Mejia','valeria.mejia405@sena.edu.co','2025-03-01'),
('2000000406','Santiago','Fernandez','santiago.fernandez406@sena.edu.co','2025-03-01'),
('2000000407','Isabella','Reyes','isabella.reyes407@sena.edu.co','2025-03-01'),
('2000000408','Mateo','Rojas','mateo.rojas408@sena.edu.co','2025-03-01'),
('2000000409','Camila','Nino','camila.nino409@sena.edu.co','2025-03-01'),
('2000000410','Nicolas','Guerrero','nicolas.guerrero410@sena.edu.co','2025-03-01'),
('2000000411','Luciana','Zapata','luciana.zapata411@sena.edu.co','2025-03-01'),
('2000000412','Samuel','Martinez','samuel.martinez412@sena.edu.co','2025-03-01'),
('2000000413','Gabriela','Jimenez','gabriela.jimenez413@sena.edu.co','2025-03-01'),
('2000000414','Emilio','Ortega','emilio.ortega414@sena.edu.co','2025-03-01'),
('2000000415','Daniela','Cardenas','daniela.cardenas415@sena.edu.co','2025-03-01'),
('2000000416','Tomas','Rincon','tomas.rincon416@sena.edu.co','2025-03-01'),
('2000000417','Antonia','Cifuentes','antonia.cifuentes417@sena.edu.co','2025-03-01'),
('2000000418','Alejandro','Perez','alejandro.perez418@sena.edu.co','2025-03-01'),
('2000000419','Renata','Alvarez','renata.alvarez419@sena.edu.co','2025-03-01'),
('2000000420','Sebastian','Vargas','sebastian.vargas420@sena.edu.co','2025-03-01');

-- ------------------------------------------------------------
-- 2. INSTRUCTOR (usuarios 1-20)
-- ------------------------------------------------------------
INSERT INTO Instructor (id_instructor, acred_lic, telefono_celular, telefono_fijo) VALUES
(1,'Lic. Ingeniería de Software','3001110001','6011110001'),
(2,'Lic. Contaduría','3001110002','6011110002'),
(3,'Lic. Diseño Gráfico','3001110003','6011110003'),
(4,'Lic. Administración','3001110004','6011110004'),
(5,'Lic. Redes de Datos','3001110005','6011110005'),
(6,'Lic. Gastronomía','3001110006','6011110006'),
(7,'Lic. Mercadeo','3001110007','6011110007'),
(8,'Lic. Seguridad Industrial','3001110008','6011110008'),
(9,'Lic. Logística','3001110009','6011110009'),
(10,'Lic. Multimedia','3001110010','6011110010'),
(11,'Lic. Electricidad','3001110011','6011110011'),
(12,'Lic. Mecánica Automotriz','3001110012','6011110012'),
(13,'Lic. Turismo','3001110013','6011110013'),
(14,'Lic. Comercio Exterior','3001110014','6011110014'),
(15,'Lic. Desarrollo Web','3001110015','6011110015'),
(16,'Lic. Publicidad','3001110016','6011110016'),
(17,'Lic. Enfermería','3001110017','6011110017'),
(18,'Lic. Construcción','3001110018','6011110018'),
(19,'Lic. Producción Agropecuaria','3001110019','6011110019'),
(20,'Lic. Sistemas','3001110020','6011110020');

-- ------------------------------------------------------------
-- 3. PROGRAMA_FORMACION
-- ------------------------------------------------------------
INSERT INTO Programa_Formacion (nombre_programa) VALUES
('Análisis y Desarrollo de Software'),
('Contabilidad y Finanzas'),
('Diseño Gráfico'),
('Gestión Administrativa'),
('Redes y Telecomunicaciones'),
('Cocina'),
('Mercadeo'),
('Seguridad y Salud en el Trabajo'),
('Logística'),
('Producción Multimedia'),
('Electricidad Industrial'),
('Mecánica Automotriz'),
('Turismo'),
('Comercio Exterior'),
('Desarrollo Web'),
('Publicidad'),
('Enfermería'),
('Construcción'),
('Producción Agropecuaria'),
('Sistemas');

-- ------------------------------------------------------------
-- 4. FICHA (id_programa = N, id_instructor = N)
-- ------------------------------------------------------------
INSERT INTO Ficha (numero_ficha, jornada, fecha_inicio, fecha_fin, id_programa, id_instructor) VALUES
('2758501','Mañana','2025-02-03','2026-06-30',1,1),
('2758502','Tarde','2025-02-03','2026-06-30',2,2),
('2758503','Noche','2025-02-03','2026-06-30',3,3),
('2758504','Mixta','2025-02-03','2026-06-30',4,4),
('2758505','Mañana','2025-02-03','2026-06-30',5,5),
('2758506','Tarde','2025-02-03','2026-06-30',6,6),
('2758507','Noche','2025-02-03','2026-06-30',7,7),
('2758508','Mixta','2025-02-03','2026-06-30',8,8),
('2758509','Mañana','2025-02-03','2026-06-30',9,9),
('2758510','Tarde','2025-02-03','2026-06-30',10,10),
('2758511','Noche','2025-02-03','2026-06-30',11,11),
('2758512','Mixta','2025-02-03','2026-06-30',12,12),
('2758513','Mañana','2025-02-03','2026-06-30',13,13),
('2758514','Tarde','2025-02-03','2026-06-30',14,14),
('2758515','Noche','2025-02-03','2026-06-30',15,15),
('2758516','Mixta','2025-02-03','2026-06-30',16,16),
('2758517','Mañana','2025-02-03','2026-06-30',17,17),
('2758518','Tarde','2025-02-03','2026-06-30',18,18),
('2758519','Noche','2025-02-03','2026-06-30',19,19),
('2758520','Mixta','2025-02-03','2026-06-30',20,20);

-- ------------------------------------------------------------
-- 5. APRENDIZ (20 aprendices por ficha)
-- ------------------------------------------------------------
INSERT INTO Aprendiz (id_aprendiz, id_ficha, celular) VALUES
(21,1,'3003000001'),
(22,1,'3003000002'),
(23,1,'3003000003'),
(24,1,'3003000004'),
(25,1,'3003000005'),
(26,1,'3003000006'),
(27,1,'3003000007'),
(28,1,'3003000008'),
(29,1,'3003000009'),
(30,1,'3003000010'),
(31,1,'3003000011'),
(32,1,'3003000012'),
(33,1,'3003000013'),
(34,1,'3003000014'),
(35,1,'3003000015'),
(36,1,'3003000016'),
(37,1,'3003000017'),
(38,1,'3003000018'),
(39,1,'3003000019'),
(40,1,'3003000020'),
(41,2,'3003000021'),
(42,2,'3003000022'),
(43,2,'3003000023'),
(44,2,'3003000024'),
(45,2,'3003000025'),
(46,2,'3003000026'),
(47,2,'3003000027'),
(48,2,'3003000028'),
(49,2,'3003000029'),
(50,2,'3003000030'),
(51,2,'3003000031'),
(52,2,'3003000032'),
(53,2,'3003000033'),
(54,2,'3003000034'),
(55,2,'3003000035'),
(56,2,'3003000036'),
(57,2,'3003000037'),
(58,2,'3003000038'),
(59,2,'3003000039'),
(60,2,'3003000040'),
(61,3,'3003000041'),
(62,3,'3003000042'),
(63,3,'3003000043'),
(64,3,'3003000044'),
(65,3,'3003000045'),
(66,3,'3003000046'),
(67,3,'3003000047'),
(68,3,'3003000048'),
(69,3,'3003000049'),
(70,3,'3003000050'),
(71,3,'3003000051'),
(72,3,'3003000052'),
(73,3,'3003000053'),
(74,3,'3003000054'),
(75,3,'3003000055'),
(76,3,'3003000056'),
(77,3,'3003000057'),
(78,3,'3003000058'),
(79,3,'3003000059'),
(80,3,'3003000060'),
(81,4,'3003000061'),
(82,4,'3003000062'),
(83,4,'3003000063'),
(84,4,'3003000064'),
(85,4,'3003000065'),
(86,4,'3003000066'),
(87,4,'3003000067'),
(88,4,'3003000068'),
(89,4,'3003000069'),
(90,4,'3003000070'),
(91,4,'3003000071'),
(92,4,'3003000072'),
(93,4,'3003000073'),
(94,4,'3003000074'),
(95,4,'3003000075'),
(96,4,'3003000076'),
(97,4,'3003000077'),
(98,4,'3003000078'),
(99,4,'3003000079'),
(100,4,'3003000080'),
(101,5,'3003000081'),
(102,5,'3003000082'),
(103,5,'3003000083'),
(104,5,'3003000084'),
(105,5,'3003000085'),
(106,5,'3003000086'),
(107,5,'3003000087'),
(108,5,'3003000088'),
(109,5,'3003000089'),
(110,5,'3003000090'),
(111,5,'3003000091'),
(112,5,'3003000092'),
(113,5,'3003000093'),
(114,5,'3003000094'),
(115,5,'3003000095'),
(116,5,'3003000096'),
(117,5,'3003000097'),
(118,5,'3003000098'),
(119,5,'3003000099'),
(120,5,'3003000100'),
(121,6,'3003000101'),
(122,6,'3003000102'),
(123,6,'3003000103'),
(124,6,'3003000104'),
(125,6,'3003000105'),
(126,6,'3003000106'),
(127,6,'3003000107'),
(128,6,'3003000108'),
(129,6,'3003000109'),
(130,6,'3003000110'),
(131,6,'3003000111'),
(132,6,'3003000112'),
(133,6,'3003000113'),
(134,6,'3003000114'),
(135,6,'3003000115'),
(136,6,'3003000116'),
(137,6,'3003000117'),
(138,6,'3003000118'),
(139,6,'3003000119'),
(140,6,'3003000120'),
(141,7,'3003000121'),
(142,7,'3003000122'),
(143,7,'3003000123'),
(144,7,'3003000124'),
(145,7,'3003000125'),
(146,7,'3003000126'),
(147,7,'3003000127'),
(148,7,'3003000128'),
(149,7,'3003000129'),
(150,7,'3003000130'),
(151,7,'3003000131'),
(152,7,'3003000132'),
(153,7,'3003000133'),
(154,7,'3003000134'),
(155,7,'3003000135'),
(156,7,'3003000136'),
(157,7,'3003000137'),
(158,7,'3003000138'),
(159,7,'3003000139'),
(160,7,'3003000140'),
(161,8,'3003000141'),
(162,8,'3003000142'),
(163,8,'3003000143'),
(164,8,'3003000144'),
(165,8,'3003000145'),
(166,8,'3003000146'),
(167,8,'3003000147'),
(168,8,'3003000148'),
(169,8,'3003000149'),
(170,8,'3003000150'),
(171,8,'3003000151'),
(172,8,'3003000152'),
(173,8,'3003000153'),
(174,8,'3003000154'),
(175,8,'3003000155'),
(176,8,'3003000156'),
(177,8,'3003000157'),
(178,8,'3003000158'),
(179,8,'3003000159'),
(180,8,'3003000160'),
(181,9,'3003000161'),
(182,9,'3003000162'),
(183,9,'3003000163'),
(184,9,'3003000164'),
(185,9,'3003000165'),
(186,9,'3003000166'),
(187,9,'3003000167'),
(188,9,'3003000168'),
(189,9,'3003000169'),
(190,9,'3003000170'),
(191,9,'3003000171'),
(192,9,'3003000172'),
(193,9,'3003000173'),
(194,9,'3003000174'),
(195,9,'3003000175'),
(196,9,'3003000176'),
(197,9,'3003000177'),
(198,9,'3003000178'),
(199,9,'3003000179'),
(200,9,'3003000180'),
(201,10,'3003000181'),
(202,10,'3003000182'),
(203,10,'3003000183'),
(204,10,'3003000184'),
(205,10,'3003000185'),
(206,10,'3003000186'),
(207,10,'3003000187'),
(208,10,'3003000188'),
(209,10,'3003000189'),
(210,10,'3003000190'),
(211,10,'3003000191'),
(212,10,'3003000192'),
(213,10,'3003000193'),
(214,10,'3003000194'),
(215,10,'3003000195'),
(216,10,'3003000196'),
(217,10,'3003000197'),
(218,10,'3003000198'),
(219,10,'3003000199'),
(220,10,'3003000200'),
(221,11,'3003000201'),
(222,11,'3003000202'),
(223,11,'3003000203'),
(224,11,'3003000204'),
(225,11,'3003000205'),
(226,11,'3003000206'),
(227,11,'3003000207'),
(228,11,'3003000208'),
(229,11,'3003000209'),
(230,11,'3003000210'),
(231,11,'3003000211'),
(232,11,'3003000212'),
(233,11,'3003000213'),
(234,11,'3003000214'),
(235,11,'3003000215'),
(236,11,'3003000216'),
(237,11,'3003000217'),
(238,11,'3003000218'),
(239,11,'3003000219'),
(240,11,'3003000220'),
(241,12,'3003000221'),
(242,12,'3003000222'),
(243,12,'3003000223'),
(244,12,'3003000224'),
(245,12,'3003000225'),
(246,12,'3003000226'),
(247,12,'3003000227'),
(248,12,'3003000228'),
(249,12,'3003000229'),
(250,12,'3003000230'),
(251,12,'3003000231'),
(252,12,'3003000232'),
(253,12,'3003000233'),
(254,12,'3003000234'),
(255,12,'3003000235'),
(256,12,'3003000236'),
(257,12,'3003000237'),
(258,12,'3003000238'),
(259,12,'3003000239'),
(260,12,'3003000240'),
(261,13,'3003000241'),
(262,13,'3003000242'),
(263,13,'3003000243'),
(264,13,'3003000244'),
(265,13,'3003000245'),
(266,13,'3003000246'),
(267,13,'3003000247'),
(268,13,'3003000248'),
(269,13,'3003000249'),
(270,13,'3003000250'),
(271,13,'3003000251'),
(272,13,'3003000252'),
(273,13,'3003000253'),
(274,13,'3003000254'),
(275,13,'3003000255'),
(276,13,'3003000256'),
(277,13,'3003000257'),
(278,13,'3003000258'),
(279,13,'3003000259'),
(280,13,'3003000260'),
(281,14,'3003000261'),
(282,14,'3003000262'),
(283,14,'3003000263'),
(284,14,'3003000264'),
(285,14,'3003000265'),
(286,14,'3003000266'),
(287,14,'3003000267'),
(288,14,'3003000268'),
(289,14,'3003000269'),
(290,14,'3003000270'),
(291,14,'3003000271'),
(292,14,'3003000272'),
(293,14,'3003000273'),
(294,14,'3003000274'),
(295,14,'3003000275'),
(296,14,'3003000276'),
(297,14,'3003000277'),
(298,14,'3003000278'),
(299,14,'3003000279'),
(300,14,'3003000280'),
(301,15,'3003000281'),
(302,15,'3003000282'),
(303,15,'3003000283'),
(304,15,'3003000284'),
(305,15,'3003000285'),
(306,15,'3003000286'),
(307,15,'3003000287'),
(308,15,'3003000288'),
(309,15,'3003000289'),
(310,15,'3003000290'),
(311,15,'3003000291'),
(312,15,'3003000292'),
(313,15,'3003000293'),
(314,15,'3003000294'),
(315,15,'3003000295'),
(316,15,'3003000296'),
(317,15,'3003000297'),
(318,15,'3003000298'),
(319,15,'3003000299'),
(320,15,'3003000300'),
(321,16,'3003000301'),
(322,16,'3003000302'),
(323,16,'3003000303'),
(324,16,'3003000304'),
(325,16,'3003000305'),
(326,16,'3003000306'),
(327,16,'3003000307'),
(328,16,'3003000308'),
(329,16,'3003000309'),
(330,16,'3003000310'),
(331,16,'3003000311'),
(332,16,'3003000312'),
(333,16,'3003000313'),
(334,16,'3003000314'),
(335,16,'3003000315'),
(336,16,'3003000316'),
(337,16,'3003000317'),
(338,16,'3003000318'),
(339,16,'3003000319'),
(340,16,'3003000320'),
(341,17,'3003000321'),
(342,17,'3003000322'),
(343,17,'3003000323'),
(344,17,'3003000324'),
(345,17,'3003000325'),
(346,17,'3003000326'),
(347,17,'3003000327'),
(348,17,'3003000328'),
(349,17,'3003000329'),
(350,17,'3003000330'),
(351,17,'3003000331'),
(352,17,'3003000332'),
(353,17,'3003000333'),
(354,17,'3003000334'),
(355,17,'3003000335'),
(356,17,'3003000336'),
(357,17,'3003000337'),
(358,17,'3003000338'),
(359,17,'3003000339'),
(360,17,'3003000340'),
(361,18,'3003000341'),
(362,18,'3003000342'),
(363,18,'3003000343'),
(364,18,'3003000344'),
(365,18,'3003000345'),
(366,18,'3003000346'),
(367,18,'3003000347'),
(368,18,'3003000348'),
(369,18,'3003000349'),
(370,18,'3003000350'),
(371,18,'3003000351'),
(372,18,'3003000352'),
(373,18,'3003000353'),
(374,18,'3003000354'),
(375,18,'3003000355'),
(376,18,'3003000356'),
(377,18,'3003000357'),
(378,18,'3003000358'),
(379,18,'3003000359'),
(380,18,'3003000360'),
(381,19,'3003000361'),
(382,19,'3003000362'),
(383,19,'3003000363'),
(384,19,'3003000364'),
(385,19,'3003000365'),
(386,19,'3003000366'),
(387,19,'3003000367'),
(388,19,'3003000368'),
(389,19,'3003000369'),
(390,19,'3003000370'),
(391,19,'3003000371'),
(392,19,'3003000372'),
(393,19,'3003000373'),
(394,19,'3003000374'),
(395,19,'3003000375'),
(396,19,'3003000376'),
(397,19,'3003000377'),
(398,19,'3003000378'),
(399,19,'3003000379'),
(400,19,'3003000380'),
(401,20,'3003000381'),
(402,20,'3003000382'),
(403,20,'3003000383'),
(404,20,'3003000384'),
(405,20,'3003000385'),
(406,20,'3003000386'),
(407,20,'3003000387'),
(408,20,'3003000388'),
(409,20,'3003000389'),
(410,20,'3003000390'),
(411,20,'3003000391'),
(412,20,'3003000392'),
(413,20,'3003000393'),
(414,20,'3003000394'),
(415,20,'3003000395'),
(416,20,'3003000396'),
(417,20,'3003000397'),
(418,20,'3003000398'),
(419,20,'3003000399'),
(420,20,'3003000400');

-- ------------------------------------------------------------
-- 6. COMPETENCIA
-- ------------------------------------------------------------
INSERT INTO Competencia (nombre_competencia, duracion_horas) VALUES
('Codificar aplicaciones de software',880),
('Elaborar diagnósticos financieros',240),
('Diseñar piezas gráficas',160),
('Administrar procesos de gestión documental',400),
('Configurar redes de datos',320),
('Preparar alimentos',350),
('Ejecutar estrategias de mercadeo',180),
('Aplicar normas de seguridad industrial',120),
('Gestionar procesos logísticos',260),
('Producir contenidos multimedia',300),
('Instalar sistemas eléctricos',280),
('Realizar mantenimiento automotriz',400),
('Planear rutas turísticas',150),
('Gestionar operaciones de comercio exterior',220),
('Desarrollar software web',500),
('Crear campañas publicitarias',170),
('Brindar cuidados básicos de enfermería',380),
('Ejecutar procesos constructivos',450),
('Cultivar productos agropecuarios',300),
('Administrar bases de datos',400);

-- ------------------------------------------------------------
-- 7. RESULTADO_APRENDIZAJE (id_competencia = N)
-- ------------------------------------------------------------
INSERT INTO Resultado_Aprendizaje (descripcion, duracion_horas, id_competencia) VALUES
('Aplicar fundamentos de programación en un caso práctico',80,1),
('Elaborar un estado financiero básico',60,2),
('Diseñar una pieza gráfica publicitaria',50,3),
('Organizar el archivo documental de una oficina',40,4),
('Configurar una red LAN básica',70,5),
('Preparar un menú de tres tiempos',60,6),
('Diseñar un plan de mercadeo básico',50,7),
('Identificar riesgos laborales en un puesto de trabajo',40,8),
('Elaborar una ruta logística de distribución',60,9),
('Editar un video corto para redes sociales',70,10),
('Instalar un tablero eléctrico residencial',80,11),
('Diagnosticar fallas mecánicas básicas',90,12),
('Diseñar un paquete turístico',50,13),
('Elaborar una factura comercial de exportación',60,14),
('Construir una página web responsiva',100,15),
('Diseñar una campaña en redes sociales',60,16),
('Aplicar protocolos básicos de enfermería',70,17),
('Leer planos arquitectónicos básicos',50,18),
('Aplicar buenas prácticas agrícolas',60,19),
('Diseñar un modelo entidad-relación',80,20);

-- ------------------------------------------------------------
-- 8. ACTIVIDAD (id_instructor = N, id_ficha = N, id_resultado = N)
-- ------------------------------------------------------------
INSERT INTO Actividad (titulo, descripcion, fecha_vencimiento, tipo_actividad, id_instructor, id_ficha, id_resultado) VALUES
('Taller de variables y tipos de datos','Ejercicios básicos de programación','2026-03-01 23:59:00','Taller',1,1,1),
('Quiz de estados financieros','Evaluación corta de conceptos contables','2026-03-02 23:59:00','Quiz',2,2,2),
('Proyecto de identidad visual','Diseño de logo y manual de marca','2026-03-03 23:59:00','Proyecto',3,3,3),
('Taller de gestión documental','Organización de archivo físico y digital','2026-03-04 23:59:00','Taller',4,4,4),
('Evaluación de redes LAN','Configuración práctica de una red','2026-03-05 23:59:00','Evaluación',5,5,5),
('Foro de técnicas culinarias','Discusión sobre técnicas de cocción','2026-03-06 23:59:00','Foro',6,6,6),
('Proyecto plan de mercadeo','Plan de mercadeo para producto ficticio','2026-03-07 23:59:00','Proyecto',7,7,7),
('Quiz de seguridad industrial','Evaluación de normas de seguridad','2026-03-08 23:59:00','Quiz',8,8,8),
('Taller de rutas logísticas','Diseño de ruta de distribución','2026-03-09 23:59:00','Taller',9,9,9),
('Proyecto de video corto','Edición de video para redes','2026-03-10 23:59:00','Proyecto',10,10,10),
('Taller de instalaciones eléctricas','Práctica de tablero residencial','2026-03-11 23:59:00','Taller',11,11,11),
('Evaluación de diagnóstico automotriz','Diagnóstico de fallas comunes','2026-03-12 23:59:00','Evaluación',12,12,12),
('Proyecto de paquete turístico','Diseño de paquete turístico regional','2026-03-13 23:59:00','Proyecto',13,13,13),
('Taller de comercio exterior','Elaboración de documentos de exportación','2026-03-14 23:59:00','Taller',14,14,14),
('Proyecto página web','Construcción de sitio web responsivo','2026-03-15 23:59:00','Proyecto',15,15,15),
('Taller de campaña publicitaria','Diseño de campaña en redes sociales','2026-03-16 23:59:00','Taller',16,16,16),
('Evaluación de enfermería básica','Aplicación de protocolos básicos','2026-03-17 23:59:00','Evaluación',17,17,17),
('Taller de lectura de planos','Interpretación de planos arquitectónicos','2026-03-18 23:59:00','Taller',18,18,18),
('Proyecto agropecuario','Plan de buenas prácticas agrícolas','2026-03-19 23:59:00','Proyecto',19,19,19),
('Taller de modelado de datos','Diseño de modelo entidad-relación','2026-03-20 23:59:00','Taller',20,20,20);

-- ------------------------------------------------------------
-- 9. ENTREGA (id_actividad = N, id_aprendiz = primer aprendiz de la ficha N)
-- ------------------------------------------------------------
INSERT INTO Entrega (id_actividad, id_aprendiz, fecha_entrega, estado) VALUES
(1,21,'2026-02-28 09:00:00','EVALUADO'),
(2,41,'2026-03-02 10:00:00','EVALUADO'),
(3,61,'2026-03-03 11:00:00','EVALUADO'),
(4,81,'2026-03-04 12:00:00','EVALUADO'),
(5,101,'2026-03-05 13:00:00','EVALUADO'),
(6,121,'2026-03-06 14:00:00','EVALUADO'),
(7,141,'2026-03-07 15:00:00','EVALUADO'),
(8,161,'2026-03-08 16:00:00','EVALUADO'),
(9,181,'2026-03-09 17:00:00','EVALUADO'),
(10,201,'2026-03-10 08:00:00','EVALUADO'),
(11,221,'2026-03-11 09:00:00','EVALUADO'),
(12,241,'2026-03-12 10:00:00','EVALUADO'),
(13,261,'2026-03-13 11:00:00','EVALUADO'),
(14,281,'2026-03-14 12:00:00','EVALUADO'),
(15,301,'2026-03-15 13:00:00','EVALUADO'),
(16,321,'2026-03-16 14:00:00','EVALUADO'),
(17,341,'2026-03-17 15:00:00','EVALUADO'),
(18,361,'2026-03-18 16:00:00','ENVIADO'),
(19,381,'2026-03-19 17:00:00','ENVIADO'),
(20,401,'2026-03-20 08:00:00','CORREGIR');

-- ------------------------------------------------------------
-- 10. RETROALIMENTACION (entregas evaluadas/corregidas: 18 filas)
-- ------------------------------------------------------------
INSERT INTO Retroalimentacion (id_entrega, id_instructor, nota, descripcion, fecha_calificacion) VALUES
(1,1,4.5,'Buen manejo de variables, revisar tipos de dato','2026-03-02 10:00:00'),
(2,2,4.2,'Estados financieros correctos','2026-03-03 10:00:00'),
(3,3,4.8,'Excelente propuesta de marca','2026-03-04 10:00:00'),
(4,4,3.9,'Buen orden documental, falta rotulado','2026-03-05 10:00:00'),
(5,5,4.6,'Red configurada correctamente','2026-03-06 10:00:00'),
(6,6,4.3,'Buena participación en el foro','2026-03-07 10:00:00'),
(7,7,4.0,'Plan de mercadeo coherente','2026-03-08 10:00:00'),
(8,8,4.9,'Excelente identificación de riesgos','2026-03-09 10:00:00'),
(9,9,3.8,'Ruta logística funcional, optimizar tiempos','2026-03-10 10:00:00'),
(10,10,4.7,'Buen manejo de edición de video','2026-03-11 10:00:00'),
(11,11,4.4,'Instalación eléctrica correcta','2026-03-12 10:00:00'),
(12,12,4.1,'Diagnóstico acertado','2026-03-13 10:00:00'),
(13,13,4.6,'Paquete turístico atractivo','2026-03-14 10:00:00'),
(14,14,3.7,'Documentos incompletos, corregir','2026-03-15 10:00:00'),
(15,15,4.9,'Sitio web bien estructurado','2026-03-16 10:00:00'),
(16,16,4.3,'Campaña creativa y coherente','2026-03-17 10:00:00'),
(17,17,4.5,'Protocolos aplicados correctamente','2026-03-18 10:00:00'),
(20,20,2.90,'Modelo entidad-relación con errores, corregir relaciones','2026-03-20 10:00:00');

-- ------------------------------------------------------------
-- 11. COMENTARIO (hilo sobre las retroalimentaciones 1-10)
-- ------------------------------------------------------------
INSERT INTO Comentario (id_retroalimentacion, id_usuario, texto_comentario, fecha_comentario) VALUES
(1,1,'Recuerda documentar tu código la próxima vez','2026-03-02 11:00:00'),
(1,21,'Gracias profe, lo tendré en cuenta','2026-03-02 11:15:00'),
(2,2,'Muy buen trabajo con los balances','2026-03-03 11:00:00'),
(2,41,'Gracias, tuve dudas con el activo corriente','2026-03-03 11:15:00'),
(3,3,'La paleta de colores quedó muy bien','2026-03-04 11:00:00'),
(3,61,'Gracias, la ajusté varias veces','2026-03-04 11:15:00'),
(4,4,'Falta rotular las carpetas físicas','2026-03-05 11:00:00'),
(4,81,'Entendido, lo corrijo esta semana','2026-03-05 11:15:00'),
(5,5,'Buena segmentación de subredes','2026-03-06 11:00:00'),
(5,101,'Gracias, practiqué bastante','2026-03-06 11:15:00'),
(6,6,'Excelente aporte en el foro','2026-03-07 11:00:00'),
(6,121,'Fue un tema interesante','2026-03-07 11:15:00'),
(7,7,'Revisa el público objetivo del plan','2026-03-08 11:00:00'),
(7,141,'Lo ajusto para la próxima entrega','2026-03-08 11:15:00'),
(8,8,'Identificaste todos los riesgos correctamente','2026-03-09 11:00:00'),
(8,161,'Gracias por la retroalimentación','2026-03-09 11:15:00'),
(9,9,'Optimiza los tiempos de la ruta 2','2026-03-10 11:00:00'),
(9,181,'Voy a revisar esa ruta','2026-03-10 11:15:00'),
(10,10,'Buen ritmo de edición','2026-03-11 11:00:00'),
(10,201,'Gracias, use varias transiciones','2026-03-11 11:15:00');

-- ------------------------------------------------------------
-- 12. REPOSITORIO (10 materiales de instructor + 10 archivos de entrega)
-- ------------------------------------------------------------
INSERT INTO Repositorio (nombre_archivo, tipo_formato, url_ubicacion, fecha_subida, tamanio, id_instructor, id_actividad, id_entrega) VALUES
('guia_variables.pdf','PDF','https://storage.sira.edu.co/materiales/guia_variables.pdf','2026-02-20 08:00:00',850,1,1,NULL),
('plantilla_estados_financieros.xlsx','XLSX','https://storage.sira.edu.co/materiales/plantilla_ef.xlsx','2026-02-20 08:00:00',120,2,2,NULL),
('brief_identidad_visual.pdf','PDF','https://storage.sira.edu.co/materiales/brief_marca.pdf','2026-02-20 08:00:00',600,3,3,NULL),
('guia_gestion_documental.pdf','PDF','https://storage.sira.edu.co/materiales/guia_gd.pdf','2026-02-20 08:00:00',400,4,4,NULL),
('manual_redes_lan.pdf','PDF','https://storage.sira.edu.co/materiales/manual_lan.pdf','2026-02-20 08:00:00',950,5,5,NULL),
('recetario_base.pdf','PDF','https://storage.sira.edu.co/materiales/recetario.pdf','2026-02-20 08:00:00',1200,6,6,NULL),
('plantilla_plan_mercadeo.docx','DOCX','https://storage.sira.edu.co/materiales/plan_mercadeo.docx','2026-02-20 08:00:00',300,7,7,NULL),
('normas_seguridad.pdf','PDF','https://storage.sira.edu.co/materiales/normas_seg.pdf','2026-02-20 08:00:00',500,8,8,NULL),
('guia_rutas_logisticas.pdf','PDF','https://storage.sira.edu.co/materiales/rutas.pdf','2026-02-20 08:00:00',420,9,9,NULL),
('guia_edicion_video.pdf','PDF','https://storage.sira.edu.co/materiales/edicion_video.pdf','2026-02-20 08:00:00',700,10,10,NULL),
('entrega_taller_variables.zip','ZIP','https://storage.sira.edu.co/entregas/e1.zip','2026-02-28 09:00:00',80,NULL,NULL,1),
('entrega_estados_financieros.xlsx','XLSX','https://storage.sira.edu.co/entregas/e2.xlsx','2026-03-02 10:00:00',95,NULL,NULL,2),
('entrega_identidad_visual.pdf','PDF','https://storage.sira.edu.co/entregas/e3.pdf','2026-03-03 11:00:00',1500,NULL,NULL,3),
('entrega_gestion_documental.pdf','PDF','https://storage.sira.edu.co/entregas/e4.pdf','2026-03-04 12:00:00',210,NULL,NULL,4),
('entrega_config_red.pdf','PDF','https://storage.sira.edu.co/entregas/e5.pdf','2026-03-05 13:00:00',180,NULL,NULL,5),
('entrega_participacion_foro.docx','DOCX','https://storage.sira.edu.co/entregas/e6.docx','2026-03-06 14:00:00',60,NULL,NULL,6),
('entrega_plan_mercadeo.pdf','PDF','https://storage.sira.edu.co/entregas/e7.pdf','2026-03-07 15:00:00',330,NULL,NULL,7),
('entrega_seguridad_industrial.pdf','PDF','https://storage.sira.edu.co/entregas/e8.pdf','2026-03-08 16:00:00',140,NULL,NULL,8),
('entrega_ruta_logistica.pdf','PDF','https://storage.sira.edu.co/entregas/e9.pdf','2026-03-09 17:00:00',260,NULL,NULL,9),
('entrega_video_corto.mp4','MP4','https://storage.sira.edu.co/entregas/e10.mp4','2026-03-10 08:00:00',5200,NULL,NULL,10);

-- ------------------------------------------------------------
-- 13. NOTIFICACION
-- ------------------------------------------------------------
INSERT INTO Notificacion (id_usuario, mensaje, tipo, leida, fecha_envio) VALUES
(21,'Tu entrega de Taller de variables fue calificada','CALIFICACION',TRUE,'2026-03-02 10:05:00'),
(41,'Tu entrega de Quiz de estados financieros fue calificada','CALIFICACION',TRUE,'2026-03-03 10:05:00'),
(61,'Tu entrega de Proyecto de identidad visual fue calificada','CALIFICACION',FALSE,'2026-03-04 10:05:00'),
(81,'Tu entrega de Taller de gestión documental fue calificada','CALIFICACION',FALSE,'2026-03-05 10:05:00'),
(101,'Tu entrega de Evaluación de redes LAN fue calificada','CALIFICACION',TRUE,'2026-03-06 10:05:00'),
(1,'Tienes una nueva entrega pendiente por evaluar','ACTIVIDAD',FALSE,'2026-03-06 09:00:00'),
(2,'Tienes una nueva entrega pendiente por evaluar','ACTIVIDAD',TRUE,'2026-03-07 09:00:00'),
(361,'Recuerda que tu entrega vence pronto','ACTIVIDAD',FALSE,'2026-03-16 09:00:00'),
(381,'Recuerda que tu entrega vence pronto','ACTIVIDAD',FALSE,'2026-03-17 09:00:00'),
(401,'Tu entrega fue marcada para corrección','CALIFICACION',FALSE,'2026-03-20 10:05:00'),
(21,'Nuevo comentario en tu retroalimentación','COMENTARIO',TRUE,'2026-03-02 11:15:00'),
(1,'Nuevo comentario en tu retroalimentación','COMENTARIO',TRUE,'2026-03-02 11:16:00'),
(3,'Nuevo material disponible para tu ficha','SISTEMA',FALSE,'2026-02-20 08:05:00'),
(4,'Nuevo material disponible para tu ficha','SISTEMA',FALSE,'2026-02-20 08:05:00'),
(5,'Nuevo material disponible para tu ficha','SISTEMA',TRUE,'2026-02-20 08:05:00'),
(26,'Bienvenido a la plataforma SIRA','SISTEMA',TRUE,'2025-02-01 08:00:00'),
(27,'Bienvenido a la plataforma SIRA','SISTEMA',TRUE,'2025-02-01 08:00:00'),
(28,'Bienvenido a la plataforma SIRA','SISTEMA',FALSE,'2025-02-01 08:00:00'),
(29,'Bienvenido a la plataforma SIRA','SISTEMA',FALSE,'2025-02-01 08:00:00'),
(30,'Bienvenido a la plataforma SIRA','SISTEMA',TRUE,'2025-02-01 08:00:00');

-- ------------------------------------------------------------
-- CONSULTAS
-- ------------------------------------------------------------

-- 1. Perfil completo de un usuario, detectando su rol
SELECT
    u.id_usuario, u.nombres, u.apellidos, u.email,
    CASE
        WHEN i.id_instructor IS NOT NULL THEN 'INSTRUCTOR'
        WHEN a.id_aprendiz  IS NOT NULL THEN 'APRENDIZ'
    END AS rol,
    i.acred_lic, i.telefono_celular AS tel_instructor,
    a.id_ficha, a.celular AS tel_aprendiz
FROM Usuario u
LEFT JOIN Instructor i ON i.id_instructor = u.id_usuario
LEFT JOIN Aprendiz   a ON a.id_aprendiz   = u.id_usuario
WHERE u.id_usuario = 41;

-- 2. Actividades pendientes de un aprendiz (aún no entregadas)
SELECT
    act.id_actividad, act.titulo, act.fecha_vencimiento, act.tipo_actividad,
    f.numero_ficha
FROM Actividad act
JOIN Aprendiz apr   ON apr.id_ficha = act.id_ficha
JOIN Ficha f        ON f.id_ficha  = act.id_ficha
LEFT JOIN Entrega e ON e.id_actividad = act.id_actividad
                    AND e.id_aprendiz  = apr.id_aprendiz
WHERE apr.id_aprendiz = 1
  AND e.id_entrega IS NULL
ORDER BY act.fecha_vencimiento ASC;

-- 3. Historial de entregas de un aprendiz con su calificación (si existe)
SELECT
    act.titulo, e.fecha_entrega, e.estado,
    r.nota, r.descripcion AS retro_descripcion, r.fecha_calificacion
FROM Entrega e
JOIN Actividad act        ON act.id_actividad = e.id_actividad
LEFT JOIN Retroalimentacion r ON r.id_entrega = e.id_entrega
WHERE e.id_aprendiz = 1
ORDER BY e.fecha_entrega DESC;

-- 4. Actividades creadas por un instructor, con avance de entregas
SELECT
    act.id_actividad, act.titulo, act.fecha_vencimiento,
    f.numero_ficha,
    COUNT(DISTINCT e.id_entrega) AS entregas_recibidas,
    (SELECT COUNT(*) FROM Aprendiz WHERE id_ficha = f.id_ficha) AS total_aprendices
FROM Actividad act
JOIN Ficha f    ON f.id_ficha = act.id_ficha
LEFT JOIN Entrega e ON e.id_actividad = act.id_actividad
WHERE act.id_instructor = 1
GROUP BY act.id_actividad, act.titulo, act.fecha_vencimiento, f.numero_ficha, f.id_ficha
ORDER BY act.fecha_vencimiento DESC;

-- 5. Aprendices que aún no han entregado una actividad puntual
SELECT u.nombres, u.apellidos, u.email
FROM Aprendiz apr
JOIN Usuario u ON u.id_usuario = apr.id_aprendiz
LEFT JOIN Entrega e ON e.id_aprendiz = apr.id_aprendiz
                    AND e.id_actividad = 1
WHERE apr.id_ficha = (SELECT id_ficha FROM Actividad WHERE id_actividad = 1)
  AND e.id_entrega IS NULL;

-- 6. Bandeja de entregas pendientes de evaluar por un instructor
SELECT
    e.id_entrega, u.nombres, u.apellidos, act.titulo, e.fecha_entrega
FROM Entrega e
JOIN Actividad act ON act.id_actividad = e.id_actividad
JOIN Aprendiz apr  ON apr.id_aprendiz  = e.id_aprendiz
JOIN Usuario u     ON u.id_usuario     = apr.id_aprendiz
WHERE act.id_instructor = 1
  AND e.estado = 'ENVIADO'
ORDER BY e.fecha_entrega ASC;

-- 7. Detalle completo de una entrega evaluada: nota, retro y archivo
SELECT
    e.id_entrega, e.fecha_entrega, e.estado,
    r.nota, r.descripcion, r.fecha_calificacion,
    rep.nombre_archivo, rep.url_ubicacion
FROM Entrega e
LEFT JOIN Retroalimentacion r ON r.id_entrega   = e.id_entrega
LEFT JOIN Repositorio rep     ON rep.id_entrega = e.id_entrega
WHERE e.id_entrega = 1;

-- 8. Hilo de comentarios de una retroalimentación, con autor
SELECT
    c.id_comentario, u.nombres, u.apellidos, c.texto_comentario, c.fecha_comentario
FROM Comentario c
JOIN Usuario u ON u.id_usuario = c.id_usuario
WHERE c.id_retroalimentacion = 1
ORDER BY c.fecha_comentario ASC;

-- 9. Materiales de estudio subidos por el instructor para una actividad
SELECT rep.nombre_archivo, rep.tipo_formato, rep.url_ubicacion, rep.fecha_subida
FROM Repositorio rep
WHERE rep.id_actividad = 1
ORDER BY rep.fecha_subida DESC;

-- 10. Notificaciones no leídas de un usuario, más recientes primero
SELECT id_notificacion, mensaje, tipo, fecha_envio
FROM Notificacion
WHERE id_usuario = 1 AND leida = FALSE
ORDER BY fecha_envio DESC;

-- 11. Promedio de notas por ficha
SELECT
    f.numero_ficha,
    ROUND(AVG(r.nota), 2) AS promedio_nota,
    COUNT(r.id_retroalimentacion) AS total_calificaciones
FROM Ficha f
JOIN Aprendiz apr   ON apr.id_ficha = f.id_ficha
JOIN Entrega e      ON e.id_aprendiz = apr.id_aprendiz
JOIN Retroalimentacion r ON r.id_entrega = e.id_entrega
GROUP BY f.id_ficha, f.numero_ficha
ORDER BY promedio_nota DESC;

-- 12. Fichas de un programa con instructor asignado y cantidad de aprendices
SELECT
    pf.nombre_programa, f.numero_ficha, f.jornada,
    CONCAT(ui.nombres, ' ', ui.apellidos) AS instructor_lider,
    COUNT(apr.id_aprendiz) AS total_aprendices
FROM Ficha f
JOIN Programa_Formacion pf ON pf.id_programa = f.id_programa
JOIN Instructor ins        ON ins.id_instructor = f.id_instructor
JOIN Usuario ui             ON ui.id_usuario = ins.id_instructor
LEFT JOIN Aprendiz apr      ON apr.id_ficha = f.id_ficha
GROUP BY pf.nombre_programa, f.id_ficha, f.numero_ficha, f.jornada, ui.nombres, ui.apellidos
ORDER BY pf.nombre_programa, f.numero_ficha;
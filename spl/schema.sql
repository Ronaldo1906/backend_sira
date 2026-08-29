CREATE DATABASE IF NOT EXISTS sira CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sira;

-- Tabla Usuario
CREATE TABLE IF NOT EXISTS Usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    num_documento VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Ficha
CREATE TABLE IF NOT EXISTS Ficha (
    id_ficha INT AUTO_INCREMENT PRIMARY KEY,
    codigo_ficha VARCHAR(20) NOT NULL UNIQUE,
    nombre_programa VARCHAR(150) NOT NULL
);

-- Tabla Aprendiz
CREATE TABLE IF NOT EXISTS Aprendiz (
    id_aprendiz INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    id_ficha INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_ficha) REFERENCES Ficha(id_ficha) ON DELETE RESTRICT
);

-- Tabla Instructor
CREATE TABLE IF NOT EXISTS Instructor (
    id_instructor INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    especialidad VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Actividad
CREATE TABLE IF NOT EXISTS Actividad (
    id_actividad INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_vencimiento DATETIME NOT NULL,
    tipo_actividad VARCHAR(50),
    id_instructor INT NOT NULL,
    id_ficha INT NOT NULL,
    FOREIGN KEY (id_instructor) REFERENCES Instructor(id_instructor) ON DELETE RESTRICT,
    FOREIGN KEY (id_ficha) REFERENCES Ficha(id_ficha) ON DELETE RESTRICT
);

-- Tabla Entrega
CREATE TABLE IF NOT EXISTS Entrega (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_actividad INT NOT NULL,
    id_aprendiz INT NOT NULL,
    fecha_entrega DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('ENVIADO', 'EVALUADO', 'CORREGIR') DEFAULT 'ENVIADO',
    FOREIGN KEY (id_actividad) REFERENCES Actividad(id_actividad) ON DELETE CASCADE,
    FOREIGN KEY (id_aprendiz) REFERENCES Aprendiz(id_aprendiz) ON DELETE RESTRICT
);

-- Tabla Retroalimentacion
CREATE TABLE IF NOT EXISTS Retroalimentacion (
    id_retroalimentacion INT AUTO_INCREMENT PRIMARY KEY,
    id_entrega INT NOT NULL UNIQUE,
    id_instructor INT NOT NULL,
    nota DECIMAL(4, 2) NOT NULL,
    descripcion TEXT,
    fecha_calificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_entrega) REFERENCES Entrega(id_entrega) ON DELETE CASCADE,
    FOREIGN KEY (id_instructor) REFERENCES Instructor(id_instructor) ON DELETE RESTRICT
);

-- Tabla Repositorio
CREATE TABLE IF NOT EXISTS Repositorio (
    id_repositorio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_archivo VARCHAR(255) NOT NULL,
    url_archivo VARCHAR(255) NOT NULL,
    id_actividad INT NULL,
    id_entrega INT NULL,
    CONSTRAINT chk_repositorio_destino CHECK (
        (id_actividad IS NOT NULL AND id_entrega IS NULL) OR 
        (id_actividad IS NULL AND id_entrega IS NOT NULL)
    ),
    FOREIGN KEY (id_actividad) REFERENCES Actividad(id_actividad) ON DELETE CASCADE,
    FOREIGN KEY (id_entrega) REFERENCES Entrega(id_entrega) ON DELETE CASCADE
);

-- Trigger: Actualizar estado de la entrega a EVALUADO
DELIMITER $$
CREATE TRIGGER trg_actualizar_estado_entrega
AFTER INSERT ON Retroalimentacion
FOR EACH ROW
BEGIN
    UPDATE Entrega 
    SET estado = 'EVALUADO' 
    WHERE id_entrega = NEW.id_entrega;
END$$
DELIMITER ;
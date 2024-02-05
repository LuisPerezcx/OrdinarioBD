drop database inscripcionesunsij;
create database inscripcionesunsij;
use inscripcionesunsij;

-- Crear la tabla Carrera
CREATE TABLE Carrera (
    idCarrera INT(2) PRIMARY KEY NOT NULL,
    nombreCarrera VARCHAR(40) NOT NULL
);

-- Crear la tabla Semestre
CREATE TABLE Semestre (
    idSemestre INT(2) PRIMARY KEY NOT NULL,
    nombreSemestre VARCHAR(15) NOT NULL
);

-- Crear la tabla Pais
CREATE TABLE Pais (
    idPais INT(2) PRIMARY KEY NOT NULL,
    nombrePais VARCHAR(15) NOT NULL
);

-- Crear la tabla Estado
CREATE TABLE Estado (
    idEstado INT(2) PRIMARY KEY NOT NULL,
    nombreEstado VARCHAR(30) NOT NULL,
    idPais INT(2) NOT NULL,
    FOREIGN KEY (idPais) REFERENCES Pais(idPais)
);

-- Crear la tabla Ciudad
CREATE TABLE Ciudad (
    idCiudad INT(2) PRIMARY KEY NOT NULL,
    nombreCiudad VARCHAR(30) NOT NULL,
    idEstado INT(3) NOT NULL,
    FOREIGN KEY (idEstado) REFERENCES Estado(idEstado)
);

-- Crear la tabla CodigoPostal
CREATE TABLE CodigoPostal (
    idCodigoPostal INT(2) PRIMARY KEY NOT NULL,
    numeroCodigo INT(5) NOT NULL,
    idCiudad INT(3) NOT NULL,
    FOREIGN KEY (idCiudad) REFERENCES Ciudad(idCiudad)
);

-- Crear la tabla Tutor
CREATE TABLE Tutor (
    idTutor INT(2) PRIMARY KEY NOT NULL,
    nombreTutor VARCHAR(45) NOT NULL,
    numeroTutor BIGINT(10) NOT NULL,
    direccionTutor VARCHAR(100) NOT NULL
);

-- Crear la tabla Inscripcion
CREATE TABLE EscuelaProcedencia (
    idEscuelaProcedencia INT(2) PRIMARY KEY NOT NULL,
    escuelaProcedencia VARCHAR(45) NOT NULL,
    direccionEscuela varchar(60) not null
);


-- Crear la tabla Grupo
CREATE TABLE Grupo (
    idGrupo INT(2) PRIMARY KEY NOT NULL,
    grupo INT(3) NOT NULL,
    idCarrera INT(2) NOT NULL,
    idSemestre INT(2) NOT NULL,
    FOREIGN KEY (idCarrera) REFERENCES Carrera(idCarrera),
    FOREIGN KEY (idSemestre) REFERENCES Semestre(idSemestre)
);

-- Crear la tabla Direccion
CREATE TABLE Direccion (
    idDireccion INT(2) PRIMARY KEY NOT NULL,
    idCodigoPostal INT(3) NOT NULL,
    calle VARCHAR(45) NOT NULL,
    colonia VARCHAR(45) NOT NULL,
    municipio VARCHAR(45) NOT NULL,
    FOREIGN KEY (idCodigoPostal) REFERENCES CodigoPostal(idCodigoPostal)
);


-- Creación de la tabla Genero
CREATE TABLE Genero (
    idGenero INT PRIMARY KEY NOT NULL,
    nombreGenero VARCHAR(20) NOT NULL
);


-- Crear la tabla Area
CREATE TABLE Area (
    idArea INT(2) PRIMARY KEY NOT NULL,
    nombreArea VARCHAR(45) NOT NULL
);

-- Crear la tabla Alumno
CREATE TABLE Alumno (
    idAlumno INT(2) PRIMARY KEY NOT NULL,
    nombreCompleto VARCHAR(100) NOT NULL,
    idGenero INT NOT NULL,
    edad INT(2) NOT NULL,
    fechaNacimiento DATE NOT NULL,
    CURP VARCHAR(18) NOT NULL,
    telefono BIGINT(10) NOT NULL,
    correo VARCHAR(45) NOT NULL,
    enfermedadCronica BOOLEAN NOT NULL,
    idGrupo INT(2) NOT NULL,
    idDireccion INT(2) NOT NULL,
    idEscuelaProcedencia INT(2) NOT NULL,
    FOREIGN KEY (idGrupo) REFERENCES Grupo(idGrupo),
    FOREIGN KEY (idDireccion) REFERENCES Direccion(idDireccion),
    FOREIGN KEY (idEscuelaProcedencia) REFERENCES EscuelaProcedencia(idEscuelaProcedencia),
    FOREIGN KEY (idGenero) REFERENCES Genero(idGenero)
);

-- Crear la tabla Alergias
CREATE TABLE Alergias (
    idAlergias INT(2) PRIMARY KEY NOT NULL,
    alergia VARCHAR(45) NOT NULL,
    idAlumno INT(2) NOT NULL,
    FOREIGN KEY (idAlumno) REFERENCES Alumno(idAlumno)
);


-- Crear la tabla Adeudo
CREATE TABLE Adeudo (
    idAdeudo INT(2) PRIMARY KEY NOT NULL,
    articuloAdeudo VARCHAR(45) NOT NULL,
    descripcion VARCHAR(45) NOT NULL,
    fechaSolicitud DATE NOT NULL,
    idAlumno INT(2) NOT NULL,
    idArea INT(2) NOT NULL,
    FOREIGN KEY (idAlumno) REFERENCES Alumno(idAlumno),
    FOREIGN KEY (idArea) REFERENCES Area(idArea)
);

-- Crear la tabla Materia
CREATE TABLE Materia (
    idMateria INT(2) PRIMARY KEY NOT NULL,
    nombreMateria VARCHAR(75) NOT NULL,
    idGrupo INT(2) NOT NULL,
    FOREIGN KEY (idGrupo) REFERENCES Grupo(idGrupo)
);

-- Crear tabla inscripciones
CREATE TABLE inscripcion(
    idInscripcion INT auto_increment PRIMARY KEY NOT NULL,
    fecha DATE,
    idAlumno INT NOT NULL,
    FOREIGN KEY (idAlumno) REFERENCES Alumno(idAlumno)
);


-- Crear la tabla Reinscripcion
CREATE TABLE Reinscripcion (
    idReinscripcion INT(2) PRIMARY KEY NOT NULL,
    fecha DATE NOT NULL,
    semestre INT(2) NOT NULL,
    Regular BOOLEAN NOT NULL,
    idAlumno INT(2) NOT NULL,
    FOREIGN KEY (idAlumno) REFERENCES Alumno(idAlumno)
);


-- Crear la tabla Boleta
CREATE TABLE Boleta (
    idBoleta INT(2) PRIMARY KEY NOT NULL,
    idAlumno INT(2) NOT NULL,
    idSemestre int(2) NOT NULL,
    FOREIGN KEY (idSemestre) REFERENCES Semestre(idSemestre),
    FOREIGN KEY (idAlumno) REFERENCES Alumno(idAlumno)
);



-- Crear la tabla calificaciones
CREATE TABLE Calificaciones(
    idCalificaciones int(2) PRIMARY KEY NOT NULL,
    calificacion DECIMAL(4,2) NOT NULL,
    idBoleta int(2) NOT NULL,
    idMateria int(4) NOT NULL,
    FOREIGN KEY (idBoleta) REFERENCES Boleta(idBoleta),
    FOREIGN KEY (idMateria) REFERENCES Materia(idMateria)
);


-- triggers

DELIMITER //
CREATE TRIGGER agregarInscripcion
AFTER insert ON alumno
FOR EACH ROW
BEGIN
    DECLARE semestreNuevo varchar(20);
    
	-- Obtener el nuevo semestre del alumno
    SELECT nombreSemestre INTO semestreNuevo
    FROM Alumno
    JOIN Grupo ON alumno.idGrupo = Grupo.idGrupo
    JOIN semestre ON grupo.idSemestre = semestre.idSemestre
    WHERE grupo.idGrupo = NEW.idGrupo;
    
    
	-- Insertar en reinscripciones si cambia de semestre 1 a semestre 2
    IF semestreNuevo = 'Primero' THEN
        INSERT INTO inscripcion (idInscripcion, fecha, idAlumno) VALUES (0,CURDATE(),NEW.idAlumno);
    END IF;
    
END;
//


/*

DELIMITER //

CREATE TRIGGER agregaReinscripcion
AFTER UPDATE ON alumno
FOR EACH ROW
BEGIN
    IF NEW.semestre = 2 AND OLD.semestre = 1 THEN
        INSERT INTO reinscripciones (idAlumno, semestre) VALUES (NEW.idAlumno, 2);
    END IF;
END;
//

CREATE TRIGGER eliminaInscripcion
AFTER UPDATE ON alumno
FOR EACH ROW
BEGIN
    IF NEW.semestre = 2 AND OLD.semestre = 1 THEN
        DELETE FROM inscripciones WHERE idAlumno = NEW.idAlumno;
    END IF;
END;
//
*/

-- INSERCIONES
INSERT INTO Carrera (idCarrera, nombreCarrera) VALUES
(1, 'Ingeniería Forestal'),
(2, 'Licenciatura en Ciencias Ambientales'),
(3, 'Licenciatura en Informática'),
(4, 'Licenciatura en Biología'),
(5, 'Ingeniería en Tecnología de la Madera'),
(6, 'Licenciatura en Administración Turística');



INSERT INTO Semestre (idSemestre, nombreSemestre) VALUES
(1, 'Primero'),
(2, 'Segundo'),
(3, 'Tercero'),
(4, 'Cuarto'),
(5, 'Quinto'),
(6, 'Sexto'),
(7, 'Séptimo'),
(8, 'Octavo'),
(9, 'Noveno'),
(10, 'Décimo');


INSERT INTO Pais (idPais, nombrePais) VALUES
(1, 'México'),
(2, 'Argentina'),
(3, 'Colombia');


INSERT INTO Estado (idEstado, nombreEstado, idPais) VALUES
(1, 'Ciudad de México', 1),
(2, 'Jalisco', 1),
(3, 'Nuevo León', 1),
(4, 'Oaxaca', 1),
(5, 'Yucatán', 1),
(6, 'Querétaro', 1),
(7, 'Buenos Aires', 2),
(8, 'Córdoba', 2),
(9, 'Mendoza', 2),
(10, 'Santa Fe', 2),
(11, 'Tucumán', 2),
(12, 'Salta', 2),
(13, 'Bogotá', 3),
(14, 'Antioquia', 3),
(15, 'Valle del Cauca', 3),
(16, 'Atlántico', 3),
(17, 'Santander', 3),
(18, 'Cundinamarca', 3);



INSERT INTO Ciudad (idCiudad, nombreCiudad, idEstado) VALUES
(1, 'Ciudad de México', 1),
(2, 'Guadalajara', 2),
(3, 'Monterrey', 3),
(4, 'Oaxaca de Juárez', 4),
(5, 'Mérida', 5),
(6, 'Querétaro', 6),
(7, 'Puebla', 1),
(8, 'Cancún', 5),
(9, 'Buenos Aires', 7),
(10, 'Córdoba', 8),
(11, 'Bogotá', 13),
(12, 'Medellín', 14);

INSERT INTO CodigoPostal (idCodigoPostal, numeroCodigo, idCiudad) VALUES
(1, 10000, 1), 
(2, 44620, 2), 
(3, 64000, 3), 
(4, 68000, 4), 
(5, 97000, 5),  
(6, 76000, 6),  
(7, 72000, 7),  
(8, 77500, 8), 
(9, 1000, 9), 
(10, 5000, 10), 
(11, 11001, 11),
(12, 5001, 12);


INSERT INTO Tutor (idTutor, nombreTutor, numeroTutor, direccionTutor) VALUES
(1, 'Juan Pérez', 1234567890, 'Calle Principal #123'),
(2, 'María García', 9876543210, 'Avenida Central #456'),
(3, 'Luis Rodríguez', 5551112233, 'Calle Secundaria #789'),
(4, 'Ana Martínez', 7778889990, 'Boulevard Norte #321'),
(5, 'Carlos López', 4443332221, 'Callejón Este #654'),
(6, 'Laura Hernández', 9990001112, 'Avenida Sur #987'),
(7, 'Pedro González', 8887776665, 'Ruta Oeste #234'),
(8, 'Sofía Díaz', 2223334447, 'Camino Lateral #567'),
(9, 'Javier Sánchez', 6665554448, 'Pasaje Tranquilo #876'),
(10, 'Mariana Ramírez', 1112223339, 'Carretera Principal #135'),
(11, 'Diego Torres', 3332221110, 'Avenida Grande #246'),
(12, 'Paula Flores', 9998887776, 'Bulevar Ocaso #579'),
(13, 'Gabriel Vargas', 7778889993, 'Calle Pequeña #357'),
(14, 'Valentina Cruz', 8889990004, 'Paseo Luminoso #579'),
(15, 'Emilio Aguilar', 4445556665, 'Ronda Central #234'),
(16, 'Camila Ortiz', 6667778886, 'Pasaje Brillante #951'),
(17, 'Ricardo Mendoza', 5554443337, 'Callejón del Sol #246'),
(18, 'Fernanda Castro', 2221110008, 'Avenida Ancha #753'),
(19, 'Pablo Núñez', 1110002229, 'Calle Estrecha #468'),
(20, 'Adriana Silva', 3334445550, 'Bulevar Norte #159'),
(21, 'Héctor Guzmán', 8887776661, 'Avenida del Río #582'),
(22, 'Lucía Velázquez', 9998887772, 'Camino Angosto #793'),
(23, 'Alejandro Reyes', 6665554443, 'Calle Principal #246'),
(24, 'Patricia Morales', 1112223334, 'Boulevard Central #579'),
(25, 'Isaac Jiménez', 3332221115, 'Avenida Luminosa #234'),
(26, 'Elena Aguilar', 5556667776, 'Paseo Principal #951');


INSERT INTO EscuelaProcedencia (idEscuelaProcedencia, escuelaProcedencia, direccionEscuela) VALUES
(1, 'Escuela Secundaria Independencia', 'Direccion #1'),
(2, 'Colegio Juana de Arco', 'Direccion #2'),
(3, 'Instituto Benito Juárez', 'Direccion #3'),
(4, 'Preparatoria Miguel Hidalgo', 'Direccion #4');


INSERT INTO Direccion (idDireccion, idCodigoPostal, calle, colonia, municipio) VALUES
(1, 1, 'Avenida de la Revolución', 'Centro', 'Ciudad de México'),
(2, 5, 'Calle Juárez', 'Del Valle', 'Guadalajara'),
(3, 10, 'Avenida Principal', 'Centro', 'Monterrey'),
(4, 2, 'Calle Morelos', 'Centro', 'Buenos Aires'),
(5, 11, 'Avenida Libertador', 'Norte', 'Bogotá'),
(6, 9, 'Calle Hidalgo', 'Centro', 'Puebla');



INSERT INTO Area (idArea, nombreArea) VALUES
(1, 'BIBLIOTECA'),
(2, 'SALA DE COMPUTO'),
(3, 'DEPARTAMENTO DE RECURSOS FINANCIEROS'),
(4, 'LABORATORIO DE ELECTRÓNICA'),
(5, 'LABORATORIO QUÍMICO-BIOLÓGICO'),
(6, 'LABORATORIO DE ANÁLISIS AMBIENTAL');


-- Inserciones en Grupo para todas las carreras
INSERT INTO Grupo (idGrupo, grupo, idCarrera, idSemestre)
VALUES

    (1, 101, 1, 1),
    (2, 201, 1, 2),
    (3, 301, 1, 3),
    (4, 401, 1, 4),
    (5, 501, 1, 5),
    (6, 601, 1, 6),
    (7, 701, 1, 7),
    (8, 801, 1, 8),
    (9, 901, 1, 9),
    (10, 1001, 1, 10),
    (11, 102, 2, 1),
    (12, 202, 2, 2),
    (13, 302, 2, 3),
    (14, 402, 2, 4),
    (15, 502, 2, 5),
    (16, 602, 2, 6),
    (17, 702, 2, 7),
    (18, 802, 2, 8),
    (19, 902, 2, 9),
    (20, 1002, 2, 10),
    (21, 103, 3, 1),
    (22, 203, 3, 2),
    (23, 303, 3, 3),
    (24, 403, 3, 4),
    (25, 503, 3, 5),
    (26, 603, 3, 6),
    (27, 703, 3, 7),
    (28, 803, 3, 8),
    (29, 903, 3, 9),
    (30, 1003, 3, 10),
    (31, 104, 4, 1),
    (32, 204, 4, 2),
    (33, 304, 4, 3),
    (34, 404, 4, 4),
    (35, 504, 4, 5),
    (36, 604, 4, 6),
    (37, 704, 4, 7),
    (38, 804, 4, 8),
    (39, 904, 4, 9),
    (40, 1004, 4, 10),
    (41, 105, 5, 1),
    (42, 205, 5, 2),
    (43, 305, 5, 3),
    (44, 405, 5, 4),
    (45, 505, 5, 5),
    (46, 605, 5, 6),
    (47, 705, 5, 7),
    (48, 805, 5, 8),
    (49, 905, 5, 9),
    (50, 1005, 5, 10),
    (51, 106, 6, 1),
    (52, 206, 6, 2),
    (53, 306, 6, 3),
    (54, 406, 6, 4),
    (55, 506, 6, 5),
    (56, 606, 6, 6),
    (57, 706, 6, 7),
    (58, 806, 6, 8),
    (59, 906, 6, 9),
    (60, 1006, 6, 10);


INSERT INTO Genero (idGenero, nombreGenero) VALUES 
    (1, 'Hombre'), 
    (2, 'Mujer');



INSERT INTO Alumno (idAlumno, nombreCompleto, idGenero, edad, fechaNacimiento, CURP, telefono, correo, enfermedadCronica, idGrupo, idDireccion, idEscuelaProcedencia)
VALUES
(1, 'Juan Pérez', 1, 20, '2003-04-10', 'PERJ930410HMCLNR02', 5551234567, 'juanperez@example.com', 0, 5, 3, 1),
(2, 'María García', 2, 22, '2001-07-15', 'GARM010715MCLNR06', 5559876543, 'mariagarcia@example.com', 1, 12, 6, 2),
(3, 'Luis Rodríguez', 1, 21, '2002-02-28', 'RODL020228HMCLNS03', 5551112222, 'luisrodriguez@example.com', 0, 28, 5, 3),
(4, 'Ana Martínez', 2, 23, '1999-11-20', 'MATA991120HMCLNN01', 5553334444, 'anamartinez@example.com', 0, 13, 1, 4),
(5, 'Carlos López', 1, 19, '2004-09-05', 'LOPC040905HMCLRC09', 5555556666, 'carloslopez@example.com', 1, 9, 4, 1),
(6, 'Laura Hernández', 2, 20, '2002-06-18', 'HERL020618MCLRR04', 5557778888, 'laurahernandez@example.com', 0, 20, 2, 2),
(7, 'Pedro González', 1, 21, '2001-12-12', 'GONP011212HMCLZR07', 5559990000, 'pedrogonzalez@example.com', 0, 41, 6, 3),
(8, 'Sofía Díaz', 2, 22, '2000-03-25', 'DIAS000325MCLSF05', 5552223333, 'sofiadiaz@example.com', 0, 25, 3, 2),
(9, 'Javier Sánchez', 1, 20, '2003-08-30', 'SANJ030830HMCLVR08', 5554445555, 'javiersanchez@example.com', 0, 15, 5, 1),
(10, 'Mariana Ramírez', 2, 21, '2001-05-12', 'RAMM010512MCLNR01', 5556667777, 'marianaramirez@example.com', 1, 6, 2, 3);


INSERT INTO Alergias (idAlergias, alergia, idAlumno) VALUES
(1, 'Polen', 1),
(2, 'Maní', 2),
(3, 'Mariscos', 3),
(4, 'Lácteos', 3),
(5, 'Pólenes', 7),
(6, 'Nueces', 7),
(7, 'Cacahuetes', 7),
(8, 'Mariscos', 8),
(9, 'Gluten', 10),
(10, 'Polen', 10),
(11, 'Lácteos', 2);



INSERT INTO Adeudo (idAdeudo, articuloAdeudo, descripcion, fechaSolicitud, idAlumno, idArea) VALUES
(1, 'Libro de Matemáticas', 'Préstamo de libro', '2023-11-12', 1, 1),
(2, 'Equipo de Computadora', 'Uso de computadora', '2023-11-13', 1, 2),
(3, 'Microscopio', 'Uso de equipo de laboratorio', '2023-11-14', 1, 5),
(4, 'Cámara', 'Préstamo de cámara', '2023-11-15', 3, 4),
(5, 'Laptop', 'Uso de computadora', '2023-11-16', 3, 2),
(6, 'Reactivos Químicos', 'Uso de materiales de laboratorio', '2023-11-17', 4, 5),
(7, 'Impresora', 'Uso de equipo de impresión', '2023-11-18', 4, 2),
(8, 'Libro de Historia', 'Préstamo de libro', '2023-11-19', 5, 1),
(9, 'Equipo de Análisis Ambiental', 'Uso de equipo de laboratorio', '2023-11-20', 5, 6),
(10, 'Microscopio', 'Uso de equipo de laboratorio', '2023-11-21', 7, 5),
(11, 'Equipo de Análisis Financiero', 'Uso de equipo', '2023-11-22', 7, 3),
(12, 'Libro de Biología', 'Préstamo de libro', '2023-11-23', 8, 1);



-- Inserciones en Materia para Ingeniería Forestal
INSERT INTO Materia (idMateria, nombreMateria, idGrupo)
VALUES
    -- Primer Semestre
    (1, 'Matemáticas I', 1),
    (2, 'Química Inorgánica', 1),
    (3, 'Historia del Pensamiento Filosófico', 1),
    (4, 'Biología', 1),
    (5, 'Física', 1),
    -- Segundo Semestre
    (6, 'Matemáticas II', 2),
    (7, 'Química Orgánica', 2),
    (8, 'Teoría General de Sistemas', 2),
    (9, 'Ecología', 2),
    (10, 'Introducción a la Economía', 2),
    -- Tercer Semestre
    (11, 'Métodos Estadísticos', 3),
    (12, 'Bioquímica', 3),
    (13, 'Dendrometría', 3),
    (14, 'Botánica', 3),
    (15, 'Economía de los Recursos Naturales', 3),
    -- Cuarto Semestre
    (16, 'Fisiología Vegetal', 4),
    (17, 'Edafología', 4),
    (18, 'Epidometría', 4),
    (19, 'Botánica Forestal', 4),
    (20, 'Ecosistemas Forestales', 4),
    -- Quinto Semestre
    (21, 'Muestreo e Inventario Forestal', 5),
    (22, 'Conservación y Manejo de Suelos Forestal', 5),
    (23, 'Silvicultura de Bosques Templados', 5),
    (24, 'Legislación Forestal', 5),
    (25, 'Topografía y Fotogrametría', 5),
    -- Sexto Semestre
    (26, 'Sistemas de Información Geográfica', 6),
    (27, 'Genética', 6),
    (28, 'Silvicultura Tropical', 6),
    (29, 'Anatomía y Tecnología de la Madera', 6),
    (30, 'Viveros Forestales', 6),
    -- Séptimo Semestre
    (31, 'Manejo Integral de los Recursos Forestales I', 7),
    (32, 'Métodos de Mejoramiento Genético Forestal', 7),
    (33, 'Administración de Empresas Forestales', 7),
    (34, 'Industrias Forestales', 7),
    (35, 'Operaciones Forestales', 7),
    -- Octavo Semestre
    (36, 'Manejo Integral de los Recursos Forestales II', 8),
    (37, 'Evaluación de Impacto Ambiental', 8),
    (38, 'Manejo de Fauna Silvestre', 8),
    (39, 'Formulación y Evaluación de Proyectos', 8),
    (40, 'Plantaciones Forestales Comerciales', 8),
    -- Noveno Semestre
    (41, 'Sistemas Agroforestales', 9),
    (42, 'Manejo de Cuencas Hidrográficas', 9),
    (43, 'Metodología de la Investigación', 9),
    (44, 'Recreación y Ecoturismo', 9),
    (45, 'Optativa I', 9),
    -- Décimo Semestre
    (46, 'Productos Forestales No Maderables', 10),
    (47, 'Desarrollo Rural Forestal', 10),
    (48, 'Seminario de Tesis', 10),
    (49, 'Protección Forestal', 10),
    (50, 'Optativa II', 10);


-- Inserciones en Materia para Licenciatura en Ciencias Ambientales
INSERT INTO Materia (idMateria, nombreMateria, idGrupo)
VALUES
    -- Primer Semestre
    (51, 'Matemáticas I', 11),
    (52, 'Química Inorgánica', 11),
    (53, 'Física', 11),
    (54, 'Biología', 11),
    (55, 'Historia del Pensamiento Filosófico', 11),
    -- Segundo Semestre
    (56, 'Matemáticas II', 12),
    (57, 'Estadística', 12),
    (58, 'Química Orgánica', 12),
    (59, 'Teoría General de Sistemas', 12),
    (60, 'Introducción al Estudio del Medio Ambiente', 12),
    -- Tercer Semestre
    (61, 'Fisicoquímica', 13),
    (62, 'Bioquímica', 13),
    (63, 'Química Ambiental', 13),
    (64, 'Botánica', 13),
    (65, 'Ecología', 13),
    -- Cuarto Semestre
    (66, 'Contaminación Ambiental', 14),
    (67, 'Microbiología', 14),
    (68, 'Ecología del Paisaje', 14),
    (69, 'Fisiología Vegetal', 14),
    (70, 'Sociedad y Naturaleza', 14),
    -- Quinto Semestre
    (71, 'Economía de los Recursos Naturales', 15),
    (72, 'Dinámica de Xenobióticos en el Ambiente', 15),
    (73, 'Geología', 15),
    (74, 'Restauración Ecológica', 15),
    (75, 'Desarrollo Sostenible', 15),
    -- Sexto Semestre
    (76, 'Economía Ecológica', 16),
    (77, 'Legislación Ambiental', 16),
    (78, 'Edafología', 16),
    (79, 'Sistemas de Información Geográfica', 16),
    (80, 'Ética Ambiental', 16),
    -- Séptimo Semestre
    (81, 'Hidrología', 17),
    (82, 'Bases de la Ingeniería Ambiental', 17),
    (83, 'Gestión de Residuos Sólidos', 17),
    (84, 'Conflictos Socioambientales', 17),
    (85, 'Administración', 17),
    -- Octavo Semestre
    (86, 'Impacto Ambiental', 18),
    (87, 'Operaciones Básicas en Ingeniería Ambiental', 18),
    (88, 'Toxicología Ambiental', 18),
    (89, 'Ordenamiento Ecológico', 18),
    (90, 'Formulación y Evaluación de Proyectos', 18),
    -- Noveno Semestre
    (91, 'Biotecnología Ambiental', 19),
    (92, 'Tecnologías del Tratamiento de Aguas', 19),
    (93, 'Cambio Climático', 19),
    (94, 'Seminario de Tesis I', 19),
    (95, 'Optativa I', 19),
    -- Décimo Semestre
    (96, 'Gestión Energética', 20),
    (97, 'Auditorias Ambientales', 20),
    (98, 'Remediación de Suelos Contaminados', 20),
    (99, 'Seminario de Tesis II', 20),
    (100, 'Optativa II', 20);

-- Inserciones en Materia para Licenciatura en Informática
INSERT INTO Materia (idMateria, nombreMateria, idGrupo)
VALUES
    -- Primer Semestre
    (101, 'Diseño Estructurado de Algoritmos', 21),
    (102, 'Administración', 21),
    (103, 'Lógica Matemática', 21),
    (104, 'Historia del Pensamiento Filosófico', 21),
    (105, 'Matemáticas I', 21),
    -- Segundo Semestre
    (106, 'Programación Estructurada', 22),
    (107, 'Electrónica I', 22),
    (108, 'Matemáticas Discretas', 22),
    (109, 'Teoría General de Sistemas', 22),
    (110, 'Matemáticas II', 22),
    -- Tercer Semestre
    (111, 'Estructuras de Datos', 23),
    (112, 'Electrónica II', 23),
    (113, 'Derecho y Legislación en Informática', 23),
    (114, 'Contabilidad', 23),
    (115, 'Álgebra Lineal', 23),
    -- Cuarto Semestre
    (116, 'Paradigmas de Programación I', 24),
    (117, 'Diseño Web', 24),
    (118, 'Bases de Datos I', 24),
    (119, 'Programación de Sistemas', 24),
    (120, 'Métodos Numéricos', 24),
    -- Quinto Semestre
    (121, 'Paradigmas de Programación II', 25),
    (122, 'Ingeniería de Software I', 25),
    (123, 'Bases de Datos II', 25),
    (124, 'Arquitectura de Computadoras', 25),
    (125, 'Redes I', 25),
    -- Sexto Semestre
    (126, 'Tecnologías Web I', 26),
    (127, 'Ingeniería de Software II', 26),
    (128, 'Programación Visual', 26),
    (129, 'Sistemas Operativos I', 26),
    (130, 'Redes II', 26),
    -- Séptimo Semestre
    (131, 'Tecnologías Web II', 27),
    (132, 'Proyectos de Tecnologías de Información', 27),
    (133, 'Bases de Datos Distribuidas', 27),
    (134, 'Sistemas Operativos II', 27),
    (135, 'Estadística', 27),
    -- Octavo Semestre
    (136, 'Sistemas Distribuidos', 28),
    (137, 'Calidad de Software', 28),
    (138, 'Interacción Humano – Computadora', 28),
    (139, 'Organización de Centros de Informática', 28),
    (140, 'Investigación de Operaciones', 28),
    -- Noveno Semestre
    (141, 'Metodología de la Investigación', 29),
    (142, 'Seguridad de Centros de Informática', 29),
    (143, 'Teoría de Algoritmos', 29),
    (144, 'Optativa 1', 29),
    (145, 'Optativa 2', 29),
    -- Décimo Semestre
    (146, 'Seminario de Tesis', 30),
    (147, 'Auditoría de Sistemas', 30),
    (148, 'Función Informática', 30),
    (149, 'Optativa 3', 30),
    (150, 'Optativa 4', 30);

-- Inserciones en Materia para Licenciatura en Biología
INSERT INTO Materia (idMateria, nombreMateria, idGrupo)
VALUES
    -- Primer Semestre
    (151, 'Elementos de Matemáticas', 31),
    (152, 'Física', 31),
    (153, 'Química Inorgánica', 31),
    (154, 'Introducción a la Biología', 31),
    (155, 'Historia del Pensamiento Filosófico', 31),
    -- Segundo Semestre
    (156, 'Cálculo Diferencial e Integral', 32),
    (157, 'Fisicoquímica', 32),
    (158, 'Biología Celular', 32),
    (159, 'Química Orgánica', 32),
    (160, 'Teoría General de Sistemas', 32),
    -- Tercer Semestre
    (161, 'Estadística', 33),
    (162, 'Embriología Animal', 33),
    (163, 'Bioquímica', 33),
    (164, 'Biología de Procariotas y Virus', 33),
    (165, 'Procesos Dinámicos de la Tierra', 33),
    -- Cuarto Semestre
    (166, 'Métodos Estadísticos', 34),
    (167, 'Anatomía Animal Comparada', 34),
    (168, 'Biología Molecular', 34),
    (169, 'Biología de Protozoa y Chromista', 34),
    (170, 'Meteorología y Climatología', 34),
    -- Quinto Semestre
    (171, 'Biología de Invertebrados I', 35),
    (172, 'Histología Animal', 35),
    (173, 'Genética', 35),
    (174, 'Biología de Briofitas a Gimnospermas', 35),
    (175, 'Biología de Hongos', 35),
    -- Sexto Semestre
    (176, 'Biología de Invertebrados II', 36),
    (177, 'Fisiología Animal', 36),
    (178, 'Sistemas de Información Geográfica', 36),
    (179, 'Biología de Angiospermas', 36),
    (180, 'Evolución', 36),
    -- Séptimo Semestre
    (181, 'Biología de Cordados', 37),
    (182, 'Ética y Valores en la Biología', 37),
    (183, 'Fisiología Vegetal', 37),
    (184, 'Ecología Básica y de Poblaciones', 37),
    (185, 'Sistemática', 37),
    -- Octavo Semestre
    (186, 'Manejo y Conservación de los Recursos Naturales', 38),
    (187, 'Legislación Ambiental', 38),
    (188, 'Biogeografía', 38),
    (189, 'Ecología de Comunidades y Ecosistemas', 38),
    (190, 'Paleobiología', 38),
    -- Noveno Semestre
    (191, 'Investigación en Biología', 39),
    (192, 'Gestión Ambiental y Formulación de Proyectos', 39),
    (193, 'Temas Selectos de Recursos Naturales I', 39),
    (194, 'Temas Selectos Biotecnología I', 39),
    (195, 'Temas Selectos de Biodiversidad I', 39),
    -- Décimo Semestre
    (196, 'Seminario de Tesis II', 40),
    (197, 'Economía Ecológica', 40),
    (198, 'Temas Selectos de Recursos Naturales II', 40),
    (199, 'Temas Selectos Biotecnología II', 40),
    (200, 'Temas Selectos de Biodiversidad II', 40);

-- Inserciones en Materia para Ingeniería en Tecnología de la Madera
INSERT INTO Materia (idMateria, nombreMateria, idGrupo)
VALUES
    -- Primer Semestre
    (201, 'Matemáticas I', 41),
    (202, 'Química I', 41),
    (203, 'Física I', 41),
    (204, 'Biología', 41),
    (205, 'Historia del Pensamiento Filosófico', 41),
    -- Segundo Semestre
    (206, 'Matemáticas II', 42),
    (207, 'Química II', 42),
    (208, 'Física II', 42),
    (209, 'Introducción a la Teoría General de Sistemas', 42),
    (210, 'Fundamentos de la Tecnología de la Madera', 42),
    -- Tercer Semestre
    (211, 'Procesamiento Primario de la Madera', 43),
    (212, 'Botánica', 43),
    (213, 'Bioquímica', 43),
    (214, 'Dendrología', 43),
    (215, 'Estadística', 43),
    -- Cuarto Semestre
    (216, 'Introducción a la Economía', 44),
    (217, 'Anatomía de la Madera I', 44),
    (218, 'Física de la Madera', 44),
    (219, 'Fisiología Vegetal', 44),
    (220, 'Tecnología de Herramientas y Maquinaria I', 44),
    -- Quinto Semestre
    (221, 'Economía de los Recursos Naturales', 45),
    (222, 'Anatomía de la Madera II', 45),
    (223, 'Tecnología de Herramientas y Maquinaria II', 45),
    (224, 'Química de la Madera', 45),
    (225, 'Administración', 45),
    (226, 'Métodos Numéricos', 45),
    -- Sexto Semestre
    (227, 'Administración de Empresas Forestales I', 46),
    (228, 'Mecánica de la Madera', 46),
    (229, 'Economía Forestal', 46),
    (230, 'Industrias Forestales I', 46),
    (231, 'Operaciones Unitarias I', 46),
    (232, 'Estática', 46),
    -- Séptimo Semestre
    (233, 'Administración de Empresas Forestales II', 47),
    (234, 'Industrias Forestales II', 47),
    (235, 'Investigación de Operaciones I', 47),
    (236, 'Diseño y Desarrollo de Productos y Estructuras I', 47),
    (237, 'Operaciones Unitarias II', 47),
    (238, 'Manejo de Materiales', 47),
    -- Octavo Semestre
    (239, 'Formulación y Evaluación de Proyectos Productivos', 48),
    (240, 'Investigación de Operaciones II', 48),
    (241, 'Diseño y Desarrollo de Productos y Estructuras II', 48),
    (242, 'Secado de la Madera I', 48),
    (243, 'Tableros y Laminado', 48),
    (244, 'Optativa I', 48),
    -- Noveno Semestre
    (245, 'Mercadeo y Vías de Comercialización de Productos Maderables y no Maderables', 49),
    (246, 'Secado de la Madera II', 49),
    (247, 'Preservación de la Madera I', 49),
    (248, 'Celulosa y Papel', 49),
    (249, 'Seminario de Tesis I', 49),
    (250, 'Optativa II', 49),
    -- Décimo Semestre
    (251, 'Preservación de la Madera II', 50),
    (252, 'Productos Extraíbles de la Madera', 50),
    (253, 'Manejo de Calidad Total', 50),
    (254, 'Seminario de Tesis II', 50),
    (255, 'Optativa III', 50);

-- Inserciones en Materia para Licenciatura en Administración Turística
INSERT INTO Materia (idMateria, nombreMateria, idGrupo)
VALUES
    -- Primer Semestre
    (256, 'Computación I', 51),
    (257, 'Matemáticas Financieras', 51),
    (258, 'Proceso Administrativo', 51),
    (259, 'Metodología de la Investigación', 51),
    (260, 'Historia del Pensamiento Filosófico', 51),
    -- Segundo Semestre
    (261, 'Geografía', 52),
    (262, 'Computación II', 52),
    (263, 'Estadística', 52),
    (264, 'Administración de Personal', 52),
    (265, 'Teoría General de Sistemas', 52),
    -- Tercer Semestre
    (266, 'Geografía Turística', 53),
    (267, 'Economía General', 53),
    (268, 'Contabilidad General', 53),
    (269, 'Administración Hotelera I', 53),
    (270, 'Derecho', 53),
    -- Cuarto Semestre
    (271, 'Turismo I', 54),
    (272, 'Economía Turística', 54),
    (273, 'Contabilidad Aplicada', 54),
    (274, 'Administración Hotelera II', 54),
    (275, 'Legislación Turística', 54),
    -- Quinto Semestre
    (276, 'Turismo II', 55),
    (277, 'Sociología', 55),
    (278, 'Costos', 55),
    (279, 'Mercadotecnia General', 55),
    (280, 'Historia de la Cultura', 55),
    -- Sexto Semestre
    (281, 'Administración de Empresas de Alimentos y Bebidas I', 56),
    (282, 'Sociología del Turismo', 56),
    (283, 'Finanzas Turísticas', 56),
    (284, 'Mercadotecnia Turística', 56),
    (285, 'Patrimonio', 56),
    -- Séptimo Semestre
    (286, 'Administración de Empresas de Alimentos y Bebidas II', 57),
    (287, 'Psicología Turística', 57),
    (288, 'Administración de Agencias de Viajes y Líneas de Transportación', 57),
    (289, 'Planeación Turística', 57),
    (290, 'Turismo Cultural', 57),
    -- Octavo Semestre
    (291, 'Enología', 58),
    (292, 'Recreación Turística', 58),
    (293, 'Servicios Complementarios', 58),
    (294, 'Calidad en los Servicios Turísticos', 58),
    (295, 'Historia del Arte en México', 58),
    -- Noveno Semestre
    (296, 'Seminario de Tesis I', 59),
    (297, 'Turismo y Sustentabilidad', 59),
    (298, 'Formulación y Evaluación de Proyectos', 59),
    (299, 'Mercados Mundiales del Turismo', 59),
    -- Décimo Semestre
    (300, 'Seminario de Tesis II', 60),
    (301, 'Turismo Alternativo', 60),
    (302, 'Formulación y Evaluación de Proyectos Turísticos', 60),
    (303, 'Estrategias Turísticas', 60);




INSERT INTO Reinscripcion (idReinscripcion, fecha, semestre, Regular, idAlumno) VALUES
(1, '2022-12-20', 2, 1, 1),
(2, '2023-6-21', 3, 1, 1),
(3, '2023-12-22', 4, 0, 1),

(4, '2021-12-21', 2, 1, 2),
(5, '2022-6-22', 3, 0, 2),
(6, '2022-12-23', 4, 1, 2),
(7, '2023-6-24', 5, 1, 2),
(8, '2023-12-25', 6, 0, 2),

(9, '2023-12-26', 2, 1, 3),

(10, '2021-12-27', 2, 0, 4),
(11, '2022-6-28', 3, 1, 4),
(12, '2022-12-29', 4, 1, 4),
(13, '2023-6-30', 5, 0, 4), 

(14, '2022-12-1', 2, 0, 8),
(15, '2023-6-2', 3, 1, 8),

(16, '2022-12-3', 2, 1, 9),
(17, '2023-6-4', 3, 0, 9),

(18, '2019-12-5', 2, 0, 10),
(19, '2020-6-6', 3, 1, 10),
(20, '2020-12-7', 4, 1, 10),
(21, '2021-6-8', 5, 0, 10),
(22, '2021-12-9', 6, 0, 10),
(23, '2022-6-10', 7, 1, 10),
(24, '2022-12-11', 8, 1, 10),
(25, '2023-6-12', 9, 0, 10);


INSERT INTO Boleta (idBoleta, idAlumno,idSemestre) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),

(4, 2, 1),
(5, 2, 2),

(6, 3, 1),
(7, 3, 2),
(8, 3, 3),
(9, 3, 4),

(10, 4, 1),

(11, 5, 1),
(12, 5, 2),
(13, 5, 3),

(14, 6, 1),
(15, 6, 2),

(16, 7, 1),
(17, 7, 2),
(18, 7, 3),
(19, 7, 4),

(20, 8, 1),

(21, 9, 1),
(22, 9, 2),
(23, 9, 3),

(24, 10, 1),
(25, 10, 2);



-- Inserciones en Calificaciones para los alumnos especificados

INSERT INTO Calificaciones (idCalificaciones, calificacion, idBoleta, idMateria)
VALUES

 -- Juan Pérez (Ingeniería Forestal, Semestre 1)
    (1, 7.5, 1, 1),
    (2, 8.0, 1, 2),
    (3, 8.2, 1, 3),
    (4, 7.8, 1, 4),
    (5, 9.0, 1, 5),

 -- Juan Pérez (Ingeniería Forestal, Semestre 2)
    (6, 7.5, 2, 6),
    (7, 6.0, 2, 7),
    (8, 8.2, 2, 8),
    (9, 5.8, 2, 9),
    (10, 7.0, 2, 10),

    -- Juan Pérez (Ingeniería Forestal, Semestre 3)
    (11, 9.5, 3, 11),
    (12, 8.0, 3, 12),
    (13, 9.2, 3, 13),
    (14, 7.8, 3, 14),
    (15, 9.0, 3, 15),

-- María García (Ciencias Ambientales, Semestre 1)
    (16, 6.5, 4, 51),
    (17, 8.0, 4, 52),
    (18, 7.3, 4, 53),
    (19, 5.5, 4, 54),
    (20, 8.5, 4,55),

    -- María García (Ciencias Ambientales, Semestre 2)
    (21, 7.5, 5, 56),
    (22, 9.0, 5, 57),
    (23, 8.3, 5, 58),
    (24, 6.5, 5, 59),
    (25, 9.5, 5,60),

-- Luis Rodríguez (Licenciatura en Informática, Semestre 1)
    (26, 7.5, 6, 101),
    (27, 6.0, 6, 102),
    (28, 6.7, 6, 103),
    (29, 4.2, 6, 104),
    (30, 7.0, 6, 105),
    
-- Luis Rodríguez (Licenciatura en Informática, Semestre 2)
    (31, 8.5, 7, 106),
    (32, 7.0, 7, 107),
    (33, 7.7, 7, 108),
    (34, 6.2, 7, 109),
    (35, 8.0, 7, 110),

-- Luis Rodríguez (Licenciatura en Informática, Semestre 3)
    (36, 10.0, 8, 111),
    (37, 9.0, 8, 112),
    (38, 9.7, 8, 113),
    (39, 8.2, 8, 114),
    (40, 10.0, 8, 115),

    -- Luis Rodríguez (Licenciatura en Informática, Semestre 4)
    (41, 9.5, 9, 116),
    (42, 8.0, 9, 117),
    (43, 8.7, 9, 118),
    (44, 7.2, 9, 119),
    (45, 9.0, 9, 120),

    -- Ana Martínez (Biología, Semestre 1)
    (46, 8.0, 10, 151),
    (47, 9.3, 10, 152),
    (48, 8.5, 10, 153),
    (49, 7.8, 10, 154),
    (50, 9.7, 10, 155),

  -- Carlos López (Ingeniería Forestal, Semestre 1)
    (51, 6.5, 11, 1),
    (52, 8.0, 11, 2),
    (53, 7.3, 11, 3),
    (54, 5.5, 11, 4),
    (55, 8.5, 11, 5),

  -- Carlos López (Ingeniería Forestal, Semestre 2)
    (56, 8.5, 12, 6),
    (57, 10.0, 12, 7),
    (58, 9.3, 12, 8),
    (59, 7.5, 12, 9),
    (60, 10.0, 12, 10),

    -- Carlos López (Ingeniería Forestal, Semestre 3)
    (61, 7.5, 13, 11),
    (62, 9.0, 13, 12),
    (63, 8.3, 13, 13),
    (64, 6.5, 13, 14),
    (65, 9.5, 13, 15),

-- Laura Hernández (Ciencias Ambientales, Semestre 1)
    (66, 6.0, 14, 51),
    (67, 7.8, 14, 52),
    (68, 7.2, 14, 53),
    (69, 6.0, 14, 54),
    (70, 8.3, 14, 55),

    -- Laura Hernández (Ciencias Ambientales, Semestre 2)
    (71, 7.0, 15, 56),
    (72, 8.8, 15, 57),
    (73, 8.2, 15, 58),
    (74, 7.0, 15, 59),
    (75, 9.3, 15, 60),

-- Pedro González (Licenciatura en Informática, Semestre 1)
    (76, 7.5, 16, 101),
    (77, 6.0, 16, 102),
    (78, 6.7, 16, 103),
    (79, 5.2, 16, 104),
    (80, 7.0, 16, 105),

-- Pedro González (Licenciatura en Informática, Semestre 2)
    (81, 8.5, 17, 106),
    (82, 7.0, 17, 107),
    (83, 7.7, 17, 108),
    (84, 6.2, 17, 109),
    (85, 8.0, 17, 110),

-- Pedro González (Licenciatura en Informática, Semestre 3)
    (86, 10.0, 18, 111),
    (87, 9.0, 18, 112),
    (88, 9.7, 18, 113),
    (89, 8.2, 18, 114),
    (90, 10.0, 18, 115),

    -- Pedro González (Licenciatura en Informática, Semestre 4)
    (91, 9.5, 19, 116),
    (92, 8.0, 19, 117),
    (93, 8.7, 19, 118),
    (94, 7.2, 19, 119),
    (95, 9.0, 19, 120),

    -- Sofía Díaz (Biología, Semestre 1)
    (96, 8.0, 20, 151),
    (97, 9.3, 20, 152),
    (98, 8.5, 20, 153),
    (99, 7.8, 20, 154),
    (100, 9.7, 20, 155),

-- Javier Sánchez (Tecnología de la Madera, Semestre 1)
    (101, 8.8, 21, 201),
    (102, 9.2, 21, 202),
    (103, 8.5, 21, 203),
    (104, 7.5, 21, 204),
    (105, 9.0, 21, 205),

-- Javier Sánchez (Tecnología de la Madera, Semestre 2)
    (106, 8.8, 22, 206),
    (107, 9.2, 22, 207),
    (108, 8.5, 22, 208),
    (109, 7.5, 22, 209),
    (110, 9.0, 22, 210),
    
    -- Javier Sánchez (Tecnología de la Madera, Semestre 3)
    (111, 8.8, 23, 211),
    (112, 9.2, 23, 212),
    (113, 8.5, 23, 213),
    (114, 7.5, 23, 214),
    (115, 9.0, 23, 215),
    
-- Mariana Ramírez (Ciencias Ambientales, Semestre 1)
    (116, 6.5, 24, 51),
    (117, 7.9, 24, 52),
    (118, 7.2, 24, 53),
    (119, 8.0, 24, 54),
    (120, 6.5, 24, 55),

    -- Mariana Ramírez (Ciencias Ambientales, Semestre 2)
    (121, 7.5, 25, 56),
    (122, 8.9, 25, 57),
    (123, 8.2, 25, 58),
    (124, 7.0, 25, 59),
    (125, 9.5, 25, 60);

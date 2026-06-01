-- Tabla cursos
CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(75) NOT NULL
);

-- Tabla alumnos
CREATE TABLE alumnos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(75) NOT NULL,
    apellido VARCHAR(75) NOT NULL,
    id_curso INT REFERENCES cursos(id),
    fecha_nacimiento DATE,
    hace_deportes BOOLEAN
);

-- INSERTS PARA cursos
INSERT INTO cursos (nombre) VALUES ('5IA');
INSERT INTO cursos (nombre) VALUES ('5IB');
INSERT INTO cursos (nombre) VALUES ('5IC');
INSERT INTO cursos (nombre) VALUES ('5ID');
INSERT INTO cursos (nombre) VALUES ('5IE');

-- INSERTS PARA alumnos (generados desde alumnos.json)
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Federico', 'De La Puente Sztajer', 1, '2007-03-14', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Nicolas', 'Frenkel', 1, '2008-11-02', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Andres', 'Furland Otero', 1, '2007-06-21', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Brandon Ivan', 'Gaguine Alexandrovich', 1, '2008-08-09', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Luca', 'Gamas De Maio', 1, '2007-01-18', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Benjamin', 'Hamra Minian', 1, '2008-05-30', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Martina Sol', 'Korinfeld Asher', 1, '2007-09-11', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Eitan Uriel', 'Koze', 1, '2008-12-25', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Benjamin Esteban', 'Kracovitz', 1, '2007-04-07', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tomás Vinicio', 'Lopez', 1, '2008-09-13', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tomás', 'Mandelman', 1, '2007-07-19', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Joaquín', 'Medina', 1, '2008-02-03', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Nicolas Darren', 'Navarro Feinberg', 1, '2007-10-28', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Catalina Luján', 'Rodriguez Grosso', 1, '2008-06-15', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Lucas Ioel', 'Roitman', 1, '2007-05-08', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Martín', 'Saban', 1, '2008-03-27', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Florencia', 'Sirotinsky', 1, '2007-08-16', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Victoria', 'Tandeter', 1, '2008-10-05', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Elian', 'Ulman', 1, '2007-02-22', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Milena', 'Winer', 1, '2008-07-01', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Camila', 'Zielonka', 1, '2007-11-09', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Zoe', 'Acquistapace', 2, '2008-04-14', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Vitas', 'Alán', 2, '2007-06-02', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Felipe', 'Andraca', 2, '2008-09-18', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Felipe', 'Beckford', 2, '2007-01-11', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ilán', 'Bleicher', 2, '2008-12-07', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Facundo', 'Cardoso Peri', 2, '2007-03-24', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Juan Sebastián', 'Carús', 2, '2008-08-29', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Lucas', 'Chechik', 2, '2007-10-12', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Catalina', 'Cohen', 2, '2008-05-21', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Nicolás', 'Cukier', 2, '2007-07-03', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Gastón', 'Daiksel', 2, '2008-11-14', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Federico', 'Drucker', 2, '2007-02-27', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Felipe', 'Feldman', 2, '2008-06-18', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Uriel', 'Galanti', 2, '2007-04-30', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Alán', 'Gordon', 2, '2008-09-05', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tomás', 'Grinstein', 2, '2007-01-16', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Canela', 'Ledezma', 2, '2008-03-08', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Manuel', 'Mandel', 2, '2007-12-01', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Matias', 'Naddeo', 2, '2008-07-25', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Brisa', 'Monastiridis Vorornicoff', 2, '2007-05-19', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Chloe', 'Monastirsky', 2, '2008-10-10', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Levi Iván', 'Moscovich', 2, '2007-01-28', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Máximo', 'Patejim', 2, '2008-08-17', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Juan Manuel', 'Sabathie Lopez', 2, '2007-03-06', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Florencia', 'Sack', 2, '2008-05-23', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Naomi', 'Serebrinsky', 2, '2007-09-12', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Suti', 'Uriel', 2, '2008-11-30', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Julieta', 'Usoz', 2, '2007-06-15', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Luciano', 'Vallejos', 2, '2008-02-09', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Matias', 'Wolfus', 2, '2007-07-27', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Agustin', 'Aiello', 3, '2008-04-03', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Jazmin', 'Arias', 3, '2007-10-21', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Alejo', 'Campano', 3, '2008-12-13', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Julian', 'Canievsky', 3, '2007-05-29', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Santiago', 'Choe', 3, '2008-09-07', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Damian', 'Cymerman', 3, '2007-02-14', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tobias', 'Digestani', 3, '2008-06-11', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Valentina', 'Elterman', 3, '2007-08-25', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Andrés', 'Fishman', 3, '2008-01-31', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Fidel', 'Goldsman', 3, '2007-11-18', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Julian', 'Hofman', 3, '2008-03-03', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Santiago', 'Hong', 3, '2007-07-14', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Joaquin', 'Iribas', 3, '2008-10-26', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Nicolas', 'Jajurin', 3, '2007-04-09', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ignacio', 'Kohn', 3, '2008-06-20', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Victoria', 'Kriger', 3, '2007-12-02', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Alan', 'Laizerovich', 3, '2008-05-15', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Damian', 'Leibman', 3, '2007-09-27', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Facundo', 'Lukacher', 3, '2008-02-08', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Pedro', 'Malowicki', 3, '2007-11-22', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Dante', 'Martinez', 3, '2008-03-17', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Jonatan', 'Naifeld', 3, '2007-08-04', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Diana', 'Park', 3, '2008-01-25', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ciro', 'Perazzo', 3, '2007-06-30', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Santiago', 'Schettini', 3, '2008-10-11', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Nicolas', 'Schnaider', 3, '2007-05-07', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ailin', 'Severino', 3, '2008-09-19', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Sofia', 'Zalucki', 3, '2007-12-28', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Gael', 'Zolotow', 3, '2008-04-24', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Cecilia', 'Abreu', 4, '2007-07-13', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Federico', 'Ajami', 4, '2008-02-16', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Maximiliano', 'Bernardoni', 4, '2007-10-03', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Sebastián', 'Calviño', 4, '2008-06-09', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Santiago', 'Dobrovitzky', 4, '2007-01-12', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Lucas', 'Dorin', 4, '2008-11-01', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Lucas', 'Dueñaz', 4, '2007-03-29', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tobias', 'Epsztein', 4, '2008-08-18', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ignacio', 'Eskenazi', 4, '2007-05-26', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Manuel', 'Gartenkrot Casal', 4, '2008-09-30', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tomás', 'Goldentul', 4, '2007-02-05', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Uriel', 'Grinfeld', 4, '2008-07-21', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Máximo', 'Hevia', 4, '2007-12-14', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Luciana', 'Kampel', 4, '2008-04-06', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Martín', 'Ku', 4, '2007-10-23', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Juana', 'Lopez Valenzuela', 4, '2008-01-17', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tobias', 'Nul', 4, '2007-06-28', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Augusto', 'Perez', 4, '2008-11-09', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ramiro', 'Pita', 4, '2007-08-31', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Felipe', 'Plat', 4, '2008-03-12', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ciro', 'Ranieli', 4, '2007-05-04', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Joaquín', 'Stock', 4, '2008-09-15', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Iara', 'Szwarstein', 4, '2007-02-20', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Lior', 'Tanel', 4, '2008-07-08', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Theo', 'Trosman', 4, '2007-11-24', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Clara', 'Wolman', 4, '2008-04-27', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Federico Victor', 'Abas', 5, '2007-01-30', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Facundo Eliel', 'Angel', 5, '2008-06-13', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Micaela', 'Berman Kreserman', 5, '2007-09-22', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Matias Ramiro', 'Brasburg', 5, '2008-03-05', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Kiara Sofía', 'Brukiew', 5, '2007-12-19', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ilan Uriel', 'Busso', 5, '2008-05-10', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Franco', 'Cappella', 5, '2007-08-01', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Francisco', 'Castillo', 5, '2008-10-14', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ludmila Uma', 'Grün', 5, '2007-04-11', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Uriel Federico', 'Hamu', 5, '2008-07-26', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Eliel', 'Jamilis', 5, '2007-11-06', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Delfina', 'Kaltman', 5, '2008-02-15', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Federico', 'Kreserman', 5, '2007-06-22', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Benjamin', 'Liberman', 5, '2008-09-08', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Mateo Julian', 'Milano', 5, '2007-01-09', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Gael Ricardo', 'Mizrahi', 5, '2008-12-03', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Andres', 'Perel', 5, '2007-05-17', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tobías', 'Rohr', 5, '2008-08-27', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Bruno', 'Roth', 5, '2007-03-01', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Ivan Daniel', 'Shoffer', 5, '2008-10-20', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Sofia', 'Sufryn', 5, '2007-07-02', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Milena', 'Svatzky', 5, '2008-11-11', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Augusto Amadeo', 'Traverso', 5, '2007-04-18', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Maica', 'Trutner Kobryniec', 5, '2008-06-29', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Tobias Yoel', 'Turquie', 5, '2007-09-16', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Franco', 'Urquizo Barba', 5, '2008-01-24', TRUE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Alexia', 'Wainstok', 5, '2007-08-07', FALSE);
INSERT INTO alumnos (nombre, apellido, id_curso, fecha_nacimiento, hace_deportes) VALUES ('Morena Yael', 'Zalcman', 5, '2008-05-12', TRUE);

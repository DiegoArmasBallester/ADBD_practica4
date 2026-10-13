-- 1. Creación de la base de datos
CREATE DATABASE viveros;
-- Moverse a la base de datos
\c viveros;

-- 2. Creación de las tablas de las entidades

CREATE TABLE Vivero (
    id_vivero SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(9, 6),
    longitud NUMERIC(9, 6)
);

-- Entidad Débil: Depende de Vivero (ON DELETE CASCADE)
CREATE TABLE Zona (
    id_vivero INT,
    id_zona VARCHAR(20),
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(9, 6),
    longitud NUMERIC(9, 6),
    PRIMARY KEY (id_vivero, id_zona),
    FOREIGN KEY (id_vivero) REFERENCES Vivero(id_vivero) ON DELETE CASCADE
);

CREATE TABLE Producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio_actual NUMERIC(10,2) NOT NULL CHECK (precio_actual >= 0)
);

CREATE TABLE Empleado (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL
);

CREATE TABLE Cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    fecha_ingreso_plus DATE -- Nulo significa que no es Plus
);

CREATE TABLE Pedido (
    id_pedido SERIAL PRIMARY KEY,
    fecha_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente) ON DELETE RESTRICT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE RESTRICT
);

CREATE TABLE Tarea (
    id_tarea SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- 3. Creación de las tablas de las relaciones

CREATE TABLE Puesto (
    id_empleado INT,
    id_vivero INT,
    id_zona VARCHAR(20),
    fecha_inicio DATE NOT NULL,
    fecha_final DATE,
    productividad NUMERIC(5, 2) CHECK (productividad >= 0 AND productividad <= 100),
    PRIMARY KEY (id_empleado, id_vivero, id_zona, fecha_inicio),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE,
    FOREIGN KEY (id_vivero, id_zona) REFERENCES Zona(id_vivero, id_zona) ON DELETE CASCADE,
    CHECK (fecha_final IS NULL OR fecha_final >= fecha_inicio)
);

CREATE TABLE Asignacion_Producto (
    id_producto INT,
    id_vivero INT,
    id_zona VARCHAR(20),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    PRIMARY KEY (id_producto, id_vivero, id_zona),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto) ON DELETE CASCADE,
    FOREIGN KEY (id_vivero, id_zona) REFERENCES Zona(id_vivero, id_zona) ON DELETE CASCADE
);

CREATE TABLE Registro_Pedido (
    id_pedido INT,
    id_producto INT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_venta NUMERIC(10,2) NOT NULL CHECK (precio_venta >= 0),
    PRIMARY KEY (id_pedido, id_producto),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto) ON DELETE RESTRICT
);

-- 4. Vista para num_pedidos
-- Resuelve el atributo derivado 'num_pedidos' calculándolo dinámicamente
CREATE VIEW Vista_Clientes_Estadisticas AS
SELECT
    c.id_cliente,
    c.nombre,
    c.fecha_ingreso_plus,
    (c.fecha_ingreso_plus IS NOT NULL) AS es_plus,
    COUNT(p.id_pedido) AS num_pedidos
FROM Cliente c
LEFT JOIN Pedido p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombre, c.fecha_ingreso_plus;

-- 5. Inserción de datos en las tablas

INSERT INTO Vivero (nombre, latitud, longitud) VALUES
('Tajinaste Norte', 28.41, -16.54),
('Tajinaste Sur', 28.05, -16.71),
('Tajinaste Capital', 28.46, -16.25),
('Tajinaste Este', 28.32, -16.38),
('Tajinaste Oeste', 28.29, -16.82);

INSERT INTO Zona (id_vivero, id_zona, nombre, latitud, longitud) VALUES
(1, 'Z-EXT', 'Exterior', 28.411, -16.541),
(1, 'Z-ALM', 'Almacén Principal', 28.412, -16.542),
(2, 'Z-EXT', 'Exterior', 28.051, -16.711),
(2, 'Z-INT', 'Invernadero', 28.052, -16.712),
(3, 'Z-DEC', 'Decoración', 28.461, -16.251);

INSERT INTO Producto (nombre, categoria, precio_actual) VALUES
('Rosal Trepador', 'Plantas', 15.50),
('Saco Abono 50L', 'Jardinería', 8.99),
('Maceta Barro 30cm', 'Decoración', 12.00),
('Fertilizante Líquido', 'Jardinería', 5.75),
('Cactus Variado', 'Plantas', 3.50);

INSERT INTO Empleado (nombre) VALUES
('Ana García'),
('Luis Martínez'),
('Carlos Sosa'),
('Marta Torres'),
('Elena Díaz');

INSERT INTO Cliente (nombre, fecha_ingreso_plus) VALUES
('Empresa Paisajismo SL', '2023-01-15'),
('Juan Pérez', NULL),
('Laura Gómez', '2023-06-20'),
('Hotel Paraíso', '2022-11-05'),
('Pedro Sánchez', NULL);

INSERT INTO Pedido (id_cliente, id_empleado, fecha_pedido) VALUES
(1, 1, '2023-10-01 10:00:00'),
(2, 2, '2023-10-02 11:30:00'),
(3, 1, '2023-10-05 09:15:00'),
(1, 3, '2023-10-10 14:20:00'),
(4, 4, '2023-10-12 16:45:00');

INSERT INTO Tarea (nombre, descripcion) VALUES
('Limpieza y Poda', 'Limpieza general de instalaciones y poda estacional de plantas'),
('Gestión de Almacén', 'Control de stock, inventario y organización de mercancía'),
('Mantenimiento', 'Reparación de infraestructuras, estanterías y sistemas de agua'),
('Riego y Abono', 'Aplicación de riego general y fertilización de zonas verdes'),
('Atención al Público', 'Asistencia a clientes en zonas de decoración y exterior');

INSERT INTO Puesto (id_empleado, id_vivero, id_zona, fecha_inicio, fecha_final, productividad, id_tarea) VALUES
(1, 1, 'Z-EXT', '2023-01-01', NULL, 95.5, 1),
(2, 1, 'Z-ALM', '2023-01-01', '2023-06-30', 88.0, 2),
(2, 2, 'Z-INT', '2023-07-01', NULL, 92.0, 4),
(3, 3, 'Z-DEC', '2022-05-15', NULL, 85.5, 3),
(4, 2, 'Z-EXT', '2023-03-10', NULL, 90.0, 5);

INSERT INTO Asignacion_Producto (id_producto, id_vivero, id_zona, stock) VALUES
(1, 1, 'Z-EXT', 50),
(2, 1, 'Z-ALM', 200),
(3, 3, 'Z-DEC', 75),
(4, 2, 'Z-INT', 120),
(5, 1, 'Z-EXT', 30);

INSERT INTO Registro_Pedido (id_pedido, id_producto, cantidad, precio_venta) VALUES
(1, 1, 10, 15.50),
(1, 2, 5, 8.50),
(2, 3, 2, 12.00),
(3, 4, 1, 5.75),
(4, 2, 20, 8.99);

-- 6. Ejemplos de DELETE

-- Ejemplo 1: Borrar un Vivero (Demostración de CASCADE)
DELETE FROM Vivero WHERE id_vivero = 1;

-- Ejemplo 2: Borrar un Pedido (Demostración de CASCADE parcial)
DELETE FROM Pedido WHERE id_pedido = 4;

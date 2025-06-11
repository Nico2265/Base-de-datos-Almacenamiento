CREATE TABLE Productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    codigo_barra VARCHAR(50) UNIQUE NOT NULL,
    unidad_medida VARCHAR(10),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_productos_codigo_barra ON Productos(codigo_barra);

CREATE TABLE Ubicaciones (
    ubicacion_id SERIAL PRIMARY KEY,
    codigo_ubicacion VARCHAR(20) UNIQUE NOT NULL,
    descripcion VARCHAR(100),
    tipo VARCHAR(50),
    bodega VARCHAR(50),
    nivel INTEGER DEFAULT 1
);

CREATE TABLE Usuarios_RF (
    usuario_id SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    nombre_completo VARCHAR(100),
    rol VARCHAR(20) DEFAULT 'OPERADOR',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Inventario (
    inventario_id SERIAL PRIMARY KEY,
    producto_id INTEGER NOT NULL,
    ubicacion_id INTEGER NOT NULL,
    cantidad NUMERIC(10,2) NOT NULL DEFAULT 0,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT UQ_Producto_Ubicacion UNIQUE (producto_id, ubicacion_id),
    CONSTRAINT chk_cantidad_non_negative CHECK (cantidad >= 0),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),
    FOREIGN KEY (ubicacion_id) REFERENCES Ubicaciones(ubicacion_id)
);

CREATE INDEX idx_inventario_producto_id ON Inventario(producto_id);
CREATE INDEX idx_inventario_ubicacion_id ON Inventario(ubicacion_id);

CREATE TABLE Movimientos (
    movimiento_id SERIAL PRIMARY KEY,
    producto_id INTEGER NOT NULL,
    cantidad NUMERIC(10,2) NOT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL,
    ubicacion_origen_id INTEGER,
    ubicacion_destino_id INTEGER,
    usuario_id INTEGER NOT NULL,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    referencia_externa VARCHAR(50),
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    FOREIGN KEY (producto_id) REFERENCES Productos(producto_id),
    FOREIGN KEY (ubicacion_origen_id) REFERENCES Ubicaciones(ubicacion_id),
    FOREIGN KEY (ubicacion_destino_id) REFERENCES Ubicaciones(ubicacion_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios_RF(usuario_id)
);

CREATE OR REPLACE FUNCTION validar_stock_suficiente()
RETURNS TRIGGER AS $$
DECLARE
    stock_actual NUMERIC(10,2);
BEGIN
    IF NEW.tipo_movimiento IN ('SALIDA', 'TRASLADO') THEN
        SELECT cantidad INTO stock_actual
        FROM Inventario
        WHERE producto_id = NEW.producto_id AND ubicacion_id = NEW.ubicacion_origen_id;

        IF stock_actual IS NULL OR stock_actual < NEW.cantidad THEN
            RAISE EXCEPTION 'Stock insuficiente en la ubicación origen.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_stock_suficiente
BEFORE INSERT ON Movimientos
FOR EACH ROW
EXECUTE FUNCTION validar_stock_suficiente();



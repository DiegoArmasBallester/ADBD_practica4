# Administración y Diseño de Base de Datos - Viveros Tajinaste S.A.

Este documento resume la estructura final del modelo relacional para la gestión de Viveros Tajinaste S.A., detallando las tablas, vistas y las optimizaciones aplicadas sobre el diseño conceptual original.

## 1. Consultas SELECT
<img width="568" height="278" alt="image" src="https://github.com/user-attachments/assets/1ef3fe76-bfd6-4a52-9dca-d2b8412d89d1" />

<img width="613" height="299" alt="image" src="https://github.com/user-attachments/assets/bd36e91b-feb9-4e58-82d2-b7dd394f700f" />

<img width="1185" height="384" alt="image" src="https://github.com/user-attachments/assets/87943cea-8c07-4014-b564-e0506a9aff63" />

## 1. Mejoras Aplicadas al Esquema Original

Para asegurar la viabilidad del cálculo de facturación, mantener un histórico real de compras y cumplir con las normas de diseño relacional, se realizaron las siguientes modificaciones clave en el modelo:

*   **Desglose de Coordenadas (Atributos Simples):** El atributo compuesto `georef` se dividió en dos columnas independientes (`latitud` y `longitud`). Esto se aplicó en las entidades `Vivero` y `Zona`, permitiendo una mejor indexación y el uso futuro de funciones geoespaciales.
*   **Gestión de Precios (Cálculo del Volumen de Compras):** 
    *   Se añadió el atributo **`precio_actual`** a la entidad **`Producto`** para definir el coste en tiempo real del catálogo.
    *   Se añadió el atributo **`precio_venta`** a la tabla de relación **`Registro_Pedido`** (líneas de pedido). Esto es fundamental para "congelar" el precio en el momento de la transacción. Así, si el precio de un producto sube al mes siguiente, el volumen de compras histórico de los clientes Tajinaste Plus no se verá alterado erróneamente.
*   **Mantenimiento Histórico (N:M):** La relación de Mantenimiento se configuró correctamente como una tabla Muchos a Muchos (N:M). Esto evita bloquear a un empleado en una sola zona de por vida, permitiendo registrar qué empleado limpió o reparó qué zona en una fecha específica.

## 2. Resumen de Tablas Creadas

### Entidades Principales
*   **`Vivero`**: Registro de las sucursales físicas (ID, nombre, latitud, longitud).
*   **`Producto`**: Catálogo de artículos disponibles (ID, nombre, categoría, precio_actual).
*   **`Empleado`**: Personal de la empresa (ID, nombre).
*   **`Cliente`**: Compradores registrados. Incluye el atributo `fecha_ingreso_plus` (si es Nulo, el cliente no pertenece al programa de fidelización).

### Entidades Dependientes
*   **`Zona` (Entidad Débil)**: Diferentes áreas dentro de las sucursales (Exterior, Almacén, etc.). Su existencia está atada a un `Vivero` (borrado en cascada).
*   **`Pedido`**: Cabecera de los tickets de compra. Contiene la fecha de la venta y se enlaza directamente con el `Cliente` que compra y el `Empleado` que gestiona la transacción.

### Tablas Intermedias (Relaciones N:M)
*   **`Puesto`**: Historial laboral. Registra la ubicación (Zona y Vivero) donde trabaja un empleado en rangos de fechas definidos, junto con su productividad.
*   **`Asignacion_Producto`**: Inventario. Controla la cantidad exacta (`stock`) de cada producto almacenada en una zona concreta.
*   **`Registro_Pedido`**: Detalle del carrito de la compra. Une el pedido con los productos, almacenando la `cantidad` comprada y el `precio_venta` fijado en ese instante.
*   **`Mantenimiento`**: Partes de trabajo (limpieza, reparación, etc.) realizados por los empleados en las distintas zonas, con detalle de fechas y duración.

## 3. Resumen de Vistas

*   **`Vista_Clientes_Estadisticas`**: Esta vista sustituye al atributo derivado (calculado) del diagrama original. En lugar de almacenar físicamente la cantidad de pedidos (lo cual genera problemas de actualización), la vista calcula dinámicamente sobre la marcha el volumen total (`num_pedidos`) de cada cliente agrupando las tablas, y determina ágilmente si son miembros del programa Plus.

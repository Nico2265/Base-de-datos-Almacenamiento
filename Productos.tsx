import { useEffect, useState } from "react";

type Producto = {
  producto_id: number;
  nombre: string;
  codigo_barra: string;
  unidad_medida: string;
  fecha_creacion: string;
};

export default function Productos() {
  const [productos, setProductos] = useState<Producto[]>([]);

  useEffect(() => {
    fetch("http://localhost/api/obtener_productos.php")
      .then((res) => res.json())
      .then((data) => setProductos(data))
      .catch((err) => console.error("Error al obtener productos:", err));
  }, []);

  return (
    <div className="p-4">
      <h2 className="text-xl font-bold mb-2">Lista de Productos</h2>
      <table className="table-auto border w-full">
        <thead>
          <tr className="bg-gray-200">
            <th className="border px-4 py-2">ID</th>
            <th className="border px-4 py-2">Nombre</th>
            <th className="border px-4 py-2">Código de Barra</th>
            <th className="border px-4 py-2">Unidad</th>
            <th className="border px-4 py-2">Fecha</th>
          </tr>
        </thead>
        <tbody>
          {productos.map((p) => (
            <tr key={p.producto_id}>
              <td className="border px-4 py-2">{p.producto_id}</td>
              <td className="border px-4 py-2">{p.nombre}</td>
              <td className="border px-4 py-2">{p.codigo_barra}</td>
              <td className="border px-4 py-2">{p.unidad_medida}</td>
              <td className="border px-4 py-2">{p.fecha_creacion}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

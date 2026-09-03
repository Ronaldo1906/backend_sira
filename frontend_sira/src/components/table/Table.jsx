import { useState, useMemo, useEffect } from "react";
import { Card, InputGroup, Form, Button, Badge, Table as BootstrapTable, Pagination } from "react-bootstrap";
import { Search, X } from "lucide-react";

function Table({
  columnas = [],
  datos = [],
  renderCelda,
  campoId = null,
  mostrarBuscador = true,
  camposBusqueda = [],
  placeholderBusqueda = "Buscar...",
  mostrarAccion = false,
  textoAccion = "Ver",
  onAccion,
  elementosPorPagina = 10
}) {
  const [busqueda, setBusqueda] = useState("");
  const [paginaActual, setPaginaActual] = useState(1);

  const datosFiltrados = useMemo(() => {
    if (!busqueda.trim()) return datos;
    const texto = busqueda.toLowerCase().trim();
    return datos.filter((fila) => {
      if (camposBusqueda.length === 0) {
        return Object.values(fila).some((val) => val && String(val).toLowerCase().includes(texto));
      }
      return camposBusqueda.some((campo) => fila[campo] && String(fila[campo]).toLowerCase().includes(texto));
    });
  }, [datos, busqueda, camposBusqueda]);

  const totalPaginas = Math.ceil(datosFiltrados.length / elementosPorPagina);

  useEffect(() => {
    setPaginaActual(1);
  }, [busqueda]);

  const indiceInicial = (paginaActual - 1) * elementosPorPagina;
  const datosPagina = datosFiltrados.slice(indiceInicial, indiceInicial + elementosPorPagina);

  const formatearColumna = (col) => col.replaceAll("_", " ").replace(/\b\w/g, (l) => l.toUpperCase());

  return (
    <Card className="border-0 shadow-sm rounded-3">
      {mostrarBuscador && (
        <Card.Header className="bg-white border-0 p-3">
          <div className="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <InputGroup style={{ maxWidth: "400px" }}>
              <InputGroup.Text className="bg-white"><Search size={18} /></InputGroup.Text>
              <Form.Control
                type="text"
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder={placeholderBusqueda}
              />
              {busqueda && (
                <Button variant="outline-secondary" onClick={() => setBusqueda("")}><X size={17} /></Button>
              )}
            </InputGroup>
            <Badge bg="light" text="dark" className="border px-3 py-2">
              {datosFiltrados.length} registros
            </Badge>
          </div>
        </Card.Header>
      )}
      <div className="table-responsive">
        <BootstrapTable hover bordered responsive className="align-middle mb-0">
          <thead className="table-light">
            <tr>
              {columnas.map((col) => (
                <th key={col} className="text-nowrap">{formatearColumna(col)}</th>
              ))}
              {mostrarAccion && <th className="text-center text-nowrap">Acción</th>}
            </tr>
          </thead>
          <tbody>
            {datosPagina.length === 0 ? (
              <tr>
                <td colSpan={columnas.length + (mostrarAccion ? 1 : 0)} className="text-center text-muted py-5">
                  <Search size={32} className="mb-2" />
                  <div>No se encontraron registros</div>
                </td>
              </tr>
            ) : (
              datosPagina.map((fila, i) => (
                <tr key={campoId ? fila[campoId] : i}>
                  {columnas.map((col) => (
                    <td key={col}>
                      {renderCelda ? renderCelda(col, fila[col], fila) : fila[col]}
                    </td>
                  ))}
                  {mostrarAccion && (
                    <td className="text-center">
                      <Button variant="outline-primary" size="sm" onClick={() => onAccion && onAccion(fila)}>
                        {textoAccion}
                      </Button>
                    </td>
                  )}
                </tr>
              ))
            )}
          </tbody>
        </BootstrapTable>
      </div>
      {datosFiltrados.length > 0 && totalPaginas > 1 && (
        <Card.Footer className="bg-white border-0 p-3 d-flex justify-content-between align-items-center">
          <small className="text-muted">Página {paginaActual} de {totalPaginas}</small>
          <Pagination className="mb-0">
            <Pagination.Prev onClick={() => setPaginaActual((p) => Math.max(p - 1, 1))} disabled={paginaActual === 1} />
            <Pagination.Next onClick={() => setPaginaActual((p) => Math.min(p + 1, totalPaginas))} disabled={paginaActual === totalPaginas} />
          </Pagination>
        </Card.Footer>
      )}
    </Card>
  );
}

export default Table;
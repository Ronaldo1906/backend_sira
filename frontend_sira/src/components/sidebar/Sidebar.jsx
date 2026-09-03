import { Nav, Button } from "react-bootstrap";
import { LayoutDashboard, Users, FileText, LogOut } from "lucide-react";
import { useAuth } from "../../context/AuthContext";

function Sidebar({ pagina, cambiarPagina }) {
  const { logout, usuario } = useAuth();

  const opciones = [
    { key: "dashboard", label: "Dashboard", icon: LayoutDashboard },
    { key: "usuarios", label: "Usuarios", icon: Users },
    { key: "reportes", label: "Reportes", icon: FileText }
  ];

  return (
    <div className="d-flex flex-column bg-dark text-white p-3 min-vh-100" style={{ width: "240px" }}>
      <div className="fs-4 fw-bold mb-4 text-center border-bottom pb-2">SIRA</div>
      <Nav className="flex-column gap-2 flex-grow-1">
        {opciones.map((item) => {
          const Icono = item.icon;
          return (
            <Nav.Link
              key={item.key}
              onClick={() => cambiarPagina(item.key)}
              className={`text-white d-flex align-items-center gap-2 rounded px-3 py-2 ${
                pagina === item.key ? "bg-primary" : "hover-bg-secondary"
              }`}
            >
              <Icono size={18} />
              {item.label}
            </Nav.Link>
          );
        })}
      </Nav>
      <div className="border-top pt-3 mt-auto">
        <small className="d-block text-muted mb-2">{usuario?.correo}</small>
        <Button variant="outline-danger" size="sm" className="w-100 d-flex align-items-center justify-content-center gap-2" onClick={logout}>
          <LogOut size={16} /> Cerrar Sesión
        </Button>
      </div>
    </div>
  );
}

export default Sidebar;
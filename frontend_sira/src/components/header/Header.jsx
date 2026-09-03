import { Navbar, Container } from "react-bootstrap";
import { useAuth } from "../../context/AuthContext";

function Header() {
  const { usuario } = useAuth();

  return (
    <Navbar bg="white" className="border-bottom px-4 py-3 shadow-sm">
      <Container fluid className="p-0 d-flex justify-content-between align-items-center">
        <h5 className="mb-0 text-secondary">Sistema SIRA</h5>
        <div className="d-flex align-items-center gap-2">
          <span className="fw-semibold text-dark">{usuario?.nombre || "Usuario"}</span>
          <span className="badge bg-secondary">{usuario?.rol || "Rol"}</span>
        </div>
      </Container>
    </Navbar>
  );
}

export default Header;
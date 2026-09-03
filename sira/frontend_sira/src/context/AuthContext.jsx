import { createContext, useContext, useState } from "react";
import { login as loginService } from "../services/authService";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [usuario, setUsuario] = useState(() => {
    const usuarioGuardado = localStorage.getItem("sira_usuario");
    if (!usuarioGuardado) return null;
    try {
      return JSON.parse(usuarioGuardado);
    } catch {
      localStorage.removeItem("sira_usuario");
      return null;
    }
  });

  const login = async (correo, password) => {
    const resultado = await loginService(correo, password);
    if (resultado.status && resultado.data) {
      setUsuario(resultado.data);
      localStorage.setItem("sira_usuario", JSON.stringify(resultado.data));
    }
    return resultado;
  };

  const logout = () => {
    setUsuario(null);
    localStorage.removeItem("sira_usuario");
  };

  return (
    <AuthContext.Provider value={{ usuario, autenticado: usuario !== null, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
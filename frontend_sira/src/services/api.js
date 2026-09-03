import axios from "axios";

const API = axios.create({
  baseURL: "http://localhost:8000/api", // Ajusta con la URL base de tu backend
  headers: {
    "Content-Type": "application/json"
  }
});

API.interceptors.request.use((config) => {
  const usuario = localStorage.getItem("sira_usuario");
  if (usuario) {
    const { token } = JSON.parse(usuario);
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }
  return config;
});

export default API;
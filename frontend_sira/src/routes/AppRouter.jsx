import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Dashboard from '../views/Dashboard/Dashboard';
import Login from '../views/login/Login';

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Ruta raíz: redirige automáticamente a /login */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        
        {/* Rutas principales */}
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<Dashboard />} />
        
        {/* Ruta comodín: redirige cualquier URL no existente a /login */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default AppRouter;
import React from 'react';
import { useNavigate } from 'react-router-dom';

export default function Dashboard() {
  const navigate = useNavigate();
  const usuario = localStorage.getItem('usuario') || 'Usuario SIRA';
  const iniciales = usuario.substring(0, 2).toUpperCase();

  const handleLogout = () => {
    if (window.confirm('¿Seguro que quieres cerrar sesión?')) {
      localStorage.clear();
      navigate('/login');
    }
  };

  const menuItems = [
    { icon: '👤', title: 'Perfil', desc: 'Ver y editar tu información personal y contraseña' },
    { icon: '📝', title: 'Actividades', desc: 'Revisa tareas, evaluaciones y fechas de entrega' },
    { icon: '📚', title: 'Material Académico', desc: 'Descarga guías, videos y recursos de tus cursos' },
    { icon: '📊', title: 'Reportes', desc: 'Consulta tus calificaciones y progreso académico' }
  ];

  return (
    <div style={styles.body}>
      {/* Navbar */}
      <nav style={styles.navbar}>
        <h1 style={styles.logo}>🎓 Sistema Académico</h1>
        <div style={styles.userInfo}>
          <span>{usuario}</span>
          <div style={styles.avatar}>{iniciales}</div>
          <button style={styles.btnLogout} onClick={handleLogout}>Salir</button>
        </div>
      </nav>

      {/* Contenido Principal */}
      <div style={styles.container}>
        <div style={styles.welcome}>
          <h2>Bienvenido, Aprendiz</h2>
          <p>Selecciona una opción para continuar</p>
        </div>

        <div style={styles.menuGrid}>
          {menuItems.map((item, index) => (
            <div key={index} style={styles.card}>
              <div style={styles.cardIcon}>{item.icon}</div>
              <h3 style={styles.cardTitle}>{item.title}</h3>
              <p style={styles.cardDesc}>{item.desc}</p>
            </div>
          ))}
        </div>
      </div>

      <footer style={styles.footer}>
        © 2026 Sistema de Aprendizaje Virtual | SENA Bogotá
      </footer>
    </div>
  );
}

const styles = {
  body: {
    background: '#f5f7fa',
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
  },
  navbar: {
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    padding: '15px 30px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    color: 'white',
    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
    position: 'sticky',
    top: 0,
    zIndex: 100
  },
  logo: {
    fontSize: '20px',
    margin: 0
  },
  userInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '15px'
  },
  avatar: {
    width: '40px',
    height: '40px',
    borderRadius: '50%',
    background: 'white',
    color: '#667eea',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 'bold',
    fontSize: '16px'
  },
  btnLogout: {
    background: 'rgba(255,255,255,0.2)',
    border: 'none',
    padding: '8px 15px',
    borderRadius: '8px',
    color: 'white',
    cursor: 'pointer',
    fontSize: '14px'
  },
  container: {
    maxWidth: '1100px',
    margin: '40px auto',
    padding: '0 20px',
    width: '100%'
  },
  welcome: {
    textAlign: 'center',
    marginBottom: '40px'
  },
  menuGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
    gap: '25px'
  },
  card: {
    background: 'white',
    padding: '35px 25px',
    borderRadius: '15px',
    textAlign: 'center',
    cursor: 'pointer',
    boxShadow: '0 5px 15px rgba(0,0,0,0.08)',
    transition: 'transform 0.2s'
  },
  cardIcon: {
    width: '70px',
    height: '70px',
    margin: '0 auto 20px',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    borderRadius: '20px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '35px'
  },
  cardTitle: {
    color: '#333',
    fontSize: '20px',
    marginBottom: '10px'
  },
  cardDesc: {
    color: '#888',
    fontSize: '14px',
    lineHeight: '1.5',
    margin: 0
  },
  footer: {
    textAlign: 'center',
    padding: '30px 20px',
    color: '#999',
    fontSize: '14px'
  }
};
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { login } from '../../services/authService';

export default function Login() {
  const [credentials, setCredentials] = useState({ username: '', password: '' });
  const [errorMsg, setErrorMsg] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => {
    setCredentials({ ...credentials, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setLoading(true);

    try {
      const data = await login(credentials);

      // Guardar el token de sesión y el usuario devueltos por el backend
      localStorage.setItem('token', data.token);
      localStorage.setItem('usuario', data.usuario || credentials.username);
      
      // Redirigir al panel principal
      navigate('/dashboard');
    } catch (err) {
      setErrorMsg(err.message || 'Credenciales inválidas. Intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.body}>
      <div style={styles.card}>
        <div style={styles.iconHeader}>🎓</div>
        <h2 style={styles.title}>SIRA</h2>
        <p style={styles.subtitle}>Ingresa tus credenciales para continuar</p>
        
        {errorMsg && <div style={styles.errorAlert}>{errorMsg}</div>}

        <form onSubmit={handleSubmit}>
          <div style={styles.inputGroup}>
            <label style={styles.label}>Usuario</label>
            <input
              type="text"
              name="username"
              style={styles.input}
              placeholder="Ej. Aprendiz"
              value={credentials.username}
              onChange={handleChange}
              required
            />
          </div>

          <div style={styles.inputGroup}>
            <label style={styles.label}>Contraseña</label>
            <input
              type="password"
              name="password"
              style={styles.input}
              placeholder="••••••••"
              value={credentials.password}
              onChange={handleChange}
              required
            />
          </div>

          <button type="submit" style={styles.button} disabled={loading}>
            {loading ? 'Verificando...' : 'Ingresar'}
          </button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  body: {
    background: '#f5f7fa',
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
  },
  card: {
    background: 'white',
    padding: '40px 30px',
    borderRadius: '15px',
    boxShadow: '0 5px 15px rgba(0,0,0,0.08)',
    width: '100%',
    maxWidth: '400px',
    textAlign: 'center'
  },
  iconHeader: {
    width: '60px',
    height: '60px',
    margin: '0 auto 15px',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    borderRadius: '15px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '30px'
  },
  title: {
    color: '#333',
    fontSize: '24px',
    marginBottom: '5px'
  },
  subtitle: {
    color: '#777',
    fontSize: '14px',
    marginBottom: '20px'
  },
  errorAlert: {
    backgroundColor: '#ffe6e6',
    color: '#d93025',
    padding: '10px',
    borderRadius: '8px',
    fontSize: '13px',
    marginBottom: '15px',
    border: '1px solid #ffcccc'
  },
  inputGroup: {
    textAlign: 'left',
    marginBottom: '18px'
  },
  label: {
    display: 'block',
    fontSize: '14px',
    color: '#555',
    marginBottom: '6px',
    fontWeight: '500'
  },
  input: {
    width: '100%',
    padding: '10px 14px',
    borderRadius: '8px',
    border: '1px solid #ddd',
    fontSize: '14px',
    outline: 'none',
    boxSizing: 'border-box'
  },
  button: {
    width: '100%',
    padding: '12px',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    border: 'none',
    borderRadius: '8px',
    color: 'white',
    fontSize: '16px',
    fontWeight: 'bold',
    cursor: 'pointer',
    marginTop: '10px'
  }
};
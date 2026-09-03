const API_URL = 'http://localhost:8000/api';

// Asegúrate de que diga 'export const login'
export const login = async (credentials) => {
  try {
    const response = await fetch(`${API_URL}/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(credentials),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.detail || data.message || 'Error en el inicio de sesión');
    }

    return data;
  } catch (error) {
    throw error;
  }
};
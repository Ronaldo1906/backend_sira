# backend_sira

# 1. Frontend (Interfaz de Usuario)
# React: Librería principal utilizada para construir la interfaz SPA (Single Page Application).

# Vite: Herramienta de construcción y entorno de desarrollo rápido para empaquetar el frontend. ##

# React Router DOM: Manejo de rutas del lado del cliente (/login, /dashboard, etc.).

# JavaScript (ES6+) & JSX: Lenguaje de programación base y sintaxis de renderizado de componentes.

# CSS en JS (Inline Styles): Estilizado de la interfaz estructurado mediante objetos JavaScript.

# 2. Backend (Lógica de Negocio y API)
# Python: Lenguaje de programación principal del lado del servidor.

# FastAPI: Framework web asíncrono para la construcción de los endpoints RESTful.

# Uvicorn: Servidor ASGI para ejecutar la aplicación de FastAPI.

# Pydantic: Definición de esquemas, validación de tipos y serialización de datos de la API.

# 3. Base de Datos y ORM
# MySQL: Sistema de gestión de base de datos relacional (RDBMS) para almacenar tablas como Usuario, Aprendiz, Instructor, etc.

# SQLAlchemy: ORM y toolkit de SQL para gestionar conexiones y ejecutar consultas (en este caso, mediante consultas nativas con text()).

# Resumen Visual del Stack
# Plaintext
# [ React + Vite ]  <--->  [ FastAPI (Python) ]  <--->  [ SQLAlchemy / MySQL ]
#    (Frontend)                  (Backend)                  (Base de datos)

# 🎓 SIRA - Sistema de Información de Revisiones y Actividades

SIRA es una plataforma web full-stack desacoplada diseñada para la gestión, entrega y retroalimentación de actividades académicas entre instructores y aprendices.

---

## 🛠️ Stack Tecnológico Utilizado

### **Frontend**
* **React.js:** Librería principal para la creación de interfaces de usuario interactivas en arquitectura SPA (*Single Page Application*).
* **Vite:** Herramienta de construcción y servidor de desarrollo ultrarrápido para empaquetar el código de React.
* **React Router DOM:** Gestor de rutas del lado del cliente para la navegación entre vistas (`/login`, `/dashboard`).
* **CSS en JS (Inline Styles):** Estilizado modular de componentes mediante objetos JavaScript.

### **Backend**
* **Python 3.10+:** Lenguaje de programación base del servidor.
* **FastAPI:** Framework web asíncrono de alto rendimiento para el diseño de endpoints RESTful.
* **Uvicorn:** Servidor ASGI encargado de correr la aplicación FastAPI.
* **Pydantic:** Definición de modelos de datos, parsing y validación estricta del cuerpo de las peticiones HTTP.

### **Base de Datos y Persistencia**
* **MySQL:** Sistema de Gestión de Base de Datos Relacional (RDBMS).
* **SQLAlchemy & PyMySQL:** ORM y controlador de conexión en Python para la ejecución de mapeos y consultas nativas SQL con manejo seguro de parámetros.

---

## 📋 Requisitos Previos e Instalación

### **1. Prerrequisitos del Sistema**
* **Node.js** (v18.0 o superior) y **npm**.
* **Python** (v3.10 o superior).
* **MySQL Server** corriendo localmente o mediante MySQL Workbench / XAMPP.

---

### **2. Configuración del Backend (`backend_sira`)**

1. Navega a la carpeta del servidor:
   ```bash
   cd backend_sira

<!--
Crea un entorno virtual e inicialízalo:

Bash
python -m venv .venv

# En Windows:
.venv\Scripts\activate


Bash
pip install -r requirements.txt
Configura las variables de entorno en el archivo .env:

Fragmento de código
DATABASE_URL=mysql+pymysql://root:tu_contraseña@localhost:3306/nombre_base_datos
Inicia el servidor del backend con Uvicorn:

Bash
uvicorn app.main:app --reload
El backend estará disponible en http://127.0.0.1:8000 y la documentación interactiva Swagger en http://127.0.0.1:8000/docs.

3. Configuración del Frontend (frontend_sira)
Abre una nueva terminal y navega a la carpeta del frontend:

Bash
cd frontend_sira
Instala los paquetes de Node.js:

Bash
npm install
Levanta la aplicación en modo desarrollo:

Bash
npm run dev
El frontend estará disponible en http://localhost:5173.

🎤 Guía de Preparación para la Sustentación Académica
Utiliza las siguientes secciones conceptuales para responder con solidez técnica ante los evaluadores durante la defensa de tu proyecto:

1. Justificación de la Arquitectura (Full Stack Desacoplado)
"Elegimos una arquitectura desacoplada dividiendo el Frontend (React) y el Backend (FastAPI). Esto nos da escalabilidad: el servidor se enfoca exclusivamente en procesar reglas de negocio y responder datos ligeros en formato JSON, mientras que el cliente se encarga del renderizado de la interfaz. Esto permitiría a futuro reutilizar la misma API para una aplicación móvil."

2. Justificación del Backend (FastAPI + SQLAlchemy)
"Optamos por FastAPI debido a su velocidad de respuesta asíncrona y la validación automática de schemas mediante Pydantic, lo cual previene datos corruptos desde la entrada de los endpoints. Para la comunicación con MySQL implementamos SQLAlchemy con consultas nativas usando text(), optimizando el rendimiento y garantizando la seguridad contra inyecciones SQL mediante el binding de parámetros."

3. Modelo de Roles y Relaciones en Base de Datos
"La base de datos maneja un esquema relacional donde la tabla Usuario sirve de entidad central. Mediante joins LEFT JOIN con las tablas específicas Instructor y Aprendiz, determinamos dinámicamente el rol del usuario durante la autenticación sin duplicar información personal."

4. Integración del Frontend (React + Vite)
"El frontend fue desarrollado con React modularizando componentes clave y gestionando estados con useState. Las peticiones HTTP se comunican directamente con los endpoints del backend en FastAPI, capturando respuestas o posibles excepciones de error para retroalimentar dinámicamente la experiencia del usuario final."
-->
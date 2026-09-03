from typing import List, Optional
from datetime import datetime

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from sqlalchemy import text

from .database import get_db, engine
from . import models, schemas


# ============================================================
# CREAR TABLAS EN LA BASE DE DATOS SI NO EXISTEN
# ============================================================

models.Base.metadata.create_all(bind=engine)


# ============================================================
# CONFIGURACIÓN DE FASTAPI
# ============================================================

app = FastAPI(
    title="SIRA API",
    version="1.0.0",
    description="API RESTful backend para la gestión de entregas y retroalimentaciones SIRA."
)


# ============================================================
# CONFIGURACIÓN DE CORS
# Conexión con React / Vite
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# ESQUEMAS DE AUTENTICACIÓN
# ============================================================

class LoginRequest(BaseModel):
    username: str
    password: str


# ============================================================
# RUTA PRINCIPAL
# ============================================================

@app.get("/", tags=["Inicio"])
def inicio():
    return {
        "mensaje": "API SIRA funcionando correctamente",
        "version": "1.0.0"
    }


# ============================================================
# AUTENTICACIÓN
# ============================================================

@app.post("/api/login", tags=["Autenticación"])
def login(
    credentials: LoginRequest,
    db: Session = Depends(get_db)
):
    """
    Verifica las credenciales del usuario utilizando
    email y contraseña.

    Retorna información básica del usuario y su rol.
    """

    # Mostrar en consola los datos recibidos
    print(
        f"--> Intento de Login | "
        f"Usuario/Email: {credentials.username} | "
        f"Contraseña: {credentials.password}"
    )

    query = text("""
        SELECT
            u.id_usuario,
            u.nombres,
            u.apellidos,
            u.email,
            u.password AS contrasena,

            CASE
                WHEN i.id_instructor IS NOT NULL THEN 'INSTRUCTOR'
                WHEN a.id_aprendiz IS NOT NULL THEN 'APRENDIZ'
                ELSE 'USUARIO'
            END AS rol

        FROM Usuario u

        LEFT JOIN Instructor i
            ON i.id_instructor = u.id_usuario

        LEFT JOIN Aprendiz a
            ON a.id_aprendiz = u.id_usuario

        WHERE u.email = :email;
    """)

    user = (
        db.execute(
            query,
            {"email": credentials.username}
        )
        .mappings()
        .first()
    )

    # Validar usuario y contraseña
    if not user or user["contrasena"] != credentials.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas"
        )

    nombre_completo = (
        f"{user['nombres']} {user['apellidos']}"
    )

    return {
        "token": f"fake-jwt-token-{user['id_usuario']}",
        "usuario": nombre_completo,
        "id_usuario": user["id_usuario"],
        "rol": user["rol"]
    }


# ============================================================
# 1. USUARIOS
# ============================================================


# ------------------------------------------------------------
# CREAR USUARIO
# ------------------------------------------------------------

@app.post(
    "/usuarios",
    response_model=schemas.UsuarioResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Usuarios"]
)
def crear_usuario(
    usuario: schemas.UsuarioCreate,
    db: Session = Depends(get_db)
):

    # Verificar si el email ya existe
    usuario_existente = (
        db.query(models.Usuario)
        .filter(models.Usuario.email == usuario.email)
        .first()
    )

    if usuario_existente:
        raise HTTPException(
            status_code=400,
            detail="El email ya se encuentra registrado"
        )

    # Convertir los datos recibidos a diccionario
    datos_usuario = usuario.model_dump()

    # --------------------------------------------------------
    # IMPORTANTE:
    # El frontend/schema utiliza "contrasena"
    # pero la tabla/modelo utiliza "password".
    # --------------------------------------------------------

    if "contrasena" in datos_usuario:
        datos_usuario["password"] = datos_usuario.pop("contrasena")

    # Crear usuario
    nuevo_usuario = models.Usuario(**datos_usuario)

    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)

    return nuevo_usuario


# ------------------------------------------------------------
# LISTAR USUARIOS
# ------------------------------------------------------------

@app.get(
    "/usuarios",
    response_model=List[schemas.UsuarioResponse],
    tags=["Usuarios"]
)
def listar_usuarios(
    skip: int = 0,
    limit: int = 10,
    db: Session = Depends(get_db)
):

    return (
        db.query(models.Usuario)
        .offset(skip)
        .limit(limit)
        .all()
    )


# ------------------------------------------------------------
# OBTENER USUARIO POR ID
# ------------------------------------------------------------

@app.get(
    "/usuarios/{id_usuario}",
    response_model=schemas.UsuarioResponse,
    tags=["Usuarios"]
)
def obtener_usuario(
    id_usuario: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            id_usuario,
            num_documento,
            nombres,
            apellidos,
            email,
            password AS contrasena,
            fecha_registro

        FROM usuario

        WHERE id_usuario = :id_usuario;
    """)

    usuario = (
        db.execute(
            query,
            {"id_usuario": id_usuario}
        )
        .mappings()
        .first()
    )

    if not usuario:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado"
        )

    return dict(usuario)


# ------------------------------------------------------------
# ELIMINAR USUARIO
# ------------------------------------------------------------

@app.delete(
    "/usuarios/{id_usuario}",
    status_code=status.HTTP_200_OK,
    tags=["Usuarios"]
)
def eliminar_usuario(
    id_usuario: int,
    db: Session = Depends(get_db)
):
    """
    Elimina un usuario por su id_usuario.
    """

    usuario = (
        db.query(models.Usuario)
        .filter(
            models.Usuario.id_usuario == id_usuario
        )
        .first()
    )

    if not usuario:
        raise HTTPException(
            status_code=404,
            detail=f"Usuario con ID {id_usuario} no encontrado"
        )

    db.delete(usuario)
    db.commit()

    return {
        "mensaje": (
            f"Usuario con ID {id_usuario} "
            "eliminado correctamente"
        )
    }


# ------------------------------------------------------------
# PERFIL DEL USUARIO
# ------------------------------------------------------------

@app.get(
    "/usuarios/{id_usuario}/perfil",
    tags=["Usuarios"]
)
def obtener_perfil_usuario(
    id_usuario: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            u.id_usuario,
            u.nombres,
            u.apellidos,
            u.email,

            CASE
                WHEN i.id_instructor IS NOT NULL THEN 'INSTRUCTOR'
                WHEN a.id_aprendiz IS NOT NULL THEN 'APRENDIZ'
                ELSE 'USUARIO'
            END AS rol,

            i.acred_lic,
            i.telefono_celular AS tel_instructor,

            a.id_ficha,
            a.celular AS tel_aprendiz

        FROM Usuario u

        LEFT JOIN Instructor i
            ON i.id_instructor = u.id_usuario

        LEFT JOIN Aprendiz a
            ON a.id_aprendiz = u.id_usuario

        WHERE u.id_usuario = :id_usuario;
    """)

    result = (
        db.execute(
            query,
            {"id_usuario": id_usuario}
        )
        .mappings()
        .first()
    )

    if not result:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado"
        )

    return dict(result)


# ------------------------------------------------------------
# NOTIFICACIONES NO LEÍDAS
# ------------------------------------------------------------

@app.get(
    "/usuarios/{id_usuario}/notificaciones-no-leidas",
    tags=["Usuarios"]
)
def notificaciones_no_leidas(
    id_usuario: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            id_notificacion,
            mensaje,
            tipo,
            fecha_envio

        FROM Notificacion

        WHERE id_usuario = :id_usuario
          AND leida = FALSE

        ORDER BY fecha_envio DESC;
    """)

    resultado = (
        db.execute(
            query,
            {"id_usuario": id_usuario}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ============================================================
# 2. ACTIVIDADES
# ============================================================


# ------------------------------------------------------------
# CREAR ACTIVIDAD
# ------------------------------------------------------------

@app.post(
    "/actividades",
    response_model=schemas.ActividadResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Actividades"]
)
def crear_actividad(
    actividad: schemas.ActividadCreate,
    db: Session = Depends(get_db)
):

    # Verificar existencia de la ficha
    ficha = (
        db.query(models.Ficha)
        .filter(
            models.Ficha.id_ficha == actividad.id_ficha
        )
        .first()
    )

    if not ficha:
        raise HTTPException(
            status_code=404,
            detail="La ficha especificada no existe"
        )

    nueva_actividad = models.Actividad(
        **actividad.model_dump()
    )

    db.add(nueva_actividad)
    db.commit()
    db.refresh(nueva_actividad)

    return nueva_actividad


# ------------------------------------------------------------
# LISTAR ACTIVIDADES
# ------------------------------------------------------------

@app.get(
    "/actividades",
    response_model=List[schemas.ActividadResponse],
    tags=["Actividades"]
)
def listar_actividades(
    db: Session = Depends(get_db)
):

    return db.query(
        models.Actividad
    ).all()


# ------------------------------------------------------------
# APRENDICES SIN ENTREGAR
# ------------------------------------------------------------

@app.get(
    "/actividades/{id_actividad}/pendientes-entrega",
    tags=["Actividades"]
)
def aprendices_sin_entregar(
    id_actividad: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            u.nombres,
            u.apellidos,
            u.email

        FROM Aprendiz apr

        JOIN Usuario u
            ON u.id_usuario = apr.id_aprendiz

        LEFT JOIN Entrega e
            ON e.id_aprendiz = apr.id_aprendiz
           AND e.id_actividad = :id_actividad

        WHERE apr.id_ficha = (
            SELECT id_ficha
            FROM Actividad
            WHERE id_actividad = :id_actividad
        )

        AND e.id_entrega IS NULL;
    """)

    resultado = (
        db.execute(
            query,
            {"id_actividad": id_actividad}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ------------------------------------------------------------
# MATERIALES DE UNA ACTIVIDAD
# ------------------------------------------------------------

@app.get(
    "/actividades/{id_actividad}/materiales",
    tags=["Actividades"]
)
def materiales_actividad(
    id_actividad: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            rep.nombre_archivo,
            rep.tipo_formato,
            rep.url_ubicacion,
            rep.fecha_subida

        FROM Repositorio rep

        WHERE rep.id_actividad = :id_actividad

        ORDER BY rep.fecha_subida DESC;
    """)

    resultado = (
        db.execute(
            query,
            {"id_actividad": id_actividad}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ------------------------------------------------------------
# ACTIVIDADES PENDIENTES DE UN APRENDIZ
# ------------------------------------------------------------

@app.get(
    "/aprendices/{id_aprendiz}/actividades-pendientes",
    tags=["Actividades"]
)
def actividades_pendientes(
    id_aprendiz: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            act.id_actividad,
            act.titulo,
            act.fecha_vencimiento,
            act.tipo_actividad,
            f.codigo_ficha

        FROM Actividad act

        JOIN Aprendiz apr
            ON apr.id_ficha = act.id_ficha

        JOIN Ficha f
            ON f.id_ficha = act.id_ficha

        LEFT JOIN Entrega e
            ON e.id_actividad = act.id_actividad
           AND e.id_aprendiz = apr.id_aprendiz

        WHERE apr.id_aprendiz = :id_aprendiz
          AND e.id_entrega IS NULL

        ORDER BY act.fecha_vencimiento ASC;
    """)

    resultado = (
        db.execute(
            query,
            {"id_aprendiz": id_aprendiz}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ------------------------------------------------------------
# AVANCE DE ACTIVIDADES DEL INSTRUCTOR
# ------------------------------------------------------------

@app.get(
    "/instructores/{id_instructor}/actividades-avance",
    tags=["Actividades"]
)
def actividades_avance(
    id_instructor: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            act.id_actividad,
            act.titulo,
            act.fecha_vencimiento,
            f.codigo_ficha,

            COUNT(DISTINCT e.id_entrega)
                AS entregas_recibidas,

            (
                SELECT COUNT(*)
                FROM Aprendiz
                WHERE id_ficha = f.id_ficha
            ) AS total_aprendices

        FROM Actividad act

        JOIN Ficha f
            ON f.id_ficha = act.id_ficha

        LEFT JOIN Entrega e
            ON e.id_actividad = act.id_actividad

        WHERE act.id_instructor = :id_instructor

        GROUP BY
            act.id_actividad,
            act.titulo,
            act.fecha_vencimiento,
            f.codigo_ficha,
            f.id_ficha

        ORDER BY act.fecha_vencimiento DESC;
    """)

    resultado = (
        db.execute(
            query,
            {"id_instructor": id_instructor}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ============================================================
# 3. ENTREGAS
# ============================================================


# ------------------------------------------------------------
# CREAR ENTREGA
# ------------------------------------------------------------

@app.post(
    "/entregas",
    response_model=schemas.EntregaResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Entregas"]
)
def crear_entrega(
    entrega: schemas.EntregaCreate,
    db: Session = Depends(get_db)
):

    actividad = (
        db.query(models.Actividad)
        .filter(
            models.Actividad.id_actividad
            == entrega.id_actividad
        )
        .first()
    )

    if not actividad:
        raise HTTPException(
            status_code=404,
            detail="La actividad no existe"
        )

    # Verificar fecha de vencimiento
    if datetime.utcnow() > actividad.fecha_vencimiento:
        raise HTTPException(
            status_code=400,
            detail=(
                "El plazo de entrega para esta "
                "actividad ha expirado"
            )
        )

    nueva_entrega = models.Entrega(
        **entrega.model_dump()
    )

    db.add(nueva_entrega)
    db.commit()
    db.refresh(nueva_entrega)

    return nueva_entrega


# ------------------------------------------------------------
# OBTENER ENTREGA
# ------------------------------------------------------------

@app.get(
    "/entregas/{id_entrega}",
    response_model=schemas.EntregaResponse,
    tags=["Entregas"]
)
def obtener_entrega(
    id_entrega: int,
    db: Session = Depends(get_db)
):

    entrega = (
        db.query(models.Entrega)
        .filter(
            models.Entrega.id_entrega == id_entrega
        )
        .first()
    )

    if not entrega:
        raise HTTPException(
            status_code=404,
            detail="Entrega no encontrada"
        )

    return entrega


# ------------------------------------------------------------
# DETALLE DE ENTREGA
# ------------------------------------------------------------

@app.get(
    "/entregas/{id_entrega}/detalle",
    tags=["Entregas"]
)
def detalle_entrega(
    id_entrega: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            e.id_entrega,
            e.fecha_entrega,
            e.estado,

            r.nota,
            r.descripcion,
            r.fecha_calificacion,

            rep.nombre_archivo,
            rep.url_ubicacion

        FROM Entrega e

        LEFT JOIN Retroalimentacion r
            ON r.id_entrega = e.id_entrega

        LEFT JOIN Repositorio rep
            ON rep.id_entrega = e.id_entrega

        WHERE e.id_entrega = :id_entrega;
    """)

    result = (
        db.execute(
            query,
            {"id_entrega": id_entrega}
        )
        .mappings()
        .first()
    )

    if not result:
        raise HTTPException(
            status_code=404,
            detail="Entrega no encontrada"
        )

    return dict(result)


# ------------------------------------------------------------
# HISTORIAL DE ENTREGAS DEL APRENDIZ
# ------------------------------------------------------------

@app.get(
    "/aprendices/{id_aprendiz}/historial-entregas",
    tags=["Entregas"]
)
def historial_entregas(
    id_aprendiz: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            act.titulo,
            e.fecha_entrega,
            e.estado,
            r.nota,
            r.descripcion AS retro_descripcion,
            r.fecha_calificacion

        FROM Entrega e

        JOIN Actividad act
            ON act.id_actividad = e.id_actividad

        LEFT JOIN Retroalimentacion r
            ON r.id_entrega = e.id_entrega

        WHERE e.id_aprendiz = :id_aprendiz

        ORDER BY e.fecha_entrega DESC;
    """)

    resultado = (
        db.execute(
            query,
            {"id_aprendiz": id_aprendiz}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ------------------------------------------------------------
# ENTREGAS PENDIENTES DE EVALUAR
# ------------------------------------------------------------

@app.get(
    "/instructores/{id_instructor}/entregas-pendientes",
    tags=["Entregas"]
)
def entregas_pendientes_evaluar(
    id_instructor: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            e.id_entrega,
            u.nombres,
            u.apellidos,
            act.titulo,
            e.fecha_entrega

        FROM Entrega e

        JOIN Actividad act
            ON act.id_actividad = e.id_actividad

        JOIN Aprendiz apr
            ON apr.id_aprendiz = e.id_aprendiz

        JOIN Usuario u
            ON u.id_usuario = apr.id_aprendiz

        WHERE act.id_instructor = :id_instructor
          AND e.estado = 'ENVIADO'

        ORDER BY e.fecha_entrega ASC;
    """)

    resultado = (
        db.execute(
            query,
            {"id_instructor": id_instructor}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ============================================================
# 4. RETROALIMENTACIÓN
# ============================================================


# ------------------------------------------------------------
# CALIFICAR ENTREGA
# ------------------------------------------------------------

@app.post(
    "/retroalimentaciones",
    response_model=schemas.RetroalimentacionResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Retroalimentación"]
)
def calificar_entrega(
    retro: schemas.RetroalimentacionCreate,
    db: Session = Depends(get_db)
):

    # Verificar que exista la entrega
    entrega = (
        db.query(models.Entrega)
        .filter(
            models.Entrega.id_entrega
            == retro.id_entrega
        )
        .first()
    )

    if not entrega:
        raise HTTPException(
            status_code=404,
            detail="Entrega no encontrada"
        )

    # Verificar si ya fue calificada
    retro_existente = (
        db.query(models.Retroalimentacion)
        .filter(
            models.Retroalimentacion.id_entrega
            == retro.id_entrega
        )
        .first()
    )

    if retro_existente:
        raise HTTPException(
            status_code=400,
            detail="Esta entrega ya ha sido calificada"
        )

    # Crear retroalimentación
    nueva_retro = models.Retroalimentacion(
        **retro.model_dump()
    )

    db.add(nueva_retro)
    db.commit()

    db.refresh(nueva_retro)
    db.refresh(entrega)

    return nueva_retro


# ------------------------------------------------------------
# COMENTARIOS DE RETROALIMENTACIÓN
# ------------------------------------------------------------

@app.get(
    "/retroalimentaciones/{id_retro}/comentarios",
    tags=["Retroalimentación"]
)
def comentarios_retroalimentacion(
    id_retro: int,
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            c.id_comentario,
            u.nombres,
            u.apellidos,
            c.texto_comentario,
            c.fecha_comentario

        FROM Comentario c

        JOIN Usuario u
            ON u.id_usuario = c.id_usuario

        WHERE c.id_retroalimentacion = :id_retro

        ORDER BY c.fecha_comentario ASC;
    """)

    resultado = (
        db.execute(
            query,
            {"id_retro": id_retro}
        )
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ============================================================
# 5. FICHAS Y REPORTES
# ============================================================


# ------------------------------------------------------------
# PROMEDIO DE NOTAS POR FICHA
# ------------------------------------------------------------

@app.get(
    "/fichas/promedio-notas",
    tags=["Fichas y Reportes"]
)
def promedio_notas_fichas(
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            f.codigo_ficha,

            ROUND(
                AVG(r.nota),
                2
            ) AS promedio_nota,

            COUNT(
                r.id_retroalimentacion
            ) AS total_calificaciones

        FROM Ficha f

        JOIN Aprendiz apr
            ON apr.id_ficha = f.id_ficha

        JOIN Entrega e
            ON e.id_aprendiz = apr.id_aprendiz

        JOIN Retroalimentacion r
            ON r.id_entrega = e.id_entrega

        GROUP BY
            f.id_ficha,
            f.codigo_ficha

        ORDER BY promedio_nota DESC;
    """)

    resultado = (
        db.execute(query)
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]


# ------------------------------------------------------------
# RESUMEN DE FICHAS Y PROGRAMAS
# ------------------------------------------------------------

@app.get(
    "/fichas/resumen-programas",
    tags=["Fichas y Reportes"]
)
def resumen_fichas_programas(
    db: Session = Depends(get_db)
):

    query = text("""
        SELECT
            pf.nombre_programa,
            f.codigo_ficha,
            f.jornada,

            CONCAT(
                ui.nombres,
                ' ',
                ui.apellidos
            ) AS instructor_lider,

            COUNT(
                apr.id_aprendiz
            ) AS total_aprendices

        FROM Ficha f

        JOIN Programa_Formacion pf
            ON pf.id_programa = f.id_programa

        JOIN Instructor ins
            ON ins.id_instructor = f.id_instructor

        JOIN Usuario ui
            ON ui.id_usuario = ins.id_instructor

        LEFT JOIN Aprendiz apr
            ON apr.id_ficha = f.id_ficha

        GROUP BY
            pf.nombre_programa,
            f.id_ficha,
            f.codigo_ficha,
            f.jornada,
            ui.nombres,
            ui.apellidos

        ORDER BY
            pf.nombre_programa,
            f.codigo_ficha;
    """)

    resultado = (
        db.execute(query)
        .mappings()
        .all()
    )

    return [
        dict(row)
        for row in resultado
    ]
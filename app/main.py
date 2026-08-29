from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app import models, schemas
from app.database import get_db, engine
from app.config import settings

models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API RESTful backend para la gestión de entregas y retroalimentaciones SIRA."
)

# --- USUARIOS ---
@app.post("/usuarios", response_model=schemas.UsuarioResponse, status_code=status.HTTP_201_CREATED, tags=["Usuarios"])
def crear_usuario(usuario: schemas.UsuarioCreate, db: Session = Depends(get_db)):
    if db.query(models.Usuario).filter(models.Usuario.email == usuario.email).first():
        raise HTTPException(status_code=400, detail="El email ya se encuentra registrado")
    
    nuevo_usuario = models.Usuario(**usuario.model_dump())
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario

@app.get("/usuarios", response_model=List[schemas.UsuarioResponse], tags=["Usuarios"])
def listar_usuarios(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return db.query(models.Usuario).offset(skip).limit(limit).all()

@app.get("/usuarios/{id_usuario}", response_model=schemas.UsuarioResponse, tags=["Usuarios"])
def obtener_usuario(id_usuario: int, db: Session = Depends(get_db)):
    usuario = db.query(models.Usuario).filter(models.Usuario.id_usuario == id_usuario).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return usuario

# --- ACTIVIDADES ---
@app.post("/actividades", response_model=schemas.ActividadResponse, status_code=status.HTTP_201_CREATED, tags=["Actividades"])
def crear_actividad(actividad: schemas.ActividadCreate, db: Session = Depends(get_db)):
    if not db.query(models.Ficha).filter(models.Ficha.id_ficha == actividad.id_ficha).first():
        raise HTTPException(status_code=404, detail="La ficha especificada no existe")
    
    nueva_actividad = models.Actividad(**actividad.model_dump())
    db.add(nueva_actividad)
    db.commit()
    db.refresh(nueva_actividad)
    return nueva_actividad

@app.get("/actividades", response_model=List[schemas.ActividadResponse], tags=["Actividades"])
def listar_actividades(db: Session = Depends(get_db)):
    return db.query(models.Actividad).all()

# --- ENTREGAS ---
@app.post("/entregas", response_model=schemas.EntregaResponse, status_code=status.HTTP_201_CREATED, tags=["Entregas"])
def crear_entrega(entrega: schemas.EntregaCreate, db: Session = Depends(get_db)):
    actividad = db.query(models.Actividad).filter(models.Actividad.id_actividad == entrega.id_actividad).first()
    if not actividad:
        raise HTTPException(status_code=404, detail="La actividad no existe")
    
    if datetime.utcnow() > actividad.fecha_vencimiento:
        raise HTTPException(status_code=400, detail="El plazo de entrega para esta actividad ha expirado")
    
    nueva_entrega = models.Entrega(**entrega.model_dump())
    db.add(nueva_entrega)
    db.commit()
    db.refresh(nueva_entrega)
    return nueva_entrega

@app.get("/entregas/{id_entrega}", response_model=schemas.EntregaResponse, tags=["Entregas"])
def obtener_entrega(id_entrega: int, db: Session = Depends(get_db)):
    entrega = db.query(models.Entrega).filter(models.Entrega.id_entrega == id_entrega).first()
    if not entrega:
        raise HTTPException(status_code=404, detail="Entrega no encontrada")
    return entrega

# --- RETROALIMENTACIÓN ---
@app.post("/retroalimentaciones", response_model=schemas.RetroalimentacionResponse, status_code=status.HTTP_201_CREATED, tags=["Retroalimentación"])
def calificar_entrega(retro: schemas.RetroalimentacionCreate, db: Session = Depends(get_db)):
    entrega = db.query(models.Entrega).filter(models.Entrega.id_entrega == retro.id_entrega).first()
    if not entrega:
        raise HTTPException(status_code=404, detail="Entrega no encontrada")
    
    if db.query(models.Retroalimentacion).filter(models.Retroalimentacion.id_entrega == retro.id_entrega).first():
        raise HTTPException(status_code=400, detail="Esta entrega ya ha sido calificada")

    nueva_retro = models.Retroalimentacion(**retro.model_dump())
    db.add(nueva_retro)
    db.commit()
    db.refresh(nueva_retro)
    db.refresh(entrega)
    
    return nueva_retro
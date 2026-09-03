from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional, List

# Usuario
class UsuarioBase(BaseModel):
    num_documento: str = Field(..., max_length=20)
    nombres: str = Field(..., max_length=100)
    apellidos: str = Field(..., max_length=100)
    email: EmailStr

class UsuarioCreate(UsuarioBase):
    contrasena: str  # Útil al momento de registrar un usuario

class UsuarioResponse(UsuarioBase):
    id_usuario: int
    contrasena: str  # <--- AGREGAR AQUÍ para que FastAPI la incluya en la respuesta
    fecha_registro: datetime

    class Config:
        from_attributes = True

# Ficha
class FichaBase(BaseModel):
    codigo_ficha: str
    nombre_programa: str

class FichaCreate(FichaBase):
    pass

class FichaResponse(FichaBase):
    id_ficha: int

    class Config:
        from_attributes = True

# Actividad
class ActividadBase(BaseModel):
    titulo: str
    descripcion: Optional[str] = None
    fecha_vencimiento: datetime
    tipo_actividad: Optional[str] = None
    id_instructor: int
    id_ficha: int

class ActividadCreate(ActividadBase):
    pass

class ActividadResponse(ActividadBase):
    id_actividad: int

    class Config:
        from_attributes = True

# Entrega
class EntregaBase(BaseModel):
    id_actividad: int
    id_aprendiz: int

class EntregaCreate(EntregaBase):
    pass

class EntregaResponse(EntregaBase):
    id_entrega: int
    fecha_entrega: datetime
    estado: str

    class Config:
        from_attributes = True

# Retroalimentación
class RetroalimentacionCreate(BaseModel):
    id_entrega: int
    id_instructor: int
    nota: float = Field(..., ge=0.0, le=5.0)
    descripcion: Optional[str] = None

class RetroalimentacionResponse(BaseModel):
    id_retroalimentacion: int
    id_entrega: int
    id_instructor: int
    nota: float
    descripcion: Optional[str]
    fecha_calificacion: datetime

    class Config:
        from_attributes = True
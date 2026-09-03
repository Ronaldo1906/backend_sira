from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime
from typing import Optional, List


# ============================================================
# USUARIO
# ============================================================

class UsuarioBase(BaseModel):
    num_documento: str = Field(..., max_length=20)
    nombres: str = Field(..., max_length=100)
    apellidos: str = Field(..., max_length=100)
    email: EmailStr


class UsuarioCreate(UsuarioBase):
    # Útil al momento de registrar un usuario
    contrasena: str


class UsuarioResponse(UsuarioBase):
    id_usuario: int

    # Mapea el atributo "password" del modelo de BD
    # a la clave "contrasena" del esquema
    contrasena: str = Field(validation_alias="password")

    fecha_registro: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )


# ============================================================
# FICHA
# ============================================================

class FichaBase(BaseModel):
    codigo_ficha: str
    nombre_programa: str


class FichaCreate(FichaBase):
    pass


class FichaResponse(FichaBase):
    id_ficha: int

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# ACTIVIDAD
# ============================================================

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

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# ENTREGA
# ============================================================

class EntregaBase(BaseModel):
    id_actividad: int
    id_aprendiz: int


class EntregaCreate(EntregaBase):
    pass


class EntregaResponse(EntregaBase):
    id_entrega: int
    fecha_entrega: datetime
    estado: str

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# RETROALIMENTACIÓN
# ============================================================

class RetroalimentacionCreate(BaseModel):
    id_entrega: int
    id_instructor: int

    # La nota debe estar entre 0.0 y 5.0
    nota: float = Field(
        ...,
        ge=0.0,
        le=5.0
    )

    descripcion: Optional[str] = None


class RetroalimentacionResponse(BaseModel):
    id_retroalimentacion: int
    id_entrega: int
    id_instructor: int
    nota: float
    descripcion: Optional[str]
    fecha_calificacion: datetime

    model_config = ConfigDict(
        from_attributes=True
    )
from sqlalchemy import Column, Integer, String, DateTime, Date, ForeignKey, Text, Numeric, Enum, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base
 
 
class Usuario(Base):
    __tablename__ = "Usuario"
 
    id_usuario = Column(Integer, primary_key=True, index=True, autoincrement=True)
    num_documento = Column(String(20), unique=True, nullable=False)
    nombres = Column(String(100), nullable=False)
    apellidos = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password = Column(String(20), nullable=False)  # texto plano solo para pruebas
    fecha_registro = Column(DateTime, default=datetime.utcnow)
 
    aprendiz = relationship("Aprendiz", back_populates="usuario", uselist=False)
    instructor = relationship("Instructor", back_populates="usuario", uselist=False)
    comentarios = relationship("Comentario", back_populates="usuario")
    notificaciones = relationship("Notificacion", back_populates="usuario")
 
 
class Instructor(Base):
    __tablename__ = "Instructor"
 
    # id_instructor ES id_usuario (llave compartida, igual que en la BD)
    id_instructor = Column(Integer, ForeignKey("Usuario.id_usuario"), primary_key=True)
    acred_lic = Column(String(50), nullable=True)
    telefono_celular = Column(String(20), nullable=True)
    telefono_fijo = Column(String(20), nullable=True)
 
    usuario = relationship("Usuario", back_populates="instructor")
    fichas = relationship("Ficha", back_populates="instructor")
    actividades = relationship("Actividad", back_populates="instructor")
    retroalimentaciones = relationship("Retroalimentacion", back_populates="instructor")
    repositorios = relationship("Repositorio", back_populates="instructor")
 
 
class Programa_Formacion(Base):
    __tablename__ = "Programa_Formacion"
 
    id_programa = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre_programa = Column(String(150), nullable=False)
 
    fichas = relationship("Ficha", back_populates="programa")
 
 
class Ficha(Base):
    __tablename__ = "Ficha"
 
    id_ficha = Column(Integer, primary_key=True, index=True, autoincrement=True)
    numero_ficha = Column(String(20), unique=True, nullable=False)
    jornada = Column(String(30), nullable=False)
    fecha_inicio = Column(Date, nullable=True)
    fecha_fin = Column(Date, nullable=True)
    id_programa = Column(Integer, ForeignKey("Programa_Formacion.id_programa"), nullable=False)
    id_instructor = Column(Integer, ForeignKey("Instructor.id_instructor"), nullable=False)
 
    programa = relationship("Programa_Formacion", back_populates="fichas")
    instructor = relationship("Instructor", back_populates="fichas")
    aprendices = relationship("Aprendiz", back_populates="ficha")
    actividades = relationship("Actividad", back_populates="ficha")
 
 
class Aprendiz(Base):
    __tablename__ = "Aprendiz"
 
    # id_aprendiz ES id_usuario (llave compartida, igual que en la BD)
    id_aprendiz = Column(Integer, ForeignKey("Usuario.id_usuario"), primary_key=True)
    id_ficha = Column(Integer, ForeignKey("Ficha.id_ficha"), nullable=False)
    celular = Column(String(20), nullable=True)
 
    usuario = relationship("Usuario", back_populates="aprendiz")
    ficha = relationship("Ficha", back_populates="aprendices")
    entregas = relationship("Entrega", back_populates="aprendiz")
 
 
class Competencia(Base):
    __tablename__ = "Competencia"
 
    id_competencia = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre_competencia = Column(String(150), nullable=False)
    duracion_horas = Column(Integer, nullable=True)
 
    resultados = relationship("Resultado_Aprendizaje", back_populates="competencia")
 
 
class Resultado_Aprendizaje(Base):
    __tablename__ = "Resultado_Aprendizaje"
 
    id_resultado = Column(Integer, primary_key=True, index=True, autoincrement=True)
    descripcion = Column(Text, nullable=False)
    duracion_horas = Column(Integer, nullable=True)
    id_competencia = Column(Integer, ForeignKey("Competencia.id_competencia"), nullable=False)
 
    competencia = relationship("Competencia", back_populates="resultados")
    actividades = relationship("Actividad", back_populates="resultado")
 
 
class Actividad(Base):
    __tablename__ = "Actividad"
 
    id_actividad = Column(Integer, primary_key=True, index=True, autoincrement=True)
    titulo = Column(String(150), nullable=False)
    descripcion = Column(Text, nullable=True)
    fecha_vencimiento = Column(DateTime, nullable=False)
    tipo_actividad = Column(String(50), nullable=True)
    id_instructor = Column(Integer, ForeignKey("Instructor.id_instructor"), nullable=False)
    id_ficha = Column(Integer, ForeignKey("Ficha.id_ficha"), nullable=False)
    id_resultado = Column(Integer, ForeignKey("Resultado_Aprendizaje.id_resultado"), nullable=True)
 
    instructor = relationship("Instructor", back_populates="actividades")
    ficha = relationship("Ficha", back_populates="actividades")
    resultado = relationship("Resultado_Aprendizaje", back_populates="actividades")
    entregas = relationship("Entrega", back_populates="actividad")
    repositorios = relationship("Repositorio", back_populates="actividad")
 
 
class Entrega(Base):
    __tablename__ = "Entrega"
 
    id_entrega = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_actividad = Column(Integer, ForeignKey("Actividad.id_actividad"), nullable=False)
    id_aprendiz = Column(Integer, ForeignKey("Aprendiz.id_aprendiz"), nullable=False)
    fecha_entrega = Column(DateTime, default=datetime.utcnow)
    estado = Column(Enum('ENVIADO', 'EVALUADO', 'CORREGIR'), default='ENVIADO')
 
    actividad = relationship("Actividad", back_populates="entregas")
    aprendiz = relationship("Aprendiz", back_populates="entregas")
    retroalimentacion = relationship("Retroalimentacion", back_populates="entrega", uselist=False)
    repositorio = relationship("Repositorio", back_populates="entrega", uselist=False)
 
 
class Retroalimentacion(Base):
    __tablename__ = "Retroalimentacion"
 
    id_retroalimentacion = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_entrega = Column(Integer, ForeignKey("Entrega.id_entrega"), unique=True, nullable=False)
    id_instructor = Column(Integer, ForeignKey("Instructor.id_instructor"), nullable=False)
    nota = Column(Numeric(4, 2), nullable=False)
    descripcion = Column(Text, nullable=True)
    fecha_calificacion = Column(DateTime, default=datetime.utcnow)
 
    entrega = relationship("Entrega", back_populates="retroalimentacion")
    instructor = relationship("Instructor", back_populates="retroalimentaciones")
    comentarios = relationship("Comentario", back_populates="retroalimentacion")
 
 
class Comentario(Base):
    __tablename__ = "Comentario"
 
    id_comentario = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_retroalimentacion = Column(Integer, ForeignKey("Retroalimentacion.id_retroalimentacion"), nullable=False)
    id_usuario = Column(Integer, ForeignKey("Usuario.id_usuario"), nullable=False)
    texto_comentario = Column(Text, nullable=False)
    fecha_comentario = Column(DateTime, default=datetime.utcnow)
 
    retroalimentacion = relationship("Retroalimentacion", back_populates="comentarios")
    usuario = relationship("Usuario", back_populates="comentarios")
 
 
class Repositorio(Base):
    __tablename__ = "Repositorio"
 
    id_repositorio = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre_archivo = Column(String(150), nullable=False)
    tipo_formato = Column(String(20), nullable=True)
    url_ubicacion = Column(String(255), nullable=False)
    fecha_subida = Column(DateTime, default=datetime.utcnow)
    tamanio = Column(Integer, nullable=True)  # en KB
    id_instructor = Column(Integer, ForeignKey("Instructor.id_instructor"), nullable=True)
    id_actividad = Column(Integer, ForeignKey("Actividad.id_actividad"), nullable=True)
    id_entrega = Column(Integer, ForeignKey("Entrega.id_entrega"), unique=True, nullable=True)
    # Regla de exclusividad (id_actividad XOR id_entrega) va como CHECK a nivel de BD;
    # valídala también en la capa de servicio/schema de FastAPI antes de insertar.
 
    instructor = relationship("Instructor", back_populates="repositorios")
    actividad = relationship("Actividad", back_populates="repositorios")
    entrega = relationship("Entrega", back_populates="repositorio")
 
 
class Notificacion(Base):
    __tablename__ = "Notificacion"
 
    id_notificacion = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_usuario = Column(Integer, ForeignKey("Usuario.id_usuario"), nullable=False)
    mensaje = Column(Text, nullable=False)
    tipo = Column(String(30), nullable=True)
    leida = Column(Boolean, default=False)
    fecha_envio = Column(DateTime, default=datetime.utcnow)
 
    usuario = relationship("Usuario", back_populates="notificaciones")
 
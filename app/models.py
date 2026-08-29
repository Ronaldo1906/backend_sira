from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Numeric, Enum
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
    fecha_registro = Column(DateTime, default=datetime.utcnow)

    aprendiz = relationship("Aprendiz", back_populates="usuario", uselist=False)
    instructor = relationship("Instructor", back_populates="usuario", uselist=False)


class Ficha(Base):
    __tablename__ = "Ficha"

    id_ficha = Column(Integer, primary_key=True, index=True, autoincrement=True)
    codigo_ficha = Column(String(20), unique=True, nullable=False)
    nombre_programa = Column(String(150), nullable=False)

    aprendices = relationship("Aprendiz", back_populates="ficha")
    actividades = relationship("Actividad", back_populates="ficha")


class Aprendiz(Base):
    __tablename__ = "Aprendiz"

    id_aprendiz = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_usuario = Column(Integer, ForeignKey("Usuario.id_usuario"), unique=True, nullable=False)
    id_ficha = Column(Integer, ForeignKey("Ficha.id_ficha"), nullable=False)

    usuario = relationship("Usuario", back_populates="aprendiz")
    ficha = relationship("Ficha", back_populates="aprendices")
    entregas = relationship("Entrega", back_populates="aprendiz")


class Instructor(Base):
    __tablename__ = "Instructor"

    id_instructor = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_usuario = Column(Integer, ForeignKey("Usuario.id_usuario"), unique=True, nullable=False)
    especialidad = Column(String(100), nullable=False)

    usuario = relationship("Usuario", back_populates="instructor")
    actividades = relationship("Actividad", back_populates="instructor")
    retroalimentaciones = relationship("Retroalimentacion", back_populates="instructor")


class Actividad(Base):
    __tablename__ = "Actividad"

    id_actividad = Column(Integer, primary_key=True, index=True, autoincrement=True)
    titulo = Column(String(150), nullable=False)
    descripcion = Column(Text, nullable=True)
    fecha_vencimiento = Column(DateTime, nullable=False)
    tipo_actividad = Column(String(50), nullable=True)
    id_instructor = Column(Integer, ForeignKey("Instructor.id_instructor"), nullable=False)
    id_ficha = Column(Integer, ForeignKey("Ficha.id_ficha"), nullable=False)

    instructor = relationship("Instructor", back_populates="actividades")
    ficha = relationship("Ficha", back_populates="actividades")
    entregas = relationship("Entrega", back_populates="actividad")


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
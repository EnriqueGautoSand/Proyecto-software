from flask_appbuilder import Model
from sqlalchemy import Column, Integer, String, ForeignKey,Float,Date, Boolean, UniqueConstraint
from sqlalchemy.orm import relationship
from flask_appbuilder.models.decorators import renders
from flask_appbuilder.models.mixins import AuditMixin
from . import appbuilder, db
from flask_appbuilder.security.sqla.models import User
from flask import Markup, url_for, redirect
import enum
from sqlalchemy import Enum

class TipoClaves(enum.Enum):
    """
    # creo clase que enumera los tipos de clave
    """
    consumidorFinal="Consumidor Final"
    responsableInscripto="Responsable Inscripto"
    monotributista="Monotributista"

    #defino como se representara al ser llamado
    def __str__(self):
        return f'{self.value}'
    def __repr__(self):
        return f'{self.value}'

class tiposDocumentos(enum.Enum):
    """
    creo clase que enumera los tipos de documento
    """
    DNI="DNI"
    CUIT="CUIT"
    CDI="CDI"
    LE = "LE"
    LC ="LC"
    CI_extranjera="CI extranjera"
    Pasaporte="Pasaporte"
    CI_PoliciaFederal="CI PoliciaFederal"
    CertificadodeMigracion="Certificado de Migracion"

    # defino como se representara al ser llamado
    def __str__(self):
        return f'{self.value}'
    def __repr__(self):
        return f'{self.value}'
class Proveedor(Model,AuditMixin):
    """
    creo clase que sera mapeada como la tabla Proveedor en la base de datos
    """
    __tablename__ = 'proveedor'
    id = Column(Integer, primary_key=True)
    cuit=Column(String(30),nullable=False,unique=True)
    nombre = Column(String(30))
    apellido = Column(String(30))
    domicilio =Column(String(255))
    correo = Column(String(100))
    estado = Column(Boolean,default=True)

    # defino como se representara al ser llamado
    def __repr__(self):
        return f"Cuit {self.cuit} {self.apellido} {self.nombre}"

class Clientes(Model,AuditMixin):
    """
    creo clase que sera mapeada como la tabla clientes en la base de datos
    """
    __tablename__ = 'clientes'
    id = Column(Integer, primary_key=True)
    documento=Column(String(30),nullable=False)
    nombre = Column(String(30))
    apellido = Column(String(30))
    condicionFrenteIva = Column(Enum(TipoClaves))
    tipoDocumento=Column(Enum(tiposDocumentos))
    estado = Column(Boolean,default=True)
    #creo clave compuesta que no se pueden repetir dicha combinacion
    __table_args__ = (
        UniqueConstraint("tipoDocumento","documento"),
    )

    # defino como se representara al ser llamado
    def __repr__(self):
        if self.documento=="Consumidor Final" :
            return "Consumidor Final"

        return f"{self.nombre} {self.apellido} {self.tipoDocumento} {self.documento} {self.condicionFrenteIva} "

class FormadePago(Model):
    """
    creo clase que sera mapeada como la tabla formadepago en la base de datos
    """
    __tablename__= 'formadepago'
    id=Column(Integer, primary_key=True)
    Metodo=Column(String(30), unique=True)

    # defino como se representara al ser llamado esto es util para las ver tablas foraneas
    def __repr__(self):
        return self.Metodo

class Compra(Model):
    """
    creo clase que sera mapeada como la tabla ventas en la base de datos
    """
    __tablename__= 'compras'
    id=Column(Integer, primary_key=True)
    Estado=Column(Boolean)
    total=Column(Float, nullable=False)
    fecha=Column(Date, nullable=False)
    cliente_id = Column(Integer, ForeignKey('proveedor.id'), nullable=False)
    cliente = relationship("Proveedor")
    formadepago_id = Column(Integer, ForeignKey('formadepago.id'), nullable=False)
    formadepago = relationship("FormadePago")


class Venta(Model):
    """
    creo clase que sera mapeada como la tabla ventas en la base de datos
    """
    __tablename__= 'ventas'
    id=Column(Integer, primary_key=True)
    Estado=Column(Boolean)
    total=Column(Float, nullable=False)
    cliente_id = Column(Integer, ForeignKey('clientes.id'), nullable=False)
    cliente = relationship("Clientes")
    formadepago_id = Column(Integer, ForeignKey('formadepago.id'), nullable=False)
    formadepago = relationship("FormadePago")

    @renders('total')
    def totalrender(self):
         return Markup('<b> $' + str(self.total) + '</b>')
    @renders('estado')
    def estadorender(self):
            if self.Estado:
                return Markup('<b> Venta Realizada </b>')
            return Markup('<b> Venta Anulada </b>')
    @renders('renglones')
    def renglonesrender(self):
    # will render this columns as lista
        print(self.renglones)
        renglones="</table> <table class='table table-bordered'> <tr><td>Producto</td> <td>Precio</td><td>Cantidad</td><td>Subtotal</td></tr>"
        from .views import RenglonVentas
        total=0
        for i in  self.renglones:
            print(type(i))
            print(f'{redirect(url_for("RenglonVentas.edit",pk=i.id))}')
            #el editar era en caso de que quisiera darle el permiso de editar una venta pero decidi que no.
            editar=f"<td><a  href='http://localhost:8080/renglonventas/edit/{i.id}' class='btn btn-sm btn-default'> <i class='fa fa-edit' ></i></a></td>"

            unrenglon=f"<tr><td>{i.producto}</td> <td>${i.precioVenta}</td><td>{i.cantidad}</td><td>${i.precioVenta*i.cantidad}</td></tr> "
            renglones+=unrenglon+'\n'
            total+=i.precioVenta*i.cantidad

        renglones+=f"<tr><td></td><td></td><td>Total</td> <td>${total}</td></tr>"
        print(renglones)
        renglones+="</table>"
        return Markup( renglones )

    # defino como se representara al ser llamado
    def __repr__(self):
        return f'{self.cliente} {self.total} {self.Estado} {self.changed_on}'
class UnidadMedida(Model):

    """
    creo clase que sera mapeada como la tabla unidad_medida en la base de datos
    """
    __tablename__='unidad_medida'
    id = Column(Integer, primary_key=True)
    unidad = Column(String(50), unique=True, nullable=False)

    # defino como se representara al ser llamado
    def __repr__(self):
        return self.unidad

class Marcas(Model):
    """
    creo clase que sera mapeada como la tabla marcas en la base de datos
    """
    __tablename__='marcas'
    id = Column(Integer, primary_key=True)
    marca = Column(String(50), unique=True, nullable=False)

    # defino como se representara al ser llamado
    def __repr__(self):
        return self.marca

class Productos(Model,AuditMixin):
    """
    creo clase que sera mapeada como la tabla productos en la base de datos
    """
    id = Column(Integer, primary_key=True)
    producto=Column(String(30))
    precio=Column(Float)
    stock=Column(Integer,default=0)
    unidad_id = Column(Integer, ForeignKey('unidad_medida.id'), nullable=False)
    unidad = relationship("UnidadMedida")
    marcas_id = Column(Integer, ForeignKey('marcas.id'), nullable=False)
    marca = relationship("Marcas")
    medida = Column(Float)
    detalle=Column(String(255))
    # creo clave compuesta que no se pueden repetir dicha combinacion
    __table_args__ = (
        UniqueConstraint("producto","marcas_id","unidad_id","medida"),
    )

    # defino como se representara al ser llamado
    def __repr__(self):
        return f"{self.producto} ${self.precio} {self.marca} {self.medida} {self.unidad}"

class RenglonCompras(Model):
    """
    creo clase que sera mapeada como la tabla renglon en la base de datos
    """
    id = Column(Integer, primary_key=True)
    precioCompra = Column(Float)
    cantidad = Column(Integer)
    compra_id = Column(Integer, ForeignKey('compras.id'), nullable=False)
    compra = relationship("Compra", backref='renglones')
    producto_id = Column(Integer, ForeignKey('productos.id'), nullable=False)
    producto = relationship("Productos")

    # defino como se representara al ser llamado
    def __repr__(self):
        return f"{self.producto} ${self.precioCompra} {self.compra} {self.producto} {self.cantidad} "

class Renglon(Model):
    """
    creo clase que sera mapeada como la tabla renglon en la base de datos
    """
    id = Column(Integer, primary_key=True)
    precioVenta = Column(Float)
    cantidad = Column(Integer)
    venta_id = Column(Integer, ForeignKey('ventas.id'), nullable=False)
    venta = relationship("Venta", backref='renglones')
    producto_id = Column(Integer, ForeignKey('productos.id'), nullable=False)
    producto = relationship("Productos")

    # defino como se representara al ser llamado
    def __repr__(self):
        return f"{self.producto} ${self.precioVenta} {self.venta} {self.producto} {self.cantidad} "

class Ususarios(User):
    __tablename__ = "ab_user"
    extra = Column(String(50), unique=True, nullable=False)
db.create_all()
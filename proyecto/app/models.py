
import flask_appbuilder
from sqlalchemy import Column, Integer, String, ForeignKey,Float,Date, Boolean, UniqueConstraint
from sqlalchemy.orm import relationship
from flask_appbuilder.models.decorators import renders
from flask_appbuilder.models.mixins import  ImageColumn

from flask_appbuilder.security.sqla.models import User
from flask import Markup, url_for, redirect

from datetime import datetime as dt
from flask_appbuilder.filemanager import  ImageManager
from flask_appbuilder import Model
from . import appbuilder, db

print(flask_appbuilder.security.sqla.models)


class EmpresaDatos(Model):
    """
    # creo clase que sera mapeada como la tabla companiaTarjeta
    """
    __tablename__ = 'datosEmpresa'
    id = Column(Integer, primary_key=True)
    compania = Column(String(50), unique=True)
    direccion = Column(String(255), unique=True)
    cuit = Column(String(30), unique=True,nullable=True)
    logo = Column(ImageColumn(size=(300, 300, True), thumbnail_size=(30, 30, True)))
    tipoClave_id = Column(Integer, ForeignKey('tiposClave.id'), nullable=False,default=3)
    tipoClave = relationship("TipoClaves")
    __table_args__ = (
        UniqueConstraint("compania","direccion"),
    )
    def __repr__(self):
        return f'{self.compania}'
    def photo_img(self):
        im = ImageManager()
        if self.logo:
            return Markup('<a href="' + url_for('Empresaview.show',pk=str(self.id)) +\
             '" class="thumbnail"><img src="' + im.get_url(self.logo) +\
              '" alt="logo" class="img-rounded img-responsive"></a>')
        else:
            return Markup('<a href="' + url_for('Empresaview.show',pk=str(self.id)) +\
             '" class="thumbnail"><img src="//:0" alt="logo" class="img-responsive"></a>')

    def photo_img_thumbnail(self):
        im = ImageManager()
        if self.logo:
            return Markup('<a href="' + url_for('Empresaview.show',pk=str(self.id)) +\
             '" class="thumbnail"><img src="' + im.get_url_thumbnail(self.logo) +\
              '" alt="logo" class="img-rounded img-responsive"></a>')
        else:
            return Markup('<a href="' + url_for('Empresaview.show',pk=str(self.id)) +\
             '" class="thumbnail"><img src="//:0" alt="logo" class="img-responsive"></a>')





class Localidad (Model):
    """
    # creo clase que sirve para las localidades
    """
    __tablename__ = 'localidad'
    idlocalidad = Column(Integer, primary_key=True)
    localidad = Column(String(55), nullable=False, unique=True)

    # defino como se representara al ser llamado
    def __repr__(self):
        return f'{self.localidad}'
class TipoPersona(Model):
    """
    # creo clase que enumera los tipos de persona

    Fisica
    Juridica

    """
    __tablename__ = 'tipoPersona'
    idTipoPersona = Column(Integer, primary_key=True)
    tipoPersona = Column(String(30), nullable=False, unique=True)


    #defino como se representara al ser llamado
    def __repr__(self):
        return f'{self.tipoPersona}'

class TipoClaves(Model):
    """
    # creo clase que enumera los tipos de clave

    consumidorFinal="Consumidor Final"
    responsableInscripto="Responsable Inscripto"
    monotributista="Monotributista"
    exento = "Exento"
    """
    __tablename__ = 'tiposClave'
    id = Column(Integer, primary_key=True)
    tipoClave = Column(String(30), nullable=False, unique=True)


    #defino como se representara al ser llamado
    def __repr__(self):
        return f'{self.tipoClave}'


class TiposDocumentos(Model):
    """
    creo clase que enumera los tipos de documento

    DNI="DNI"
    CUIT="CUIT"
    CDI="CDI"
    LE = "LE"
    LC ="LC"
    CI_extranjera="CI extranjera"
    Pasaporte="Pasaporte"
    CI_PoliciaFederal="CI PoliciaFederal"
    CertificadodeMigracion="Certificado de Migracion"
    """
    __tablename__ = 'tiposDocumentos'
    id = Column(Integer, primary_key=True)
    tipoDocumento = Column(String(30), nullable=False, unique=True)
    # defino como se representara al ser llamado
    def __repr__(self):
        return f'{self.tipoDocumento}'
class Proveedor(Model):
    """
    creo clase que sera mapeada como la tabla Proveedor en la base de datos
    """
    __tablename__ = 'proveedor'
    __versioned__ = {}
    id = Column(Integer, primary_key=True)
    cuit=Column(String(30),nullable=False,unique=True)
    nombre = Column(String(30),nullable=False)
    apellido = Column(String(30),nullable=False)
    ranking = Column(Integer, default=0, nullable=True)
    domicilio =Column(String(255))
    correo = Column(String(100),unique=False)
    estado = Column(Boolean,default=True)
    tipoClave_id = Column(Integer, ForeignKey('tiposClave.id'), nullable=False)
    tipoClave = relationship("TipoClaves")
    idTipoPersona = Column(Integer, ForeignKey('tipoPersona.idTipoPersona'), nullable=False)
    tipoPersona = relationship("TipoPersona")
    direccion = Column(String(100), nullable=True)
    idlocalidad = Column(Integer, ForeignKey('localidad.idlocalidad'), nullable=True)
    localidad = relationship("Localidad")
    # defino como se representara al ser llamado
    def __repr__(self):
        return f"Cuit {self.cuit} {self.apellido} {self.nombre}"
    @renders('estado')
    def estadorender(self):
            if self.estado:
                return Markup('<b> Activo </b>')
            return Markup('<b> Desactivado</b>')


class Clientes(Model):
    """
    creo clase que sera mapeada como la tabla clientes en la base de datos
    """
    __tablename__ = 'clientes'
    __versioned__ = {}
    id = Column(Integer, primary_key=True)
    documento=Column(String(30),nullable=False)
    nombre = Column(String(30))
    apellido = Column(String(30))
    tipoDocumento_id = Column(Integer, ForeignKey('tiposDocumentos.id'), nullable=False)
    tipoDocumento = relationship("TiposDocumentos")
    tipoClave_id = Column(Integer, ForeignKey('tiposClave.id'), nullable=False)
    tipoClave = relationship("TipoClaves")
    idTipoPersona = Column(Integer, ForeignKey('tipoPersona.idTipoPersona'), nullable=False)
    tipoPersona = relationship("TipoPersona")
    estado = Column(Boolean,default=True)
    direccion = Column(String(100))
    idlocalidad = Column(Integer, ForeignKey('localidad.idlocalidad'), nullable=True)
    localidad = relationship("Localidad")

    #creo clave compuesta que no se pueden repetir dicha combinacion
    __table_args__ = (
        UniqueConstraint("documento","tipoDocumento_id"),
    )

    # defino como se representara al ser llamado
    def __repr__(self):
        if self.documento=="Consumidor Final" :
            return "Consumidor Final"

        return f"{self.nombre} {self.apellido} {self.tipoDocumento} {self.documento} "

    @renders('estado')
    def estadorender(self):
            if self.estado:
                return Markup('<b> Activo </b>')
            return Markup('<b> Desactivado</b>')

class CompaniaTarjeta(Model):
    """
    # creo clase que sera mapeada como la tabla companiaTarjeta
    """
    __tablename__ = 'companiaTarjeta'
    id = Column(Integer, primary_key=True)
    compania = Column(String(50), unique=True)

    def __repr__(self):
        return f'{self.compania}'



class FormadePago(Model):
    """
    creo clase que sera mapeada como la tabla formadepago en la base de datos
    """
    __tablename__= 'formadepago'
    id=Column(Integer, primary_key=True)
    Metodo=Column(String(50), unique=True)

    # defino como se representara al ser llamado esto es util para las ver tablas foraneas
    def __repr__(self):
           return str(self.Metodo)






class Compra(Model):
    """
    creo clase que sera mapeada como la tabla Compra en la base de datos
    """
    __tablename__= 'compras'
    id=Column(Integer, primary_key=True)
    estado=Column(Boolean)
    total=Column(Float, nullable=False)
    totalNeto = Column(Float, nullable=False)
    totaliva = Column(Float, nullable=True)
    fecha=Column(Date, nullable=False,default=dt.now())

    proveedor_id = Column(Integer, ForeignKey('proveedor.id'), nullable=False)
    proveedor = relationship("Proveedor")
    formadepago_id = Column(Integer, ForeignKey('formadepago.id'), nullable=False)
    formadepago = relationship("FormadePago")
    datosFormaPagos_id = Column(Integer, ForeignKey('datosFormaPagosCompra.id'), nullable=True)
    datosFormaPagos = relationship("DatosFormaPagosCompra")
    percepcion = Column(Float,default=0)

    # defino como se representara al ser llamado
    def __repr__(self):
        return f'{self.proveedor} {self.total} {self.estado} {self.fecha}'

    def condicionFrenteIva(self):
        return self.proveedor.tipoClave

    @renders('formatofecha')
    def formatofecha(self):
         return Markup('<b> ' + str(self.fecha.strftime(" %d-%m-%Y ")) + '</b>')
    @renders('estado')
    def estadorender(self):
            if self.estado:
                return Markup('<b> Compra Realizada </b>')
            return Markup('<b> Compra Anulada </b>')
    @renders('renglones')
    def renglonesrender(self):
    # will render this columns as lista
        print(self.renglones)
        renglones="</table> <table class='table table-bordered'> <tr><td>Producto</td> <td>Precio</td><td>Cantidad</td><td>IVA</td><td>Descuento</td><td>Subtotal</td></tr>"
        total=0
        for i in  self.renglones:
            if i.compra_id == self.id:
                unrenglon=f"<tr><td>{i.producto}</td> <td>${i.precioCompra}</td><td>{i.cantidad}</td><td>{i.producto.iva}%</td><td>{i.descuento} %</td><td>${i.precioCompra*i.cantidad*(1-i.descuento/100)}</td></tr> "
                unrenglon=f"<tr><td>{i.producto}</td> <td>${i.precioCompra}</td><td>{i.cantidad}</td><td>{i.producto.iva}%</td><td>{i.descuento} %</td><td>${i.precioCompra*i.cantidad*(1-i.descuento/100)}</td></tr> "
                renglones+=unrenglon+'\n'
                total+=i.precioCompra*i.cantidad
            else:
                print('equibocado',i)

        renglones += f"<tr><td></td><td></td><td></td><td></td><td>Total Neto</td> <td>${self.totalNeto}</td></tr>"
        renglones+=f"<tr><td></td><td></td><td></td><td></td><td>Total</td> <td>${self.total}</td></tr>"
        print(renglones)
        renglones+="</table>"
        return Markup( renglones )

class Venta(Model):
    """
    creo clase que sera mapeada como la tabla ventas en la base de datos
    """
    __tablename__= 'ventas'
    id=Column(Integer, primary_key=True)
    estado=Column(Boolean)
    fecha = Column(Date, nullable=False,default=dt.now())
    totalNeto = Column(Float, nullable=False)
    totaliva = Column(Float, nullable=True)
    #condicionFrenteIva = Column(Enum(TipoClaves))
    total=Column(Float, nullable=False)
    cliente_id = Column(Integer, ForeignKey('clientes.id'), nullable=False)
    cliente = relationship("Clientes")
    percepcion = Column(Float)
    #formadepago_id = Column(Integer, ForeignKey('formadepago.id'), nullable=False)
    #formadepago = relationship("FormadePago")
    #datosFormaPagos_id = Column(Integer, ForeignKey('datosFormaPagos.id'), nullable=True)
    #datosFormaPagos = relationship("DatosFormaPagos").

    @renders('formatofecha')
    def formatofecha(self):
         return Markup('<b> ' + str(self.fecha.strftime(" %d-%m-%Y ")) + '</b>')
    def condicionFrenteIva(self):
        return self.cliente.tipoClave
    def formadepago(self):
        pagos=""

        if len(self.formadepagos)>1:
            for i in self.formadepagos:
                pagos+= str(i) + " $"+ str(i.monto)+ "\n"
            return pagos
        else:
            return str(self.formadepagos[0])



    @renders('total')
    def totalrender(self):
         return Markup(' $' + str(format(self.total, '.2f')) )
    @renders('estado')
    def estadorender(self):
            if self.estado:
                return Markup('<b> Venta Realizada </b>')
            return Markup('<b> Venta Anulada </b>')
    @renders('renglones')
    def renglonesrender(self):
    # will render this columns as lista
        print(self.renglones)
        renglones="</table> <table class='table table-bordered'> <tr><td>Producto</td> <td>Precio</td><td>Cantidad</td><td>IVA</td><td>Descuento</td><td>Subtotal</td></tr>"
        from .views import RenglonVentas
        total=0
        for i in  self.renglones:
            print(type(i))
            print(f'{redirect(url_for("RenglonVentas.edit",pk=i.id))}')

            unrenglon=f"<tr><td>{i.producto}</td> <td>${i.precioVenta}</td><td>{i.cantidad}</td><td>{i.producto.iva}%</td><td>{i.descuento} %</td><td>${(i.precioVenta*i.cantidad)*(1-i.descuento/100)}</td></tr> "
            renglones+=unrenglon+'\n'
            total+=i.precioVenta*i.cantidad

        renglones += f"<tr><td></td><td></td><td></td><td></td><td>Total Neto</td> <td>${self.totalNeto}</td></tr>"
        renglones+=f"<tr><td></td><td></td><td></td><td></td><td>Total</td> <td>${self.total}</td></tr>"
        print(renglones)
        renglones+="</table>"
        return Markup( renglones )

    # defino como se representara al ser llamado
    def __repr__(self):
        return f'{self.cliente} {self.total} {self.estado} {self.fecha}'

class FormadePagoxVenta(Model):
    __tablename__ = 'FormadePago_Venta'
    id = Column(Integer, primary_key=True)
    monto = Column(Float, nullable=False)
    venta_id = Column(Integer, ForeignKey('ventas.id'), nullable=False)
    venta = relationship("Venta", backref='formadepagos')
    formadepago_id = Column(Integer, ForeignKey('formadepago.id'), nullable=False)
    formadepago = relationship("FormadePago")
    def __repr__(self):
        return str(self.formadepago)
class DatosFormaPagosCompra(Model):
    """
    # creo clase que sera mapeada como la tabla  de los datos de forma de pago tarjeta
    """
    __tablename__ = 'datosFormaPagosCompra'
    id = Column(Integer, primary_key=True)
    numeroCupon = Column(String(50), unique=True, nullable=False)
    credito = Column(Boolean, default=False)
    cuotas = Column(Integer)
    companiaTarjeta_id = Column(Integer, ForeignKey('companiaTarjeta.id'), nullable=False)
    companiaTarjeta = relationship("CompaniaTarjeta")
    formadepago_id = Column(Integer, ForeignKey('formadepago.id'), nullable=False)
    formadepago = relationship("FormadePago")
    def __repr__(self):
        return f'{self.numeroCupon}'
class DatosFormaPagos(Model):
    """
    # creo clase que sera mapeada como la tabla  de los datos de forma de pago tarjeta
    """
    __tablename__ = 'datosFormaPagos'
    id = Column(Integer, primary_key=True)
    numeroCupon = Column(String(50), unique=True)
    credito = Column(Boolean, default=False)
    cuotas = Column(Integer)
    companiaTarjeta_id = Column(Integer, ForeignKey('companiaTarjeta.id'), nullable=False)
    companiaTarjeta = relationship("CompaniaTarjeta")
    formadepago_id = Column(Integer, ForeignKey('FormadePago_Venta.id'), nullable=False)
    formadepago = relationship("FormadePagoxVenta")
    def __repr__(self):
        return f'{self.numeroCupon}'



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
class Categoria(Model):
    """
    creo clase que sera mapeada como la tabla marcas en la base de datos
    """
    __tablename__='categoria'
    id = Column(Integer, primary_key=True)
    categoria = Column(String(50), unique=True, nullable=False)

    # defino como se representara al ser llamado
    def __repr__(self):
        return self.categoria

class Productos(Model):
    """
    creo clase que sera mapeada como la tabla productos en la base de datos
    """
    __tablename__ = 'productos'
    id = Column(Integer, primary_key=True)
    #producto=Column(String(30))
    estado=Column(Boolean,default=True, nullable=True)

    precio=Column(Float)
    stock=Column(Integer,default=0)
    iva=Column(Float,default=0, nullable=False)
    unidad_id = Column(Integer, ForeignKey('unidad_medida.id'), nullable=False)
    unidad = relationship("UnidadMedida")
    marcas_id = Column(Integer, ForeignKey('marcas.id'), nullable=False)
    marca = relationship("Marcas")
    categoria_id = Column(Integer, ForeignKey('categoria.id'), nullable=False)
    categoria = relationship("Categoria")
    medida = Column(Float)
    detalle=Column(String(255))
    # creo clave compuesta que no se pueden repetir dicha combinacion
    __table_args__ = (
        UniqueConstraint("categoria_id","marcas_id","unidad_id","medida"),
    )

    # defino como se representara al ser llamado
    def __repr__(self):
        return f"{self.categoria} ${self.precio} {self.marca} {self.medida} {self.unidad}"
    def __str__(self):
        return f"{self.categoria} {self.marca} {self.medida} {self.unidad}"
    @renders('estado')
    def estadorender(self):
            if self.estado:
                return Markup('<b> Activo </b>')
            return Markup('<b> Desactivado</b>')
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
    descuento=Column(Float)

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
    descuento = Column(Float)

    # defino como se representara al ser llamado
    def __repr__(self):
        return f"{self.producto} ${self.precioVenta} {self.venta} {self.producto} {self.cantidad} "



db.create_all()



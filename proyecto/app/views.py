from flask import render_template, request, jsonify,url_for,redirect,session, Markup, send_file
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder import ModelView, ModelRestApi, BaseView, expose, has_access, MultipleView, SimpleFormView
from flask_appbuilder.views import ModelView, CompactCRUDMixin, MasterDetailView
from flask import flash



from .apis import *
from flask_appbuilder.models.sqla.filters import FilterEqualFunction,FilterEqual,FilterInFunction

from flask_appbuilder.actions import action
from flask_appbuilder.urltools import  Stack


from wtforms import Form, BooleanField, StringField, validators, DateField, FloatField, IntegerField, FieldList, \
    SelectField, SubmitField
from validadores import cuitvalidator, cuitvalidatorProveedores



from wtforms.validators import DataRequired,InputRequired
from flask_appbuilder.fieldwidgets import BS3TextFieldWidget, Select2Widget
from flask_babelpkg import gettext
from flask_appbuilder.urltools import get_filter_args
from .reportes import generarReporte
#manejador en caso de que no se encuentre la pagina
@appbuilder.app.errorhandler(404)
def page_not_found(e):
    return (
        render_template(
            "404.html", base_template=appbuilder.base_template, appbuilder=appbuilder
        ),
        404,
    )

from flask_appbuilder.widgets import ListWidget


class Empresaview(ModelView):
    datamodel = SQLAInterface(EmpresaDatos)
    label_columns ={'photo_img':'logo', 'photo_img_thumbnail':'logo'}
    list_title = "Datos de La Empresa"
    list_columns = ['compania','direccion','cuit','photo_img_thumbnail']
    show_columns = ['compania','direccion','cuit','photo_img']
    base_permissions = ['can_show', 'can_list', 'can_edit']



class CompaniaTarjetaview(ModelView):
    datamodel = SQLAInterface(CompaniaTarjeta)
    list_title = "Lista de companias de Tarjeta"
    class_permission_name = "tarjeta"
    method_permission_name = {
        'add': 'access',
        'delete': 'access',
        'download': 'access',
        'edit': 'access',
        'list': 'access',
        'muldelete': 'access',
        'show': 'access',
        'api': 'access',
        'api_column_add': 'access',
        'api_column_edit': 'access',
        'api_create': 'access',
        'api_delete': 'access',
        'api_get': 'access',
        'api_read': 'access',
        'api_readvalues': 'access',
        'api_update': 'access'
    }

class Sistemaview(MultipleView):
    views =[Empresaview,CompaniaTarjetaview]
    class_permission_name = "crudempresa"
    method_permission_name = {
        'add': 'access',
        'delete': 'access',
        'download': 'access',
        'edit': 'access',
        'list': 'access',
        'muldelete': 'access',
        'show': 'access',
        'api': 'access',
        'api_column_add': 'access',
        'api_column_edit': 'access',
        'api_create': 'access',
        'api_delete': 'access',
        'api_get': 'access',
        'api_read': 'access',
        'api_readvalues': 'access',
        'api_update': 'access'
    }


class ListDownloadWidgetventa(ListWidget):
    template = 'reporteventa.html'
class ListDownloadWidgetcompra(ListWidget):
    template = 'reportecompras.html'


#creo y configuro la clase de manejador de  vista de productos
class ProductoModelview(ModelView):
    datamodel = SQLAInterface(Productos)
    #configuro vistas de crear, listar y editar
    list_title = "Listado de Productos"
    add_columns = ['categoria', 'marca','unidad', 'medida', 'precio', 'detalle']
    list_columns = ['categoria', 'marca', 'medida','unidad', 'precio', 'stock', 'detalle']
    edit_columns = ['categoria','medida','unidad','marca','precio','stock','detalle']
    # search_columns = ['producto','unidad','medida','marca','precio','stock']


#creo clase de manejador de vistas de marcas y unidad de medida
class MarcasModelview(ModelView):
    list_title = "Listado de Marcas"
    datamodel = SQLAInterface(Marcas)

class CategoriaModelview(ModelView):
    list_title = "Listado de Categorias"
    datamodel = SQLAInterface(Categoria)

    def post_add_redirect(self):
        self.update_redirect()
        return redirect(url_for("CategoriaModelview.add"))




class unidadesModelView(ModelView):
    datamodel = SQLAInterface(UnidadMedida)
#creo clases de manejador de una vista que incluya las vistas de marcas y unidad de medidas
class CrudProducto(MultipleView):
    views = [MarcasModelview, unidadesModelView, ProductoModelview,CategoriaModelview]
    class_permission_name = "productocrud"
    method_permission_name = {
        'add': 'access',
        'delete': 'access',
        'download': 'access',
        'edit': 'access',
        'list': 'access',
        'muldelete': 'access',
        'show': 'access',
        'api': 'access',
        'api_column_add': 'access',
        'api_column_edit': 'access',
        'api_create': 'access',
        'api_delete': 'access',
        'api_get': 'access',
        'api_read': 'access',
        'api_readvalues': 'access',
        'api_update': 'access'
    }

class ReportesView(BaseView):
    default_view = 'reportes'

    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/reportes/<var>', methods=["GET", "POST"])
    @has_access
    def show_static_pdf(self,var):
        from flask import send_from_directory, g
        import os
        print(os.getcwd())
        return send_from_directory(os.getcwd()+"/app/static/docs/", f'{var}.pdf')

#creo clase de manejador de la vista de ventas
def repre(self):
    retstr = "FILTROS:"
    if len(self.get_filters_values())>0:
        for flt, value in self.get_filters_values():
            retstr = retstr + "%s:%s\n" % (
                str(flt.column_name).capitalize(),
                str(value),
            )
        return retstr
    else:
        return ""
class VentaReportes(ModelView):
    datamodel = SQLAInterface(Venta)
    list_title = "Listado de Ventas"
    label_columns = {"totalrender":"Total",'formadepago':'Forma de Pago','renglonesrender':'','estadorender':'Estado'}
    list_columns = ['cliente', "totalrender", 'estadorender','fecha']
    show_columns = ['cliente', 'estadorender','fecha','renglonesrender']
    edit_columns = ['Estado']
    base_permissions = ['can_show','can_list', 'can_edit']
    #list_template = "reportes.html"
    show_template = "imprimirventa.html"
    list_widget = ListDownloadWidgetventa

    @expose('/csv', methods=['GET'])
    def download_csv(self):

        get_filter_args(self._filters)

        if self.base_order==None:
            count, lst = self.datamodel.query(self._filters)
        else:
           order_column, order_direction = self.base_order

           count, lst = self.datamodel.query(self._filters, order_column, order_direction)
           print(count , self.base_order)
        print(lst)
        print(self._filters, type(self._filters))


        import types
        filtros=self._filters
        filtros.__repr__ = types.MethodType(repre, filtros)
        filtros.__str__ = types.MethodType(repre, filtros)
        print(filtros, filtros.__repr__())

        cabecera = (
            ("cliente", "Cliente"),("condicionFrenteIva", "Cond. Frente Iva"),("fecha", "Fecha"),
            ("formadepago", "Forma de Pago"),("total", "Total"),
        )

        generarReporte(titulo="Listado de ventas",cabecera=cabecera,buscar=Venta,nombre="Listado de ventas",datos=lst,filtros=self._filters)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de ventas" ))


class CompraReportes(ModelView):
    datamodel = SQLAInterface(Compra)
    list_widget =ListDownloadWidgetcompra
    list_title = "Listado de Compras"
    label_columns = {'renglonesrender':'', 'estadorender':'Estado'}
    list_columns = ['proveedor', "total", 'estadorender', 'formadepago','fecha']
    show_columns = ['proveedor', 'total', 'estadorender','formadepago','fecha','renglonesrender']
    edit_columns = ['Estado']

    base_permissions = ['can_show','can_list', 'can_edit']




    @expose('/pdf', methods=['GET'])
    def download_pdf(self):

        get_filter_args(self._filters)
        if self.base_order==None:
            count, lst = self.datamodel.query(self._filters)
        else:
           order_column, order_direction = self.base_order

           count, lst = self.datamodel.query(self._filters, order_column, order_direction)
        print(lst)
        print(self._filters)
        cabecera = (
            ("proveedor", "Proveedor"),("condicionFrenteIva", "Cond. Frente Iva"),("fecha", "Fecha"),
            ("formadepago", "Forma de Pago"),("total", "Total"),
        )

        generarReporte(titulo="Listado de Compras",cabecera=cabecera,buscar=Venta,nombre="Listado de Compras",datos=lst)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de Compras" ))


#creo clase de el manejador de renglones
class RenglonVentas(ModelView):
    datamodel = SQLAInterface(Renglon)
    list_columns = ['producto', 'precioVenta', 'cantidad']
    edit_columns = ['producto', 'precioVenta', 'cantidad']
    related_views = [VentaReportes]

from flask_wtf import FlaskForm

#creo clase de formulario de venta
class RenglonVenta(Form):
    cliente=SelectField('Cliente', coerce=str, choices=[(c.id, c) for c in db.session.query(Clientes)])
    Fecha = DateField('Fecha', format='%d-%m-%Y %H:%M:%S', default=dt.now(), render_kw={'disabled': ''},
                      validators=[DataRequired()])
    producto = SelectField('Producto', coerce=str, choices=[(p.id, p) for p in db.session.query(Productos)])
    cantidad = IntegerField('Cantidad', widget=BS3TextFieldWidget())
    metodo = SelectField('Forma de Pago', coerce=str, choices=[(p.id, p) for p in db.session.query(FormadePago)])
    #condicionfrenteiva= SelectField('Condicion Frente Iva', coerce=TipoClaves.coerce, choices=TipoClaves.choices() )
    Total = FloatField('Total $', render_kw={'disabled': ''},
                       validators=[DataRequired()], default=0)
    numeroCupon = IntegerField('Numero de cupon', widget=BS3TextFieldWidget())
    companiaTarjeta = SelectField('Compania de la Tarjeta', coerce=str, choices=[(p.id, p) for p in db.session.query(CompaniaTarjeta)] )
    credito = BooleanField("Credito", default=False)
    cuotas = IntegerField("Cuotas", default=0)

#creo clase manejadora de la vista de realizar venta
class VentaView(BaseView):
    default_view = 'venta'

    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/venta/', methods=["GET", "POST"])
    @has_access
    def venta(self):
        #creo formulario
        form2 = RenglonVenta(request.form)
        #cargo las elecciones de producto
        form2.producto.choices = [('{"id": ' + f'{p.id}' + ', "representacion":' + f'"{p.__repr__()}"' + '}', p) for p
                                  in db.session.query(Productos)]
        form2.Fecha.data = dt.now()
        # cargo las elecciones de cliente
        form2.cliente.choices = [(c.id, c) for c in db.session.query(Clientes)]
        # cargo las elecciones de metodo de pago
        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]

        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta)]
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta
        self.update_redirect()
        #renderizo el html y le paso el formulario
        return render_template('venta.html', base_template=appbuilder.base_template, appbuilder=appbuilder, form2=form2)





#creo clase de formulario de renglon compra
class RenglonCompra(Form):
    proveedor=SelectField('Proveedor', coerce=str, choices=[(c.id, c) for c in db.session.query(Proveedor)])
    producto = SelectField('Producto', coerce=str, choices=[(p.id, p) for p in db.session.query(Productos)])
    cantidad = IntegerField('Cantidad', widget=BS3TextFieldWidget())
    metodo = SelectField('Metodo de Pago', coerce=str, choices=[(p.id, p) for p in db.session.query(FormadePago)])
    Total = FloatField('Total', render_kw={'disabled': ''},
                       validators=[DataRequired()], default=0)
    #condicionfrenteiva = SelectField('Condicion Frente Iva', coerce=TipoClaves.coerce, choices=TipoClaves.choices())
    numeroCupon = IntegerField('Numero de cupon', widget=BS3TextFieldWidget())
    companiaTarjeta = SelectField('Compania de la Tarjeta', coerce=str, choices=[(p.id, p) for p in db.session.query(CompaniaTarjeta)] )
    credito = BooleanField("Credito", default=False)
    cuotas = IntegerField("Cuotas", default=0)

#creo clase manejadora de la vista de realizar compra
class CompraView(BaseView):
    default_view = 'compra'
    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/compra/', methods=["GET", "POST"])
    @has_access
    def compra(self,id=None):

        cabecera = (
            ("cliente", "Cliente"),
            ("formadepago", "Forma de Pago"),("total", "Total"),
        )
        generarReporte(titulo="Listado de ventas",cabecera=cabecera,buscar=Venta,nombre="Listado de ventas")
        #creo formulario
        form2 = RenglonCompra(request.form)
        #cargo las elecciones de producto
        form2.producto.choices = [('{"id": ' + f'{p.id}' + ', "representacion":' + f'"{p.__repr__()}"' + '}', p) for p
                                  in db.session.query(Productos)]

        # cargo las elecciones de cliente
        form2.proveedor.choices = [(c.id, c) for c in db.session.query(Proveedor)]
        # cargo las elecciones de metodo de pago
        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta)]
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta
        self.update_redirect()
        #renderizo el html y le paso el formulario
        return render_template('compra.html', base_template=appbuilder.base_template, appbuilder=appbuilder, form2=form2)
    class_permission_name = "compraclass"
    method_permission_name = {
        'compra': 'access'
    }




def tipoClave_query():
    print(g.user.__dict__.keys(), g.user.roles)
    return db.session.query(TipoClaves).filter(TipoClaves.tipoClave != "Consumidor Final" ).all()

class ProveedorView(ModelView):
    """
    #creo clase de el manejador de proveedor
    """
    from wtforms.ext.sqlalchemy.fields import QuerySelectField
    datamodel = SQLAInterface(Proveedor)
    related_views = [Compra]
    #le digo los permisos

    base_permissions =['can_list','can_add','can_edit', 'can_delete' ]
    label_columns = {'tipoClave': 'Cond. Frente Iva'}
    add_columns = ['cuit', 'nombre', 'apellido', 'correo','tipoClave']
    list_columns = ['cuit', 'nombre', 'apellido','correo' ,'tipoClave']
    edit_columns = ['cuit', 'nombre', 'apellido', 'correo','tipoClave']
    add_template = "addproveedor.html"

    validators_columns ={
        'cuit':[InputRequired(),cuitvalidatorProveedores]
    }

    add_form_extra_fields = {
        'tipoClave':  QuerySelectField(
                            'Cond. Frente Iva',
                            query_factory=tipoClave_query,
                            widget=Select2Widget("readonly")
                       )
    }

    edit_form_extra_fields = {
        'tipoClave':  QuerySelectField(
                            'Cond. Frente Iva',
                            query_factory=tipoClave_query,
                            widget=Select2Widget("readonly")
                       )
    }

#creo clase de el manejador de clientes
class ClientesView(ModelView):
    datamodel = SQLAInterface(Clientes)
    related_views = [Venta]
    #le digo los permisos
    base_permissions =['can_list','can_add','can_edit', 'can_delete' ]
    message="cliente creado"
    #presonalizando las etiquetas de las columnas
    label_columns = {'tipoDocumento':'Tipo de Documento' ,'tipoClave':'Tipo de Clave'}
    #filtrando los valores
    #base_filters = [['estado', FilterEqual, True]]#descomentar para que filtre solo los activos
    add_template = "agregarcliente.html"
    #configurando las columnas de las vistas crear listar y editar
    add_columns = ['tipoDocumento','documento','tipoClave', 'nombre', 'apellido']
    list_columns = ['documento', 'nombre', 'apellido','tipoDocumento']
    edit_columns = ['documento', 'nombre', 'apellido','tipoDocumento','estado']
    validators_columns ={
        'documento':[InputRequired(),cuitvalidator(dato='tipoDocumento')]
    }

    def get_redirect_anterior(self):
        """
        me devuelve la url previa
            simplemente le edite para que guarde bien la url y no afecte al historial
        """
        index_url = self.appbuilder.get_url_for_index
        page_history = Stack(session.get("page_history", []))

        if page_history.pop() is None:
            return index_url
        session["page_history"] = page_history.to_json()

        url = page_history.pop()
        page_history.push(url)

        session["page_history"] = page_history.to_json()
        return url
    #metodo de postproceso despues de crear un cliente
    #sirve para mandar el mensagge flash de "cliente creado" a la vista de realizar venta
    def post_add(self, item):
        urlanterior =self.get_redirect_anterior()
        try:
            url="http://localhost:8080"+url_for("VentaView.venta")
            if urlanterior== url:
                flash("Cliente Creado", "nuevocliente")
        except Exception as e:
            print(e)
            print(str(e))
            flash("Error ocurrido", "error")
            print(repr(e))
        #se guarada el enlace en el historial
        self.update_redirect()





#aca agrego los manejadores de las vistas al appbuilder para que sean visuales


appbuilder.add_view(VentaView, "Realizar Ventas", category='Ventas', category_icon='fa-tag' )

appbuilder.add_view(CrudProducto, "Productos",icon="fa-archive")

appbuilder.add_view(CompraView, "Compra", category='Compras', category_icon="fa-cart-plus" )
appbuilder.add_view(ClientesView, "Clientes")
appbuilder.add_view(ProveedorView, "Proveedor")


#appbuilder.add_view(ProductoModelview, "Poductos vista",icon='fa-archive')
appbuilder.add_view_no_menu(ProductoModelview)
appbuilder.add_view_no_menu(MarcasModelview)
appbuilder.add_view_no_menu(unidadesModelView)
appbuilder.add_view_no_menu(CategoriaModelview)
appbuilder.add_view_no_menu(ReportesView)
appbuilder.add_view(VentaReportes, "Reporte Ventas",icon="fa-save", category='Ventas' )
appbuilder.add_view(CompraReportes, "Reporte Compras",icon="fa-save", category='Compras' )


appbuilder.add_view(Sistemaview,'Datos Empresa',category='Security')

appbuilder.add_view_no_menu(Empresaview)
appbuilder.add_view_no_menu(CompaniaTarjetaview)
from .auditoria import *
appbuilder.add_view_no_menu(RenglonVentas)



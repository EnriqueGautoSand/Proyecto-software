from flask import render_template, request, jsonify,url_for,redirect,session, Markup, send_file
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder import ModelView, ModelRestApi, BaseView, expose, has_access, MultipleView, SimpleFormView
from flask_appbuilder.views import ModelView, CompactCRUDMixin, MasterDetailView
from flask import flash
from . import appbuilder, db
from .models import *
import flask_appbuilder
from datetime import datetime as dt
import json
from .apis import *
from flask_appbuilder.models.sqla.filters import FilterEqualFunction,FilterEqual

from flask_appbuilder.actions import action
from flask_appbuilder.urltools import  Stack
from flask_appbuilder.models.decorators import renders

from wtforms import Form, BooleanField, StringField, validators, DateField, FloatField, IntegerField, FieldList, \
    SelectField, SubmitField
from wtforms.validators import DataRequired
from flask_appbuilder.fieldwidgets import BS3TextFieldWidget, Select2Widget
from flask_appbuilder.forms import DynamicForm
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from flask import make_response
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


class ListDownloadWidget(ListWidget):
    template = 'reporteventa.html'

#creo y configuro la clase de manejador de  vista de productos
class ProductoModelview(ModelView):
    datamodel = SQLAInterface(Productos)
    #configuro vistas de crear, listar y editar
    add_columns = ['categoria', 'marca','unidad', 'medida', 'precio', 'stock', 'detalle']
    list_columns = ['categoria', 'marca', 'medida','unidad', 'precio', 'stock', 'detalle']
    edit_columns = ['categoria','medida','unidad','marca','precio','stock','detalle']
    # search_columns = ['producto','unidad','medida','marca','precio','stock']


#creo clase de manejador de vistas de marcas y unidad de medida
class MarcasModelview(ModelView):
    datamodel = SQLAInterface(Marcas)

class CategoriaModelview(ModelView):
    datamodel = SQLAInterface(Categoria)

class unidadesModelView(ModelView):
    datamodel = SQLAInterface(UnidadMedida)
#creo clases de manejador de una vista que incluya las vistas de marcas y unidad de medidas
class CrudProducto(MultipleView):
    views = [MarcasModelview, unidadesModelView, ProductoModelview,CategoriaModelview]
class ReportesView(BaseView):
    default_view = 'reportes'

    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/reportes/<var>', methods=["GET", "POST"])
    @has_access
    def show_static_pdf(self,var):
        from flask import send_from_directory, g
        from app import app
        import os
        print(os.getcwd())
        return send_from_directory(os.getcwd()+"/app/static/docs/", f'{var}.pdf')

#creo clase de manejador de la vista de ventas
class VentaReportes(ModelView):
    datamodel = SQLAInterface(Venta)

    label_columns = {"totalrender":"Total",'formadepago':'Forma de Pago','renglonesrender':'','estadorender':'Estado'}
    list_columns = ['cliente', "totalrender", 'estadorender', 'formadepago','fecha']
    show_columns = ['cliente', 'estadorender', 'formadepago','fecha','renglonesrender']
    edit_columns = ['Estado']
    base_permissions = ['can_show','can_list', 'can_edit']
    list_template = "reportes.html"
    show_template = "imprimirventa.html"
    list_widget = ListDownloadWidget

    @expose('/csv', methods=['GET'])
    def download_csv(self):

        get_filter_args(self._filters)

        if self.base_order==None:
            count, lst = self.datamodel.query(self._filters)
        else:
           order_column, order_direction = self.base_order

           count, lst = self.datamodel.query(self._filters, order_column, order_direction)
        print(self._filters)
        cabecera = (
            ("cliente", "Cliente"),
            ("formadepago", "Forma de Pago"),("total", "Total"),
        )

        generarReporte(titulo="Listado de ventas",cabecera=cabecera,buscar=Venta,nombre="Listado de ventas",datos=lst)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de ventas" ))

    @action("down_excel", "Download to xlsx", "", "fa-file-excel-o", single=False)
    def down_excel(self, items):

        get_filter_args(self._filters)
        print(self.base_order)
        order_column, order_direction = self.base_order

        count, lst = self.datamodel.query(self._filters, order_column, order_direction)
        print(lst)
        csv = ''
        suma=0
        for las in self.datamodel.get_values(lst, self.list_columns):
            suma+=1
            print( str(las),suma)

        from io import BytesIO
        import pandas as pd
        print(items)
        output = BytesIO()
        list_items = list()
        print(len(items))
        for item in items:
            row = dict()
            for col, colname in self.label_columns.items():
                row[colname] = str(getattr(item, col))
            list_items.append(row)

        df = pd.DataFrame(list_items)
        writer = pd.ExcelWriter(output, engine='xlsxwriter')
        df.to_excel(writer, 'data', index=False)
        writer.save()
        output.seek(0)

        return send_file(output, attachment_filename='list.xlsx', as_attachment=True)
class CompraReportes(ModelView):
    datamodel = SQLAInterface(Compra)


    list_columns = ['proveedor', "total", 'estadorender', 'formadepago','fecha']
    show_columns = ['proveedor', 'total', 'formadepago','fecha']
    edit_columns = ['Estado']
    base_permissions = ['can_show','can_list', 'can_edit']

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
    metodo = SelectField('Metodo de Pago', coerce=str, choices=[(m.id, m) for m in db.session.query(FormadePago)])
    Total = FloatField('Total', render_kw={'disabled': ''},
                       validators=[DataRequired()], default=0)
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
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta
        self.update_redirect()
        #renderizo el html y le paso el formulario
        return render_template('venta.html', base_template=appbuilder.base_template, appbuilder=appbuilder, form2=form2)





#creo clase de formulario de renglon compra
class RenglonCompra(Form):
    proveedor=SelectField('Proveedor', coerce=str, choices=[(c.id, c) for c in db.session.query(Proveedor)])
    Fecha = DateField('Fecha', format='%d-%m-%Y %H:%M:%S', default=dt.now(), render_kw={'disabled': ''},
                      validators=[DataRequired()])
    producto = SelectField('Producto', coerce=str, choices=[(p.id, p) for p in db.session.query(Productos)])
    cantidad = IntegerField('Cantidad', widget=BS3TextFieldWidget())
    metodo = SelectField('Metodo de Pago', coerce=str, choices=[(m.id, m) for m in db.session.query(FormadePago)])
    Total = FloatField('Total', render_kw={'disabled': ''},
                       validators=[DataRequired()], default=0)
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
        form2.Fecha.data = dt.now()
        # cargo las elecciones de cliente
        form2.proveedor.choices = [(c.id, c) for c in db.session.query(Proveedor)]
        # cargo las elecciones de metodo de pago
        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta
        self.update_redirect()
        #renderizo el html y le paso el formulario
        return render_template('compra.html', base_template=appbuilder.base_template, appbuilder=appbuilder, form2=form2)
#creo clase de el manejador de proveedor
class ProveedorView(ModelView):
    datamodel = SQLAInterface(Proveedor)
    related_views = [Compra]
    #le digo los permisos
    base_permissions =['can_list','can_add','can_edit', 'can_delete' ]

    add_columns = ['cuit', 'nombre', 'apellido', 'correo']
    list_columns = ['cuit', 'nombre', 'apellido','correo' ]
    edit_columns = ['cuit', 'nombre', 'apellido', 'correo']
    add_template = "addcliente.html"

#creo clase de el manejador de clientes
class ClientesView(ModelView):
    datamodel = SQLAInterface(Clientes)
    related_views = [Venta]
    #le digo los permisos
    base_permissions =['can_list','can_add','can_edit', 'can_delete' ]
    message="cliente creado"
    #presonalizando las etiquetas de las columnas
    label_columns = {'condicionFrenteIva': 'condicion Frente al Iva','tipoDocumento':'tipo de Documento' }
    #filtrando los valores
    #base_filters = [['estado', FilterEqual, True]]#descomentar para que filtre solo los activos
    #configurando las columnas de las vistas crear listar y editar
    add_columns = ['documento', 'nombre', 'apellido', 'condicionFrenteIva','tipoDocumento']
    list_columns = ['documento', 'nombre', 'apellido', 'condicionFrenteIva','tipoDocumento']
    edit_columns = ['documento', 'nombre', 'apellido', 'condicionFrenteIva','tipoDocumento','estado']
    #me devuelve la url previa
    def get_redirect_anterior(self):
        """
            Returns the previous url.
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





#aca simplemente agrego los manejadores de las vistas al appbuilder para que sean visuales

appbuilder.add_view(VentaView, "Realizar Ventas", category='Ventas', category_icon='fa-tag' )

appbuilder.add_view(CrudProducto, "Poductos",icon="fa-archive")
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

appbuilder.add_view_no_menu(RenglonVentas)



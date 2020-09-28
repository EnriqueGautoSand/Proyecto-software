from flask import render_template, request, jsonify,url_for,redirect,session, Markup
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
from flask_admin.babel import gettext

from flask_appbuilder.urltools import  Stack
from flask_appbuilder.models.decorators import renders

from wtforms import Form, BooleanField, StringField, validators, DateField, FloatField, IntegerField, FieldList, \
    SelectField, SubmitField
from wtforms.validators import DataRequired
from flask_appbuilder.fieldwidgets import BS3TextFieldWidget, Select2Widget
from flask_appbuilder.forms import DynamicForm
from wtforms.ext.sqlalchemy.fields import QuerySelectField

#manejador en caso de que no se encuentre la pagina
@appbuilder.app.errorhandler(404)
def page_not_found(e):
    return (
        render_template(
            "404.html", base_template=appbuilder.base_template, appbuilder=appbuilder
        ),
        404,
    )






#creo y configuro la clase de manejador de  vista de productos
class ProductoModelview(ModelView):
    datamodel = SQLAInterface(Productos)
    #configuro vistas de crear, listar y editar
    add_columns = ['producto', 'marca','unidad', 'medida', 'precio', 'stock', 'detalle']
    list_columns = ['producto', 'medida','unidad', 'marca', 'precio', 'stock', 'detalle']
    edit_columns = ['producto','medida','unidad','marca','precio','stock','detalle']
    # search_columns = ['producto','unidad','medida','marca','precio','stock']


#creo clase de manejador de vistas de marcas y unidad de medida
class MarcasModelview(ModelView):
    datamodel = SQLAInterface(Marcas)

class unidadesModelView(ModelView):
    datamodel = SQLAInterface(UnidadMedida)
#creo clases de manejador de una vista que incluya las vistas de marcas y unidad de medidas
class CrudProducto(MultipleView):
    views = [MarcasModelview, unidadesModelView, ProductoModelview]

#creo clase de manejador de la vista de ventas
class VentaReportes(ModelView):
    datamodel = SQLAInterface(Venta)

    label_columns = {"totalrender":"Total",'formadepago':'Forma de Pago','renglonesrender':'','estadorender':'Estado', 'created_on':'Fecha'}
    list_columns = ['cliente', "totalrender", 'estadorender', 'formadepago','created_on']
    show_columns = ['cliente', "totalrender", 'estadorender', 'formadepago','created_on','renglonesrender']
    edit_columns = ['Estado']
    base_permissions = ['can_show','can_list', 'can_edit']
    list_template = "reportes.html"
    show_template = "imprimirventa.html"

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

appbuilder.add_view(VentaView, "Realizar Ventas",icon="fa-cart-plus", category='Ventas', category_icon='fa-tag' )

appbuilder.add_view(CrudProducto, "Poductos",icon="fa-file-download")
appbuilder.add_view(ClientesView, "Clientes")


appbuilder.add_view(ProductoModelview, "Poductos vista",icon='fas fa-archive')
appbuilder.add_view_no_menu(ProductoModelview)
appbuilder.add_view_no_menu(MarcasModelview)
appbuilder.add_view_no_menu(unidadesModelView)


appbuilder.add_view(VentaReportes(), "Reporte Ventas",icon="fa-save", category='Ventas' )
appbuilder.add_view_no_menu(RenglonVentas)



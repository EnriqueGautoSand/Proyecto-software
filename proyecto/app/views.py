from flask import render_template, request, jsonify,url_for,redirect,session, Markup, send_file
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder import ModelView, ModelRestApi, BaseView, expose, has_access, MultipleView, SimpleFormView
from flask_appbuilder.views import ModelView, CompactCRUDMixin, MasterDetailView
from flask import flash
from flask_appbuilder.models.sqla.filters import FilterEqualFunction


from .apis import *
from flask_appbuilder.models.sqla.filters import FilterEqualFunction,FilterEqual,FilterInFunction,FilterRelationManyToManyEqual

from flask_appbuilder.actions import action
from flask_appbuilder.urltools import  Stack


from wtforms import Form, BooleanField, StringField, validators, DateField, FloatField, IntegerField, FieldList, \
    SelectField, SubmitField
from validadores import cuitvalidator, cuitvalidatorProveedores



from wtforms.validators import DataRequired,InputRequired
from flask_appbuilder.fieldwidgets import BS3TextFieldWidget, Select2Widget
from flask_babelpkg import gettext
from flask_appbuilder.urltools import get_filter_args
from flask_appbuilder.widgets import ListWidget
from .reportes import generarReporte
import types
import inspect
def _init_titles(self):
    """
        Init Titles if not defined
    """

    class_name = self.datamodel.model_name
    if not self.list_title:
        self.list_title = "Listado de " + self._prettify_name(class_name)
    if not self.add_title:
        self.add_title = "Agregar " + self._prettify_name(class_name)
    if not self.edit_title:
        self.edit_title = "Editar " + self._prettify_name(class_name)
    if not self.show_title:
        self.show_title = "Detalle de " + self._prettify_name(class_name)
    self.title = self.list_title
ModelView._init_titles=_init_titles
ModelView.list_template="list.html"
class listwitgetall(ListWidget):
    template = 'listwitget.html'
ModelView.list_widget=listwitgetall

from fab_addon_audit.views import AuditedModelView

def pre_add(self, item):
    for key in self.show_item_dict(item):
        if not inspect.ismethod(getattr(item, key)):
            print(key, type(getattr(item, key)),type("string"))
            if type(getattr(item, key))==type("string"):
                setattr(item, key, getattr(item, key).upper())
            if type(getattr(item, key)) == type(10.0):
                setattr(item, key,format(getattr(item, key), '.2f') )


ModelView.pre_add=pre_add



ModelView.list_widget = listwitgetall


#manejador en caso de que no se encuentre la pagina
@appbuilder.app.errorhandler(404)
def page_not_found(e):
    return (
        render_template(
            "404.html", base_template=appbuilder.base_template, appbuilder=appbuilder
        ),
        404,
    )




class Empresaview(ModelView):
    datamodel = SQLAInterface(EmpresaDatos)
    label_columns ={'photo_img':'logo', 'photo_img_thumbnail':'logo','tipoClave':'Cond Frente Iva'}
    list_title = "Datos de La Empresa"
    list_columns = ['compania','tipoClave','direccion','cuit','photo_img_thumbnail']
    show_columns = ['compania','tipoClave','direccion','cuit','photo_img']
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
class ListWidgetProducto(ListWidget):
    template = 'productoshtml.html'

#creo y configuro la clase de manejador de  vista de productos


#creo y configuro la clase de manejador de  vista de productos
class ProductoModelview(AuditedModelView):
    datamodel = SQLAInterface(Productos,session=db.session)
    #configuro vistas de crear, listar y editar

    list_title = "Listado de Productos"
    label_columns = {'estadorender':'Estado'}
    add_columns = ['categoria', 'marca','unidad', 'medida', 'precio','iva', 'detalle']
    list_columns = ['categoria', 'marca', 'medida','unidad', 'precio', 'stock','iva','estadorender', 'detalle']
    edit_columns = ['categoria','medida','unidad','marca','precio','iva','Estado','detalle']
    base_order = ('categoria.id', 'dsc')
    # search_columns = ['producto','unidad','medida','marca','precio','stock']

    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        item = self.datamodel.get(pk, self._base_filters)
        item.Estado=False
        db.session.commit()
        self.post_update(item)
        self.update_redirect()

        return self.post_delete_redirect()




#creo clase de manejador de vistas de marcas y unidad de medida
class MarcasModelview(AuditedModelView):
    list_title = "Listado de Marcas"
    datamodel = SQLAInterface(Marcas)

class CategoriaModelview(AuditedModelView):
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
class PrecioMdelview(AuditedModelView):
    datamodel = SQLAInterface(Productos)
    #configuro vistas de crear, listar y editar
    list_widget = ListWidgetProducto
    label_columns = {'estadorender': 'Estado'}
    list_title = "Listado de Productos"
    add_columns = ['categoria', 'marca','unidad', 'medida', 'precio','iva', 'detalle']
    list_columns = ['categoria', 'marca', 'medida','unidad', 'precio', 'stock','iva','estadorender', 'detalle']
    edit_columns = ['categoria','medida','unidad','marca','precio','iva','Estado','detalle']


    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        item = self.datamodel.get(pk, self._base_filters)
        item.Estado=False
        db.session.commit()
        self.post_update(item)
        self.update_redirect()
        return self.post_delete_redirect()
    @expose('/updateprecio/<var>/<signo>', methods=['GET'])
    def updateprecio(self,var,signo):
        get_filter_args(self._filters)
        if self.base_order==None:
            count, lst = self.datamodel.query(self._filters)
        else:
           order_column, order_direction = self.base_order

           count, lst = self.datamodel.query(self._filters, order_column, order_direction)
        print(self._filters,lst,count)
        if request.method == "GET":
            data = request.json
            print(var,request.url)
            print(lst)
            for i in lst:
                try:

                    if signo==-1:
                        var=-var
                    self.pre_update(i)
                    i.precio=format(float(i.precio)+((float(i.precio)/100) * float(var)), '.2f')
                    if self.datamodel.edit(i):
                        self.post_update(i)
                except Exception as e:
                    print(e.__str__())
            widgets = self._list()
            self.update_redirect()

            return self.render_template(
                self.list_template, title=self.list_title, widgets=widgets
                )

        else:
            return self.response(400, message="error")

class ReportesView(BaseView):
    default_view = 'reportes'

    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/reportes/<var>', methods=["GET", "POST"])
    @has_access
    def show_static_pdf(self,var):
        from flask import send_from_directory
        import os
        print(os.getcwd())
        return send_from_directory(os.getcwd()+"/app/static/docs/", f'{var}.pdf')

#creo clase de el manejador de renglones
class MetododepagoVentas(ModelView):
    datamodel = SQLAInterface(FormadePagoxVenta)
    list_columns = ['formadepago', 'monto']

class RenglonVentas(ModelView):
    datamodel = SQLAInterface(Renglon)
    list_columns = ['producto', 'precioVenta', 'cantidad']
    edit_columns = ['producto', 'precioVenta', 'cantidad']
def repre(self,labels=None,tabla=None,db=None):
    if labels!=None:
        self.labels=labels
        self.tabla=tabla
        self.db=db
        print(labels,' \n', 'desde filtros')
    retstr = "FILTROS: "


    if len(self.get_filters_values())>0 and labels==None:
        import inspect
        for flt, value in self.get_filters_values():
            print(self.labels[flt.column_name],flt.arg_name, flt.name, value)

            print(getattr(self.tabla, flt.column_name),type(getattr(self.tabla,flt.column_name)))
            #print('prueba',getattr(self.db.session.query(self.tabla).filter(getattr(self.tabla, flt.column_name) == value).all()[0]))
            """
                        if flt.column_name=="Estado" and value=="y":
                value=self.tabla().__class__.__name__+" Realizada"
            elif inspect.ismethod(getattr(self.tabla, flt.column_name) ):
                value=getattr(self.db.session.query(self.tabla).filter(getattr(self.tabla, flt.column_name) == value).all()[0],flt.column_name)()
            else:
                value=getattr(self.db.session.query(self.tabla).filter(getattr(self.tabla, flt.column_name) == value).all()[0], flt.column_name)
            """
            from dateutil.parser import parse


            try:
                if flt.column_name == "Estado" and value == "y":
                    value = self.tabla().__class__.__name__ + " Realizada"
                elif type(parse(value))==type(dt.now()) and flt.column_name=="fecha":
                    value=parse(value).strftime("%d/%m/%Y-%H:%M")
            except Exception as e:
                print(e.__str__())

            retstr = retstr + "%s %s %s\n" % (
                str(self.labels[flt.column_name]).capitalize(),flt.name,
                str(value),
            )
        return retstr
    else:
        return ""

def tipoClave_queryventa():
    print(g.user.__dict__.keys(), g.user.roles)

    return[i.id for i in db.session.query(Venta).filter(Venta.cliente_id == 1 ).all()]
class VentaReportes(AuditedModelView):
    # creo clase de manejador de la vista de ventas
    datamodel = SQLAInterface(Venta)
    list_title = "Listado de Ventas"
    label_columns = {"formatofecha":"Fecha","totaliva":"Alicuota Iva","totalrender":"Total",'formadepago':'Forma de Pago','renglonesrender':'','estadorender':'Estado'}
    list_columns = ['cliente','totaliva',"percepcion", "totalrender", 'estadorender','formatofecha']
    show_columns = ['cliente','totaliva',"percepcion", 'estadorender','formatofecha','renglonesrender']
    edit_columns = ['Estado']
    base_order = ('fecha', 'dsc')
    #base_filters = [["id",FilterInFunction,tipoClave_queryventa],]
    base_permissions = ['can_show','can_list', 'can_edit','can_delete']
    #list_template = "reportes.html"
    #related_views = [RenglonVentas,MetododepagoVentas]

    #show_template = 'appbuilder/general/model/show_cascade.html'
    show_template = "imprimirventa.html"
    list_widget = ListDownloadWidgetventa

    @expose('/csv', methods=['GET'])
    def download_csv(self):

        get_filter_args(self._filters)
        print(request.url)
        if self.base_order==None:
            count, lst = self.datamodel.query(self._filters)
        else:
           order_column, order_direction = self.base_order

           count, lst = self.datamodel.query(self._filters, order_column, order_direction)
           print(count , self.base_order)
        print(lst)
        print(request.url)
        filtros=self._filters
        filtros.__repr__ = types.MethodType(repre, filtros)
        filtros.__str__ = types.MethodType(repre, filtros)
        filtros.__repr__(self.label_columns,Venta,db=db)
        cabecera = (
            ("cliente", "Cliente"),("condicionFrenteIva", "Cond. Frente Iva"),("fecha", "Fecha"),
            ("formadepago", "Forma de Pago"),("total", "Total"),
        )
        generarReporte(titulo="Listado de ventas",cabecera=cabecera,buscar=Venta,nombre="Listado de ventas",datos=lst,filtros=self._filters)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de ventas" ))
    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        item = self.datamodel.get(pk, self._base_filters)
        item.Estado=False
        db.session.commit()
        self.post_update(item)
        self.update_redirect()
        return self.post_delete_redirect()


class CompraReportes(AuditedModelView):
    datamodel = SQLAInterface(Compra)
    list_widget =ListDownloadWidgetcompra
    list_title = "Listado de Compras"
    label_columns = {'renglonesrender':'',"totaliva":"Alicuota Iva", 'estadorender':'Estado','formatofecha':'Fecha',"percepcion":"Percepcion %"}
    list_columns = ['proveedor',"totaliva", "total", 'estadorender', 'formadepago','formatofecha',"percepcion"]
    show_columns = ['proveedor',"totaliva", 'total', 'estadorender','formadepago','formatofecha',"percepcion",'renglonesrender']
    edit_columns = ['Estado']
    base_order = ('fecha', 'dsc')
    base_permissions = ['can_show','can_list', 'can_edit','can_delete']




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
        filtros=self._filters
        filtros.__repr__ = types.MethodType(repre, filtros)
        print(request.url,request.full_path , request.full_path,request.base_url)
        print( filtros.__repr__(self.label_columns,Compra))


        generarReporte(titulo="Listado de Compras",cabecera=cabecera,buscar=Compra,nombre="Listado de Compras",datos=lst,filtros=self._filters)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de Compras" ))

    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        item = self.datamodel.get(pk, self._base_filters)
        item.Estado=False
        db.session.commit()
        self.post_update(item)
        self.update_redirect()
        return self.post_delete_redirect()



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
    Total = FloatField('Total $', render_kw={'disabled': '', 'type':"number"},
                       validators=[DataRequired()], default=0)
    numeroCupon = IntegerField('Numero de cupon', widget=BS3TextFieldWidget())
    companiaTarjeta = SelectField('Compania de la Tarjeta', coerce=str, choices=[(p.id, p) for p in db.session.query(CompaniaTarjeta)] )
    credito = BooleanField("Credito", default=False)
    descuento = FloatField("Descuento %", render_kw={ 'type':"number"}, default=0)
    percepcion = FloatField("Percepcion %", render_kw={ 'type':"number", 'disabled':''}, default=0)
    cuotas = FloatField("Cuotas", render_kw={ 'type':"number"}, default=0)
    totalneto = FloatField("Total Neto $", render_kw={'disabled': ''},default=0)
    totaliva= FloatField("Total IVA $", render_kw={ 'disabled': '','type':"number"}, default=0)

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
        responsableinscripto = str(db.session.query(EmpresaDatos).first().tipoClave) == "Responsable Inscripto"
        form2.producto.choices = [('{"id": ' + f'{p.id}' + ', "iva":' + f'"{p.iva}"' + ', "representacion":' + f'"{p.__str__()}"' + '}',  p.__str__()) for p  in db.session.query(Productos).filter(Productos.Estado == True).all()]

        form2.Fecha.data = dt.now()
        # cargo las elecciones de cliente
        form2.cliente.choices = [('{"id": ' + f'{c.id}'+', "tipoclave":' + f'"{c.tipoClave}"'+'}', c) for c in db.session.query(Clientes).filter(Clientes.estado==True).all()]
        # cargo las elecciones de metodo de pago
        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
        # cargo las elecciones de las tarjetas

        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta)]
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta

        self.update_redirect()
        #renderizo el html y le paso el formulario
        return render_template('venta.html', base_template=appbuilder.base_template, appbuilder=appbuilder, form2=form2,responsableinscripto=responsableinscripto)





#creo clase de formulario de renglon compra
class RenglonCompra(Form):
    proveedor=SelectField('Proveedor', coerce=str, choices=[(c.id, c) for c in db.session.query(Proveedor)])
    producto = SelectField('Producto', coerce=str, choices=[(p.id, p) for p in db.session.query(Productos)])
    cantidad = IntegerField('Cantidad', render_kw={ 'type':"number"}, widget=BS3TextFieldWidget())
    metodo = SelectField('Metodo de Pago', coerce=str, choices=[(p.id, p) for p in db.session.query(FormadePago)])
    Total = FloatField('Total', render_kw={'disabled': ''},
                       validators=[DataRequired()], default=0)
    #condicionfrenteiva = SelectField('Condicion Frente Iva', coerce=TipoClaves.coerce, choices=TipoClaves.choices())
    numeroCupon = IntegerField('Numero de cupon', render_kw={ 'type':"number"}, widget=BS3TextFieldWidget())
    companiaTarjeta = SelectField('Compania de la Tarjeta', coerce=str, choices=[(p.id, p) for p in db.session.query(CompaniaTarjeta)] )
    credito = BooleanField("Credito", default=False)
    cuotas = IntegerField("Cuotas", render_kw={ 'type':"number"}, default=0)
    percepcion = IntegerField("Percepcion %", render_kw={ 'type':"number"}, default=0)
    descuento = FloatField("Descuento %", render_kw={ 'type':"number"}, default=0)
    totalneto = FloatField("Total Neto $", render_kw={'disabled': ''},default=0)
    preciocompra = FloatField("Precio de Compra", render_kw={ 'type':"number"}, default=0)
    totaliva= FloatField("Total IVA $", render_kw={ 'disabled': '','type':"number"}, default=0)

#creo clase manejadora de la vista de realizar compra
class CompraView(BaseView):
    default_view = 'compra'
    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/compra/', methods=["GET", "POST"])
    @has_access
    def compra(self,id=None):


        #creo formulario
        form2 = RenglonCompra(request.form)
        #cargo las elecciones de producto
        form2.producto.choices = [('{"id": ' + f'{p.id}' + ', "iva":' + f'"{p.iva}"' + ', "representacion":' + f'"{p.__str__()}"' + '}', p.__str__()) for p
                                  in db.session.query(Productos).filter(Productos.Estado==True).all()]

        # cargo las elecciones de cliente
        form2.proveedor.choices = [('{"id": ' + f'{c.id}' + ', "tipoclave":' +f'"{c.tipoClave}"'+'}', c) for c in db.session.query(Proveedor)]
        # cargo las elecciones de metodo de pago
        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta)]
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta
        self.update_redirect()
        #renderizo el html y le paso el formulario
        iva=str(db.session.query(EmpresaDatos).first().tipoClave)=="Responsable Inscripto"
        return render_template('compra.html', base_template=appbuilder.base_template, appbuilder=appbuilder, form2=form2,iva=iva)
    class_permission_name = "compraclass"
    method_permission_name = {
        'compra': 'access'
    }




def tipoClave_query():
    print(g.user.__dict__.keys(), g.user.roles)
    return db.session.query(TipoClaves).filter(TipoClaves.tipoClave != "Consumidor Final" ).all()

class ProveedorView(AuditedModelView):
    """
    #creo clase de el manejador de proveedor
    """
    from wtforms.ext.sqlalchemy.fields import QuerySelectField
    datamodel = SQLAInterface(Proveedor)
    related_views = [Compra]
    #le digo los permisos

    base_permissions =['can_list','can_add','can_edit', 'can_delete' ]
    label_columns = {'tipoClave': 'Cond. Frente Iva'}
    add_columns = ["tipoPersona",'cuit', 'nombre', 'apellido', 'correo','tipoClave']
    list_columns = ["tipoPersona",'cuit', 'nombre', 'apellido','correo' ,'tipoClave']
    edit_columns = ["tipoPersona",'cuit', 'nombre', 'apellido', 'correo','tipoClave']
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
class ClientesView(AuditedModelView):
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
    add_columns = ["tipoPersona",'tipoClave','tipoDocumento','documento', 'nombre', 'apellido']
    list_columns = ["tipoPersona",'tipoClave','documento', 'nombre', 'apellido','tipoDocumento']
    edit_columns = ["tipoPersona",'tipoClave','documento', 'nombre', 'apellido','tipoDocumento','estado']
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

appbuilder.add_view(CrudProducto, "Productos",icon="fa-archive", category='Productos', category_icon='fa-archive' )

appbuilder.add_view(CompraView, "Compra", category='Compras', category_icon="fa-cart-plus" )
appbuilder.add_view(ClientesView, "Clientes")
appbuilder.add_view(ProveedorView, "Proveedor")


appbuilder.add_view(PrecioMdelview, "Control de Precios",category='Productos',icon='fa-dollar-sign')
appbuilder.add_view_no_menu(ProductoModelview)
appbuilder.add_view_no_menu(MarcasModelview)
appbuilder.add_view_no_menu(unidadesModelView)
appbuilder.add_view_no_menu(CategoriaModelview)
appbuilder.add_view_no_menu(ReportesView)
appbuilder.add_view_no_menu(MetododepagoVentas)
appbuilder.add_view(VentaReportes, "Reporte Ventas",icon="fa-save", category='Ventas' )
appbuilder.add_view(CompraReportes, "Reporte Compras",icon="fa-save", category='Compras' )

appbuilder.add_view(Sistemaview,'Datos Empresa',category='Security')

appbuilder.add_view_no_menu(Empresaview)
appbuilder.add_view_no_menu(CompaniaTarjetaview)
from .auditoria import *
appbuilder.add_view_no_menu(RenglonVentas)



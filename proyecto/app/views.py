from flask import render_template, request, jsonify,url_for,redirect,session, Markup, send_file
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder import ModelRestApi, BaseView, expose, has_access, MultipleView, SimpleFormView
from flask_appbuilder.views import ModelView, CompactCRUDMixin, MasterDetailView
from flask import flash
from flask_appbuilder.models.sqla.filters import FilterEqualFunction
from sqlalchemy import desc,asc

from .apis import *
from flask_appbuilder.models.sqla.filters import FilterEqualFunction,FilterEqual,FilterInFunction,FilterRelationManyToManyEqual

from flask_appbuilder.actions import action
from flask_appbuilder.urltools import  Stack


from wtforms import Form, BooleanField, StringField, validators, DateField, FloatField, IntegerField, FieldList, \
    SelectField, SubmitField, PasswordField
from .validadores.validadores import cuitvalidator, cuitvalidatorProveedores,fechavalidador

from twilio.twiml.messaging_response import MessagingResponse

from wtforms.validators import DataRequired,InputRequired
from flask_appbuilder.fieldwidgets import BS3TextFieldWidget, Select2Widget
from flask_babelpkg import gettext
from flask_appbuilder.urltools import get_filter_args
from flask_appbuilder.widgets import ListWidget
from .reportes import generarReporte
import types
from flask_babelpkg import lazy_gettext
from fab_addon_audit.views import AuditedModelView
from .modelo.ModelView import Modelovista
AuditedModelView.__bases__=(Modelovista,)
ModelView=Modelovista
from datetimepicker  import DateTimePickerWidget
#manejador en caso de que no se encuentre la pagina
@appbuilder.app.errorhandler(404)
def page_not_found(e):
    return (
        render_template(
            "404.html", base_template=appbuilder.base_template, appbuilder=appbuilder
        ),
        404,
    )



class ModulosInteligentesView(ModelView):
    datamodel = SQLAInterface(ModulosConfiguracion)
    label_columns = {'porcentaje_subida_precio':'Cuanto va a Subir el precio automaticamente despues de una Compra','descuento':'Porcentaje de descuento de ofertas por WhatsApp','twilio_account_sid':'SID de la cuenta de Twilio','modulo_pedidor':'Modulo de Pedidos','modulo_ofertas':'Modulo Ofertas WhatsApp'}
    list_columns = ['modulo_pedidor','modulo_ofertas']
    show_columns = ['porcentaje_subida_precio','dias_atras','porcentaje_ventas','fecha_vencimiento']
    base_permissions = ['can_edit','can_list']


    edit_form_extra_fields = {
        'dias_pedido': IntegerField('Días Pedido', render_kw={'type': "number", 'min': '0'},
                                   description="""Intervalo de cada cuantos días se ejecutara el modulo de pedidos de presupuesto"""),
        'dias_atras':  IntegerField('Días Anteriores',  render_kw={'type': "number",'min':'0'},
                                    description="""Numero de días anteriores que mirara el modulo de pedidos de presupuesto 
                                                             para realizar sus calculos; En caso de cambio es necesario reiniciar el servidor"""),
        'porcentaje_ventas':FloatField('Porcentaje de Ventas',  render_kw={'type': "number",'min':'0','max':'100','step':"0.01"},
                                    description=lazy_gettext("""Numero de porcentaje minimo de ventas respecto compras para
                                                                realizar el pedido de presupuesto""")),
        'fecha_vencimiento': IntegerField('Días antes de vencer',
                                        render_kw={'type': "number", 'min': '0', 'max': '100'},
                                        description=lazy_gettext("""Numero de días que quedan antes de que se venza un producto para 
                                                                realizar un pedido de presupuesto""")),
        'dias_oferta': IntegerField('Días Oferta', render_kw={'type': "number", 'min': '0'},
                                    description="""Intervalo de cada cuantos días se ejecutara el modulo de ofertas por whatsapp
                                                    En caso de cambio es necesario reiniciar el servidor"""),
        'fecha_vencimiento_oferta': IntegerField('Días antes de vencer', render_kw={'type': "number", 'min': '0'},
                                    description="""Numero de dias que quedan antes de que se venza un producto para 
                                                                realizar  ofertas por whatsapp"""),
        'twilio_auth_token': StringField('Clave de autentificacion de Twilio', render_kw={'type': "password"},
                                                 description="""Clave de autentificacion de Twilio para whatsapp"""),

        'descuento': IntegerField('Porcentaje de descuento de ofertas por WhatsApp',
                                                              render_kw={'type': "number"},validators=[InputRequired()]),
        'porcentaje_subida_precio':IntegerField('Cuanto va a Subir el precio automaticamente despues de una Compra',
                                                              render_kw={'type': "number"},validators=[InputRequired()])
    }






class Empresaview(ModelView):
    datamodel = SQLAInterface(EmpresaDatos)
    label_columns ={'photo_img':'logo', 'photo_img_thumbnail':'logo','tipoClave':'Cond Frente Iva'}
    list_title = "Datos de La Empresa"
    list_columns = ['compania','tipoClave','cuit','direccion','localidad','photo_img_thumbnail']
    show_columns = ['compania','tipoClave','cuit','direccion','localidad','photo_img']
    base_permissions = ['can_show', 'can_list', 'can_edit']
    edit_template = "editarempresa.html"
    validators_columns ={
        'cuit':[InputRequired(),cuitvalidatorProveedores]
    }


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
class ListDownloadWidgetstock(ListWidget):
    template = 'reportestock.html'
class ListDownloadWidgetcompra(ListWidget):
    template = 'reportecompras.html'
class ListWidgetProducto(ListWidget):
    template = 'productoshtml.html'


#creo y configuro la clase de manejador de  vista de productos


#creo y configuro la clase de manejador de  vista de productos
class ProductoModelview(AuditedModelView):
    list_template = "list.html"
    datamodel = SQLAInterface(Productos,session=db.session)
    #configuro vistas de crear, listar y editar

    list_title = "Listado de Productos"
    label_columns = {'estadorender':'Estado'}
    add_columns = ['categoria', 'marca','unidad', 'medida', 'precio','iva', 'detalle']
    list_columns = ['categoria', 'marca', 'medida','unidad', 'precio', 'stock','iva','estadorender', 'detalle']
    edit_columns = ['categoria','medida','unidad','marca','precio','iva','estado','detalle']
    show_exclude_columns = ['renglon_compra']
    search_exclude_columns = ['renglon_compra']
    base_order = ('categoria.id', 'dsc')
    # search_columns = ['producto','unidad','medida','marca','precio','stock']






#creo clase de manejador de vistas de marcas y unidad de medida
class MarcasModelview(ModelView):
    list_title = "Listado de Marcas"
    datamodel = SQLAInterface(Marcas)
    base_order = ('marca', 'asc')
    def post_add_redirect(self):
        self.update_redirect()
        return redirect(url_for("MarcasModelview.add"))

class CategoriaModelview(ModelView):
    list_title = "Listado de Categorías"
    datamodel = SQLAInterface(Categoria)
    label_columns = {'categoria':'Categoría'}
    base_order =  ('categoria','asc')

    def post_add_redirect(self):
        self.update_redirect()
        return redirect(url_for("CategoriaModelview.add"))




class unidadesModelView(ModelView):
    datamodel = SQLAInterface(UnidadMedida)
#creo clases de manejador de una vista que incluya las vistas de marcas y unidad de medidas
class CrudProducto(MultipleView):
    views = [MarcasModelview, unidadesModelView,CategoriaModelview]
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
    list_template = "list.html"
    datamodel = SQLAInterface(Productos)
    #configuro vistas de crear, listar y editar
    list_widget = ListWidgetProducto
    label_columns = {'medidarendercolumna':'medida','preciorendercolumna':'precio','stockarendercolumna':'stock','ivarendercolumna':'iva',
                     'estadorender': 'Estado','categoria':'Categoría','categoria.categoria':'categoria'}
    list_title = "Listado de Productos"
    add_columns = ['categoria', 'marca','unidad', 'medida', 'precio','iva', 'detalle']
    list_columns = ['categoria', 'marca', 'medidarendercolumna','unidad', 'preciorendercolumna', 'stockarendercolumna','ivarendercolumna','estadorender', 'detalle']
    show_columns = ['categoria', 'marca', 'medidarendercolumna','unidad', 'preciorendercolumna', 'stockarendercolumna','ivarendercolumna','estadorender', 'detalle']
    edit_columns = ['categoria','medida','unidad','marca','precio','iva','estado','detalle']
    show_exclude_columns = ['renglon_compra']
    search_exclude_columns = ['renglon_compra']

    order_rel_fields = {'categoria': ('categoria', 'asc'),'marca': ('marca', 'asc')}








    def post_add_redirect(self):
        self.update_redirect()
        return redirect(url_for("PrecioMdelview.add"))
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
    class_permission_name = "PrecioMdelviewip"
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
class RenglonComprasView(ModelView):
    datamodel = SQLAInterface(RenglonCompras)
    label_columns = {'formatofecha':'Fecha de Vencimiento','precioCompra':'Precio de Compra'}
    list_columns = ['producto','formatofecha']
    edit_columns = ['fecha_vencimiento']
    base_permissions = ['can_edit','can_list']
    edit_template = 'appbuilder/general/model/edit_cascade.html'
    edit_form_extra_fields = {
        'fecha_vencimiento':    DateField('Fecha de Vencimiento',
                                          widget= DateTimePickerWidget(),validators=[InputRequired(),fechavalidador] )
    }
def query_ComprasxProucto_Vencer():
    #return[i.id for i in db.session.query(RenglonCompras).filter(RenglonCompras.fecha_vencimiento>=dt.now().date(), RenglonCompras.vendido ==False).all()]
    return[i.id for i in db.session.query(RenglonCompras).filter( RenglonCompras.vendido ==False).all()]
class RenglonComprasxVencer(ModelView):
    datamodel = SQLAInterface(RenglonCompras)
    label_columns = {'vendidor':'vendido','formatofecha': 'Fecha de Vencimiento','precioCompra':'Precio de Compra','stock_lote':'Stock','fechacompra':'Fecha de Compra'}
    list_columns = ['producto', 'precioCompra', 'cantidad', 'descuento', 'formatofecha','fechacompra','vendidor','stock_lote']
    base_permissions = ['can_list']
    base_filters = [["id", FilterInFunction, query_ComprasxProucto_Vencer], ]
    list_title = "Detalle de Lotes por Producto"

    #list_template = 'productos_vencidos.html'
    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        renglon=db.session.query(RenglonCompras).filter(RenglonCompras.id==pk).first()
        renglon.vendido=True
        self.datamodel.edit(renglon)
        return redirect(self.get_redirect())

def query_producto_por_Vencer():
    #return[i.id for i in db.session.query(Productos).join(RenglonCompras).filter(RenglonCompras.fecha_vencimiento>=dt.now().date() ,RenglonCompras.vendido==False).all()]

    return[i.id for i in db.session.query(Productos).join(RenglonCompras).join(Productos.marca).join(Productos.categoria).filter(RenglonCompras.vendido==False).order_by(asc(Productos.categoria),asc(Productos.marca)).all()]
def query_producto_ordencategoria():
    #return[i.id for i in db.session.query(Productos).join(RenglonCompras).filter(RenglonCompras.fecha_vencimiento>=dt.now().date() ,RenglonCompras.vendido==False).all()]

    return[i.id for i in db.session.query(Categoria).order_by(asc(Categoria.categoria)).all()]

class ProductoxVencer(ModelView):
    datamodel = SQLAInterface(Productos)
    list_title = "Listado de Lotes del Producto"
    label_columns = {'medidarendercolumna':'medida','preciorendercolumna':'precio','stockarendercolumna':'stock','ivarendercolumna':'iva',
                     'estadorender': 'Estado','categoria':'Categoría','categoria.categoria':'categoria','detaller': 'Producto','rengloneslotescolumna':'Lote','stock':'Total'}
    list_columns = ['detaller','rengloneslotescolumna','stock']
    show_columns = ['categoria', 'marca', 'medidarendercolumna','unidad', 'preciorendercolumna', 'stockarendercolumna','ivarendercolumna','estadorender', 'detalle']

    base_permissions = ['can_list','can_show']
    base_filters = [["id", FilterInFunction, query_producto_por_Vencer], ]
    show_exclude_columns = ['renglon_compra']
    #search_form_query_rel_fields = {'categoria':[["id", FilterInFunction, query_producto_ordencategoria]]}
    #order_columns = ['categoria']
    base_order = ('stock','asc')
    list_widget = ListDownloadWidgetstock
    search_exclude_columns = ['renglon_compra']
    order_rel_fields = {'categoria': ('categoria', 'asc'), 'marca': ('marca', 'asc')}
    order_columns = ['detaller']
    related_views = [RenglonComprasxVencer]


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
        filtros.__repr__(self.label_columns,ProductoxVencer,db=db)
        cabecera = (
            ("detaller", "Producto"),("rengloneslotesimprimir", "Lote"),("stock", "Total")
        )
        from .reportestock import  generarReporteStock
        generarReporteStock(titulo="Listado de Stock",cabecera=cabecera,buscar=Productos,nombre="Listado de Stock",datos=lst,filtros=self._filters,no_registros=count)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de Stock" ))

def query_producto_Vencido():
    return[i.id for i in db.session.query(RenglonCompras).filter(RenglonCompras.fecha_vencimiento<=dt.now().date() , RenglonCompras.stock_lote>0 ).all()]
class RenglonComprasVencidos(ModelView):
    datamodel = SQLAInterface(RenglonCompras)
    list_title = 'Lotes Vencidos'
    label_columns = {'formatofecha': 'Fecha de Vencimiento','precioCompra':'Precio de Compra','stock_lote':'Stock','fechacompra':'Fecha de Compra'}
    list_columns = ['producto', 'precioCompra', 'cantidad', 'descuento', 'formatofecha','fechacompra','vendido','stock_lote']
    base_permissions = ['can_list','can_delete']

    base_filters = [["id", FilterInFunction, query_producto_Vencido], ]
    #list_template = 'productos_vencidos.html'


    # @action("anular_vencido","Descontar vencido","Seguro de Decontar el stock de los productos seleccionados?", "fa-backspace", single=False)
    #     # def anular_vencido(self, item):
    #     #     print(item)
    #     #     return redirect(self.get_redirect())
    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        try:
            renglon=db.session.query(RenglonCompras).filter(RenglonCompras.id==pk).first()
            producto=db.session.query(Productos).filter(Productos.id==RenglonCompras.producto_id).first()
            #precioauditado=PrecioMdelview()
            #precioauditado.datamodel=SQLAInterface(Productos,session=db.session)
            #precioauditado.pre_pre_update(copy.copy(producto))
            producto.stock-=renglon.stock_lote
            renglon.stock_lote=0
            db.session.commit()
            #precioauditado.post_update(producto)



        except Exception as e:
            print(e)
            print(str(e))
            print(repr(e))
            db.session.rollback()

        self.update_redirect()
        return redirect(self.get_redirect())

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

            #print(getattr(self.tabla, flt.column_name),type(getattr(self.tabla,flt.column_name)))
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
            from flask_appbuilder.models.sqla.filters import FilterRelationOneToManyEqual


            try:
                if flt.name=='Relación':
                    from sqlalchemy import inspect
                    from inspect import ismethod, getmembers

                    i = inspect(self.datamodel.obj)
                    thing_relations = inspect(self.datamodel.obj).relationships.items()
                    # for i in self.get_relation_cols():
                    #     if i==self.labels[flt.column_name]:
                    #         print(db.session.query(getattr(self, self.labels[flt.column_name])).get(value))
                    print(self.datamodel.obj.__table__.columns.keys(),self.datamodel.obj().__class__)
                    #valor=getattr(self.datamodel.obj.__table__.columns, self.labels[flt.column_name])
                    #print(type(getattr(self.datamodel.obj.__table__.columns, self.labels[flt.column_name])))
                    #objeto = db.session.query(self.datamodel.obj()).get(1)
                    print(self.datamodel.obj())
                    print(self.datamodel.obj().__table__)
                    print(self.datamodel.obj().__class__)
                    #print(self.datamodel.obj().__table__.columns)
                    #print(getattr(objeto.__table__.columns, self.labels[flt.column_name]))
                    for atributes in self.datamodel.obj.__table__.columns.keys():
                        # print()
                        # if callable(getattr(self.datamodel.obj,atributes)):
                        try:
                            print(self.datamodel.obj().__class__)
                            print(getattr(self.datamodel.obj().__class__,atributes),getattr(self.datamodel.obj().__class__.__table__.columns,atributes).__class__.__name__)
                            if getattr(self.datamodel.obj(),atributes).__class__.__name__==self.labels[flt.column_name]:
                                print('Encontro: ')
                                value=db.session.query(getattr(self.datamodel.obj,atributes).__class__).get(value)
                                print('Encontro: ',value.__str__())
                        except Exception as e:
                            import sys, os
                            exc_type, exc_obj, exc_tb = sys.exc_info()
                            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                            print(exc_type, fname, exc_tb.tb_lineno)
                            print(str(e))
                            print(e.__str__())
                    #print(db.session.query(valor).get(value))
                    #value=db.session.query(valor).get(value).__str__()


                if flt.column_name == "estado" and value == "y":
                    value = self.tabla().__class__.__name__ + " Realizada"
                elif type(parse(value))==type(dt.now()) and flt.column_name=="fecha":
                    value=parse(value).strftime("%d/%m/%Y-%H:%M")


            except Exception as e:
                import sys, os
                exc_type, exc_obj, exc_tb = sys.exc_info()
                fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                print(exc_type, fname, exc_tb.tb_lineno)
                print(str(e))
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
    list_template = "list.html"
    datamodel = SQLAInterface(Venta)
    list_title = "Listado de Ventas"
    label_columns = {'totaliva':'Iva','totalivarendercolumna':'Iva','percepcionrendercolumna':'Percepcion','percepcionrender':'Percepción %',"formatofecha":"Fecha","totalivarender":"Iva $","totalrender":"Total",'formadepago':'Forma de Pago','renglonesrender':'','estadorender':'Estado'}
    list_columns = ['formatofecha','comprobante','cliente','totalivarendercolumna',"percepcionrendercolumna", "totalrender", 'estadorender',]
    show_columns = ['cliente','comprobante','totalivarender',"percepcionrender", 'estadorender','formatofecha','renglonesrender']
    edit_columns = ['estado']
    base_order = ('comprobante', 'dsc')

    #base_filters = [["id",FilterInFunction,tipoClave_queryventa],]
    base_permissions = ['can_show','can_list','can_delete']
    #list_template = "reportes.html"
    #related_views = [RenglonVentas,MetododepagoVentas]

    #show_template = 'appbuilder/general/model/show_cascade.html'
    #show_template = "imprimirventa.html"
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
        generarReporte(titulo="Listado de ventas",cabecera=cabecera,buscar=Venta,nombre="Listado de ventas",datos=lst,filtros=self._filters,no_registros=count)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de ventas" ))



class CompraReportes(AuditedModelView):
    list_template = "list.html"
    datamodel = SQLAInterface(Compra)
    list_widget =ListDownloadWidgetcompra
    list_title = "Listado de Compras"
    label_columns = {'totalivarender':'Iva','totalivarendercolumna':'Iva','percepcionrendercolumna':'Percepcion','percepcionrender':'Percepcion','total':'Total $','formadepago':'Forma de Pago','totalrender':'Total','formadepago.Metodo':'Forma de Pago','renglonesrender':'',"totaliva":"Iva $", 'estadorender':'Estado','formatofecha':'Fecha',"percepcion":"Percepción %"}
    list_columns = ['formatofecha','comprobante','proveedor',"totalivarendercolumna","percepcionrendercolumna", "totalrender", 'estadorender', 'formadepago']
    show_columns = ['proveedor','comprobante',"totalivarender", 'total', 'estadorender','formadepago','formatofecha',"percepcionrender",'renglonesrender']
    search_columns = ['proveedor',"totaliva", "total", 'estado', 'formadepago','fecha',"percepcion"]
    order_columns =  ['proveedor',"totaliva", "total", 'estado', 'formadepago','fecha',"percepcion"]
    base_order = ('id', 'dsc')
    base_permissions = ['can_show','can_list','can_delete','can_download_pdf']
    related_views = [RenglonComprasView]
    search_exclude_columns = ['totaliva','totalneto']





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


        generarReporte(titulo="Listado de Compras",cabecera=cabecera,buscar=Compra,nombre="Listado de Compras",datos=lst,filtros=self._filters,no_registros=count)
        return redirect(url_for('ReportesView.show_static_pdf',var="Listado de Compras" ))





from flask_wtf import FlaskForm

#creo clase de formulario de venta
class RenglonVenta(Form):
    cliente=SelectField('Cliente', coerce=str, choices=[(c.id, c) for c in db.session.query(Clientes)])
    Fecha = DateField('Fecha', format='%d-%m-%Y %H:%M:%S', default=dt.now(), render_kw={'disabled': ''},
                      validators=[DataRequired()])
    producto = SelectField('Producto', coerce=str, choices=[(p.id, p) for p in db.session.query(Productos)])
    cantidad = IntegerField('Cantidad', widget=BS3TextFieldWidget(), render_kw={'type': "number"})
    metodo = SelectField('Forma de Pago', coerce=str, choices=[(p.id, p) for p in db.session.query(FormadePago)])
    #condicionfrenteiva= SelectField('Condicion Frente Iva', coerce=TipoClaves.coerce, choices=TipoClaves.choices() )
    total = FloatField('Total $', render_kw={'disabled': '','align':'right'},
                       validators=[DataRequired()], default=0)
    numeroCupon = IntegerField('Numero de cupon', render_kw={'type':'number'}, widget=BS3TextFieldWidget())
    companiaTarjeta = SelectField('Compania de la Tarjeta', coerce=str, choices=[(p.id, p) for p in db.session.query(CompaniaTarjeta)] )
    credito = BooleanField("Credito", default=False)
    descuento = FloatField("Descuento %",  default=0)
    percepcion = FloatField("Percepcion %", render_kw={'disabled':''}, default=0)
    cuotas = FloatField("Cuotas", render_kw={ 'type':"number"}, default=0)
    totalneto = FloatField("Total Neto $", render_kw={'disabled': '','align':'right'},default=0)
    totaliva= FloatField("Total IVA $", render_kw={ 'disabled': '','type':"number",'align':'right'}, default=0)
    comprobante = FloatField("Comprobante", render_kw={'type': "number"}, default=0)

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

        form2.producto.choices = [('{"id": ' + f'{p.id}' + ', "iva":' + f'"{p.iva}"' + ', "representacion":' + f'"{p.__str__()}"' + '}',  p.__str__()) for p  in db.session.query(Productos).filter(Productos.estado == True,Productos.stock>0 )
            .join(Productos.categoria).join(Productos.marca).order_by(asc(Categoria.categoria),asc(Marcas.marca)).all()]

        form2.Fecha.data = dt.now()
        # cargo las elecciones de cliente
        form2.cliente.choices = [('{"id": ' + f'{c.id}'+', "tipoclave":' + f'"{c.tipoClave}"'+'}', c) for c in db.session.query(Clientes).filter(Clientes.estado==True).all()]
        # cargo las elecciones de metodo de pago
        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
        # cargo las elecciones de las tarjetas
        from sqlalchemy import Sequence
        #COMPROBANTE_SEQ = Sequence('ventas_comprobante_seq')
        #print(COMPROBANTE_SEQ.next_value())
        comprobante_alto = db.session.query(func.max(Venta.comprobante)).first()
        if comprobante_alto[0] ==None:
            comprobante_alto=[]
            comprobante_alto.append(0)
        form2.comprobante.data=int(comprobante_alto[0]+1)
        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta).filter(CompaniaTarjeta.estado==True)]
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta

        self.update_redirect()
        #renderizo el html y le paso el formulario
        return render_template('venta.html', base_template=appbuilder.base_template, appbuilder=appbuilder, form2=form2,responsableinscripto=responsableinscripto)
    class_permission_name = "ventaclass"
    method_permission_name = {
        'venta': 'access'
    }




#creo clase de formulario de renglon compra
class RenglonCompra(Form):
    proveedor=SelectField('Proveedor', coerce=str, choices=[(c.id, c) for c in db.session.query(Proveedor)])
    producto = SelectField('Producto', coerce=str, choices=[(p.id, p) for p in db.session.query(Productos)])
    cantidad = IntegerField('Cantidad', render_kw={ 'type':"number"}, widget=BS3TextFieldWidget())
    metodo = SelectField('Metodo de Pago', coerce=str, choices=[(p.id, p) for p in db.session.query(FormadePago)])
    total = FloatField('Total', render_kw={'disabled': '','align':'right'},
                       validators=[DataRequired()], default=0)
    #condicionfrenteiva = SelectField('Condicion Frente Iva', coerce=TipoClaves.coerce, choices=TipoClaves.choices())
    numeroCupon = IntegerField('Numero de cupon', render_kw={ 'type':"number"}, widget=BS3TextFieldWidget())
    companiaTarjeta = SelectField('Compania de la Tarjeta', coerce=str, choices=[(p.id, p) for p in db.session.query(CompaniaTarjeta)] )
    credito = BooleanField("Credito", default=False)
    cuotas = IntegerField("Cuotas", render_kw={ 'type':"number"}, default=0)
    percepcion = IntegerField("Percepcion %", render_kw={ 'type':"number"}, default=0)
    descuento = FloatField("Descuento %", render_kw={ 'type':"number"}, default=0)
    totalneto = FloatField("Total Neto $", render_kw={'disabled': '','align':'right'},default=0)
    preciocompra = FloatField("Precio de Compra", default=0)
    totaliva= FloatField("Total IVA $", render_kw={ 'disabled': '','type':"number",'align':'right'}, default=0)
    fecha = DateField("Fecha",widget=DateTimePickerWidget())
    comprobante = FloatField("Comprobante", render_kw={'type': "number"}, default=0)

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
                                  in db.session.query(Productos).filter(Productos.estado==True).join(Productos.categoria).join(Productos.marca).order_by(asc(Categoria.categoria),asc(Marcas.marca)).all()]

        # cargo las elecciones de cliente
        form2.proveedor.choices = [('{"id": ' + f'{c.id}' + ', "tipoclave":' +f'"{c.tipoClave}"'+'}', c) for c in db.session.query(Proveedor).filter(Proveedor.estado==True)]
        # cargo las elecciones de metodo de pago
        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta).filter(CompaniaTarjeta.estado==True)]
        # le digo que guarde la url actual en el historial
        #esto sirve para cuando creas un cliente que te redirija despues a la venta
        comprobante_alto = db.session.query(func.max(Compra.comprobante)).first()
        if comprobante_alto[0] ==None:
            comprobante_alto=[]
            comprobante_alto.append(0)
        form2.comprobante.data = int(comprobante_alto[0] + 1)

        self.update_redirect()
        #renderizo el html y le paso el formulario
        self.update_redirect()
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
    list_template = "list.html"
    related_views = [Compra]
    #le digo los permisos

    base_permissions =['can_list','can_add','can_edit', 'can_delete' ,'can_show']
    label_columns = {'direccion':'Dirección','nombre':'Nombre/Denominación','apellido':'Apellido/Razon Social','tipoClave': 'Cond. Frente Iva','estadorender': 'Estado',"tipoPersona":"Tipo de Persona"}
    add_columns = ["tipoPersona",'tipoClave','cuit', 'nombre', 'apellido', 'correo','direccion','localidad']
    list_columns = ["tipoPersona",'cuit', 'nombre', 'apellido','correo' ,'tipoClave','estadorender']
    edit_columns = ["tipoPersona",'tipoClave','cuit', 'nombre', 'apellido', 'correo','direccion','localidad','estado']
    show_columns =  ["tipoPersona",'tipoClave','cuit', 'nombre', 'apellido', 'correo','direccion','localidad','estadorender']
    add_template = "addproveedor.html"
    edit_template = "editproveedor.html"

    validators_columns ={
        'cuit':[InputRequired(),cuitvalidatorProveedores]
    }
    from .validadores.validadortelefono import validadornumerotelefono
    add_form_extra_fields = {
        'tipoClave':  QuerySelectField(
                            'Cond. Frente Iva',
                            query_factory=tipoClave_query,
                            widget=Select2Widget("readonly")
                       ),
        'telefono_celular': IntegerField('Numero de Celular', render_kw={'type': "number", 'min': '0'},validators=[validadornumerotelefono],
                                         description="""Por defecto se toma el codigo pais +549 (Argentina) usted solo debe ingresar caracteristica+numero del celular sin espacios""")
    }

    edit_form_extra_fields = {
        'tipoClave':  QuerySelectField(
                            'Cond. Frente Iva',
                            query_factory=tipoClave_query,
                            widget=Select2Widget("readonly")
                       ),
        'telefono_celular': IntegerField('Numero de Celular', render_kw={'type': "number", 'min': '0'},validators=[validadornumerotelefono],
                                         description="""Por defecto se toma el codigo pais +549 (Argentina) usted solo debe ingresar caracteristica+numero del celular sin espacios""")

    }



#creo clase de el manejador de clientes
class ClientesView(AuditedModelView):
    datamodel = SQLAInterface(Clientes)
    list_template = "list.html"
    #le digo los permisos
    base_permissions =['can_list','can_add','can_edit', 'can_delete' ,'can_show']
    message="cliente creado"

    #presonalizando las etiquetas de las columnas
    label_columns = {'telefono':'Celular','nombre':'Nombre/Denominacion','apellido':'Apellido/Razon Social','tipoDocumento':'Tipo de Documento' ,'tipoClave':'Tipo de Clave',"tipoPersona":"Tipo de Persona",'estadorender': 'Estado'}
    #filtrando los valores
    #base_filters = [['estado', FilterEqual, True]]#descomentar para que filtre solo los activos

    #configurando las columnas de las vistas crear listar y editar
    add_columns = ["tipoPersona",'tipoClave','tipoDocumento','documento', 'nombre', 'apellido','telefono_celular','direccion','localidad']
    list_columns = ["tipoPersona",'tipoClave','documento', 'nombre', 'apellido','tipoDocumento','telefono','estadorender']
    show_columns = ["tipoPersona",'tipoClave','documento', 'nombre', 'apellido','tipoDocumento','estadorender','telefono','direccion','localidad']
    edit_columns = ["tipoPersona",'tipoClave','tipoDocumento','documento', 'nombre', 'apellido','estado','telefono_celular','direccion','localidad']
    add_template = "clienteaddedit.html"
    edit_template = "editcliente.html"
    from .validadores.validadortelefono import validadornumerotelefono
    edit_form_extra_fields = {
        'telefono_celular': StringField('Numero de Celular', render_kw={'type': "number"},validators=[validadornumerotelefono],
                                    description="""Por defecto se toma el codigo pais +549 (Argentina) usted solo debe ingresar caracteristica+numero del celular sin espacios""")}
    add_form_extra_fields = {
        'telefono_celular': StringField('Numero de Celular', render_kw={'type': "number"},validators=[validadornumerotelefono],
                                    description="""Por defecto se toma el codigo pais +549 (Argentina) usted solo debe ingresar caracteristica+numero del celular sin espacios""")}



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
    def post_post_add(self, item):
        urlanterior =self.get_redirect_anterior()
        try:
            url="http://localhost.localdomain:8080"+url_for("VentaView.venta")
            if urlanterior== url:
                flash("Cliente Creado", "nuevocliente")
        except Exception as e:
            print(e)
            print(str(e))
            flash("Error ocurrido", "error")
            print(repr(e))
        #se guarada el enlace en el historial
        self.update_redirect()


    validators_columns ={
        'documento':[InputRequired(),cuitvalidator("tipoDocumento")]
    }
class RenglonPedidoView(ModelView):
    datamodel = SQLAInterface(RenglonPedido)
    list_columns = ["producto","cantidad"]
    base_permissions = ['can_list']
class PedidoView(ModelView):
    datamodel = SQLAInterface(Pedido_Proveedor)
    label_columns = {'id':'Numero de Pedido','proveedor.representacion':'Proveedor','formatofecha':'Fecha'}
    list_columns = ["id","formatofecha",'proveedor.representacion']
    show_columns = ['proveedor',"id","formatofecha"]
    base_permissions = ['can_show','can_list']
    order_columns =['id','fecha']
    search_exclude_columns = ['renglones']
    list_title = 'Lista de Pedidos de Presupesto'
    show_title = 'Detalle de Pedido de Presupuesto'
    related_views = [RenglonPedidoView]
    base_order = ('id','desc')

class OfertaWhatsappView(ModelView):
    datamodel = SQLAInterface(OfertaWhatsapp)
    list_title = 'Lista de Ofertas por Whatsapp'
    label_columns = {'canceladorender':'Cancelado','fechaexpiracion':'Fecha de Expiración','formatofecha':'Fecha','cantidadrender':'Cantidad','reservadorender':'Reservado','hash_activacion':'Codigo de reserva','vendidorender':'Vendido'}
    list_columns = ['formatofecha', 'fechaexpiracion','hash_activacion','cliente','producto','cantidadrender','reservadorender','vendidorender','canceladorender']
    base_order = ('id', 'dsc')
    base_permissions = ['can_list','can_show','can_delete']
    # @action("Confirmar_Venta","Confirmar Venta","Seguro de convertir este pedido en una venta?", "fa-backspace", single=False)
    # def Confirmar_Venta(self, item):
    #
    #      print(item)
    #      items=item
    #      for oferta in items:
    #         renglonCompras=db.session.query(RenglonCompras).filter(RenglonCompras.id == oferta.renglon_compra_id).first()
    #
    #      self.update_redirect()
    #      return redirect(self.get_redirect())
    @expose("/show/<pk>", methods=["GET"])
    @has_access
    def show(self, pk):
        oferta = db.session.query(OfertaWhatsapp).filter(OfertaWhatsapp.id == int(pk)).first()
        if oferta.reservado==False:
            flash('Pedido NO reservado, no se puede convertir a venta', 'warning')
            return redirect(self.get_redirect())
        self.update_redirect()
        return redirect(url_for('ConvertirVenta.convertir_pedido_oferta_venta', pk=pk))
    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        self.update_redirect()
        oferta = db.session.query(OfertaWhatsapp).filter(OfertaWhatsapp.id == pk).first()
        if oferta.reservado == True and oferta.cancelado == False and oferta.vendido==False:
            oferta.reservado = False
            oferta.vendido=False
            oferta.cancelado = True
            oferta.renglon_compra.stock_lote += oferta.cantidad
            oferta.renglon_compra.producto.stock += oferta.cantidad#verificar si al convertir hace falta sumar el stock directo al producto
            db.session.commit()
            flash('Oferta cancelada','success')
            return redirect(self.get_redirect())
        else:
            if oferta.cancelado == True:
                flash('Oferta ya Cancelada no se puede volver a cancelar', 'success')
                return redirect(self.get_redirect())
            elif oferta.vendido==True:
                flash('Oferta ya Vendida no se puede cancelar', 'success')
                return redirect(self.get_redirect())

        flash('Oferta ya cancelada', 'success')
        return redirect(self.get_redirect())

class PediddosClientesView(ModelView):
    datamodel = SQLAInterface(PedidoCliente)
    related_views = [Venta]
    label_columns = {'canceladorender':'Cancelado','reservadorender':'Reservado','fechaexpiracion':'Fecha de Expiración','formatofecha':'Fecha','vendidorender':'Vendido','hash_activacion':'Codigo de reserva','expiracion':'Fecha de expiracíon'}
    list_columns = ['formatofecha','fechaexpiracion','hash_activacion','cliente','reservadorender','vendidorender','canceladorender']
    base_permissions = ['can_list','can_show','can_delete']
    base_order = ('id', 'dsc')

    @expose("/show/<pk>", methods=["GET"])
    @has_access
    def show(self, pk):
        pedido = db.session.query(PedidoCliente).filter(PedidoCliente.id == pk).first()
        if pedido.reservado==False:
            flash('Pedido NO reservado, no se puede convertir a venta', 'warning')
            return redirect(self.get_redirect())
        self.update_redirect()
        return redirect(url_for('ConvertirVenta.convertir_pedido_venta', pk=pk))
    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        self.update_redirect()
        pedido = db.session.query(PedidoCliente).filter(PedidoCliente.id == pk).first()
        if pedido.reservado == True and pedido.cancelado==False and pedido.vendido==False:
            #if pedido.venta !=None:
            if pedido.vendido==True and pedido.cancelado==False:
                flash('Pedido ya convertido a venta y realizado Para anular tendra que ir a a anular la venta directamente', 'warning')
                return redirect(self.get_redirect())
            # elif pedido.vendido==True:
            #     flash('A Ocurrido un error sobre el pedido que queria anular por favor contacte con los tecnicos para solucionar esto', 'warning')
            #     return redirect(self.get_redirect())
            else:
                try:
                    pedido.reservado = False
                    #venta=pedido.venta
                    #venta.estado==False
                    pedido.cancelado = True
                    for renglon in pedido.renglonespedido:
                        asumar=renglon.cantidad
                        for rengloncompra in renglon.renglonespedidocompras:
                            if rengloncompra.stock_lote + asumar < rengloncompra.cantidad:
                                rengloncompra.stock_lote += asumar
                                rengloncompra.vendido = False
                                print(rengloncompra.producto, rengloncompra.stock_lote, asumar)
                                break
                            else:
                                rengloncompra.vendido = False
                                asumar = asumar - (rengloncompra.cantidad - rengloncompra.stock_lote)
                                rengloncompra.stock_lote = rengloncompra.cantidad

                        renglon.producto.stock+=renglon.cantidad
                    db.session.commit()
                except Exception as e:
                    print(e)
                    print(str(e))
                    print(repr(e))
                    db.session.rollback()
                    flash('Pedido NO anulado, algo a sucedido mientras se intentaba anular.', 'warning')
                    return redirect(self.get_redirect())
                flash('Pedido Cancelado,los productos del pedido se sumaron al stock general','success')
                return redirect(self.get_redirect())
        else:
            if pedido.cancelado == True:
                flash('Pedido ya Cancelado no se puede volver a cancelar', 'success')
                return redirect(self.get_redirect())
            elif pedido.vendido == True:
                flash('Pedido ya Vendido no se puede cancelar', 'success')
                return redirect(self.get_redirect())
            flash('Pedido no reservado no hay nada que anular', 'warning')
            return redirect(self.get_redirect())

        flash('Pedido ya Cancelado', 'warning')
        return redirect(self.get_redirect())
class RenglonPedidoWhatsappOferta():

    def __init__(self,producto,cantidad,precioVenta,descuento):
        self.cantidad=cantidad
        self.producto=producto
        self.precioVenta = precioVenta
        self.descuento = descuento

    # defino como se representara al ser llamado
    def __repr__(self):
        return f"{self.producto} ${self.precioVenta:.2f} {self.pedidocliente} {self.producto} {self.cantidad} "
    def subtotal(self):
        return  format((self.precioVenta * self.cantidad) * (1 - self.descuento / 100), '.2f')
class ConvertirVenta(AuditedModelView):
    datamodel = SQLAInterface(Venta)
    related_views = [RenglonVentas]
    search_exclude_columns = ['venta']
    @expose('/convertir_pedido_venta/<pk>', methods=["GET"])
    def convertir_pedido_venta(self,pk):

        pedido=db.session.query(PedidoCliente).get(pk)
        if pedido.reservado and not pedido.vendido:
            #return render_template("convertir_pedido.html",pedido=pedido,formasdepago=pedido.venta.formadepagos,renglones=pedido.venta.renglones,venta=pedido.venta, base_template=appbuilder.base_template,
            #                                       appbuilder=appbuilder)
            from .modulos_inteligentes.modelo_whatsapp import RenglonVentapedido
            form2 = RenglonVentapedido(request.form)
            #form2.descuento.render_kw = {'disabled': 'false'}
            #form2.percepcion.render_kw = {'disabled': 'false'}

            # cargo las elecciones de producto
            responsableinscripto = str(
                db.session.query(EmpresaDatos).first().tipoClave) == "Responsable Inscripto"
            comprobante_alto = db.session.query(func.max(Venta.comprobante)).first()
            form2.comprobante.data = int(comprobante_alto[0] + 1)
            form2.producto.choices = [(
                '{"id":'+f'{p.id}'+',"iva":'+f'"{p.iva}"'+',"representacion":'+ f'"{p.__str__()}"'+'}',
                p.__str__()) for p in
                db.session.query(Productos).filter(Productos.estado == True,
                                                   Productos.stock > 0)
                    .join(Productos.categoria).join(Productos.marca).order_by(
                    asc(Categoria.categoria), asc(Marcas.marca)).all()]

            # cargo las elecciones de cliente
            cliente = db.session.query(Clientes).filter(Clientes.estado == True,
                                                        Clientes.id == pedido.cliente.id).first()
            form2.clienteidentificador.data = cliente.__repr__()
            # cargo las elecciones de metodo de pago
            form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
            # cargo las elecciones de las tarjetas

            form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta).filter(
                CompaniaTarjeta.estado == True)]
            cargarform = True
            return render_template("convertir_pedido_whatsapp.html", form2=form2,pedido=pedido,
                                   renglones=pedido.renglonespedido,cargarform=cargarform,
                                   base_template=appbuilder.base_template,
                                                   appbuilder=appbuilder)
        else:
            flash('No se puede ver el detalle porque no esta reservado','warning')
            return redirect(self.get_redirect())



    @expose('/convertir_pedido_oferta_venta/<pk>', methods=["GET"])
    def convertir_pedido_oferta_venta(self,pk):
        oferta = db.session.query(OfertaWhatsapp).filter(OfertaWhatsapp.id == int(pk)).first()
        # renglonCompras = db.session.query(RenglonCompras).filter(RenglonCompras.id == oferta.renglon_compra_id).first()
        # venta=Venta(fecha=dt.now())
        #
        # db.session.add(venta)
        # db.session.add(Renglon(precioVenta=oferta.producto.precio, cantidad=p["cantidad"], venta=venta, producto=oferta.producto,
        #                        descuento=oferta.descuento))
        #pedido=db.session.query(PedidoCliente).get(pk)
        if oferta.reservado and not oferta.vendido:
            #return render_template("convertir_pedido.html",pedido=pedido,formasdepago=pedido.venta.formadepagos,renglones=pedido.venta.renglones,venta=pedido.venta, base_template=appbuilder.base_template,
            #                                       appbuilder=appbuilder)
            from .modulos_inteligentes.modelo_whatsapp import RenglonVentapedido

            form2 = RenglonVentapedido(request.form)
            comprobante_alto = db.session.query(func.max(Venta.comprobante)).first()
            form2.comprobante.data = int(comprobante_alto[0] + 1)
            #form2.descuento.render_kw = {'disabled': 'false'}
            form2.percepcion.render_kw = {'disabled': 'false'}

            # cargo las elecciones de producto
            responsableinscripto = str(
                db.session.query(EmpresaDatos).first().tipoClave) == "Responsable Inscripto"

            form2.producto.choices = [(
                '{"id":'+f'{p.id}'+',"iva":'+f'"{p.iva}"'+',"representacion":'+ f'"{p.__str__()}"'+'}',
                p.__str__()) for p in
                db.session.query(Productos).filter(Productos.estado == True,
                                                   Productos.stock > 0)
                    .join(Productos.categoria).join(Productos.marca).order_by(
                    asc(Categoria.categoria), asc(Marcas.marca)).all()]

            # cargo las elecciones de cliente
            cliente = db.session.query(Clientes).filter(Clientes.estado == True,
                                                        Clientes.id == oferta.cliente.id).first()
            form2.clienteidentificador.data = cliente.__repr__()
            # cargo las elecciones de metodo de pago
            form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
            # cargo las elecciones de las tarjetas

            form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta).filter(
                CompaniaTarjeta.estado == True)]
            cargarform = True
            from .apis import preciocalculoiva
            data = {'p': oferta.producto.id, 'cliente_condfrenteiva': oferta.cliente.tipoClave.__repr__()}
            precio = preciocalculoiva(data)
            renglonespedido=[RenglonPedidoWhatsappOferta(precioVenta=float(precio),cantidad=oferta.cantidad,producto=oferta.producto,descuento=oferta.descuento)]

            return render_template("convertir_pedido_whatsapp_oferta.html", form2=form2,
                                   renglones=renglonespedido,cargarform=cargarform,
                                   base_template=appbuilder.base_template,
                                                   appbuilder=appbuilder)
        else:
            flash('No se puede ver el detalle porque no esta reservado','warning')
            return redirect(self.get_redirect())










from flask_appbuilder.charts.views import TimeChartView
#aca agrego los manejadores de las vistas al appbuilder para que sean visuales

class VentaTimeChartView(TimeChartView):
    search_columns = ['fecha','cliente']
    chart_title = 'Agrupado por ventas'
    label_columns = VentaReportes.label_columns
    group_by_columns = ['fecha']
    datamodel = SQLAInterface(Venta)

appbuilder.add_view(VentaTimeChartView, "Grafico de ventas", icon="fa-envelope", category="Estadistica")
appbuilder.add_view(VentaView, "Realizar Ventas", category='Ventas', category_icon='fa-tag' )
appbuilder.add_view( PrecioMdelview,"Producto" ,icon="fa-archive", category='Productos', category_icon='fa-archive' )

appbuilder.add_view(CompraView, "Compra", category='Compras', category_icon="fa-cart-plus" )
appbuilder.add_view(ClientesView, "Clientes")
appbuilder.add_view(ProveedorView, "Proveedor" ,category='Proveedor', category_icon='fa-tag')
appbuilder.add_view(PedidoView, "Pedidos de Presupesto", category='Proveedor')
appbuilder.add_view_no_menu(RenglonPedidoView)

appbuilder.add_view(CrudProducto,"Categoria Marca Unidad" ,category='Productos')
appbuilder.add_view_no_menu(ProductoModelview)
appbuilder.add_view_no_menu(MarcasModelview)
appbuilder.add_view_no_menu(unidadesModelView)
appbuilder.add_view_no_menu(CategoriaModelview)
appbuilder.add_view_no_menu(ReportesView)
appbuilder.add_view_no_menu(MetododepagoVentas)
appbuilder.add_view(VentaReportes, "Reporte Ventas",icon="fa-save", category='Ventas' )
appbuilder.add_view(OfertaWhatsappView,"Ofertas de Ventas Whtasapp", category='Ventas' )
appbuilder.add_view(PediddosClientesView,"Pedidos de Ventas Whtasapp", category='Ventas' )
appbuilder.add_view(CompraReportes, "Reporte Compras",icon="fa-save", category='Compras' )

appbuilder.add_view(Sistemaview,'Datos Empresa',category='Security')
appbuilder.add_view(ModulosInteligentesView,'Modulos Inteligentes',category='Security')

appbuilder.add_view_no_menu(Empresaview)
appbuilder.add_view_no_menu(CompaniaTarjetaview)
appbuilder.add_view_no_menu(RenglonVentas)
appbuilder.add_view_no_menu(RenglonComprasView)
appbuilder.add_view(RenglonComprasVencidos,'Vencidos',category='Productos')
appbuilder.add_view(ProductoxVencer,'Lotes',category='Productos')
appbuilder.add_view_no_menu(RenglonComprasxVencer)
from .whatsapp.whastsapp import smsreply
from .modulos_inteligentes.modelo_whatsapp import ModeloWhatsapp,ModeloWhatsappPedido
appbuilder.add_view_no_menu(smsreply)
appbuilder.add_view_no_menu(ModeloWhatsapp)
appbuilder.add_view_no_menu(ModeloWhatsappPedido)
appbuilder.add_view_no_menu(ConvertirVenta)





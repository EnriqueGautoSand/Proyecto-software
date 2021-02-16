

from flask_appbuilder.models.sqla.interface import SQLAInterface
from wtforms import Form, BooleanField, StringField, validators, DateField, FloatField, IntegerField, FieldList, \
    SelectField, SubmitField, PasswordField
from flask_appbuilder.fieldwidgets import BS3TextFieldWidget, Select2Widget
from flask_appbuilder import BaseView,expose
from flask import request,render_template,url_for,flash
from .reservas_ofertas import PedidoCliente, OfertaWhatsapp,Productos,RenglonCompras,EmpresaDatos,FormadePago,Clientes,CompaniaTarjeta,Categoria,Marcas
from .. import db, appbuilder
from flask_wtf import FlaskForm
from datetime import datetime as dt
from wtforms.validators import DataRequired,InputRequired
from flask_babelpkg import lazy_gettext
from sqlalchemy import desc,asc
#from ..views import RenglonVenta
import json
class RenglonVentapedido(Form):
    clienteidentificador=StringField('Cliente', render_kw={'disabled':''})
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
class Formulariooferta(FlaskForm):
    cliente = StringField('Cliente', render_kw={'readonly': "true"})
    producto = SelectField('Producto', render_kw={'readonly': "true"})
    descuento=FloatField('Descuento %', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], default=0)
    precio = FloatField('Precio $', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], default=0)
    cantidad_oferta=IntegerField('Cantidad disponible para la oferta', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], widget=BS3TextFieldWidget())
    cantidad = IntegerField('Cantidad', render_kw={'type': "number"},
                       validators=[DataRequired()], widget=BS3TextFieldWidget())
    total = FloatField('Total $', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], default=0,description=lazy_gettext("""Total Previo Impuestos"""))
    submit = SubmitField("Realizar Pedido", render_kw={"onclick": "confirmacion(event)"})
class ModeloWhatsappPedido(BaseView):
    default_view = 'activation'
    @expose("/pedidowhatsapp/<string:hash>",methods=["GET", "POST"])
    def activation(self, hash):
        if request.method == "GET":
            try:
                pedido = db.session.query(PedidoCliente).filter(PedidoCliente.hash_activacion == hash).first()
                if pedido.expiracion<=dt.now():
                    form2 = RenglonVentapedido(request.form)
                    responsableinscripto = False


                    cargarform = False
                    flash("Oferta Invalida, ya finalizo el tiempo de la oferta", "warning")
                    return render_template('pedidos_whatsapp.html', base_template=appbuilder.base_template,cargarform=cargarform,
                                           appbuilder=appbuilder,
                                           form2=form2, responsableinscripto=responsableinscripto)
                if pedido != None:
                    if not pedido.reservado:

                        form2 = RenglonVentapedido(request.form)
                        form2.descuento.render_kw = {'disabled': 'true'}
                        form2.percepcion.render_kw = {'disabled': 'true'}

                        # cargo las elecciones de producto
                        responsableinscripto = str(
                            db.session.query(EmpresaDatos).first().tipoClave) == "Responsable Inscripto"

                        form2.producto.choices = [(
                            '{"id": ' + f'{p.id}' + ', "iva":' + f'"{p.iva}"' + ', "representacion":' + f'"{p.__str__()}"' + '}',
                            p.__str__()) for p in
                            db.session.query(Productos).filter(Productos.estado == True,
                                                               Productos.stock > 0)
                                .join(Productos.categoria).join(Productos.marca).order_by(
                                asc(Categoria.categoria), asc(Marcas.marca)).all()]

                        # cargo las elecciones de cliente
                        cliente=db.session.query(Clientes).filter(Clientes.estado == True,
                                                                 Clientes.id == pedido.cliente.id).first()
                        form2.clienteidentificador.data = cliente.__repr__()
                        # cargo las elecciones de metodo de pago
                        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
                        # cargo las elecciones de las tarjetas

                        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta).filter(
                            CompaniaTarjeta.estado == True)]
                        # le digo que guarde la url actual en el historial
                        # esto sirve para cuando creas un cliente que te redirija despues a la venta

                        self.update_redirect()
                        # renderizo el html y le paso el formulario
                        cargarform=True
                        return render_template('pedidos_whatsapp.html', base_template=appbuilder.base_template,cargarform=cargarform,
                                               appbuilder=appbuilder,
                                               form2=form2, responsableinscripto=responsableinscripto)
                    else:
                        form2 = RenglonVentapedido(request.form)
                        responsableinscripto = False

                        form = Formulariooferta(request.form)
                        cargarform=False
                        flash("Oferta Invalida, por favor copie correctamente el enlace de oferta", "warning")
                        return render_template('pedidos_whatsapp.html', base_template=appbuilder.base_template,cargarform=cargarform,
                                               appbuilder=appbuilder,
                                               form2=form2, responsableinscripto=responsableinscripto)
            except Exception as e:
                print(e)
                print(str(e))
                form2 = RenglonVentapedido(request.form)
                cargarform = False
                flash("Pedido Invalido, por favor copie correctamente el enlace de oferta", "warning")
                return render_template('pedidos_whatsapp.html', base_template=appbuilder.base_template,cargarform=cargarform,
                                       appbuilder=appbuilder,
                                       form2=form2, responsableinscripto=responsableinscripto)

class ModeloWhatsapp(BaseView):
    default_view = 'activation'
    @expose("/reservawhatsapp/<string:hash>",methods=["GET", "POST"])
    def activation(self, hash):
            import sys, os
            if request.method=="GET":
                try:
                    oferta=db.session.query(OfertaWhatsapp).filter(OfertaWhatsapp.hash_activacion==hash).first()
                    if oferta.expiracion <= dt.now():
                        form = Formulariooferta(request.form)
                        mensaje = True
                        flash("Ofertaa Invalida, ya finalizo el tiempo de la oferta", "error")
                        return render_template('reservas_whatsapp.html', form=form, mensaje=mensaje,
                                               base_template=appbuilder.base_template, appbuilder=appbuilder)
                    if oferta.producto.stock <= 0:
                        form = Formulariooferta(request.form)
                        mensaje = True
                        flash("Pedido Invalido !!!  Ya se vendieron los productos  de esta oferta", "error")
                        return render_template('reservas_whatsapp.html', form=form, mensaje=mensaje,
                                               base_template=appbuilder.base_template, appbuilder=appbuilder)
                    if oferta!=None:
                        if not oferta.reservado:
                            mensaje=False
                            form = Formulariooferta(request.form)
                            form.cantidad.render_kw={'type': "number",'min':'1','max':f'{oferta.renglon_compra.stock_lote}'}
                            form.cantidad.data=0
                            form.cantidad_oferta.data=oferta.renglon_compra.stock_lote
                            form.descuento.data = oferta.descuento
                            form.producto.choices=[('{"id": ' + f'{p.id}' + ', "iva":' + f'"{p.iva}"' + ', "representacion":' + f'"{p.__str__()}"' + '}',  p.__str__()) for p  in db.session.query(Productos).filter(Productos.id==oferta.producto.id,Productos.estado == True,Productos.stock>0 )]
                            form.cliente.data=oferta.cliente.__repr__().upper()
                            flash("Reserve su pedido", "nuevopedido")
                            return render_template('reservas_whatsapp.html',form=form, base_template=appbuilder.base_template, mensaje=mensaje,appbuilder=appbuilder)
                        else:
                            form = Formulariooferta(request.form)
                            mensaje = True
                            flash("Oferta Invalida, esta oferta ya fue tomada", "error")
                            return render_template('reservas_whatsapp.html', form=form,mensaje=mensaje,
                                                   base_template=appbuilder.base_template, appbuilder=appbuilder)
                    else:
                        form = Formulariooferta(request.form)
                        mensaje = True
                        flash("Oferta Invalida, por favor copie correctamente el enlace de oferta", "error")
                        return render_template('reservas_whatsapp.html', form=form, mensaje=mensaje,
                                               base_template=appbuilder.base_template, appbuilder=appbuilder)
                except:
                    form = Formulariooferta(request.form)
                    mensaje = True
                    flash("Oferta Invalida, por favor copie correctamente el enlace de oferta", "error")
                    return render_template('reservas_whatsapp.html', form=form, mensaje=mensaje,
                                           base_template=appbuilder.base_template, appbuilder=appbuilder)
            if request.method == "POST":
                try:
                    oferta = db.session.query(OfertaWhatsapp).filter(OfertaWhatsapp.hash_activacion == hash).first()
                    print(request.json)
                    if oferta != None and oferta.producto.stock>0:
                        request.form['cantidad']
                        request.form['total']
                        productoid=json.loads(request.form['producto'])['id']
                        print(json.loads(request.form['producto'])['id'])
                        print(type(request.form['producto']),oferta.producto_id,request.form['producto']==oferta.producto_id,oferta.renglon_compra.stock_lote)
                        if int(productoid)==oferta.producto_id:
                            renglonCompras=db.session.query(RenglonCompras).filter(RenglonCompras.id == oferta.renglon_compra_id).first()
                            print(renglonCompras,oferta.reservado)
                            if renglonCompras.stock_lote >= int(request.form['cantidad']) and not oferta.reservado:
                                oferta.reservado=True
                                oferta.cantidad=int(request.form['cantidad'])
                                renglonCompras.stock_lote-=oferta.cantidad
                                renglonCompras.producto.stock-=oferta.cantidad
                                db.session.commit()
                                form = Formulariooferta(request.form)
                                mensaje = True
                                flash("Pedido Creado", "nuevopedido")
                                return  render_template('reservas_whatsapp.html', form=form, base_template=appbuilder.base_template,mensaje=mensaje,
                                                appbuilder=appbuilder)
                            else:
                                flash("Pedido No Creado, ya se vendio todo lo disponible en esta oferta", "error")
                                form = Formulariooferta(request.form)
                                mensaje = True
                                return render_template('reservas_whatsapp.html',mensaje=mensaje,form=form, base_template=appbuilder.base_template, appbuilder=appbuilder)
                        flash("Pedido no Creado debido a un error", "error")
                        form = Formulariooferta(request.form)
                        mensaje = True
                        return render_template('reservas_whatsapp.html', form=form, base_template=appbuilder.base_template,mensaje=mensaje,
                                               appbuilder=appbuilder)
                    else:
                        import sys, os
                        form = Formulariooferta(request.form)
                        mensaje = True
                        flash("Pedido Invalido !!!  Ya se vendieron los productos  de esta oferta", "error")
                        return render_template('reservas_whatsapp.html', form=form, mensaje=mensaje,
                                               base_template=appbuilder.base_template, appbuilder=appbuilder)
                except Exception as e:
                    import sys, os
                    form = Formulariooferta(request.form)
                    mensaje = True
                    flash("Pedido Invalido, por favor copie correctamente el enlace de oferta", "error")
                    print(e)
                    print(str(e))
                    exc_type, exc_obj, exc_tb = sys.exc_info()
                    fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                    print(exc_type, fname, exc_tb.tb_lineno)

                    return render_template('reservas_whatsapp.html', form=form, mensaje=mensaje,
                                           base_template=appbuilder.base_template, appbuilder=appbuilder)
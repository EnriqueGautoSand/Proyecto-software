

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
from ..views import RenglonVenta
class Formulariooferta(FlaskForm):
    producto = SelectField('Producto', render_kw={'readonly': "true"})
    cantidad_oferta=IntegerField('Cantidad disponible para la oferta', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], widget=BS3TextFieldWidget())
    cantidad = IntegerField('Cantidad', render_kw={'type': "number"},
                       validators=[DataRequired()], widget=BS3TextFieldWidget())
    descuento=FloatField('Descuento %', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], default=0)
    total = FloatField('Total $', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], default=0,description=lazy_gettext("""Total """))
    precio = FloatField('Precio $', render_kw={'readonly': 'true'},
                       validators=[DataRequired()], default=0)
    cliente= StringField('Cliente', render_kw={'readonly': "true"})
    submit = SubmitField("Realizar Pedido", render_kw={"onclick": "confirmacion(event)"})
class ModeloWhatsappPedido(BaseView):
    default_view = 'activation'
    @expose("/pedidowhatsapp/<string:hash>",methods=["GET", "POST"])
    def activation(self, hash):
        if request.method == "GET":
            try:
                pedido = db.session.query(PedidoCliente).filter(PedidoCliente.hash_activacion == hash).first()
                if pedido.expiracion>=dt.now():
                    form2 = RenglonVenta(request.form)
                    responsableinscripto = False

                    form = Formulariooferta(request.form)
                    mensaje = True
                    flash("Ofertaa Invalida, ya finalizo el tiempo de la oferta", "warning")
                    return render_template('pedidos_whatsapp.html', base_template=appbuilder.base_template,
                                           appbuilder=appbuilder,
                                           form2=form2, responsableinscripto=responsableinscripto)
                if pedido != None:
                    if not pedido.reservado:

                        form2 = RenglonVenta(request.form)
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
                        form2.cliente.choices = [
                            ('{"id": ' + f'{c.id}' + ', "tipoclave":' + f'"{c.tipoClave}"' + '}', c) for c
                            in db.session.query(Clientes).filter(Clientes.estado == True,
                                                                 Clientes.id == pedido.cliente.id).all()]
                        # cargo las elecciones de metodo de pago
                        form2.metodo.choices = [(c.id, c) for c in db.session.query(FormadePago)]
                        # cargo las elecciones de las tarjetas

                        form2.companiaTarjeta.choices = [(c.id, c) for c in db.session.query(CompaniaTarjeta).filter(
                            CompaniaTarjeta.estado == True)]
                        # le digo que guarde la url actual en el historial
                        # esto sirve para cuando creas un cliente que te redirija despues a la venta

                        self.update_redirect()
                        # renderizo el html y le paso el formulario
                        return render_template('pedidos_whatsapp.html', base_template=appbuilder.base_template,
                                               appbuilder=appbuilder,
                                               form2=form2, responsableinscripto=responsableinscripto)
                    else:
                        form2 = RenglonVenta(request.form)
                        responsableinscripto = False

                        form = Formulariooferta(request.form)
                        mensaje = True
                        flash("Ofertaa Invalida, por favor copie correctamente el enlace de oferta", "warning")
                        return render_template('pedidos_whatsapp.html', base_template=appbuilder.base_template,
                                               appbuilder=appbuilder,
                                               form2=form2, responsableinscripto=responsableinscripto)
            except Exception as e:
                flash("Pedido Invalido, por favor copie correctamente el enlace de oferta", "warning")
                print(e)
                print(str(e))
class ModeloWhatsapp(BaseView):
    default_view = 'activation'
    @expose("/reservawhatsapp/<string:hash>",methods=["GET", "POST"])
    def activation(self, hash):
            if request.method=="GET":
                try:
                    oferta=db.session.query(OfertaWhatsapp).filter(OfertaWhatsapp.hash_activacion==hash).first()
                    if oferta.expiracion >= dt.now():
                        form = Formulariooferta(request.form)
                        mensaje = True
                        flash("Ofertaa Invalida, ya finalizo el tiempo de la oferta", "error")
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
                    if oferta != None:
                        request.form['cantidad']
                        request.form['total']

                        print(type(request.form['producto']),oferta.producto_id,request.form['producto']==oferta.producto_id,oferta.renglon_compra.stock_lote)
                        if int(request.form['producto'])==oferta.producto_id:
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
                except Exception as e:
                    form = Formulariooferta(request.form)
                    mensaje = True
                    flash("Pedido Invalido, por favor copie correctamente el enlace de oferta", "error")
                    print(e)
                    print(str(e))

                    return render_template('reservas_whatsapp.html', form=form, mensaje=mensaje,
                                           base_template=appbuilder.base_template, appbuilder=appbuilder)
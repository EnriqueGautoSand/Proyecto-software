from flask_appbuilder.api import BaseApi, expose
from flask import request,session
from flask_appbuilder.urltools import Stack
from . import appbuilder
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder.api import ModelRestApi
from .models import *
from flask import g
from fab_addon_audit.views import AuditedModelView
from .modelo.ModelView import Modelovista
import psycopg2
from flask import jsonify
import copy
import json
AuditedModelView.__bases__=(Modelovista,)
def get_user():
    return g.user

from sqlalchemy.sql import func
class Auditar(AuditedModelView):
        datamodel = SQLAInterface(obj=Productos,session=db.session)
        def __init__(self,datamodel):
            self.datamodel=SQLAInterface(datamodel)



        
class Clienteapi(BaseApi,AuditedModelView):
    datamodel = SQLAInterface(Clientes)
    @expose('/condfisicacliente/', methods=['POST', 'GET'])
    def condfisicacliente(self):
        respuesta={c.__repr__(): c.id for c in db.session.query(TipoClaves).all()}
        res=json.dumps(respuesta )
        return self.response(200, message=res )
    @expose('/condjuridicacliente/', methods=['POST', 'GET'])
    def condfrenteiva(self):
        respuesta={c.__repr__(): c.id for c in db.session.query(TipoClaves).filter(TipoClaves.tipoClave != "Consumidor Final",TipoClaves.tipoClave != "Monotributista").all()}
        res=json.dumps(respuesta )
        return self.response(200, message=res )
    @expose('/dnicliente/', methods=['POST', 'GET'])
    def dnicliente(self):
        respuesta={c.__repr__(): c.id for c in db.session.query(TiposDocumentos).all()}
        res=json.dumps(respuesta )
        return self.response(200, message=res )
    @expose('/proveedorfisico/', methods=['POST', 'GET'])
    def proveedorfisico(self):
        respuesta={c.__repr__(): c.id for c in db.session.query(TipoClaves).filter(TipoClaves.tipoClave != "Consumidor Final").all()}
        res=json.dumps(respuesta )
        return self.response(200, message=res )

class ComprasApi(BaseApi,AuditedModelView):
    datamodel = SQLAInterface(Compra)
    @expose('/realizarcompra/', methods=['POST', 'GET'])
    def compra(self):
        """
        realizo la venta
        """

        if request.method == "POST":
            #paso los datos de la peticion a json
            data = request.json
            print(data)
            from .views import CompraReportes
            from .views import ProductoModelview
            self.list_columns = CompraReportes.list_columns
            self.show_columns = CompraReportes.show_columns
            try:
                if "metododePago" in data and "proveedor" in data and "total" in data:
                    print(data["total"])
                    # creo la compra y agrego forma de pago
                    # compracomprobacion = db.session.query(Compra).filter(Compra.comprobante == float(data["comprobante"])).first()
                    # if compracomprobacion != None:
                    #     return self.response(400, message="Error el Nro de comprobante es incorrecto o repetido")
                    if int(data["metododePago"]) == 1:
                        #comprobante = float(data["comprobante"])
                        compra=Compra(fecha=dt.now(),percepcion=float(data["percepcion"]),totaliva=float(data["totaliva"]),totalNeto=float(data["totalneto"]),estado=True,total=float(data["total"]),proveedor_id=data["proveedor"],formadepago_id=data["metododePago"])
                    else:
                        #en caso de que se hay apagado con tarjeta asocio los datos de la tarjeta a la compra
                        datosFormaPagos=DatosFormaPagosCompra(numeroCupon=data["numeroCupon"],
                                              companiaTarjeta_id=data["companiaTarjeta"],
                                              credito=data["credito"],
                                              cuotas=data["cuotas"],formadepago_id=data["metododePago"]
                                              )

                        compra = Compra(estado=True,totalNeto=float(data["totalneto"]),totaliva=float(data["totaliva"]),
                                      total=float(data["total"]), proveedor_id=data["proveedor"],formadepago_id=data["metododePago"],
                                      datosFormaPagos=datosFormaPagos,percepcion=float(data["percepcion"]),fecha=dt.now())

                    #agrego la compra
                    db.session.add(compra)
                    db.session.flush()



                    #verifico si tiene productos
                    if "productos" in data:
                        #por cada producto me genera un renglon en la compra
                        for p in data["productos"]:
                            #solicita el producto a ala base de datos
                            print(p,type(p))
                            producto = db.session.query(Productos).get(p["producto"])
                            print(producto,'\n', producto.stock, p["cantidad"])

                            #crea el renglon en la compra sino cancela transaccion y manda error

                            db.session.add(RenglonCompras(precioCompra=p["precio"] , descuento=p["descuento"], cantidad=p["cantidad"],compra=compra,  producto=producto,stock_lote=p["cantidad"]))
                            porcentaje_subida=db.session.query(ModulosConfiguracion).first().porcentaje_subida_precio
                            productoanterior=copy.copy(producto)
                            producto.precio=format(float(p["precio"])+((float(p["precio"])/100) * float(porcentaje_subida)), '.2f')

                            # auditacion=Auditar(Productos)
                            # auditacion.list_columns=ProductoModelview.list_columns
                            # auditacion.show_columns=ProductoModelview.show_columns
                            # self.appbuilder.add_view_no_menu(auditacion)
                            # auditacion.pre_pre_update(productoanterior)
                            # auditacion.post_update(producto)

                        #Guardamos

                        db.session.commit()
                        self.post_add(compra)
                        page_history = Stack(session.get("page_history", []))
                        page_history.push("http://localhost.localdomain:8080"+url_for("CompraView.compra"))
                        session["page_history"] = page_history.to_json()

                        print("compra Guardada")
                    else:
                        db.session.rollback()
                        return self.response(400, message="error no hay productos")
                else:
                    db.session.rollback()
                    return self.response(400, message="error")


                return self.response(200, message={'status':"sucess" ,'idcompra':compra.id  })
            except Exception as e:
                print(e)
                print(str(e))
                print(repr(e))
                db.session.rollback()
                return self.response(400, message="error")
        return self.response(400, message="error")

class VentasApi(BaseApi,AuditedModelView):
    datamodel = SQLAInterface(Venta)
    @expose('/venta_whatsapp/', methods=["GET", "POST"])
    def venta_whatsapp(self):
        """
        obtengo el precio de un producto
        """
        if request.method == "POST":
            data = request.json
            print(data)

    @expose('/obtenerusuario/', methods=["GET", "POST"])
    def apiusuario(self):
        """
        obtengo el precio de un producto
        """
        if request.method == "GET":
            # paso los datos de la peticion a json
            usuario=get_user()
            print(usuario.__dict__)
            #retorno el precio del producto
            return self.response(200, message={'last_name':usuario.last_name.capitalize(),'first_name':usuario.first_name.capitalize(),'cond frente iva':str(db.session.query(EmpresaDatos).first().tipoClave)})
        return self.response(400, message="error")
    @expose('/obtenerprecio/', methods=["GET", "POST"])
    def obtenerprecio(self):
        """
        obtengo el precio de un producto
        """
        if request.method == "POST":
            #verifico si soy responsable inscripto
            tipoclave=str(db.session.query(EmpresaDatos).first().tipoClave)
            responsableinscripto = tipoclave == "Responsable Inscripto"
            monotributista= tipoclave == "Monotributista"
            # paso los datos de la peticion a json
            data = request.json
            #Solicito a ala base de datos el producto
            p=db.session.query(Productos).get(data['p'])
            #si soy responsable y el que me compra no es responsable le agrego el iva en el precio
            if data["venta"] and data['cliente_condfrenteiva']!="Responsable Inscripto" and responsableinscripto:
                return self.response(200, message=format(p.precio*(1+(p.iva/100)), '.2f') )
            if data["venta"] and monotributista:
                return self.response(200, message=format(p.precio * (1 + (p.iva / 100)), '.2f'))
            # retorno el precio del producto
            return self.response(200, message=format(p.precio, '.2f'))
        return self.response(400, message="error")
    @expose('/obtenerprecio_oferta/', methods=["GET", "POST"])
    def obtenerprecio_oferta(self):
        """
        obtengo el precio de un producto
        """
        if request.method == "POST":
            # verifico si soy responsable inscripto
            tipoclave = str(db.session.query(EmpresaDatos).first().tipoClave)

            responsableinscripto = tipoclave == "Responsable Inscripto"
            monotributista = tipoclave == "Monotributista"
            # paso los datos de la peticion a json
            data = request.json
            # Solicito a ala base de datos el producto
            #cliente= db.session.query(Clientes).filter(Clientes.id==int(data['cliente'])).first()
            cliente = db.session.query(Clientes).join(OfertaWhatsapp).filter(
                Clientes.id==OfertaWhatsapp.cliente_id,OfertaWhatsapp.hash_activacion==data['hashoferta']).first()
            p  =db.session.query(Productos).join(OfertaWhatsapp.producto).join(Clientes,Clientes.id==OfertaWhatsapp.cliente_id).\
                                            filter(Clientes.id==cliente.id).\
                                            filter(Productos.id==int(json.loads(data['p'])['id'])).first()
            if p!=None:
                oferta = db.session.query(OfertaWhatsapp).join(Productos).join(Clientes).filter(Clientes.id == cliente.id,
                                                                                           Productos.id == OfertaWhatsapp.producto_id,
                                                                                           OfertaWhatsapp.cliente_id == cliente.id,
                                                                                                Productos.id==int(json.loads(data['p'])['id'])).first()
                # si soy responsable y el que me compra no es responsable le agrego el iva en el precio
                respuesta={'precio':format(p.precio * (1 + (p.iva / 100)), '.2f'),'descuento':oferta.descuento }
                if data["venta"] and cliente.tipoClave != "Responsable Inscripto" and responsableinscripto:
                    return self.response(200, message=json.dumps(respuesta))
                if data["venta"] and monotributista:
                    return self.response(200, message=json.dumps(respuesta))
            else:

                p = db.session.query(Productos).get(int(json.loads(data['p'])['id']))
                respuesta = {'precio': format(p.precio * (1 + (p.iva / 100)), '.2f'), 'descuento': 0}
                # si soy responsable y el que me compra no es responsable le agrego el iva en el precio
                if data["venta"] and cliente.tipoClave != "Responsable Inscripto" and responsableinscripto:
                    return self.response(200, message=json.dumps(respuesta))
                if data["venta"] and monotributista:
                    return self.response(200, message=json.dumps(respuesta))
            # retorno el precio del producto
            return self.response(200, message=format(p.precio, '.2f'))
        return self.response(400, message="error")
    @expose('/realizarventa/', methods=['POST', 'GET'])
    def greeting2(self):
        """
        realizo la venta
        """
        from .views import VentaReportes
        self.list_columns=VentaReportes.list_columns
        self.show_columns =VentaReportes.show_columns
        if request.method == "POST":
            #paso los datos de la peticion a json
            data = request.json
            print(data)
            try:
                if  "cliente" in data and "total" in data:
                    print(data["total"])
                    # creo la venta
                    # ventacomp=db.session.query(Venta).filter(Venta.comprobante==float(data["comprobante"])).first()
                    # print(ventacomp)
                    # if ventacomp!= None:
                    #     return self.response(400, message="Error el Nro de comprobante es incorrecto o repetido")
                    #comprobante=float(data["comprobante"]),
                    venta=Venta(estado=True,percepcion=float(data["percepcion"]),totaliva=float(data["totaliva"]),totalNeto=float(data["totalneto"]), total=float(data["total"])
                               ,cliente_id=int(data["cliente"]),fecha=dt.now())
                    db.session.add(venta)
                    db.session.flush()
                    #creo los metodos de pagos
                    for i in data["metodos"]:
                        formadePagoxVenta=FormadePagoxVenta(monto=i["monto"],venta=venta,formadepago_id=  int(i["metododePago"]))
                        db.session.add(formadePagoxVenta)
                        db.session.flush()
                        print(db.session.query( FormadePago).get( int(i["metododePago"])),type(db.session.query( FormadePago).get( int(i["metododePago"])).Metodo))
                        if db.session.query( FormadePago).get( int(i["metododePago"])).Metodo == "Tarjeta":
                            datosFormaPagos=DatosFormaPagos(numeroCupon=i["numeroCupon"],
                                                  companiaTarjeta_id=i["companiaTarjeta"],
                                                  credito=i["credito"],
                                                  cuotas=i["cuotas"],formadepago=formadePagoxVenta
                                                  )
                            db.session.add(datosFormaPagos)



                    #verifico si hay productos

                    if "productos" in data:
                        #por cada producto me genera un renglon en la venta
                        for p in data["productos"]:
                           #solicita el producto a ala base de datos
                           producto = db.session.query(Productos).get(p["producto"])
                           #print(producto.stock, p["cantidad"])
                           #print(producto)
                           #aca verifica si el stock es mayor a la cantidad a comprar
                           #crea el renglon en la venta sino cancela transaccion y manda error
                           if producto.stock>=p["cantidad"]:
                               renglones=db.session.query(RenglonCompras).join(Compra).filter(Compra.id==RenglonCompras.compra_id,RenglonCompras.vendido==False,producto.id==RenglonCompras.producto_id).order_by(Compra.fecha).all()
                               print(renglones,'renglones')
                               loteado=p["cantidad"]
                               for i in renglones:
                                   print('es III ',i,'stock lote',i.stock_lote,'stock to',loteado)
                                   if i.stock_lote>loteado:
                                       i.stock_lote=i.stock_lote-loteado
                                       break
                                   else:
                                       loteado =loteado-i.stock_lote
                                       i.stock_lote=0
                                       i.vendido=True


                               db.session.add(Renglon(precioVenta=producto.precio , cantidad=p["cantidad"],venta=venta,producto=producto,descuento=p["descuento"]))
                           else:
                               db.session.rollback()
                               return self.response(400, message=f"error {producto} stock insuficiente posee {producto.stock} y trata de vender {p['cantidad']}")
                        #Guardamos
                        db.session.commit()
                        print("venta Guardada")
                        self.post_add(venta)
                    else:
                        db.session.rollback()
                        return self.response(400, message="error")
                else:
                    db.session.rollback()
                    return self.response(400, message="error")


                return self.response(200, message={'status':"sucess" ,'idventa':venta.id  })
            except psycopg2.Error as e:
                # get error code
                error = e.pgcode
                if error==23505:
                    return self.response(400, message="Error el comprobante es repetido")

            except Exception as e:
                print(e)
                print(str(e))
                print(repr(e))
                db.session.rollback()
                return self.response(400, message="error")
        return self.response(400, message="error")

    @expose('/realizarpedido_whatsapp/', methods=['POST', 'GET'])
    def realizarpedido_whatsapp(self):
        """
        realizo la venta
        """
        from .views import VentaReportes
        self.list_columns=VentaReportes.list_columns
        self.show_columns =VentaReportes.show_columns
        if request.method == "POST":
            #paso los datos de la peticion a json
            data = request.json
            print(data)
            try:
                if  "cliente" in data and "total" in data:
                    print(data["total"])
                    # creo la venta

                    comprobante_alto=db.session.query(func.max(Venta.comprobante)).first()
                    print(comprobante_alto, 'comprobante altos')
                    if comprobante_alto==None:

                        venta=Venta(comprobante=float(9999999),estado=False,percepcion=float(data["percepcion"]),totaliva=float(data["totaliva"]),totalNeto=float(data["totalneto"]), total=float(data["total"])
                                ,cliente_id=int(data["cliente"]),fecha=dt.now())
                    else:
                        venta = Venta(comprobante=float(comprobante_alto[0]+1), estado=False, percepcion=float(data["percepcion"]),
                                      totaliva=float(data["totaliva"]), totalNeto=float(data["totalneto"]),
                                      total=float(data["total"])
                                      , cliente_id=int(data["cliente"]), fecha=dt.now())
                    db.session.add(venta)
                    db.session.flush()
                    #creo los metodos de pagos
                    for i in data["metodos"]:
                        formadePagoxVenta=FormadePagoxVenta(monto=i["monto"],venta=venta,formadepago_id=  int(i["metododePago"]))
                        db.session.add(formadePagoxVenta)
                        db.session.flush()
                        print(db.session.query( FormadePago).get( int(i["metododePago"])),type(db.session.query( FormadePago).get( int(i["metododePago"])).Metodo))
                        dato_formadepago_alto = db.session.query(func.max(DatosFormaPagos.numeroCupon)).first()
                        if db.session.query(FormadePago).get(int(i["metododePago"])).Metodo == "Tarjeta":
                            if dato_formadepago_alto == None:
                                    datosFormaPagos=DatosFormaPagos(numeroCupon=99999999,
                                                          companiaTarjeta_id=i["companiaTarjeta"],
                                                          credito=i["credito"],
                                                          cuotas=i["cuotas"],formadepago=formadePagoxVenta
                                                          )
                                    db.session.add(datosFormaPagos)
                            else:
                                    datosFormaPagos=DatosFormaPagos(numeroCupon=dato_formadepago_alto[0]+1,
                                                          companiaTarjeta_id=i["companiaTarjeta"],
                                                          credito=i["credito"],
                                                          cuotas=i["cuotas"],formadepago=formadePagoxVenta
                                                          )
                                    db.session.add(datosFormaPagos)



                    #verifico si hay productos

                    if "productos" in data:
                        #por cada producto me genera un renglon en la venta
                        for p in data["productos"]:
                           #solicita el producto a ala base de datos
                           producto = db.session.query(Productos).get(p["producto"])
                           #print(producto.stock, p["cantidad"])
                           #print(producto)
                           #aca verifica si el stock es mayor a la cantidad a comprar
                           #crea el renglon en la venta sino cancela transaccion y manda error
                           if producto.stock>=p["cantidad"]:
                               renglones=db.session.query(RenglonCompras).join(Compra).filter(Compra.id==RenglonCompras.compra_id,RenglonCompras.vendido==False,producto.id==RenglonCompras.producto_id).order_by(Compra.fecha).all()
                               print(renglones,'renglones')
                               loteado=p["cantidad"]
                               for i in renglones:
                                   print('es III ',i,'stock lote',i.stock_lote,'stock to',loteado)
                                   if i.stock_lote>loteado:
                                       i.stock_lote=i.stock_lote-loteado
                                       break
                                   else:
                                       loteado =loteado-i.stock_lote
                                       i.stock_lote=0
                                       i.vendido=True


                               db.session.add(Renglon(precioVenta=producto.precio , cantidad=p["cantidad"],venta=venta,producto=producto,descuento=p["descuento"]))
                           else:
                               db.session.rollback()
                               return self.response(400, message=f"error {producto} stock insuficiente posee {producto.stock} y trata de vender {p['cantidad']}")
                        #Guardamos

                        pedido = db.session.query(PedidoCliente).filter(PedidoCliente.hash_activacion == data["activation_hash"]).first()
                        pedido.venta_id=venta.id
                        pedido.reservado=True
                        db.session.commit()
                        print("Pedido Guardada")
                        self.post_add(venta)
                    else:
                        db.session.rollback()
                        return self.response(400, message="error")
                else:
                    db.session.rollback()
                    return self.response(400, message="error")


                return self.response(200, message={'status':"sucess" ,'idventa':venta.id  })
            except psycopg2.Error as e:
                # get error code
                error = e.pgcode
                if error==23505:
                    return self.response(400, message="Error el comprobante es repetido")

            except Exception as e:
                print(e)
                print(str(e))
                print(repr(e))
                db.session.rollback()
                return self.response(400, message="error")
        return self.response(400, message="error")
    @expose('/convertir_pedido_venta', methods=['POST'])
    def convertir_pedido_venta(self):
        try:
            data = request.json
            print(data)
            pedido = db.session.query(PedidoCliente).get(int(data['pk']))
            pedido.venta.estado=True
            pedido.venta.comprobante=int(data['comprobante'])
            tarjeta=False
            for i in pedido.venta.formadepagos:
                if i.formadepago.Metodo=='Tarjeta':
                    tarjeta=True
            if tarjeta:
                for i in data['formasdepago']:
                    formadepago=db.session.query(DatosFormaPagos).get(int(i['idformapago']))
                    formadepago.numeroCupon=int(i['numerocupon'])
            pedido.vendido=True
            db.session.commit()
        except Exception as e:
            print(e)
            print(str(e))
            print(repr(e))
            db.session.rollback()
            return self.response(400, message={'ok':'Error'})




        return self.response(200, message={'ok':'ok','id':pedido.venta.id})

appbuilder.add_api(Clienteapi)

appbuilder.add_api(VentasApi)
appbuilder.add_api(ComprasApi)
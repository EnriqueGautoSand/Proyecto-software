from flask_appbuilder.api import BaseApi, expose
from flask import request
from . import appbuilder
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder.api import ModelRestApi
from .models import *
from flask import g
from fab_addon_audit.views import AuditedModelView
def get_user():
    return g.user
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
            try:
                if "metododePago" in data and "proveedor" in data and "total" in data:
                    print(data["total"])
                    # creo la compra y agrego forma de pago
                    if int(data["metododePago"]) == 1:
                        compra=Compra(percepcion=float(data["percepcion"]),totaliva=float(data["totaliva"]),totalNeto=float(data["totalneto"]),Estado=True,total=float(data["total"]),proveedor_id=data["proveedor"],formadepago_id=data["metododePago"])
                    else:
                        #en caso de que se hay apagado con tarjeta asocio los datos de la tarjeta a la compra
                        datosFormaPagos=DatosFormaPagosCompra(numeroCupon=data["numeroCupon"],
                                              companiaTarjeta_id=data["companiaTarjeta"],
                                              credito=data["credito"],
                                              cuotas=data["cuotas"],formadepago_id=data["metododePago"]
                                              )

                        compra = Compra(Estado=True,totalNeto=float(data["totalneto"]),totaliva=float(data["totaliva"]),
                                      total=float(data["total"]), proveedor_id=data["proveedor"],formadepago_id=data["metododePago"],
                                      datosFormaPagos=datosFormaPagos,percepcion=float(data["percepcion"]))

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

                            db.session.add(RenglonCompras(precioCompra=p["precio"] , descuento=p["descuento"], cantidad=p["cantidad"],compra=compra,  producto=producto))

                        #Guardamos
                        db.session.commit()
                        self.post_add(compra)
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
            responsableinscripto = str(db.session.query(EmpresaDatos).first().tipoClave) == "Responsable Inscripto"
            # paso los datos de la peticion a json
            data = request.json
            #Solicito a ala base de datos el producto
            p=db.session.query(Productos).get(data['p'])
            #si soy responsable y el que me compra no es responsable le agrego el iva en el precio
            if data["venta"] and data['cliente_condfrenteiva']!="Responsable Inscripto" and responsableinscripto:
                return self.response(200, message=p.precio*(1+(p.iva/100)) )
            # retorno el precio del producto
            return self.response(200, message=p.precio)
        return self.response(400, message="error")
    @expose('/realizarventa/', methods=['POST', 'GET'])
    def greeting2(self):
        """
        realizo la venta
        """

        if request.method == "POST":
            #paso los datos de la peticion a json
            data = request.json
            print(data)
            try:
                if  "cliente" in data and "total" in data:
                    print(data["total"])
                    # creo la venta

                    venta=Venta(Estado=True,percepcion=float(data["percepcion"]),totaliva=float(data["totaliva"]),totalNeto=float(data["totalneto"]), total=float(data["total"])
                                ,cliente_id=int(data["cliente"]))
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
                           print(producto.stock, p["cantidad"])
                           print(producto)
                           #aca verifica si el stock es mayor a la cantidad a comprar
                           #crea el renglon en la venta sino cancela transaccion y manda error
                           if producto.stock>p["cantidad"]:
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
            except Exception as e:
                print(e)
                print(str(e))
                print(repr(e))
                db.session.rollback()
                return self.response(400, message="error")
        return self.response(400, message="error")

class ProductoApi(ModelRestApi):
    resource_name = 'produ'
    datamodel = SQLAInterface(Productos)

appbuilder.add_api(ProductoApi)


appbuilder.add_api(VentasApi)
appbuilder.add_api(ComprasApi)
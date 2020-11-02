from flask_appbuilder.api import BaseApi, expose
from flask import request
from . import appbuilder
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder.api import ModelRestApi
from .models import *
from flask import g
def get_user():
    return g.user
class ComprasApi(BaseApi):
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
                    # creo la venta
                    if int(data["metododePago"]) == 1:
                        compra=Compra(percepcion=float(data["percepcion"]),totalNeto=float(data["totalneto"]),Estado=True,total=float(data["total"]),proveedor_id=data["proveedor"],formadepago_id=data["metododePago"])
                    else:
                        datosFormaPagos=DatosFormaPagosCompra(numeroCupon=data["numeroCupon"],
                                              companiaTarjeta_id=data["companiaTarjeta"],
                                              credito=data["credito"],
                                              cuotas=data["cuotas"],formadepago_id=data["metododePago"]
                                              )

                        compra = Compra(Estado=True,totalNeto=float(data["totalneto"]),
                                      total=float(data["total"]), proveedor_id=data["proveedor"],formadepago_id=data["metododePago"],
                                      datosFormaPagos=datosFormaPagos,percepcion=float(data["percepcion"]))

                    #agrego la venta
                    db.session.add(compra)
                    db.session.flush()
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
                        print("compra Guardada")
                    else:
                        db.session.rollback()
                        return self.response(400, message="error")
                else:
                    db.session.rollback()
                    return self.response(400, message="error")


                return self.response(200, message={'status':"sucess" ,'idventa':compra.id  })
            except Exception as e:
                print(e)
                print(str(e))
                print(repr(e))
                db.session.rollback()
                return self.response(400, message="error")
        return self.response(400, message="error")

class VentasApi(BaseApi):
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
            return self.response(200, message={'last_name':usuario.last_name,'first_name':usuario.first_name})
        return self.response(400, message="error")
    @expose('/obtenerprecio/', methods=["GET", "POST"])
    def method2(self):
        """
        obtengo el precio de un producto
        """
        if request.method == "POST":
            # paso los datos de la peticion a json
            data = request.json
            print(data)
            print(db.session.query(Productos).get(data['p']))
            #Solicito a ala base de datos el producto
            p=db.session.query(Productos).get(data['p'])
            #retorno el precio del producto
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

                    venta=Venta(Estado=True,percepcion=float(data["percepcion"]),totalNeto=float(data["totalneto"]), total=float(data["total"]),cliente_id=int(data["cliente"]))
                    db.session.add(venta)
                    db.session.flush()
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



                    #agrego la venta

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


                                #producto.stock=producto.stock-p[1]
                                #db.session.add(producto)
                           else:
                               db.session.rollback()
                               return self.response(400, message=f"error {producto} stock insuficiente posee {producto.stock} y trata de vender {p['cantidad']}")
                        #Guardamos
                        db.session.commit()
                        print("venta Guardada")
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
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
                    compra=Compra(Estado=True, total=float(data["total"]),proveedor_id=int(data["proveedor"]),formadepago_id=int(data["metododePago"]))
                    #agrego la venta
                    db.session.add(compra)
                    db.session.flush()
                    if "productos" in data:
                        #por cada producto me genera un renglon en la compra
                        for p in data["productos"]:
                            #solicita el producto a ala base de datos
                            producto = db.session.query(Productos).get(p[0])
                            print(producto.stock, p[1])

                            #crea el renglon en la venta sino cancela transaccion y manda error

                            db.session.add(RenglonCompras(precioCompra=producto.precio , cantidad=p[1],compra=compra,  producto=producto))
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
                if "metododePago" in data and "cliente" in data and "total" in data:
                    print(data["total"])
                    # creo la venta
                    venta=Venta(Estado=True, total=float(data["total"]),cliente_id=int(data["cliente"]),formadepago_id=int(data["metododePago"]))
                    #agrego la venta
                    db.session.add(venta)
                    db.session.flush()
                    if "productos" in data:
                        #por cada producto me genera un renglon en la venta
                        for p in data["productos"]:
                           #solicita el producto a ala base de datos
                           producto = db.session.query(Productos).get(p[0])
                           print(producto.stock, p[1])
                           #aca verifica si el stock es mayor a la cantidad a comprar
                           #crea el renglon en la venta sino cancela transaccion y manda error
                           if producto.stock>p[1]:
                                db.session.add(Renglon(precioVenta=producto.precio , cantidad=p[1],venta=venta,  producto=producto))
                                #producto.stock=producto.stock-p[1]
                                #db.session.add(producto)
                           else:
                               db.session.rollback()
                               return self.response(400, message=f"error {producto} stock insuficiente posee {producto.stock} y trata de vender {p[1]}")
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
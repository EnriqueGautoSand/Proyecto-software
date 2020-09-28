from flask_appbuilder.api import BaseApi, expose
from flask import request
from . import appbuilder
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder.api import ModelRestApi
from .models import *

class VentasApi(BaseApi):

    @expose('/obtenerprecio/', methods=["GET", "POST"])
    def method2(self):
        """
        obtengo el precio de un producto
        """
        if request.method == "POST":
            data = request.json
            print(data)
            print(db.session.query(Productos).get(data['p']))
            p=db.session.query(Productos).get(data['p'])
            return self.response(200, message=p.precio)
        return self.response(400, message="error")
    @expose('/realizarventa/', methods=['POST', 'GET'])
    def greeting2(self):
        """
        realizo la venta
        """
        
        if request.method == "POST":
            data = request.json
            print(data)
            try:
                if "metododePago" in data and "cliente" in data and "total" in data:
                    print(data["total"])
                    venta=Venta(Estado=True, total=float(data["total"]),cliente_id=int(data["cliente"]),formadepago_id=int(data["metododePago"]))
                    db.session.add(venta)
                    db.session.flush()
                    if "productos" in data:
                        for p in data["productos"]:
                           producto = db.session.query(Productos).get(p[0])
                           print(producto.stock, p[1])
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

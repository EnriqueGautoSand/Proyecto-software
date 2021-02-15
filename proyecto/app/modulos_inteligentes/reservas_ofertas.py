from twilio.rest import Client
from apscheduler.schedulers.background import BackgroundScheduler
from ..models import *
from datetime import datetime as dt

from app import app

from pytz import utc
import os
import hashlib
from datetime import datetime as dt
import random
import string
from flask_appbuilder import expose
from datetime import timedelta
def get_random_string(length):
    letters = string.ascii_lowercase
    result_str = ''.join(random.choice(letters) for i in range(length))
    return result_str
def mandar_oferta():
    ofertaconfig = db.session.query(ModulosConfiguracion).first()

    # Your Account SID from twilio.com/console
    account_sid =ofertaconfig.twilio_account_sid #ejemplo: "ACf1f795288eef0800ecd20d4b8baf966f"
    # Your Auth Token from twilio.com/console
    auth_token  =ofertaconfig.twilio_auth_token #ejemplo: "bc1eae95cabc327d5175311b4d1594fb"
    #lista de gustos cliente,producto
    if ofertaconfig.modulo_ofertas_whatsapp:
        gustos_cliente_producto = db.session.execute("""
                        select sum(renglon.cantidad),clientes.id as cliente_id,productos.id as producto_id from renglon,clientes,ventas,productos
                                        where ventas.id=renglon.venta_id
                                        and ventas.estado=true
                                        and productos.estado=true
                                        
                                        and productos.id=renglon.producto_id
                                        and ventas.cliente_id=clientes.id
                                        group by clientes.id,productos.id order by sum(renglon.cantidad) desc ;
                             """).fetchall()
        fecha=dt.now()
        #lista de productos a vencer
        productos_a_vencer= db.session.execute("""
                        select renglon_compras.id,productos.id from renglon_compras,productos 
                        where renglon_compras.producto_id=productos.id 
                        and productos.stock>0
                        and renglon_compras.stock_lote>0
                        and (renglon_compras.fecha_vencimiento - :var_fecha) <=:dias
                        and renglon_compras.fecha_vencimiento >= :var_fecha group by renglon_compras.id,productos.id;
                               """, {'var_fecha': fecha.strftime("%Y-%m-%d"),'dias':ofertaconfig.fecha_vencimiento_oferta}).fetchall()
        print(gustos_cliente_producto,productos_a_vencer)
        for i in productos_a_vencer:

            for j in gustos_cliente_producto:
                if j[2]==i[1]:
                    try:
                        cliente=db.session.query(Clientes).filter(Clientes.id == j[1]).first()
                        if cliente.telefono_celular==None:
                            print(cliente,' No se envio oferta porque no tiene telefono celular')
                            continue

                        producto = db.session.query(Productos).filter(Productos.id == i[1]).first()
                        rengloncompra=db.session.query(RenglonCompras).filter(RenglonCompras.id == i[0]).first()


                        password = cliente.__repr__()+dt.now().strftime(" %d-%m-%Y %H:%M ")
                        hash=get_random_string(8)
                        h = hashlib.md5(password.encode())
                        oferta=OfertaWhatsapp(
                                    fecha=dt.now(),
                                    expiracion=dt.now()+timedelta(hours=1),
                                    producto_id=producto.id,
                                    cliente_id=cliente.id,
                                    descuento=ofertaconfig.descuento,
                                    hash_activacion=hash,#h.hexdigest()
                                    renglon_compra_id=i[0]

                                        )



                        m1=f"Hola {cliente.__repr__()} tenemos ofertas para usted de {producto.__str__()} "
                        var="localhost:8080/modelowhatsapp/reservawhatsapp/"+hash
                        m2=f"es una oferta especial del {ofertaconfig.descuento}% de descuento solo nos quedan {rengloncompra.stock_lote} disponibles, valla al siguiente enlace"

                        print(var)
                        db.session.add(oferta)
                        db.session.commit()
                        client = Client(account_sid, auth_token)
                        message = client.messages.create(
                            body=m1 + m2+f" {var} y haga su reserva !!!",
                            from_="whatsapp:+14155238886",
                            to="whatsapp:+549"+cliente.telefono_celular
                            )

                    except Exception as e:
                        print(e)
                        print(str(e))
                        print(repr(e))
                        db.session.rollback()

def start_scheduler_ofertas():
    ofertaconfig = db.session.query(ModulosConfiguracion).first()
    scheduler = BackgroundScheduler(timezone=utc)

    # define your job trigger
    #hourse_keeping_trigger = CronTrigger(minute='*/1',second='2')


    # add your job
    scheduler.add_job(mandar_oferta,'interval', days=ofertaconfig.dias_oferta)

    # start the scheduler
    scheduler.start()



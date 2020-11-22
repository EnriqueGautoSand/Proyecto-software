
from apscheduler.triggers.cron import CronTrigger
from apscheduler.schedulers.background import BackgroundScheduler
from app import db
from ..models import *
from apscheduler.triggers.combining import AndTrigger
from apscheduler.triggers.interval import IntervalTrigger
from datetime import datetime as dt
from datetime import timedelta
from flask_mail import Mail, Message
from app import app
from flask import render_template
class Pedido():
    def __init__(self,producto,cantidad):
        self.cantidad=cantidad
        self.producto=producto
    def __repr__(self):
        return f'producto {self.producto} cantiadad {self.cantidad}   '
def send_email(proveedordict):
    """
        Method for sending the registration Email to the user
    """

    sender=app.config['MAIL_USERNAME']


    mail = Mail(app)
    for key in proveedordict:
        proveedor=db.session.query(Proveedor).filter(Proveedor.id==key).first()
        print(proveedor,'se le envio pedido de presupuesto')
        msg = Message("Pedido de Presupuesto "+proveedor.__repr__(),
                  sender=sender,
                  recipients=[proveedor.correo])
        #msg.subject = "Pedido de Presupuesto"

        with app.app_context():
            print(proveedordict[key])
            for i in proveedordict[key]:
                print(i.__repr__())
            msg.html = render_template('pedidopresupuesto.html',pedido=proveedordict[key])
            #agregar bucle for para enviar correo a muchos proveedores
            #msg.recipients = ["bowanip213@ffeast.com"]
            mail.send(msg)

def pedido_inteligente():
    productos=db.session.query(Productos).all()
    print(productos)
    fecha=dt.now()-timedelta(days=dt.now().day-1)
    print(fecha.strftime("%Y-%m-%d"))
    pedido=[]
    cantidades=[]
    proveedores=[]
    proveedordict={}
    print( app.config['MAIL_USERNAME'])
    for producto in productos:
        compras=db.session.execute("""
                             select sum(renglon_compras.cantidad) from renglon_compras,compras 
                                where renglon_compras.compra_id=compras.id 
                                and renglon_compras.producto_id= :var_productoid
                                and compras.fecha >= :var_fecha
                             """, {'var_fecha': fecha.strftime("%Y-%m-%d"),'var_productoid':producto.id}).fetchall()

        rankingproveedor=db.session.execute("""
                             select sum(renglon_compras.cantidad),compras.proveedor_id from renglon_compras,compras 
                                where renglon_compras.compra_id=compras.id 
                                and renglon_compras.producto_id= :var_productoid
                                and compras.fecha >= :var_fecha GROUP BY compras.proveedor_id
                             """, {'var_fecha': fecha.strftime("%Y-%m-%d"),'var_productoid':producto.id}).fetchall()

        ventas=db.session.execute("""
                                select sum(renglon.cantidad) from renglon,ventas 
                                where renglon.venta_id=ventas.id 
                                and renglon.producto_id= :var_productoid
                                and ventas.fecha >=  :var_fecha
                             """, {'var_fecha': fecha.strftime("%Y-%m-%d"),'var_productoid':producto.id}).fetchall()
        print('total compras:',compras[0][0] ,' total ventas:',ventas[0][0],' ventas% ',ventas[0][0]/(compras[0][0]/100))
        print(producto,compras,' stcok: ',producto.stock,' ',(producto.stock)/(compras[0][0]/100),'% ',(producto.stock)/(ventas[0][0]/100) ,'%venta compra stock')
        if ventas[0][0]/(compras[0][0]/100)>80:
            #if not(producto.stock >(ventas[0][0])/2):
            print('carga',ventas[0][0]/(compras[0][0]/100)>80,ventas[0][0]/(compras[0][0]/100))

            #pedido.append(Pedido(producto.__str__(),str(ventas[0][0]),rankingproveedor))
            unpedido=Pedido(producto.__str__(), str(ventas[0][0]))
            for i in rankingproveedor:
                if i[1] in proveedordict:
                    proveedordict[i[1]].append(unpedido)
                else:
                    proveedordict[i[1]] = [Pedido(producto.__str__(), str(ventas[0][0]))]



    if proveedordict!={}:
         send_email(proveedordict)
    else:
        print('todos los productos tienen stock')


def start_scheduler():

    scheduler = BackgroundScheduler()

    # define your job trigger
    #hourse_keeping_trigger = CronTrigger(minute='*/1',second='2')


    # add your job
    scheduler.add_job(pedido_inteligente,'interval', seconds=10)

    # start the scheduler
    scheduler.start()
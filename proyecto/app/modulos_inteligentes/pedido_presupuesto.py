
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
        if proveedor.estado==True:
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

def pedido_productos_sin_stock():
    pedidoconfig=db.session.query(ModulosInteligentes).first()
    productos=db.session.query(Productos).filter(Productos.estado==True).all()
    print(productos)
    fecha=dt.now()-timedelta(pedidoconfig.dias_atras)#timedelta(days=dt.now().day-1)
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
        if ventas[0][0]/(compras[0][0]/100)>pedidoconfig.porcentaje_ventas:
            #if not(producto.stock >(ventas[0][0])/2):
            print('carga',ventas[0][0]/(compras[0][0]/100)>pedidoconfig.porcentaje_ventas,ventas[0][0]/(compras[0][0]/100))

            #pedido.append(Pedido(producto.__str__(),str(ventas[0][0]),rankingproveedor))
            unpedido=Pedido(producto.__str__(), str(ventas[0][0]))
            for i in rankingproveedor:
                if i[1] in proveedordict:
                    proveedordict[i[1]].append(unpedido)
                else:
                    proveedordict[i[1]] = [Pedido(producto.__str__(), str(ventas[0][0]))]



    if proveedordict!={}:
        print('enviando pedido de productos sin stock')
        send_email(proveedordict)
    else:
        print('todos los productos tienen stock')

def pedido_productos_vencidos():
    pedidoconfig = db.session.query(ModulosInteligentes).first()
    fecha = dt.now() - timedelta(pedidoconfig.dias_atras)
    proveedordict = {}
    productos_a_vencer= db.session.execute("""
                    select sum(renglon_compras.cantidad),productos.id from renglon_compras,productos 
                    where renglon_compras.producto_id=productos.id 
                    and ('2015-01-02'::date - '2015-01-01'::date) <=:dias
                    and renglon_compras.fecha_vencimiento >= :var_fecha group by productos.id;
                         """, {'var_fecha': fecha.strftime("%Y-%m-%d"),'dias':pedidoconfig.fecha_vencimiento}).fetchall()
    print(productos_a_vencer)
    for producto in productos_a_vencer:
        rankingproveedor = db.session.execute("""
                             select sum(renglon_compras.cantidad),compras.proveedor_id from renglon_compras,compras 
                                where renglon_compras.compra_id=compras.id 
                                and renglon_compras.producto_id= :var_productoid
                                and compras.fecha >= :var_fecha GROUP BY compras.proveedor_id
                             """, {'var_fecha': fecha.strftime("%Y-%m-%d"), 'var_productoid': producto[1]}).fetchall()
        poductoObjeto=db.session.query(Productos).filter(Productos.id==producto[1]).first()
        unpedido=Pedido(poductoObjeto.__str__(), str(producto[0]))
        for i in rankingproveedor:
            if i[1] in proveedordict:
                proveedordict[i[1]].append(unpedido)
            else:
                proveedordict[i[1]] = [Pedido(poductoObjeto.__str__(), str(producto[0]))]
    print('proveedordict',proveedordict)
    if proveedordict!={}:
        print('enviando pedido de productos a vencer')
        send_email(proveedordict)
    else:
        print('No hay ningun producto por vencerse')
    pedido_productos_sin_stock()

def start_scheduler():
    pedidoconfig = db.session.query(ModulosInteligentes).first()
    scheduler = BackgroundScheduler()

    # define your job trigger
    #hourse_keeping_trigger = CronTrigger(minute='*/1',second='2')


    # add your job
    scheduler.add_job(pedido_productos_vencidos,'interval', days=pedidoconfig.dias_pedido)

    # start the scheduler
    scheduler.start()
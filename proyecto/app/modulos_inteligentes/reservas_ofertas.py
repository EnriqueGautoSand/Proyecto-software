from twilio.rest import Client
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime as dt
from ..models import *
def mandar_oferta():
    ofertaconfig = db.session.query(ModulosInteligentes).first()
    productos = db.session.query(Productos).filter(Productos.estado == True).all()
    # Your Account SID from twilio.com/console
    account_sid = "ACf1f795288eef0800ecd20d4b8baf966f"
    # Your Auth Token from twilio.com/console
    auth_token  = "bc1eae95cabc327d5175311b4d1594fb"
    #lista de gustos cliente,productos
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
                    select sum(renglon_compras.cantidad),productos.id from renglon_compras,productos 
                    where renglon_compras.producto_id=productos.id 
                    and ('2015-01-02'::date - '2015-01-01'::date) <=:dias
                    and renglon_compras.fecha_vencimiento >= :var_fecha group by productos.id;
                         """, {'var_fecha': fecha.strftime("%Y-%m-%d"),'dias':ofertaconfig.fecha_vencimiento_oferta}).fetchall()

    client = Client(account_sid, auth_token)


    message = client.messages.create(
        to="whatsapp:+5493764247399",
        from_="whatsapp:+14155238886",
        body="Hello from Python!")

def start_scheduler_ofertas():
    ofertaconfig = db.session.query(ModulosInteligentes).first()
    scheduler = BackgroundScheduler()

    # define your job trigger
    #hourse_keeping_trigger = CronTrigger(minute='*/1',second='2')


    # add your job
    scheduler.add_job(mandar_oferta,'interval', seconds=ofertaconfig.dias_oferta)

    # start the scheduler
    scheduler.start()
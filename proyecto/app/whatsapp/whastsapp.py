
from flask import Flask, request
from twilio.twiml.messaging_response import MessagingResponse
from flask_appbuilder import ModelView,BaseView,expose
from datetime import datetime as dt
from datetime import timedelta
from fab_addon_audit.views import AuditedModelView
import random
import string
from ..models import  *
from .. import app
def get_random_string(length):
    letters = string.ascii_lowercase
    result_str = ''.join(random.choice(letters) for i in range(length))
    return result_str
class smsreply(BaseView):
    default_view = 'sms'
    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/sms/', methods=["GET", "POST"])
    def sms(self):
        print('entro')
        """Respond to incoming calls with a simple text message."""
        # Fetch the message
        try:
            configpedido = db.session.query(ModulosConfiguracion).first()
            sender_phone_number = request.form.get('From')
            msg = request.form.get('Body')
            print(request.form.get('Head'))
            print(request.form.get('Body'),sender_phone_number.split("whatsapp:+549"))
            cliente=db.session.query(Clientes).filter(Clientes.telefono_celular==sender_phone_number.split("whatsapp:+549")[1]).first()
            if cliente==None:
                resp = MessagingResponse()
                resp.message('Su numero no se encuentra registrado como cliente, por favor vaya al negocio y registrese')
            else:
                hash = get_random_string(15)
                pedido=PedidoCliente(cliente=cliente,fecha=dt.now(),expiracion=(dt.now()+timedelta(hours=configpedido.tiempo_expiracion)),hash_activacion=hash)
                db.session.add(pedido)
                # Create reply
                resp = MessagingResponse()

                if msg.upper()!='PEDIDO':
                    resp.message("Hola {} Si desea realizar un pedido mande la palabra pedido".format(cliente))

                else:
                    url='localhost:8080/modelowhatsapppedido/pedidowhatsapp/'+hash
                    resp.message("Vaya al siguiente enlace para realizar un pedido {}".format(url))
                    db.session.commit()
        except Exception as e:
            print(e)
            print(str(e))
            print(repr(e))
            db.session.rollback()
            resp=MessagingResponse()
            resp.message('error interno')


        return str(resp)

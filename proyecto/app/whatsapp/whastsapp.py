
from flask import Flask, request
from twilio.twiml.messaging_response import MessagingResponse
from flask_appbuilder import ModelView,BaseView,expose

from fab_addon_audit.views import AuditedModelView

class smsreply(BaseView):
    default_view = 'sms'
    #creo el metodo que maneja la url VentaView/venta/ donde se realiza la venta
    @expose('/sms/', methods=["GET", "POST"])
    def sms(self):
        print('entro')
        """Respond to incoming calls with a simple text message."""
        # Fetch the message
        msg = request.form.get('Body')
        print(request.form.get('Head'))

        # Create reply
        resp = MessagingResponse()
        resp.message("Tu dijiste: {}".format(msg))

        return str(resp)

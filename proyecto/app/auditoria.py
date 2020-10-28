from fab_addon_audit.views import AuditedModelView
from flask_appbuilder.models.sqla.interface import SQLAInterface
from .models import *
from . import appbuilder
class compraauditoriaView(AuditedModelView):
    datamodel = SQLAInterface(Compra)
class ventaauditoriaView(AuditedModelView):
    datamodel = SQLAInterface(Venta)
class clientesauditoriaView(AuditedModelView):
    datamodel = SQLAInterface(Clientes)




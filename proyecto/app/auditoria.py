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

appbuilder.add_view_no_menu(compraauditoriaView)
appbuilder.add_view_no_menu(ventaauditoriaView)
appbuilder.add_view_no_menu(clientesauditoriaView)




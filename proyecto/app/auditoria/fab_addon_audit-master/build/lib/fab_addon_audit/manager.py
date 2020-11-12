import logging
from flask_appbuilder.basemanager import BaseManager
from .views import AuditLogView, AuditLogChartView
from flask_babelpkg import lazy_gettext as _
from .models import Operacion

log = logging.getLogger(__name__)


class AuditAddOnManager(BaseManager):

    operations = ['INSERT','UPDATE','DELETE']

    def __init__(self, appbuilder):
        """
             Use the constructor to setup any config keys specific for your app. 
        """
        super(AuditAddOnManager, self).__init__(appbuilder)

    def register_views(self):
        """
            This method is called by AppBuilder when initializing, use it to add you views
        """
        self.appbuilder.add_separator("Security")
        self.appbuilder.add_view(AuditLogView, "Auditoria",icon = "fa-user-secret",category = "Security")
        self.appbuilder.add_view(AuditLogChartView, "Graficos de Auditoria",icon = "fa-area-chart",category = "Security")

    def pre_process(self):
        for operation in self.operations:
            if not self.appbuilder.get_session.query(Operacion).filter(Operacion.name == operation).first():
                _operation = Operacion(name = operation)
                self.appbuilder.get_session.add(_operation)
                self.appbuilder.get_session.commit()

    def post_process(self):
        pass


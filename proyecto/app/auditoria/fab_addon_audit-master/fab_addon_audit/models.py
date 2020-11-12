import datetime
from flask_appbuilder import Model
from flask_appbuilder.models.mixins import AuditMixin, FileColumn, ImageColumn
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Sequence
from sqlalchemy.orm import relationship
from sqlalchemy import event


class Operacion(Model):
    __tablename__ = 'operacion'
    id = Column(Integer, Sequence('audit_log_id_seq'), primary_key=True)
    name = Column(String(50), nullable=False)

    def __repr__(self):
        return self.name

class Auditoria(Model):
    id = Column(Integer, Sequence('audit_log_id_seq'), primary_key=True)
    message = Column(String(300), nullable=False)
    username = Column(String(64),  nullable=False)
    created_on = Column(DateTime, default=datetime.datetime.now, nullable=True)
    operation_id = Column(Integer, ForeignKey('operacion.id'), nullable=False)
    operation = relationship("Operacion")
    target = Column(String(150), nullable=False)



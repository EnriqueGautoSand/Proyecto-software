from flask_appbuilder.security.sqla.models import User
from sqlalchemy import Column, Integer, ForeignKey, String, Sequence, Table
from flask_appbuilder.models.decorators import renders

class Ususarios(User):
    __tablename__ = "ab_user"
    cuil = Column(String(50), unique=True, nullable=True)

    @renders('cancelado')
    def activeformat(self):
        if self.active:
            return "SI"
        else:
            "NO"
    @renders('cuil')
    def cuilformat(self):
        if self.cuil !=None:
            return  self.cuil
        else:
            return "-"

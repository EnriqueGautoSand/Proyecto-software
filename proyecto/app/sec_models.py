from flask_appbuilder.security.sqla.models import User
from sqlalchemy import Column, Integer, ForeignKey, String, Sequence, Table


class Ususarios(User):
    __tablename__ = "ab_user"
    cuil = Column(String(50), unique=True, nullable=True)


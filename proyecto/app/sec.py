from flask_appbuilder.security.sqla.manager import SecurityManager
from .sec_models import Ususarios
from .sec_view import MyUserDBModelView, MyRegisterUserDBView

class MySecurityManager(SecurityManager):
    user_model = Ususarios
    userdbmodelview = MyUserDBModelView
    registeruserdbview = MyRegisterUserDBView
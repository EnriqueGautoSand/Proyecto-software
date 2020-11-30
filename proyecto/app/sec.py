from flask_appbuilder.security.sqla.manager import SecurityManager


from .sec_models import Ususarios
from .sec_view import MyUserDBModelView, MyRegisterUserDBView
from flask_appbuilder.security.views import  AuthDBView
class Myauthdbview(AuthDBView):
    login_template = 'login.html'


class MySecurityManager(SecurityManager):

    user_model = Ususarios
    userdbmodelview = MyUserDBModelView
    registeruserdbview = MyRegisterUserDBView
    authdbview = Myauthdbview



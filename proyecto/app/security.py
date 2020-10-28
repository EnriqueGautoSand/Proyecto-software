from flask import redirect
from flask_appbuilder.actions import action
from flask_appbuilder.security.sqla.manager import SecurityManager
from flask_appbuilder.security.views import UserDBModelView
from flask_appbuilder.views import ModelView
from flask_appbuilder.fieldwidgets import  Select2Widget
from wtforms.validators import InputRequired
from validadores import  cuitvalidatorProveedores
from wtforms.ext.sqlalchemy.fields import QuerySelectMultipleField

def cuil_query():
    from .models import *
    from . import appbuilder, db
    from .sec_models import Ususarios
    from flask import g
    print(g.user.__dict__.keys(), g.user.roles)
    from flask_appbuilder.security.sqla.models import Role
    for i in g.user.roles:
        if i.name=="Admin":
            return db.session.query(Role).all()
        else:
            return db.session.query(Role).filter(Role.name  != "Admin" ).all()

class MyUserDBView(UserDBModelView):
    @action("muldelete", "Delete", "Delete all Really?", "fa-rocket", single=False)
    def muldelete(self, items):
        self.datamodel.delete_all(items)
        self.update_redirect()
        return redirect(self.get_redirect())
    validators_columns ={
        'cuil':[InputRequired(),cuitvalidatorProveedores]
    }

    add_form_extra_fields = {
        'roles':  QuerySelectMultipleField(
                            'rol',
                            query_factory=cuil_query,
                            widget=Select2Widget()
                       )
    }

    edit_form_extra_fields = {
        'roles':  QuerySelectMultipleField(
                            'rol',
                            query_factory=cuil_query,
                            widget=Select2Widget()
                       )
    }


class MySecurityManager(SecurityManager):
    userdbmodelview = MyUserDBView





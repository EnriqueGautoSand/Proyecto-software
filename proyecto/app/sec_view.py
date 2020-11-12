from flask_appbuilder.security.views import UserDBModelView
from flask_babelpkg import lazy_gettext
from wtforms.validators import InputRequired
from wtforms import validators,PasswordField
from validadores import  cuitvalidatorProveedores
from wtforms.ext.sqlalchemy.fields import QuerySelectMultipleField
from wtforms import StringField
from flask_appbuilder.fieldwidgets import  Select2ManyWidget,BS3PasswordFieldWidget,BS3TextFieldWidget
from wtforms.validators import EqualTo
from flask_appbuilder.security.registerviews import RegisterUserDBView, RegisterUserDBForm

class MyRegisterUserDBView(RegisterUserDBView):
    email_template = 'email_template.html'


def cuil_query():

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
class MyUserDBModelView(UserDBModelView):
    """
        View that add DB specifics to User view.
        Override to implement your own custom view.
        Then override userdbmodelview property on SecurityManager
    """

    show_fieldsets = [
        (lazy_gettext('User info'),
         {'fields': ['username', 'active', 'roles', 'login_count', 'cuil']}),
        (lazy_gettext('Personal Info'),
         {'fields': ['first_name', 'last_name', 'email'], 'expanded': True}),
        (lazy_gettext('Audit Info'),
         {'fields': ['last_login', 'fail_login_count', 'created_on',
                     'created_by', 'changed_on', 'changed_by'], 'expanded': False}),
    ]

    user_show_fieldsets = [
        (lazy_gettext('Informacion de Usuario'),
         {'fields': ['username', 'active', 'roles', 'login_count', 'cuil']}),
        (lazy_gettext('Informacion Personal'),
         {'fields': ['first_name', 'last_name', 'email'], 'expanded': True}),
    ]

    add_columns = [
        'username',
        'first_name',
        'last_name',
        'email',
        'cuil',
        'password',
        'conf_password'
    ]
    list_columns = [
        'first_name',
        'last_name',
        'username',
        'email',
        'cuil',
        'active',
        'roles'
    ]
    edit_columns = [
        'first_name',
        'last_name',
        'username',
        'cuil',
        'active',
        'roles'
    ]

    validators_columns ={
        'cuil':[InputRequired(),cuitvalidatorProveedores]
    }
    add_form_extra_fields = {

        'roles':  QuerySelectMultipleField(
                            'Rol',
                            query_factory=cuil_query,
                            widget=Select2ManyWidget()
                       ),
        "password": PasswordField(
            lazy_gettext("Password"),
            description=lazy_gettext(
                "Utilice una buena política de contraseñas, esta aplicación no verifica esto por usted"
            ),
            validators=[validators.DataRequired()],
            widget=BS3PasswordFieldWidget(),
        ),
        "conf_password": PasswordField(
            lazy_gettext("Confirmar Password"),
            description=lazy_gettext("Vuelva a escribir la contraseña del usuario para confirmar"),
            validators=[
                EqualTo("password", message=lazy_gettext("Passwords deben coincidir"))
            ],
            widget=BS3PasswordFieldWidget(),
        ),
    }

    edit_form_extra_fields = {
        'roles':  QuerySelectMultipleField(
                            'Rol',
                            query_factory=cuil_query,
                            widget=Select2ManyWidget()
                       ),

        'first_name': StringField(
            'Nombre',
            validators=[validators.DataRequired()]
        ),
        'last_name': StringField(
            'Apellidos',
            validators=[validators.DataRequired()]
        ),
        'username': StringField(
            'Nombre de usuario',
            validators=[validators.DataRequired()]
        ),
        'cuil': StringField(
            'Cuil',
            validators=[InputRequired(),cuitvalidatorProveedores]
        )

    }

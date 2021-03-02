import os
from flask_appbuilder.security.manager import (
    AUTH_OID,
    AUTH_REMOTE_USER,
    AUTH_DB,
    AUTH_LDAP,
    AUTH_OAUTH,
)

basedir = os.path.abspath(os.path.dirname(__file__))
#addon de auditoria
ADDON_MANAGERS = ['fab_addon_audit.manager.AuditAddOnManager']
#SERVER_NAME ='localhost.localdomain:8080'
# Your App secret key
SECRET_KEY = "jhgcjkfjlfckjyfkjvhlkukufux"

# The SQLAlchemy connection string.
#SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(basedir, "app.db")
# SQLALCHEMY_DATABASE_URI = 'mysql://myapp@localhost/myapp'
SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:410556@localhost/almacen'
AUTH_TYPE = 1
# Flask-WTF flag for CSRF
CSRF_ENABLED = False
# Config for Flask-WTF Recaptcha necessary for user registration
RECAPTCHA_PUBLIC_KEY = "6LdIhuEZAAAAAEN6gl-4QnijJCtWPkDwufuZmfJj"#'6Lfxwt8ZAAAAABEskZgHAkqLYkLWaNL0J_1nmUKH'
RECAPTCHA_PRIVATE_KEY = '6LdIhuEZAAAAAC8Pir3KC5TaoVBuvrKgoFuCAYDv'#'6Lfxwt8ZAAAAAKuuwPU3G7TfqjJBPYVE6BLR814V'

MAIL_SERVER = 'smtp.gmail.com'
MAIL_USE_TLS = True
#MAIL_USE_SSL=True
MAIL_USERNAME = 'soporte.kiogestion@gmail.com'
MAIL_PASSWORD = '123456Asdf'
MAIL_DEFAULT_SENDER = 'soporte.kiogestion@kiogestion.com'
MAIL_PORT=587
# ------------------------------
# GLOBALS FOR APP Builder
# ------------------------------
# Uncomment to setup Your App name
APP_NAME = "Kiogestion"

# Uncomment to setup Setup an App icon
# APP_ICON = "static/img/logo.jpg"

# ----------------------------------------------------
# AUTHENTICATION CONFIG
# ----------------------------------------------------
# The authentication type
# AUTH_OID : Is for OpenID
# AUTH_DB : Is for database (username/password()
# AUTH_LDAP : Is for LDAP
# AUTH_REMOTE_USER : Is for using REMOTE_USER from web server
FAB_UPDATE_PERMS = True
AUTH_TYPE = AUTH_DB

# Uncomment to setup Full admin role name
AUTH_ROLE_ADMIN = 'Admin'

# Uncomment to setup Public role name, no authentication needed
AUTH_ROLE_PUBLIC = 'Public'
FAB_ROLES = {
    "Gerente": [
        ["CompraReportes",'can_show'],["CompraReportes",'can_list'],
        ["CompraReportes", 'can_edit'],["CompraReportes", 'can_download_pdf'],
        ["compraclass","can_access"],
        ["productocrud", "can_access"],["comprarepo","can_access"],
        ["Productos", "menu_access"],
    ["Reporte Compras", "menu_access"],
    ["Compra", "menu_access"],
        ["Security","menu_access"],
       # ["UserInfoEditView","can_access" ],["MyUserDBModelView",'can_edit'],
#["UserInfoEditView","can_list" ],["ResetMyPasswordView","can_this_form_post"],["ResetMyPasswordView","can_this_form_get"],


["List Users","menu_access"],
["Proveedor","menu_access"],
    ["ProveedorView","can_access"],
["ProveedorView",'can_list'],
["ProveedorView",'can_add'],
["ProveedorView",'can_delete'],
["ProveedorView",'can_show'],
["ProveedorView",'can_edit'],
["Datos Empresa","menu_access"],["tarjeta","can_access"],
        ["Empresaview",'can_show'],["Empresaview",'can_list'],
        ["Empresaview", 'can_edit'],
["crudempresa","can_access"],
["RegisterUserModelView",'can_show'],["RegisterUserModelView",'can_list'],
["RegisterUserModelView",'can_delete'],
        ["RegisterUserModelView","can_access" ],
["Clientes","menu_access"],
["ClientesView",'can_list'],
["ClientesView",'can_add'],
["ClientesView",'can_delete'],
["ClientesView",'can_show'],
["Auditoria","menu_access"],
["AuditLogView",'can_show'],
["AuditLogView",'can_list'],
["ReportesView" ,"can_show_static_pdf"],
["PrecioMdelviewip",'can_access'],
["Producto" ,'menu_access'],
["ProductoxVencer",'can_show'],
["ProductoxVencer",'can_list'],
['Lotes',"menu_access"],
["RenglonComprasVencidos",'can_delete'],
["RenglonComprasVencidos",'can_list'],
['Vencidos',"menu_access"],

["RenglonComprasxVencer",'can_edit'],
["RenglonComprasxVencer",'can_list'],
["Control de Precios","menu_access"],

["MyUserDBModelView","can_userinfo"],
["MyUserDBModelView","can_userinfoedit "],
["MyUserDBModelView","can_this_form_post "],
["MyUserDBModelView","can_this_form_post "],
["MyUserDBModelView",'can_add'],
 ["MyUserDBModelView",'can_list'],
["MyUserDBModelView",'can_show'],
["MyUserDBModelView",'can_edit'],
#habilitar boton de rest pasword
["MyUserDBModelView",'resetpasswords'],
["MyUserDBModelView",'resetmypassword'],
["MyUserDBModelView",'userinfoedit'],
["ResetMyPasswordView","can_this_form_post"],
["ResetMyPasswordView","can_this_form_get"],
["UserInfoEditView","can_this_form_get"],
["UserInfoEditView","can_this_form_post"],
["UserInfoEditView","can_edit" ],
#ventas
["Reporte Ventas",'menu_access'],
["VentaView",'can_access'],
["VentaReportes",'can_list'],
["VentaReportes",'can_delete'],
["VentaReportes",'can_show'],
["VentaReportes",'can_edit'],
["Ventas","menu_access"],
["ReportesView",'can_show_static_pdf'],
    #Modulos inteligentes
['Modulos Inteligentes',"menu_access"],
 ["ModulosInteligentesView",'can_list'],
["ModulosInteligentesView",'can_show'],
["ModulosInteligentesView",'can_edit'],
['Modulos Configuracion',"menu_access"]

    ],
"Vendedor": [
["MyUserDBModelView","can_userinfo"],
["MyUserDBModelView","can_userinfoedit "],
["MyUserDBModelView","can_this_form_post "],
["MyUserDBModelView","can_this_form_post "],
["MyUserDBModelView",'can_add'],
 ["MyUserDBModelView",'can_list'],
["MyUserDBModelView",'can_show'],
["MyUserDBModelView",'can_edit'],
["MyUserDBModelView",'resetpasswords'],
["MyUserDBModelView",'resetmypassword'],
["MyUserDBModelView",'userinfoedit'],
#permisos para ir a los clientes
["Clientes","menu_access"],
["ClientesView",'can_list'],
["ClientesView",'can_add'],
["ClientesView",'can_show'],
#permisos para vender
["Realizar Ventas","menu_access"],
["Reporte Ventas","menu_access"],
["VentaView",'can_access'],
["ventaclass",'can_access'],
["Ventas","menu_access"],
["VentaReportes",'can_list'],
["VentaReportes",'can_show'],

["OfertaWhatsappView",'can_list'],
["OfertaWhatsappView",'can_delete'],
["OfertaWhatsappView",'can_show'],
["Pedidos de Ventas Whtasapp","menu_access"],

["PediddosClientesView",'can_show'],
["PediddosClientesView",'can_delete'],
["Ofertas de Ventas Whtasapp","menu_access"],
["PediddosClientesView",'can_list']
]



}

# Will allow user self registration
AUTH_USER_REGISTRATION = True

# The default user self registration role
AUTH_USER_REGISTRATION_ROLE = "Public"

# When using LDAP Auth, setup the ldap server
# AUTH_LDAP_SERVER = "ldap://ldapserver.new"

# Uncomment to setup OpenID providers example for OpenID authentication
#OPENID_PROVIDERS = [
#    { 'name': 'Yahoo', 'url': 'https://me.yahoo.com' },
#    { 'name': 'AOL', 'url': 'http://openid.aol.com/<username>' },
#    { 'name': 'Flickr', 'url': 'http://www.flickr.com/<username>' },
#    { 'name': 'MyOpenID', 'url': 'https://www.myopenid.com' }]
# ---------------------------------------------------
# Babel config for translations
# ---------------------------------------------------
# Setup default language
BABEL_DEFAULT_LOCALE = "es"
# Your application default translation path
BABEL_DEFAULT_FOLDER = "translations"
# The allowed translation for you app
LANGUAGES = {
    "en": {"flag": "gb", "name": "English"},
    "pt": {"flag": "pt", "name": "Portuguese"},
    "pt_BR": {"flag": "br", "name": "Pt Brazil"},
    "es": {"flag": "es", "name": "Spanish"},
    "de": {"flag": "de", "name": "German"},
    "zh": {"flag": "cn", "name": "Chinese"},
    "ru": {"flag": "ru", "name": "Russian"},
    "pl": {"flag": "pl", "name": "Polish"},
}
# ---------------------------------------------------
# Image and file configuration
# ---------------------------------------------------
# The file upload folder, when using models with files
UPLOAD_FOLDER = basedir + "/app/static/uploads/"

# The image upload folder, when using models with images
IMG_UPLOAD_FOLDER = basedir + "/app/static/uploads/"

# The image upload url, when using models with images
IMG_UPLOAD_URL = "/static/uploads/"
# Setup image size default is (300, 200, True)
# IMG_SIZE = (300, 200, True)

# Theme configuration
# these are located on static/appbuilder/css/themes
# you can create your own and easily use them placing them on the same dir structure to override
APP_THEME = "bootstrap-theme.css"  # default bootstrap
# APP_THEME = "cerulean.css"# azul y blanco pero el blanco de listProduct no se lee
#APP_THEME = "amelia.css"#amarillo y celio
#APP_THEME = "cosmo.css"#parecido a yeti
#APP_THEME = "cyborg.css"#Super negro
# APP_THEME = "flatly.css"#verde y blanco
# APP_THEME = "journal.css"#Naranja y blanco
# APP_THEME = "readable.css"
# APP_THEME = "simplex.css"
#APP_THEME = "slate.css"#dark theme
#APP_THEME = "spacelab.css"
#APP_THEME = "united.css"
#APP_THEME = "yeti.css"#Basatante Empresario

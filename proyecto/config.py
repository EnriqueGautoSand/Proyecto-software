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

# Your App secret key
SECRET_KEY = "\2\1thisismyscretkey\1\2\e\y\y\h"

# The SQLAlchemy connection string.
#SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(basedir, "app.db")
# SQLALCHEMY_DATABASE_URI = 'mysql://myapp@localhost/myapp'
SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:410556@localhost/almacen'

# Flask-WTF flag for CSRF
CSRF_ENABLED = False

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
        ["CompraReportes", 'can_edit'],
        ["compraclass","can_access"],
        ["productocrud", "can_access"],["comprarepo","can_access"],
        ["Productos", "menu_access"],
    ["Reporte Compras", "menu_access"],
    ["Compra", "menu_access"],
        ["Security","menu_access"],
        ["UserInfoEditView","can_access" ],
["UserInfoEditView","can_list" ],["ResetMyPasswordView","can_this_form_post"],["ResetMyPasswordView","can_this_form_get"],

["MyUserDBModelView",'can_add']
        ,["MyUserDBModelView",'can_list']
        ,["MyUserDBModelView",'can_show'],
["List Users","menu_access"],
["Proveedor","menu_access"],
["Datos Empresa","menu_access"],["tarjeta","can_access"],
        ["Empresaview",'can_show'],["Empresaview",'can_list'],
        ["Empresaview", 'can_edit'],
["crudempresa","can_access"]




    ]

}

# Will allow user self registration
# AUTH_USER_REGISTRATION = True

# The default user self registration role
# AUTH_USER_REGISTRATION_ROLE = "Public"

# When using LDAP Auth, setup the ldap server
# AUTH_LDAP_SERVER = "ldap://ldapserver.new"

# Uncomment to setup OpenID providers example for OpenID authentication
# OPENID_PROVIDERS = [
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
#APP_THEME = "bootstrap-theme.css"  # default bootstrap
# APP_THEME = "cerulean.css"# azul y blanco pero el blanco de listProduct no se lee
#APP_THEME = "amelia.css"#amarillo y celio
#APP_THEME = "cosmo.css"#parecido a yeti
#APP_THEME = "cyborg.css"#Super negro
# APP_THEME = "flatly.css"#verde y blanco
# APP_THEME = "journal.css"#Naranja y blanco
# APP_THEME = "readable.css"
# APP_THEME = "simplex.css"
APP_THEME = "slate.css"#dark theme
#APP_THEME = "spacelab.css"
#APP_THEME = "united.css"
#APP_THEME = "yeti.css"#Basatante Empresario

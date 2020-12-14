import logging

from flask import Flask
from flask_appbuilder import AppBuilder, SQLA

"""
 Logging configuration
"""
from .sec import MySecurityManager
from flask_appbuilder.menu import Menu
from flask_jsglue import JSGlue
from .index import MyIndexView
from flask_bootstrap import Bootstrap
from flask_ngrok import run_with_ngrok
logging.basicConfig(format="%(asctime)s:%(levelname)s:%(name)s:%(message)s")
logging.getLogger().setLevel(logging.DEBUG)

app = Flask(__name__)
jsglue = JSGlue(app)
bootstrap = Bootstrap(app)

app.config.from_object("config")
db = SQLA(app)
appbuilder = AppBuilder(app, db.session,menu=Menu(reverse=False), security_manager_class=MySecurityManager,
                        indexview=MyIndexView
                        )


"""
from sqlalchemy.engine import Engine
from sqlalchemy import event

#Only include this for SQLLite constraints
@event.listens_for(Engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    # Will force sqllite contraint foreign keys
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()
"""
from .models import *
from . import testdata
from . import views
from .modulos_inteligentes.pedido_presupuesto import start_scheduler
from .modulos_inteligentes.reservas_ofertas import start_scheduler_ofertas
start_scheduler()
start_scheduler_ofertas()
import logging

from flask import Flask
from flask_appbuilder import AppBuilder, SQLA

"""
 Logging configuration
"""
from .security import MySecurityManager
from flask_appbuilder.menu import Menu
logging.basicConfig(format="%(asctime)s:%(levelname)s:%(name)s:%(message)s")
logging.getLogger().setLevel(logging.DEBUG)

app = Flask(__name__)

app.config.from_object("config")
db = SQLA(app)
appbuilder = AppBuilder(app, db.session,menu=Menu(reverse=False), security_manager_class=MySecurityManager)


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

from . import testdata
from . import views

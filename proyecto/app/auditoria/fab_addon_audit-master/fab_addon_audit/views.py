import copy

from flask import render_template, g,redirect,flash
from flask_appbuilder.models.sqla.interface import SQLAInterface
from flask_appbuilder.widgets import ListLinkWidget
from flask_appbuilder import ModelView
from flask_appbuilder.charts.views import DirectByChartView, GroupByChartView
from flask_appbuilder.models.group import aggregate_count, aggregate_avg, aggregate_sum
from .models import Auditoria, Operacion
from flask_appbuilder._compat import string_types
from flask_appbuilder import expose,has_access

import inspect

class AuditedModelView(ModelView):

    def dict_compare(self,a, b):
        try:
            d1=self.mostraritem(a)
            d2=self.mostraritem(b)
            common_pairs = dict()
            non_common_pairs = dict()
            for key in d1:
                if key=="estadorender":
                    if getattr(a, "estado")==getattr(b, "estado"):
                        common_pairs[key] = d1[key]
                    else:
                        non_common_pairs[key]=d2[key]
                else:
                    if (key in d2 and d1[key] == d2[key]):
                        common_pairs[key] = d1[key]
                    else:
                        non_common_pairs[key]=d2[key]
        except Exception as e:
            print(e.__str__())
            print(e)
        return common_pairs,non_common_pairs


    def update_operation(self):
        return self.appbuilder.get_session.query(Operacion).filter(Operacion.name == 'UPDATE').first()

    def insert_operation(self):
        return self.appbuilder.get_session.query(Operacion).filter(Operacion.name == 'INSERT').first()

    def delete_operation(self):
        return self.appbuilder.get_session.query(Operacion).filter(Operacion.name == 'DELETE').first()

    def add_log_event(self, message, operation):
        try:
            print("buscando error")
            diccionario=self.mostraritem(message)
            #print(diccionario)
            strings=""
            for key in diccionario:
                try:
                    if  not inspect.ismethod(getattr(message,key) ) :

                            strings += key.upper() + " " + diccionario[key].__str__() + " "
                    if inspect.ismethod(getattr(message,key) ) and  key !='formatofecha' and  key !='renglonesrender' :
                            if key=="estadorender":
                                strings += "ESTADO" + " " + str(getattr(message, key)()).replace("<b>","").replace("</b>","") + " "
                            else:
                                strings += key.upper() + " " + str(getattr(message,key) ()) + " "
                    #print(key,inspect.ismethod(getattr(message,key) ), inspect.isfunction(diccionario[key]) ,strings)

                except Exception as e:
                    print(e.__str__())
                    print(e)
            cambios = ""
            anterior = ""
            if operation.name == "UPDATE":
                diccionario2 = self.mostraritem(self.preitem)
                #print('diccionario2 ',diccionario2)
                for key in diccionario2:
                    try:

                        #print('clave foranea ',set([Column.name for Column in self.datamodel.obj.__table__.columns if Column.foreign_keys]))

                        if not inspect.ismethod(getattr(self.preitem, key)):
                            anterior += key.upper() + " " + diccionario2[key].__str__() + " "
                        if inspect.ismethod(
                                getattr(self.preitem, key)) and key != 'formatofecha' and key != 'renglonesrender':
                            if key == "estadorender":
                                anterior += "ESTADO" + " " + str(getattr(self.preitem, key)()).replace("<b>", "").replace(
                                    "</b>", "") + " "
                            else:
                                anterior += key.upper() + " " + str(getattr(self.preitem, key)()) + " "
                    except Exception as e:
                        print(e.__str__())
                        print(e)

                if len(self.modificado)>0:
                    diccionario2=self.modificado
                    for key in diccionario2:
                        if not inspect.ismethod(getattr(self.preitem,key) ) :
                            cambios += key.upper() + " " + diccionario2[key].__str__() + " "
                        if inspect.ismethod(getattr(self.preitem,key) ) and  key !='formatofecha' and  key !='renglonesrender' :
                                if key=="estadorender":
                                    cambios += "ESTADO" + " " + str(getattr(self.preitem, key)()).replace("<b>","").replace("</b>","") + " "
                                else:
                                    cambios += key.upper() + " " + str(getattr(self.preitem,key)()) + " "

            auditlog = Auditoria(message=strings, anterior=anterior,username=g.user.username, operation=operation, target=self.__class__.datamodel.model_name)
            try:
                self.appbuilder.get_session.add(auditlog)
                self.appbuilder.get_session.commit()
            except Exception as e:
                print("Unable to write audit log for post_update")
                self.appbuilder.get_session.rollback()
        except Exception as e:
            print(e)
            print(str(e))
            print(repr(e))
            print("Error en la auditoria")


    def post_update(self, item):
        operation = self.update_operation()
        try:
            #print('post update',self.mostraritem(self.preitem))
            #print(item.id,'\n',self.mostraritem(item))
            same, modified =self.dict_compare(self.preitem,item)
            #print('modified: ',modified )
            self.modificado=modified

            #print('same: ', same, self.mostraritem(self.preitem)==self.mostraritem(item))

        except Exception as e:
            print(e.__str__())
            print(e)


        self.add_log_event(item, operation)
    def post_post_add(self, item):
        return redirect(self.get_redirect())

    def post_add(self, item):
        self.post_post_add(item)
        operation = self.insert_operation()
        self.add_log_event(item, operation)

    def post_delete(self, item):
        operation = self.delete_operation()
        self.add_log_event(item, operation)


    def mostraritem(self, item):
        """Returns a json-able dict for show"""
        lista = [self.list_columns,self.show_columns]
        result = list({city for cities in lista for city in cities})
        result=self.datamodel.obj.__table__.columns.keys()
        print('self.datamodel.__table__.columns.keys() ',result)
        #print('combinacion de ambas',result)
        d = {}
        for col in result:
            v = getattr(item, col)
            if not isinstance(v, (int, float, string_types)):
                v = str(v)
            d[col] = v
        return d
    @expose("/delete/<pk>", methods=["GET", "POST"])
    @has_access
    def delete(self, pk):
        import copy
        item = self.datamodel.get(pk, self._base_filters)
        self.pre_pre_update(copy.copy(item))
        item.estado=False
        self.datamodel.edit(item)
        self.post_update(item)

        self.update_redirect()
        flash(*self.datamodel.message)
        return self.post_delete_redirect()

class AuditLogView(ModelView):
    datamodel = SQLAInterface(Auditoria)
    base_order = ('created_on','dsc')
    list_widget = ListLinkWidget
    list_title = "Registro de Auditoria"
    label_columns = {'username':'Usuario','formatofecha':'Fecha de Creación','operation':'Operación','target':'Tabla','message':'Mensaje' }
    list_columns = ['formatofecha', 'username', 'operation', 'target', 'message']
    base_permissions = ['can_list','can_show']


class AuditLogChartView(GroupByChartView):
    datamodel = SQLAInterface(Auditoria)

    chart_title = 'Grouped Audit Logs'
    chart_type = 'BarChart'
    definitions = [
        {
            'group' : 'operation',
            'formatter': str,
            'series': [(aggregate_count,'operacion')]
        },
        {
            'group' : 'username',
            'formatter': str,
            'series': [(aggregate_count,'username')]
        }
    ]

from flask_appbuilder import ModelView
import inspect
from flask_appbuilder.widgets import ListWidget
class listwitgetall(ListWidget):
    template = 'listwitget.html'

class Modelovista(ModelView):
    list_template = "list.html"
    list_widget = listwitgetall
    def _init_titles(self):
        """
            Init Titles if not defined
        """

        class_name = self.datamodel.model_name
        if not self.list_title:
            self.list_title = "Listado de " + self._prettify_name(class_name)
        if not self.add_title:
            self.add_title = "Agregar " + self._prettify_name(class_name)
        if not self.edit_title:
            self.edit_title = "Editar " + self._prettify_name(class_name)
        if not self.show_title:
            self.show_title = "Detalle de " + self._prettify_name(class_name)
        self.title = self.list_title
    def pre_add(self, item):
        for key in self.show_item_dict(item):
            if not inspect.ismethod(getattr(item, key)):
                print(key, type(getattr(item, key)), type("string"))
                if type(getattr(item, key)) == type("string"):
                    setattr(item, key, getattr(item, key).upper())
                if type(getattr(item, key)) == type(10.0):
                    setattr(item, key, format(getattr(item, key), '.2f'))
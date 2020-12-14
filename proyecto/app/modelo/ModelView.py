from flask_appbuilder import ModelView
import inspect
from flask_appbuilder.widgets import ListWidget
from flask_appbuilder.baseviews import BaseCRUDView, BaseFormView, BaseView, expose, expose_api
from flask_appbuilder.security.decorators import has_access, has_access_api, permission_name
import logging
from flask_appbuilder.urltools import get_filter_args, get_order_args, get_page_args, get_page_size_args
from flask import request,make_response,jsonify,abort,flash
import copy
log = logging.getLogger(__name__)
class listwitgetall(ListWidget):
    template = 'listwitget.html'

class Modelovista(ModelView):
    list_template = "list.html"
    list_widget = listwitgetall
    edit_template = 'modelo_detalle.html'
    show_template = 'modelo_detalle_lista.html'
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
    def pre_pre_update(self, item):
        self.preitem=item
        print('prepre update',item)
        return self.preitem

    def _edit(self, pk):
        """
            Edit function logic, override to implement different logic
            returns Edit widget and related list or None
        """
        is_valid_form = True
        pages = get_page_args()
        page_sizes = get_page_size_args()
        orders = get_order_args()
        get_filter_args(self._filters)
        exclude_cols = self._filters.get_relation_cols()

        item = self.datamodel.get(pk, self._base_filters)
        if not item:
            abort(404)
        self.pre_pre_update(copy.copy(item))
        # convert pk to correct type, if pk is non string type.
        pk = self.datamodel.get_pk_value(item)

        if request.method == "POST":
            form = self.edit_form.refresh(request.form)
            # fill the form with the suppressed cols, generated from exclude_cols
            self._fill_form_exclude_cols(exclude_cols, form)
            # trick to pass unique validation
            form._id = pk
            if form.validate():
                self.process_form(form, False)

                try:
                    form.populate_obj(item)
                    self.pre_update(item)
                except Exception as e:
                    flash(str(e), "danger")
                else:
                    if self.datamodel.edit(item):
                        self.post_update(item)
                    flash(*self.datamodel.message)
                finally:
                    return None
            else:
                is_valid_form = False
        else:
            # Only force form refresh for select cascade events
            form = self.edit_form.refresh(obj=item)
            # Perform additional actions to pre-fill the edit form.
            self.prefill_form(form, pk)

        widgets = self._get_edit_widget(form=form, exclude_cols=exclude_cols)
        widgets = self._get_related_views_widgets(
            item,
            filters={},
            orders=orders,
            pages=pages,
            page_sizes=page_sizes,
            widgets=widgets,
        )
        if is_valid_form:
            self.update_redirect()
        return widgets
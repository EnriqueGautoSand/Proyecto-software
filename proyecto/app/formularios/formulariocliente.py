from wtforms import Form, BooleanField, StringField, validators, DateField, FloatField, IntegerField, FieldList, \
    SelectField, SubmitField
from wtforms.validators import DataRequired,InputRequired
from validadores import cuitvalidator
from flask_appbuilder.fieldwidgets import BS3TextFieldWidget, Select2Widget
from wtforms.widgets import TextArea
class ClienteForm(Form):
    tipopersona=SelectField('Tipo de persona', coerce=str, validators=[InputRequired()], widget=Select2Widget() )
    tipodocumento = SelectField('Tipo de Documento', coerce=str, widget=Select2Widget() )
    documento = StringField("Documento", validators=[InputRequired(),cuitvalidator(dato='tipoDocumento')] )
    tipoclave = SelectField('Cond Frente IVA', coerce=str, validators=[InputRequired()], widget=Select2Widget() )
    nombre = StringField("Nombre", validators=[InputRequired()])
    apellido = StringField("Apellido", validators=[InputRequired()])
    direccion = StringField("Direccion", widget=BS3TextFieldWidget())
    localidad = SelectField('Localidad', coerce=str, widget=Select2Widget() )
    cuit = StringField("Cuit")
    tipoclavejuridica = SelectField('Cond Frente IVA', coerce=str, validators=[InputRequired()], widget=Select2Widget())
    denominacion = StringField("Denominacion", validators=[InputRequired()])
    razonsocial = StringField("Razon social")



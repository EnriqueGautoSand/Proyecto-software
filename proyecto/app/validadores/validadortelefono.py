from ..models  import db,Clientes
from wtforms.validators import ValidationError
def validadornumerotelefono(form, field):

    numero=field.data
    print('numero',numero)
    if numero != '':
        resultado=db.session.query(Clientes).filter(Clientes.telefono_celular == numero).first()
        if resultado!=None:
            raise ValidationError(f'Telefono Repetido!!! No valido')
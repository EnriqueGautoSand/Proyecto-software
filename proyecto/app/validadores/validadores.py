from wtforms.validators import ValidationError
from datetime import datetime as dt
def fechavalidador(form, field):
    if field.data<dt.now().date():
        raise ValidationError(f'Fecha de vencimiento no valido, no debe ser menor a la fecha actual')
def cuitvalidator(dato):
    def _cuitvalidator(form, field):

        arrsinguion=field.data.split("-")
        sCUIT=""
        for i in arrsinguion:
            sCUIT+=i

        print(type(form[dato].data),form[dato].data,type(form[dato].data))
        if str(form[dato].data) == "CUIT":
            if len(sCUIT)==11 :
                aMult = '5432765432'
                aMult = list(aMult)

                iResult = 0
                aCUIT = list(sCUIT)

                for i in range(0,10):
                    iResult += float(aCUIT[i]) * float(aMult[i])

                iResult = iResult % 11

                iResult = 11 - iResult

                if iResult == 11:
                    iResult = 0
                if iResult == 10:
                    iResult = 9

                if iResult != float(aCUIT[10]):
                    raise ValidationError(f'{form[dato].data} no valido')
            else:
                raise ValidationError(f'{form[dato].data} incompleto!!! El {form[dato].data} debe estar compuesto por 11 numeros y 2 guiones')



    return _cuitvalidator



def cuitvalidatorProveedores(form, field):
    arrsinguion = field.data.split("-")
    sCUIT = ""
    for i in arrsinguion:
        sCUIT += i
    if len(sCUIT) == 11:
        aMult = '5432765432'
        aMult = list(aMult)

        iResult = 0
        aCUIT = list(sCUIT)

        for i in range(0, 10):
            iResult += float(aCUIT[i]) * float(aMult[i])

        iResult = iResult % 11

        iResult = 11 - iResult

        if iResult == 11:
            iResult = 0
        if iResult == 10:
            iResult = 9
        #print(iResult)
        if iResult != float(aCUIT[10]):
            raise ValidationError(f'{field.name.capitalize()} no valido')
    else:
        raise ValidationError(
            f'{field.name.capitalize()} incompleto!!! El {field.name.capitalize()} debe estar compuesto por 11 numeros y 2 guiones')
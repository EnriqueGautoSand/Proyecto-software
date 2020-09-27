from app import db
from app.models import Venta,Clientes,TipoClaves,tiposDocumentos,FormadePago
from datetime import datetime as dt




datos_test=[ FormadePago(Metodo="Contado"),
            FormadePago(Metodo="Tarjeta Debito"),
            Clientes(documento="Consumidor Final", condicionFrenteIva=TipoClaves.consumidorFinal,
                        tipoDocumento=tiposDocumentos.DNI, created_by_fk=1, changed_by_fk=1, estado=True),
            Clientes(documento="3905508741", condicionFrenteIva=TipoClaves.consumidorFinal,
                        tipoDocumento=tiposDocumentos.DNI, created_by_fk=1, changed_by_fk=1, estado=True),
            Clientes(documento="253648741", condicionFrenteIva=TipoClaves.consumidorFinal,
                        tipoDocumento=tiposDocumentos.DNI, created_by_fk=1, changed_by_fk=1, estado=True),
            Clientes(documento="131618746", condicionFrenteIva=TipoClaves.consumidorFinal,
                        tipoDocumento=tiposDocumentos.DNI, created_by_fk=1, changed_by_fk=1, estado=True)
        ]
for carga in datos_test:
    try:
        db.session.add(carga)
        #db.session.add(Venta(Estado="Friends", total=13, fecha=dt.now(),cliente_id=1,created_by_fk=1,changed_by_fk=1))

        db.session.commit()
    except Exception as e:
        print(str(e))
        db.session.rollback()
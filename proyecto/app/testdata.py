from app import db
from app.models import Venta,Clientes,TipoClaves,tiposDocumentos,FormadePago,CompaniaTarjeta,EmpresaDatos
from datetime import datetime as dt




datos_test=[EmpresaDatos(compania="Kiogestion",direccion="Avenida Roque Perez, 1522"),
    CompaniaTarjeta(compania="Visa"),
            CompaniaTarjeta(compania="Mastercard"),
            FormadePago(Metodo="Contado"),
            FormadePago(Metodo="Tarjeta"),
            Clientes(documento="Consumidor Final",
                        tipoDocumento=tiposDocumentos.DNI, created_by_fk=1, changed_by_fk=1, estado=True),
            Clientes(documento="3905508741",
                        tipoDocumento=tiposDocumentos.DNI, created_by_fk=1, changed_by_fk=1, estado=True),
            Clientes(documento="253648741",
                        tipoDocumento=tiposDocumentos.DNI, created_by_fk=1, changed_by_fk=1, estado=True),
            Clientes(documento="131618746",
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
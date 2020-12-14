
# ----------------------------------------------------------------------------
# Nombre:       reportePDF.py
# Autor:        Miguel Andres Garcia Niño
# Creado:       15 de Julio 2018
# Modificado:   20 de Julio 2018
# Copyright:    (c) 2018 by Miguel Andres Garcia Niño, 2018
# License:      Apache License 2.0
# ----------------------------------------------------------------------------

__versión__ = "1.0"

# Versión Python: 3.5.2

"""
El módulo *reportePDF* permite crear un reporte PDF sencillo.
"""

from sqlite3 import connect

from arrow import utcnow, get
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, mm
from reportlab.lib.pagesizes import letter
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT
from reportlab.lib.colors import black, purple, white,cyan,gray
from reportlab.pdfgen import canvas
from flask import g, url_for
from datetime import datetime as dt
from .models import EmpresaDatos
from . import appbuilder, db
import os.path
def get_user():
    return g.user.first_name.capitalize()+" "+g.user.last_name.capitalize()

# ======================= CLASE reportePDF =========================
class reportePDF(object):
    """Exportar una lista de diccionarios a una tabla en un
       archivo PDF."""


    def __init__(self, titulo, cabecera, datos, nombrePDF,nombreautor,filtros,no_registros):
        super(reportePDF, self).__init__()
        self.titulo = titulo
        self.cabecera = cabecera
        self.datos = datos
        self.nombrePDF = nombrePDF
        self.nombreautor=nombreautor
        self.filtros = filtros
        self.estilos = getSampleStyleSheet()
        self.empresadatos=db.session.query(EmpresaDatos).first()
        self.direccion=self.empresadatos.direccion
        self.localidad=self.empresadatos.localidad
        self.no_registros=no_registros




    def _encabezadoPiePagina(self,canvas, archivoPDF):
        """Guarde el estado de nuestro lienzo para que podamos aprovecharlo"""

        canvas.saveState()
        estilos = getSampleStyleSheet()

        alineacion = ParagraphStyle(name="alineacion", alignment=TA_RIGHT,
                                    parent=estilos["Normal"])

        # Encabezado
        encabezadoNombre = Paragraph(self.nombreautor, estilos["Heading1"])
        anchura, altura = encabezadoNombre.wrap(archivoPDF.width, archivoPDF.topMargin)
        encabezadoNombre.drawOn(canvas, archivoPDF.leftMargin, 720)
        if self.filtros != None:
            escribirfiltros = Paragraph(self.filtros.__repr__(), estilos["Normal"])
            anchura, altura = escribirfiltros.wrap(archivoPDF.width, archivoPDF.topMargin)
            escribirfiltros.drawOn(canvas, archivoPDF.leftMargin, 680)
        if self.direccion != None:
            localidad=""
            if self.localidad!= None:
                localidad=self.localidad.__repr__()
            escribirdireccion = Paragraph(self.direccion+" "+localidad, estilos["Normal"])
            anchura, altura = escribirdireccion.wrap(archivoPDF.width, archivoPDF.topMargin)
            escribirdireccion.drawOn(canvas, archivoPDF.leftMargin, 705)


        fecha = utcnow().to("local").format("dddd, DD / MMMM / YYYY", locale="es")
        fechaReporte = "Fecha: "+dt.now().strftime("%d/%m/%Y-%H:%M")#fecha.replace("-", "de")


        if db.session.query(EmpresaDatos).first().logo!= None:
            fn = os.path.join(os.path.dirname(os.path.abspath(__file__)),"static\\uploads\\"+db.session.query(EmpresaDatos).first().logo)
            print(os.path.dirname(os.path.abspath(__file__)))
            print(os.getcwd() + url_for('static',filename='uploads/logo_thumb.jpg'))
            canvas.drawImage(fn, archivoPDF.leftMargin, 740, width=50,height=50)

        encabezadoFecha = Paragraph(fechaReporte, alineacion)
        anchura, altura = encabezadoFecha.wrap(archivoPDF.width, archivoPDF.topMargin)
        encabezadoFecha.drawOn(canvas, archivoPDF.leftMargin, 740)

        # Pie de página
        largo=f"Generado por {get_user()}."
        piePagina = Paragraph(largo,alineacion)
        anchura, altura = piePagina.wrap(archivoPDF.width, archivoPDF.topMargin)
        piePagina.drawOn(canvas, archivoPDF.leftMargin,720)
        #numero de registros devueltos
        largo = f"Registros devueltos: {self.no_registros}"
        piePagina = Paragraph(largo,alineacion)
        anchura, altura = piePagina.wrap(archivoPDF.width, archivoPDF.topMargin)
        piePagina.drawOn(canvas, archivoPDF.leftMargin,705)

        # Suelta el lienzo
        canvas.restoreState()


    def convertirDatos(self):
        """Convertir la lista de diccionarios a una lista de listas para crear
           la tabla PDF."""

        estiloEncabezado = ParagraphStyle(name="estiloEncabezado", alignment=TA_LEFT,
                                          fontSize=10, textColor=white,
                                          fontName="Helvetica-Bold",
                                          parent=self.estilos["Normal"])

        estiloNormal = self.estilos["Normal"]
        estiloNormal.alignment = TA_LEFT

        claves, nombres = zip(*[[k, n] for k, n in self.cabecera])

        encabezado = [Paragraph(nombre, estiloEncabezado) for nombre in nombres]
        nuevosDatos = [tuple(encabezado)]

        for dato in self.datos:
            nuevosDatos.append([Paragraph(str(dato[clave]), estiloNormal) for clave in claves])

        return nuevosDatos


    def Exportar(self):
        """Exportar los datos a un archivo PDF."""

        alineacionTitulo = ParagraphStyle(name="centrar", alignment=TA_CENTER, fontSize=13,
                                          leading=10, textColor=purple,
                                          parent=self.estilos["Heading1"])

        self.ancho, self.alto = letter

        convertirDatos = self.convertirDatos()

        tabla = Table(convertirDatos, colWidths=(self.ancho - 100) / len(self.cabecera), hAlign="CENTER")
        tabla.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), gray),
            ("ALIGN", (0, 0), (0, -1), "LEFT"),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),  # Texto centrado y alineado a la izquierda
            ("INNERGRID", (0, 0), (-1, -1), 0.50, black),  # Lineas internas
            ("BOX", (0, 0), (-1, -1), 0.25, black),  # Linea (Marco) externa
        ]))

        historia = []
        historia.append(Spacer(1, 0.16 * inch))
        historia.append(Spacer(1, 0.16 * inch))
        historia.append(Spacer(1, 0.16 * inch))
        historia.append(Paragraph(self.titulo, alineacionTitulo))
        historia.append(Spacer(1, 0.16 * inch))
        historia.append(tabla)

        archivoPDF = SimpleDocTemplate(self.nombrePDF, leftMargin=50, rightMargin=50, pagesize=letter,
                                       title="Reporte PDF", author="Kiogestion")

        try:
            archivoPDF.build(historia, onFirstPage=self._encabezadoPiePagina,
                             #onLaterPages=self._encabezadoPiePagina,
                             canvasmaker=numeracionPaginas)

            # +------------------------------------+
            return "Reporte generado con éxito."
        # +------------------------------------+
        except PermissionError:
            # +--------------------------------------------+
            return "Error inesperado: Permiso denegado."
        # +--------------------------------------------+


    # ================== CLASE numeracionPaginas =======================

class numeracionPaginas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        canvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        """Agregar información de la página a cada página (página x de y)"""
        numeroPaginas = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_number(numeroPaginas)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_number(self, conteoPaginas):
        self.drawRightString(204 * mm, 15 * mm + (0.2 * inch),
                             "Página {} de {}".format(self._pageNumber, conteoPaginas))

    # ===================== FUNCIÓN generarReporte =====================
def generarReporte(titulo,cabecera,buscar,nombre,datos=None,filtros=None,no_registros=None):
    """Ejecutar consulta a la base de datos ( y llamar la función Exportar, la
       cuál esta en la clase reportePDF, a esta clase le pasamos el título de la tabla, la
       cabecera y los datos que llevará."""
    from app import db
    from .models import Venta
    lista=[]
    # cabecera = (
    #     ("total", "total"),("cliente", "cliente"),
    #     ("formadepago", "forma de pago"),
    # )
    total=0
    def row2dict(row):
        """
        configuro la fila con el formato adecuado
        :param row: es la fila, objeto
        :return: es un dicionario
        """
        d={}
        claves, nombres = zip(*[[k, n] for k, n in cabecera])
        for titulo in claves:
            d[titulo] = getattr(row, titulo)
            if titulo == "fecha":

                fecha=getattr(row, titulo)
                fecha=fecha.strftime(" %d-%m-%Y ")
                print( fecha,d[titulo], type(fecha) )
                d[titulo] =fecha
            if titulo == "total":
                if getattr(row, "estado"):
                    d[titulo] = "$"+str(getattr(row,titulo))
                else:
                    d[titulo] = "Anulado"
            elif titulo == "condicionFrenteIva" or titulo== "formadepago" :
                print(buscar().__class__.__name__, titulo)
                if buscar().__class__.__name__ == "Venta" or titulo == "condicionFrenteIva" :
                    d[titulo] = getattr(row, titulo)()
                elif buscar().__class__.__name__ == "Compra":

                    d[titulo] = getattr(row, titulo)



        return d
    if datos!=None:
        #recorro los datos
        for u in datos:
            if u.estado:
                total += u.total
            else:
                total += 0
            lista.append(row2dict(u))
    else:
        for u in db.session.query(buscar).all():

            total+=u.total
            lista.append(row2dict(u))

    claves, nombres = zip(*[[k, n] for k, n in cabecera])
    print(claves)
    d = {}
    #configuro el total de los totales
    for clave in claves:
        if clave==claves[-2]:
            d[clave] = "Total"
        elif clave==claves[-1]:
            d[clave] = '$'+str(format(total, '.2f'))
        else:
            d[clave] = ""
    lista.append(d)
    #titulo = "LISTADO DE USUARIOS"

    # cabecera = (
    #     ("total", "total"),("cliente", "cliente"),
    #     ("formadepago", "forma de pago"),
    # )

    nombrePDF = "./app/static/docs/"+ nombre +".pdf"

    nombreautor=db.session.query(EmpresaDatos).first().compania
    reporte = reportePDF(titulo, cabecera, lista, nombrePDF,nombreautor,filtros,no_registros).Exportar()
    print(reporte)


# ======================== LLAMAR FUNCIÓN ==========================



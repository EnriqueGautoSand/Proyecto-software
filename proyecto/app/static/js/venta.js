var producto = document.getElementById('producto')
var cantidad = document.getElementById('cantidad')
var cliente = document.getElementById('cliente')
var metododePago= document.getElementById('metodo')
var tablafinalizar= document.getElementById('finalizar')
var total = document.getElementById('Total')
var condicionfrenteiva = document.getElementById('condicionfrenteiva')
cantidad.className="form-inline"

var cupon= document.getElementById('numeroCupon')
cupon.className="form-inline"
var companiaTarjeta= document.getElementById('companiaTarjeta')
companiaTarjeta.className="form-control"

var credito= document.getElementById('credito')
var cuotas= document.getElementById('cuotas')


var	tabla=document.createElement("table")

var tebody=document.createElement("tbody")
function agregarTd(tere,texto){
	titulo =document.createTextNode(texto)
	tede= document.createElement("td")
	tede.appendChild(titulo)
	tede.align="center"
	tere.appendChild(tede)
}
var fila =document.getElementById('agregar')
parentNodes=fila.parentNode
parentNodes.insertBefore(tabla, fila.nextSibling); 
var boton= document.createElement("button")

boton.textContent="Finalizar Venta"
boton.className="btn  btn-success btn-sm"

var tdfinal=document.getElementById("botonagregar")

tdfinal.appendChild(boton)


var tere=document.createElement("tr")

agregarTd(tere,'Producto')
agregarTd(tere,'Cantidad')
agregarTd(tere,'SubTotal')

tebody.appendChild(tere)

tabla.appendChild(tebody)

tabla.className="table table-bordered table-hover "

var listaProductos = new Set();
var resp
var totalFila=0
var totalColuma=0
var totalhtml=document.getElementById("Total") 
var jsonProductos={}



function addRowHandlers() {
//esta funcion es la que se enecarga del evento click en las filas
  var table = tabla
  var rows = table.getElementsByTagName("tr");
  for (i = 1; i < rows.length; i++) {
    var currentRow = table.rows[i];
    var createClickHandler = function(row) {
      return function() {
        var cellProducto = row.getElementsByTagName("td")[0];
        var textoProducto = cellProducto.innerHTML;
 		$("#producto").select2().val(jsonProductos[textoProducto][0]).trigger("change");
		var cellCantidad= row.getElementsByTagName("td")[1];
        cantidad.value=cellCantidad.innerHTML;

      };
    };
    currentRow.onclick = createClickHandler(currentRow);
  }
	}
function  cantidadpos(){
if (parseInt(cantidad.value)>0){
	return parseInt(cantidad.value)
}else{
	return false 
}

}

function agregarRenglon(element){
	element.disabled=true

	totalFila=0

	
	//var producto = document.getElementById('producto')
	//var cantidad = document.getElementById('cantidad')

	console.log(producto.value, producto[producto.selectedIndex].innerHTML)
	console.log(cantidad.value)
	productosel=JSON.parse(producto.value)

	if (! listaProductos.has(productosel.id)  && cantidadpos()){
		//jsonproductos guarda el producto y su cantidad basicamente guarda los renglones de la venta
		jsonProductos[productosel.representacion]=[producto.value, cantidadpos()]

		var hilera = document.createElement("tr");
		
		var celda = document.createElement("td");
		var textoCelda = document.createTextNode(producto[producto.selectedIndex].innerHTML );
      celda.appendChild(textoCelda);
      celda.align="center"
      celda.className="col-md-1 col-lg-1 col-sm-1"
      var celda2 = document.createElement("td");
      var textoCelda2 = document.createTextNode(cantidadpos());
      celda2.appendChild(textoCelda2);
      celda2.className="col-md-1 col-lg-1 col-sm-1"
      celda2.align="center"
      hilera.appendChild(celda);
      hilera.appendChild(celda2);



var url = "http://localhost:8080/api/v1/ventasapi/obtenerprecio/"
var data = {p: productosel.id};
try {
	// statements

 fetch(url, {
  method: 'POST', // or 'PUT'
  body: JSON.stringify(data), // data can be `string` or {object}!
  headers:{
    'Content-Type': 'application/json'
  }
}).then(res => res.json())
.catch(error => console.error('Error:', error))
.then(response =>{ console.log('Success:', response)
	
	totalFila =parseFloat( response.message)
	console.log('Success:', response.message,'  ',typeof totalFila)



	var celdsa = document.createElement("td");
	totalFila*=cantidadpos()
	var textoCelda3 = document.createTextNode("$" + totalFila );
	celdsa.appendChild(textoCelda3)
	celdsa.align="center"
	celdsa.className="col-md-1 col-lg-1 col-sm-1"
	hilera.appendChild(celdsa);
	  tebody.appendChild(hilera);
      listaProductos.add(productosel.id);
      console.log(listaProductos)
      totalColuma += totalFila
      totalhtml.value=totalColuma
      addRowHandlers()
      element.disabled=false
      
})} catch(e) {
	// statements
	console.log(e);
	element.disabled=false
}



	}else{
		alert("Producto Repetido o cantidad incorrecta")
		element.disabled=false
	}




}
function conectarVentaapi(jsonventa){
	var url = "http://localhost:8080/api/v1/ventasapi/realizarventa/"
var data = jsonventa;
try {
	fetch(url, {
  method: 'POST', // or 'PUT'
  body: JSON.stringify(data), // data can be `string` or {object}!
  headers:{
    'Content-Type': 'application/json'
  }
}).then(res => res.json())
.catch(error => console.error('Error:', error))
.then(response =>{
	console.log('Success:', response)
	if (response.message.status== "sucess"){
		window.location.href ="http://localhost:8080/ventaview/venta/"
		//window.location.href = "http://localhost:8080/ventareportes/show/"+response.message.idventa.toString()
	}else {
		alert(response.message)
	}

})

} catch(e) {
	// statements
	console.log(e);
	alert(e)

}}

function realizarventa(){
boton.disabled=true
		console.log(metododePago.value);
		jsonventa={};
		jsonventa["productos"]=[]
			console.log('contado')
			for (var clave in jsonProductos){
			  // Controlando que json realmente tenga esa propiedad
			  if (jsonProductos.hasOwnProperty(clave)) {
			    // Mostrando en pantalla la clave junto a su valor
			    
			    console.log(" Producto  " + JSON.parse(jsonProductos[clave][0])['id'] , " Cantidad: "+ jsonProductos[clave][1])
				jsonventa["productos"].push([JSON.parse(jsonProductos[clave][0])['id'],jsonProductos[clave][1] ])
			  }
			}
			jsonventa["cliente"]=parseInt(cliente.value);
			jsonventa["total"]=parseFloat(total.value);
			jsonventa["condicionfrenteiva"]=condicionfrenteiva.value
	if (metododePago.value=="Contado"){
			jsonventa["metododePago"]=1;
			
			conectarVentaapi(jsonventa);

	}else {
			jsonventa["metododePago"]=2;
			if(credito.checked && parseInt(cuotas.value)<=0){

					alert("Completar todos los datos de la Tarjeta")
			}
			else{
				if ( cupon.value!=""  ){
					alert("entro1")
						jsonventa["numeroCupon"]=cupon.value;
						jsonventa["companiaTarjeta"]=companiaTarjeta.value;
						jsonventa["credito"]=credito.checked
						jsonventa["cuotas"]=parseInt(cuotas.value) 
						conectarVentaapi(jsonventa);
				}
				else{
					alert("Completar todos los datos de la Tarjeta")
				}

	}
}

boton.disabled=false

	}





boton.onclick= function() {console.log('largo json ',jQuery.isEmptyObject(jsonProductos))
						if (jQuery.isEmptyObject(jsonProductos)){
								alert("No hay poductos asociados a esta venta!!!")

							}else{return realizarventa()

						}

						};
$("#metodo").click(function() {

						if (metododePago.value=="Tarjeta"){
								//alert("Cargar Tarjeta")
								$('#divtarjeta').collapse('show')
							}
						else{
							$('#divtarjeta').collapse('hide')
						}

						})

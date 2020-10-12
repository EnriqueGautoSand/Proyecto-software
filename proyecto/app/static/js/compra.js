var producto = document.getElementById('producto')
var cantidad = document.getElementById('cantidad')
var proveedor = document.getElementById('proveedor')
var metododePago= document.getElementById('metodo')

var total = document.getElementById('Total')

cantidad.className="form-inline"
var botonborrar=document.getElementById('borrar')
var condicionfrenteiva = document.getElementById('condicionfrenteiva')
var cupon= document.getElementById('numeroCupon')
cupon.className="form-inline"
var companiaTarjeta= document.getElementById('companiaTarjeta')
companiaTarjeta.className="form-control"
var credito= document.getElementById('credito')
var cuotas= document.getElementById('cuotas')



var	tabla=document.createElement("table")

var tebody=document.createElement("tbody")
//var agregar= document.body.getElementsByClassName('row')[0].getElementById('agregar')
var fila =document.getElementById('agregar')
parentNodes=fila.parentNode
parentNodes.insertBefore(tabla, fila.nextSibling); 
var boton= document.createElement("button")
tdboton= document.createElement("td")
boton.textContent="Finalizar Compra"
boton.className="btn  btn-success btn-sm"
//boton.style.float="right "
var tdfinal=document.getElementById("botonagregar")

tdfinal.appendChild(boton)

//parentNodes=tabla.parentNode
//parentNodes.insertBefore(boton, tabla.nextSibling); 

var tere=document.createElement("tr")

teache= document.createElement("td")

titulo = document.createTextNode('Producto')
teache2= document.createElement("td")
titulo2 = document.createTextNode('Cantidad')
teache3= document.createElement("td")
titulo3 = document.createTextNode('SubTotal')
teache.appendChild(titulo)
teache2.appendChild(titulo2)
teache3.appendChild(titulo3)
teache2.align="center"
teache.align="center"
teache3.align="center"
tere.appendChild(teache)
tere.appendChild(teache2)
tere.appendChild(teache3)
tebody.appendChild(tere)

tabla.appendChild(tebody)
//tabla.appendChild(teache2)
//tabla.appendChild(teache3)
//teache.className="col-md-1 col-lg-1 col-sm-1"
tabla.className="table table-bordered table-hover "

var listaProductos = new Set();
var resp
var totalFila=0
var totalColuma=0
var totalhtml=document.getElementById("Total") 
var jsonProductos={}
var renglonseleccionado=NaN

//esta funcion es la que se enecarga del evento click en las filas
function addRowHandlers() {
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
        renglonseleccionado=row
        botonborrar.disabled=false
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
	console.log(Math.abs(parseInt(cantidad.value)))
	console.log(Math.sign(parseInt(cantidad.value)))
return Math.abs(parseInt(cantidad.value))
}

function borrarRenglon(element){
	 var cellProducto = renglonseleccionado.getElementsByTagName("td")[0];
     var textoProducto = cellProducto.innerHTML;

     var totalfi= renglonseleccionado.getElementsByTagName("td")[2];
    console.log('totalfila',totalfi)
     totalfi=totalfi.innerHTML
	totalColuma-=parseInt( totalfi.split('$')[1])
	totalhtml.value=totalColuma
     
     listaProductos.delete(JSON.parse(jsonProductos[textoProducto][0]).id)
     jsonProductos[textoProducto] = undefined;
	jsonProductos=JSON.parse(JSON.stringify(jsonProductos))
	console.log(renglonseleccionado.id)
	$("#" + renglonseleccionado.id).remove();

	element.disabled=true
}
var contadorfilas=0
function agregarRenglon(element){
	renglonseleccionado=NaN
	botonborrar.disabled=true
	element.disabled=true

	totalFila=0

	
	//var producto = document.getElementById('producto')
	//var cantidad = document.getElementById('cantidad')

	console.log(producto.value, producto[producto.selectedIndex].innerHTML)
	console.log(cantidad.value)
	productosel=JSON.parse(producto.value)

	if (! listaProductos.has(productosel.id)  && cantidadpos()){
		//jsonproductos guarga el producto y su cantidad basicamente guarda los renglones de la venta
		jsonProductos[productosel.representacion]=[producto.value, cantidadpos()]

		var hilera = document.createElement("tr");
		contadorfilas+=1
		hilera.id="fila"+contadorfilas.toString()
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
	var url = "http://localhost:8080/api/v1/comprasapi/realizarcompra/"
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
		alert("Compra Realizada Satisfactoriamente")
		window.location.href ="http://localhost:8080/compraview/compra/"
		//window.location.href = "http://localhost:8080/comprareportes/show/"+response.message.idventa.toString()
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
			    if(jsonProductos[clave]!= undefined && jsonProductos[clave]!=null ){
			   		 console.log(" Producto  " + JSON.parse(jsonProductos[clave][0])['id'] , " Cantidad: "+ jsonProductos[clave][1])
					jsonventa["productos"].push([JSON.parse(jsonProductos[clave][0])['id'],jsonProductos[clave][1] ])
				}
			  }
			}
			
			jsonventa["proveedor"]=parseInt(proveedor.value);
			jsonventa["total"]=parseFloat(total.value);
			jsonventa["condicionfrenteiva"]=condicionfrenteiva.value
	if (metododePago.value==1){
			jsonventa["metododePago"]=metododePago.value;

			conectarVentaapi(jsonventa);

	}else {
			jsonventa["metododePago"]=metododePago.value;
			if(credito.checked && parseInt(cuotas.value)<=0){

					alert("Completar todos los datos de la Tarjeta")
			}
			else{
				if ( cupon.value!=""  ){
					
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

						if (metododePago.value==2){
								//alert("Cargar Tarjeta")
								$('#divtarjeta').collapse('show')
							}
						else{
							$('#divtarjeta').collapse('hide')
						}

						})
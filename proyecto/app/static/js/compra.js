var venta=false
var compra=true
var producto = document.getElementById('producto')
var cantidad = document.getElementById('cantidad')
var proveedor = document.getElementById('proveedor')
var metododePago= document.getElementById('metodo')
var iva
var totaliva=document.getElementById('totaliva')
if (totaliva==undefined){
	totaliva={}
	totaliva.value=0
}
function calculatotaliva(){
	let total=0
			for (var clave in jsonProductos){
			  // Controlando que json realmente tenga esa propiedad
			  if (jsonProductos.hasOwnProperty(clave)) {
			    // Mostrando en pantalla la clave junto a su valor
			    if(jsonProductos[clave]!= undefined && jsonProductos[clave]!=null ){
			  console.log(" Producto  " + typeof parseFloat(JSON.parse(jsonProductos[clave][0]).iva))
                      precioxcantidad=parseFloat(JSON.parse(jsonProductos[clave][2]))*parseFloat(JSON.parse(jsonProductos[clave][1]))
			   		 total+=(precioxcantidad*(1-parseFloat(JSON.parse(jsonProductos[clave][3]))/100))*(parseFloat(JSON.parse(jsonProductos[clave][0]).iva)/100)

				}
			  }

console.log(total)
			}
			
			totaliva.value=total.toFixed(2)
		}
function totalconimpuestos(){
      if ( JSON.parse(proveedor.value).tipoclave=="Responsable Inscripto" && responsableinscripto){
      	calculatotaliva()
      	totalhtml.value= (parseFloat(totalneto.value) + parseFloat((totalneto.value/100.0)*porcentajepositivo(percepcion,true)) + parseFloat(totaliva.value)).toFixed(2)  	
      }else if (JSON.parse(proveedor.value).tipoclave=="Responsable Inscripto" && monotributista) {
      	totalhtml.value= (parseFloat(totalneto.value) + parseFloat((totalneto.value/100.0)*porcentajepositivo(percepcion,true))).toFixed(2)  	       	
      }else {
      	 totalhtml.value= parseFloat(totalneto.value).toFixed(2)  	
      }
	totalneto.value= parseFloat(totalColuma).toFixed(2)
}
var descuento= document.getElementById('descuento')

var preciocompra= document.getElementById('preciocompra')

var percepcion= document.getElementById('percepcion')

var totalneto = document.getElementById('totalneto')

condfrenteivanego()

var total = document.getElementById('total')
cantidad.className="form-inline"
var botonborrar=document.getElementById('borrar')
//var condicionfrenteiva = document.getElementById('condicionfrenteiva')
var cupon= document.getElementById('numeroCupon')
cupon.className="form-inline"
var companiaTarjeta= document.getElementById('companiaTarjeta')
companiaTarjeta.className="form-control"
var credito= document.getElementById('credito')
var cuotas= document.getElementById('cuotas')

function updateValue(e){
	if(e.target.value>100 || e.target.value<0)
		{alert("Error El valor en "+e.target.name + " debe estar entre 0 y 100");
		 
		e.target.value=0

		}
	if(e.target.id==percepcion.id){
		totalhtml.value=parseFloat(totalneto.value) + parseFloat((totalneto.value/100.0)*porcentajepositivo(percepcion,true))
	}
	}
percepcion.addEventListener('change', updateValue);
descuento.addEventListener('change', updateValue);


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



function agregarTd(tere,texto, alineacion){
	titulo =document.createTextNode(texto)
	tede= document.createElement("td")
	tede.appendChild(titulo)
	tede.align=alineacion
	tere.appendChild(tede)
}


agregarTd(tere,'Producto')
agregarTd(tere,'Precio $')
agregarTd(tere,'Cantidad')
agregarTd(tere,'IVA')
agregarTd(tere,'Descuento %')
agregarTd(tere,'SubTotal')
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
var totalhtml=document.getElementById("total") 

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
		var cellCantidad= row.getElementsByTagName("td")[2];
		descuento.value= row.getElementsByTagName("td")[4].innerHTML;
		preciocompra.value= row.getElementsByTagName("td")[1].innerHTML;
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

return Math.abs(parseInt(cantidad.value))
}
function  porcentajepositivo(valor,buelan){
if (parseFloat(valor.value)>=0 && parseFloat(valor.value)<=100){
	if (buelan){
	return parseFloat(valor.value)}else{return true}
}else{
	return false 
}
return Math.abs(parseFloat(valor.value))
}

function  cantidadpospreciocompra(buelan){
if (parseFloat(preciocompra.value)>=0 ){
	if (buelan){

	return parseFloat(preciocompra.value)}else{return true}
}else{

	return false 
}
return Math.abs(parseFloat(preciocompra.value))
}

function borrarRenglon(element){
	 var cellProducto = renglonseleccionado.getElementsByTagName("td")[0];
     var textoProducto = cellProducto.innerHTML;

     var totalfi= renglonseleccionado.getElementsByTagName("td")[5];
    console.log('totalfila',totalfi)
     totalfi=totalfi.innerHTML
	totalColuma-=parseFloat( totalfi.split('$')[1])
	totalneto.value=totalColuma.toFixed(2)
	totalhtml.value=(parseFloat(totalneto.value)-((parseFloat(totalneto.value)/100)*porcentajepositivo(percepcion,true))).toFixed(2)
     
     listaProductos.delete(JSON.parse(jsonProductos[textoProducto][0]).id)
     jsonProductos[textoProducto] = undefined;
	jsonProductos=JSON.parse(JSON.stringify(jsonProductos))
	console.log(renglonseleccionado.id)
	$("#" + renglonseleccionado.id).remove();
	totalconimpuestos()
	calculatotaliva()
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

	if (! listaProductos.has(productosel.id)  && cantidadpos() && porcentajepositivo(valor=descuento) && cantidadpospreciocompra()){
		//jsonproductos guarda el producto y su cantidad basicamente guarda los renglones de la venta
		jsonProductos[productosel.representacion]=[producto.value, cantidadpos(), parseFloat(preciocompra.value),parseFloat(descuento.value)]

		var hilera = document.createElement("tr");
		contadorfilas+=1
		hilera.id="fila"+contadorfilas.toString()
		
		var textoCelda = document.createTextNode(producto[producto.selectedIndex].innerHTML );

      agregarTd(hilera,producto[producto.selectedIndex].innerHTML,'center')
      agregarTd(hilera,cantidadpospreciocompra(true) ,"right")
      agregarTd(hilera,cantidadpos() ,"right")
      agregarTd(hilera, productosel['iva'] ,"right")
      agregarTd(hilera,porcentajepositivo(descuento,true) ,"right")
      

	totalFila=cantidadpos()*(preciocompra.value*( 1-descuento.value/100))
	agregarTd(hilera,"$" + totalFila.toFixed(2),"right")
	  tebody.appendChild(hilera);
      listaProductos.add(productosel.id);
      console.log(listaProductos)
      totalColuma += totalFila
      totalneto.value=totalColuma
      

      totalconimpuestos()
      addRowHandlers()
      element.disabled=false








	}else{
		if(!cantidadpospreciocompra()){
			alert("Precio de compra no valido")
		}
		if(!porcentajepositivo(valor=descuento)) {
			alert("Descuento no valido debe estar entre 0 y 100")
		}
		if(!porcentajepositivo(percepcion)) {
			alert("Percepcion no valido debe estar entre 0 y 100")
		}
		if(!cantidadpos() || listaProductos.has(productosel.id) ){
		alert("Producto Repetido o cantidad incorrecta o descuento incorrecto")}
		element.disabled=false
	}




}
function conectarVentaapi(jsonventa){

	var url = location.origin+Flask.url_for("ComprasApi.compra")
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
		window.location.href ="http://localhost:8080/comprareportes/show/"+response.message.idcompra.toString()
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
					jsonventa["productos"].push({"producto":JSON.parse(jsonProductos[clave][0])['id'],"cantidad":jsonProductos[clave][1],
						"precio":jsonProductos[clave][2],"descuento":jsonProductos[clave][3] })
				}
			  }
			}
			
			jsonventa["proveedor"]=parseInt(JSON.parse(proveedor.value).id);
			jsonventa["totalneto"]=parseFloat(totalneto.value);
			jsonventa["total"]=parseFloat(totalhtml.value);
			jsonventa["totaliva"]=parseFloat(totaliva.value);
			jsonventa["percepcion"]=parseFloat(percepcion.value);
			jsonventa["comprobante"]=parseFloat(comprobante.value).toFixed(2);
			//jsonventa["condicionfrenteiva"]=condicionfrenteiva.value
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
						if (comprobante.value==0){
							alert("ingrese el numero de comprobante!!!")
							return;
						}

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

proveedor.onchange= (event)=> {
console.log(JSON.parse(event.target.value).tipoclave=="Responsable Inscripto",event.target.value)
    if(JSON.parse(event.target.value).tipoclave=="Responsable Inscripto" && responsableinscripto){
    	    percepcion.disabled=false
    	    iva=true
	}else if (JSON.parse(event.target.value).tipoclave=="Responsable Inscripto" && monotributista) {
		percepcion.disabled=true
		iva=false
	}else{
		percepcion.disabled=true
		iva=false
		percepcion.value=0
	}
	

}

setTimeout(  function(){  if(JSON.parse(proveedor.value).tipoclave=="Responsable Inscripto" && responsableinscripto){
    	    percepcion.disabled=false
    	    iva=true
	}else if (JSON.parse(proveedor.value).tipoclave=="Responsable Inscripto" && monotributista) {
		percepcion.disabled=true
		iva=false
	}else{
		percepcion.disabled=true
		iva=false
		percepcion.value=0
	}
		}, 3000)

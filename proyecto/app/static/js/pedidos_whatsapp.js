
var venta=true
var compra=false
var producto = document.getElementById('producto')
var cantidad = document.getElementById('cantidad')
var cliente = document.getElementById('cliente')
var metododePago= document.getElementById('metodo')
var tablafinalizar= document.getElementById('finalizar')
var iva
var total = document.getElementById('total')
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

			return parseFloat(totaliva.value)
			
		}
var botonborrar=document.getElementById('borrar')
//var condicionfrenteiva = document.getElementById('condicionfrenteiva')
cantidad.className="form-inline"
var descuento= document.getElementById('descuento')
var percepcion= document.getElementById('percepcion')

tarjeta=document.getElementById('unmetodo')
var ultimoElemento=tarjeta
condfrenteivanego()
//var cupon= document.getElementById('numeroCupon')
//cupon.className="form-inline"
var companiaTarjeta= document.getElementById('companiaTarjeta')
companiaTarjeta.className="form-control"

var credito= document.getElementById('credito')
var cuotas= document.getElementById('cuotas')

var totalneto = document.getElementById('totalneto')
if (totalneto==undefined){
	totalneto={}
	totalneto.value=0
}
var	tabla=document.createElement("table")

var tebody=document.createElement("tbody")
function agregarTd(tere,texto){
	titulo =document.createTextNode(texto)
	tede= document.createElement("td")
	tede.appendChild(titulo)
	tede.align="center"
	tere.appendChild(tede)
}
function updateValue(e){
	if(e.target.value>100 || e.target.value<0)
		{alert("Error El valor en "+e.target.name + " debe estar entre 0 y 100");
		 
		e.target.value=0

		}
	if(e.target.id==percepcion.id){
		totalhtml.value=parseFloat(totalColuma) + parseFloat((totalColuma/100.0)*porcentajepositivo(percepcion,true))
	}
	}
percepcion.addEventListener('change', updateValue);
descuento.addEventListener('change', updateValue);

var fila =document.getElementById('agregar')
parentNodes=fila.parentNode
parentNodes.insertBefore(tabla, fila.nextSibling); 


boton=document.getElementById('finalizarVenta')
boton.className="btn  btn-success btn-sm"



var tere=document.createElement("tr")

agregarTd(tere,'Producto')
agregarTd(tere,'Precio')
agregarTd(tere,'Cantidad')
agregarTd(tere,'Descuento %')
agregarTd(tere,'IVA')
agregarTd(tere,'SubTotal')

tebody.appendChild(tere)

tabla.appendChild(tebody)

tabla.className="table table-bordered table-hover "

var listaProductos = new Set();
var resp
var totalFila=0
var totalColuma=0
var totalhtml=document.getElementById("total") 
var jsonProductos={}
var renglonseleccionado=undefined

function  porcentajepositivo(valor,buelan){
if (parseFloat(valor.value)>=0 && parseFloat(valor.value)<=100){
	if (buelan){
	return parseFloat(valor.value)}else{return true}
}else{
	return false 
}
return Math.abs(parseFloat(valor.value))
}
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
		var cellCantidad= row.getElementsByTagName("td")[2];
		descuento.value= row.getElementsByTagName("td")[3].innerHTML;
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
		return parseFloat(cantidad.value)
	}else{
		return false 
	}
}
function  cantidadposdescuento(buelan){
if (parseInt(descuento.value)>=0 && parseInt(descuento.value)<=100){
	if (buelan){
	return parseInt(descuento.value)}else{return true}
}else{
	return false 
}
return Math.abs(parseInt(descuento.value))
}
function totalconimpuestos(){
	      if (JSON.parse(cliente.value).tipoclave=="Responsable Inscripto" && responsableinscripto){
	      	
	      	console.log(totaliva.value)

      	      totalhtml.value= (parseFloat(totalColuma) + parseFloat((totalColuma/100.0)*porcentajepositivo(percepcion,true)) +  calculatotaliva());
			}
		else if (JSON.parse(cliente.value).tipoclave=="Monotributista" &&  responsableinscripto) {
			totalsiniva=0
			for (let clave in jsonProductos){
								  if (jsonProductos.hasOwnProperty(clave)) {
			    // Mostrando en pantalla la clave junto a su valor
			    if(jsonProductos[clave]!= undefined && jsonProductos[clave]!=null ){
			    		totalsiniva+=totalColuma-(totalColuma/(1+(parseFloat(JSON.parse(jsonProductos[clave][0]).iva)/100)))

			    }}
			}
			totalsiniva=totalColuma-totalsiniva

			totalhtml.value= parseFloat(totalColuma) + parseFloat((totalsiniva/100.0)*porcentajepositivo(percepcion,true)) 
			totaliva.value=0
			}
		else{
			totalhtml.value=parseFloat(totalColuma)
			totaliva.value=0
		}
		totalneto.value= parseFloat(totalColuma).toFixed(2)
}
function borrarRenglon(element){
	 var cellProducto = renglonseleccionado.getElementsByTagName("td")[0];
     var textoProducto = cellProducto.innerHTML;
     var totalfi= renglonseleccionado.getElementsByTagName("td")[5];
    console.log('totalfila',totalfi)
     totalfi=totalfi.innerHTML

	

    listaProductos.delete(JSON.parse(jsonProductos[textoProducto][0]).id)
    jsonProductos[textoProducto] = undefined;
	jsonProductos=JSON.parse(JSON.stringify(jsonProductos))
		totalColuma-=parseFloat( totalfi.split('$')[1])
	totalconimpuestos();
	console.log(renglonseleccionado.id)
	$("#" + renglonseleccionado.id).remove();

	element.disabled=true
}
var contadorfilas=0


function agregarRenglon(element){
	//estafuncion sirve para agregar un renglon de producto
	descuento.value=0
	renglonseleccionado=NaN
	botonborrar.disabled=true
	percepcion.value=0
	percepcion.disabled=true

	element.disabled=true

	totalFila=0
	console.log(producto.value, producto[producto.selectedIndex].innerHTML)
	console.log(cantidad.value)
	productosel=JSON.parse(producto.value)

	if (! listaProductos.has(productosel.id)  && cantidadpos() && porcentajepositivo(valor=descuento)){
		//jsonproductos guarda el producto y su cantidad basicamente guarda los renglones de la venta
		jsonProductos[productosel.representacion]=[producto.value, cantidadpos(),parseFloat(descuento.value)]

		var hilera = document.createElement("tr");
		//configuro id de la fila
		contadorfilas+=1
		hilera.id="fila"+contadorfilas.toString()
		
		


      

      agregarTd(hilera,producto[producto.selectedIndex].innerHTML)

      

var url = "http://"+location.host+Flask.url_for("VentasApi.obtenerprecio")
var data = {p: productosel.id, venta:true, cliente_condfrenteiva:JSON.parse(cliente.value).tipoclave,cliente:parseInt(JSON.parse(cliente.value).id)};
try {
	// statements

 fetch(url, {
  method: 'POST', // or 'PUT'
  body: JSON.stringify(data), // data can be `string` or {object}!
  headers:{
    'Content-Type': 'application/json'
  }
}).then(res => res.json())
.catch(error => { console.error('Error:', error)
	alert('Error:', error)
	element.disabled=true
	} )
.then(response =>{ console.log('Success:', response)
	

	console.log('Success:', response.message,response.message,'  ',typeof totalFila)
	
	descuento.value=0
	totalFila=cantidadpos()*(parseFloat(response.message)*( 1-descuento.value/100))
	agregarTd(hilera,response.message)
      agregarTd(hilera,cantidadpos())
      agregarTd(hilera, porcentajepositivo(descuento,true))
      agregarTd(hilera, productosel['iva'])
		agregarTd(hilera, "$" + totalFila.toFixed(2) )
	  tebody.appendChild(hilera);
      listaProductos.add(productosel.id);
      console.log(listaProductos)
      totalColuma += parseFloat(totalFila)
      let precio=parseFloat( response.message)
      jsonProductos[productosel.representacion]=[producto.value, cantidadpos(),precio,parseFloat(descuento.value),totalColuma]

      totalconimpuestos() 
      addRowHandlers()
      //busco el monto y si no esta desabiliado lo cargo en el 
      //primer monto de froma de pago
         let montos=document.getElementById('monto')
      if (!montos.disabled){
      		montos.value=totalhtml.value
      }

      element.disabled=false
      
})} catch(e) {
	// statements
	console.log(e);
	alert(e)
	element.disabled=true
}

	}else{
		alert("Producto Repetido o cantidad incorrecta")
		element.disabled=false
	}




}

function cancelar(){
	  var bool=confirm("Seguro de cancelar la venta?");
  if(bool){
    window.location.href ="http://"+location.host+Flask.url_for("VentaView.venta")//"http://localhost:8080/ventaview/venta/"
  }
}
	


function conectarVentaapi(jsonventa){
	var url = "http://"+location.host+Flask.url_for("VentasApi.realizarpedido_whatsapp")//"http://localhost:8080/api/v1/ventasapi/realizarventa/"
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
		alert("Venta Realizada Satisfactoriamente")
		window.location.href ="http://localhost.localdomain:8080/ventaview/venta/"//"http://localhost:8080/ventaview/venta/"
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
		jsonventa["metodos"]=arrayMetodos
			console.log('contado')
			for (var clave in jsonProductos){
			  // Controlando que json realmente tenga esa propiedad
			  if (jsonProductos.hasOwnProperty(clave)) {
			    // Mostrando en pantalla la clave junto a su valor
			    if(jsonProductos[clave]!= undefined && jsonProductos[clave]!=null ){
			    	console.log(" Producto  " + JSON.parse(jsonProductos[clave][0])['id'] , " Cantidad: "+ jsonProductos[clave][1])
					jsonventa["productos"].push({"producto":JSON.parse(jsonProductos[clave][0])['id'],"cantidad":jsonProductos[clave][1],
								"descuento": jsonProductos[clave][3]})
				}
			  }
			}
			jsonventa["cliente"]=parseInt(JSON.parse(cliente.value).id);
			jsonventa["total"]=parseFloat(total.value).toFixed(2);
			jsonventa["totalneto"]=parseFloat(totalneto.value).toFixed(2);
			jsonventa["totaliva"]=parseFloat(totaliva.value).toFixed(2);
			jsonventa["percepcion"]=parseFloat(percepcion.value).toFixed(2);
			jsonventa['activation_hash']=window.location.pathname.split("/")[window.location.pathname.split("/").length-1]
			//jsonventa["comprobante"]=parseFloat(comprobante.value).toFixed(2)
			//jsonventa["condicionfrenteiva"]=condicionfrenteiva.value

			//validar si la suma de los pagos no supera el total del la venta
			//validar si el total de los pagos no es inferior al total de la venta
			

			if (arrayMetodos.length>0 ){
				motototal=0
				for( i in arrayMetodos){

					if (typeof arrayMetodos[i] ==  "object"){
						motototal+=arrayMetodos[i].monto

					}
					
				}
				if (motototal==parseFloat(total.value)){
				conectarVentaapi(jsonventa);}
				else{
					if(motototal>parseFloat(total.value)){
						alert("La suma de los montos de las formas de pagos es mayor al total de la venta")
					}
					else{
					alert("La suma de los montos de las formas de pagos es menor al total de la venta")
					}
				}


			}
			else{
				alert("No se pudeo realizar la venta!!! \n Agregue al menos una Forma de Pago")
			}




boton.disabled=false

	}
function  verificarmonto(numero){
 
if (parseFloat(numero.value)>0){
	if (parseFloat(numero.value)>parseFloat(total.value)){
		return false
	}
	motototal=0
	for( i in arrayMetodos){

		if (typeof arrayMetodos[i] ==  "object"){
			motototal+=arrayMetodos[i].monto

		}
		
	}
	motototal+=parseFloat(numero.value)
	if(motototal>parseFloat(total.value)){

		return false
	}
	return numero.value
}else{
	return false 
}}

var numerodepago=0
var formadepagosborrados=0
var arrayMetodos=[]

function borrarFormadePago(element){
formadepagosborrados+=1
	ache3=document.createElement("h3")
	titulo =document.createTextNode("Borrado")
ache3.align='center';ache3.style.color="red"
	ache3.appendChild(titulo)
ache3.id="borrar"+element.id.split("borrarFormadePago")[1].toString()
element.parentNode.parentNode.appendChild(ache3)
console.log(element.id.split("borrarFormadePago")[1].toString());
for( i in arrayMetodos){


	try {
			if(arrayMetodos[i]["idpago"]==element.id.split("borrarFormadePago")[1].toString()){
		console.log(arrayMetodos[i]);
		arrayMetodos.splice(i, 1);
		//arrayMetodos.pop(i)
	}
	
	} catch(e) {
	
		console.log(e);
	}


}
$('#'+ element.parentNode.parentNode.parentNode.parentNode.parentNode.id +' *').prop('disabled',true);
//element.parentNode.parentNode.parentNode.parentNode.parentNode.disabled=true
}

function crearFormadePago(element){
	element.disabled=true
	let contado=false;
	if (arrayMetodos.length>0){
		for( i in arrayMetodos){
			if (typeof arrayMetodos[i] ==  "object"){
				if (arrayMetodos[i].metododePago=="1"){
					contado=true
				}
			}
			
		}
	}
	jsonMetodo={}
	if (numerodepago==0){
	montos=document.getElementById('monto')
	metododePago=metododePago
	
	creditos=document.getElementById('credito')
	companiaTarjetas=document.getElementById('companiaTarjeta')
	cuota=document.getElementById('cuotas')
	borraro=document.getElementById('borrarFormadePago')
	unmetodo=document.getElementById('unmetodo')
	if (!verificarmonto(montos) ){
		alert("Monto incorrecto")
		element.disabled=false
		return;
	}

		if (metododePago.value==1 ){
			if (contado){
				alert("Ya existe en metodo de pago contado")
				element.disabled=false
							return;
			}
				jsonMetodo["metododePago"]=metododePago.value;
				jsonMetodo["monto"]=parseFloat(montos.value) 
				$('#'+ unmetodo.id +' *').prop('disabled',true);
				document.getElementById(borraro.id).disabled=false
		}
		else{
			jsonMetodo["metododePago"]=metododePago.value;
					if(creditos.checked && parseInt(cuota.value)<=0){

							alert("Completar todos los datos de la Tarjeta")
							element.disabled=false

							return;
					}
					else{
						
							//alert("entro1")
								//jsonMetodo["numeroCupon"]=cupons.value;
								jsonMetodo["companiaTarjeta"]=companiaTarjetas.value;
								jsonMetodo["credito"]=creditos.checked
								jsonMetodo["cuotas"]=parseInt(cuota.value) 
								jsonMetodo["monto"]=parseFloat(montos.value) 
								$('#'+ unmetodo.id +' *').prop('disabled',true);

								document.getElementById(borraro.id).disabled=false
						


					}
		}
	}

	else{

	let metododePago1=document.getElementById('metodo'+ numerodepago.toString())

	let companiaTarjeta1=document.getElementById('companiaTarjeta'+ numerodepago.toString())
	let credito1=document.getElementById('credito'+ numerodepago.toString())
	let cuotas1=document.getElementById('cuotas'+ numerodepago.toString())
	let monto1=document.getElementById('monto'+ numerodepago.toString())

	if (!verificarmonto(monto1) ){
		alert("Monto incorrecto")
		element.disabled=false
		return;
	}
			if (metododePago1.value==1){
							if (contado){
				alert("Ya existe en metodo de pago contado")
				element.disabled=false
							return;
			}
					jsonMetodo["metododePago"]=metododePago1.value;
					jsonMetodo["monto"]=parseFloat(monto1.value) 

					
					

			}else {
					jsonMetodo["metododePago"]=metododePago1.value;
					if(credito1.checked && parseInt(cuotas1.value)<=0){

							alert("Completar todos los datos de la Tarjeta", jsonMetodo)
							element.disabled=false

							return;
					}
					else{
						
							//alert("entro1")
								//jsonMetodo["numeroCupon"]=cupon1.value;
								jsonMetodo["companiaTarjeta"]=companiaTarjeta1.value;
								jsonMetodo["credito"]=credito1.checked
								jsonMetodo["cuotas"]=parseInt(cuotas1.value) 
								jsonMetodo["monto"]=parseFloat(monto1.value) 


					}
			}

	}

arrayMetodos.push(jsonMetodo)
console.log(arrayMetodos)
jsonMetodo["idpago"]=""

alert("Forma de pago Creada Correctamente")
if (numerodepago>0){
	jsonMetodo["idpago"]=numerodepago
	unmetodo=document.getElementById('unmetodo'+ numerodepago.toString())
	let borrar=document.getElementById('borrarFormadePago'+ numerodepago.toString())
					$('#'+ unmetodo.id +' *').prop('disabled',true);
					document.getElementById(borrar.id).disabled=false
}



}


function agregarFormadePago(){

	faltante=document.getElementById('faltante')
	function sumaridclon(padre,id){
		let clonacion=padre.querySelector("#"+ id)
		clonacion.id=clonacion.id+numerodepago.toString()
	}
	motototal=0
	if(arrayMetodos.length + formadepagosborrados<numerodepago+1){
			alert("Para agregar una nueva forma de pago primero complete las anteriores")
			return;
		}
	if (arrayMetodos.length>0){

		for( i in arrayMetodos){

			if (typeof arrayMetodos[i] ==  "object"){
				motototal+=arrayMetodos[i].monto

			}
			
		}
	}
	numerodepago+=1

aclonar=document.getElementById("unmetodo").cloneNode(true);
metodoviejo=document.getElementById("unmetodo");
parentNodes=metodoviejo.parentNode

aclonar.id= aclonar.id+numerodepago.toString();
let collapse=aclonar.querySelector("#metodo")
collapse.id=collapse.id+numerodepago.toString()
let borrar=aclonar.querySelector(".select2-container")
parentNodes.insertBefore(aclonar, ultimoElemento.nextSibling);
borrar.remove()


if(aclonar.querySelector("#borrar")!=null){
aclonar.querySelector("#borrar").remove()

}

//sumaridclon(aclonar,"numeroCupon")
sumaridclon(aclonar,"companiaTarjeta")
sumaridclon(aclonar,"credito")
sumaridclon(aclonar,"cuotas")
sumaridclon(aclonar,"borrarFormadePago")
sumaridclon(aclonar,"agregarFormadePago")

let divtarjeta=aclonar.querySelector("#divtarjeta")
divtarjeta.id=divtarjeta.id+numerodepago.toString()
let monto=aclonar.querySelector("#monto")
monto.id=monto.id+numerodepago.toString()
monto.value=parseFloat(total.value)-motototal
faltante.value=monto.value
$('#'+ aclonar.id +' *').prop('disabled',false);
$(document).ready(function() { $("#"+ collapse.id).select2(); });
$(document).ready(function() { $("#"+ collapse.id).select2(); });
$('#'+ divtarjeta.id).collapse('hide')
$("#"+collapse.id).select2().val(1).trigger("change");
$("#"+"companiaTarjeta"+numerodepago.toString() ).select().val(1).trigger("change");
$("#"+ collapse.id).click(function() {

						if (collapse.value==2){
								//alert("Cargar Tarjeta")
								$('#'+ divtarjeta.id).collapse('show')
							}
						else{
							$('#'+ divtarjeta.id).collapse('hide')
						}

						})

ultimoElemento=aclonar
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
cliente.onchange= (event)=> {
console.log(JSON.parse(event.target.value).tipoclave=="Responsable Inscripto",event.target.value)
    if(JSON.parse(event.target.value).tipoclave=="Responsable Inscripto" && responsableinscripto){
    	    percepcion.disabled=true
    	    iva=true
	}else if (JSON.parse(event.target.value).tipoclave=="Monotributista" && responsableinscripto) {
		percepcion.disabled=true
		iva=false
	}else{
		percepcion.disabled=true
		iva=false
		percepcion.value=0
	}
	totalconimpuestos()
	

}
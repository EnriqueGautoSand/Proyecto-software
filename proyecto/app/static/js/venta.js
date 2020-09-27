var producto = document.getElementById('producto')
var cantidad = document.getElementById('cantidad')

function clicktr(element) {
  usertr=element
  var x=element.cells
  console.log(x[0].innerHTML)
 cantidad.innerHTML = x[0].innerHTML
user=x[0].innerHTML
}
var select2 =document.getElementById('s2id_autogen1_search')
select2.className="select2-selection select2-selection--single form-control input-sm"

var	tabla=document.createElement("table")
var tebody=document.createElement("tbody")
//var agregar= document.body.getElementsByClassName('row')[0].getElementById('agregar')
var fila =document.getElementById('agregar')
parentNodes=fila.parentNode
parentNodes.insertBefore(tabla, fila.nextSibling); 
teache= document.createElement("th")

titulo = document.createTextNode('Producto')
teache2= document.createElement("th")
titulo2 = document.createTextNode('Cantidad')
teache3= document.createElement("th")
titulo3 = document.createTextNode('SubTotal')
teache.appendChild(titulo)
teache2.appendChild(titulo2)
teache3.appendChild(titulo3)
teache3.align="center"
tabla.appendChild(teache)
tabla.appendChild(teache2)
tabla.appendChild(teache3)
teache.className="col-md-1 col-lg-1 col-sm-1"
tabla.className="table table-bordered table-hover"
var listaProductos = new Set();
var resp
var totalFila=0
var totalColuma=0
var totalhtml=document.getElementById("Total") 

function agregarRenglon(){
	totalFila=0
	console.log('cliekck')
	

	console.log(producto.value, producto[producto.selectedIndex].innerHTML)
	console.log(cantidad.value)
	if (! listaProductos.has(producto.value)  ){
	var hilera = document.createElement("tr");
	hilera.onclick="clicktr(this)"
	var celda = document.createElement("td");
	celda.className="col-md-1 col-lg-1 col-sm-1"
	var textoCelda = document.createTextNode(producto[producto.selectedIndex].innerHTML );
      celda.appendChild(textoCelda);
      var celda2 = document.createElement("td");
      celda2.className="col-md-1 col-lg-1 col-sm-1"
      var textoCelda2 = document.createTextNode(cantidad.value);
      celda2.appendChild(textoCelda2);
      celda2.align="center"
      hilera.appendChild(celda);
      hilera.appendChild(celda2);


var url = "http://localhost:8080/api/v1/exampleapi/method2/";
var data = {p: producto.value};

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
	celdsa.className="col-md-1 col-lg-1 col-sm-1"
	totalFila*=parseFloat(cantidad.value)
	var textoCelda3 = document.createTextNode("$" + totalFila );
	celdsa.appendChild(textoCelda3)
	celdsa.align="center"
	hilera.appendChild(celdsa);
	  tabla.appendChild(hilera);
      listaProductos.add(producto.value);
      console.log(listaProductos)
      totalColuma += totalFila
      totalhtml.value=totalColuma
})



	}else{
		alert("Prodcto Repetido")
	}




}



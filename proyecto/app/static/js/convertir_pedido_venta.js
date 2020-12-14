function convertirpedidoventa(element,pk){
	element.disabled=true
console.log(pk)
comprobante=document.getElementById("comprobanteventa")

formasdepago=document.getElementsByClassName("formadepago")
listaformasTarjeta=[]
for(forma in formasdepago){

if (formasdepago[forma].id!=undefined){console.log(formasdepago[forma].id)
id=formasdepago[forma].id
listaformasTarjeta.push({idformapago:id.split('formapago')[1],numerocupon:formasdepago[forma].value})
console.log(listaformasTarjeta)
}

}
	var url = location.origin+Flask.url_for("VentasApi.convertir_pedido_venta")
var data = {'pk':pk,'comprobante':comprobante.value,'formasdepago':listaformasTarjeta};

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
	if (response.message.ok== "ok"){
		alert("Pedido convertido a Venta Realizada Satisfactoriamente")
		window.location.href ="http://localhost:8080/ventareportes/show/"+response.message.id.toString()//"http://localhost:8080/ventaview/venta/"
		//window.location.href = "http://localhost:8080/ventareportes/show/"+response.message.idventa.toString()
	}else {
		alert(response.message)
	}})
}
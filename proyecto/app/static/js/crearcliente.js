var data

function crearsion(){
	var data={}

	var url = "http://"+location.host+Flask.url_for("Clienteapi.crear")
	if( tipopersona.value==1){
		if (validaCuit(documento.value) && tipodocumento.value==2  ){
			if (nombre.value!="" && apellido.value != ""){
				data={
					"tipopersona":tipopersona.value,
					"condiva":tipoclave.value,
					"tipodocumento":tipodocumento.value,
					"nombre":nombre.value,
					"apellido":apellido.value
				}

			}else{
					alert("Nombre o Apellido incompletos")
					return;
			}

		}else{
			if (tipodocumento.value!=2){
					data={
						"tipopersona":tipopersona.value,
						"condiva":tipoclave.value,
						"tipodocumento":tipodocumento.value,
						"documento":documento.value,
						"nombre":nombre.value,
						"apellido":apellido.value
					}
			}else{
				alert("Cuit no valido")
				return;
			}
	}

	}
	else{
			if (validaCuit(cuit.value)){
				data={
					"tipopersona":tipopersona.value,
					"condiva":tipoclavejuridica.value,
					"cuit":cuit.value,
					"denominacion":denominacion.value,
					"razonsocial":razonsocial.value
				}
			}else{
			alert("Cuit no valido")
			return;
			}
		
	}
	if(direccion.value!= ""){
	data["direccion"]=direccion.value
	data["localidad"]=localidad.value}
	else{
		alert("Direccion no debe estar vacia")
		return 1;
	}
 fetch(url, {
  method: 'POST', // or 'PUT'
  body: JSON.stringify(data), // data can be `string` or {object}!
  headers:{
    'Content-Type': 'application/json'
  }
}).then(res => res.json())
.catch(error => { console.error('Error:', error)
	alert('Error:', error)
	} )
.then(response =>{ console.log('Success:', response)
	if (response.message.status=="sucess"){
		alert("Cliente Creado Satisfactoriamente")
		window.location.href="http://"+location.host+Flask.url_for("ClientesView.show", {"id": response.idcliente})
	}
	})

}

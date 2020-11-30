//hago un get de que tipo de cond frente al iva esta el negocio
var responsableinscripto
var monotributista

function condfrenteivanego(){
return fetch(location.origin+Flask.url_for("VentasApi.apiusuario"))
    .then(res => res.json())
    .then(res => {console.log(res.message["cond frente iva"])
    monotributista=(res.message["cond frente iva"]=="Monotributista")
    responsableinscripto=(res.message["cond frente iva"]=="Responsable Inscripto")
    if (!responsableinscripto){
percepcion.disabled=true
percepcion.value=0}
else{
	percepcion.disabled=false
}

    if (JSON.parse(proveedor.value).tipoclave=="Responsable Inscripto" ){
percepcion.disabled=false}


	})


}
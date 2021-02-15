//hago un get de que tipo de cond frente al iva esta el negocio
var responsableinscripto
var monotributista

function condfrenteivanego(){
return fetch(location.origin+Flask.url_for("VentasApi.apiusuario"))
    .then(res => res.json())
    .then(res => {console.log(res.message["cond frente iva"])
    monotributista=(res.message["cond frente iva"]=="Monotributista")
    responsableinscripto=(res.message["cond frente iva"]=="Responsable Inscripto")



	})


}
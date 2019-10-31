/** Semulacro de Parceeeaallllll */

class Carpeta {
	var archivos = #{}
	method contieneArchivo(nombre){
		return archivos.any(
			{archivo => archivo.seLlama(nombre)}
		)
	}
	
	method crear(nombreArchivo){
		archivos.add(new Archivo(nombre = nombreArchivo))
	}
	
	method eliminar(nombreArchivo){
		archivos.remove(self.archivo(nombreArchivo))
	}
	
	method agregaAlFinal(nombreArchivo,texto){
		self.archivo(nombreArchivo).agregarAlFinal(texto)
	}
	
	method sacarAlFinalDe(nombreArchivo,texto){
		self.archivo(nombreArchivo).sacarDelFinal(texto)
	}
	
	method archivo(nombreArchivo){
		return archivos.find({archivo => archivo.seLlama(nombreArchivo)})
	}
	
	method estaVacia() = archivos.isEmpty()
}

class Archivo {
	var nombre
	var contenido = ""
	method seLlama(n){
		return n == nombre
	}
	method agregarAlFinal(texto){
		contenido = contenido + texto
	}
	method sacarDelFinal(texto){
		if (!contenido.endsWith(texto)){
			self.error("No puedo sacar ese texto del final")
		}
		contenido = contenido.take(contenido.size()-texto.size())
	}
	method contenido() = contenido
}

class Commit {
	var cambios = []
	var descripcion = ""
	method aplicarCambiosEn(carpeta){
		cambios.forEach({cambio => cambio.aplicarEn(carpeta)})
	}
	
	method modificaArchivo(nombreArchivo){
		return cambios.any({cambio => cambio.modificaArchivo(nombreArchivo)})
	}
	
	// Un commit revert y uno normal SE COMPORTAN IGUAL, asi que
	// son de la misma clase. Lo unico que necesito es un lugar donde
	// crearlo. La responsabilidad de crear un revert de un commit
	// esta aqui, en el commit. Le pido al commit su revert.
	method revert(){
		return new Commit(
			descripcion = "REVERT " + descripcion,
			cambios = self.cambiosOpuestos().reverse()			
		)
	}
	
	method cambiosOpuestos(){
		return cambios.map({cambio => cambio.opuesto()})
	}
}

class Cambio {
	// Las superclases DEBEN tener
	// comportamiento (métodos)
	// sino no eran necesarias
	var nombreArchivo
	
	// Esto es un template method. Cualquier cambio siempre
	// tiene 2 partes: verificar si puede realizarse, y realizarse.
	// Cada subclase define como verifica y como se aplica de posta.
	method aplicarEn(carpeta){
		self.chequeo(carpeta)
		self.postaAplicarEn(carpeta)
	}
	
	method postaAplicarEn(carpeta)
	
	// tira error ó no hace nada
	method chequeo(carpeta){
		if(!carpeta.contieneArchivo(nombreArchivo)){
			self.error("No está el archivo")
		}
	}
	
	method modificaArchivo(nombre){
		return nombreArchivo == nombre
	}
}

class Agregar inherits Cambio {
	var texto
	method postaAplicarEn(carpeta){
		carpeta.agregaAlFinal(nombreArchivo,texto)
	}
	method opuesto(){
		return new Sacar(nombreArchivo = nombreArchivo, texto = texto)
	}
}

class Sacar inherits Cambio  {
	var texto
	method postaAplicarEn(carpeta){
		carpeta.sacarAlFinalDe(nombreArchivo,texto)
	}
	method opuesto(){
		return new Agregar(nombreArchivo = nombreArchivo, texto = texto)
	}
}

class Crear inherits Cambio {
	method chequeo(carpeta){
		if(carpeta.contieneArchivo(nombreArchivo)){
			self.error("Ya está el archivo")
		}
	}
	
	method postaAplicarEn(carpeta){
		carpeta.crear(nombreArchivo)
	}
	
	method opuesto(){
		return new Eliminar(nombreArchivo = nombreArchivo)
	}
}


class Eliminar inherits Cambio  {
	method postaAplicarEn(carpeta){
		carpeta.eliminar(nombreArchivo)
	}
	
	method opuesto(){
		return new Crear(nombreArchivo = nombreArchivo)
	}
}


class Branch {
	var commits = []
	var colaboradores = #{}
	
	method checkoutEn(carpeta){
		commits.forEach({commit => commit.aplicarCambiosEn(carpeta)})
	}
	method logDe(nombreArchivo){
		return commits.filter({commit => commit.modificaArchivo(nombreArchivo)})
	}
	method agregarCommit(c){
		commits.add(c)
	}
	method estaEntreColaboradores(alguien){
		return colaboradores.contains(alguien)
	}
}

class Usuario {
	// usamos composición y no herencia
	// porque necesito poder cambiar de tipo
	var tipoUsuario = tipoComun 
	method crearBranch(colaboradores){
		return new Branch(colaboradores = colaboradores + self)
	}
	method commitearA(branch,commit){
		if(!tipoUsuario.puedeCommitearEn(branch,self)){
			self.error("AHHHHH NO PODES COMMITEAR NO TENES PERMISOS")
		}
		branch.agregarCommit(commit)
	}
	
	method cambiarPermisosA(victima,permisoNuevo){
		if (!tipoUsuario.puedeCambiarPermisos()){
			self.error("PARATE DE MANOS! NO podes cambiar permisos")
		}
		victima.tipoUsuario(permisoNuevo)
	}
}

object tipoComun {
	method puedeCommitearEn(branch,usuario){
		return branch.estaEntreColaboradores(usuario)
	}
	method puedeCambiarPermisos(){
		return false
	}
}
object tipoBot {
	method puedeCommitearEn(branch,usuario){
		return branch.tieneMasDe10Commits()
	}
	method puedeCambiarPermisos(){
		return false
	}
}
object tipoAdmin {
	method puedeCommitearEn(branch,usuario){
		return true
	}
	method puedeCambiarPermisos(){
		return false
	}
}

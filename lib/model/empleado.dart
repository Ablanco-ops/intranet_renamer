
class Empleado {
  final String id;
  final String nombre;
 
  List<String> files = [];
  Empleado({
    required this.id,
    required this.nombre,

  });

  @override
  String toString() {
    return 'Archivo(id: $id, nombre: $nombre, files: $files)';
  }
}

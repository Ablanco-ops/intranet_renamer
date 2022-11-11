
class Empleado {
  final String id;
  final String nombre;
  final String apellidos;
  List<String> files = [];
  Empleado({
    required this.id,
    required this.nombre,
    required this.apellidos,
  });

  @override
  String toString() {
    return 'Archivo(id: $id, nombre: $nombre, apellidos: $apellidos, files: $files)';
  }
}

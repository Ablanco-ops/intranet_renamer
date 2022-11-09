// ignore_for_file: public_member_api_docs, sort_constructors_first
class Empleado {
  final String id;
  final String nombre;
  final String apellidos;
  String? filePath;
  Empleado({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.filePath,
  });

  @override
  String toString() {
    return 'Archivo(id: $id, nombre: $nombre, apellidos: $apellidos, filePath: $filePath)';
  }
}

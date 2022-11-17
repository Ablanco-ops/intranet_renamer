// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:archive/archive_io.dart';

import 'model/empleado.dart';

class ZipProcessor {
  final String outPath;
  final String inPath;
  const ZipProcessor({
    required this.outPath,
    required this.inPath,
  });

  Future extractFile(String filepath) async {
    final bytes = ZipDecoder().decodeBytes(await File(filepath).readAsBytes());
    for (var file in bytes.files) {
      if (file.isFile) {
        final data = file.content as List<int>;
        await File('$inPath/${file.name}').create(recursive: true);
        await File('$inPath/${file.name}').writeAsBytes(data);
      }
    }
  }

  Future<List<Empleado>> generateZip(Map<String, dynamic> data) async {
    final lista = data['listaEmpleados'];
    final tipo = data['tipo'];
    final fecha = '${DateTime.now().month}_${DateTime.now().year}';
    final encoder = ZipFileEncoder();
    encoder.create('$outPath\\${tipo}_$fecha.zip');

    for (Empleado empleado in lista) {
      for (String archivo in empleado.files) {
        final extension = archivo.split('.').last.toLowerCase();
        String outFile =
            '$inPath\\${tipo}_${empleado.id}_${empleado.nombre}.$extension';

        int index = 1;
        while (await File(outFile).exists()) {
          outFile =
              '$inPath\\${tipo}_${empleado.id}_${empleado.nombre}_$index.$extension';
          index++;
        }
        await File(archivo).rename(outFile);
        empleado.files.remove(archivo);
        empleado.files.add(outFile);
        encoder.addFile(File(outFile));
      }
    }
    encoder.close();
    return lista;
  }
}

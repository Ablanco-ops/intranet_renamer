// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

import 'model/empleado.dart';

class ZipProcessor {
  final String outPath;
  final String inPath;
  const ZipProcessor({
    required this.outPath,
    required this.inPath,
  });
  // Future extractFile(String filepath) async {

  //   final inputStream = InputFileStream(filepath);
  //   final archive = ZipDecoder().decodeBuffer(inputStream);

  //   for (var file in archive.files) {
  //     if (file.isFile) {
  //       final outputStream = OutputFileStream('$inPath/${file.name}');
  //       file.writeContent(outputStream);
  //       outputStream.close();
  //     }
  //   }
  // }
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

  Future generateZip(Map<String, dynamic> data) async {
    final lista = data['listaEmpleados'];
    final tipo = data['tipo'];
    final fecha = '${DateTime.now().month}_${DateTime.now().year}';
    final encoder = ZipFileEncoder();
    encoder.create('$outPath\\${tipo}_$fecha.zip');
    // final archive = Archive();

    for (Empleado empleado in lista) {
      for (String archivo in empleado.files) {
        final extension = archivo.split('.').last;
        final outFile =
            '$inPath\\${tipo}_${empleado.id}_${empleado.nombre}.$extension';
        await File(archivo).rename(outFile);
        // encoder.addFile(File(archivo),
        //     '$outPath\\${tipo}_${empleado.id}_${empleado.apellidos}, ${empleado.nombre}.$extension');
        // final bytes = await File(outFile).readAsBytes();
        // archive.addFile(ArchiveFile(outFile, bytes.length, bytes));
        // zi
        encoder.addFile(File(outFile));
      }
    }
    encoder.close();
    // encoder.zipDirectory(Directory(inPath), filename: '${tipo}_$fecha.zip');
  }
}

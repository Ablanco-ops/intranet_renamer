// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:intranet_renamer/model/empleado.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfExtractor {
  final String inputPath;
  const PdfExtractor({
    required this.inputPath,
  });

  Future<String?> _obtainId(String path) async {
    final doc = PdfDocument(inputBytes: await File(path).readAsBytes());
    String text = PdfTextExtractor(doc).extractText();
    // print(text);
    RegExp reg = RegExp(r'[XYZ]?([0-9]{7,8})([A-Z])');
    RegExpMatch? id = reg.firstMatch(text);
    final nombre = text.split('\n').first;
    print(nombre);
    doc.dispose();
    if (id != null) {
      print(id[0]);
      return id[0];
    } else {
      return null;
    }
  }

  Future<List<Empleado>> addDoc(List<Empleado> lista) async {
    final Directory inputDir = Directory(inputPath);
    for (var entity in inputDir.listSync()) {
      print(entity.path);
      if (entity is File &&
          (entity.path.endsWith('.pdf') || entity.path.endsWith('.PDF'))) {
        final id = await _obtainId(entity.path);
        final matched = lista.firstWhereOrNull((element) => element.id == id);
        if (matched != null) {
          matched.files.add(entity.path);
          print('matched $id');
        }
      }
    }
    return lista;
  }
}

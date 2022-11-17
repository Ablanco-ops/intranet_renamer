import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<String?> pickDirectory() async {
  final String? result = await FilePicker.platform.getDirectoryPath();
  return result;
}

Future<String> pickFile(String extension) async {
  final result =
      await FilePicker.platform.pickFiles(allowedExtensions: [extension]);
  if (result != null) {
    return result.files.single.path!;
  } else {
    return '';
  }
}

Future clearDirectory(String path) async {
  final directory = Directory(path);
  for (FileSystemEntity entity in directory.listSync()) {
    await entity.delete(recursive: true);
  }
}

void customSnack(String texto, BuildContext context) {
  SnackBar snackBar = SnackBar(content: Text(texto));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Map<String, int> mapaColumnas() {
  List lista = List.generate(26, (index) => String.fromCharCode(index + 65));
  Map<String, int> mapa = {};
  int index = 0;
  for (var letra in lista) {
    mapa[letra] = index;
    index++;
  }
  return mapa;
}

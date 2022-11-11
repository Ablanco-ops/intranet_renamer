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



void customSnack(String texto, BuildContext context) {
  SnackBar snackBar = SnackBar(content: Text(texto));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

import 'package:flutter/cupertino.dart';
import 'package:intranet_renamer/common.dart';

class Excepciones {
  static void incorrectFile(BuildContext context) {
    customSnack('Archivo incorrecto', context);
  }

  static void tooManyFiles(BuildContext context) {
    customSnack('Arrastre un solo archivo', context);
  }

  static void decodingError(BuildContext context) {
    customSnack('Error al descomprimir archivo', context);
  }

  static void readingPdfError(BuildContext context) {
    customSnack('Error al leer documentos', context);
  }

  static void renameError(BuildContext context) {
    customSnack('Error al renombrar documentos', context);
  }

  static void excelReadError(BuildContext context) {
    customSnack('Error al leer excel de empleados', context);
  }
}

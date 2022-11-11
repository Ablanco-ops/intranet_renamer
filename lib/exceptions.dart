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
}

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intranet_renamer/common.dart';
import 'package:intranet_renamer/preferences.dart';
import 'package:intranet_renamer/zip_processor.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../model/empleado.dart';

class DataProvider extends ChangeNotifier {
  String _outputPath = '';
  String _inputPath = '';
  String _excelPath = '';
  bool preferenciasCargadas = false;
  int _colId = 0;
  int _colNombre = 1;
  int _colApellidos = 2;
  List<Empleado> _listaEmpleados = [];
  bool dragging = false;
  bool processing = false;
  int numDoc = 0;

  List<Empleado> get listaEmpleados => _listaEmpleados;
  String get outputPath => _outputPath;
  String get inputPath => _inputPath;
  String get excelPath => _excelPath;

  Map<String, String> mapaTipos = {'Nóminas': 'NOMI', 'Certificados': 'CERT'};
  String tipoElegido = 'Nóminas';

  void typeChange(String key) {
    tipoElegido = key;
    notifyListeners();
  }

  void getPreferences() async {
    if (preferenciasCargadas == false) {
      _inputPath = await Preferences.getPreferences('inputPath');
      _outputPath = await Preferences.getPreferences('outputPath');
      _excelPath = await Preferences.getPreferences('excelPath');
      notifyListeners();
      preferenciasCargadas = true;
    }
  }

  void setInputPath() async {
    _inputPath = await pickDirectory() ?? '';
    await Preferences.setPreferences('inputPath', _inputPath);
    notifyListeners();
  }

  void setOutputPath() async {
    _outputPath = await pickDirectory() ?? '';
    await Preferences.setPreferences('outputPath', _outputPath);
    notifyListeners();
  }

  Future setExcelPath() async {
    final result = await pickFile('xlsx');
    if (result != '') {
      _excelPath = result;
    }
    Preferences.setPreferences('excelPath', _excelPath);

    notifyListeners();
  }

  void setListaEmpleados(List<Empleado> lista) {
    _listaEmpleados = lista;
    for (Empleado empleado in lista) {
      if (empleado.files.isNotEmpty) {
        numDoc++;
      }
    }
    notifyListeners();
  }

  Future readExcel() async {
    listaEmpleados.clear();
    final data = await File(_excelPath).readAsBytes();
    final excel = Excel.decodeBytes(data);
    final sheet = excel.sheets[excel.getDefaultSheet()];
    for (var row in sheet!.rows) {
      String id = '';
      String nombre = '';
      String apellidos = '';
      int valido = 0;
      print(row);
      if (row[_colId] != null) {
        if (row[_colId]!.value != null) {
          id = row[_colId]!.value.toString();
          print(id);
          valido++;
        }
        if (row[_colNombre]!.value != null) {
          nombre = row[_colNombre]!.value.toString();
          valido++;
          print(nombre);
        }
        if (row[_colApellidos]!.value != null) {
          apellidos = row[_colApellidos]!.value.toString();
          valido++;
          print(apellidos);
        }
      }
      if (valido == 3) {
        _listaEmpleados
            .add(Empleado(id: id, nombre: nombre, apellidos: apellidos));
      }
    }
    notifyListeners();
  }

  Future getArchives() async {
    final file = await pickFile('zip');
    final zip = ZipProcessor(inPath: _inputPath, outPath: _outputPath);
    await zip.extractFile(file);
  }

  void draggingFile(bool value) {
    dragging = value;

    notifyListeners();
  }

  void showProgressIndicator() {
    processing = !processing;
    notifyListeners();
  }

  // Future draggedFile(DropDoneDetails file, BuildContext context) async {
  //   draggingFile(false);

  //   if (file.files.length != 1) {
  //     Excepciones.tooManyFiles(context);
  //   } else if (!file.files[0].name.endsWith('zip')) {
  //     Excepciones.incorrectFile(context);
  //   } else {
  //     try {
  //       await extractFile(file.files[0].path, inputPath);
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  // }

}

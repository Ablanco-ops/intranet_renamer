import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intranet_renamer/common.dart';
import 'package:intranet_renamer/preferences.dart';
import 'package:intranet_renamer/zip_processor.dart';

import '../model/empleado.dart';

class DataProvider extends ChangeNotifier {
  String _outputPath = '';
  String _inputPath = '';
  String _excelPath = '';
  bool preferenciasCargadas = false;

  List<Empleado> _listaEmpleados = [];
  bool dragging = false;
  bool processing = false;
  int docAsociados = 0;

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

  Map<String, int> mapaExcelNombre = mapaColumnas();
  String colNombre = 'A';
  void colNombreChange(String key) {
    colNombre = key;
    Preferences.setPreferences('colNombre', key);
    notifyListeners();
  }

  Map<String, int> mapaExcelId = mapaColumnas();
  String colId = 'A';
  void colIdChange(String key) {
    colId = key;
    Preferences.setPreferences('colId', key);
    notifyListeners();
  }

  void getPreferences() async {
    if (preferenciasCargadas == false) {
      _inputPath = await Preferences.getPreferences('inputPath');
      _outputPath = await Preferences.getPreferences('outputPath');
      _excelPath = await Preferences.getPreferences('excelPath');
      colId = await Preferences.getPreferences('colId');
      colNombre = await Preferences.getPreferences('colNombre');
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
    docAsociados = 0;
    for (Empleado empleado in lista) {
      if (empleado.files.isNotEmpty) {
        docAsociados++;
      }
    }
    notifyListeners();
  }

  Future<bool> readExcel() async {
    listaEmpleados.clear();
    bool hayEntradas = false;
    final data = await File(_excelPath).readAsBytes();
    final excel = Excel.decodeBytes(data);
    final sheet = excel.sheets[excel.getDefaultSheet()];
    for (var row in sheet!.rows) {
      String id = '';
      String nombre = '';
      int valido = 0;
      print(row);
      if (row[mapaExcelId[colId]!] != null) {
        if (row[mapaExcelId[colId]!]!.value != null) {
          id = row[mapaExcelId[colId]!]!.value.toString();
          print(id);
          valido++;
        }
        if (row[mapaExcelNombre[colNombre]!]!.value != null) {
          nombre = row[mapaExcelNombre[colNombre]!]!.value.toString();
          valido++;
          print(nombre);
        }
      }
      if (valido == 2) {
        _listaEmpleados.add(Empleado(id: id, nombre: nombre));
        hayEntradas = true;
      }
    }
    notifyListeners();
    return hayEntradas;
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

  int pdfNumber = 0;
  void countWorkingFiles() {
    final dir = Directory(inputPath);
    pdfNumber = 0;
    for (var entity in dir.listSync()) {
      if (entity is File) {
        final extension = entity.path.split('.').last;
        if (extension == 'pdf' || extension == 'PDF') {
          pdfNumber++;
          notifyListeners();
        }
      }
    }
  }

  bool isExcelExpanded = false;
  void expandExcel() {
    isExcelExpanded = !isExcelExpanded;
    notifyListeners();
  }
}

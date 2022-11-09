import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:intranet_renamer/common.dart';
import 'package:intranet_renamer/preferences.dart';

import '../model/Empleado.dart';

class DataProvider extends ChangeNotifier {
  String _outputPath = '';
  String _inputPath = '';
  String _excelPath = '';
  bool preferenciasCargadas = false;
  int _colId = 0;
  int _colNombre = 1;
  int _colApellidos = 2;
  List<Empleado> listaEmpleados = [];

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

    _readExcel();
    notifyListeners();
  }

  Future _readExcel() async {
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
        listaEmpleados
            .add(Empleado(id: id, nombre: nombre, apellidos: apellidos));
      }
    }
    notifyListeners();
  }

  Future getArchives() async {
    final file = await pickFile('zip');
    await extractFile(file, _inputPath);

  }
}

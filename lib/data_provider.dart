import 'package:flutter/cupertino.dart';
import 'package:intranet_renamer/common.dart';
import 'package:intranet_renamer/preferences.dart';

class DataProvider extends ChangeNotifier {
  String _outputPath = '';
  String _inputPath = '';
  bool preferenciasCargadas = false;

  String get outputPath => _outputPath;
  String get inputPath => _inputPath;

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
}

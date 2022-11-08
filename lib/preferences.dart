import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future setPreferences(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
  }

  static Future<String> getPreferences(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getString(key)??'';
  }
}

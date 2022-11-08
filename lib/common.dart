import 'package:file_picker/file_picker.dart';

Future<String?> pickDirectory() async {
  final String? result = await FilePicker.platform.getDirectoryPath();
  return result;
}

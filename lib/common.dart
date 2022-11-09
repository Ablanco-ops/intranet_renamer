import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';

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

Future extractFile(String filepath, String outPath) async {
  final inputStream = InputFileStream(filepath);
  final archive = ZipDecoder().decodeBuffer(inputStream);

  for (var file in archive.files) {
    if (file.isFile) {
      final outputStream = OutputFileStream('$outPath/${file.name}');
      file.writeContent(outputStream);
      outputStream.close();
    }
  }
}

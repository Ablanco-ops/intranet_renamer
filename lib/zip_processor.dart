// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:archive/archive_io.dart';

class ZipProcessor {
  final String outPath;
  final String inPath;
  const ZipProcessor({
    required this.outPath,
    required this.inPath,
  });
  Future extractFile(String filepath) async {
    final inputStream = InputFileStream(filepath);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    for (var file in archive.files) {
      if (file.isFile) {
        final outputStream = OutputFileStream('$inPath/${file.name}');
        file.writeContent(outputStream);
        outputStream.close();
      }
    }
  }
}

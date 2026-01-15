import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ImageCapture {
  static Future<File> savePng(Uint8List bytes, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name.png');
    await file.writeAsBytes(bytes);
    return file;
  }
}

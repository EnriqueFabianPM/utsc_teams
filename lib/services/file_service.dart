import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileService {
  /// Selecciona .doc/.docx/.pdf y devuelve la ruta original elegida.
  Future<String?> pickDocument() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx', 'pdf'],
      withData: false,
    );
    if (res == null || res.files.isEmpty) return null;
    return res.files.single.path;
  }

  /// Copia el archivo a /Documents de la app y devuelve la nueva ruta.
  Future<String> saveCopyToAppDir(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = p.basename(sourcePath);
    final safeName = name.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final dest = p.join(dir.path, 'entregas', safeName);
    await Directory(p.dirname(dest)).create(recursive: true);
    await File(sourcePath).copy(dest);
    return dest;
  }

  /// Abre un archivo con la app del sistema.
  Future<void> openFile(String path) async {
    await OpenFilex.open(path);
  }
}

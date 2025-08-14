import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileService {
  /// Abre el diálogo y permite seleccionar doc/docx/pdf.
  /// Devuelve la ruta temporal elegida, o null si se cancela.
  Future<String?> pickDocument() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx', 'pdf'],
      withData: false,
    );
    if (res == null || res.files.isEmpty) return null;
    return res.files.single.path;
  }

  /// Copia el archivo a la carpeta de documentos de la app.
  /// Devuelve la NUEVA ruta copiada (recomendada para guardar en la BD).
  Future<String> saveCopyToAppDir(String originalPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(originalPath);
    final dstPath = p.join(dir.path, 'entregas', fileName);

    final dstDir = Directory(p.dirname(dstPath));
    if (!await dstDir.exists()) {
      await dstDir.create(recursive: true);
    }

    final srcFile = File(originalPath);
    final newFile = await srcFile.copy(dstPath);
    return newFile.path;
  }

  /// Intenta abrir el archivo con una app instalada (Word, lector PDF, etc.)
  Future<void> openFile(String path) async {
    await OpenFilex.open(path);
  }

  /// Borra un archivo del storage de la app (opcional para limpiar).
  Future<void> deleteLocal(String path) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}

import 'package:flutter/material.dart';
import 'app.dart';
import 'database/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB(); // para que el import NO quede "unused" y la DB esté lista
  runApp(const UtscTeamsApp());
}

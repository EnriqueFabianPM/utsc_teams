import 'package:flutter/material.dart';
import 'app.dart';

// Ajusta esta import a tu helper real:
import 'database/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // === Elige la que aplique a TU helper (deja UNA y comenta la otra) ===
  // 1) Si tienes un singleton con .instance/.database:
  // await DBHelper.instance.database;

  // 2) Si tu helper es clase simple que abre en el ctor:
  // final db = DBHelper(); await db.database;

  // 3) Si tu helper abre on-demand en el primer query, puedes omitir init.

  runApp(const UtscTeamsApp());
}

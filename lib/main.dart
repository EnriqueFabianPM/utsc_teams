import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTSC Teams',
      theme: ThemeData(
        useMaterial3: true,           // para FilledButton y estilos modernos
        colorSchemeSeed: Colors.blue, // paleta primaria
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';

// Estudiante
import 'screens/estudiante/estudiante_home.dart';
import 'screens/estudiante/calificaciones_estudiante.dart';
import 'screens/estudiante/horario_estudiante.dart';

// Maestro
import 'screens/maestro/maestro_home.dart';
import 'screens/maestro/entregas_tarea.dart';

class UtscTeamsApp extends StatelessWidget {
  const UtscTeamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTSC Teams',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/estudiante/home',
      routes: {
        '/estudiante/home'   : (_) => const EstudianteHome(),
        '/estudiante/calif'  : (_) => const CalificacionesEstudiantePage(),
        '/estudiante/horario': (_) => const HorarioEstudiantePage(),

        '/maestro/home'      : (_) => const MaestroHome(),
        '/maestro/entregas'  : (_) => const EntregasTareaPage(),
      },
    );
  }
}

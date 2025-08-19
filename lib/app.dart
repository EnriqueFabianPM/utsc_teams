import 'package:flutter/material.dart';

// ===== IMPORTS a pantallas que YA tienes =====
import 'screens/estudiante/estudiante_home.dart';
import 'screens/estudiante/tareas_estudiante.dart';
import 'screens/estudiante/subir_trabajo.dart';
import 'screens/maestro/maestro_home.dart';
import 'screens/maestro/publicar_tarea.dart';
import 'screens/maestro/entregas_tarea.dart';
import 'screens/admin/carreras_crud.dart';
import 'screens/admin/semestres_crud.dart';
import 'screens/admin/grupos_crud.dart';
import 'screens/admin/usuarios_crud.dart';
import 'screens/admin/horarios_crud.dart';

// ===== NUEVAS =====
import 'screens/estudiante/calificaciones_estudiante.dart';
import 'screens/estudiante/horario_estudiante.dart';

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

      // Si aún no tienes login, deja EstudianteHome para demo
      initialRoute: '/estudiante/home',

      routes: {
        // Estudiante
        '/estudiante/home'    : (_) => const EstudianteHome(),
        '/estudiante/tareas'  : (_) => const TareasEstudiante(),
        '/estudiante/entregar': (_) => const SubirTrabajoPage(),
        '/estudiante/calif'   : (_) => const CalificacionesEstudiantePage(), // NUEVA
        '/estudiante/horario' : (_) => const HorarioEstudiantePage(),        // NUEVA
      
        // Maestro
        '/maestro/home'       : (_) => const MaestroHome(),
        '/maestro/publicar'   : (_) => const PublicarTareaPage(),
        '/maestro/entregas'   : (_) => const EntregasTareaPage(),            // MEJORADA (reemplazo)
        
        // Admin (las que ya tienes)
        '/admin/carreras'     : (_) => const CarrerasCrudPage(),
        '/admin/semestres'    : (_) => const SemestresCrudPage(),
        '/admin/grupos'       : (_) => const GruposCrudPage(),
        '/admin/usuarios'     : (_) => const UsuariosCrudPage(),
        '/admin/horarios'     : (_) => const HorariosCrudPage(),
      },

      // Si necesitas pasar argumentos a alguna ruta en el futuro:
      onGenerateRoute: (settings) {
        // ejemplo para detalle con args
        return null;
      },
    );
  }
}

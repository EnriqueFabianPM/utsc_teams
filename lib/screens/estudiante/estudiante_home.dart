import 'package:flutter/material.dart';

class EstudianteHome extends StatelessWidget {
  const EstudianteHome({super.key});

  Widget _card(BuildContext ctx, {required IconData icon, required String title, required String route}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(ctx, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio (Estudiante)')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _card(context, icon: Icons.check_circle, title: 'Calificaciones', route: '/estudiante/calif'),
          _card(context, icon: Icons.schedule,     title: 'Horario',        route: '/estudiante/horario'),
          // Cuando tengamos TareasEstudiante sin params requeridos, reactivamos:
          // _card(context, icon: Icons.assignment,    title: 'Tareas',         route: '/estudiante/tareas'),
        ],
      ),
    );
  }
}

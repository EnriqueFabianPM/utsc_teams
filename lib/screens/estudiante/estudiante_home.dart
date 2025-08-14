import 'package:flutter/material.dart';
import '../../database/models/usuario.dart';
import 'subir_trabajo.dart';
import 'horario_estudiante.dart';
import 'calificaciones_estudiante.dart';

class EstudianteHome extends StatelessWidget {
  final Usuario user;
  const EstudianteHome({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel Estudiante - ${user.nombre}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Ver horario del grupo"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HorarioEstudiante(user: user))),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text("Subir trabajo (Word/PDF)"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubirTrabajo(estudiante: user))),
          ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: const Text("Ver calificaciones y feedback"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalificacionesEstudiante(user: user))),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

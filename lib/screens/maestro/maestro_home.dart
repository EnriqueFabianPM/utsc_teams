import 'package:flutter/material.dart';
import '../../database/models/usuario.dart';
import 'calificar_trabajo.dart';
import 'horario_maestro.dart';
import 'calificaciones_maestro.dart';

class MaestroHome extends StatelessWidget {
  final Usuario user;
  const MaestroHome({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panel Maestro - ${user.nombre}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Ver mi horario"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HorarioMaestro(user: user))),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check),
            title: const Text("Calificar entregas"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalificarTrabajo(maestro: user))),
          ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: const Text("Mis calificaciones (editar)"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalificacionesMaestro(maestro: user))),
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

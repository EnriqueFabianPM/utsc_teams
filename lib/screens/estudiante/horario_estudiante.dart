import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/horario.dart';
import '../../database/models/usuario.dart';

class HorarioEstudiante extends StatelessWidget {
  final Usuario user;
  const HorarioEstudiante({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi horario')),
      body: FutureBuilder<List<Horario>>(
        future: db.horariosPorGrupo(user.grupoId!),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('Sin horarios asignados'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final h = items[i];
              return ListTile(
                leading: const Icon(Icons.schedule),
                title: Text('${h.materia} • ${h.dia}'),
                subtitle: Text('${h.horaInicio} - ${h.horaFin}  • maestro ${h.maestroId}'),
              );
            },
          );
        },
      ),
    );
  }
}

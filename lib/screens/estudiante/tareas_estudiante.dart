import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/tarea.dart';
import '../../database/models/usuario.dart';
import 'subir_trabajo.dart'; // lo usaremos como SubirEntrega

class TareasEstudiante extends StatelessWidget {
  final Usuario alumno;
  const TareasEstudiante({super.key, required this.alumno});

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas del grupo')),
      body: FutureBuilder<List<Tarea>>(
        future: db.getTareasPorGrupo(alumno.grupoId!),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('Sin tareas publicadas'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final t = items[i];
              return ListTile(
                leading: const Icon(Icons.assignment),
                title: Text(t.titulo),
                subtitle: Text((t.descripcion ?? '').isEmpty
                    ? (t.fechaEntrega == null ? '' : 'Entrega: ${t.fechaEntrega}')
                    : '${t.descripcion}${t.fechaEntrega == null ? '' : '\nEntrega: ${t.fechaEntrega}'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SubirTrabajo( // reutilizamos tu pantalla, ahora como “entrega”
                      estudiante: alumno,
                      tarea: t, // ⬅️ nuevo parámetro
                    ),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/trabajo.dart';
import '../../database/models/usuario.dart';

class CalificacionesEstudiante extends StatelessWidget {
  final Usuario user;
  const CalificacionesEstudiante({super.key, required this.user});

  Color _gradeColor(double? g) {
    if (g == null) return Colors.grey;
    if (g >= 90) return Colors.green;
    if (g >= 70) return Colors.orange;
    return Colors.red;
    }

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis calificaciones')),
      body: FutureBuilder<List<Trabajo>>(
        future: db.getTrabajosPorEstudiante(user.id!),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('No hay trabajos todavía'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final t = items[i];
              return ListTile(
                title: Text(t.titulo),
                subtitle: Text(t.retroalimentacion == null || t.retroalimentacion!.isEmpty
                    ? 'Sin feedback'
                    : 'Feedback: ${t.retroalimentacion}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _gradeColor(t.calificacion).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gradeColor(t.calificacion)),
                  ),
                  child: Text(
                    t.calificacion == null ? '—' : t.calificacion!.toStringAsFixed(1),
                    style: TextStyle(color: _gradeColor(t.calificacion), fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

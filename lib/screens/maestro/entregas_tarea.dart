import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/tarea.dart';
import '../../database/models/trabajo.dart';

class EntregasTarea extends StatelessWidget {
  final Tarea tarea;
  const EntregasTarea({super.key, required this.tarea});

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();

    Future<void> _editar(BuildContext ctx, Trabajo t) async {
      final gradeCtrl = TextEditingController(text: t.calificacion?.toStringAsFixed(1) ?? '');
      final fbCtrl = TextEditingController(text: t.retroalimentacion ?? '');
      final ok = await showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          title: Text('Calificar • ${t.titulo}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: 'Calificación (0–100)'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: fbCtrl, decoration: const InputDecoration(labelText: 'Feedback (opcional)'), maxLines: 3),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
          ],
        ),
      ) ?? false;
      if (!ok) return;

      final grade = double.tryParse(gradeCtrl.text.trim());
      if (grade == null || grade < 0 || grade > 100) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Ingresa una calificación válida (0–100)')));
        return;
      }
      await db.calificarTrabajo(t.id!, grade.toString(), feedback: fbCtrl.text.trim().isEmpty ? null : fbCtrl.text.trim());
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Calificación guardada ✅')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Entregas • ${tarea.titulo}')),
      body: FutureBuilder<List<Trabajo>>(
        future: db.getEntregasPorTarea(tarea.id!),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('Sin entregas aún'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final t = items[i];
              return ListTile(
                leading: Icon(t.calificacion == null ? Icons.pending_actions : Icons.check_circle,
                    color: t.calificacion == null ? Colors.orange : Colors.green),
                title: Text(t.titulo),
                subtitle: Text('Alumno: ${t.estudianteNombre ?? t.estudianteId}'),
                trailing: Text(t.calificacion == null ? '—' : t.calificacion!.toStringAsFixed(1)),
                onTap: () => _editar(context, t),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../database/db_helper.dart';
import '../../services/file_service.dart';
import '../../database/models/usuario.dart';
import '../../database/models/trabajo.dart';

class CalificarTrabajo extends StatefulWidget {
  final Usuario maestro;
  const CalificarTrabajo({super.key, required this.maestro});

  @override
  State<CalificarTrabajo> createState() => _CalificarTrabajoState();
}

class _CalificarTrabajoState extends State<CalificarTrabajo> {
  final _db = DBHelper();
  late Future<List<Trabajo>> _future;

  @override
  void initState() {
    super.initState();
    _future = _db.getTrabajosPorMaestro(widget.maestro.id!);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _db.getTrabajosPorMaestro(widget.maestro.id!);
    });
  }

  Future<void> _editar(Trabajo t) async {
    final gradeCtrl =
        TextEditingController(text: t.calificacion?.toStringAsFixed(1) ?? '');
    final fbCtrl =
        TextEditingController(text: t.retroalimentacion ?? '');

    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Calificar • ${t.titulo}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: gradeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Calificación (0–100)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fbCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Feedback (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Guardar')),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    await _db.calificarTrabajo(
      t.id!,
      gradeCtrl.text.trim(),
      feedback: fbCtrl.text.trim().isEmpty ? null : fbCtrl.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificación guardada ✅')),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar entregas')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Trabajo>>(
          future: _future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('Sin entregas todavía'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = items[i];
                return ListTile(
                  leading: Icon(
                    t.calificacion == null
                        ? Icons.pending_actions
                        : Icons.check_circle,
                    color: t.calificacion == null
                        ? Colors.orange
                        : Colors.green,
                  ),
                  title: Text(t.titulo),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alumno: ${t.estudianteNombre ?? t.estudianteId}  •  Grupo ${t.grupoId}',
                      ),
                      if (t.archivoPath != null && t.archivoPath!.isNotEmpty)
                        Text(
                          'Archivo: ${t.archivoPath}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if ((t.retroalimentacion ?? '').isNotEmpty)
                        Text(
                          'Feedback: ${t.retroalimentacion}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Text(
                    t.calificacion == null
                        ? '—'
                        : t.calificacion!.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: t.calificacion == null
                          ? Colors.grey
                          : Colors.green,
                    ),
                  ),
                  // Long press para abrir el archivo adjunto
                  onLongPress: () async {
                    if (t.archivoPath != null && t.archivoPath!.isNotEmpty) {
                      await FileService().openFile(t.archivoPath!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('La entrega no tiene archivo adjunto'),
                        ),
                      );
                    }
                  },
                  onTap: () => _editar(t),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

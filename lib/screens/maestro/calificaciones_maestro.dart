import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/trabajo.dart';
import '../../database/models/usuario.dart';

class CalificacionesMaestro extends StatefulWidget {
  final Usuario maestro;
  const CalificacionesMaestro({super.key, required this.maestro});

  @override
  State<CalificacionesMaestro> createState() => _CalificacionesMaestroState();
}

class _CalificacionesMaestroState extends State<CalificacionesMaestro>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final DBHelper _db = DBHelper();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  Future<List<Trabajo>> _pendientes() async {
    final list = await _db.getTrabajosPorMaestro(widget.maestro.id!);
    return list.where((t) => t.calificacion == null).toList();
  }

  Future<List<Trabajo>> _calificados() async {
    final list = await _db.getTrabajosPorMaestro(widget.maestro.id!);
    return list.where((t) => t.calificacion != null).toList();
  }

  void _editar(Trabajo t) async {
    final gradeCtrl =
        TextEditingController(text: t.calificacion?.toStringAsFixed(1) ?? '');
    final fbCtrl = TextEditingController(text: t.retroalimentacion ?? '');
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Editar calificación • ${t.titulo}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: gradeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Calificación (0–100)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                    controller: fbCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Feedback')),
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

    final grade = double.tryParse(gradeCtrl.text.trim());
    if (grade == null || grade < 0 || grade > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una calificación válida (0–100)')),
      );
      return;
    }

    _db.calificarTrabajo(t.id!, grade.toString(), feedback: fbCtrl.text.trim());
    setState(() {}); // refresca
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Calificación actualizada')));
  }

  Widget _list(Future<List<Trabajo>> future) {
    return FutureBuilder(
      future: future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data as List<Trabajo>;
        if (items.isEmpty) return const Center(child: Text('Nada por aquí'));
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final t = items[i];
            return ListTile(
              title: Text(t.titulo),
              subtitle: Text(
                  'Alumno: ${t.estudianteNombre ?? t.estudianteId} • Grupo ${t.grupoId}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.calificacion == null
                        ? '—'
                        : t.calificacion!.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          t.calificacion == null ? Colors.grey : Colors.green,
                    ),
                  ),
                  if ((t.retroalimentacion ?? '').isNotEmpty)
                    const Text('Con feedback', style: TextStyle(fontSize: 11)),
                ],
              ),
              onTap: () => _editar(t),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis calificaciones'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Pendientes'), Tab(text: 'Calificadas')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _list(_pendientes()),
          _list(_calificados()),
        ],
      ),
    );
  }
}

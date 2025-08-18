import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/db_helper.dart';

class EntregasTareaPage extends StatefulWidget {
  const EntregasTareaPage({super.key});
  @override State<EntregasTareaPage> createState() => _EntregasTareaPageState();
}

class _EntregasTareaPageState extends State<EntregasTareaPage> with SingleTickerProviderStateMixin {
  bool _loading = true;
  List<_EnvioRow> _pendientes = [];
  List<_EnvioRow> _calificadas = [];

  // TODO: id real del maestro logueado
  static const int currentTeacherId = 2;

  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  Future<Database> _db() async {
    final helper = DBHelper();
    return helper.db!;
  }

  Future<void> _load() async {
    final db = await _db();

    // PENDIENTES: sin calificación
    final rowsPend = await db.rawQuery('''
      SELECT t.id AS trabajo_id, t.titulo, t.descripcion, t.archivo_path,
             u.nombre AS alumno, ta.titulo AS tarea
      FROM trabajos t
      JOIN usuarios u ON u.id = t.estudiante_id
      LEFT JOIN tareas ta ON ta.id = t.tarea_id
      WHERE t.maestro_id = ? AND t.calificacion IS NULL
      ORDER BY t.id DESC
    ''', [currentTeacherId]);

    // CALIFICADAS: con calificación
    final rowsCalif = await db.rawQuery('''
      SELECT t.id AS trabajo_id, t.titulo, t.descripcion, t.archivo_path,
             u.nombre AS alumno, ta.titulo AS tarea,
             t.calificacion AS puntos, t.retroalimentacion AS retro
      FROM trabajos t
      JOIN usuarios u ON u.id = t.estudiante_id
      LEFT JOIN tareas ta ON ta.id = t.tarea_id
      WHERE t.maestro_id = ? AND t.calificacion IS NOT NULL
      ORDER BY t.id DESC
    ''', [currentTeacherId]);

    setState(() {
      _pendientes  = rowsPend.map(_EnvioRow.fromMap).toList();
      _calificadas = rowsCalif.map(_EnvioRow.fromMap).toList();
      _loading = false;
    });
  }

  Future<void> _calificar(_EnvioRow row) async {
    final puntosCtrl = TextEditingController();
    final retroCtrl  = TextEditingController();
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text('Calificar: ${row.tarea ?? row.titulo} (${row.alumno})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: puntosCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Puntos (0-100)')),
            TextField(controller: retroCtrl, decoration: const InputDecoration(labelText: 'Retroalimentación (opcional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final puntos = double.tryParse(puntosCtrl.text);
              final db = await _db();
              await db.update('trabajos',
                  {'calificacion': puntos, 'retroalimentacion': retroCtrl.text},
                  where: 'id=?', whereArgs: [row.trabajoId]);
              if (mounted) Navigator.pop(context);
              await _load();
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    });
  }

  Widget _list(List<_EnvioRow> data, {bool pendientes = true}) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (data.isEmpty) return Center(child: Text(pendientes ? 'Sin pendientes' : 'Sin calificadas'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final it = data[i];
        final titulo = it.tarea ?? it.titulo ?? 'Entrega';
        return Card(
          child: ListTile(
            leading: Icon(pendientes ? Icons.hourglass_bottom : Icons.check_circle),
            title: Text(titulo),
            subtitle: Text('${it.alumno}${it.descripcion != null && it.descripcion!.isNotEmpty ? '\n${it.descripcion}' : ''}'),
            isThreeLine: it.descripcion != null && it.descripcion!.isNotEmpty,
            trailing: pendientes
                ? FilledButton(onPressed: () => _calificar(it), child: const Text('Calificar'))
                : Text(it.puntos?.toStringAsFixed(1) ?? '-'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entregas'),
          bottom: const TabBar(tabs: [ Tab(text: 'Pendientes'), Tab(text: 'Calificadas') ]),
        ),
        body: TabBarView(children: [
          _list(_pendientes, pendientes: true),
          _list(_calificadas, pendientes: false),
        ]),
      ),
    );
  }
}

class _EnvioRow {
  final int trabajoId;
  final String? titulo;   // de trabajos
  final String? tarea;    // de tareas
  final String alumno;
  final String? descripcion;
  final String? archivoPath;
  final double? puntos;
  final String? retro;

  _EnvioRow({
    required this.trabajoId,
    required this.alumno,
    this.titulo,
    this.tarea,
    this.descripcion,
    this.archivoPath,
    this.puntos,
    this.retro,
  });

  factory _EnvioRow.fromMap(Map<String, Object?> m) => _EnvioRow(
    trabajoId  : m['trabajo_id'] as int,
    titulo     : m['titulo'] as String?,
    tarea      : m['tarea'] as String?,
    descripcion: m['descripcion'] as String?,
    archivoPath: m['archivo_path'] as String?,
    alumno     : (m['alumno'] ?? '') as String,
    puntos     : (m['puntos'] as num?)?.toDouble(),
    retro      : m['retro'] as String?,
  );
}

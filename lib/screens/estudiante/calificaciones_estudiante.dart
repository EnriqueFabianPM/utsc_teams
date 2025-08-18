import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/db_helper.dart';

class CalificacionesEstudiantePage extends StatefulWidget {
  const CalificacionesEstudiantePage({super.key});

  @override
  State<CalificacionesEstudiantePage> createState() => _CalificacionesEstudiantePageState();
}

class _CalificacionesEstudiantePageState extends State<CalificacionesEstudiantePage> {
  bool _loading = true;
  List<_ItemCalif> _items = [];

  // TODO: id real del alumno logueado
  static const int currentUserId = 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<Database> _getDb() async {
    final helper = DBHelper();
    return helper.db!;
  }

  Future<void> _load() async {
    final db = await _getDb();

    final rows = await db.rawQuery('''
      SELECT
        ta.titulo AS titulo_tarea,
        t.titulo  AS titulo_envio,
        t.retroalimentacion AS retro,
        t.calificacion AS puntos
      FROM trabajos t
      LEFT JOIN tareas ta ON ta.id = t.tarea_id
      WHERE t.estudiante_id = ?
      ORDER BY t.id DESC
    ''', [currentUserId]);

    setState(() {
      _items = rows.map((m) => _ItemCalif(
        tituloTarea: (m['titulo_tarea'] ?? 'Tarea') as String,
        tituloEnvio: (m['titulo_envio'] ?? '') as String,
        puntos     : (m['puntos'] as num?)?.toDouble(),
        retro      : (m['retro'] ?? '') as String,
      )).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis calificaciones')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('Aún no tienes calificaciones'))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final it = _items[i];
          final estado = it.puntos == null ? 'Pendiente' : 'Calificado: ${it.puntos!.toStringAsFixed(1)}';
          final subt = [
            if (it.tituloEnvio.isNotEmpty) 'Envío: ${it.tituloEnvio}',
            estado,
            if (it.retro.isNotEmpty) 'Retro: ${it.retro}',
          ].join('\n');
          return Card(
            child: ListTile(
              leading: Icon(it.puntos == null ? Icons.hourglass_bottom : Icons.check_circle),
              title: Text(it.tituloTarea),
              subtitle: Text(subt),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

class _ItemCalif {
  final String tituloTarea;
  final String tituloEnvio;
  final double? puntos;
  final String retro;
  _ItemCalif({required this.tituloTarea, required this.tituloEnvio, required this.puntos, required this.retro});
}

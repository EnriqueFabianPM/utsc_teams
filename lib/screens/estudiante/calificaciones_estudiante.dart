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

  // TODO: reemplazar por el id del usuario logueado (de tu sesión)
  static const int currentUserId = 3; // Ana Alumna demo

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await _getDb();

    // JOIN: trabajos (envíos) + calificaciones + tareas
    final rows = await db.rawQuery('''
      SELECT
        t.titulo AS titulo_tarea,
        tr.fecha_envio AS fecha_envio,
        c.puntos AS puntos,
        c.retroalimentacion AS retro
      FROM trabajos tr
      LEFT JOIN calificaciones c ON c.envio_id = tr.id
      LEFT JOIN tareas t ON t.id = tr.tarea_id
      WHERE tr.estudiante_id = ?
      ORDER BY tr.fecha_envio DESC
    ''', [currentUserId]);

    setState(() {
      _items = rows.map((m) => _ItemCalif(
        tituloTarea: (m['titulo_tarea'] ?? 'Tarea') as String,
        fechaEnvio : (m['fecha_envio'] ?? '') as String,
        puntos     : (m['puntos'] as num?)?.toDouble(),
        retro      : (m['retro'] ?? '') as String,
      )).toList();
      _loading = false;
    });
  }

  Future<Database> _getDb() async {
    // Ajusta esto a tu helper real si es distinto
    // 1) Singleton:
    // return DBHelper.instance.database;
    // 2) Clase:
    final helper = DBHelper();
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    return await helper.database;
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
          return Card(
            child: ListTile(
              title: Text(it.tituloTarea),
              subtitle: Text('Entregado: ${_fmt(it.fechaEnvio)}\n$estado'
                  '${it.retro.isNotEmpty ? '\nRetro: ${it.retro}' : ''}'),
              leading: Icon(it.puntos == null ? Icons.hourglass_bottom : Icons.check_circle),
            ),
          );
        },
      ),
    );
  }

  String _fmt(String iso) {
    if (iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _ItemCalif {
  final String tituloTarea;
  final String fechaEnvio;
  final double? puntos;
  final String retro;
  _ItemCalif({required this.tituloTarea, required this.fechaEnvio, required this.puntos, required this.retro});
}

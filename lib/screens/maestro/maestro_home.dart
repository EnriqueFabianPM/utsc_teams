import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/db_helper.dart';

class MaestroHome extends StatefulWidget {
  const MaestroHome({super.key});
  @override State<MaestroHome> createState() => _MaestroHomeState();
}

class _MaestroHomeState extends State<MaestroHome> {
  bool _loading = true;
  int _pendientes = 0;
  int _calificadas = 0;

  // TODO: usa el id del maestro logueado
  static const int currentTeacherId = 2;

  @override
  void initState() {
    super.initState();
    _cargarConteos();
  }

  Future<Database> _db() async {
    final helper = DBHelper();
    return helper.db!;
  }

  Future<void> _cargarConteos() async {
    final db = await _db();

    // Pendientes = trabajos del maestro sin calificación
    final pend = await db.rawQuery('''
      SELECT COUNT(*) AS cnt
      FROM trabajos
      WHERE maestro_id = ? AND calificacion IS NULL
    ''', [currentTeacherId]);

    // Calificadas = trabajos del maestro con calificación
    final calif = await db.rawQuery('''
      SELECT COUNT(*) AS cnt
      FROM trabajos
      WHERE maestro_id = ? AND calificacion IS NOT NULL
    ''', [currentTeacherId]);

    setState(() {
      _pendientes  = (pend.first['cnt'] as int?) ?? 0;
      _calificadas = (calif.first['cnt'] as int?) ?? 0;
      _loading = false;
    });
  }

  Widget _tile(BuildContext ctx, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _loading
        ? 'Cargando...'
        : 'Pendientes: $_pendientes  •  Calificadas: $_calificadas';

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio (Maestro)')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _tile(context,
            icon: Icons.post_add,
            title: 'Publicar tarea',
            onTap: () => Navigator.pushNamed(context, '/maestro/publicar'),
          ),
          _tile(context,
            icon: Icons.inbox,
            title: 'Revisar entregas',
            subtitle: resumen,
            onTap: () => Navigator.pushNamed(context, '/maestro/entregas'),
          ),
        ],
      ),
    );
  }
}

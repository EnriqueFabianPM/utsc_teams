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
    final pend = await db.rawQuery('SELECT COUNT(*) AS cnt FROM trabajos WHERE maestro_id=? AND calificacion IS NULL',[currentTeacherId]);
    final calif = await db.rawQuery('SELECT COUNT(*) AS cnt FROM trabajos WHERE maestro_id=? AND calificacion IS NOT NULL',[currentTeacherId]);
    setState(() {
      _pendientes  = (pend.first['cnt'] as int?) ?? 0;
      _calificadas = (calif.first['cnt'] as int?) ?? 0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _loading ? 'Cargando...' : 'Pendientes: $_pendientes  •  Calificadas: $_calificadas';
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio (Maestro)')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(child: ListTile(
            leading: const Icon(Icons.inbox),
            title: const Text('Revisar entregas'),
            subtitle: Text(resumen),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/maestro/entregas'),
          )),
        ],
      ),
    );
  }
}

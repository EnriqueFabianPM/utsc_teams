import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/db_helper.dart';

class HorarioEstudiantePage extends StatefulWidget {
  const HorarioEstudiantePage({super.key});

  @override
  State<HorarioEstudiantePage> createState() => _HorarioEstudiantePageState();
}

class _HorarioEstudiantePageState extends State<HorarioEstudiantePage> {
  bool _loading = true;
  List<_Slot> _slots = [];

  // TODO: usa el id real del usuario logueado
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

    // grupo del estudiante (si tu esquema usa grupo_id en usuarios, puedes leerlo directo)
    final gRow = await db.rawQuery(
        'SELECT grupo_id FROM usuarios WHERE id=? LIMIT 1', [currentUserId]);
    if (gRow.isEmpty || gRow.first['grupo_id'] == null) {
      setState(() { _slots = []; _loading = false; });
      return;
    }
    final grupoId = gRow.first['grupo_id'] as int;

    final rows = await db.rawQuery('''
      SELECT dia, materia, hora_inicio, hora_fin
      FROM horarios
      WHERE grupo_id=?
      ORDER BY dia, hora_inicio
    ''', [grupoId]);

    setState(() {
      _slots = rows.map((m) => _Slot(
        dia: (m['dia'] ?? '') as String,
        inicio: (m['hora_inicio'] ?? '') as String,
        fin: (m['hora_fin'] ?? '') as String,
        materia: (m['materia'] ?? '') as String,
      )).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final byDay = <String, List<_Slot>>{};
    for (final s in _slots) { byDay.putIfAbsent(s.dia, () => []).add(s); }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi horario')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _slots.isEmpty
          ? const Center(child: Text('Sin horario asignado'))
          : ListView(
        children: byDay.keys.map((dia) {
          final daySlots = byDay[dia]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(dia, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...daySlots.map((s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(s.materia),
                    subtitle: Text('${s.inicio} - ${s.fin}'),
                  ),
                ),
              )),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Slot {
  final String dia, inicio, fin, materia;
  _Slot({required this.dia, required this.inicio, required this.fin, required this.materia});
}

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
    // Ajusta a tu helper real
    final helper = DBHelper();
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    return await helper.database;
  }

  Future<void> _load() async {
    final db = await _getDb();

    // 1) grupo del estudiante (asumiendo tabla grupo_miembro con rol_grupo=2)
    final gRow = await db.rawQuery(
        'SELECT grupo_id FROM grupo_miembro WHERE usuario_id=? AND rol_grupo=2 LIMIT 1',
        [currentUserId]
    );
    if (gRow.isEmpty) {
      setState(() { _slots = []; _loading = false; });
      return;
    }
    final grupoId = gRow.first['grupo_id'] as int;

    // 2) horario del grupo
    final rows = await db.rawQuery('''
      SELECT h.dia_semana, h.hora_inicio, h.hora_fin, h.aula, c.nombre AS curso
      FROM horarios h
      JOIN cursos c ON c.id = h.curso_id
      WHERE h.grupo_id=?
      ORDER BY h.dia_semana, h.hora_inicio
    ''', [grupoId]);

    setState(() {
      _slots = rows.map((m) => _Slot(
        dia: m['dia_semana'] as int,
        inicio: (m['hora_inicio'] ?? '') as String,
        fin: (m['hora_fin'] ?? '') as String,
        aula: (m['aula'] ?? '') as String,
        curso:(m['curso'] ?? '') as String,
      )).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final byDay = <int, List<_Slot>>{};
    for (final s in _slots) { byDay.putIfAbsent(s.dia, () => []).add(s); }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi horario')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _slots.isEmpty
          ? const Center(child: Text('Sin horario asignado'))
          : ListView(
        children: List.generate(7, (i) => i+1).map((dia) {
          final daySlots = byDay[dia] ?? [];
          if (daySlots.isEmpty) {
            return ListTile(
              title: Text(_nombreDia(dia), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('—'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(_nombreDia(dia), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...daySlots.map((s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(s.curso),
                    subtitle: Text('${s.inicio} - ${s.fin}${s.aula.isNotEmpty ? '  •  ${s.aula}' : ''}'),
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

  String _nombreDia(int d) {
    switch (d) {
      case 1: return 'Lunes';
      case 2: return 'Martes';
      case 3: return 'Miércoles';
      case 4: return 'Jueves';
      case 5: return 'Viernes';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '—';
    }
  }
}

class _Slot {
  final int dia;
  final String inicio, fin, aula, curso;
  _Slot({required this.dia, required this.inicio, required this.fin, required this.aula, required this.curso});
}

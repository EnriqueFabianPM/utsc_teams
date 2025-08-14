import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/usuario.dart';

class HorarioMaestro extends StatelessWidget {
  final Usuario user;
  const HorarioMaestro({super.key, required this.user});

  static const List<String> _ordenDias = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  static final Map<String, int> _idx = {
    for (var i = 0; i < _ordenDias.length; i++) _ordenDias[i]: i
  };

  Map<String, List<Map<String, dynamic>>> _groupByDay(List<Map<String, dynamic>> items) {
    items.sort((a, b) {
      final ai = _idx[a['dia']] ?? 99;
      final bi = _idx[b['dia']] ?? 99;
      if (ai != bi) return ai.compareTo(bi);
      return (a['hora_inicio'] as String).compareTo(b['hora_inicio'] as String);
    });

    final map = <String, List<Map<String, dynamic>>>{};
    for (final h in items) {
      final d = (h['dia'] as String?) ?? '';
      map.putIfAbsent(d, () => []).add(h);
    }

    final ordered = <String, List<Map<String, dynamic>>>{};
    for (final d in _ordenDias) {
      if (map.containsKey(d)) ordered[d] = map[d]!;
    }
    for (final k in map.keys) {
      if (!ordered.containsKey(k)) ordered[k] = map[k]!;
    }
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi horario')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.horariosDetalladosPorMaestro(user.id!),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final raw = snap.data ?? [];
          if (raw.isEmpty) {
            return const Center(child: Text('Sin horarios asignados'));
          }

          final grouped = _groupByDay(List<Map<String, dynamic>>.from(raw));
          final sections = grouped.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sections.fold<int>(0, (sum, e) => sum + 1 + e.value.length),
            itemBuilder: (_, index) {
              var cursor = 0;
              for (final e in sections) {
                if (index == cursor) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
                    child: Text(
                      e.key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }
                cursor += 1;
                final localIdx = index - cursor;
                if (localIdx < e.value.length) {
                  final h = e.value[localIdx];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(h['materia'].toString()),
                      subtitle: Text(
                        '${h['hora_inicio']} – ${h['hora_fin']}  • Grupo: ${h['grupo_nombre']}',
                      ),
                    ),
                  );
                }
                cursor += e.value.length;
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

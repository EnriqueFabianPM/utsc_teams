import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';
import '../../../database/models/horario.dart';

class HorariosCrud extends StatefulWidget {
  const HorariosCrud({super.key});
  @override
  State<HorariosCrud> createState() => _HorariosCrudState();
}

class _HorariosCrudState extends State<HorariosCrud> {
  final db = DBHelper();
  Future<List<Map<String, dynamic>>> _loadAll() => db.db!.rawQuery('''
    SELECT h.id, h.grupo_id, h.maestro_id, h.dia, h.hora_inicio, h.hora_fin, h.materia,
           g.nombre AS grupo, u.nombre AS maestro
    FROM horarios h
    JOIN grupos g   ON g.id = h.grupo_id
    JOIN usuarios u ON u.id = h.maestro_id
    ORDER BY g.nombre, h.dia, h.hora_inicio
  ''');

  List<Map<String, dynamic>> _grupos = [];
  List<Map<String, dynamic>> _maestros = [];

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    _grupos = await db.getGrupos();
    final maestros = await db.getUsuarios(rol: 'maestro');
    _maestros = maestros.map((m) => {'id': m.id, 'nombre': m.nombre}).toList();
    setState(() {});
  }

  Future<void> _openForm({Map<String, dynamic>? row}) async {
    int? grupoId   = row?['grupo_id'] as int?;
    int? maestroId = row?['maestro_id'] as int?;
    String dia     = (row?['dia'] as String?) ?? 'Lun';
    final matCtrl  = TextEditingController(text: row?['materia']?.toString() ?? '');
    final hiCtrl   = TextEditingController(text: row?['hora_inicio']?.toString() ?? '08:00');
    final hfCtrl   = TextEditingController(text: row?['hora_fin']?.toString() ?? '09:30');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(row == null ? 'Nuevo horario' : 'Editar horario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: grupoId,
                items: _grupos.map((g) => DropdownMenuItem(value: g['id'] as int, child: Text(g['nombre'].toString()))).toList(),
                onChanged: (v) => grupoId = v,
                decoration: const InputDecoration(labelText: 'Grupo'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: maestroId,
                items: _maestros.map((m) => DropdownMenuItem(value: m['id'] as int, child: Text(m['nombre'].toString()))).toList(),
                onChanged: (v) => maestroId = v,
                decoration: const InputDecoration(labelText: 'Maestro'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: dia,
                items: const ['Lun','Mar','Mie','Jue','Vie','Sab'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => dia = v ?? 'Lun',
                decoration: const InputDecoration(labelText: 'Día'),
              ),
              const SizedBox(height: 12),
              TextField(controller: matCtrl, decoration: const InputDecoration(labelText: 'Materia')),
              const SizedBox(height: 12),
              TextField(controller: hiCtrl, decoration: const InputDecoration(labelText: 'Hora inicio (HH:mm)')),
              const SizedBox(height: 12),
              TextField(controller: hfCtrl, decoration: const InputDecoration(labelText: 'Hora fin (HH:mm)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (ok == true && grupoId != null && maestroId != null && matCtrl.text.trim().isNotEmpty) {
      final h = Horario(
        id: row?['id'] as int?,
        grupoId: grupoId!,
        dia: dia,
        materia: matCtrl.text.trim(),
        horaInicio: hiCtrl.text.trim(),
        horaFin: hfCtrl.text.trim(),
        maestroId: maestroId!,
      );
      if (h.id == null) {
        await db.insertHorario(h);
      } else {
        await db.updateHorario(h);
      }
      setState(() {}); // refrescar
    }
  }

  Future<void> _delete(int id) async {
    await db.deleteHorario(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horarios (CRUD)')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadAll(),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final data = snap.data ?? [];
          if (data.isEmpty) return const Center(child: Text('Sin horarios'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = data[i];
              return ListTile(
                title: Text('${r['grupo']} · ${r['materia']}'),
                subtitle: Text('${r['dia']}  ${r['hora_inicio']}–${r['hora_fin']}  · ${r['maestro']}'),
                trailing: Wrap(spacing: 8, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(row: r)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(r['id'] as int)),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

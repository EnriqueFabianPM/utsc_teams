import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';

class GruposCrud extends StatefulWidget {
  const GruposCrud({super.key});
  @override
  State<GruposCrud> createState() => _GruposCrudState();
}

class _GruposCrudState extends State<GruposCrud> {
  final db = DBHelper();
  late Future<List<Map<String, dynamic>>> _data;
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _semestres = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _data = db.getGrupos();
    db.getCarreras().then((v) => setState(() => _carreras = v));
    db.getSemestres().then((v) => setState(() => _semestres = v));
    setState(() {});
  }

  Future<void> _openForm({int? id, String? nombre}) async {
    final nameCtrl = TextEditingController(text: nombre ?? '');
    int? cId;
    int? sId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Nuevo Grupo' : 'Editar Grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del grupo')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: cId,
              items: _carreras.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['nombre'].toString()))).toList(),
              onChanged: (v) => cId = v,
              decoration: const InputDecoration(labelText: 'Carrera'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: sId,
              items: _semestres.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['nombre'].toString()))).toList(),
              onChanged: (v) => sId = v,
              decoration: const InputDecoration(labelText: 'Semestre'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (ok == true && nameCtrl.text.trim().isNotEmpty && cId != null && sId != null) {
      if (id == null) {
        await db.createGrupo(nameCtrl.text.trim(), cId!, sId!);
      } else {
        await db.updateGrupo(id, nameCtrl.text.trim(), cId!, sId!);
      }
      _reload();
    }
  }

  Future<void> _delete(int id) async {
    await db.deleteGrupo(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos (CRUD)')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _data,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final data = snap.data ?? [];
          if (data.isEmpty) return const Center(child: Text('Sin grupos'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final g = data[i];
              return ListTile(
                title: Text(g['nombre'].toString()),
                subtitle: Text('Carrera: ${g['carrera']} · Semestre: ${g['semestre']}'),
                trailing: Wrap(spacing: 8, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(id: g['id'] as int, nombre: g['nombre'] as String)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(g['id'] as int)),
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

import 'package:flutter/material.dart';

typedef OnCreate = Future<void> Function(String text);
typedef OnUpdate = Future<void> Function(int id, String text);
typedef OnDelete = Future<void> Function(int id);

class SimpleCrudPage extends StatefulWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> Function() loader;
  final OnCreate onCreate;
  final OnUpdate onUpdate;
  final OnDelete onDelete;
  final String fieldLabel;

  const SimpleCrudPage({
    super.key,
    required this.title,
    required this.loader,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
    required this.fieldLabel,
  });

  @override
  State<SimpleCrudPage> createState() => _SimpleCrudPageState();
}

class _SimpleCrudPageState extends State<SimpleCrudPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _reload() => setState(() => _future = widget.loader());

  Future<void> _openForm({int? id, String? initial}) async {
    final ctrl = TextEditingController(text: initial ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Nuevo' : 'Editar'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: widget.fieldLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      if (id == null) {
        await widget.onCreate(ctrl.text.trim());
      } else {
        await widget.onUpdate(id, ctrl.text.trim());
      }
      _reload();
    }
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Seguro que quieres eliminar este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      await widget.onDelete(id);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data ?? const [];
          if (data.isEmpty) return const Center(child: Text('Sin registros'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final row = data[i];
              return ListTile(
                title: Text(row['nombre'].toString()),
                trailing: Wrap(spacing: 8, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(id: row['id'] as int, initial: row['nombre'] as String)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(row['id'] as int)),
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

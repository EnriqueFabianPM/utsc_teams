import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/tarea.dart';
import '../../database/models/usuario.dart';

class PublicarTarea extends StatefulWidget {
  final Usuario maestro;
  final int grupoId; // grupo al que enseña (o seleccionado en UI)
  const PublicarTarea({super.key, required this.maestro, required this.grupoId});

  @override
  State<PublicarTarea> createState() => _PublicarTareaState();
}

class _PublicarTareaState extends State<PublicarTarea> {
  final _db = DBHelper();
  final _titulo = TextEditingController();
  final _desc = TextEditingController();
  final _fecha = TextEditingController(); // opcional yyyy-mm-dd

  Future<void> _guardar() async {
    if (_titulo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Título requerido')));
      return;
    }
    final t = Tarea(
      titulo: _titulo.text.trim(),
      descripcion: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      grupoId: widget.grupoId,
      maestroId: widget.maestro.id!,
      fechaEntrega: _fecha.text.trim().isEmpty ? null : _fecha.text.trim(),
    );
    await _db.createTarea(t);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea publicada ✅')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar tarea')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _titulo, decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción (opcional)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _fecha, decoration: const InputDecoration(labelText: 'Fecha entrega (opcional, yyyy-mm-dd)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: _guardar, child: const Text('Publicar')),
        ],
      ),
    );
  }
}

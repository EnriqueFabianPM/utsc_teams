import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../services/file_service.dart';
import '../../database/models/usuario.dart';
import '../../database/models/trabajo.dart';
import '../../database/models/tarea.dart';

class SubirTrabajo extends StatefulWidget {
  final Usuario estudiante;
  final Tarea tarea; // ⬅️ NUEVO: viene desde la lista de tareas
  const SubirTrabajo({super.key, required this.estudiante, required this.tarea});

  @override
  State<SubirTrabajo> createState() => _SubirTrabajoState();
}

class _SubirTrabajoState extends State<SubirTrabajo> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _db = DBHelper();
  final _files = FileService();

  String? _filePath;

  Future<void> _pickFile() async {
    final picked = await _files.pickDocument();
    if (picked != null) {
      final local = await _files.saveCopyToAppDir(picked);
      setState(() => _filePath = local);
    }
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty || _filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y archivo')),
      );
      return;
    }

    final t = Trabajo(
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      archivoPath: _filePath,
      grupoId: widget.tarea.grupoId,
      estudianteId: widget.estudiante.id!,
      maestroId: widget.tarea.maestroId,
      calificacion: null,
      retroalimentacion: null,
    );
    // Guardamos con tarea_id vía toMap “manual”
    final map = t.toMap();
    map['tarea_id'] = widget.tarea.id;

    await _db.insertTrabajo(Trabajo.fromMap(map)); // reusamos el método
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrega enviada ✅')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entregar: ${widget.tarea.titulo}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(
              labelText: 'Título de tu entrega',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _filePath ?? 'Ningún archivo seleccionado',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Adjuntar'),
              )
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

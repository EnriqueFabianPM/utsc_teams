import 'package:flutter/material.dart';
// Ya no necesitas importar file_picker directo porque usamos FileService
// import 'package:file_picker/file_picker.dart';

import '../../database/db_helper.dart';
import '../../services/file_service.dart';
import '../../database/models/usuario.dart';
import '../../database/models/trabajo.dart';
import '../../database/models/horario.dart';

class SubirTrabajo extends StatefulWidget {
  final Usuario estudiante;
  const SubirTrabajo({super.key, required this.estudiante});

  @override
  State<SubirTrabajo> createState() => _SubirTrabajoState();
}

class _SubirTrabajoState extends State<SubirTrabajo> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _db = DBHelper();
  final _files = FileService(); // 👈 faltaba instanciar

  String? _filePath;
  Horario? _horarioSeleccionado; // define materia + maestroId según horario

  Future<List<Horario>> _cargarHorarios() async {
    if (widget.estudiante.grupoId == null) return [];
    return _db.horariosPorGrupo(widget.estudiante.grupoId!);
  }

  Future<void> _pickFile() async {
    final picked = await _files.pickDocument();
    if (picked != null) {
      final local = await _files.saveCopyToAppDir(picked);
      setState(() => _filePath = local); // guarda la ruta copiada en la app
    }
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty ||
        _horarioSeleccionado == null ||
        _filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título, materia y archivo')),
      );
      return;
    }

    final t = Trabajo(
      titulo: _tituloCtrl.text.trim(),
      descripcion:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      archivoPath: _filePath,
      grupoId: _horarioSeleccionado!.grupoId,
      estudianteId: widget.estudiante.id!, // viene del login
      maestroId: _horarioSeleccionado!.maestroId,
      calificacion: null,
      retroalimentacion: null,
    );

    await _db.insertTrabajo(t);

    if (mounted) {
      _tituloCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _filePath = null;
        _horarioSeleccionado = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trabajo enviado ✅')),
      );
      Navigator.pop(context); // vuelve al home del estudiante
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir trabajo')),
      body: FutureBuilder<List<Horario>>(
        future: _cargarHorarios(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final horarios = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
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

              // Materia / Maestro a partir del horario del grupo
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Materia / Maestro',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Horario>(
                    isExpanded: true,
                    value: _horarioSeleccionado,
                    items: horarios.map((h) {
                      final label =
                          '${h.materia} • ${h.dia}  (${h.horaInicio}-${h.horaFin})';
                      return DropdownMenuItem<Horario>(
                        value: h,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (h) => setState(() => _horarioSeleccionado = h),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Archivo
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _filePath == null
                          ? 'Ningún archivo seleccionado'
                          : _filePath!,
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
          );
        },
      ),
    );
  }
}

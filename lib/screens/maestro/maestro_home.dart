import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/models/usuario.dart';
import '../../database/models/tarea.dart';

import 'horario_maestro.dart';
import 'calificar_trabajo.dart';
import 'calificaciones_maestro.dart';
import 'publicar_tarea.dart';
import 'entregas_tarea.dart';

class MaestroHome extends StatefulWidget {
  final Usuario user;
  const MaestroHome({super.key, required this.user});

  @override
  State<MaestroHome> createState() => _MaestroHomeState();
}

class _MaestroHomeState extends State<MaestroHome> {
  final _db = DBHelper();

  Future<int?> _elegirGrupoParaPublicar(BuildContext context) async {
    // Tomamos los grupos donde el maestro tiene horario y su nombre
    final det = await _db.horariosDetalladosPorMaestro(widget.user.id!);
    if (det.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes grupos asignados en horarios')),
        );
      }
      return null;
    }
    // Mapa único: grupoId -> nombre
    final Map<int, String> grupos = {};
    for (final h in det) {
      final gid = h['grupo_id'] as int;
      grupos[gid] = h['grupo_nombre']?.toString() ?? 'Grupo $gid';
    }

    return showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Selecciona un grupo'),
        children: grupos.entries
            .map(
              (e) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, e.key),
            child: Text(e.value),
          ),
        )
            .toList(),
      ),
    );
  }

  Future<Tarea?> _elegirTarea(BuildContext context) async {
    final tareas = await _db.getTareasPorMaestro(widget.user.id!);
    if (tareas.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aún no has publicado tareas')),
        );
      }
      return null;
    }
    return showDialog<Tarea>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Selecciona una tarea'),
        children: tareas
            .map(
              (t) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, t),
            child: Text(t.titulo),
          ),
        )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(title: Text("Panel Maestro - ${user.nombre}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Ver mi horario"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HorarioMaestro(user: user)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_add),
            title: const Text("Publicar tarea"),
            subtitle: const Text('Elige un grupo y crea una nueva tarea'),
            onTap: () async {
              final grupoId = await _elegirGrupoParaPublicar(context);
              if (grupoId == null) return;
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicarTarea(maestro: user, grupoId: grupoId),
                ),
              );
              setState(() {}); // por si luego quieres refrescar algo
            },
          ),
          ListTile(
            leading: const Icon(Icons.fact_check),
            title: const Text("Calificar entregas (todas)"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CalificarTrabajo(maestro: user)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder_shared),
            title: const Text("Ver entregas por tarea"),
            subtitle: const Text('Selecciona una tarea publicada'),
            onTap: () async {
              final tarea = await _elegirTarea(context);
              if (tarea == null) return;
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EntregasTarea(tarea: tarea)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: const Text("Mis calificaciones (editar)"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CalificacionesMaestro(maestro: user),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

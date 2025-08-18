import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';
import '../../../database/models/usuario.dart';

class UsuariosCrud extends StatefulWidget {
  const UsuariosCrud({super.key});
  @override
  State<UsuariosCrud> createState() => _UsuariosCrudState();
}

class _UsuariosCrudState extends State<UsuariosCrud> {
  final db = DBHelper();

  String? _rolFilter; // null = todos
  static const _roles = ['admin', 'maestro', 'estudiante'];

  List<Map<String, dynamic>> _grupos = []; // [{id,nombre,carrera,semestre}]
  Map<int, String> _grupoNombreById = {}; // id -> "DSM03A (TIC 2025-A)"

  late Future<List<Usuario>> _future;

  @override
  void initState() {
    super.initState();
    _loadLookups();
    _reload();
  }

  Future<void> _loadLookups() async {
    _grupos = await db.getGrupos();
    _grupoNombreById = {
      for (final g in _grupos)
        (g['id'] as int): '${g['nombre']} (${g['carrera']} ${g['semestre']})'
    };
    if (!mounted) return;
    setState(() {});
  }

  void _reload() {
    _future = db.getUsuarios(rol: _rolFilter);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openForm({Usuario? u}) async {
    final nameCtrl = TextEditingController(text: u?.nombre ?? '');
    final emailCtrl = TextEditingController(text: u?.email ?? '');
    final passCtrl = TextEditingController(); // vacío = conservar al editar
    String rol = u?.rol ?? 'estudiante';
    int? grupoId = u?.grupoId;
    bool hidePass = true;

    // Capturamos el messenger antes del await
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setModal) {
          return AlertDialog(
            title: Text(u == null ? 'Nuevo usuario' : 'Editar usuario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: hidePass,
                    decoration: InputDecoration(
                      labelText: u == null
                          ? 'Contraseña'
                          : 'Contraseña (vacío = conservar)',
                      suffixIcon: IconButton(
                        icon: Icon(hidePass
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setModal(() => hidePass = !hidePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: rol,
                    items: _roles
                        .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setModal(() {
                      rol = v ?? 'estudiante';
                      // si cambia a rol != estudiante, el grupo se ignora
                    }),
                    decoration: const InputDecoration(labelText: 'Rol'),
                  ),
                  const SizedBox(height: 12),
                  if (rol == 'estudiante')
                    DropdownButtonFormField<int>(
                      value: grupoId,
                      items: _grupos
                          .map(
                            (g) => DropdownMenuItem<int>(
                          value: g['id'] as int,
                          child: Text(_grupoNombreById[g['id'] as int] ??
                              g['nombre'].toString()),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setModal(() => grupoId = v),
                      decoration:
                      const InputDecoration(labelText: 'Grupo'),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    ) ??
        false;

    if (ok != true) {
      return;
    }

    // Validaciones
    final nombre = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    String? error;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (nombre.isEmpty) {
      error = 'Nombre requerido.';
    } else if (!emailRegex.hasMatch(email)) {
      error = 'Email inválido.';
    } else if (u == null && pass.isEmpty) {
      error = 'Contraseña requerida.';
    } else if (rol == 'estudiante' && grupoId == null) {
      error = 'Selecciona un grupo.';
    }

    if (error != null) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    try {
      if (u == null) {
        await db.createUsuario(
          Usuario(
            id: null,
            nombre: nombre,
            email: email,
            password: pass,
            rol: rol,
            grupoId: rol == 'estudiante' ? grupoId : null,
          ),
        );
      } else {
        await db.updateUsuario(
          Usuario(
            id: u.id,
            nombre: nombre,
            email: email,
            password: pass.isEmpty ? u.password : pass,
            rol: rol,
            grupoId: rol == 'estudiante' ? grupoId : null,
          ),
        );
      }
      if (!mounted) return;
      _reload();
    } catch (e) {
      final msg = e.toString().contains('UNIQUE')
          ? 'Ese email ya está registrado.'
          : 'Error: $e';
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('¿Seguro que quieres eliminarlo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ??
        false;

    if (ok == true) {
      await db.deleteUsuario(id);
      if (!mounted) return;
      _reload();
    }
  }

  Widget _roleFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: _rolFilter == null,
          onSelected: (_) {
            _rolFilter = null;
            _reload();
          },
        ),
        for (final r in _roles)
          ChoiceChip(
            label: Text(r),
            selected: _rolFilter == r,
            onSelected: (_) {
              _rolFilter = r;
              _reload();
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios (CRUD)')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _roleFilterChips(),
          ),
          const Divider(height: 16),
          Expanded(
            child: FutureBuilder<List<Usuario>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snap.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('Sin usuarios'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final u = data[i];
                    final grupoTxt = (u.rol == 'estudiante' && u.grupoId != null)
                        ? ' · Grupo: ${_grupoNombreById[u.grupoId!] ?? u.grupoId}'
                        : '';
                    return ListTile(
                      title: Text(u.nombre),
                      subtitle: Text('${u.email} · ${u.rol}$grupoTxt'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openForm(u: u),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _delete(u.id!),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

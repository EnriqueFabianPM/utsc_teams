import 'package:flutter/material.dart';
import 'carreras_crud.dart';
import 'semestres_crud.dart';
import 'grupos_crud.dart';
import 'usuarios_crud.dart';
import 'horarios_crud.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  Widget _tile(BuildContext ctx, String title, Widget page, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Administrador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, 'Carreras (CRUD)',   const CarrerasCrud(),  Icons.school),
          _tile(context, 'Semestres (CRUD)',  const SemestresCrud(), Icons.date_range),
          _tile(context, 'Grupos (CRUD)',     const GruposCrud(),    Icons.group),
          _tile(context, 'Usuarios (CRUD)',   const UsuariosCrud(),  Icons.person),
          _tile(context, 'Horarios (CRUD)',   const HorariosCrud(),  Icons.schedule),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

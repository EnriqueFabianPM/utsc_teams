import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';
import 'crud_template.dart';

class SemestresCrud extends StatelessWidget {
  const SemestresCrud({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();
    return SimpleCrudPage(
      title: 'Semestres (CRUD)',
      fieldLabel: 'Nombre del semestre',
      loader: () => db.getSemestres(),
      onCreate: (nombre) => db.createSemestre(nombre),
      onUpdate: (id, nombre) => db.updateSemestre(id, nombre),
      onDelete: (id) => db.deleteSemestre(id),
    );
  }
}

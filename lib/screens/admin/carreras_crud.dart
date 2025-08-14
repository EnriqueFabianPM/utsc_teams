import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';
import 'crud_template.dart';

class CarrerasCrud extends StatelessWidget {
  const CarrerasCrud({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();
    return SimpleCrudPage(
      title: 'Carreras (CRUD)',
      fieldLabel: 'Nombre de la carrera',
      loader: () => db.getCarreras(),
      onCreate: (nombre) => db.createCarrera(nombre),
      onUpdate: (id, nombre) => db.updateCarrera(id, nombre),
      onDelete: (id) => db.deleteCarrera(id),
    );
  }
}

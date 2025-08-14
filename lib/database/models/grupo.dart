class Grupo {
  int? id;
  String nombre;
  int carreraId;
  int semestreId;

  Grupo({
    this.id,
    required this.nombre,
    required this.carreraId,
    required this.semestreId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'carrera_id': carreraId,
        'semestre_id': semestreId,
      };

  factory Grupo.fromMap(Map<String, dynamic> m) => Grupo(
        id: m['id'] as int?,
        nombre: m['nombre'] as String,
        carreraId: m['carrera_id'] as int,
        semestreId: m['semestre_id'] as int,
      );
}

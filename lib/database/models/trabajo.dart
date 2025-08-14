class Trabajo {
  int? id;
  String titulo;
  String? descripcion;          // puede ser null
  String? archivoPath;          // puede ser null si aún no suben
  int grupoId;
  int estudianteId;
  int maestroId;
  double? calificacion;         // REAL -> puede venir int/double/null
  String? retroalimentacion;    // puede ser null

  // Solo para UI cuando hacemos JOIN con usuarios:
  String? estudianteNombre;

  Trabajo({
    this.id,
    required this.titulo,
    this.descripcion,
    this.archivoPath,
    required this.grupoId,
    required this.estudianteId,
    required this.maestroId,
    this.calificacion,
    this.retroalimentacion,
    this.estudianteNombre,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'archivo_path': archivoPath,
        'grupo_id': grupoId,
        'estudiante_id': estudianteId,
        'maestro_id': maestroId,
        'calificacion': calificacion,
        'retroalimentacion': retroalimentacion,
      };

  factory Trabajo.fromMap(Map<String, dynamic> m) => Trabajo(
        id: m['id'] as int?,
        titulo: m['titulo'] as String,
        descripcion: m['descripcion'] as String?,
        archivoPath: m['archivo_path'] as String?,
        grupoId: m['grupo_id'] as int,
        estudianteId: m['estudiante_id'] as int,
        maestroId: m['maestro_id'] as int,
        calificacion: (m['calificacion'] as num?)?.toDouble(),
        retroalimentacion: m['retroalimentacion'] as String?,
      );

  factory Trabajo.fromMapWithStudent(Map<String, dynamic> m) {
    final base = Trabajo.fromMap(m);
    return Trabajo(
      id: base.id,
      titulo: base.titulo,
      descripcion: base.descripcion,
      archivoPath: base.archivoPath,
      grupoId: base.grupoId,
      estudianteId: base.estudianteId,
      maestroId: base.maestroId,
      calificacion: base.calificacion,
      retroalimentacion: base.retroalimentacion,
      estudianteNombre: m['estudiante_nombre'] as String?,
    );
  }
}

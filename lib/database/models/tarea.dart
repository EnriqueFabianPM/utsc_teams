class Tarea {
  int? id;
  String titulo;
  String? descripcion;
  int grupoId;
  int maestroId;
  String? fechaEntrega; // opcional, ej. "2025-08-31"

  Tarea({
    this.id,
    required this.titulo,
    this.descripcion,
    required this.grupoId,
    required this.maestroId,
    this.fechaEntrega,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'grupo_id': grupoId,
    'maestro_id': maestroId,
    'fecha_entrega': fechaEntrega,
  };

  factory Tarea.fromMap(Map<String, dynamic> m) => Tarea(
    id: m['id'] as int?,
    titulo: m['titulo'] as String,
    descripcion: m['descripcion'] as String?,
    grupoId: m['grupo_id'] as int,
    maestroId: m['maestro_id'] as int,
    fechaEntrega: m['fecha_entrega'] as String?,
  );
}

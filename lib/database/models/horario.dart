class Horario {
  int? id;
  int grupoId;
  String dia;           // "Lun", "Mar", ...
  String materia;
  String horaInicio;    // "08:00"
  String horaFin;       // "09:30"
  int maestroId;

  Horario({
    this.id,
    required this.grupoId,
    required this.dia,
    required this.materia,
    required this.horaInicio,
    required this.horaFin,
    required this.maestroId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'grupo_id': grupoId,
        'dia': dia,
        'materia': materia,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'maestro_id': maestroId,
      };

  factory Horario.fromMap(Map<String, dynamic> m) => Horario(
        id: m['id'] as int?,
        grupoId: m['grupo_id'] as int,
        dia: m['dia'] as String,
        materia: m['materia'] as String,
        horaInicio: m['hora_inicio'] as String,
        horaFin: m['hora_fin'] as String,
        maestroId: m['maestro_id'] as int,
      );
}

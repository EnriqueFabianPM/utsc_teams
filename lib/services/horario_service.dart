import '../database/models/horario.dart';

class HorarioService {
  static const List<String> _ordenDias = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  static final Map<String, int> _diaIndex = {
    for (var i = 0; i < _ordenDias.length; i++) _ordenDias[i]: i
  };

  /// Ordena por día (según _ordenDias) y luego por hora_inicio.
  List<Horario> sort(List<Horario> list) {
    final copy = List<Horario>.from(list);
    copy.sort((a, b) {
      final da = _diaIndex[a.dia] ?? 99;
      final db = _diaIndex[b.dia] ?? 99;
      if (da != db) return da.compareTo(db);
      return a.horaInicio.compareTo(b.horaInicio);
    });
    return copy;
  }

  /// Agrupa por día (clave = 'Lun', 'Mar'...) manteniendo el orden.
  Map<String, List<Horario>> groupByDay(List<Horario> list) {
    final sorted = sort(list);
    final map = <String, List<Horario>>{};
    for (final h in sorted) {
      map.putIfAbsent(h.dia, () => []).add(h);
    }
    // Ordena las claves según _ordenDias
    final ordered = <String, List<Horario>>{};
    for (final d in _ordenDias) {
      if (map.containsKey(d)) ordered[d] = map[d]!;
    }
    // agrega días no contemplados al final
    for (final k in map.keys) {
      if (!ordered.containsKey(k)) ordered[k] = map[k]!;
    }
    return ordered;
  }

  /// Ej: "Programación • Lun • 08:00–09:30"
  String line(Horario h) => '${h.materia} • ${h.dia} • ${h.horaInicio}-${h.horaFin}';
}

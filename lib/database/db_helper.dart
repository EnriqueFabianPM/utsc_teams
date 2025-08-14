import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/usuario.dart';
import 'models/grupo.dart';
import 'models/horario.dart';
import 'models/trabajo.dart';

class DBHelper {
  static Database? _db;

  // ===================== INIT / OPEN =====================
  static Future<void> initDB() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'utsc_teams.db');
    _db = await openDatabase(path, version: 2, onCreate: _onCreate);
    await _seed();
  }

  static Future _onCreate(Database db, int version) async {
    // Carreras y Semestres
    await db.execute('''
      CREATE TABLE carreras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE semestres(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    // Grupos
    await db.execute('''
      CREATE TABLE grupos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        carrera_id INTEGER NOT NULL,
        semestre_id INTEGER NOT NULL
      )
    ''');

    // Usuarios
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        rol TEXT NOT NULL,         -- admin | maestro | estudiante
        grupo_id INTEGER
      )
    ''');

    // Horarios
    await db.execute('''
      CREATE TABLE horarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grupo_id INTEGER NOT NULL,
        dia TEXT NOT NULL,         -- Lun, Mar, Mie, ...
        materia TEXT NOT NULL,
        hora_inicio TEXT NOT NULL, -- "08:00"
        hora_fin TEXT NOT NULL,    -- "09:30"
        maestro_id INTEGER NOT NULL
      )
    ''');

    // Trabajos
    await db.execute('''
      CREATE TABLE trabajos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        archivo_path TEXT,         -- ruta local
        grupo_id INTEGER NOT NULL,
        estudiante_id INTEGER NOT NULL,
        maestro_id INTEGER NOT NULL,
        calificacion REAL,
        retroalimentacion TEXT
      )
    ''');
  }

  static Future _seed() async {
    final db = _db!;
    final uCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM usuarios'),
        ) ??
        0;

    if (uCount == 0) {
      // Carreras & Semestres
      final carId = await db.insert('carreras', {'nombre': 'TIC'});
      final semId = await db.insert('semestres', {'nombre': '2025-A'});

      // Grupo demo
      final gId = await db.insert('grupos', {
        'nombre': 'DSM03A',
        'carrera_id': carId,
        'semestre_id': semId,
      });

      // Usuarios demo
      final maestroId = await db.insert('usuarios', {
        'nombre': 'Profe Juan',
        'email': 'juan@demo',
        'password': '123',
        'rol': 'maestro',
        'grupo_id': null
      });

      await db.insert('usuarios', {
        'nombre': 'Admin',
        'email': 'admin@demo',
        'password': 'admin',
        'rol': 'admin',
        'grupo_id': null
      });

      final alumnoId = await db.insert('usuarios', {
        'nombre': 'Ana Alumna',
        'email': 'ana@demo',
        'password': '123',
        'rol': 'estudiante',
        'grupo_id': gId
      });

      // Horario demo
      await db.insert('horarios', {
        'grupo_id': gId,
        'dia': 'Lun',
        'materia': 'Programación',
        'hora_inicio': '08:00',
        'hora_fin': '09:30',
        'maestro_id': maestroId
      });
      await db.insert('horarios', {
        'grupo_id': gId,
        'dia': 'Mie',
        'materia': 'BD',
        'hora_inicio': '10:00',
        'hora_fin': '11:30',
        'maestro_id': maestroId
      });

      // Trabajo demo (sin calificar)
      await db.insert('trabajos', {
        'titulo': 'Proyecto 1',
        'descripcion': 'Sube tu Word/PDF',
        'archivo_path': null,
        'grupo_id': gId,
        'estudiante_id': alumnoId,
        'maestro_id': maestroId,
        'calificacion': null,
        'retroalimentacion': null
      });
    }
  }

  Database? get db => _db;

  // ===================== AUTH =====================
  Future<Map<String, dynamic>?> _firstRow(
      String table, String where, List args) async {
    final res = await _db!.query(table, where: where, whereArgs: args, limit: 1);
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<Usuario?> loginUser(String email, String pass) async {
    final row =
        await _firstRow('usuarios', 'email=? AND password=?', [email, pass]);
    if (row == null) return null;
    return Usuario.fromMap(row);
  }

  // ===================== USUARIOS =====================
  Future<int> createUsuario(Usuario u) async =>
      _db!.insert('usuarios', u.toMap());

  Future<int> updateUsuario(Usuario u) async => _db!.update('usuarios',
      u.toMap(),
      where: 'id=?', whereArgs: [u.id]);

  Future<int> deleteUsuario(int id) async =>
      _db!.delete('usuarios', where: 'id=?', whereArgs: [id]);

  Future<List<Usuario>> getUsuarios({String? rol}) async {
    final res = (rol == null)
        ? await _db!.query('usuarios', orderBy: 'id DESC')
        : await _db!
            .query('usuarios', where: 'rol=?', whereArgs: [rol], orderBy: 'id DESC');
    return res.map(Usuario.fromMap).toList();
  }

  // ===================== CARRERAS =====================
  Future<int> createCarrera(String nombre) async =>
      _db!.insert('carreras', {'nombre': nombre});

  Future<int> updateCarrera(int id, String nombre) async => _db!.update(
      'carreras', {'nombre': nombre},
      where: 'id=?', whereArgs: [id]);

  Future<int> deleteCarrera(int id) async =>
      _db!.delete('carreras', where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getCarreras() async =>
      _db!.query('carreras', orderBy: 'nombre');

  // ===================== SEMESTRES =====================
  Future<int> createSemestre(String nombre) async =>
      _db!.insert('semestres', {'nombre': nombre});

  Future<int> updateSemestre(int id, String nombre) async => _db!.update(
      'semestres', {'nombre': nombre},
      where: 'id=?', whereArgs: [id]);

  Future<int> deleteSemestre(int id) async =>
      _db!.delete('semestres', where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getSemestres() async =>
      _db!.query('semestres', orderBy: 'id DESC');

  // ===================== GRUPOS =====================
  Future<int> createGrupo(String nombre, int carreraId, int semestreId) async =>
      _db!.insert('grupos', {
        'nombre': nombre,
        'carrera_id': carreraId,
        'semestre_id': semestreId
      });

  Future<int> updateGrupo(
          int id, String nombre, int carreraId, int semestreId) async =>
      _db!.update(
          'grupos',
          {
            'nombre': nombre,
            'carrera_id': carreraId,
            'semestre_id': semestreId
          },
          where: 'id=?',
          whereArgs: [id]);

  Future<int> deleteGrupo(int id) async =>
      _db!.delete('grupos', where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getGrupos() async => _db!.rawQuery('''
      SELECT g.id, g.nombre,
             c.nombre AS carrera, s.nombre AS semestre
      FROM grupos g
      JOIN carreras c ON c.id=g.carrera_id
      JOIN semestres s ON s.id=g.semestre_id
      ORDER BY g.id DESC
    ''');

  // ===================== HORARIOS =====================
  Future<int> insertHorario(Horario h) async =>
      _db!.insert('horarios', h.toMap());

  Future<int> updateHorario(Horario h) async => _db!.update(
      'horarios', h.toMap(),
      where: 'id=?', whereArgs: [h.id]);

  Future<int> deleteHorario(int id) async =>
      _db!.delete('horarios', where: 'id=?', whereArgs: [id]);

  Future<List<Horario>> horariosPorGrupo(int grupoId) async {
    final res = await _db!.query('horarios',
        where: 'grupo_id=?', whereArgs: [grupoId], orderBy: 'dia, hora_inicio');
    return res.map(Horario.fromMap).toList();
  }

  Future<List<Horario>> horariosPorMaestro(int maestroId) async {
    final res = await _db!.query('horarios',
        where: 'maestro_id=?', whereArgs: [maestroId], orderBy: 'dia, hora_inicio');
    return res.map(Horario.fromMap).toList();
  }

  // ===================== TRABAJOS =====================
  Future<int> insertTrabajo(Trabajo t) async =>
      _db!.insert('trabajos', t.toMap());

  Future<int> calificarTrabajo(int trabajoId, String calificacion,
          {String? feedback}) async =>
      _db!.update(
        'trabajos',
        {
          'calificacion': double.tryParse(calificacion),
          'retroalimentacion': feedback,
        },
        where: 'id=?',
        whereArgs: [trabajoId],
      );

  Future<List<Trabajo>> getTrabajosPorEstudiante(int estudianteId) async {
    final res = await _db!.rawQuery('''
      SELECT t.*
      FROM trabajos t
      WHERE t.estudiante_id = ?
      ORDER BY t.id DESC
    ''', [estudianteId]);
    return res.map(Trabajo.fromMap).toList();
  }

  Future<List<Trabajo>> getTrabajosPorMaestro(int maestroId) async {
    final res = await _db!.rawQuery('''
      SELECT t.*, u.nombre as estudiante_nombre
      FROM trabajos t
      JOIN usuarios u ON u.id = t.estudiante_id
      WHERE t.maestro_id = ?
      ORDER BY t.id DESC
    ''', [maestroId]);
    return res.map(Trabajo.fromMapWithStudent).toList();
  }
}

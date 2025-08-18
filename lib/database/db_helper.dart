import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/usuario.dart';
import 'models/grupo.dart';
import 'models/horario.dart';
import 'models/trabajo.dart';
import 'models/tarea.dart';

class DBHelper {
  static Database? _db;

  // ===================== INIT / OPEN =====================
  static Future<void> initDB() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'utsc_teams.db');
    _db = await openDatabase(
      path,
      version: 3,              // ⬅️ subimos versión
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,   // ⬅️ migración
    );
    await _seed();
  }

  static Future _onCreate(Database db, int version) async {
    // Carreras
    await db.execute('''
      CREATE TABLE carreras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    // Semestres
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
        dia TEXT NOT NULL,
        materia TEXT NOT NULL,
        hora_inicio TEXT NOT NULL,
        hora_fin TEXT NOT NULL,
        maestro_id INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_horarios_grupo   ON horarios(grupo_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_horarios_maestro ON horarios(maestro_id)');

    // Tareas (nueva)
    await db.execute('''
      CREATE TABLE tareas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        grupo_id INTEGER NOT NULL,
        maestro_id INTEGER NOT NULL,
        fecha_entrega TEXT
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tareas_grupo ON tareas(grupo_id)');

    // Trabajos = entregas ligadas a tarea_id (puede ser null si viene de versión vieja)
    await db.execute('''
      CREATE TABLE trabajos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        archivo_path TEXT,
        grupo_id INTEGER NOT NULL,
        estudiante_id INTEGER NOT NULL,
        maestro_id INTEGER NOT NULL,
        tarea_id INTEGER,
        calificacion REAL,
        retroalimentacion TEXT
      )
    ''');
  }

  static Future _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 3) {
      // Crear tabla tareas si no existe
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tareas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          descripcion TEXT,
          grupo_id INTEGER NOT NULL,
          maestro_id INTEGER NOT NULL,
          fecha_entrega TEXT
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_tareas_grupo ON tareas(grupo_id)');

      // Agregar columna tarea_id a trabajos si no existe
      final cols = await db.rawQuery("PRAGMA table_info(trabajos)");
      final hasTareaId = cols.any((c) => (c['name'] as String) == 'tarea_id');
      if (!hasTareaId) {
        await db.execute('ALTER TABLE trabajos ADD COLUMN tarea_id INTEGER');
      }
    }
  }

  static Future _seed() async {
    final db = _db!;
    final uCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM usuarios'),
    ) ?? 0;

    if (uCount == 0) {
      // Carreras & Semestres
      final carId = await db.insert('carreras', {'nombre': 'Desarrollo de Software'});
      final semId = await db.insert('semestres', {'nombre': '2022-04-31'});

      // Grupo demo
      final gId = await db.insert('grupos', Grupo(
        nombre: '11-A',
        carreraId: carId,
        semestreId: semId,
      ).toMap());

      // Usuarios demo
      final maestroId = await db.insert('usuarios', {
        'nombre': 'Maestra',
        'email': 'paolamaestra@gmail.com',
        'password': 'maestra123',
        'rol': 'maestro',
        'grupo_id': null
      });

      await db.insert('usuarios', {
        'nombre': 'Administrador',
        'email': 'paolaadmin@virtual.utsc.edu.mx',
        'password': 'admin123',
        'rol': 'admin',
        'grupo_id': null
      });

      // Estudiantes
      final alumnoId = await db.insert('usuarios', {
        'nombre': 'Paola Coronado Perez',
        'email': 'paolacoronado@gmail.com',
        'password': 'paola123',
        'rol': 'estudiante',
        'grupo_id': gId
      });

      // Horario demo
      await db.insert('horarios', {
        'grupo_id': gId,
        'dia': 'Lun',
        'materia': 'Programación de Modelos',
        'hora_inicio': '07:00',
        'hora_fin': '09:30',
        'maestro_id': maestroId
      });
      await db.insert('horarios', {
        'grupo_id': gId,
        'dia': 'Mie',
        'materia': 'Matematicas II',
        'hora_inicio': '9:30',
        'hora_fin': '11:30',
        'maestro_id': maestroId
      });

      // Tarea demo (publicada por el maestro para el grupo)
      final tareaId = await db.insert('tareas', Tarea(
        titulo: 'Tarea 1',
        descripcion: 'Sube tu trabajo',
        grupoId: gId,
        maestroId: maestroId,
        fechaEntrega: null,
      ).toMap());

      // Entrega demo (del primer alumno) ligada a la tarea
      await db.insert('trabajos', {
        'titulo': 'Demo Tarea',
        'descripcion': 'descripcion demo',
        'archivo_path': null,
        'grupo_id': gId,
        'estudiante_id': alumnoId,
        'maestro_id': maestroId,
        'tarea_id': tareaId,
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

  Future<int> updateUsuario(Usuario u) async => _db!.update(
    'usuarios', u.toMap(),
    where: 'id=?', whereArgs: [u.id],
  );

  Future<int> deleteUsuario(int id) async =>
      _db!.delete('usuarios', where: 'id=?', whereArgs: [id]);

  Future<List<Usuario>> getUsuarios({String? rol}) async {
    final res = (rol == null)
        ? await _db!.query('usuarios', orderBy: 'id DESC')
        : await _db!.query('usuarios',
        where: 'rol=?', whereArgs: [rol], orderBy: 'id DESC');
    return res.map(Usuario.fromMap).toList();
  }

  // ===================== CARRERAS =====================
  Future<int> createCarrera(String nombre) async =>
      _db!.insert('carreras', {'nombre': nombre});

  Future<int> updateCarrera(int id, String nombre) async => _db!.update(
    'carreras', {'nombre': nombre},
    where: 'id=?', whereArgs: [id],
  );

  Future<int> deleteCarrera(int id) async =>
      _db!.delete('carreras', where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getCarreras() async =>
      _db!.query('carreras', orderBy: 'nombre');

  // ===================== SEMESTRES =====================
  Future<int> createSemestre(String nombre) async =>
      _db!.insert('semestres', {'nombre': nombre});

  Future<int> updateSemestre(int id, String nombre) async => _db!.update(
    'semestres', {'nombre': nombre},
    where: 'id=?', whereArgs: [id],
  );

  Future<int> deleteSemestre(int id) async =>
      _db!.delete('semestres', where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getSemestres() async =>
      _db!.query('semestres', orderBy: 'id DESC');

  // ===================== GRUPOS =====================
  Future<int> createGrupo(String nombre, int carreraId, int semestreId) async =>
      _db!.insert('grupos', {
        'nombre': nombre,
        'carrera_id': carreraId,
        'semestre_id': semestreId,
      });

  Future<int> updateGrupo(
      int id, String nombre, int carreraId, int semestreId) async =>
      _db!.update(
        'grupos',
        {
          'nombre': nombre,
          'carrera_id': carreraId,
          'semestre_id': semestreId,
        },
        where: 'id=?',
        whereArgs: [id],
      );

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
      'horarios', h.toMap(), where: 'id=?', whereArgs: [h.id]);

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

  // Detallados
  Future<List<Map<String, dynamic>>> horariosDetalladosPorGrupo(int grupoId) =>
      _db!.rawQuery('''
        SELECT h.*, u.nombre AS maestro_nombre
        FROM horarios h
        JOIN usuarios u ON u.id = h.maestro_id
        WHERE h.grupo_id = ?
        ORDER BY h.dia, h.hora_inicio
      ''', [grupoId]);

  Future<List<Map<String, dynamic>>> horariosDetalladosPorMaestro(int maestroId) =>
      _db!.rawQuery('''
        SELECT h.*, g.nombre AS grupo_nombre
        FROM horarios h
        JOIN grupos g ON g.id = h.grupo_id
        WHERE h.maestro_id = ?
        ORDER BY h.dia, h.hora_inicio
      ''', [maestroId]);

  // ===================== TAREAS =====================
  Future<int> createTarea(Tarea t) async => _db!.insert('tareas', t.toMap());

  Future<List<Tarea>> getTareasPorGrupo(int grupoId) async {
    final res = await _db!
        .query('tareas', where: 'grupo_id=?', whereArgs: [grupoId], orderBy: 'id DESC');
    return res.map(Tarea.fromMap).toList();
  }

  Future<List<Tarea>> getTareasPorMaestro(int maestroId) async {
    final res = await _db!.query('tareas',
        where: 'maestro_id=?', whereArgs: [maestroId], orderBy: 'id DESC');
    return res.map(Tarea.fromMap).toList();
  }

  // ===================== ENTREGAS (TRABAJOS) =====================
  Future<int> insertTrabajo(Trabajo t) async => _db!.insert('trabajos', t.toMap());

  Future<int> calificarTrabajo(int trabajoId, String calificacion, {String? feedback}) async =>
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

  Future<List<Trabajo>> getEntregasPorTarea(int tareaId) async {
    final res = await _db!.rawQuery('''
      SELECT t.*, u.nombre AS estudiante_nombre
      FROM trabajos t
      JOIN usuarios u ON u.id = t.estudiante_id
      WHERE t.tarea_id = ?
      ORDER BY t.id DESC
    ''', [tareaId]);
    return res.map(Trabajo.fromMapWithStudent).toList();
  }
}

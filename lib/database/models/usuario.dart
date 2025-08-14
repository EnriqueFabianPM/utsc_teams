class Usuario {
  int? id;
  String nombre;
  String email;
  String password;
  String rol;        // admin | maestro | estudiante
  int? grupoId;      // null para admin/maestro

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
    this.grupoId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': rol,
        'grupo_id': grupoId,
      };

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        id: m['id'] as int?,
        nombre: m['nombre'] as String,
        email: m['email'] as String,
        password: m['password'] as String,
        rol: m['rol'] as String,
        grupoId: m['grupo_id'] as int?,
      );
}

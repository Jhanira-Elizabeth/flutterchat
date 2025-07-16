class Dueno {
  final int id;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? email;
  final String estado;
  final int idLocal;

  Dueno({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.email,
    required this.estado,
    required this.idLocal,
  });
}

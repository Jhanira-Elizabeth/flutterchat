import 'package:cloud_firestore/cloud_firestore.dart';

class Visita {
  final String id;
  final String userId;
  final String lugarId;
  final String nombreLugar;
  final String tipoLugar; // 'PuntoTuristico' o 'LocalTuristico'
  final String? imagenUrl;
  final DateTime fechaVisita;

  Visita({
    required this.id,
    required this.userId,
    required this.lugarId,
    required this.nombreLugar,
    required this.tipoLugar,
    this.imagenUrl,
    required this.fechaVisita,
  });

  factory Visita.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Visita(
      id: doc.id,
      userId: data['userId'] ?? '',
      lugarId: data['lugarId'] ?? '',
      nombreLugar: data['nombreLugar'] ?? '',
      tipoLugar: data['tipoLugar'] ?? '',
      imagenUrl: data['imagenUrl'],
      fechaVisita: (data['fechaVisita'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lugarId': lugarId,
      'nombreLugar': nombreLugar,
      'tipoLugar': tipoLugar,
      'imagenUrl': imagenUrl,
      'fechaVisita': fechaVisita,
    };
  }
}

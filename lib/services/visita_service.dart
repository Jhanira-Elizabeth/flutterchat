import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visita.dart';

class VisitaService {
  final CollectionReference _visitasRef = FirebaseFirestore.instance.collection('visitas');

  Future<void> guardarVisita(Visita visita) async {
    await _visitasRef.add(visita.toMap());
  }

  Future<List<Visita>> obtenerVisitasPasadas(String userId) async {
    final hoy = DateTime.now();
    final query = await _visitasRef
        .where('userId', isEqualTo: userId)
        .where('fechaVisita', isLessThan: hoy)
        .orderBy('fechaVisita', descending: true)
        .get();
    return query.docs.map((doc) => Visita.fromFirestore(doc)).toList();
  }
}

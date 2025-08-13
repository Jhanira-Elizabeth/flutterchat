import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/visita.dart';
import '../services/visita_service.dart';
import '../widgets/custom_card.dart';

class VisitadosScreen extends StatefulWidget {
  const VisitadosScreen({Key? key}) : super(key: key);

  @override
  State<VisitadosScreen> createState() => _VisitadosScreenState();
}

class _VisitadosScreenState extends State<VisitadosScreen> {
  late Future<List<Visita>> _visitasFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _visitasFuture = user != null
        ? VisitaService().obtenerVisitasPasadas(user.uid)
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lugares visitados')),
      body: FutureBuilder<List<Visita>>(
        future: _visitasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final visitas = snapshot.data ?? [];
          if (visitas.isEmpty) {
            return const Center(child: Text('No has visitado ningún lugar aún.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemCount: visitas.length,
            itemBuilder: (context, index) {
              final visita = visitas[index];
              return CustomCard(
                imageUrl: visita.imagenUrl ?? 'assets/images/viejo5.jpg',
                title: visita.nombreLugar,
                subtitle: visita.tipoLugar,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/detalles',
                    arguments: {
                      'item': {
                        'id': visita.lugarId,
                        'nombre': visita.nombreLugar,
                        'tipo': visita.tipoLugar,
                        'imagenUrl': visita.imagenUrl,
                      },
                      'imageUrl': visita.imagenUrl,
                    },
                  );
                },
                item: visita,
              );
            },
          );
        },
      ),
    );
  }
}

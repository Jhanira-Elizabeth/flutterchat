import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/visita.dart';
import '../services/visita_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';

class VisitadosScreen extends StatefulWidget {
  const VisitadosScreen({Key? key}) : super(key: key);

  @override
  State<VisitadosScreen> createState() => _VisitadosScreenState();
}

class _VisitadosScreenState extends State<VisitadosScreen> {
  late Future<List<Visita>> _visitasFuture;
  int _currentIndex = 0;

  void _onTabChange(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/mapa');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/favoritos');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/chatbot');
          break;
      }
    });
  }

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
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}

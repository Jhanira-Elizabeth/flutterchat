import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';
import '../../models/punto_turistico.dart';

class BalneariosScreen extends StatefulWidget {
  const BalneariosScreen({super.key});

  @override
  _BalneariosScreenState createState() => _BalneariosScreenState();
}

class _BalneariosScreenState extends State<BalneariosScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _balneariosFuture;
  final List<String> _imageUrls = [
    'assets/images/afiche_publicitario_balneario_ibiza.jpg',
    'assets/images/otonga3.jpg',
    'assets/images/GorilaPark1.jpg',
    'assets/images/BalnearioEspanoles1.jpg',
    'assets/images/BalnearioEspanoles1.jpg',
    'assets/images/BalnearioEspanoles1.jpg',
    'assets/images/BalnearioEspanoles1.jpg',
    'assets/images/BalnearioEspanoles1.jpg',
    'assets/images/BalnearioEspanoles1.jpg',
    ];

  @override
  void initState() {
    super.initState();
    _balneariosFuture = _fetchBalnearios();
  }

  Future<List<dynamic>> _fetchBalnearios() async {
    final locales = await _apiService.fetchLocalesConEtiquetas();
    final localesBalnearios = locales.where(
      (local) => local.etiquetas.any((et) => et.id == 7)
    ).toList();

    final puntos = await _apiService.fetchPuntosConEtiquetas();
    final puntosBalnearios = puntos.where(
      (punto) => punto.etiquetas.any((et) => et.id == 7)
    ).toList();

    return [...localesBalnearios, ...puntosBalnearios];
  }

  void _onTabChange(int index) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balnearios')),
      body: FutureBuilder<List<dynamic>>(
        future: _balneariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron balnearios disponibles.'),
            );
          } else {
            final balnearios = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: balnearios.length,
              itemBuilder: (context, index) {
                final item = balnearios[index];
                final imageUrl = _imageUrls[index % _imageUrls.length];
                String title = 'Desconocido';

                if (item is PuntoTuristico || item is LocalTuristico) {
                  title = item.nombre;
                }

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalles',
                    arguments: {
                      'item': item,
                      'imageUrl': imageUrl,
                      'categoria': 'Balneario',
                    },
                  ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: title,
                    item: item,
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/punto_turistico.dart';
// import '../models/local_turistico.dart'; // Eliminado porque el archivo no existe
import '../widgets/custom_card.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';
import '../../services/cache_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Solo precargar imágenes de los recomendados visibles (máx 5)
  final List<String> _imagenesPrecarga = [
    'assets/images/congoma1.jpg',
    'assets/images/Tapir5.jpg',
    'assets/images/cascadas_diablo.jpg',
    'assets/images/afiche_publicitario_balneario_ibiza.jpg',
    'assets/images/VenturaMiniGolf1.jpg',
  ];
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>> _recomendadosFuture;
  List<dynamic> _resultadosBusqueda = [];
  bool _buscando = false;
  List<dynamic> _recomendadosEnMemoria = [];

  final Map<String, String> imagenesRecomendados = {
    'punto_3': 'assets/images/congoma1.jpg',
    'punto_5': 'assets/images/Tapir5.jpg',
    'local_3': 'assets/images/cascadas_diablo.jpg',
    'local_4': 'assets/images/afiche_publicitario_balneario_ibiza.jpg',
    'local_16': 'assets/images/VenturaMiniGolf1.jpg',
  };

  final List<Map<String, dynamic>> categorias = [
    {
      'nombre': 'Etnia Tsáchila',
      'imagen': 'assets/images/Mushily1.jpg',
      'route': '/etniatsachila',
    },
    {
      'nombre': 'Atracciones',
      'imagen': 'assets/images/GorilaPark1.jpg',
      'route': '/atracciones',
    },
    {
      'nombre': 'Parroquias',
      'imagen': 'assets/images/ValleHermoso1.jpg',
      'route': '/parroquias',
    },
    {
      'nombre': 'Alojamiento',
      'imagen': 'assets/images/HotelRefugio1.jpg',
      'route': '/alojamiento',
    },
    {
      'nombre': 'Alimentación',
      'imagen': 'assets/images/OhQueRico1.jpg',
      'route': '/alimentacion',
    },
    {
      'nombre': 'Parques',
      'imagen': 'assets/images/ParqueJuventud1.jpg',
      'route': '/parques',
    },
    {
      'nombre': 'Ríos',
      'imagen': 'assets/images/SanGabriel1.jpg',
      'route': '/rios',
    },
    {
      'nombre': 'Balneario',
      'imagen': 'assets/images/BalnearioEspanoles1.jpg',
      'route': '/balneario',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _recomendadosFuture = _cargarRecomendados().then((list) {
      _recomendadosEnMemoria = list;
      // Precargar solo las imágenes de los primeros recomendados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < _imagenesPrecarga.length && i < list.length; i++) {
          precacheImage(AssetImage(_imagenesPrecarga[i]), context);
        }
      });
      return list;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _cargarRecomendados() async {
    // Eliminar delay artificial para acelerar el renderizado inicial
    final puntos = [
      PuntoTuristico(
        id: 3,
        nombre: 'Comuna Tsáchila Congoma',
        imagenUrl: 'assets/images/congoma1.jpg',
        descripcion:
            'Comunidad ancestral Tsáchila que conserva tradiciones culturales únicas, con actividades interactivas para los visitantes.',
        latitud: -0.390846,
        longitud: -79.351443,
        idParroquia: 39,
        estado: 'activo',
        esRecomendado: true,
      ),
      PuntoTuristico(
        id: 5,
        nombre: 'Zoológico La Isla del Tapir',
        imagenUrl: 'assets/images/Tapir5.jpg',
        descripcion:
            'Es un lugar ecológico y recreativo.\nproyectado a la conservación de la Flora y Fauna.',
        latitud: -0.117760,
        longitud: -79.258118,
        idParroquia: 37,
        estado: 'activo',
        esRecomendado: true,
      ),
    ];
    final locales = [
      LocalTuristico(
        id: 3,
        nombre: 'Cascadas del Diablo',
        imagenUrl: 'assets/images/cascadas_diablo.jpg',
        descripcion:
            'Se debe escalar una montaña de senderos angostos. La ruta se inicia en el kilómetro 38 de la vía Santo Domingo - Quito.',
        direccion:
            'Ubicado el recinto Unión del Toachi, kilometro 38 de la vía Santo Domingo - Quito.',
        latitud: -0.328215,
        longitud: -78.948441,
        estado: 'activo',
      ),
      LocalTuristico(
        id: 4,
        nombre: 'Balneario Ibiza',
        imagenUrl: 'assets/images/afiche_publicitario_balneario_ibiza.jpg',
        descripcion:
            'Lugar ideal para disfrutar de la naturaleza con piscina, jacuzzi, eventos y karaoke.',
        direccion: 'Parroquia Alluriquín, km 23 vía Santo Domingo - Quito',
        latitud: -0.310870,
        longitud: -79.030298,
        estado: 'activo',
      ),
      LocalTuristico(
        id: 16,
        nombre: 'Aventure mini Golf',
        imagenUrl: 'assets/images/VenturaMiniGolf1.jpg',
        descripcion:
            'Este centro de entretenimiento, impulsado por la empresa privada, ofrece opciones como una cancha de pádel, campos de minigolf y un mirador con vistas al río Toachi, promoviendo el disfrute y el desarrollo turístico en la región.',
        direccion: 'Santo Domingo',
        latitud: -0.253312,
        longitud: -79.134135,
        estado: 'activo',
      ),
    ];
    for (var punto in puntos) {
      try {
        CacheService.saveData('homeCache', 'punto_${punto.id}', punto.toMap());
      } catch (e) {}
    }
    for (var local in locales) {
      try {
        CacheService.saveData('homeCache', 'local_${local.id}', local.toMap());
      } catch (e) {}
    }
    return [...puntos, ...locales];
  }

  String _normalizarTexto(String texto) {
    final Map<String, String> reemplazos = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ü': 'u',
      'Ü': 'U',
      'ñ': 'n',
      'Ñ': 'N',
    };
    String resultado = texto.toLowerCase();
    reemplazos.forEach((key, value) {
      resultado = resultado.replaceAll(key, value);
    });
    return resultado;
  }

  void _buscar(String query) {
    if (query.isEmpty) {
      setState(() {
        _buscando = false;
        _resultadosBusqueda = [];
      });
      return;
    }
    final String queryNormalizado = _normalizarTexto(query);
    final List<dynamic> resultadosFiltrados =
        _recomendadosEnMemoria.where((item) {
      final String nombreNormalizado = _normalizarTexto(item.nombre);
      return nombreNormalizado.contains(queryNormalizado);
    }).toList();
    setState(() {
      _buscando = true;
      _resultadosBusqueda = resultadosFiltrados;
    });
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
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

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            title == 'Categorías' ? 'Ver todos (8)' : 'Ver Todos (5)',
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _getImageUrl(dynamic item) {
    if (item == null) return 'assets/images/IndioColorado3.jpg';
    String key = '';
    if (item is PuntoTuristico) {
      key = 'punto_${item.id}';
    } else if (item is LocalTuristico) {
      key = 'local_${item.id}';
    } else if (item is Map<String, dynamic> && item.containsKey('imagen')) {
      return item['imagen'] as String;
    }
    if (imagenesRecomendados.containsKey(key)) {
      return imagenesRecomendados[key]!;
    }
    if ((item is PuntoTuristico &&
            item.imagenUrl != null &&
            item.imagenUrl!.isNotEmpty) ||
        (item is LocalTuristico &&
            item.imagenUrl != null &&
            item.imagenUrl!.isNotEmpty)) {
      return item.imagenUrl!;
    }
    return 'assets/images/IndioColorado3.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.wb_sunny
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.pushNamed(context, '/categorias');
            },
          ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleSignOut,
            ),
        ],
      ),
      body: _buscando
          ? ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _resultadosBusqueda.isEmpty
                  ? 2
                  : _resultadosBusqueda.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    'Resultados de búsqueda',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  );
                } else if (index == 1 && _resultadosBusqueda.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: Text(
                        'No se encontraron resultados',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.6)),
                      ),
                    ),
                  );
                } else {
                  final item = _resultadosBusqueda[index - 2];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _getImageUrl(item),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            cacheWidth: 120,
                            cacheHeight: 120,
                          ),
                        ),
                        title: Text(
                          item.nombre,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        subtitle: Text(
                          item is PuntoTuristico
                              ? 'Punto Turístico'
                              : 'Local Turístico',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6)),
                        ),
                        onTap: () {
                          String? detalleImagenUrl;
                          String key = '';
                          if (item is PuntoTuristico) {
                            key = 'punto_${item.id}';
                          } else if (item is LocalTuristico) {
                            key = 'local_${item.id}';
                          }
                          if (imagenesRecomendados.containsKey(key)) {
                            detalleImagenUrl = imagenesRecomendados[key];
                          } else {
                            detalleImagenUrl = item.imagenUrl;
                          }
                          Navigator.pushNamed(
                            context,
                            '/detalles',
                            arguments: {
                              'item': item,
                              'imageUrl': detalleImagenUrl,
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Búsqueda',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                            fontSize: 16,
                          ),
                          icon: Icon(Icons.search,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(bottom: 10),
                        ),
                        onChanged: _buscar,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Recomendados',
                      onPressed: () {
                        _recomendadosFuture = _cargarRecomendados();
                        Navigator.pushNamed(
                          context,
                          '/recomendados',
                          arguments: null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    RecomendadosSection(
                      recomendadosFuture: _recomendadosFuture,
                      getImageUrl: _getImageUrl,
                      imagenesRecomendados: imagenesRecomendados,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Categorías',
                      onPressed: () {
                        Navigator.pushNamed(context, '/categorias');
                      },
                    ),
                    const SizedBox(height: 16),
                    CategoriasSection(categorias: categorias),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}

// ================= WIDGETS AUXILIARES =================

class RecomendadosSection extends StatelessWidget {
  final Future<List<dynamic>> recomendadosFuture;
  final String Function(dynamic) getImageUrl;
  final Map<String, String> imagenesRecomendados;
  const RecomendadosSection({
    super.key,
    required this.recomendadosFuture,
    required this.getImageUrl,
    required this.imagenesRecomendados,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: recomendadosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(child: Text('Error al cargar recomendados')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 220,
            child: Center(child: Text('No hay recomendados disponibles')),
          );
        } else {
          final recomendados = snapshot.data!;
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recomendados.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final item = recomendados[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < recomendados.length - 1 ? 12.0 : 0.0,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: CustomCard(
                      imageUrl: getImageUrl(item),
                      title: item.nombre,
                      subtitle: item is PuntoTuristico
                          ? item.parroquia?.nombre ?? 'Santo Domingo'
                          : (item is LocalTuristico ? item.direccion : ''),
                      onTap: () {
                        String? detalleImagenUrl;
                        String key = '';
                        if (item is PuntoTuristico) {
                          key = 'punto_${item.id}';
                        } else if (item is LocalTuristico) {
                          key = 'local_${item.id}';
                        }
                        if (imagenesRecomendados.containsKey(key)) {
                          detalleImagenUrl = imagenesRecomendados[key];
                        } else {
                          detalleImagenUrl = item.imagenUrl;
                        }
                        Navigator.pushNamed(
                          context,
                          '/detalles',
                          arguments: {
                            'item': item,
                            'imageUrl': detalleImagenUrl,
                          },
                        );
                      },
                      item: item,
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class CategoriasSection extends StatelessWidget {
  final List<Map<String, dynamic>> categorias;
  const CategoriasSection({super.key, required this.categorias});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: 160,
              child: CustomCard(
                imageUrl: categoria['imagen'],
                title: categoria['nombre'],
                onTap: () {
                  Navigator.pushNamed(context, categoria['route']);
                },
                item: categoria,
              ),
            ),
          );
        },
      ),
    );
  }
}

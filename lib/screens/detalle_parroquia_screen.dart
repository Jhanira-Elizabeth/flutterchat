import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../providers/theme_provider.dart';
import '../../services/cache_service.dart';


class DetallesParroquiaScreen extends StatefulWidget {
  const DetallesParroquiaScreen({Key? key}) : super(key: key);

  @override
  _DetallesParroquiaScreenState createState() =>
      _DetallesParroquiaScreenState();
}

class _DetallesParroquiaScreenState extends State<DetallesParroquiaScreen> with TickerProviderStateMixin {
  Future<LatLng> _getParroquiaCoords(Parroquia parroquia) async {
    final boxName = 'parroquiaCoordsCache';
    final cacheKey = parroquia.nombre;
    final cached = await CacheService.getData(boxName, cacheKey);
    if (cached != null && cached is Map<String, dynamic>) {
      return LatLng(cached['lat'] as double, cached['lng'] as double);
    }
    final locations = await geocoding.locationFromAddress(
      '${parroquia.nombre}, Santo Domingo de los Tsáchilas, Ecuador');
    if (locations.isNotEmpty) {
      final loc = locations.first;
      await CacheService.saveData(boxName, cacheKey, {
        'lat': loc.latitude,
        'lng': loc.longitude,
      });
      return LatLng(loc.latitude, loc.longitude);
    }
    return const LatLng(-0.2520, -79.1764);
  }
  late TabController _tabController;
  int _currentIndex = 0; // Para la BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Importante: liberar el controlador del TabBar
    super.dispose();
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
        case 2: // Favoritos
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
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // Accede al ThemeProvider

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final Parroquia parroquia = args['parroquia'];
    final String imageUrl = args['imageUrl'];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: Center(
                    child: Icon(Icons.broken_image, color: theme.colorScheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface.withOpacity(0.6),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parroquia.nombre,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TabBar(
                            controller: _tabController,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                            indicatorColor: theme.colorScheme.primary,
                            tabs: const [
                              Tab(text: 'Información'),
                              Tab(text: 'Ubicación'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Descripción',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    parroquia.descripcion,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Más Información',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Población: ${parroquia.poblacion}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Temperatura Promedio: ${parroquia.temperaturaPromedio}°C',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Ubicación
                          FutureBuilder<LatLng>(
                            future: _getParroquiaCoords(parroquia),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              LatLng coords = snapshot.data ?? const LatLng(-0.2520, -79.1764);
                              return SizedBox(
                                height: 250,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: coords,
                                      zoom: 13,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('parroquia'),
                                        position: coords,
                                        infoWindow: InfoWindow(title: parroquia.nombre),
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
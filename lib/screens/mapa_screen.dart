import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/punto_turistico.dart';
import '../services/api_service.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';
import '../providers/theme_provider.dart';
import '../services/cache_service.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  late Future<List<PuntoTuristico>> _puntosFuture;
  int _currentIndex = 1;
  
  // Variables para optimización
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<PuntoTuristico> _puntos = [];
  bool _isMapReady = false;
  CameraPosition? _initialCameraPosition;

  // Cache para evitar reconstrucciones innecesarias
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _puntosFuture = _fetchPuntosConCache();
    print("MapaScreen: initState - Cargando puntos turísticos...");
  }

  Future<List<PuntoTuristico>> _fetchPuntosConCache() async {
    try {
      final puntos = await _apiService.fetchPuntosTuristicos();
      
      // Preparar datos una sola vez
      await _prepareMapData(puntos);
      
      // Guardar en caché en background
      _saveToCache(puntos);
      
      return puntos;
    } catch (e) {
      print('Error al obtener puntos de la API: $e');
      
      // Intentar leer del caché
      List<PuntoTuristico> puntosCache = [];
      try {
        final allData = await CacheService.getAllData('mapaCache');
        for (var map in allData.values) {
          if (map != null) {
            puntosCache.add(PuntoTuristico.fromJson(Map<String, dynamic>.from(map)));
          }
        }
        print('Recuperados ${puntosCache.length} puntos del caché');
        
        if (puntosCache.isNotEmpty) {
          await _prepareMapData(puntosCache);
        }
      } catch (e) {
        print('Error al leer puntos del caché: $e');
      }
      
      return puntosCache;
    }
  }

  // Preparar todos los datos del mapa de una vez
  Future<void> _prepareMapData(List<PuntoTuristico> puntos) async {
    _puntos = puntos;
    
    if (puntos.isEmpty) return;

    // Calcular centro una sola vez
    double sumLat = 0;
    double sumLng = 0;
    
    for (var punto in puntos) {
      sumLat += punto.latitud;
      sumLng += punto.longitud;
    }
    
    final centerLat = sumLat / puntos.length;
    final centerLng = sumLng / puntos.length;
    
    _initialCameraPosition = CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: 12,
    );

    // Crear marcadores una sola vez
    _createMarkers(puntos);
    
    print("MapaScreen: Datos preparados - ${puntos.length} puntos, ${_markers.length} marcadores");
  }

  void _createMarkers(List<PuntoTuristico> puntos) {
    final Set<Marker> newMarkers = {};
    
    for (var punto in puntos) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(punto.id.toString()),
          position: LatLng(punto.latitud, punto.longitud),
          infoWindow: InfoWindow(
            title: punto.nombre,
            snippet: punto.descripcion.length > 50
                ? '${punto.descripcion.substring(0, 47)}...'
                : punto.descripcion,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detalles',
                arguments: punto,
              );
            },
          ),
        ),
      );
    }
    
    _markers = newMarkers;
  }

  // Guardar en caché en background
  void _saveToCache(List<PuntoTuristico> puntos) {
    Future.microtask(() async {
      for (var punto in puntos) {
        try {
          await CacheService.saveData('mapaCache', 'punto_${punto.id}', punto.toMap());
        } catch (e) {
          print('Error al guardar punto en caché: $e');
        }
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    print("MapaScreen: Mapa creado exitosamente");
  }

  void _onTabChange(int index) {
    if (_currentIndex == index) return; // Evitar navegación innecesaria
    
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
    super.build(context); // Importante para AutomaticKeepAliveClientMixin
    
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Mapa Turístico',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark 
                  ? Icons.wb_sunny 
                  : Icons.nightlight_round,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _puntosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando mapa turístico...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el mapa',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifica tu conexión a internet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay puntos turísticos disponibles',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Datos listos, mostrar mapa optimizado
            return _buildMapView(theme);
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }

  Widget _buildMapView(ThemeData theme) {
    if (_initialCameraPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Mapa optimizado
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialCameraPosition!,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false, // Reducir overhead
          liteModeEnabled: false,
          compassEnabled: true,
          trafficEnabled: false, // Desactivar tráfico para mejor rendimiento
          buildingsEnabled: true,
          // Configuraciones de rendimiento
          minMaxZoomPreference: const MinMaxZoomPreference(8.0, 18.0),
        ),
        
        // Barra de búsqueda
        _buildSearchBar(theme),
        
        // Botón de mi ubicación personalizado
        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.primary,
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar en el mapa',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
          onSubmitted: _searchLocation,
        ),
      ),
    );
  }

  void _searchLocation(String query) {
    // Implementar búsqueda de ubicaciones
    final punto = _puntos.where((p) => 
      p.nombre.toLowerCase().contains(query.toLowerCase()) ||
      p.descripcion.toLowerCase().contains(query.toLowerCase())
    ).firstOrNull;
    
    if (punto != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(punto.latitud, punto.longitud),
          15.0,
        ),
      );
    }
  }

  void _goToMyLocation() async {
    if (_mapController != null) {
      // Implementar navegación a ubicación actual
      // Aquí puedes agregar la lógica para obtener la ubicación actual
      print("Ir a mi ubicación");
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
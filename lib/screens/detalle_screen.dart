import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/punto_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/favorite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import '../../services/cache_service.dart';

class DetallesScreen extends StatefulWidget {
  final Map<String, dynamic>? itemData;
  final String? imageUrl;

  const DetallesScreen({Key? key, this.itemData, this.imageUrl})
      : super(key: key);

  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> with TickerProviderStateMixin {
  // Ejemplo: Guardar un PuntoTuristico en caché
  Future<void> guardarPuntoTuristicoEnCache(PuntoTuristico punto) async {
    await CacheService.saveData('detalleCache', 'punto_${punto.id}', punto.toMap());
  }

  // Ejemplo: Leer un PuntoTuristico del caché
  Future<PuntoTuristico?> leerPuntoTuristicoDeCache(int id) async {
    final cached = await CacheService.getData('detalleCache', 'punto_${id}');
    if (cached != null) {
      return PuntoTuristico.fromJson(Map<String, dynamic>.from(cached));
    }
    return null;
  }
  final resenasRef = FirebaseFirestore.instance.collection('resenas');
  final comentariosRef = FirebaseFirestore.instance.collection('comentarios');
  late TabController _tabController;
  int _currentIndex = 0;
  dynamic _item;
  late String _imageUrl;
  final ApiService _apiService = ApiService();
  final FavoriteService _favoriteService = FavoriteService();
  late Future<List<HorarioAtencion>> _horariosFuture;
  late Future<List<Servicio>> _serviciosFuture;
  late Future<List<Actividad>> _actividadesFuture;
  String? _barrioSector;
  String? _dueno;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _item = widget.itemData?['item'];
    _imageUrl = widget.itemData?['imageUrl'] ?? 'assets/images/Bomboli8.jpg';

    // Integración de caché para PuntoTuristico
    if (_item is PuntoTuristico) {
      final punto = _item as PuntoTuristico;
      leerPuntoTuristicoDeCache(punto.id).then((cachedPunto) async {
        if (cachedPunto != null) {
          setState(() {
            _item = cachedPunto;
          });
        } else {
          // Si no está en caché, obtén de la API y guarda en caché
          final actividades = await _apiService.fetchActividadesByPunto(punto.id);
          await guardarPuntoTuristicoEnCache(punto);
          setState(() {
            _actividadesFuture = Future.value(actividades);
          });
        }
      });
      _actividadesFuture = _fetchActividades();
      _horariosFuture = Future.value([]);
      _serviciosFuture = Future.value([]);
    } else if (_item is LocalTuristico) {
      _horariosFuture = _fetchHorarios();
      _serviciosFuture = _fetchServicios();
      _actividadesFuture = Future.value([]);
    } else {
      _horariosFuture = Future.value([]);
      _serviciosFuture = Future.value([]);
      _actividadesFuture = Future.value([]);
    }
    _getBarrioSector();
    _simulateDueno();
  }

  Future<List<Servicio>> _fetchServicios() async {
    if (_item is LocalTuristico) {
      return _apiService.fetchServiciosByLocal(_item.id);
    }
    return [];
  }

  Future<List<Actividad>> _fetchActividades() async {
    if (_item is PuntoTuristico) {
      return _apiService.fetchActividadesByPunto(_item.id);
    }
    return [];
  }

  Future<List<HorarioAtencion>> _fetchHorarios() async {
    if (_item is LocalTuristico) {
      final allHorarios = await _apiService.fetchHorariosByLocal(_item.id);
      return allHorarios
          .where((horario) => horario.idLocal == _item.id)
          .toList();
    }
    return [];
  }

  Future<void> _getBarrioSector() async {
    setState(() {
      _barrioSector = "Barrio Ejemplo";
    });
  }

  void _simulateDueno() {
    String duenoNombre = "Dueño Desconocido";
    if (_item is LocalTuristico || _item is PuntoTuristico) {
      duenoNombre = "Dueño ${(_item.id % 3) + 1}";
    }
    setState(() {
      _dueno = duenoNombre;
    });
  }

  void _openMap(double latitude, double longitude) async {
    final googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(googleUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el mapa.')),
      );
    }
  }

  String _getCategoryName(dynamic item) {
    if (item is LocalTuristico && item.etiquetas.isNotEmpty) {
      final categoria = item.etiquetas.firstWhere(
        (e) =>
            e.nombre.toLowerCase().contains('alojamiento') ||
            e.nombre.toLowerCase().contains('río') ||
            e.nombre.toLowerCase().contains('etnia') ||
            e.nombre.toLowerCase().contains('alimento') ||
            e.nombre.toLowerCase().contains('atracción'),
        orElse: () => item.etiquetas.first,
      );
      return categoria.nombre;
    } else if (item is PuntoTuristico && item.etiquetas.isNotEmpty) {
      final categoria = item.etiquetas.firstWhere(
        (e) =>
            e.nombre.toLowerCase().contains('alojamiento') ||
            e.nombre.toLowerCase().contains('río') ||
            e.nombre.toLowerCase().contains('etnia') ||
            e.nombre.toLowerCase().contains('alimento') ||
            e.nombre.toLowerCase().contains('atracción'),
        orElse: () => item.etiquetas.first,
      );
      return categoria.nombre;
    }
    return 'Desconocida';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String lugarId = (_item != null && _item.id != null) ? _item.id.toString() : '';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[200];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final dragIndicatorColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];
    final tabColor = isDarkMode ? Colors.greenAccent : Colors.green;

    String nombre = (_item != null && _item.nombre != null) ? _item.nombre : 'Detalles';
    String categoriaMostrar = _getCategoryName(_item);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Imagen superior
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  cacheHeight: 400,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 0.7, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Text(
                          nombre,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.7),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (categoriaMostrar != 'Desconocida')
                        Text(
                          categoriaMostrar,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      // Estrellas de calificación
                      StreamBuilder<QuerySnapshot>(
                        stream: resenasRef.where('idLugar', isEqualTo: lugarId).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          final docs = snapshot.data?.docs ?? [];
                          double promedio = 0;
                          if (docs.isNotEmpty) {
                            final calificaciones = docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return (data['calificacion'] ?? 0).toDouble();
                            }).toList();
                            promedio = calificaciones.reduce((a, b) => a + b) / calificaciones.length;
                          }
                          int estrellas = promedio.round();
                          return Row(
                            children: List.generate(5, (i) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.star_border,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                                  Icon(
                                    i < estrellas ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                ],
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Botón de regreso
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Botón de Favoritos
                Positioned(
                  top: MediaQuery.of(context).padding.top + 270,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: () {
                        // Implementa tu lógica de favoritos aquí
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido desplazable sobre la imagen
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dragIndicatorColor,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 20, right: 20),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: tabColor,
                        unselectedLabelColor: secondaryTextColor,
                        indicatorColor: tabColor,
                        tabs: const [
                          Tab(text: 'Información'),
                          Tab(text: 'Actividades'),
                          Tab(text: 'Ubicación'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Información
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('Categoría: $categoriaMostrar', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(height: 8),
                                  Text(_item?.descripcion ?? 'No hay descripción disponible.', style: TextStyle(color: textColor)),
                                  const SizedBox(height: 16),
                                  Text('Más Información', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(height: 8),
                                  Text('Dueño: $_dueno', style: TextStyle(color: textColor)),
                                  if (_item is LocalTuristico) ...[
                                    if ((_item as LocalTuristico).email != null)
                                      Text('Email: ${(_item as LocalTuristico).email}', style: TextStyle(color: textColor)),
                                    if ((_item as LocalTuristico).telefono != null)
                                      Text('Teléfono: ${(_item as LocalTuristico).telefono}', style: TextStyle(color: textColor)),
                                    if ((_item as LocalTuristico).direccion != null)
                                      Text('Dirección: ${(_item as LocalTuristico).direccion}', style: TextStyle(color: textColor)),
                                  ],
                                  Text('Ubicación: $_barrioSector', style: TextStyle(color: textColor)),
                                  const SizedBox(height: 24),
                                  Text('Calificación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tabColor)),
                                  const SizedBox(height: 8),
                                  if (user != null)
                                    _CalificacionWidget(lugarId: lugarId, user: user, resenasRef: resenasRef),
                                  const SizedBox(height: 24),
                                  Text('Comentarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tabColor)),
                                  const SizedBox(height: 8),
                                  if (user != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        StatefulBuilder(
                                          builder: (context, setState) {
                                            final controllerComentario = TextEditingController();
                                            return Card(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller: controllerComentario,
                                                      decoration: const InputDecoration(hintText: 'Escribe un comentario...'),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.send),
                                                    onPressed: () async {
                                                      final value = controllerComentario.text.trim();
                                                      if (value.isNotEmpty) {
                                                        // Datos extra del lugar
                                                        final nombreLugar = _item?.nombre ?? '';
                                                        final ubicacion = {
                                                          'latitud': _item?.latitud ?? '',
                                                          'longitud': _item?.longitud ?? '',
                                                        };
                                                        final descripcion = _item?.descripcion ?? '';
                                                        List actividades = [];
                                                        List servicios = [];
                                                        List horarios = [];
                                                        if (_item is PuntoTuristico) {
                                                          actividades = _item.actividades.map((a) => a.nombre).toList();
                                                        }
                                                        if (_item is LocalTuristico) {
                                                          servicios = _item.servicios.map((s) => s.servicioNombre).toList();
                                                          horarios = _item.horarios.map((h) => {
                                                            'diaSemana': h.diaSemana,
                                                            'horaInicio': h.horaInicio,
                                                            'horaFin': h.horaFin,
                                                          }).toList();
                                                        }
                                                        await comentariosRef.add({
                                                          'idLugar': lugarId,
                                                          'uid': user.uid,
                                                          'nombreUsuario': user.displayName ?? '',
                                                          'fotoUsuario': user.photoURL ?? '',
                                                          'texto': value,
                                                          'nombreLugar': nombreLugar,
                                                          'ubicacion': ubicacion,
                                                          'descripcion': descripcion,
                                                          'actividades': actividades,
                                                          'servicios': servicios,
                                                          'horarios': horarios,
                                                          'timestamp': FieldValue.serverTimestamp(),
                                                        });
                                                        setState(() {
                                                          controllerComentario.clear();
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: comentariosRef.where('idLugar', isEqualTo: lugarId).orderBy('timestamp', descending: true).snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }
                                            final docs = snapshot.data?.docs ?? [];
                                            if (docs.isEmpty) {
                                              return const Text('No hay comentarios aún.');
                                            }
                                            return Column(
                                              children: docs.map((doc) {
                                                final comentario = doc.data() as Map<String, dynamic>;
                                                return Card(
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundImage: NetworkImage(comentario['fotoUsuario'] ?? ''),
                                                    ),
                                                    title: Text(comentario['nombreUsuario'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    subtitle: Text(comentario['texto'] ?? ''),
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Actividades / Servicios / Horarios
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_item is LocalTuristico) ...[
                                    Text('Servicios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<Servicio>>(
                                      future: _serviciosFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar servicios: ${snapshot.error}', style: TextStyle(color: textColor));
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text('No hay servicios disponibles.', style: TextStyle(color: textColor));
                                        } else {
                                          final serviciosFiltrados = snapshot.data!.where((servicio) => servicio.idLocal == _item.id).toList();
                                          if (serviciosFiltrados.isEmpty) {
                                            return Text('No hay servicios disponibles para este local.', style: TextStyle(color: textColor));
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: serviciosFiltrados.map((servicio) {
                                              return Text('- ${servicio.servicioNombre}', style: TextStyle(color: textColor));
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Horarios de atención', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<HorarioAtencion>>(
                                      future: _horariosFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar horarios: ${snapshot.error}', style: TextStyle(color: textColor));
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text('No hay horarios de atención disponibles.', style: TextStyle(color: textColor));
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: snapshot.data!.map((horario) {
                                              return Text('${horario.diaSemana}: ${horario.horaInicio} - ${horario.horaFin}', style: TextStyle(color: textColor));
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ] else if (_item is PuntoTuristico) ...[
                                    Text('Actividades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<Actividad>>(
                                      future: _actividadesFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar actividades: ${snapshot.error}', style: TextStyle(color: textColor));
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text('No hay actividades disponibles.', style: TextStyle(color: textColor));
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: snapshot.data!.map((actividad) {
                                              return Text('- ${actividad.nombre} ${actividad.precio != null ? '(USD)' : ''}', style: TextStyle(color: textColor));
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                  if (_item is! LocalTuristico && _item is! PuntoTuristico)
                                    Center(child: Text('No hay información de actividades disponible.', style: TextStyle(color: textColor))),
                                ],
                              ),
                            ),
                          ),
                          // Ubicación
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ubicación en el Mapa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(height: 8),
                          if (_item?.latitud != null && _item?.longitud != null)
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: FutureBuilder(
                                future: Future.delayed(const Duration(milliseconds: 200)), // Pequeño delay para evitar freeze
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState != ConnectionState.done) {
                                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                  }
                                  return GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(_item.latitud, _item.longitud),
                                      zoom: 15,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: MarkerId(_item.id.toString()),
                                        position: LatLng(_item.latitud, _item.longitud),
                                        infoWindow: InfoWindow(title: nombre),
                                        onTap: () {
                                          _openMap(_item.latitud, _item.longitud);
                                        },
                                      ),
                                    },
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    liteModeEnabled: true, // Lite mode para mejor rendimiento
                                  );
                                },
                              ),
                            )
                          else
                            Text('Ubicación no disponible.', style: TextStyle(color: textColor)),
                                  if (_item?.latitud != null && _item?.longitud != null)
                                    ElevatedButton(
                                      onPressed: () {
                                        _openMap(_item.latitud, _item.longitud);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: tabColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Abrir en Google Maps'),
                                    ),
                                  const SizedBox(height: 16),
                                  Text('Dirección', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(height: 8),
                                  Text(((_item is LocalTuristico) ? (_item as LocalTuristico).direccion ?? 'Dirección no disponible.' : 'Dirección no disponible.'), style: TextStyle(color: textColor)),
                                ],
                              ),
                            ),
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
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.index = index;
          });
        },
      ),
    );
  }
}

// Widget para calificación sin reseña
class _CalificacionWidget extends StatefulWidget {
  final String lugarId;
  final User user;
  final CollectionReference resenasRef;
  const _CalificacionWidget({required this.lugarId, required this.user, required this.resenasRef});

  @override
  State<_CalificacionWidget> createState() => _CalificacionWidgetState();
}

class _CalificacionWidgetState extends State<_CalificacionWidget> {
  double _calificacion = 3;
  String? _docId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCalificacion();
  }

  Future<void> _loadCalificacion() async {
    final query = await widget.resenasRef
        .where('idLugar', isEqualTo: widget.lugarId)
        .where('uid', isEqualTo: widget.user.uid)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      setState(() {
        _docId = doc.id;
        _calificacion = (doc['calificacion'] ?? 3).toDouble();
        _loading = false;
      });
    } else {
      setState(() {
        _docId = null;
        _calificacion = 3;
        _loading = false;
      });
    }
  }

  Future<void> _guardarCalificacion() async {
    // Obtén el lugar desde el contexto padre
    final detallesState = context.findAncestorStateOfType<_DetallesScreenState>();
    final item = detallesState?._item;
    String comentario = '';
    // Busca el comentario del usuario si existe en la colección comentarios
    final comentariosQuery = await detallesState?.comentariosRef
        .where('idLugar', isEqualTo: widget.lugarId)
        .where('uid', isEqualTo: widget.user.uid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (comentariosQuery != null && comentariosQuery.docs.isNotEmpty) {
      final data = comentariosQuery.docs.first.data() as Map<String, dynamic>;
      comentario = data['texto'] ?? '';
    }

    // Construye los campos extra
    final nombreLugar = item?.nombre ?? '';
    final ubicacion = {
      'latitud': item?.latitud ?? '',
      'longitud': item?.longitud ?? '',
    };
    final descripcion = item?.descripcion ?? '';
    List actividades = [];
    List servicios = [];
    List horarios = [];
    if (item is PuntoTuristico && item.actividades != null) {
      actividades = item.actividades.map((a) => a.nombre).toList();
    }
    if (item is LocalTuristico && item.servicios != null) {
      servicios = item.servicios.map((s) => s.servicioNombre).toList();
    }
    if (item is LocalTuristico && item.horarios != null) {
      horarios = item.horarios.map((h) => {
        'diaSemana': h.diaSemana,
        'horaInicio': h.horaInicio,
        'horaFin': h.horaFin,
      }).toList();
    }

    final resenaData = {
      'idLugar': widget.lugarId,
      'uid': widget.user.uid,
      'nombreUsuario': widget.user.displayName ?? '',
      'fotoUsuario': widget.user.photoURL ?? '',
      'calificacion': _calificacion,
      'comentario': comentario,
      'nombreLugar': nombreLugar,
      'ubicacion': ubicacion,
      'descripcion': descripcion,
      'actividades': actividades,
      'servicios': servicios,
      'horarios': horarios,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (_docId == null) {
      final docRef = await widget.resenasRef.add(resenaData);
      setState(() {
        _docId = docRef.id;
      });
    } else {
      await widget.resenasRef.doc(_docId).update(resenaData);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calificación y reseña guardadas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu calificación:', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _calificacion,
              min: 1,
              max: 5,
              divisions: 4,
              label: _calificacion.round().toString(),
              onChanged: (val) {
                setState(() {
                  _calificacion = val;
                });
              },
            ),
            ElevatedButton(
              onPressed: _guardarCalificacion,
              child: Text(_docId == null ? 'Guardar calificación' : 'Actualizar calificación'),
            ),
          ],
        ),
      ),
    );
  }
}
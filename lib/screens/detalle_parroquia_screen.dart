import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../providers/theme_provider.dart';

class DetallesParroquiaScreen extends StatefulWidget {
  const DetallesParroquiaScreen({Key? key}) : super(key: key);

  @override
  _DetallesParroquiaScreenState createState() => _DetallesParroquiaScreenState();
}

class _DetallesParroquiaScreenState extends State<DetallesParroquiaScreen>
    with TickerProviderStateMixin {
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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final Parroquia parroquia = args['parroquia'];
    final String imageUrl = args['imageUrl'];
    // Firestore y usuario para calificaciones y comentarios
    final user = FirebaseAuth.instance.currentUser;
    final resenasRef = FirebaseFirestore.instance.collection('resenas');
    final comentariosRef = FirebaseFirestore.instance.collection('comentarios');

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
          // Promedio de estrellas en la parte superior derecha
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: StreamBuilder<QuerySnapshot>(
              stream: resenasRef.where('idLugar', isEqualTo: parroquia.id.toString()).snapshots(),
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
                          color: theme.colorScheme.onSurface,
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
                                  const SizedBox(height: 16),
                                  const SizedBox(height: 24),
                                  // Calificación y comentarios para parroquia
                                  Text('Calificación', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                                  const SizedBox(height: 8),
                                  if (user != null)
                                    _CalificacionWidget(lugarId: parroquia.id.toString(), user: user, resenasRef: resenasRef),
                                  const SizedBox(height: 24),
                                  Text('Comentarios', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
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
                                                        await comentariosRef.add({
                                                          'idLugar': parroquia.id.toString(),
                                                          'uid': user.uid,
                                                          'nombreUsuario': user.displayName ?? '',
                                                          'fotoUsuario': user.photoURL ?? '',
                                                          'texto': value,
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
                                          stream: comentariosRef.where('idLugar', isEqualTo: parroquia.id.toString()).orderBy('timestamp', descending: true).snapshots(),
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
                                                    title: Text(comentario['nombreUsuario'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
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
// ...existing code...
                          // Ubicación
                          FutureBuilder<List<geocoding.Location>>(
                            future: geocoding.locationFromAddress(
                              '${parroquia.nombre}, Santo Domingo de los Tsáchilas, Ecuador'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              LatLng coords;
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                final loc = snapshot.data!.first;
                                coords = LatLng(loc.latitude, loc.longitude);
                              } else {
                                // Coordenadas por defecto
                                coords = const LatLng(-0.2520, -79.1764);
                              }
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
    if (_docId == null) {
      final docRef = await widget.resenasRef.add({
        'idLugar': widget.lugarId,
        'uid': widget.user.uid,
        'nombreUsuario': widget.user.displayName ?? '',
        'fotoUsuario': widget.user.photoURL ?? '',
        'calificacion': _calificacion,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _docId = docRef.id;
      });
    } else {
      await widget.resenasRef.doc(_docId).update({
        'calificacion': _calificacion,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calificación guardada')),
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
            const Text('Tu calificación:', style: TextStyle(fontWeight: FontWeight.bold)),
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
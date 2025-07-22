import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/punto_turistico.dart';
import '../../models/dueno.dart';
//import '../../models/servicio.dart';
import 'package:url_launcher/url_launcher.dart';

class DetallesScreen extends StatefulWidget {
  final Map<String, dynamic>? itemData;
  final String? imageUrl;

  const DetallesScreen({Key? key, this.itemData, this.imageUrl})
      : super(key: key);

  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  dynamic _item;
  late String _imageUrl;
  late Future<List<dynamic>> _serviciosFuture;
  late Future<List<dynamic>> _actividadesFuture;
  @override
  void initState() {
    super.initState();
    // Mantener la lógica anterior: obtener imagen desde itemData['imageUrl'] y usar Bomboli8 solo como defecto
    // Acceso correcto a los datos del item
    if (widget.itemData != null && widget.itemData!['item'] != null) {
      _item = widget.itemData!['item'];
    } else {
      _item = null;
    }
    if (widget.itemData != null && widget.itemData!['imageUrl'] != null) {
      _imageUrl = widget.itemData!['imageUrl'];
    } else {
      _imageUrl = 'assets/images/Bomboli8.jpg';
    }
    _tabController = TabController(length: 3, vsync: this);
    // Inicializar futuros para actividades y servicios
    _serviciosFuture = _fetchServicios();
    _actividadesFuture = _fetchActividades();

  }

  Future<List<dynamic>> _fetchServicios() async {
    if (_item == null) return [];
    // Si es Map
    if (_item is Map) {
      final map = _item as Map;
      if (map['servicios'] != null && map['servicios'] is List) {
        return map['servicios'];
      }
    }
    // Si es objeto con propiedad servicios
    try {
      if (_item.servicios != null && _item.servicios is List) {
        return _item.servicios;
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> _fetchActividades() async {
    if (_item == null) return [];
    // Si es Map
    if (_item is Map) {
      final map = _item as Map;
      if (map['actividades'] != null && map['actividades'] is List) {
        return map['actividades'];
      }
    }
    // Si es objeto con propiedad actividades
    try {
      if (_item.actividades != null && _item.actividades is List) {
        return _item.actividades;
      }
    } catch (_) {}
    return [];
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final resenasRef = FirebaseFirestore.instance.collection('resenas');
    final comentariosRef = FirebaseFirestore.instance.collection('comentarios');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[200];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final dragIndicatorColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];
    final tabColor = isDarkMode ? Colors.greenAccent : Colors.green;
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final categoriaManual = args['categoria'] as String?;
    String categoriaMostrar = 'Desconocida';
    String descripcion = 'No hay descripción disponible.';
    String dueno = 'Desconocido';
    String barrioSector = 'Barrio Ejemplo';
    String actividades = '';
    String ubicacion = '';
    String telefonoDueno = '';
    String emailDueno = '';
    String lugarId = '';
    // Validación de _item y sus propiedades
    if (_item != null) {
      try {
        categoriaMostrar = (_item is Map)
            ? (_item['nombre'] ?? categoriaManual ?? 'Desconocida')
            : (_item.nombre ?? categoriaManual ?? 'Desconocida');
        descripcion = (_item is Map)
            ? (_item['descripcion'] ?? 'No hay descripción disponible.')
            : (_item.descripcion ?? 'No hay descripción disponible.');
        lugarId = (_item is Map)
            ? (_item['id']?.toString() ?? '')
            : (_item.id != null ? _item.id.toString() : '');
        // Mostrar solo los datos esenciales del dueño
        if (_item is Dueno) {
          final datos = _item.datosEsenciales();
          dueno = datos['nombreCompleto'] ?? 'Desconocido';
          telefonoDueno = datos['telefono'] ?? '';
          emailDueno = datos['email'] ?? '';
        } else if (_item is Map && _item['dueno'] != null) {
          final d = _item['dueno'];
          final nombreCompleto = (d['nombre'] ?? '') + (d['apellido'] != null ? ' ' + d['apellido'] : '');
          dueno = nombreCompleto.isNotEmpty ? nombreCompleto : 'Desconocido';
          telefonoDueno = d['telefono'] ?? '';
          emailDueno = d['email'] ?? '';
        } else if (_item is Map && _item['creadoPor'] != null) {
          dueno = _item['creadoPor'];
        } else if (_item is Map && _item.containsKey('creadoPor')) {
          dueno = _item['creadoPor'];
        } else if (_item.runtimeType.toString() == 'LocalTuristico') {
          dueno = 'Desconocido';
        } else if ((_item is Map ? _item['creadoPor'] : _item.creadoPor) != null) {
          dueno = _item is Map ? _item['creadoPor'] : _item.creadoPor;
        } else {
          dueno = 'Desconocido';
        }
      } catch (e) {
        categoriaMostrar = categoriaManual ?? 'Desconocida';
        descripcion = 'No hay descripción disponible.';
        dueno = 'Desconocido';
        telefonoDueno = '';
        emailDueno = '';
        lugarId = '';
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Imagen superior con promedio de calificación
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                child: _imageUrl.startsWith('http')
                    ? Image.network(_imageUrl, fit: BoxFit.cover)
                    : Image.asset(_imageUrl, fit: BoxFit.cover),
              ),
              // Flecha personalizada en la esquina superior izquierda
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: StreamBuilder<QuerySnapshot>(
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
              ),
            ],
          ),
          // Panel inferior con detalles
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
                                  Text(descripcion, style: TextStyle(color: textColor)),
                                  const SizedBox(height: 16),
                                  Text('Más Información', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(height: 8),
                                  Text('Dueño: $dueno', style: TextStyle(color: textColor)),
                                  if (telefonoDueno.isNotEmpty)
                                    Text('Teléfono: $telefonoDueno', style: TextStyle(color: textColor)),
                                  if (emailDueno.isNotEmpty)
                                    Text('Correo electrónico: $emailDueno', style: TextStyle(color: textColor)),
                                  Text('Ubicación: $barrioSector', style: TextStyle(color: textColor)),
                                  if (actividades.isNotEmpty && !actividades.contains('@'))
                                    Text('Actividades: $actividades', style: TextStyle(color: textColor)),
                                  if (ubicacion.isNotEmpty)
                                    Text('Ubicación detallada: $ubicacion', style: TextStyle(color: textColor)),
                                  // Calificación y comentarios
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
                                                        await comentariosRef.add({
                                                          'idLugar': lugarId,
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
                          // Actividades/Servicios/Horarios según tipo
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_item is LocalTuristico) ...[
                                    Text('Servicios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tabColor)),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<dynamic>>(
                                      future: _serviciosFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar servicios', style: TextStyle(color: textColor));
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text('No hay servicios disponibles.', style: TextStyle(color: textColor));
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: snapshot.data!.map((servicio) {
                                              if (servicio is Servicio) {
                                                return Text('- ${servicio.servicioNombre} ${(servicio.precio >= 0) ? "(Precio: \$${servicio.precio})" : ""}', style: TextStyle(color: textColor));
                                              } else if (servicio is Map && (servicio['servicioNombre'] != null || servicio['servicio'] != null)) {
                                                final nombre = servicio['servicioNombre'] ?? servicio['servicio'] ?? '';
                                                final precio = servicio['precio'] != null ? servicio['precio'].toString() : '';
                                                return Text('- $nombre ${(precio.isNotEmpty && double.tryParse(precio) != null && double.parse(precio) >= 0) ? "(Precio: \$$precio)" : ""}', style: TextStyle(color: textColor));
                                              } else if (servicio is String) {
                                                return Text('- $servicio', style: TextStyle(color: textColor));
                                              }
                                              return const SizedBox.shrink();
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    const SizedBox(height: 16),
                                    Text('Horarios de atención', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tabColor)),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<dynamic>>(
                                      future: _item != null && _item is LocalTuristico && _item.horarios != null ? Future.value(_item.horarios) : Future.value([]),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar horarios', style: TextStyle(color: textColor));
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text('No hay horarios de atención disponibles.', style: TextStyle(color: textColor));
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: snapshot.data!.map((horario) {
                                              if (horario is Map) {
                                                final dia = horario['diaSemana'] ?? '';
                                                final inicio = horario['horaInicio'] ?? '';
                                                final fin = horario['horaFin'] ?? '';
                                                return Text('$dia: $inicio - $fin', style: TextStyle(color: textColor));
                                              } else if (horario is HorarioAtencion) {
                                                return Text('${horario.diaSemana}: ${horario.horaInicio} - ${horario.horaFin}', style: TextStyle(color: textColor));
                                              }
                                              return const SizedBox.shrink();
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ] else if (_item is PuntoTuristico) ...[
                                    Text('Actividades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tabColor)),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<dynamic>>(
                                      future: _actividadesFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar actividades', style: TextStyle(color: textColor));
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text('No hay actividades disponibles.', style: TextStyle(color: textColor));
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: snapshot.data!.map((actividad) {
                                              if (actividad is Actividad) {
                                                return Text('- ${actividad.nombre} ${(actividad.precio >= 0) ? "(Precio: \$${actividad.precio})" : ""}', style: TextStyle(color: textColor));
                                              } else if (actividad is Map && actividad['nombre'] != null) {
                                                final precio = actividad['precio'] != null ? actividad['precio'].toString() : '';
                                                return Text('- ${actividad['nombre']} ${(precio.isNotEmpty && double.tryParse(precio) != null && double.parse(precio) >= 0) ? "(Precio: \$$precio)" : ""}', style: TextStyle(color: textColor));
                                              } else if (actividad is String) {
                                                return Text('- $actividad', style: TextStyle(color: textColor));
                                              }
                                              return const SizedBox.shrink();
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ] else ...[
                                    Center(child: Text('No hay información de actividades ni servicios disponible.', style: TextStyle(color: textColor))),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // Ubicación (validación reforzada de tipo y propiedades)
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tabColor)),
                                  const SizedBox(height: 12),
                                  Builder(
                                    builder: (context) {
                                      double? lat;
                                      double? lng;
                                      String direccion = '';
                                      if (_item == null) {
                                        return Text('No hay información de ubicación disponible.', style: TextStyle(color: secondaryTextColor));
                                      }
                                      if (_item is Map) {
                                        final map = _item as Map;
                                        if (map['latitud'] != null && map['longitud'] != null) {
                                          lat = double.tryParse(map['latitud'].toString());
                                          lng = double.tryParse(map['longitud'].toString());
                                        }
                                        if (map['direccion'] != null) {
                                          direccion = map['direccion'].toString();
                                        }
                                      }
                                      if (_item is LocalTuristico) {
                                        final local = _item as LocalTuristico;
                                        lat = local.latitud;
                                        lng = local.longitud;
                                      }
                                      if (_item is PuntoTuristico) {
                                        final punto = _item as PuntoTuristico;
                                        lat = punto.latitud;
                                        lng = punto.longitud;
                                      }
                                      if (lat == null || lng == null) {
                                        return Text('No hay coordenadas para mostrar el mapa.', style: TextStyle(color: secondaryTextColor));
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (direccion.isNotEmpty)
                                            Text(direccion, style: TextStyle(color: textColor)),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            height: 250,
                                            child: GoogleMap(
                                              initialCameraPosition: CameraPosition(
                                                target: LatLng(lat, lng),
                                                zoom: 15,
                                              ),
                                              markers: {
                                                Marker(
                                                  markerId: const MarkerId('ubicacion'),
                                                  position: LatLng(lat, lng),
                                                  infoWindow: InfoWindow(title: direccion.isNotEmpty ? direccion : 'Ubicación'),
                                                ),
                                              },
                                              zoomControlsEnabled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.map),
                                            label: const Text('Abrir en Google Maps'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: tabColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                                              if (await canLaunch(url.toString())) {
                                                await launch(url.toString());
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('No se pudo abrir Google Maps')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
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
      SnackBar(content: Text('Calificación guardada')),
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

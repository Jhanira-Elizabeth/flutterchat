import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../../models/punto_turistico.dart';
import '../../models/dueno.dart';
// import '../../models/servicio.dart';

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
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final lugarId = _item != null && _item.id != null ? _item.id.toString() : '';
    final resenasRef = FirebaseFirestore.instance.collection('resenas');
    final comentariosRef = FirebaseFirestore.instance.collection('comentarios');
    // ...existing code...
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[200];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final dragIndicatorColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];
    final tabColor = isDarkMode ? Colors.greenAccent : Colors.green;
    // Variables necesarias
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
    if (_item != null) {
      categoriaMostrar = _item.nombre ?? categoriaManual ?? 'Desconocida';
      descripcion = _item.descripcion ?? 'No hay descripción disponible.';
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
      } else if (_item.creadoPor != null) {
        dueno = _item.creadoPor;
      } else {
        dueno = 'Desconocido';
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
                                  // Solo calificación
                                  const SizedBox(height: 24),
                                  Text('Calificación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: tabColor)),
                                  const SizedBox(height: 8),
                                  if (user != null)
                                    _CalificacionWidget(lugarId: lugarId, user: user, resenasRef: resenasRef),
                                  const SizedBox(height: 24),
                                  // COMENTARIOS ILIMITADOS
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
                          // Actividades
                          Center(child: Text('Actividades', style: TextStyle(color: textColor))),
                          // Ubicación
                          Center(child: Text('Ubicación', style: TextStyle(color: textColor))),
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

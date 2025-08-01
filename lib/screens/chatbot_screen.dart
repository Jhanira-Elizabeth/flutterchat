import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tursd/widgets/bottom_navigation_bar_turistico.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../services/cache_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  bool _waitingBotReply = false;
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 2; // Índice inicial para el chatbot, como estaba
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    // Oculta las barras de sistema para pantalla completa (gestos para mostrar navegación)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Iniciar o cargar la última conversación (persistencia mientras la app esté abierta)
    _initOrLoadLastConversation();
  }

  Future<void> _initOrLoadLastConversation() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final boxName = 'chatbotCache';
    final cacheKey = 'lastConv_$uid';
    final cached = await CacheService.getData(boxName, cacheKey);
    if (cached != null && cached is Map<String, dynamic>) {
      setState(() {
        _currentConversationId = cached['convId'] as String?;
      });
      await _loadChatHistoryFromCache(cached['messages'] as List?);
    } else {
      final convRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(uid)
          .collection('conversaciones');
      final querySnapshot =
          await convRef.orderBy('timestamp', descending: true).limit(1).get();
      if (querySnapshot.docs.isEmpty) {
        // No hay conversaciones previas, crea una nueva
        await _startNewConversation();
      } else {
        final lastConv = querySnapshot.docs.first;
        setState(() {
          _currentConversationId = lastConv.id;
        });
        await _loadChatHistory(conversationId: _currentConversationId);
      }
    }
  }

  Future<void> _loadChatHistoryFromCache(List? cachedMessages) async {
    setState(() {
      _messages.clear();
      if (cachedMessages == null || cachedMessages.isEmpty) {
        _messages.add(_Message(
          text: "Hola viajero! ¿Qué quieres saber hoy?",
          isUser: false,
        ));
      } else {
        for (var msg in cachedMessages) {
          _messages.add(_Message(
            text: msg['text'] ?? '',
            isUser: msg['isUser'] ?? false,
          ));
        }
      }
    });
    _scrollToBottom();
  }

  Future<void> _startNewConversation() async {
    // Crea una nueva conversación y actualiza el estado
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final convRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('conversaciones');
    final newConv = await convRef.add({
      'timestamp': FieldValue.serverTimestamp(),
    });
    setState(() {
      _currentConversationId = newConv.id;
      _messages.clear();
      _messages.add(_Message(
        text: "Hola viajero! ¿Qué quieres saber hoy?",
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  Future<void> _loadChatHistory({List<DocumentSnapshot>? docs, String? conversationId}) async {
    final convId = conversationId ?? _currentConversationId;
    if (convId == null) return;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final msgRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('conversaciones')
        .doc(convId)
        .collection('mensajes');
    final querySnapshot = docs == null ? await msgRef.orderBy('timestamp').get() : null;
    final messagesDocs = docs ?? querySnapshot!.docs;

    setState(() {
      _messages.clear();
      if (messagesDocs.isEmpty) {
        _messages.add(_Message(
          text: "Hola viajero! ¿Qué quieres saber hoy?",
          isUser: false,
        ));
      } else {
        for (var doc in messagesDocs) {
          final data = doc.data() as Map<String, dynamic>;
          _messages.add(_Message(
            text: data['text'] ?? '',
            isUser: data['isUser'] ?? false,
          ));
        }
      }
    });
    // Guardar historial en Hive
    final boxName = 'chatbotCache';
    final cacheKey = 'lastConv_$uid';
    final cacheMessages = _messages.map((m) => {'text': m.text, 'isUser': m.isUser}).toList();
    await CacheService.saveData(boxName, cacheKey, {
      'convId': convId,
      'messages': cacheMessages,
    });
    _scrollToBottom();
  }

  Future<List<List<DocumentSnapshot>>> _getConversationsHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final convRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('conversaciones');
    final convSnapshot =
        await convRef.orderBy('timestamp', descending: true).get();
    List<List<DocumentSnapshot>> conversations = [];
    for (var convDoc in convSnapshot.docs) {
      final msgRef = convDoc.reference.collection('mensajes');
      final msgSnapshot = await msgRef.orderBy('timestamp').get();
      conversations.add(msgSnapshot.docs);
    }
    return conversations;
  }

  bool _historyModalOpen = false;

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
          break;
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _currentConversationId == null || _waitingBotReply) return;
    setState(() {
      _waitingBotReply = true;
    });

    // Obtén el UID del usuario actual
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final msgRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('conversaciones')
        .doc(_currentConversationId)
        .collection('mensajes');

    // Obtén la ubicación actual
    double? latitude;
    double? longitude;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        latitude = position.latitude;
        longitude = position.longitude;
      }
    } catch (e) {
      // Si ocurre un error, no se envía ubicación
      latitude = null;
      longitude = null;
    }

    // Guarda el mensaje del usuario en Firestore
    await msgRef.add({
      'text': text,
      'isUser': true,
      'timestamp': FieldValue.serverTimestamp(),
      'latitude': latitude,
      'longitude': longitude,
    });

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
    });

    _scrollToBottom();

    // Llama al método que genera la respuesta y maneja la estructura
    String reply = await _getFormattedBotReply(text,
        latitude: latitude, longitude: longitude);

    // Guarda la respuesta del bot en Firestore
    await msgRef.add({
      'text': reply,
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messages.add(_Message(text: reply, isUser: false));
      _waitingBotReply = false;
    });

    // Guardar historial actualizado en Hive
    final boxName = 'chatbotCache';
    final cacheKey = 'lastConv_$uid';
    final cacheMessages = _messages.map((m) => {'text': m.text, 'isUser': m.isUser}).toList();
    await CacheService.saveData(boxName, cacheKey, {
      'convId': _currentConversationId,
      'messages': cacheMessages,
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Nuevo método para obtener y formatear la respuesta del bot, ahora acepta ubicación
  Future<String> _getFormattedBotReply(String userText,
      {double? latitude, double? longitude}) async {
    try {
      print('Current conversation ID: $_currentConversationId');
      final body = {
        'chat_id': _currentConversationId ?? 'sin_chat_id',
        'message': userText,
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
      };

      print('Sending body: ${jsonEncode(body)}');
      final response = await http.post(
        Uri.parse('https://tursd-chatbot-fqdxgsa4arb8fjf9.brazilsouth-01.azurewebsites.net/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Respuesta cruda del chatbot: ${response.body}');
      print('Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        try {
          final decodedData = jsonDecode(response.body);
          if (decodedData is Map && decodedData.containsKey('response')) {
            final botResponse = decodedData['response'];
            if (botResponse is Map && botResponse.containsKey('tipo_respuesta')) {
              String tipoRespuesta = botResponse['tipo_respuesta'];
              switch (tipoRespuesta) {
                case 'hoteles_internet':
                  List<dynamic> hoteles = botResponse['data'] ?? [];
                  if (hoteles.isNotEmpty) {
                    String hotelesStr = hoteles.map((hotel) {
                      String nombre = hotel['nombre'] ?? 'Hotel Desconocido';
                      String precio = hotel['precio'] ?? 'Precio no disponible';
                      String rating = hotel['rating'] ?? 'Sin calificar';
                      String descripcion = hotel['descripcion'] ?? '';
                      String fuente = hotel['fuente'] ?? 'Desconocida';
                      String ubicacion = hotel['direccion'] ?? '';
                      String mapsQuery;
                      if (ubicacion.toString().trim().isNotEmpty) {
                        mapsQuery = ubicacion.toString();
                      } else {
                        mapsQuery = '$nombre, Santo Domingo de los Tsáchilas, Ecuador';
                      }
                      final query = Uri.encodeComponent(mapsQuery);
                      String mapsUrl = '[Ver en Google Maps](https://www.google.com/maps/search/?api=1&query=$query)';
                      return '🏨 **$nombre**\n$mapsUrl\n'
                          '   💰 $precio\n'
                          '   ⭐ $rating\n'
                          '   📍 $descripcion\n'
                          '   🔗 Fuente: $fuente';
                    }).join('\n\n');
                    return '¡Perfecto! Encontré estos hoteles actualizados para ti en Santo Domingo de los Tsáchilas:\n\n$hotelesStr\n\n'
                        '📋 **Para reservar:**\n'
                        '• Booking.com - Mejores precios y cancelación gratis\n'
                        '• Expedia - Paquetes hotel + vuelo\n'
                        '• Contacto directo con el hotel\n\n'
                        '🏞️ **También te recomiendo visitar:**\n'
                        '• Malecón del Río Toachi (zona céntrica)\n'
                        '• Parque Zaracay (área turística)\n'
                        '• Comunidades Tsáchilas (turismo cultural)\n\n'
                        '¿Te gustaría que te cuente sobre algún lugar turístico específico mientras planificas tu estadía? 😊';
                  } else {
                    return botResponse['texto'] ?? 'No se encontraron hoteles actualizados en internet.';
                  }
                case 'lugar_turistico_bd':
                  String nombre = botResponse['nombre_lugar'] ?? 'Lugar turístico';
                  String descripcion = botResponse['descripcion'] ?? '';
                  List<dynamic> servicios = botResponse['servicios'] ?? [];
                  List<dynamic> actividades = botResponse['actividades'] ?? [];
                  String serviciosStr = servicios.isNotEmpty ? servicios.map((s) => '- $s').join('\n') : 'No se especifican servicios.';
                  String actividadesStr = actividades.isNotEmpty ? actividades.map((a) => '- $a').join('\n') : 'No se especifican actividades.';
                  String textoOriginal = botResponse['texto_original_bd'] ?? 'No hay información detallada disponible.';
                  return textoOriginal;
                case 'servicios_info':
                  String servicioBuscado = botResponse['servicio_buscado'] ?? 'servicio';
                  List<dynamic> lugares = botResponse['lugares'] ?? [];
                  if (lugares.isNotEmpty) {
                    String lugaresStr = lugares.map((l) {
                      String nombreLugar = l is Map && l.containsKey('nombre') ? l['nombre'] : l.toString();
                      String ubicacion = l is Map && l.containsKey('direccion') ? l['direccion'] : '';
                      String mapsQuery;
                      if (ubicacion.toString().trim().isNotEmpty) {
                        mapsQuery = ubicacion.toString();
                      } else {
                        mapsQuery = '$nombreLugar, Santo Domingo de los Tsáchilas, Ecuador';
                      }
                      final query = Uri.encodeComponent(mapsQuery);
                      String mapsUrl = '[Ver en Google Maps](https://www.google.com/maps/search/?api=1&query=$query)';
                      return '🏞️ **$nombreLugar**\n$mapsUrl';
                    }).join('\n');
                    return '¡Claro! Encontré lugares con **$servicioBuscado** en Santo Domingo de los Tsáchilas, como:\n\n'
                        '$lugaresStr\n\n'
                        '¿Te gustaría saber más sobre alguno de ellos o te ayudo a buscar más opciones?';
                  } else {
                    return botResponse['texto'] ?? 'No encontré lugares específicos con $servicioBuscado en mi base de datos local.';
                  }
                case 'lugares_multiples':
                  String terminoRelacionado = botResponse['termino_relacionado'] ?? 'este tipo de lugar';
                  List<dynamic> lugares = botResponse['lugares'] ?? [];
                  if (lugares.isNotEmpty) {
                    String lugaresStr = lugares.map((l) {
                      String nombreLugar = l is Map && l.containsKey('nombre') ? l['nombre'] : l.toString();
                      String ubicacion = l is Map && l.containsKey('direccion') ? l['direccion'] : '';
                      String mapsQuery;
                      if (ubicacion.toString().trim().isNotEmpty) {
                        mapsQuery = ubicacion.toString();
                      } else {
                        mapsQuery = '$nombreLugar, Santo Domingo de los Tsáchilas, Ecuador';
                      }
                      final query = Uri.encodeComponent(mapsQuery);
                      String mapsUrl = '[Ver en Google Maps](https://www.google.com/maps/search/?api=1&query=$query)';
                      return '🏞️ **$nombreLugar**\n$mapsUrl';
                    }).join('\n');
                    return '¡Excelente! Aquí tienes varios lugares relacionados con **$terminoRelacionado** en Santo Domingo de los Tsáchilas:\n\n'
                        '$lugaresStr\n\n'
                        '¿Cuál de ellos te interesa más?';
                  } else {
                    return botResponse['texto'] ?? 'No encontré lugares relacionados.';
                  }
                case 'info_general_internet':
                  String texto = botResponse['texto'] ?? 'No se encontró información relevante en internet.';
                  return '🌐 (Búsqueda en Internet)\n$texto';
                case 'general':
                  return botResponse['texto'] ?? 'Lo siento, no tengo una respuesta específica para eso en este momento. Intenta otra pregunta.';
                case 'error':
                  return '¡Ups! Ocurrió un error: ${botResponse['texto'] ?? 'Desconocido'}. Por favor, inténtalo de nuevo.';
                default:
                  return 'Recibí una respuesta del chatbot que no puedo interpretar correctamente. Contenido: ${jsonEncode(botResponse)}';
              }
            }
          }
          return decodedData['response'].toString();
        } catch (e) {
          // Si no es JSON válido, muestra el texto plano
          return response.body;
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('response') && errorData['response'] is Map && errorData['response'].containsKey('texto')) {
            return 'Error del chatbot (${response.statusCode}): ${errorData['response']['texto']}';
          }
          return 'Error del servidor (${response.statusCode}): ${response.body}';
        } catch (e) {
          // Si no es JSON válido, muestra el texto plano
          return response.body;
        }
      }
    } catch (e) {
      return 'Ocurrió un error al consultar el chatbot: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: const Text('ChatBot'),
        backgroundColor: const Color(0xFF007BFF),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Limpiar chat',
            onPressed: () async {
              await _startNewConversation();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 15.0),
            child: GestureDetector(
              onTap: () async {
                if (_historyModalOpen) return;
                _historyModalOpen = true;
                final conversations = await _getConversationsHistory();
                await showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    // ...existing code...
                    return Container(
                      // ...existing code...
                    );
                  },
                );
                _historyModalOpen = false;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  if (msg.isUser) {
                    // Mensaje del usuario: igual que antes
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 148, 219, 252),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: MarkdownBody(
                          data: msg.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.black87, fontSize: 16),
                            strong: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                            h1: const TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
                            h2: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                            listBullet: const TextStyle(color: Colors.black87, fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }
                  // Mensaje del bot: renderizado especial para botones de mapa por opción
                  // Dividir el texto en bloques por doble salto de línea
                  final bloques = msg.text.split(RegExp(r'\n\s*\n'));
                  List<Widget> bloquesWidgets = [];
                  for (final bloque in bloques) {
                    // Buscar nombre del lugar (por ejemplo, **Nombre**)
                    final nombreMatch = RegExp(r'\*\*(.*?)\*\*').firstMatch(bloque);
                    String? nombreLugar = nombreMatch != null ? nombreMatch.group(1)?.trim() : null;
                    // Buscar dirección (línea que contiene 'Dirección:' o 'Ubicación:')
                    final direccionMatch = RegExp(r'(Dirección|Ubicación):?\s*(.*)', caseSensitive: false).firstMatch(bloque);
                    String? direccion = direccionMatch != null ? direccionMatch.group(2)?.trim() : null;
                    // Frases genéricas a evitar
                    final frasesGenericas = [
                      'Consulta su página para más detalles sobre la dirección y actividades.',
                      'Santo Domingo, consulta su página para más detal',
                      'Consulta su página para más detalles.',
                      'No disponible',
                      'Sin dirección',
                      'No especificada',
                      '',
                    ];
                    // Limpiar dirección de Markdown y espacios
                    if (direccion != null) {
                      direccion = direccion.replaceAll(RegExp(r'\*'), '').trim();
                    }
                    // Limpiar nombre de Markdown y espacios
                    if (nombreLugar != null) {
                      nombreLugar = nombreLugar.replaceAll(RegExp(r'\*'), '').trim();
                    }
                    // Determinar mapsQuery
                    String mapsQuery = '';
                    if (direccion != null &&
                        direccion.isNotEmpty &&
                        !frasesGenericas.any((f) => direccion!.toLowerCase().contains(f.toLowerCase()))) {
                      mapsQuery = direccion;
                    } else if (nombreLugar != null && nombreLugar.isNotEmpty) {
                      mapsQuery = '$nombreLugar, Santo Domingo de los Tsáchilas, Ecuador';
                    }
                    // Widget del bloque (Markdown)
                    bloquesWidgets.add(
                      MarkdownBody(
                        data: bloque,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: Colors.black87, fontSize: 16),
                          strong: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                          h1: const TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
                          h2: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                          listBullet: const TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                      ),
                    );
                    // Si hay query de mapa, poner botón justo después del bloque
                    if (mapsQuery.isNotEmpty) {
                      bloquesWidgets.add(
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.map, color: Colors.blue),
                              tooltip: 'Ver en Google Maps',
                              onPressed: () async {
                                final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapsQuery)}';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: bloquesWidgets,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _waitingBotReply
                      ? SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF007BFF)),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}

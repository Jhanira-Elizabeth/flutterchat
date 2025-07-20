import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tursd/widgets/bottom_navigation_bar_turistico.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
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

    // Iniciar o cargar la última conversación
    _initOrLoadLastConversation();
  }

  Future<void> _initOrLoadLastConversation() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final convRef = FirebaseFirestore.instance.collection('chats').doc(uid).collection('conversaciones');
    final querySnapshot = await convRef.orderBy('timestamp', descending: true).limit(1).get();
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

  Future<void> _startNewConversation() async {
    // Crea una nueva conversación y actualiza el estado
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final convRef = FirebaseFirestore.instance.collection('chats').doc(uid).collection('conversaciones');
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
    final msgRef = FirebaseFirestore.instance.collection('chats').doc(uid).collection('conversaciones').doc(convId).collection('mensajes');
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
    _scrollToBottom();
  }

  Future<List<List<DocumentSnapshot>>> _getConversationsHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final convRef = FirebaseFirestore.instance.collection('chats').doc(uid).collection('conversaciones');
    final convSnapshot = await convRef.orderBy('timestamp', descending: true).get();
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
          // Ya estamos en el chatbot, no navegamos de nuevo a la misma pantalla
          break;
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _currentConversationId == null) return;

    // Obtén el UID del usuario actual
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final msgRef = FirebaseFirestore.instance.collection('chats').doc(uid).collection('conversaciones').doc(_currentConversationId).collection('mensajes');

    // Guarda el mensaje del usuario en Firestore
    await msgRef.add({
      'text': text,
      'isUser': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
    });

    _scrollToBottom();

    // Llama al método que genera la respuesta y maneja la estructura
    String reply = await _getFormattedBotReply(text);

    // Guarda la respuesta del bot en Firestore
    await msgRef.add({
      'text': reply,
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messages.add(_Message(text: reply, isUser: false));
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

  // Nuevo método para obtener y formatear la respuesta del bot
  Future<String> _getFormattedBotReply(String userText) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://tursd-chatbot-fqdxgsa4arb8fjf9.brazilsouth-01.azurewebsites.net/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userText}),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map && decodedData.containsKey('response')) {
          final botResponse = decodedData[
              'response']; // Este es el diccionario estructurado de Python

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

                    return '🏨 **$nombre**\n'
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
                  return botResponse['texto'] ??
                      'No se encontraron hoteles actualizados en internet.';
                }

              case 'lugar_turistico_bd':
                String nombre =
                    botResponse['nombre_lugar'] ?? 'Lugar turístico';
                String descripcion = botResponse['descripcion'] ??
                    ''; // La descripción ya viene del backend
                List<dynamic> servicios = botResponse['servicios'] ?? [];
                List<dynamic> actividades = botResponse['actividades'] ?? [];

                String serviciosStr = servicios.isNotEmpty
                    ? servicios.map((s) => '- $s').join('\n')
                    : 'No se especifican servicios.';
                String actividadesStr = actividades.isNotEmpty
                    ? actividades.map((a) => '- $a').join('\n')
                    : 'No se especifican actividades.';

                // El texto_original_bd ya debería contener el formato Markdown (negritas)
                String textoOriginal = botResponse['texto_original_bd'] ??
                    'No hay información detallada disponible.';

                // Asegúrate de que el nombre del lugar siempre esté en negritas al inicio del texto
                // Si el texto original ya tiene el nombre en negritas (como debería venir del backend),
                // no es necesario añadirlo de nuevo a menos que quieras una introducción específica.
                // Para simplificar y usar el markdown del backend:
                return textoOriginal;

              case 'servicios_info':
                String servicioBuscado =
                    botResponse['servicio_buscado'] ?? 'servicio';
                List<dynamic> lugares = botResponse['lugares'] ?? [];
                if (lugares.isNotEmpty) {
                  return '¡Claro! Encontré lugares con **$servicioBuscado** en Santo Domingo de los Tsáchilas, como:\n\n'
                      '${lugares.map((l) => '🏞️ **$l**').join('\n')}\n\n' // Nombres de lugares en negritas aquí también
                      '¿Te gustaría saber más sobre alguno de ellos o te ayudo a buscar más opciones?';
                } else {
                  return botResponse['texto'] ??
                      'No encontré lugares específicos con $servicioBuscado en mi base de datos local.';
                }

              case 'lugares_multiples':
                String terminoRelacionado =
                    botResponse['termino_relacionado'] ?? 'este tipo de lugar';
                List<dynamic> lugares = botResponse['lugares'] ?? [];
                if (lugares.isNotEmpty) {
                  return '¡Excelente! Aquí tienes varios lugares relacionados con **$terminoRelacionado** en Santo Domingo de los Tsáchilas:\n\n'
                      '${lugares.map((l) => '🏞️ **$l**').join('\n')}\n\n' // Nombres de lugares en negritas aquí también
                      '¿Cuál de ellos te interesa más?';
                } else {
                  return botResponse['texto'] ??
                      'No encontré lugares relacionados.';
                }

              case 'info_general_internet':
                String texto = botResponse['texto'] ??
                    'No se encontró información relevante en internet.';
                return '🌐 (Búsqueda en Internet)\n$texto';

              case 'general':
                // Para respuestas generales o de fallback
                return botResponse['texto'] ??
                    'Lo siento, no tengo una respuesta específica para eso en este momento. Intenta otra pregunta.';

              case 'error':
                // Para errores específicos del bot
                return '¡Ups! Ocurrió un error: ${botResponse['texto'] ?? 'Desconocido'}. Por favor, inténtalo de nuevo.';

              default:
                // Si el tipo de respuesta no se reconoce
                return 'Recibí una respuesta del chatbot que no puedo interpretar correctamente. Contenido: ${jsonEncode(botResponse)}';
            }
          }
        }
        // Fallback si la respuesta no contiene 'response' o no es un mapa
        return decodedData['response'].toString();
      } else {
        // Manejar otros códigos de estado HTTP
        final errorData = jsonDecode(response.body);
        if (errorData is Map &&
            errorData.containsKey('response') &&
            errorData['response'] is Map &&
            errorData['response'].containsKey('texto')) {
          return 'Error del chatbot (${response.statusCode}): ${errorData['response']['texto']}';
        }
        return 'Error del servidor (${response.statusCode}): ${response.body}';
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Historial de conversaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (conversations.isEmpty)
                            const Text('No hay conversaciones previas.')
                          else
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                itemCount: conversations.length,
                                itemBuilder: (context, idx) {
                                  final conv = conversations[idx].cast<QueryDocumentSnapshot>();
                                  final validMsgs = conv.where((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    return (data['text'] != null && (data['text'] as String).trim().isNotEmpty);
                                  }).toList();
                                  if (validMsgs.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  QueryDocumentSnapshot? firstUserMsg;
                                  try {
                                    firstUserMsg = validMsgs.firstWhere((doc) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      return data['isUser'] == true;
                                    }, orElse: () => validMsgs[0]);
                                  } catch (e) {
                                    firstUserMsg = validMsgs[0];
                                  }
                                  final data = firstUserMsg.data() as Map<String, dynamic>;
                                  final date = (data['timestamp'] as Timestamp?)?.toDate();
                                  final preview = data['text'] ?? '';
                                  return ListTile(
                                    title: Text(preview.isNotEmpty ? preview : 'Sin mensajes de usuario', maxLines: 1, overflow: TextOverflow.ellipsis),
                                    subtitle: date != null ? Text('${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}') : null,
                                    onTap: validMsgs.isNotEmpty
                                        ? () {
                                            Navigator.pop(context);
                                            _loadChatHistory(docs: validMsgs);
                                        }
                                        : null,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
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
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? const Color.fromARGB(255, 148, 219, 252) // Celeste claro para usuario
                            : const Color(0xFFF8F9FA),
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
                          p: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          strong: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          h1: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          listBullet: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
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
                  IconButton(
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

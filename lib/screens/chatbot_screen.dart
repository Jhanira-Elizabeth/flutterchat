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

  @override
  void initState() {
    super.initState();
    // Oculta las barras de sistema para pantalla completa (gestos para mostrar navegación)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Cargar historial de Firestore
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(uid).collection('mensajes');
    final querySnapshot = await chatRef.orderBy('timestamp').get();

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _messages.add(_Message(
          text: "Hola viajero! ¿Qué quieres saber hoy?",
          isUser: false,
        ));
      });
    } else {
      setState(() {
        _messages.clear();
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          _messages.add(_Message(
            text: data['text'] ?? '',
            isUser: data['isUser'] ?? false,
          ));
        }
      });
    }
    _scrollToBottom();
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
          // Ya estamos en el chatbot, no navegamos de nuevo a la misma pantalla
          break;
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Obtén el UID del usuario actual
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'anonimo';
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(uid).collection('mensajes');

    // Guarda el mensaje del usuario en Firestore
    await chatRef.add({
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
    await chatRef.add({
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Encabezado tipo ChatGPT con tres líneas horizontales en la parte superior derecha
            Container(
              padding: const EdgeInsets.only(top: 12, right: 20, left: 20, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 32,
                        height: 3,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 3,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 3,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                            ? const Color(0xFF007BFF)
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
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                          strong: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          h1: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          listBullet: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
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

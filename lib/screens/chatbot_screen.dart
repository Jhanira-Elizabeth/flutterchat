import 'package:flutter/material.dart';
import 'package:tursd/widgets/bottom_navigation_bar_turistico.dart';
import 'package:tursd/data/sample_data.dart';
import 'package:tursd/data/buscador_inteligente.dart';
import 'package:tursd/services/database_service.dart';
import 'package:tursd/models/punto_turistico.dart';
import 'dart:math';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _messages.add(_Message(
      text: "Hola viajero! ¿Qué quieres saber hoy?",
      isUser: false,
    ));
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
    });

    String reply = await _generateBotReply(text);
    setState(() {
      _messages.add(_Message(text: reply, isUser: false));
    });

    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String> _generateBotReply(String userText) async {
    // 1. Saludos y frases motivacionales cálidas y variadas
    final greetings = [
      '¡Hola! 😊',
      '¡Qué gusto saludarte! 👋',
      '¡Bienvenido! 🌟',
      '¡Hola, explorador! 🧭',
      '¡Hola! ¿Listo para descubrir algo nuevo? 🗺️',
      '¡Saludos, viajero curioso! ✈️',
      '¡Encantado de ayudarte! 🤗',
      '¡Hola! ¿En qué puedo inspirarte hoy? 💡',
    ];
    final motivational = [
      'Recuerda que cada aventura comienza con una pregunta. 🚀',
      '¡Explorar es vivir! 🌄',
      '¡Tu próxima experiencia inolvidable está a un mensaje de distancia! ✨',
      '¡Déjame ayudarte a encontrar el mejor destino! 🏞️',
      '¡La curiosidad es el primer paso para una gran aventura! 🔍',
      '¡Nunca dejes de descubrir! 🌍',
      '¡El mundo está lleno de sorpresas para ti! 🎁',
      '¡Hoy puede ser el día de tu próxima gran experiencia! 🥳',
    ];
    final random = Random();
    final greeting = greetings[random.nextInt(greetings.length)];
    final motiv = motivational[random.nextInt(motivational.length)];

    // 2. Buscar usando BuscadorInteligente
    final resultadosInteligente = BuscadorInteligente.buscar(userText);
    if (resultadosInteligente.isNotEmpty) {
      // Plantillas variadas y cálidas para mostrar resultados
      final templates = [
        (r) => '¡Genial! Encontré esto para ti: ${r.nombre} - ${r.descripcion} 😃',
        (r) => '¿Buscabas algo como "${r.nombre}"? Aquí tienes: ${r.descripcion} 🏝️',
        (r) => '¡Mira lo que encontré! ${r.nombre}: ${r.descripcion} ✨',
        (r) => 'Te recomiendo: ${r.nombre}. ${r.descripcion} 👍',
        (r) => '¡Perfecto para ti! ${r.nombre} - ${r.descripcion} 🌟',
        (r) => '¡Esto podría interesarte! ${r.nombre}: ${r.descripcion} 😉',
        (r) => '¡No te pierdas ${r.nombre}! ${r.descripcion} 🏆',
        (r) => '¡Una excelente opción! ${r.nombre} - ${r.descripcion} 🥇',
      ];
      final buffer = StringBuffer();
      buffer.writeln('$greeting $motiv');
      for (var punto in resultadosInteligente.take(3)) {
        final template = templates[random.nextInt(templates.length)];
        buffer.writeln(template(punto));
      }
      return buffer.toString().trim();
    }

    // 2. Si no hay resultados inteligentes, buscar en la base de datos y fallback
    final dbService = DatabaseService();
    final results = await dbService.buscarGeneralConFallback(userText);

    // Prioridad: parroquias, puntos turísticos, actividades, locales
    if (results['parroquiasDb'] != null && results['parroquiasDb']!.isNotEmpty) {
      final parroquia = results['parroquiasDb']!.first;
      return 'Parroquia: ${parroquia['nombre']}\n${parroquia['descripcion'] ?? "Sin descripción"}';
    }
    if (results['parroquiasSample'] != null && results['parroquiasSample']!.isNotEmpty) {
      final parroquia = results['parroquiasSample']!.first;
      return 'Parroquia: ${parroquia.nombre}\n${parroquia.descripcion}';
    }
    if (results['puntosDb'] != null && results['puntosDb']!.isNotEmpty) {
      final punto = results['puntosDb']!.first;
      return 'Punto turístico: ${punto['nombre']}\n${punto['descripcion'] ?? "Sin descripción"}';
    }
    if (results['puntosSample'] != null && results['puntosSample']!.isNotEmpty) {
      final punto = results['puntosSample']!.first;
      return 'Punto turístico: ${punto.nombre}\n${punto.descripcion}';
    }

    // Si no hay resultados locales, buscar los 3 lugares más relevantes en Google Places de Santo Domingo de los Tsáchilas, Ecuador
    final googleResults = await dbService.buscarLugaresGoogle(userText);
    if (googleResults != null && googleResults.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln('Estos son los lugares más relevantes de Santo Domingo de los Tsáchilas, Ecuador:');
      for (var lugar in googleResults.take(3)) {
        buffer.writeln('• ${lugar['name']}\n  Dirección: ${lugar['formatted_address'] ?? lugar['vicinity'] ?? "No disponible"}\n  Valoración: ${lugar['rating'] ?? "No disponible"} ⭐');
      }
      return buffer.toString();
    }

    // Si no encuentra nada local, mostrar el mensaje amigable de Google Places
    if (results['googlePlaces'] != null && results['googlePlaces'].isNotEmpty) {
      // results['googlePlaces'] es una lista de mensajes amigables (string)
      return results['googlePlaces'].join("\n\n");
    }

    // Mensaje genérico si no hay nada
    return 'No encontré información sobre tu búsqueda. ¿Quieres intentar con otra palabra clave?';
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
          break;
      }
    });
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
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
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
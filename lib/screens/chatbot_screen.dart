import 'package:flutter/material.dart';
import 'package:tursd/widgets/bottom_navigation_bar_turistico.dart';
// import 'package:tursd/data/sample_data.dart'; // No usado en este snippet, puedes eliminar si no lo usas
// import 'package:tursd/data/buscador_inteligente.dart'; // No usado
// import 'package:tursd/services/database_service.dart'; // No usado
// import 'package:tursd/models/punto_turistico.dart'; // No usado
// import 'dart:math'; // No usado
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // Solo una definición de las variables
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 2; // Índice inicial para el chatbot, como estaba

  @override
  void initState() {
    super.initState();
    // Solo una definición de initState
    _messages.add(_Message(
      text: "Hola viajero! ¿Qué quieres saber hoy?",
      isUser: false,
    ));
  }

  // Una sola definición del método _onTabChange para manejar la navegación
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
        case 3: // Si el chatbot es el índice 3
          // Ya estamos en el chatbot, no navegamos
          break;
      }
    });
  }

  // Solo una definición del método _sendMessage
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
    });

    // Desplazarse al final después de añadir el mensaje del usuario
    _scrollToBottom();

    String reply = await _generateBotReply(text);
    setState(() {
      _messages.add(_Message(text: reply, isUser: false));
    });

    _controller.clear();
    // Desplazarse al final después de añadir la respuesta del bot
    _scrollToBottom();
  }

  // Helper para desplazar el scroll
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80, // Pequeño extra para padding
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Solo una definición del método _generateBotReply
  Future<String> _generateBotReply(String userText) async {
    try {
      final response = await http.post(
        // ¡Esta es la URL que consultas y ya está correctamente aquí!
        Uri.parse('https://tursd-chatbot-fqdxgsa4arb8fjf9.brazilsouth-01.azurewebsites.net/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // La API devuelve un mapa con 'response' o 'reply'
        if (data is Map && data.containsKey('response')) { // Asumo 'response' basándome en el ejemplo de Flask
          if (data['response'].toString().trim().isNotEmpty) {
            return data['response'].toString();
          }
        } else if (data is Map && data.containsKey('reply')) { // Si la API retorna 'reply'
          if (data['reply'].toString().trim().isNotEmpty) {
            return data['reply'].toString();
          }
        }
        // Si la respuesta es una cadena directa (menos común pero posible)
        else if (data is String && data.trim().isNotEmpty) {
          return data;
        }
        // Si el cuerpo de la respuesta es directamente la cadena (como fallback)
        else if (response.body.toString().trim().isNotEmpty) {
          return response.body.toString();
        }
      } else {
        // Manejar otros códigos de estado HTTP (e.g., 405, 500)
        return 'Error del servidor (${response.statusCode}): ${response.body}';
      }
      return 'No se pudo obtener una respuesta válida del chatbot de Azure.';
    } catch (e) {
      return 'Ocurrió un error al consultar el chatbot de Azure: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
      // Aquí se pasa la ÚNICA definición de _onTabChange
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange, // Usa el método _onTabChange definido arriba
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}
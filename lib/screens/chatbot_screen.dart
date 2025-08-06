import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  String? _ultimoLugarSeleccionado;
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _waitingBotReply = false;
  List<String> _menuOptions = [];
  List<String> _lastMenuOptions = [];
  String? _chatId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startChat();
  } 

  //Sistema de envío de mensajes al bot
  //Acceso a la API del bot en Azure
  Future<Map<String, dynamic>> _sendToBot(Map<String, dynamic> body) async {
    final url = Uri.parse('https://tursd-asistente-menu-ehg2aqcag2djbcgk.canadacentral-01.azurewebsites.net/chat');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_id': _chatId ?? 'flutter_frontend',
        ...body,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'response': 'Error del servidor: ${response.statusCode}'};
    }
  }

  Future<void> _startChat() async {
    setState(() {
      _messages.clear();
      _menuOptions.clear();
      _lastMenuOptions.clear();
      _waitingBotReply = true;
      _ultimoLugarSeleccionado = null;
    });
    final response = await _sendToBot({});
    _handleBotResponse(response);
  }

  void _handleBotResponse(Map<String, dynamic> data) {
    setState(() {
      _waitingBotReply = false;
      
      // Guardar el lugar seleccionado si viene en la respuesta
      if (data.containsKey('lugar_seleccionado')) {
        _ultimoLugarSeleccionado = data['lugar_seleccionado'];
        print('[DEBUG] Lugar seleccionado guardado: $_ultimoLugarSeleccionado');
      }
      
      // 1. Si hay menú en la respuesta, lo usamos y lo guardamos como último menú
      if (data.containsKey('menu') && data['menu'] is List) {
        _menuOptions = List<String>.from(data['menu']);
        _lastMenuOptions = List<String>.from(data['menu']);
      } else if (data.containsKey('opciones') && data['opciones'] is List) {
        _menuOptions = List<String>.from(data['opciones']);
        _lastMenuOptions = List<String>.from(data['opciones']);
      } else {
        // 2. Si no hay menú pero hay uno anterior, lo mostramos
        _menuOptions = List<String>.from(_lastMenuOptions);
      }

      String responseText = (data['response'] ?? '').toString();

      // Si la respuesta es detalles de un lugar, guardar el nombre para la próxima ubicación
      final detallesLugarReg = RegExp(r'Detalles de ([^:]+):', caseSensitive: false);
      final matchDetalles = detallesLugarReg.firstMatch(responseText);
      if (matchDetalles != null) {
        _ultimoLugarSeleccionado = matchDetalles.group(1)?.trim();
        print('[DEBUG] Lugar extraído de detalles: $_ultimoLugarSeleccionado');
      }

      // Si la respuesta está vacía y hay menú, mostrar mensaje de bienvenida
      if (responseText.trim().isEmpty && _menuOptions.isNotEmpty) {
        responseText = '¡Hola! ¿En qué puedo ayudarte?';
      }

      // Manejar respuesta de ubicación
      if (data.containsKey('ubicacion') && data['ubicacion'] is Map) {
        final ubicacion = data['ubicacion'];
        _showLocationMessage(ubicacion);
      } else {
        // Mensaje normal
        print('[CHATBOT] $responseText');
        _messages.add(_Message(text: responseText, isUser: false));
      }

      // Si hay lugares, agregarlos como mensajes con enlace a Maps
      if (data.containsKey('lugares') && data['lugares'] is List) {
        final lugares = data['lugares'] as List;
        for (var l in lugares) {
          String nombreLugar = l is Map && l.containsKey('nombre') ? l['nombre'].toString() : l.toString();
          String ubicacion = l is Map && l.containsKey('direccion') ? l['direccion'].toString() : '';
          String mapsQuery;
          if (ubicacion.trim().isNotEmpty) {
            mapsQuery = ubicacion;
          } else {
            mapsQuery = '$nombreLugar, Santo Domingo de los Tsáchilas, Ecuador';
          }
          final query = Uri.encodeComponent(mapsQuery);
          String mapsUrl = '[Ver en Google Maps](https://www.google.com/maps/search/?api=1&query=$query)';
          String lugarMsg = '**$nombreLugar**\n$mapsUrl';
          print('[CHATBOT] $lugarMsg');
          _messages.add(_Message(text: lugarMsg, isUser: false));
        }
      }
    });
    _scrollToBottom();
  }

  void _showLocationMessage(Map<String, dynamic> ubicacion) {
    final nombre = ubicacion['nombre']?.toString() ?? '';
    final direccion = ubicacion['direccion']?.toString() ?? '';
    final latitud = ubicacion['latitud'];
    final longitud = ubicacion['longitud'];

    String locationText = '';
    if (nombre.isNotEmpty) {
      locationText += '**$nombre**\n';
    }
    if (direccion.isNotEmpty) {
      locationText += '$direccion\n';
    }

    print('[CHATBOT] $locationText');
    _messages.add(_Message(
      text: locationText.trim(),
      isUser: false,
      ubicacion: ubicacion,
    ));
  }

  Future<void> _openGoogleMaps(String direccion) async {
    // Crear una búsqueda específica y detallada para Santo Domingo de los Tsáchilas
    String searchQuery;
    if (direccion.isNotEmpty) {
      // Si ya incluye información de la ciudad, usar tal como está
      if (direccion.toLowerCase().contains('santo domingo')) {
        searchQuery = direccion;
      } else {
        // Si no, agregar la información completa de la ciudad
        searchQuery = '$direccion, Santo Domingo de los Tsáchilas, Ecuador';
      }
    } else {
      searchQuery = 'Santo Domingo de los Tsáchilas, Ecuador';
    }
    
    final query = Uri.encodeComponent(searchQuery);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    
    print('[DEBUG] Abriendo Google Maps con: $searchQuery');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }
  }

  void _sendUserMessage(String text) async {
    if (text.trim().isEmpty || _waitingBotReply) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _waitingBotReply = true;
      _menuOptions.clear();
    });
    _controller.clear();
    _scrollToBottom();
    
    Map<String, dynamic> body = {'seleccion': text};
    
    // Si el usuario pulsa 'Ver ubicación', enviar también el último lugar seleccionado
    if (text == 'Ver ubicación' && _ultimoLugarSeleccionado != null) {
      body['lugar_seleccionado'] = _ultimoLugarSeleccionado;
      print('[DEBUG] Enviando lugar_seleccionado: $_ultimoLugarSeleccionado');
    }
    
    final response = await _sendToBot(body);
    _handleBotResponse(response);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        title: const Text('ChatBot Turístico'),
        backgroundColor: const Color(0xFF007BFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar conversación',
            onPressed: _waitingBotReply ? null : _startChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_menuOptions.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                // Si es el último elemento y hay opciones de menú, renderiza los botones como mensaje
                if (_menuOptions.isNotEmpty && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _menuOptions.map((option) {
                          return ElevatedButton(
                            onPressed: _waitingBotReply ? null : () => _sendUserMessage(option),
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
                
                // Mensajes normales
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (msg.text.isNotEmpty)
                          MarkdownBody(
                            data: msg.text,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 16),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF007BFF),
                              ),
                            ),
                          ),
                        // Si el mensaje tiene ubicación, mostrar botón de Google Maps
                        if (msg.ubicacion != null) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              final ubicacion = msg.ubicacion!;
                              final nombreLugar = ubicacion['nombre']?.toString() ?? '';
                              final parroquia = ubicacion.containsKey('parroquia') ? ubicacion['parroquia']?.toString() : null;
                              
                              // Crear una búsqueda más específica combinando nombre y parroquia
                              String searchQuery = nombreLugar;
                              if (parroquia != null && parroquia.isNotEmpty) {
                                searchQuery += ', Parroquia $parroquia';
                              }
                              searchQuery += ', Santo Domingo de los Tsáchilas, Ecuador';
                              
                              _openGoogleMaps(searchQuery);
                            },
                            icon: const Icon(Icons.map, color: Colors.white),
                            label: const Text('Ver en Google Maps', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? ubicacion;
  
  _Message({
    required this.text, 
    required this.isUser, 
    this.ubicacion,
  });
}
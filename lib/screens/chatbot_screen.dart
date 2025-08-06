import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  String? _ultimoLugarSeleccionado;
  String? _fechaViaje;
  String? _horaSalida;
  Position? _ubicacionActual;
  
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _waitingBotReply = false;
  bool _esperandoFecha = false;
  bool _esperandoHora = false;
  List<String> _menuOptions = [];
  List<String> _lastMenuOptions = [];
  String? _chatId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _obtenerUbicacionActual();
    _startChat();
  }

  // Obtener ubicación actual del usuario
  Future<void> _obtenerUbicacionActual() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('[DEBUG] Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[DEBUG] Permisos de ubicación denegados permanentemente');
        return;
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _ubicacionActual = position;
      });
      
      print('[DEBUG] Ubicación obtenida: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('[ERROR] Error al obtener ubicación: $e');
    }
  }

  //Sistema de envío de mensajes al bot
  //Acceso a la API del bot en Azure
  Future<Map<String, dynamic>> _sendToBot(Map<String, dynamic> body) async {
    final url = Uri.parse('https://tursd-asistente-menu-ehg2aqcag2djbcgk.canadacentral-01.azurewebsites.net/chat');
    
    // Agregar ubicación actual si está disponible
    if (_ubicacionActual != null) {
      body['ubicacion_actual'] = {
        'latitud': _ubicacionActual!.latitude,
        'longitud': _ubicacionActual!.longitude,
      };
    }
    
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
      _fechaViaje = null;
      _horaSalida = null;
      _esperandoFecha = false;
      _esperandoHora = false;
    });
    final response = await _sendToBot({});
    _handleBotResponse(response);
  }

  void _handleBotResponse(Map<String, dynamic> data) {
    setState(() {
      _waitingBotReply = false;
      
      // Manejar estados de espera
      _esperandoFecha = data['esperando_fecha'] == true;
      _esperandoHora = data['esperando_hora'] == true;
      
      // Guardar información del agendamiento
      if (data.containsKey('lugar_seleccionado')) {
        _ultimoLugarSeleccionado = data['lugar_seleccionado'];
        print('[DEBUG] Lugar seleccionado guardado: $_ultimoLugarSeleccionado');
      }
      
      if (data.containsKey('fecha_viaje')) {
        _fechaViaje = data['fecha_viaje'];
        print('[DEBUG] Fecha de viaje guardada: $_fechaViaje');
      }
      
      if (data.containsKey('hora_salida')) {
        _horaSalida = data['hora_salida'];
        print('[DEBUG] Hora de salida guardada: $_horaSalida');
      }
      
      // Manejar generación de ruta
      if (data.containsKey('generar_ruta') && data['generar_ruta'] == true) {
        _generarRutaGoogleMaps(data['destino']);
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

  Future<void> _generarRutaGoogleMaps(Map<String, dynamic> destino) async {
    if (_ubicacionActual == null) {
      _mostrarSnackBar('No se pudo obtener tu ubicación actual');
      return;
    }

    try {
      final lat = _ubicacionActual!.latitude;
      final lng = _ubicacionActual!.longitude;
      final destinoNombre = destino['nombre']?.toString() ?? '';
      final destinoDireccion = destino['direccion']?.toString() ?? destinoNombre;
      
      // URL para navegación con Google Maps desde ubicación actual
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$lat,$lng&destination=${Uri.encodeComponent(destinoDireccion)}&travelmode=driving'
      );
      
      print('[DEBUG] Generando ruta desde ($lat, $lng) hacia: $destinoDireccion');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _mostrarSnackBar('Abriendo navegación en Google Maps...');
      } else {
        _mostrarSnackBar('No se pudo abrir Google Maps');
      }
    } catch (e) {
      print('[ERROR] Error al generar ruta: $e');
      _mostrarSnackBar('Error al generar la ruta');
    }
  }

  void _mostrarSnackBar(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
      _mostrarSnackBar('No se pudo abrir Google Maps');
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
    
    // Agregar contexto de agendamiento si estamos en proceso
    if (_esperandoFecha) {
      body['esperando_fecha'] = true;
      if (_ultimoLugarSeleccionado != null) {
        body['lugar_seleccionado'] = _ultimoLugarSeleccionado;
      }
    }
    
    if (_esperandoHora) {
      body['esperando_hora'] = true;
      if (_ultimoLugarSeleccionado != null) {
        body['lugar_seleccionado'] = _ultimoLugarSeleccionado;
      }
      if (_fechaViaje != null) {
        body['fecha_viaje'] = _fechaViaje;
      }
    }
    
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

  Widget _buildInputField() {
    // Si estamos esperando fecha o hora, mostrar un campo especializado
    if (_esperandoFecha) {
      return _buildDateInputField();
    } else if (_esperandoHora) {
      return _buildTimeInputField();
    } else {
      return _buildNormalInputField();
    }
  }

  Widget _buildDateInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(top: BorderSide(color: Colors.orange.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ingresa la fecha de tu visita',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'DD/MM/YYYY (ej: 25/12/2024)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: const Icon(Icons.date_range),
                  ),
                  keyboardType: TextInputType.datetime,
                  enabled: !_waitingBotReply,
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: _waitingBotReply ? null : () => _sendUserMessage(_controller.text),
                backgroundColor: Colors.orange,
                child: _waitingBotReply
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(top: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hora de salida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'HH:MM (ej: 09:30)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: const Icon(Icons.schedule),
                  ),
                  keyboardType: TextInputType.datetime,
                  enabled: !_waitingBotReply,
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: _waitingBotReply ? null : () => _sendUserMessage(_controller.text),
                backgroundColor: Colors.blue,
                child: _waitingBotReply
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNormalInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              enabled: !_waitingBotReply,
              onSubmitted: _waitingBotReply ? null : _sendUserMessage,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _waitingBotReply ? null : () => _sendUserMessage(_controller.text),
            backgroundColor: const Color(0xFF007BFF),
            child: _waitingBotReply
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
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
          // Mostrar indicador de ubicación
          if (_ubicacionActual != null)
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.green),
              tooltip: 'Ubicación obtenida',
              onPressed: () {
                _mostrarSnackBar('Ubicación actual: ${_ubicacionActual!.latitude.toStringAsFixed(6)}, ${_ubicacionActual!.longitude.toStringAsFixed(6)}');
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.location_off, color: Colors.red),
              tooltip: 'Obtener ubicación',
              onPressed: _obtenerUbicacionActual,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar conversación',
            onPressed: _waitingBotReply ? null : _startChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mostrar información de agendamiento activo si existe
          if (_ultimoLugarSeleccionado != null && (_fechaViaje != null || _horaSalida != null))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_available, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Agendamiento en proceso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Lugar: $_ultimoLugarSeleccionado'),
                  if (_fechaViaje != null) Text('Fecha: $_fechaViaje'),
                  if (_horaSalida != null) Text('Hora de salida: $_horaSalida'),
                ],
              ),
            ),
          
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
                          // Dar colores especiales a ciertos botones
                          Color buttonColor = Colors.blue;
                          Color textColor = Colors.white;
                          
                          if (option == "Agendar visita") {
                            buttonColor = Colors.orange;
                          } else if (option == "Sí, generar ruta" || option == "Si, generar ruta") {
                            buttonColor = Colors.green;
                          } else if (option == "Cancelar agendamiento") {
                            buttonColor = Colors.red;
                          } else if (option == "Ver ubicación") {
                            buttonColor = Colors.purple;
                          }
                          
                          return ElevatedButton(
                            onPressed: _waitingBotReply ? null : () => _sendUserMessage(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
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
          
          // Campo de entrada adaptativo
          _buildInputField(),
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
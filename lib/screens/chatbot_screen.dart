import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/visita.dart';
import '../services/visita_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  // Utilidad para comparar acciones ignorando tildes y espacios invisibles
  bool _accionEsAgendar(String texto) {
    String normalizado = texto
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '') // quita caracteres raros
        .replaceAll(RegExp(r'\s+'), ' ') // espacios múltiples a uno solo
        .trim();
    return normalizado == 'agendar visita';
  }
  
  // Normaliza todos los espacios (incluyendo no separables) a espacio simple y trim
  String _normalizarEspacios(String? texto) {
    if (texto == null) return '';
    return texto.replaceAll(RegExp(r'\s+'), ' ').replaceAll(String.fromCharCode(160), ' ').trim();
  }

  // Extrae los días permitidos del último mensaje del bot
  List<String> _extractDiasPermitidos() {
    // Busca en el último mensaje del bot los días de la semana
    final dias = <String>[];
    final diasSemana = [
      'Lunes', 'Martes', 'Miércoles', 'Miercoles', 'Jueves', 'Viernes', 'Sábado', 'Sabado', 'Domingo'
    ];
    for (final msg in _messages.reversed) {
      for (final dia in diasSemana) {
        final reg = RegExp('•? ?$dia:', caseSensitive: false);
        if (reg.hasMatch(msg.text)) {
          if (!dias.contains(dia)) dias.add(dia);
        }
      }
      if (dias.isNotEmpty) break;
    }
    return dias;
  }

  // Formatea DateTime a DD/MM/YYYY
  String _formatDateDDMMYYYY(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  String? _ultimoLugarSeleccionado;
  String? _fechaViaje;
  String? _horaSalida;
  Position? _ubicacionActual;
  bool _visitaAgendada = false;
  bool _procesoAgendamiento = false; // (Se usa en el flujo de agendamiento)
  String? _inputMode; // 'text', 'menu', etc.
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _waitingBotReply = false;
  bool _esperandoFecha = false;
  bool _esperandoHora = false;
  bool _esperandoConfirmacionAgendamiento = false;
  List<String> _menuOptions = [];
  List<String> _lastMenuOptions = [];
  String? _chatId;
  String? _googleAccessToken; // Guardar el accessToken de Google

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _obtenerUbicacionActual();
    _obtenerGoogleAccessToken();
    _startChat();
  }

  // Obtiene el accessToken de Google si el usuario está logueado
  Future<void> _obtenerGoogleAccessToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Usar AuthService para obtener el accessToken
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signInSilently();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          setState(() {
            _googleAccessToken = googleAuth.accessToken;
          });
        }
      }
    } catch (e) {
      print('[ERROR] No se pudo obtener el accessToken de Google: $e');
    }
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
          _mostrarSnackBar('Se necesitan permisos de ubicación para generar rutas');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[DEBUG] Permisos de ubicación denegados permanentemente');
        _mostrarSnackBar('Por favor, habilita los permisos de ubicación en configuración');
        return;
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      setState(() {
        _ubicacionActual = position;
      });
      
      print('[DEBUG] Ubicación obtenida: ${position.latitude}, ${position.longitude}');
      _mostrarSnackBar('Ubicación obtenida correctamente');
    } catch (e) {
      print('[ERROR] Error al obtener ubicación: $e');
      _mostrarSnackBar('No se pudo obtener la ubicación actual');
    }
  }

  //Sistema de envío de mensajes al bot
  //Acceso a la API del bot
  Future<Map<String, dynamic>> _sendToBot(Map<String, dynamic> body) async {
    final url = Uri.parse('http://192.168.1.7:8000/chat');
    
    // Agregar ubicación actual si está disponible
    if (_ubicacionActual != null) {
      body['ubicacion_actual'] = {
        'latitud': _ubicacionActual!.latitude,
        'longitud': _ubicacionActual!.longitude,
      };
    }
    
    final requestPayload = {
      'chat_id': _chatId ?? 'flutter_frontend',
      ...body,
    };
    
    print('[API][SEND] => ${jsonEncode(requestPayload)}');
    
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestPayload),
          )
          .timeout(const Duration(seconds: 300));
      
      print('[API][RECV] <= status: ${response.statusCode} body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'response': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('[ERROR] Error de conexión: $e');
      return {'response': 'Error de conexión. Verifica tu conexión a internet.'};
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
      _esperandoConfirmacionAgendamiento = false;
      _visitaAgendada = false;
      _procesoAgendamiento = false;
      _inputMode = null;
    });
    final response = await _sendToBot({});
    _handleBotResponse(response);
  }

  void _handleBotResponse(Map<String, dynamic> data) {
    print('[API][PARSE] <= $data');
    setState(() {
      _waitingBotReply = false;

      // Nuevo: manejar input_mode y proceso_agendamiento
      _inputMode = data['input_mode']?.toString();
      _procesoAgendamiento = data['proceso_agendamiento'] == true;
      _esperandoFecha = data['esperando_fecha'] == true || data['proceso_agendamiento'] == 'esperando_fecha' || data['input_mode'] == 'date';
      _esperandoHora = data['esperando_hora'] == true || data['proceso_agendamiento'] == 'esperando_hora' || data['input_mode'] == 'time';
      final visitaAgendadaAntes = _visitaAgendada;
      _visitaAgendada = data['visita_agendada'] == true;

      // Guardar visita en Firebase solo si acaba de agendarse
      if (!visitaAgendadaAntes && _visitaAgendada && _ultimoLugarSeleccionado != null && _fechaViaje != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Intentar extraer más datos del lugar si están disponibles
          String nombreLugar = _ultimoLugarSeleccionado ?? '';
          String tipoLugar = '';
          String? imagenUrl;
          String lugarId = '';
          if (data.containsKey('lugar_id')) {
            lugarId = data['lugar_id'].toString();
          }
          if (data.containsKey('tipo_lugar')) {
            tipoLugar = data['tipo_lugar'].toString();
          }
          if (data.containsKey('imagen_url')) {
            imagenUrl = data['imagen_url'].toString();
          }
          // Si no hay id, usar nombre como id fallback
          if (lugarId.isEmpty) lugarId = nombreLugar;
          // Parsear fecha
          DateTime fechaVisita;
          try {
            // Soporta formatos 'dd/MM/yyyy' o 'yyyy-MM-dd'
            if (_fechaViaje!.contains('/')) {
              final partes = _fechaViaje!.split('/');
              fechaVisita = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
            } else {
              fechaVisita = DateTime.parse(_fechaViaje!);
            }
          } catch (_) {
            fechaVisita = DateTime.now();
          }
          final visita = Visita(
            id: '', // Firestore lo asigna
            userId: user.uid,
            lugarId: lugarId,
            nombreLugar: nombreLugar,
            tipoLugar: tipoLugar,
            imagenUrl: imagenUrl,
            fechaVisita: fechaVisita,
          );
          VisitaService().guardarVisita(visita);
        }
      }

      // Guardar información del agendamiento
      if (data.containsKey('lugar_seleccionado')) {
        _ultimoLugarSeleccionado = _normalizarEspacios(data['lugar_seleccionado']);
        print('[DEBUG] Lugar seleccionado guardado: $_ultimoLugarSeleccionado');
      }
      // Aceptar tanto 'fecha_viaje' como 'fecha_visita' para mantener la fecha correctamente
      if (data.containsKey('fecha_visita') && data['fecha_visita'] != null) {
        _fechaViaje = data['fecha_visita'];
        print('[DEBUG] Fecha de visita guardada: $_fechaViaje');
      } else if (data.containsKey('fecha_viaje') && data['fecha_viaje'] != null) {
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

      // Manejar opciones de menú
      if (data.containsKey('menu') && data['menu'] is List) {
        _menuOptions = List<String>.from(data['menu']);
        _lastMenuOptions = List<String>.from(data['menu']);
      } else if (data.containsKey('opciones') && data['opciones'] is List) {
        _menuOptions = List<String>.from(data['opciones']);
        _lastMenuOptions = List<String>.from(data['opciones']);
      } else {
        _menuOptions = List<String>.from(_lastMenuOptions);
      }

      String responseText = (data['response'] ?? '').toString();

      // Si la respuesta es detalles de un lugar, guardar el nombre para contexto
      final detallesLugarReg = RegExp(r'Detalles de ([^:]+):', caseSensitive: false);
      final matchDetalles = detallesLugarReg.firstMatch(responseText);
      if (matchDetalles != null) {
        _ultimoLugarSeleccionado = _normalizarEspacios(matchDetalles.group(1));
        print('[DEBUG] Lugar extraído de detalles: $_ultimoLugarSeleccionado');
      }

      // Si la respuesta está vacía y hay menú, mostrar mensaje de bienvenida
      if (responseText.trim().isEmpty && _menuOptions.isNotEmpty) {
        responseText = '¡Hola! Soy tu asistente turístico inteligente. ¿En qué puedo ayudarte?';
      }

      // Manejar respuesta de ubicación
      if (data.containsKey('ubicacion') && data['ubicacion'] is Map) {
        final ubicacion = data['ubicacion'];
        _showLocationMessage(ubicacion);
      } else if (responseText.isNotEmpty) {
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

    // FUNCIONALIDAD INTELIGENTE: Después de mostrar ubicación, preguntar sobre agendar visita
    if (nombre.isNotEmpty && !_visitaAgendada) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _esperandoConfirmacionAgendamiento = true;
          _menuOptions = ["Sí, agendar visita", "No, solo consulta", "Volver al inicio"];
        });
        _messages.add(_Message(
          text: "¿Te gustaría que te ayude a agendar tu visita a $nombre?",
          isUser: false,
        ));
        _scrollToBottom();
      });
    }
  }

  Future<void> _generarRutaGoogleMaps(Map<String, dynamic> destino) async {
    if (_ubicacionActual == null) {
      _mostrarSnackBar('Obteniendo tu ubicación actual...');
      await _obtenerUbicacionActual();
      
      if (_ubicacionActual == null) {
        _mostrarSnackBar('No se pudo obtener tu ubicación actual. Por favor, habilita el GPS.');
        return;
      }
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
        
        // Mensaje de confirmación
        setState(() {
          _messages.add(_Message(
            text: "🗺️ **Ruta generada exitosamente**\n\nSe ha abierto Google Maps con la ruta desde tu ubicación actual hasta $destinoNombre.\n\n¡Que disfrutes tu visita!",
            isUser: false,
          ));
        });
        _scrollToBottom();
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
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openGoogleMaps(String direccion) async {
    String searchQuery;
    if (direccion.isNotEmpty) {
      if (direccion.toLowerCase().contains('santo domingo')) {
        searchQuery = direccion;
      } else {
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

    // Mapear "Sí, agendar visita" y "Si, agendar visita" a "Agendar visita" para el backend
    String seleccionMapped = text.trim();
    if (seleccionMapped.toLowerCase() == 'sí, agendar visita' || seleccionMapped.toLowerCase() == 'si, agendar visita') {
      seleccionMapped = 'Agendar visita';
    }
    // Si el usuario pulsa "Sí, generar ruta" o "Si, generar ruta", enviar el nombre del último lugar seleccionado y accion
    bool esGenerarRuta = seleccionMapped.toLowerCase() == 'sí, generar ruta' || seleccionMapped.toLowerCase() == 'si, generar ruta';

    // Si el usuario pulsa "No, gracias" en el contexto de agendamiento/ruta, reiniciar el chat/menu
    if (seleccionMapped.toLowerCase() == 'no, gracias') {
      await _startChat();
      return;
    }

    Map<String, dynamic> body;
    if (esGenerarRuta && _ultimoLugarSeleccionado != null) {
      body = {
        'seleccion': _ultimoLugarSeleccionado,
        'accion': 'generar_ruta',
      };
    } else {
      body = {'seleccion': seleccionMapped};
    }

    // Si el usuario está agendando una visita o estamos en el flujo de agendamiento, incluir el accessToken de Google si está disponible
    if ((_accionEsAgendar(seleccionMapped) || _procesoAgendamiento || _esperandoHora || _inputMode == 'time') && _googleAccessToken != null) {
      body['google_access_token'] = _googleAccessToken;
      print('[DEBUG] Incluyendo google_access_token en el request');
    }

    // Si estamos esperando la hora, guardar la hora ingresada
    if (_esperandoHora || _inputMode == 'time') {
      _horaSalida = text.trim();
    }

    print('[USER][SEND] $text');
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _waitingBotReply = true;
      _menuOptions.clear();
      if (_esperandoConfirmacionAgendamiento) {
        _esperandoConfirmacionAgendamiento = false;
      }
    });
    _controller.clear();
    _scrollToBottom();

    // CORREGIDO: enviar input_mode si está presente
    if (_inputMode != null) {
      body['input_mode'] = _inputMode;
    }

    // SIEMPRE enviar proceso_agendamiento con el valor correcto en cada paso
    if (_esperandoHora || _inputMode == 'time') {
      body['proceso_agendamiento'] = "esperando_hora";
      if (_horaSalida != null) {
        body['hora_salida'] = _horaSalida;
      }
    } else if (_esperandoFecha || _inputMode == 'date') {
      body['proceso_agendamiento'] = "esperando_fecha";
    }
    // SIEMPRE reenviar fecha_visita y hora_salida si están disponibles
    if (_fechaViaje != null && _fechaViaje!.isNotEmpty) {
      body['fecha_visita'] = _fechaViaje;
    }
    if (_horaSalida != null && _horaSalida!.isNotEmpty) {
      body['hora_salida'] = _horaSalida;
    }
    // Siempre enviar lugar_seleccionado si está disponible (para no perder contexto en el backend)
    if (_ultimoLugarSeleccionado != null) {
      body['lugar_seleccionado'] = _normalizarEspacios(_ultimoLugarSeleccionado);
    }

    // Si el usuario pulsa una acción que requiere contexto de lugar, enviar también el último lugar seleccionado
    final accionesLugar = [
      'Ver ubicación',
      'Sí, agendar visita',
      'Si, agendar visita',
      'Agendar visita',
      'Ver horarios',
      'Ver actividades',
      'Ver servicios',
    ];
    if (accionesLugar.any((accion) => text.trim().toLowerCase() == accion.toLowerCase()) && _ultimoLugarSeleccionado != null) {
      body['lugar_seleccionado'] = _normalizarEspacios(_ultimoLugarSeleccionado);
      print('[DEBUG] Enviando lugar_seleccionado: ${_normalizarEspacios(_ultimoLugarSeleccionado)}');
    }

    // Enviar ubicación actual si está disponible
    if (_ubicacionActual != null) {
      body['lat_usuario'] = _ubicacionActual!.latitude;
      body['lon_usuario'] = _ubicacionActual!.longitude;
    }

    final response = await _sendToBot(body);
    _handleBotResponse(response);

    // Si el usuario acaba de agendar, refrescar el accessToken por si expira
    if (_accionEsAgendar(seleccionMapped)) {
      await _obtenerGoogleAccessToken();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildInputField() {
    // Adaptar campo de entrada según input_mode del backend
    if (_inputMode == 'date' || _esperandoFecha) {
      return _buildDateInputField();
    } else if (_inputMode == 'time' || _esperandoHora) {
      return _buildTimeInputField();
    } else if (_inputMode == 'text') {
      return _buildNormalInputField();
    } else {
      // Si el backend pide solo menú, no mostrar campo de texto
      if (_menuOptions.isNotEmpty) {
        return const SizedBox.shrink();
      } else {
        return _buildNormalInputField();
      }
    }
  }

  Widget _buildDateInputField() {
    // Extraer días permitidos del último mensaje del bot
    final diasPermitidos = _extractDiasPermitidos();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(top: BorderSide(color: Colors.orange.shade200, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange.shade700, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Fecha de visita a $_ultimoLugarSeleccionado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            diasPermitidos.isNotEmpty
                ? 'Selecciona una fecha permitida (${diasPermitidos.join(", ")})'
                : 'Selecciona la fecha de tu visita',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _waitingBotReply
                      ? null
                      : () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365)),
                            selectableDayPredicate: (date) {
                              if (diasPermitidos.isEmpty) return true;
                              final diasSemana = {
                                'Lunes': DateTime.monday,
                                'Martes': DateTime.tuesday,
                                'Miércoles': DateTime.wednesday,
                                'Miercoles': DateTime.wednesday,
                                'Jueves': DateTime.thursday,
                                'Viernes': DateTime.friday,
                                'Sábado': DateTime.saturday,
                                'Sabado': DateTime.saturday,
                                'Domingo': DateTime.sunday,
                              };
                              return diasPermitidos.any((dia) => diasSemana[dia] == date.weekday);
                            },
                          );
                          if (picked != null) {
                            final formatted = _formatDateDDMMYYYY(picked);
                            setState(() {
                              _controller.text = formatted;
                            });
                          }
                        },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'DD/MM/YYYY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.orange.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.orange.shade500, width: 2),
                        ),
                        prefixIcon: Icon(Icons.date_range, color: Colors.orange.shade700),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.datetime,
                      enabled: !_waitingBotReply,
                      readOnly: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                width: 40,
                child: IconButton(
                  icon: _waitingBotReply
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.orange,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: _waitingBotReply || _controller.text.isEmpty
                      ? null
                      : () => _sendUserMessage(_controller.text),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
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
        border: Border(top: BorderSide(color: Colors.blue.shade200, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue.shade700, size: 22),
              const SizedBox(width: 8),
              Text(
                'Hora de salida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu hora de salida en formato 24h (ejemplo: 09:30)',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'HH:MM',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
                    ),
                    prefixIcon: Icon(Icons.schedule, color: Colors.blue.shade700),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.datetime,
                  enabled: !_waitingBotReply,
                  onChanged: (_) {
                    setState(() {}); // Para actualizar el estado del botón
                  },
                  onSubmitted: _waitingBotReply ? null : (value) {
                    if (value.trim().isNotEmpty) {
                      _sendUserMessage(value.trim());
                      setState(() {
                        _controller.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  icon: _waitingBotReply
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  label: const SizedBox.shrink(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(40, 40),
                  ),
                  onPressed: _waitingBotReply || _controller.text.isEmpty
                      ? null
                      : () {
                          _sendUserMessage(_controller.text.trim());
                          setState(() {
                            _controller.clear();
                          });
                        },
                ),
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
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              enabled: !_waitingBotReply,
              onSubmitted: _waitingBotReply ? null : _sendUserMessage,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              icon: _waitingBotReply
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              label: const SizedBox.shrink(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(40, 40),
              ),
              onPressed: _waitingBotReply || _controller.text.isEmpty
                  ? null
                  : () => _sendUserMessage(_controller.text),
            ),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Volver',
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        title: const Text(
          'Asistente Turístico Inteligente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF007BFF),
        elevation: 4,
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reiniciar conversación',
            onPressed: _waitingBotReply ? null : _startChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mostrar información de agendamiento activo solo si el proceso está en curso y no se ha agendado aún
          if (_procesoAgendamiento == true && !_visitaAgendada && _ultimoLugarSeleccionado != null && (_fechaViaje != null || _horaSalida != null))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.green.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_available, color: Colors.green.shade700, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Agendamiento en Proceso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 Lugar: $_ultimoLugarSeleccionado',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  if (_fechaViaje != null) 
                    Text(
                      '📅 Fecha: $_fechaViaje',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  if (_horaSalida != null) 
                    Text(
                      '⏰ Hora de salida: $_horaSalida',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + (_menuOptions.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                // Si es el último elemento y hay opciones de menú, renderiza los botones
                if (_menuOptions.isNotEmpty && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _menuOptions.map((option) {
                          Color buttonColor = const Color(0xFF007BFF);
                          Color textColor = Colors.white;
                          IconData? icon;
                          if (option.contains("Agendar") || option.contains("agendar")) {
                            buttonColor = Colors.orange;
                            icon = Icons.event_note;
                          } else if (option.contains("Sí, generar") || option.contains("Si, generar")) {
                            buttonColor = Colors.green;
                            icon = Icons.directions;
                          } else if (option.contains("Cancelar")) {
                            buttonColor = Colors.red;
                            icon = Icons.cancel;
                          } else if (option.contains("ubicación") || option.contains("ubicacion")) {
                            buttonColor = Colors.purple;
                            icon = Icons.location_on;
                          } else if (option.contains("horarios")) {
                            buttonColor = Colors.teal;
                            icon = Icons.access_time;
                          } else if (option.contains("servicios")) {
                            buttonColor = Colors.indigo;
                            icon = Icons.room_service;
                          } else if (option.contains("actividades")) {
                            buttonColor = Colors.amber.shade700;
                            icon = Icons.local_activity;
                          } else if (option.contains("Volver")) {
                            buttonColor = Colors.grey.shade600;
                            icon = Icons.home;
                          }
                          return ElevatedButton.icon(
                            onPressed: _waitingBotReply ? null : () => _sendUserMessage(option),
                            icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
                            label: Text(
                              option,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 2,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }

                // Mensajes normales
                final msg = _messages[index];

                // Detectar si el mensaje contiene un enlace de Google Calendar especial
                if (msg.text.contains('[Abrir Google Calendar]')) {
                  final urlReg = RegExp(r'\[Abrir Google Calendar\]\((.*?)\)');
                  final match = urlReg.firstMatch(msg.text);
                  final url = match != null ? match.group(1) : null;
                  if (url != null) {
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser 
                              ? const Color(0xFF007BFF) 
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.event, color: Colors.white),
                          label: const Text('Abrir Google Calendar', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 2,
                          ),
                        ),
                      ),
                    );
                  }
                }

                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser 
                          ? const Color(0xFF007BFF) 
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (msg.text.isNotEmpty)
                          SelectableText.rich(
                            _parseMarkdown(
                              msg.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: msg.isUser ? Colors.white : Colors.black87,
                              ),
                              linkStyle: TextStyle(
                                color: msg.isUser ? Colors.white : const Color(0xFF007BFF),
                                decoration: TextDecoration.underline,
                              ),
                              boldStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: msg.isUser ? Colors.white : const Color(0xFF007BFF),
                              ),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        // Si el mensaje tiene ubicación, mostrar botón de Google Maps
                        if (msg.ubicacion != null) ...[
                          const SizedBox(height: 12),
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
                            icon: const Icon(Icons.map, color: Colors.white, size: 20),
                            label: const Text(
                              'Ver en Google Maps', 
                              style: TextStyle(color: Colors.white, fontSize: 14)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              elevation: 2,
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
      // Botón flotante para obtener ubicación rápidamente
      floatingActionButton: _ubicacionActual == null
          ? FloatingActionButton(
              onPressed: _obtenerUbicacionActual,
              backgroundColor: Colors.orange,
              tooltip: 'Obtener mi ubicación',
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }
}

// Simple Markdown parser for bold, links, and normal text
TextSpan _parseMarkdown(
  String text, {
  TextStyle? style,
  TextStyle? linkStyle,
  TextStyle? boldStyle,
}) {
  final List<InlineSpan> children = [];
  final RegExp exp = RegExp(
    r'(\*\*([^\*]+)\*\*|\[([^\]]+)\]\(([^\)]+)\))',
    multiLine: true,
  );
  int currentIndex = 0;

  Iterable<RegExpMatch> matches = exp.allMatches(text);
  for (final match in matches) {
    if (match.start > currentIndex) {
      children.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: style,
      ));
    }
    if (match.group(2) != null) {
      // Bold
      children.add(TextSpan(
        text: match.group(2),
        style: boldStyle ?? style?.copyWith(fontWeight: FontWeight.bold),
      ));
    } else if (match.group(3) != null && match.group(4) != null) {
      // Link
      final String linkText = match.group(3)!;
      final String url = match.group(4)!;
      children.add(
        TextSpan(
          text: linkText,
          style: linkStyle ?? style?.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ),
      );
    }
    currentIndex = match.end;
  }
  if (currentIndex < text.length) {
    children.add(TextSpan(
      text: text.substring(currentIndex),
      style: style,
    ));
  }
  return TextSpan(children: children, style: style);
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
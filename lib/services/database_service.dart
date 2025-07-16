// import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';

import '../models/punto_turistico.dart';
import '../data/sample_data.dart';
import '../config/app_config.dart';
import 'google_places_service.dart';

class DatabaseService {
  /// Busca los 3 lugares más relevantes en Google Places de Santo Domingo de los Tsáchilas, Ecuador, para cualquier término
  Future<List<Map<String, dynamic>>> buscarLugaresGoogle(String query) async {
    final queryGoogle = '$query en Santo Domingo de los Tsáchilas, Ecuador';
    final lugaresGoogle = await GooglePlacesService(AppConfig.googleApiKey).buscarLugares(queryGoogle);
    // Filtrar solo lugares en Santo Domingo de los Tsáchilas, Ecuador
    final lugaresFiltrados = lugaresGoogle.where((lugar) {
      final address = (lugar['formatted_address'] ?? lugar['vicinity'] ?? '').toString().toLowerCase();
      return address.contains('santo domingo') && address.contains('ecuador');
    }).toList();
    // Ordenar por rating descendente si existe
    lugaresFiltrados.sort((a, b) {
      final ratingA = a['rating'] ?? 0.0;
      final ratingB = b['rating'] ?? 0.0;
      return (ratingB as num).compareTo(ratingA as num);
    });
    return lugaresFiltrados.take(3).toList();
  }
  /// Busca las 3 parroquias más visitadas de Santo Domingo de los Tsáchilas, Ecuador usando Google Places
  Future<List<Map<String, dynamic>>> buscarParroquiasGoogle() async {
    // Consulta específica para parroquias en Santo Domingo de los Tsáchilas, Ecuador
    final queryGoogle = 'parroquia en Santo Domingo de los Tsáchilas, Ecuador';
    final lugaresGoogle = await GooglePlacesService(AppConfig.googleApiKey).buscarLugares(queryGoogle);
    // Filtrar solo lugares que sean parroquias y estén en Santo Domingo de los Tsáchilas
    final lugaresFiltrados = lugaresGoogle.where((lugar) {
      final name = (lugar['name'] ?? '').toString().toLowerCase();
      final address = (lugar['formatted_address'] ?? lugar['vicinity'] ?? '').toString().toLowerCase();
      return (name.contains('parroquia') || address.contains('parroquia')) &&
             address.contains('santo domingo') && address.contains('ecuador');
    }).toList();
    // Ordenar por rating descendente si existe
    lugaresFiltrados.sort((a, b) {
      final ratingA = a['rating'] ?? 0.0;
      final ratingB = b['rating'] ?? 0.0;
      return (ratingB as num).compareTo(ratingA as num);
    });
    return lugaresFiltrados.take(3).toList();
  }
  /// Ejemplo de uso en un chatbot:
  ///
  /// final resultados = await DatabaseService().buscarGeneralConFallback(query);
  /// if (resultados['puntosDb'].isNotEmpty || resultados['puntosSample'].isNotEmpty || ... ) {
  ///   // Mostrar resultados locales
  /// } else if (resultados['googlePlaces'] != null && resultados['googlePlaces'].isNotEmpty) {
  ///   // Mostrar los lugares de Google con nombre, tipo/servicio y precio
  ///   // Ejemplo:
  ///   for (var lugar in resultados['googlePlaces']) {
  ///     print('Nombre: \\${lugar['name']}');
  ///     print('Tipo: \\${lugar['types']?.join(', ') ?? ''}');
  ///     print('Precio: \\${lugar['price_level'] ?? 'No disponible'}');
  ///   }
  /// } else {
  ///   // No se encontraron resultados
  /// }
  /// Busca en la base local y SampleData, y si no hay resultados, consulta Google Places.
  /// Devuelve un mapa con los resultados locales y, si aplica, una lista de lugares de Google bajo la clave 'googlePlaces'.
  Future<Map<String, dynamic>> buscarGeneralConFallback(String query) async {
    final resultados = await buscarGeneral(query);
    final bool hayResultados = resultados.values.any((list) => list.isNotEmpty);
    if (hayResultados) {
      return resultados;
    } else {
      // Palabras genéricas que no tienen sentido en Google Places
      final palabrasGenericas = [
        'parroquias', 'parroquia', 'actividades', 'actividad', 'lugares', 'lugar', 'etiquetas', 'etiqueta', 'turismo', 'turísticos', 'turistico', 'turísticos', 'turistica', 'turísticas', 'turisticos', 'turisticas', 'sitios', 'sitio', 'locales', 'local', 'servicios', 'servicio'
      ];
      final queryLimpio = query.trim().toLowerCase();
      if (palabrasGenericas.contains(queryLimpio)) {
        final mensaje = 'La búsqueda "{query}" es muy general. Por favor, intenta con el nombre de una parroquia, lugar o actividad específica para obtener mejores resultados.';
        return {
          ...resultados,
          'googlePlaces': [mensaje.replaceAll('{query}', query)],
        };
      }
      // Mensajes variados para no encontrado
      final mensajesNoEncontrado = [
        'No encontré resultados locales para "{query}". ¡Pero mira lo que encontré en Santo Domingo de los Tsáchilas!',
        'Ups, no hallé nada en la base local sobre "{query}". Sin embargo, aquí tienes algunas opciones de internet:',
        'No tengo información local sobre "{query}", pero estos lugares pueden interesarte:',
        'No hay coincidencias locales para "{query}", pero encontré estos sitios en Santo Domingo de los Tsáchilas:',
        'No logré encontrar "{query}" aquí, pero te muestro alternativas de la web:',
      ];
      final saludos = [
        '¡Hola!',
        '¡Saludos!',
        '¡Buen día!',
        '¡Qué gusto ayudarte!',
        '¡Aquí estoy para ayudarte!',
      ];
      final random = DateTime.now().millisecondsSinceEpoch;
      final saludo = saludos[random % saludos.length];
      final mensajeNoEncontrado = mensajesNoEncontrado[random % mensajesNoEncontrado.length].replaceAll('{query}', query);

      // Buscar en Google Places SOLO en Santo Domingo de los Tsáchilas, Ecuador
      // Modificamos el query para asegurar búsqueda en la ciudad y país correctos
      final queryGoogle = '$query en Santo Domingo, Ecuador';
      final lugaresGoogle = await GooglePlacesService(AppConfig.googleApiKey).buscarLugares(queryGoogle);
      // Filtrar solo lugares en Santo Domingo de los Tsáchilas, Ecuador
      final lugaresFiltrados = lugaresGoogle.where((lugar) {
        final address = (lugar['formatted_address'] ?? lugar['vicinity'] ?? '').toString().toLowerCase();
        return address.contains('santo domingo') && address.contains('ecuador');
      }).toList();

      // Mapear a mensajes amigables para el chatbot
      final lugaresChat = lugaresFiltrados.map((lugar) {
        final nombre = lugar['name'] ?? 'Sin nombre';
        final direccion = lugar['formatted_address'] ?? lugar['vicinity'] ?? 'Dirección no disponible';
        final horario = (lugar['opening_hours'] != null && lugar['opening_hours']['weekday_text'] != null)
            ? (lugar['opening_hours']['weekday_text'] as List).join(' | ')
            : 'Horario no disponible';
        final precio = lugar['price_level'] != null
            ? _descripcionPrecio(lugar['price_level'])
            : 'Precio no disponible';
        final gratis = (lugar['price_level'] == 0) ? 'Gratis' : null;
        // Mensajes variados para cada lugar
        final plantillas = [
          'Te recomiendo "{nombre}", ubicado en {direccion}. Abren: {horario}. Precio: {precio}.',
          'Una opción es "{nombre}" en {direccion}. Horario: {horario}. Costo: {precio}.',
          'Puedes visitar "{nombre}" (dirección: {direccion}). Horario de atención: {horario}. Valor: {precio}.',
          '¿Qué tal "{nombre}"? Lo encuentras en {direccion}, abre: {horario}, y cuesta: {precio}.',
          'Considera "{nombre}" en {direccion}. Horario: {horario}. Precio estimado: {precio}.',
        ];
        final idx = (nombre.hashCode + direccion.hashCode + random) % plantillas.length;
        return plantillas[idx]
          .replaceAll('{nombre}', nombre)
          .replaceAll('{direccion}', direccion)
          .replaceAll('{horario}', horario)
          .replaceAll('{precio}', gratis ?? precio);
      }).toList();

      // Si no hay lugares, mensaje especial
      if (lugaresChat.isEmpty) {
        return {
          ...resultados,
          'googlePlaces': [
            '$saludo $mensajeNoEncontrado\nTampoco encontré opciones en internet para tu búsqueda. ¿Quieres intentar con otra palabra clave?'
          ],
        };
      }

      // Mensaje de saludo y explicación antes de la lista
      final mensajeFinal = '$saludo $mensajeNoEncontrado\n' + lugaresChat.join('\n\n');
      return {
        ...resultados,
        'googlePlaces': [mensajeFinal],
      };
    }
  }

  // Traduce el price_level de Google Places a texto amigable
  String _descripcionPrecio(dynamic priceLevel) {
    switch (priceLevel) {
      case 0:
        return 'Gratis';
      case 1:
        return 'Económico';
      case 2:
        return 'Moderado';
      case 3:
        return 'Costoso';
      case 4:
        return 'Muy costoso';
      default:
        return 'Precio no disponible';
    }
  }
  /// Busca puntos turísticos, parroquias, actividades y locales por nombre o palabra clave.
  /// Devuelve un mapa con los resultados encontrados en cada categoría.
  /// Si no encuentra nada en la base de datos ni en SampleData, retorna un mapa vacío.
  Future<Map<String, List<dynamic>>> buscarGeneral(String query) async {
    final db = await database;
    final lowerQuery = query.toLowerCase();

    // Función para quitar tildes
    String quitarTildes(String s) {
      return s
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('Á', 'a')
        .replaceAll('É', 'e')
        .replaceAll('Í', 'i')
        .replaceAll('Ó', 'o')
        .replaceAll('Ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('Ñ', 'n');
    }
    final querySinTildes = quitarTildes(lowerQuery);

    // Buscar en puntos turísticos (DB)
    final puntosDb = await db.rawQuery(
      '''SELECT * FROM puntos_turisticos WHERE estado = ? AND (
        lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nombre, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?
        OR lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(descripcion, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?
      )''',
      ['activo', '%$querySinTildes%', '%$querySinTildes%']
    );
    // Buscar en SampleData puntos turísticos
    final puntosSample = SampleData.puntosTuristicos.where((p) =>
      quitarTildes(p.nombre.toLowerCase()).contains(querySinTildes) ||
      quitarTildes(p.descripcion.toLowerCase()).contains(querySinTildes)
    ).toList();

    // Buscar en parroquias (DB)
    final parroquiasDb = await db.rawQuery(
      '''SELECT * FROM parroquias WHERE estado = ? AND (
        lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nombre, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?
        OR lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(descripcion, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?
      )''',
      ['activo', '%$querySinTildes%', '%$querySinTildes%']
    );
    // Buscar en SampleData parroquias
    final parroquiasSample = SampleData.parroquias.where((p) =>
      quitarTildes(p.nombre.toLowerCase()).contains(querySinTildes) ||
      quitarTildes(p.descripcion.toLowerCase()).contains(querySinTildes)
    ).toList();

    // Buscar en actividades (DB)
    final actividadesDb = await db.rawQuery(
      '''SELECT * FROM actividades WHERE estado = ? AND (
        lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nombre, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?
      )''',
      ['activo', '%$querySinTildes%']
    );
    // Buscar en SampleData actividades
    final actividadesSample = SampleData.actividades.where((a) =>
      quitarTildes(a.nombre.toLowerCase()).contains(querySinTildes)
    ).toList();

    // Buscar en locales turísticos (DB)
    final localesDb = await db.rawQuery(
      '''SELECT * FROM locales_turisticos WHERE estado = ? AND (
        lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nombre, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?
        OR lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(descripcion, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?
      )''',
      ['activo', '%$querySinTildes%', '%$querySinTildes%']
    );
    // Buscar en SampleData locales turísticos
    List localesSample = [];
    try {
      localesSample = SampleData.localesTuristicos.where((l) =>
        quitarTildes(l.nombre.toLowerCase()).contains(querySinTildes) ||
        quitarTildes(l.descripcion.toLowerCase()).contains(querySinTildes)
      ).toList();
    } catch (_) {
      localesSample = [];
    }

    // Buscar en servicios de locales turísticos (DB)
    final serviciosDb = await db.rawQuery(
      '''SELECT s.*, l.nombre as nombre_local FROM servicios s
         LEFT JOIN locales_turisticos l ON s.id_local = l.id
         WHERE lower(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(s.servicio, 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'Á', 'a'), 'É', 'e'), 'Í', 'i'), 'Ó', 'o'), 'Ú', 'u')) LIKE ?''',
      ['%' + querySinTildes + '%']
    );
    // Buscar en SampleData servicios (si existe)
    List serviciosSample = [];
    try {
      serviciosSample = SampleData.servicios.where((s) =>
        quitarTildes(s.servicioNombre.toLowerCase()).contains(querySinTildes)
      ).toList();
    } catch (_) {
      serviciosSample = [];
    }

    return {
      'puntosDb': puntosDb,
      'puntosSample': puntosSample,
      'parroquiasDb': parroquiasDb,
      'parroquiasSample': parroquiasSample,
      'actividadesDb': actividadesDb,
      'actividadesSample': actividadesSample,
      'localesDb': localesDb,
      'localesSample': localesSample,
      'serviciosDb': serviciosDb,
      'serviciosSample': serviciosSample,
    };
  }
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'turismo_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabla de Parroquias
    await db.execute('''
      CREATE TABLE parroquias (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        poblacion INTEGER,
        temperatura_promedio REAL,
        estado TEXT DEFAULT 'activo',
        imagen_url TEXT
      )
    ''');

    // Tabla de Etiquetas
    await db.execute('''
      CREATE TABLE etiquetas (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        estado TEXT DEFAULT 'activo'
      )
    ''');

    // Tabla de Puntos Turísticos
    await db.execute('''
      CREATE TABLE puntos_turisticos (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        id_parroquia INTEGER,
        estado TEXT DEFAULT 'activo',
        latitud REAL,
        longitud REAL,
        imagen_url TEXT,
        creado_por TEXT,
        editado_por TEXT,
        fecha_creacion TEXT,
        fecha_ultima_edicion TEXT,
        es_recomendado INTEGER DEFAULT 0,
        FOREIGN KEY (id_parroquia) REFERENCES parroquias (id)
      )
    ''');

    // Tabla de Actividades
    await db.execute('''
      CREATE TABLE actividades (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        id_punto_turistico INTEGER,
        precio REAL DEFAULT 0.0,
        estado TEXT DEFAULT 'activo',
        creado_por TEXT,
        editado_por TEXT,
        fecha_creacion TEXT,
        fecha_ultima_edicion TEXT,
        FOREIGN KEY (id_punto_turistico) REFERENCES puntos_turisticos (id)
      )
    ''');

    // Tabla de relación Puntos Turísticos - Etiquetas
    await db.execute('''
      CREATE TABLE punto_turistico_etiquetas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_punto_turistico INTEGER,
        id_etiqueta INTEGER,
        FOREIGN KEY (id_punto_turistico) REFERENCES puntos_turisticos (id),
        FOREIGN KEY (id_etiqueta) REFERENCES etiquetas (id)
      )
    ''');

    // Tabla de Locales Turísticos
    await db.execute('''
      CREATE TABLE locales_turisticos (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        direccion TEXT,
        latitud REAL,
        longitud REAL,
        telefono TEXT,
        email TEXT,
        sitioweb TEXT,
        estado TEXT DEFAULT 'activo',
        imagen_url TEXT
      )
    ''');

    // Tabla de Dueños
    await db.execute('''
      CREATE TABLE duenos (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        telefono TEXT,
        email TEXT,
        estado TEXT DEFAULT 'activo',
        id_local INTEGER,
        FOREIGN KEY (id_local) REFERENCES locales_turisticos (id)
      )
    ''');

    // Tabla de Horarios de Atención
    await db.execute('''
      CREATE TABLE horarios_atencion (
        id INTEGER PRIMARY KEY,
        hora_inicio TEXT NOT NULL,
        hora_fin TEXT NOT NULL,
        dia_semana TEXT NOT NULL,
        id_local INTEGER,
        estado TEXT DEFAULT 'activo',
        FOREIGN KEY (id_local) REFERENCES locales_turisticos (id)
      )
    ''');

    // Tabla de Servicios
    await db.execute('''
      CREATE TABLE servicios (
        id INTEGER PRIMARY KEY,
        id_local INTEGER,
        servicio TEXT NOT NULL,
        FOREIGN KEY (id_local) REFERENCES locales_turisticos (id)
      )
    ''');

    // Tabla de relación Locales Turísticos - Etiquetas
    await db.execute('''
      CREATE TABLE local_turistico_etiquetas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_local INTEGER,
        id_etiqueta INTEGER,
        FOREIGN KEY (id_local) REFERENCES locales_turisticos (id),
        FOREIGN KEY (id_etiqueta) REFERENCES etiquetas (id)
      )
    ''');

    // Tabla de configuración para controlar sincronización
    await db.execute('''
      CREATE TABLE sync_config (
        id INTEGER PRIMARY KEY,
        tabla TEXT NOT NULL,
        ultima_sincronizacion TEXT,
        total_registros INTEGER DEFAULT 0
      )
    ''');

    // Poblar con datos iniciales
    await _populateInitialData(db);
  }

  // Función para poblar datos iniciales
  Future<void> _populateInitialData(Database db) async {
    if (AppConfig.enableDebugPrints) {
      print('DatabaseService: Cargando datos iniciales...');
    }

    try {
      // Insertar parroquias
      for (var parroquia in SampleData.parroquias) {
        await db.insert('parroquias', {
          'id': parroquia.id,
          'nombre': parroquia.nombre,
          'descripcion': parroquia.descripcion,
          'poblacion': parroquia.poblacion,
          'temperatura_promedio': parroquia.temperaturaPromedio,
          'estado': parroquia.estado,
        });
      }

      // Insertar etiquetas
      for (var etiqueta in SampleData.etiquetas) {
        await db.insert('etiquetas', {
          'id': etiqueta.id,
          'nombre': etiqueta.nombre,
          'descripcion': etiqueta.descripcion,
          'estado': etiqueta.estado,
        });
      }

      // Insertar puntos turísticos
      for (var punto in SampleData.puntosTuristicos) {
        await db.insert('puntos_turisticos', {
          'id': punto.id,
          'nombre': punto.nombre,
          'descripcion': punto.descripcion,
          'imagen_url': punto.imagenUrl,
          'latitud': punto.latitud,
          'longitud': punto.longitud,
          'id_parroquia': punto.idParroquia,
          'estado': punto.estado,
          'es_recomendado': punto.esRecomendado ? 1 : 0,
        });

        // Insertar relación con etiquetas (usar el campo correcto)
        for (var etiqueta in punto.etiquetas) {
          await db.insert('punto_turistico_etiquetas', {
            'id_punto_turistico': punto.id,
            'id_etiqueta': etiqueta.id,
          });
        }
      }

      // Insertar actividades
      for (var actividad in SampleData.actividades) {
        await db.insert('actividades', {
          'id': actividad.id,
          'nombre': actividad.nombre,
          'precio': actividad.precio,
          'estado': actividad.estado,
          'id_punto_turistico': actividad.idPuntoTuristico,
        });
      }

      if (AppConfig.enableDebugPrints) {
        print('DatabaseService: Datos iniciales cargados exitosamente');
      }
    } catch (e) {
      if (AppConfig.enableDebugPrints) {
        print('DatabaseService: Error cargando datos iniciales: $e');
      }
    }
  }

  // ========== MÉTODOS PARA PUNTOS TURÍSTICOS ==========
  
  Future<List<PuntoTuristico>> getPuntosTuristicos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT pt.*, p.nombre as nombre_parroquia, p.descripcion as descripcion_parroquia,
             p.poblacion, p.temperatura_promedio, p.imagen_url as parroquia_imagen_url
      FROM puntos_turisticos pt
      LEFT JOIN parroquias p ON pt.id_parroquia = p.id
      WHERE pt.estado = 'activo'
      ORDER BY pt.es_recomendado DESC, pt.nombre ASC
    ''');

    List<PuntoTuristico> puntos = [];
    
    for (var map in maps) {
      // Obtener actividades del punto
      final actividades = await getActividadesByPunto(map['id']);
      
      // Obtener etiquetas del punto
      final etiquetas = await getEtiquetasByPunto(map['id']);
      
      // Crear objeto Parroquia si existe
      Parroquia? parroquia;
      if (map['nombre_parroquia'] != null) {
        parroquia = Parroquia(
          id: map['id_parroquia'] ?? 0,
          nombre: map['nombre_parroquia'] ?? '',
          descripcion: map['descripcion_parroquia'] ?? '',
          poblacion: map['poblacion'] ?? 0,
          temperaturaPromedio: map['temperatura_promedio']?.toDouble() ?? 0.0,
          estado: 'activo',
          imagenUrl: map['parroquia_imagen_url'],
        );
      }
      
      puntos.add(PuntoTuristico(
        id: map['id'],
        nombre: map['nombre'],
        descripcion: map['descripcion'] ?? '',
        idParroquia: map['id_parroquia'] ?? 0,
        estado: map['estado'],
        latitud: map['latitud']?.toDouble() ?? 0.0,
        longitud: map['longitud']?.toDouble() ?? 0.0,
        imagenUrl: map['imagen_url'],
        creadoPor: map['creado_por'],
        editadoPor: map['editado_por'],
        fechaCreacion: map['fecha_creacion'] != null 
            ? DateTime.parse(map['fecha_creacion']) 
            : null,
        fechaUltimaEdicion: map['fecha_ultima_edicion'] != null 
            ? DateTime.parse(map['fecha_ultima_edicion']) 
            : null,
        actividades: actividades,
        etiquetas: etiquetas,
        parroquia: parroquia,
        esRecomendado: map['es_recomendado'] == 1,
      ));
    }
    
    return puntos;
  }

  Future<PuntoTuristico?> getPuntoTuristicoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT pt.*, p.nombre as nombre_parroquia, p.descripcion as descripcion_parroquia,
             p.poblacion, p.temperatura_promedio, p.imagen_url as parroquia_imagen_url
      FROM puntos_turisticos pt
      LEFT JOIN parroquias p ON pt.id_parroquia = p.id
      WHERE pt.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      final map = maps.first;
      
      // Obtener actividades del punto
      final actividades = await getActividadesByPunto(map['id']);
      
      // Obtener etiquetas del punto
      final etiquetas = await getEtiquetasByPunto(map['id']);
      
      // Crear objeto Parroquia si existe
      Parroquia? parroquia;
      if (map['nombre_parroquia'] != null) {
        parroquia = Parroquia(
          id: map['id_parroquia'] ?? 0,
          nombre: map['nombre_parroquia'] ?? '',
          descripcion: map['descripcion_parroquia'] ?? '',
          poblacion: map['poblacion'] ?? 0,
          temperaturaPromedio: map['temperatura_promedio']?.toDouble() ?? 0.0,
          estado: 'activo',
          imagenUrl: map['parroquia_imagen_url'],
        );
      }
      
      return PuntoTuristico(
        id: map['id'],
        nombre: map['nombre'],
        descripcion: map['descripcion'] ?? '',
        idParroquia: map['id_parroquia'] ?? 0,
        estado: map['estado'],
        latitud: map['latitud']?.toDouble() ?? 0.0,
        longitud: map['longitud']?.toDouble() ?? 0.0,
        imagenUrl: map['imagen_url'],
        creadoPor: map['creado_por'],
        editadoPor: map['editado_por'],
        fechaCreacion: map['fecha_creacion'] != null 
            ? DateTime.parse(map['fecha_creacion']) 
            : null,
        fechaUltimaEdicion: map['fecha_ultima_edicion'] != null 
            ? DateTime.parse(map['fecha_ultima_edicion']) 
            : null,
        actividades: actividades,
        etiquetas: etiquetas,
        parroquia: parroquia,
        esRecomendado: map['es_recomendado'] == 1,
      );
    }
    
    return null;
  }

  Future<List<Actividad>> getActividadesByPunto(int idPuntoTuristico) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'actividades',
      where: 'id_punto_turistico = ? AND estado = ?',
      whereArgs: [idPuntoTuristico, 'activo'],
    );

    return maps.map((map) => Actividad(
      id: map['id'],
      nombre: map['nombre'],
      idPuntoTuristico: map['id_punto_turistico'],
      precio: map['precio']?.toDouble() ?? 0.0,
      estado: map['estado'],
      creadoPor: map['creado_por'],
      editadoPor: map['editado_por'],
      fechaCreacion: map['fecha_creacion'] != null 
          ? DateTime.parse(map['fecha_creacion']) 
          : null,
      fechaUltimaEdicion: map['fecha_ultima_edicion'] != null 
          ? DateTime.parse(map['fecha_ultima_edicion']) 
          : null,
    )).toList();
  }

  Future<List<Etiqueta>> getEtiquetasByPunto(int idPuntoTuristico) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*
      FROM etiquetas e
      INNER JOIN punto_turistico_etiquetas pte ON e.id = pte.id_etiqueta
      WHERE pte.id_punto_turistico = ? AND e.estado = ?
    ''', [idPuntoTuristico, 'activo']);

    return maps.map((map) => Etiqueta(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'] ?? '',
      estado: map['estado'],
    )).toList();
  }

  // ========== MÉTODOS PARA LOCALES TURÍSTICOS ==========
  
  Future<List<LocalTuristico>> getLocalesTuristicos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locales_turisticos',
      where: 'estado = ?',
      whereArgs: ['activo'],
      orderBy: 'nombre ASC',
    );

    List<LocalTuristico> locales = [];
    
    for (var map in maps) {
      // Obtener horarios del local
      final horarios = await getHorariosByLocal(map['id']);
      
      // Obtener etiquetas del local
      final etiquetas = await getEtiquetasByLocal(map['id']);
      
      // Obtener servicios del local
      final servicios = await getServiciosByLocal(map['id']);
      
      locales.add(LocalTuristico(
        id: map['id'],
        nombre: map['nombre'],
        descripcion: map['descripcion'] ?? '',
        direccion: map['direccion'] ?? '',
        latitud: map['latitud']?.toDouble() ?? 0.0,
        longitud: map['longitud']?.toDouble() ?? 0.0,
        telefono: map['telefono'],
        email: map['email'],
        sitioweb: map['sitioweb'],
        estado: map['estado'],
        imagenUrl: map['imagen_url'],
        horarios: horarios,
        etiquetas: etiquetas,
        servicios: servicios,
      ));
    }
    
    return locales;
  }

  Future<LocalTuristico?> getLocalTuristicoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locales_turisticos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      
      // Obtener horarios del local
      final horarios = await getHorariosByLocal(map['id']);
      
      // Obtener etiquetas del local
      final etiquetas = await getEtiquetasByLocal(map['id']);
      
      // Obtener servicios del local
      final servicios = await getServiciosByLocal(map['id']);
      
      return LocalTuristico(
        id: map['id'],
        nombre: map['nombre'],
        descripcion: map['descripcion'] ?? '',
        direccion: map['direccion'] ?? '',
        latitud: map['latitud']?.toDouble() ?? 0.0,
        longitud: map['longitud']?.toDouble() ?? 0.0,
        telefono: map['telefono'],
        email: map['email'],
        sitioweb: map['sitioweb'],
        estado: map['estado'],
        imagenUrl: map['imagen_url'],
        horarios: horarios,
        etiquetas: etiquetas,
        servicios: servicios,
      );
    }
    
    return null;
  }

  Future<List<HorarioAtencion>> getHorariosByLocal(int idLocal) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'horarios_atencion',
      where: 'id_local = ? AND estado = ?',
      whereArgs: [idLocal, 'activo'],
    );

    return maps.map((map) => HorarioAtencion(
      id: map['id'],
      horaInicio: map['hora_inicio'],
      horaFin: map['hora_fin'],
      diaSemana: map['dia_semana'],
      idLocal: map['id_local'],
      estado: map['estado'],
    )).toList();
  }

  Future<List<Etiqueta>> getEtiquetasByLocal(int idLocal) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*
      FROM etiquetas e
      INNER JOIN local_turistico_etiquetas lte ON e.id = lte.id_etiqueta
      WHERE lte.id_local = ? AND e.estado = ?
    ''', [idLocal, 'activo']);

    return maps.map((map) => Etiqueta(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'] ?? '',
      estado: map['estado'],
    )).toList();
  }

  Future<List<Servicio>> getServiciosByLocal(int idLocal) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'servicios',
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );

    return maps.map((map) => Servicio(
      id: map['id'],
      idLocal: map['id_local'],
      servicioNombre: map['servicio'],
      precio: map['precio']?.toDouble() ?? 0.0,
    )).toList();
  }

  // ========== MÉTODOS PARA PARROQUIAS ==========
  
  Future<List<Parroquia>> getParroquias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'parroquias',
      where: 'estado = ?',
      whereArgs: ['activo'],
      orderBy: 'nombre ASC',
    );

    return maps.map((map) => Parroquia(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'] ?? '',
      poblacion: map['poblacion'] ?? 0,
      temperaturaPromedio: map['temperatura_promedio']?.toDouble() ?? 0.0,
      estado: map['estado'],
      imagenUrl: map['imagen_url'],
    )).toList();
  }

  Future<Parroquia?> getParroquiaById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'parroquias',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Parroquia(
        id: map['id'],
        nombre: map['nombre'],
        descripcion: map['descripcion'] ?? '',
        poblacion: map['poblacion'] ?? 0,
        temperaturaPromedio: map['temperatura_promedio']?.toDouble() ?? 0.0,
        estado: map['estado'],
        imagenUrl: map['imagen_url'],
      );
    }
    
    return null;
  }

  // ========== MÉTODOS PARA ETIQUETAS ==========
  
  Future<List<Etiqueta>> getEtiquetas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'etiquetas',
      where: 'estado = ?',
      whereArgs: ['activo'],
      orderBy: 'nombre ASC',
    );

    return maps.map((map) => Etiqueta(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'] ?? '',
      estado: map['estado'],
    )).toList();
  }

  // ========== MÉTODOS PARA ACTIVIDADES ==========
  
  Future<List<Actividad>> getActividades() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'actividades',
      where: 'estado = ?',
      whereArgs: ['activo'],
      orderBy: 'nombre ASC',
    );

    return maps.map((map) => Actividad(
      id: map['id'],
      nombre: map['nombre'],
      idPuntoTuristico: map['id_punto_turistico'],
      precio: map['precio']?.toDouble() ?? 0.0,
      estado: map['estado'],
      creadoPor: map['creado_por'],
      editadoPor: map['editado_por'],
      fechaCreacion: map['fecha_creacion'] != null 
          ? DateTime.parse(map['fecha_creacion']) 
          : null,
      fechaUltimaEdicion: map['fecha_ultima_edicion'] != null 
          ? DateTime.parse(map['fecha_ultima_edicion']) 
          : null,
    )).toList();
  }

  // ========== MÉTODOS PARA DUEÑOS ==========
  
  // Future<List<Dueno>> getDuenos() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'duenos',
  //     where: 'estado = ?',
  //     whereArgs: ['activo'],
  //     orderBy: 'nombre ASC',
  //   );
  //
  //   return maps.map((map) => Dueno(
  //     id: map['id'],
  //     nombre: map['nombre'],
  //     apellido: map['apellido'],
  //     telefono: map['telefono'],
  //     email: map['email'],
  //     estado: map['estado'],
  //     idLocal: map['id_local'],
  //   )).toList();
  // }

  // Future<Dueno?> getDuenoByLocal(int idLocal) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'duenos',
  //     where: 'id_local = ? AND estado = ?',
  //     whereArgs: [idLocal, 'activo'],
  //   );
  //
  //   if (maps.isNotEmpty) {
  //     final map = maps.first;
  //     return Dueno(
  //       id: map['id'],
  //       nombre: map['nombre'],
  //       apellido: map['apellido'],
  //       telefono: map['telefono'],
  //       email: map['email'],
  //       estado: map['estado'],
  //       idLocal: map['id_local'],
  //     );
  //   }
  //   return null;
  // }

  // Future<void> insertDueno(Dueno dueno) async {
  //   final db = await database;
  //   await db.insert(
  //     'duenos',
  //     {
  //       'id': dueno.id,
  //       'nombre': dueno.nombre,
  //       'apellido': dueno.apellido,
  //       'telefono': dueno.telefono,
  //       'email': dueno.email,
  //       'estado': dueno.estado,
  //       'id_local': dueno.idLocal,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // ========== MÉTODOS DE INSERCIÓN ==========
  
  Future<void> insertPuntoTuristico(PuntoTuristico punto) async {
    final db = await database;
    
    await db.insert(
      'puntos_turisticos',
      {
        'id': punto.id,
        'nombre': punto.nombre,
        'descripcion': punto.descripcion,
        'id_parroquia': punto.idParroquia,
        'estado': punto.estado,
        'latitud': punto.latitud,
        'longitud': punto.longitud,
        'imagen_url': punto.imagenUrl,
        'creado_por': punto.creadoPor,
        'editado_por': punto.editadoPor,
        'fecha_creacion': punto.fechaCreacion?.toIso8601String(),
        'fecha_ultima_edicion': punto.fechaUltimaEdicion?.toIso8601String(),
        'es_recomendado': punto.esRecomendado ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insertar actividades
    for (var actividad in punto.actividades) {
      await insertActividad(actividad);
    }

    // Insertar relaciones con etiquetas
    // for (var etiqueta in punto.etiquetas) {
    //   await insertPuntoTuristicoEtiqueta(punto.id, etiqueta.id);
    // }
  }

  Future<void> insertLocalTuristico(LocalTuristico local) async {
    final db = await database;
    
    await db.insert(
      'locales_turisticos',
      {
        'id': local.id,
        'nombre': local.nombre,
        'descripcion': local.descripcion,
        'direccion': local.direccion,
        'latitud': local.latitud,
        'longitud': local.longitud,
        'telefono': local.telefono,
        'email': local.email,
        'sitioweb': local.sitioweb,
        'estado': local.estado,
        'imagen_url': local.imagenUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insertar horarios
    // for (var horario in local.horarios) {
    //   await insertHorarioAtencion(horario);
    // }

    // // Insertar servicios
    // for (var servicio in local.servicios) {
    //   await insertServicio(servicio);
    // }

    // // Insertar relaciones con etiquetas
    // for (var etiqueta in local.etiquetas) {
    //   await insertLocalTuristicoEtiqueta(local.id, etiqueta.id);
    // }
  }

  Future<void> insertParroquia(Parroquia parroquia) async {
    final db = await database;
    
    await db.insert(
      'parroquias',
      {
        'id': parroquia.id,
        'nombre': parroquia.nombre,
        'descripcion': parroquia.descripcion,
        'poblacion': parroquia.poblacion,
        'temperatura_promedio': parroquia.temperaturaPromedio,
        'estado': parroquia.estado,
        'imagen_url': parroquia.imagenUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertEtiqueta(Etiqueta etiqueta) async {
    final db = await database;
    
    await db.insert(
      'etiquetas',
      {
        'id': etiqueta.id,
        'nombre': etiqueta.nombre,
        'descripcion': etiqueta.descripcion,
        'estado': etiqueta.estado,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertActividad(Actividad actividad) async {
    final db = await database;
    
    await db.insert(
      'actividades',
      {
        'id': actividad.id,
        'nombre': actividad.nombre,
        'id_punto_turistico': actividad.idPuntoTuristico,
        'precio': actividad.precio,
        'estado': actividad.estado,
        'creado_por': actividad.creadoPor,
        'editado_por': actividad.editadoPor,
        'fecha_creacion': actividad.fechaCreacion?.toIso8601String(),
        'fecha_ultima_edicion': actividad.fechaUltimaEdicion?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ========== MÉTODOS DE LIMPIEZA ==========
  
  Future<void> clearAllData() async {
    final db = await database;
    
    await db.delete('punto_turistico_etiquetas');
    await db.delete('local_turistico_etiquetas');
    await db.delete('actividades');
    await db.delete('servicios');
    await db.delete('horarios_atencion');
    await db.delete('duenos');
    await db.delete('puntos_turisticos');
    await db.delete('locales_turisticos');
    await db.delete('etiquetas');
    await db.delete('parroquias');
    await db.delete('sync_config');
  }

  // ========== MÉTODOS DE SINCRONIZACIÓN ==========
  
  Future<void> updateSyncConfig(String tabla, int totalRegistros) async {
    final db = await database;
    
    await db.insert(
      'sync_config',
      {
        'tabla': tabla,
        'ultima_sincronizacion': DateTime.now().toIso8601String(),
        'total_registros': totalRegistros,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSyncConfig(String tabla) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_config',
      where: 'tabla = ?',
      whereArgs: [tabla],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  Future<DateTime?> getLastSyncDate() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT MAX(ultima_sincronizacion) as ultima_fecha
      FROM sync_config
    ''');

    if (maps.isNotEmpty && maps.first['ultima_fecha'] != null) {
      return DateTime.parse(maps.first['ultima_fecha']);
    }
    
    return null;
  }
}

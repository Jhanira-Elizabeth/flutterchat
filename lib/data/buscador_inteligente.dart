import 'dart:convert';
import 'package:collection/collection.dart';
import '../models/punto_turistico.dart';
import 'sample_data.dart';
import 'package:characters/characters.dart';

class BuscadorInteligente {
  // Diccionario de sinónimos y equivalencias
  static final Map<String, List<String>> sinonimos = {
    'hotel': ['hospedaje', 'hostal', 'hostería', 'alojamiento'],
    'balneario': ['piscina', 'spa', 'aguas', 'natación'],
    'malecon': ['malecón', 'río', 'rio', 'parque'],
    'comida': ['restaurante', 'alimentos', 'gastronomía', 'plato', 'cocina'],
    'cascada': ['cascadas', 'salto de agua'],
    'parque': ['área verde', 'jardín', 'recreación'],
    'piscina': ['balneario', 'natación', 'agua'],
    'hospedaje': ['hotel', 'hostal', 'hostería', 'alojamiento'],
    // Puedes agregar más equivalencias aquí
  };

  // Normaliza texto: minúsculas, sin tildes, sin caracteres especiales
  static String normalizar(String texto) {
    final tildes = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
      'ñ': 'n', 'Ñ': 'n',
    };
    return texto
        .toLowerCase()
        .split('')
        .map((c) => tildes[c] ?? c)
        .join()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // Expande la consulta con sinónimos
  static List<String> expandirConsulta(String consulta) {
    final palabras = normalizar(consulta).split(' ');
    final expandidas = <String>{};
    for (var palabra in palabras) {
      expandidas.add(palabra);
      sinonimos.forEach((clave, lista) {
        if (palabra == clave || lista.contains(palabra)) {
          expandidas.add(clave);
          expandidas.addAll(lista);
        }
      });
    }
    return expandidas.toList();
  }

  // Busca en puntos turísticos, servicios y descripciones
  static List<PuntoTuristico> buscar(String consulta) {
    final terminos = expandirConsulta(consulta);
    final puntos = SampleData.puntosTuristicos;
    final servicios = SampleData.servicios;
    final resultados = <PuntoTuristico, int>{};

    for (var punto in puntos) {
      int score = 0;
      final nombre = normalizar(punto.nombre);
      final descripcion = normalizar(punto.descripcion);
      final etiquetas = punto.etiquetas.map((e) => normalizar(e.nombre)).join(' ');
      final serviciosLocal = servicios
          .where((s) => s.idLocal == punto.id)
          .map((s) => normalizar(s.servicioNombre))
          .join(' ');
      for (var termino in terminos) {
        if (nombre.contains(termino)) score += 3;
        if (descripcion.contains(termino)) score += 2;
        if (etiquetas.contains(termino)) score += 2;
        if (serviciosLocal.contains(termino)) score += 2;
      }
      if (score > 0) {
        resultados[punto] = score;
      }
    }
    // Ordena por score descendente
    final lista = resultados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return lista.map((e) => e.key).toList();
  }
}

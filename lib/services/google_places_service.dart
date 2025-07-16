import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  final String apiKey;

  GooglePlacesService(this.apiKey);

  Future<List<Map<String, dynamic>>> buscarLugares(String query, {String? location, String? type}) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query${type != null ? '&type=$type' : ''}${location != null ? '&location=$location&radius=5000' : ''}&key=$apiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      // Tomar solo los 3 primeros
      return results.take(3).map((place) {
        return {
          'nombre': place['name'],
          'direccion': place['formatted_address'],
          'tipo': place['types'] != null && place['types'].isNotEmpty ? place['types'][0] : '',
          'precio': place['price_level'] ?? 'No disponible',
          'rating': place['rating'] ?? 'No disponible',
        };
      }).toList();
    } else {
      throw Exception('Error al consultar Google Places');
    }
  }
}

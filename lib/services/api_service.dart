import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bien_immobilier.dart';

class ApiService {
  // Exemple d'API externe : API de géocodage pour enrichir les adresses
  // Utilisation de l'API Nominatim (OpenStreetMap) - gratuite et sans clé API
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Récupérer les coordonnées GPS d'une adresse
  Future<Map<String, double>?> getCoordinatesFromAddress({
    required String adresse,
    required String ville,
    required String codePostal,
  }) async {
    try {
      final String query = '$adresse, $codePostal $ville';
      final Uri uri = Uri.parse(
        '$_baseUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'GestionImmobiliere/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lon': double.parse(data[0]['lon']),
          };
        }
      }
      return null;
    } catch (e) {
      print('Erreur API géocodage: $e');
      return null;
    }
  }

  // Récupérer des informations supplémentaires sur une ville
  Future<Map<String, dynamic>?> getVilleInfo(String ville) async {
    try {
      final Uri uri = Uri.parse(
        '$_baseUrl/search?q=${Uri.encodeComponent(ville)}&format=json&limit=1&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'GestionImmobiliere/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'nom': data[0]['display_name'],
            'lat': double.tryParse(data[0]['lat'] ?? '0'),
            'lon': double.tryParse(data[0]['lon'] ?? '0'),
          };
        }
      }
      return null;
    } catch (e) {
      print('Erreur API ville: $e');
      return null;
    }
  }

  // Alternative : API RESTCountries pour enrichir avec des données de pays
  // (exemple d'enrichissement de contenu)
  Future<Map<String, dynamic>?> getCountryInfo(String countryCode) async {
    try {
      final Uri uri = Uri.parse(
        'https://restcountries.com/v3.1/alpha/$countryCode',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'nom': data[0]['name']['common'],
            'capitale': data[0]['capital']?[0],
            'population': data[0]['population'],
            'devise': data[0]['currencies']?.values.first?['name'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Erreur API pays: $e');
      return null;
    }
  }
}

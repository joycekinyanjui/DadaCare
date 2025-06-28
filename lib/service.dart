import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsService {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  /// Find nearby hospitals & clinics
  Future<List<Map<String, dynamic>>> searchNearbyHospitals(
    double lat,
    double lng,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=50000'
        '&type=hospital'
        '&keyword=clinic'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception("Failed to load nearby hospitals");
    }
  }

  /// Calculate distance & time
  Future<Map<String, String>> getDistanceAndTime(
    double userLat,
    double userLng,
    double destLat,
    double destLng,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$userLat,$userLng'
        '&destinations=$destLat,$destLng'
        '&mode=driving'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final element = data['rows'][0]['elements'][0];
      return {
        'distance': element['distance']['text'],
        'duration': element['duration']['text'],
      };
    } else {
      throw Exception("Failed to load distance & time");
    }
  }
}

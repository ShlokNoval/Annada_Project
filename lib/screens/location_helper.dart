import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Request location permission and get current user location
Future<Position> determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied.');
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

// Fetch nearby places by type and optional keyword
Future<List<dynamic>> fetchNearbyPlaces({
  required double lat,
  required double lng,
  required String type,
  required String apiKey,
  String? keyword,
}) async {
  final buffer = StringBuffer();
  buffer.write('https://maps.googleapis.com/maps/api/place/nearbysearch/json');
  buffer.write('?location=$lat,$lng');
  buffer.write('&radius=5000'); // 5 km radius
  buffer.write('&type=$type');
  if (keyword != null && keyword.trim().isNotEmpty) {
    buffer.write('&keyword=${Uri.encodeComponent(keyword)}');
  }
  buffer.write('&key=$apiKey');

  final url = buffer.toString();

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'OK') {
      return jsonResponse['results'] as List<dynamic>;
    } else {
      throw Exception('Google Places API error: ${jsonResponse['status']}');
    }
  } else {
    throw Exception('Failed to fetch places: ${response.statusCode}');
  }
}

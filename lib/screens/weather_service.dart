import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class WeatherService {
  static const String apiKey = "c5ca84df187e5713e0c1fa8ad725b5e0";
  static const String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  // ✅ FALLBACK LOCATION - Mountain View
  static const double fallbackLat = 37.4219;
  static const double fallbackLon = -122.0840;

  /// ✅ NEW: Explicit permission request (THIS triggers the dialog)
  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) debugPrint("📍 Location services disabled");
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // 🔥 DIALOG HERE
      if (permission == LocationPermission.denied) {
        if (kDebugMode) debugPrint("🚫 Location permission denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) debugPrint("⛔ Location permission denied forever");
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>> fetchWeather() async {
    try {
      // 🔑 Ask permission ONCE before accessing GPS
      await ensureLocationPermission();

      final position = await _getLocationSafely().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (kDebugMode) debugPrint("⏰ GPS timeout - using fallback");
          return _fallbackPosition();
        },
      );

      final latitude = position.latitude;
      final longitude = position.longitude;

      if (kDebugMode) {
        debugPrint("📍 Using location: $latitude, $longitude");
      }

      final response = await http.get(
        Uri.parse(
          "$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=en",
        ),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () => http.Response('{"error":"timeout"}', 408),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {"error": "Weather service unavailable"};
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Weather Error: $e");
      return {
        "name": "Mountain View",
        "main": {"temp": 15.0},
        "weather": [{"description": "clear sky"}],
      };
    }
  }

  Future<Position> _getLocationSafely() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 500,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint("📍 Location failed: $e");
      return _fallbackPosition();
    }
  }

  Position _fallbackPosition() {
    return Position(
      latitude: fallbackLat,
      longitude: fallbackLon,
      timestamp: DateTime.now(),
      accuracy: 1000,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
      floor: 0,
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  late final String apiKey = dotenv.env['WEATHER_API_KEY']!;
  static const String baseUrl =
      "https://api.openweathermap.org/data/2.5/weather";
  static const String forecastUrl =
      "https://api.openweathermap.org/data/2.5/forecast";

  static const double fallbackLat = 37.4219;
  static const double fallbackLon = -122.0840;

  // ✅ STEP 3: Cached location
  Position? _lastSuccessfulPosition;

  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) debugPrint("📍 Location services disabled");
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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

  Future<Map<String, dynamic>> fetchWeather(String languageCode) async {
    try {
      await ensureLocationPermission();

      final position = await _getLocationSafely().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (kDebugMode) debugPrint("⏰ GPS timeout - using fallback");
          return _fallbackPosition();
        },
      );

      final response = await http.get(
        Uri.parse(
          "$baseUrl?lat=${position.latitude}&lon=${position.longitude}"
              "&appid=$apiKey&units=metric&lang=$languageCode",
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
        "weather": [
          {"description": "clear sky"}
        ],
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchDailyForecast(
      String languageCode) async {
    try {
      await ensureLocationPermission();

      final position = await _getLocationSafely().timeout(
        const Duration(seconds: 8),
        onTimeout: () => _fallbackPosition(),
      );

      final response = await http.get(
        Uri.parse(
          "$forecastUrl?lat=${position.latitude}&lon=${position.longitude}"
              "&appid=$apiKey&units=metric&lang=$languageCode&cnt=40",
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"error":"timeout"}', 408),
      );

      if (response.statusCode != 200) {
        throw Exception("Forecast API error: ${response.statusCode}");
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> list = data['list'] ?? [];

      final Map<String, _DayAccumulator> buckets = {};

      for (final slot in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          (slot['dt'] as int) * 1000,
        );
        final key =
            "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

        buckets.putIfAbsent(key, () => _DayAccumulator(dt));
        buckets[key]!.add(
          (slot['main']['temp_min'] as num).toDouble(),
          (slot['main']['temp_max'] as num).toDouble(),
          slot['weather'][0]['description'] as String,
          slot['weather'][0]['icon'] as String,
          slot['pop'] != null ? (slot['pop'] as num).toDouble() : 0.0,
        );
      }

      final today = DateTime.now();
      final todayKey =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final days = buckets.keys.where((k) => k != todayKey).toList()..sort();

      return days.take(7).map((key) => buckets[key]!.toMap()).toList();
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Forecast Error: $e");
      return [];
    }
  }

  // ✅ UPDATED: Uses cached location before fallback
  Future<Position> _getLocationSafely() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 500,
        ),
      );

      // Save last successful position
      _lastSuccessfulPosition = position;

      return position;
    } catch (e) {
      if (_lastSuccessfulPosition != null) {
        if (kDebugMode) debugPrint("📍 Using cached location");
        return _lastSuccessfulPosition!;
      }

      if (kDebugMode) debugPrint("📍 Using fallback location");
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

class _DayAccumulator {
  final DateTime date;
  double minTemp = double.infinity;
  double maxTemp = double.negativeInfinity;
  double totalPop = 0;
  int count = 0;
  String description = '';
  String icon = '';

  _DayAccumulator(this.date);

  void add(double min, double max, String desc, String ic, double pop) {
    if (min < minTemp) minTemp = min;
    if (max > maxTemp) maxTemp = max;
    totalPop += pop;
    count++;
    description = desc;
    icon = ic;
  }

  Map<String, dynamic> toMap() => {
    'date': date,
    'minTemp': minTemp.roundToDouble(),
    'maxTemp': maxTemp.roundToDouble(),
    'description': description,
    'icon': icon,
    'rainChance': ((totalPop / (count == 0 ? 1 : count)) * 100).round(),
  };
}
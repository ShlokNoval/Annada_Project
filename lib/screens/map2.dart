

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Map2Page extends StatefulWidget {
  const Map2Page({super.key});

  @override
  State<Map2Page> createState() => _Map2PageState();
}

class _Map2PageState extends State<Map2Page> {
  List<dynamic> markets = [];
  bool isLoading = true;
  String? error;

  late final String googleApiKey = dotenv.env['PLACES_MAPS_API_KEY']!;

  @override
  void initState() {
    super.initState();
    loadNearbyMarkets();
  }

  Future<void> loadNearbyMarkets() async {
    try {
      Position pos = await determinePosition();

      final results = await fetchNearbyPlaces(
        lat: pos.latitude,
        lng: pos.longitude,
        type: 'market',
        apiKey: googleApiKey,
      );

      setState(() {
        markets = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> openGoogleMaps(double lat, double lng) async {
    final Uri googleUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl,
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Markets')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : ListView.builder(
        itemCount: markets.length,
        itemBuilder: (context, index) {
          final market = markets[index];
          final lat =
          market['geometry']['location']['lat'];
          final lng =
          market['geometry']['location']['lng'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              onTap: () => openGoogleMaps(lat, lng),
              leading: const Icon(Icons.storefront,
                  color: Colors.green),
              title: Text(market['name'] ?? 'No name'),
              subtitle:
              Text(market['vicinity'] ?? 'No address'),
              trailing: market['opening_hours']
              ?['open_now'] ==
                  true
                  ? const Text('Open',
                  style: TextStyle(
                      color: Colors.green))
                  : const Text('Closed',
                  style:
                  TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}
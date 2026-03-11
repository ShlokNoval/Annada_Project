

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Map1Page extends StatefulWidget {
  const Map1Page({super.key});

  @override
  State<Map1Page> createState() => _Map1PageState();
}

class _Map1PageState extends State<Map1Page> {
  List<dynamic> shops = [];
  bool isLoading = true;
  String? error;

  late final String googleApiKey = dotenv.env['PLACES_MAPS_API_KEY']!;

  @override
  void initState() {
    super.initState();
    loadNearbyShops();
  }

  Future<void> loadNearbyShops() async {
    try {
      Position pos = await determinePosition();

      final results = await fetchNearbyPlaces(
        lat: pos.latitude,
        lng: pos.longitude,
        type: 'hardware_store',
        apiKey: googleApiKey,
        keyword: 'fertilizer',
      );

      setState(() {
        shops = results;
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
      appBar: AppBar(title: const Text('Nearby Fertilizer Shops')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : ListView.builder(
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          final lat =
          shop['geometry']['location']['lat'];
          final lng =
          shop['geometry']['location']['lng'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              onTap: () => openGoogleMaps(lat, lng),
              leading: const Icon(Icons.store,
                  color: Colors.green),
              title: Text(shop['name'] ?? 'No name'),
              subtitle:
              Text(shop['vicinity'] ?? 'No address'),
              trailing: shop['opening_hours']
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
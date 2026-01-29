import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_helper.dart'; // The helper file created above

class Map1Page extends StatefulWidget {
  const Map1Page({super.key});

  @override
  State<Map1Page> createState() => _Map1PageState();
}

class _Map1PageState extends State<Map1Page> {
  List<dynamic> shops = [];
  bool isLoading = true;
  String? error;

  final String googleApiKey = 'AIzaSyCrn-feXL3CmjbI3bMhLoANEfvu8CH229Q'; // Replace with your API key

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
        type: 'hardware_store',  // hardware_store often covers fertilizer stores
        apiKey: googleApiKey,
        keyword: 'fertilizer',  // filter with fertilizer keyword
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
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.store, color: Colors.green),
              title: Text(shop['name'] ?? 'No name'),
              subtitle: Text(shop['vicinity'] ?? 'No address'),
              trailing: shop['opening_hours']?['open_now'] == true
                  ? const Text('Open', style: TextStyle(color: Colors.green))
                  : const Text('Closed', style: TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}

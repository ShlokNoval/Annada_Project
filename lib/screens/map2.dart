import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_helper.dart'; // Import location & API helper from your setup

class Map2Page extends StatefulWidget {
  const Map2Page({super.key});

  @override
  State<Map2Page> createState() => _Map2PageState();
}

class _Map2PageState extends State<Map2Page> {
  List<dynamic> markets = [];
  bool isLoading = true;
  String? error;

  final String googleApiKey = 'AIzaSyCrn-feXL3CmjbI3bMhLoANEfvu8CH229Q'; // Replace with your API key

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
        type: 'market',  // or 'grocery_or_supermarket' or 'shopping_mall'
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
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.storefront, color: Colors.green),
              title: Text(market['name'] ?? 'No name'),
              subtitle: Text(market['vicinity'] ?? 'No address'),
              trailing: market['opening_hours']?['open_now'] == true
                  ? const Text('Open', style: TextStyle(color: Colors.green))
                  : const Text('Closed', style: TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}

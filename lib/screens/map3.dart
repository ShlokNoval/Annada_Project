import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_helper.dart'; // Import your helper functions

class Map3Page extends StatefulWidget {
  const Map3Page({super.key});

  @override
  State<Map3Page> createState() => _Map3PageState();
}

class _Map3PageState extends State<Map3Page> {
  List<dynamic> agencies = [];
  bool isLoading = true;
  String? error;

  final String googleApiKey = 'AIzaSyCrn-feXL3CmjbI3bMhLoANEfvu8CH229Q'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    loadNearbyAgencies();
  }

  Future<void> loadNearbyAgencies() async {
    try {
      Position pos = await determinePosition();

      final results = await fetchNearbyPlaces(
        lat: pos.latitude,
        lng: pos.longitude,
        type: 'point_of_interest', // generic type for NGOs/recycling
        apiKey: googleApiKey,
        keyword: 'recycling ngo',
      );

      setState(() {
        agencies = results;
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
      appBar: AppBar(title: const Text('Nearby NGOs / Recycling Agencies')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : ListView.builder(
        itemCount: agencies.length,
        itemBuilder: (context, index) {
          final agency = agencies[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.recycling, color: Colors.green),
              title: Text(agency['name'] ?? 'No name'),
              subtitle: Text(agency['vicinity'] ?? 'No address'),
              trailing: agency['opening_hours']?['open_now'] == true
                  ? const Text('Open', style: TextStyle(color: Colors.green))
                  : const Text('Closed', style: TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}

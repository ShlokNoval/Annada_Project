

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Map3Page extends StatefulWidget {
  const Map3Page({super.key});

  @override
  State<Map3Page> createState() => _Map3PageState();
}

class _Map3PageState extends State<Map3Page> {
  List<dynamic> agencies = [];
  bool isLoading = true;
  String? error;

  late final String googleApiKey = dotenv.env['PLACES_MAPS_API_KEY']!; // Replace with your API key

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
        type: 'point_of_interest',
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

  Future<void> openGoogleMaps(double lat, double lng) async {
    final Uri googleUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(
        googleUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby NGOs / Recycling Agencies'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : ListView.builder(
        itemCount: agencies.length,
        itemBuilder: (context, index) {
          final agency = agencies[index];

          final lat =
          agency['geometry']['location']['lat'];
          final lng =
          agency['geometry']['location']['lng'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              onTap: () => openGoogleMaps(lat, lng),
              leading: const Icon(
                Icons.recycling,
                color: Colors.green,
              ),
              title:
              Text(agency['name'] ?? 'No name'),
              subtitle: Text(
                  agency['vicinity'] ?? 'No address'),
              trailing: agency['opening_hours']
              ?['open_now'] ==
                  true
                  ? const Text(
                'Open',
                style: TextStyle(
                    color: Colors.green),
              )
                  : const Text(
                'Closed',
                style:
                TextStyle(color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
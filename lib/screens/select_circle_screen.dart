import 'package:flutter/material.dart';
import '../models/circle_data.dart';
import '../services/firestore_service.dart';

class SelectCircleScreen extends StatelessWidget {

  final List<CircleData> availableCircles;
  final FirestoreService _firestoreService = FirestoreService();

  SelectCircleScreen({
    super.key,
    required this.availableCircles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Crop"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<String>>(
        stream: _firestoreService.getUserCrops(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final selectedNames = snapshot.data!;

          final filteredCircles = availableCircles
              .where((circle) =>
          !selectedNames.contains(circle.name))
              .toList();

          if (filteredCircles.isEmpty) {
            return const Center(
              child: Text("No more crops to select!"),
            );
          }

          return ListView.builder(
            itemCount: filteredCircles.length,
            itemBuilder: (context, index) {
              final circle = filteredCircles[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                    AssetImage(circle.imageUrl),
                  ),
                  title: Text(circle.name),
                  onTap: () async {
                    await _firestoreService
                        .addCrop(circle.name);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
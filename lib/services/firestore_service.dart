import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current logged-in user ID
  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  // ─────────────────────────────────────────
  // Add Crop to User
  // ─────────────────────────────────────────
  Future<void> addCrop(String cropName) async {
    await _firestore.collection('users').doc(_uid).set({
      'selectedCrops': FieldValue.arrayUnion([cropName])
    }, SetOptions(merge: true));
  }

  // ─────────────────────────────────────────
  // Remove Crop from User
  // ─────────────────────────────────────────
  Future<void> removeCrop(String cropName) async {
    await _firestore.collection('users').doc(_uid).update({
      'selectedCrops': FieldValue.arrayRemove([cropName])
    });
  }

  // ─────────────────────────────────────────
  // Stream User Selected Crops
  // ─────────────────────────────────────────
  Stream<List<String>> getUserCrops() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.data();
      if (data == null || !data.containsKey('selectedCrops')) {
        return [];
      }

      final List<dynamic> crops = data['selectedCrops'];
      return crops.cast<String>();
    });
  }
}
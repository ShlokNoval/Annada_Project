import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // Add crop
  Future<void> addCrop(String cropName) async {
    await _db.collection('users').doc(userId).set({
      'selectedCrops': FieldValue.arrayUnion([cropName])
    }, SetOptions(merge: true));
  }

  // Remove crop
  Future<void> removeCrop(String cropName) async {
    await _db.collection('users').doc(userId).update({
      'selectedCrops': FieldValue.arrayRemove([cropName])
    });
  }

  // Listen to user crops (REAL-TIME)
  Stream<List<String>> getUserCrops() {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      List<dynamic> crops = doc.data()?['selectedCrops'] ?? [];
      return crops.cast<String>();
    });
  }
}
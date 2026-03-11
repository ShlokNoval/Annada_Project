import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _descriptionController =
  TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  // 🔥 Pick Image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // 🔥 Submit Post to Firebase
  Future<void> _submitPost() async {
    if (_descriptionController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // 1️⃣ Upload Image if exists
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("post_images")
            .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // 2️⃣ Get username
      final prefs = await SharedPreferences.getInstance();
      final userName =
          prefs.getString('userName') ?? "Farmer";

      // 3️⃣ Save Post in Firestore
      await FirebaseFirestore.instance
          .collection("posts")
          .add({
        "text": _descriptionController.text.trim(),
        "imageUrl": imageUrl ?? "",
        "authorId": user.uid,
        "authorName": userName,
        "timestamp": FieldValue.serverTimestamp(),
        "likesCount": 0,
      });

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Post error: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "What's happening?",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius:
                BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.grey),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitPost,
                icon: const Icon(Icons.upload),
                label:
                const Text("Submit Post"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.green,
                  padding:
                  const EdgeInsets.symmetric(
                      vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _phoneController.text = prefs.getString('phoneNumber') ?? '';
      final imagePath = prefs.getString('profilePhoto');
      if (imagePath != null && File(imagePath).existsSync()) {
        _image = File(imagePath);
      }
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('phoneNumber', _phoneController.text);
    if (_image != null) {
      await prefs.setString('profilePhoto', _image!.path);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

    }
  }

  Future<void> _pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
        child: Center(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [




        const SizedBox(height: 20),

    const Text(
    "Your Profile",
    textAlign: TextAlign.center,
    style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),

                const SizedBox(height: 30),

                // 🧾 White Card Container
    Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 15,
    offset: const Offset(0, 8),
    ),
    ],
    ),
    child: Column(
    children: [

                      // 👤 Profile Image
    GestureDetector(
    onTap: _pickImage,
    child: Stack(
    alignment: Alignment.center,
    children: [
    CircleAvatar(
    radius: 65,
    backgroundColor: Colors.green.shade100,
    backgroundImage:
    _image != null ? FileImage(_image!) : null,
    child: _image == null
    ? const Icon(Icons.person,
    size: 60, color: Colors.green)
        : null,
    ),
    Positioned(
    bottom: 5,
    right: 5,
    child: CircleAvatar(
    radius: 18,
    backgroundColor: Colors.green,
    child: const Icon(
    Icons.edit,
    size: 16,
    color: Colors.white,
    ),
    ),
    )
    ],
    ),
    ),

                      const SizedBox(height: 30),

                      // 📝 Name Field

      TextField(
        controller: _nameController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person),
          labelText: 'Full Name',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 20),

      TextField(
        controller: _phoneController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.phone),
          labelText: 'Phone Number',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 30),

      SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _saveProfileData,
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text(
            "Save Profile",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
        ),
      ),

      const SizedBox(height: 20),

      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    ],
    ),
    ),

          const SizedBox(height: 30),

          const Text(
            "🌾 Annada - Harvesting the Future",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }
}

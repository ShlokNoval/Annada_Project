

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart'; // ✅ NEW: Import for Markdown rendering

class ImageDetectionPage extends StatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  State<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  File? _image;
  final TextEditingController _cropController = TextEditingController();
  String? _resultText;

  @override
  void initState() {
    super.initState();
    _cropController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _resultText = null;
      });
    }
  }

  Future<String?> _getImageBase64(File? imageFile) async {
    if (imageFile == null) return null;
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _analyzeCrop() async {
    setState(() {
      _resultText = 'Analyzing...';
    });

    final imageBase64 = await _getImageBase64(_image);
    if (imageBase64 == null) {
      setState(() {
        _resultText = "No image selected.";
      });
      return;
    }

    final String cropType = _cropController.text;
    const String apiKey = "AIzaSyB9nAw3WGcDgTourM3GTyqtrb1poNW9IWA";
    final String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey";

    final String prompt = "Analyze the attached plant photo and describe any issues affecting its health. Suggest a solution. Crop: $cropType";

    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {"inline_data": {"mime_type": "image/jpeg", "data": imageBase64}}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final description = data["candidates"]?[0]["content"]["parts"]?[0]["text"] ??
            "No analysis found.";
        setState(() {
          _resultText = description;
        });
      } else {
        setState(() {
          _resultText = "Error: ${response.statusCode}, ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _resultText = "Error analyzing image: $e";
      });
    }
  }

  bool get _canAnalyze {
    return _image != null && _cropController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Detection'),
        backgroundColor: Colors.green.shade700,  // ✅ No const
      ),
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.green.shade50,
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 60,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(  // ✅ REMOVED const - FIXED!
                        "Tap to select image",
                        style: TextStyle(
                          color: Colors.green.shade700,  // ✅ Now safe
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cropController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: 'Enter crop type',
                prefixIcon: Icon(Icons.grass, color: Colors.green),  // ✅ Removed const
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canAnalyze ? _analyzeCrop : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canAnalyze ? Colors.green.shade600 : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _canAnalyze ? 6 : 0,
                ),
                child: const Text(
                  'Upload & Analyze',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_resultText != null)
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      child: MarkdownBody( // ✅ CHANGED: Use MarkdownBody instead of SelectableText
                        data: _resultText!,
                        selectable: true, // Allow text selection
                        styleSheet: MarkdownStyleSheet( // Optional: Customize styles if needed
                          p: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    final loc = AppLocalizations.of(context)!;

    setState(() {
      _resultText = loc.analyzing;
    });

    final imageBase64 = await _getImageBase64(_image);

    if (imageBase64 == null) {
      setState(() {
        _resultText = loc.noImageSelected;
      });
      return;
    }

    final String cropType = _cropController.text;
    late final String apiKey = dotenv.env['GEMINI_API_KEY']!;

    final String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    // 🔥 Detect selected language
    final langCode = Localizations.localeOf(context).languageCode;

    String languageName;

    switch (langCode) {
      case 'hi': languageName = "Hindi"; break;
      case 'mr': languageName = "Marathi"; break;
      case 'ta': languageName = "Tamil"; break;
      case 'te': languageName = "Telugu"; break;
      case 'kn': languageName = "Kannada"; break;
      case 'ml': languageName = "Malayalam"; break;
      case 'gu': languageName = "Gujarati"; break;
      case 'pa': languageName = "Punjabi"; break;
      case 'bn': languageName = "Bengali"; break;
      case 'or': languageName = "Odia"; break;
      case 'as': languageName = "Assamese"; break;
      case 'ur': languageName = "Urdu"; break;
      case 'sa': languageName = "Sanskrit"; break;
      default: languageName = "English";
    }

    final String prompt = """You are Annada, an expert AI agronomist helping Indian farmers.

Respond strictly in $languageName language.

Analyze the attached plant image carefully.

Start your response STRICTLY with the following structured parameters in this exact format, using bullet points:
- Plant Name: 
- Credibility: (High/Medium/Low)
- Risk Level: (High/Medium/Low)
- Plant Disease Name:
- Accuracy of the answer: (percentage %)
- Severity Score: (1-10)
- Immediate Action: (one line recommendation)

Then, continue with:

- Diagnosis: [detailed diagnosis]
- Causes: [list of causes in bullets]
- Step-by-step Treatment: [numbered steps]
- Prevention Tips: [bulleted tips]

Crop Type: $cropType

Do not include any greetings, introductions, or additional text outside this structure.""";

    final headers = {
      'Content-Type': 'application/json'
    };

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": imageBase64
              }
            }
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

        final description =
            data["candidates"]?[0]["content"]["parts"]?[0]["text"] ??
                "No analysis found.";

        setState(() {
          _resultText = description;
        });

      } else {

        setState(() {
          _resultText =
          "Error: ${response.statusCode}, ${response.reasonPhrase}";
        });

      }

    } catch (e) {

      setState(() {
        _resultText = "${loc.analysisError}: $e";
      });

    }
  }

  bool get _canAnalyze {
    return _image != null &&
        _cropController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.cropDetectionTitle),
        backgroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.green.shade50,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                      Icon(Icons.add_photo_alternate,
                          size: 60,
                          color: Colors.green.shade600),
                      const SizedBox(height: 8),
                      Text(
                        loc.tapToSelectImage,
                        style: TextStyle(
                          color: Colors.green.shade700,
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
                  onPressed: () =>
                      _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.upload_file),
                  label: Text(loc.uploadImage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(loc.takePhoto),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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
                labelText: loc.enterCropType,
                prefixIcon: const Icon(
                  Icons.grass,
                  color: Colors.green,
                ),
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
                  backgroundColor: _canAnalyze
                      ? Colors.green.shade600
                      : Colors.grey,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  elevation: _canAnalyze ? 6 : 0,
                ),
                child: Text(
                  loc.uploadAndAnalyze,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_resultText != null)
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: _resultText!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
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
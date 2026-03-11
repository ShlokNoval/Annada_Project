import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");

  File? selectedImage;
  bool _isSending = false;
  bool _imageLoading = false;
  String _loadingText = "Uploading";
  Timer? _loadingTimer;

  late final String apiKey = dotenv.env['GEMINI_API_KEY']!;
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(loc.annadaAssistance),
        backgroundColor: Colors.green,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    final loc = AppLocalizations.of(context)!;

    List<String> faqs = [
      loc.faq1,
      loc.faq2,
      loc.faq3,
      loc.faq4,
      loc.faq5,
    ];

    return Stack(
      children: [

        Positioned.fill(
          child: Image.asset(
            "assets/gemini_background.jpeg",
            fit: BoxFit.cover,
          ),
        ),

        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),

        Column(
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerLeft,
              child: Text(
                loc.farmerFaqs,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: faqs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      ChatMessage msg = ChatMessage(
                        user: currentUser,
                        createdAt: DateTime.now(),
                        text: faqs[index],
                      );
                      _sendMessage(msg);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Center(
                        child: Text(
                          faqs[index],
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            if (selectedImage != null)
              Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                height: 160,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _imageLoading
                          ? Center(
                        child: Text(
                          "$_loadingText...",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : Image.file(
                        selectedImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (!_imageLoading)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            if (!_isSending) {
                              setState(() {
                                selectedImage = null;
                              });
                            }
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            Expanded(
              child: DashChat(
                currentUser: currentUser,
                messages: messages,
                onSend: (ChatMessage chatMessage) async {
                  await _sendMessage(chatMessage);
                },
                inputOptions: InputOptions(
                  trailing: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.green),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
                messageOptions: MessageOptions(
                  messageTextBuilder:
                      (ChatMessage msg, ChatMessage? prev, ChatMessage? next) {

                    bool isUser = msg.user.id == currentUser.id;

                    return MarkdownBody(
                      data: msg.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final loc = AppLocalizations.of(context)!;

    final picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        _imageLoading = true;
        _loadingText = loc.uploading;
      });

      _loadingTimer?.cancel();
      _loadingTimer =
          Timer.periodic(const Duration(milliseconds: 500), (timer) {
            setState(() {
              if (_loadingText.endsWith("...")) {
                _loadingText = loc.uploading;
              } else {
                _loadingText += ".";
              }
            });
          });

      try {
        await precacheImage(FileImage(selectedImage!), context);
      } catch (e) {
        setState(() {
          selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${loc.failedToLoadImage}: $e")),
        );
      } finally {
        _loadingTimer?.cancel();
        setState(() {
          _imageLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (_isSending || _imageLoading) return;

    final loc = AppLocalizations.of(context)!;

    setState(() {
      _isSending = true;
    });

    File? imageToSend = selectedImage;

    setState(() {
      selectedImage = null;
      _imageLoading = false;
    });

    _loadingTimer?.cancel();

    ChatMessage userMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: chatMessage.text,
      medias: imageToSend != null
          ? [
        ChatMedia(
          url: imageToSend.path,
          fileName: "image.jpg",
          type: MediaType.image,
        )
      ]
          : [],
    );

    setState(() {
      messages.insert(0, userMessage);
    });

    ChatMessage botMessage = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: imageToSend != null
          ? loc.analyzingImage
          : loc.thinking,
    );

    setState(() {
      messages.insert(0, botMessage);
    });

    try {
      final response =
      await _fetchGeminiResponse(chatMessage.text, imageToSend);

      String reply = response ?? loc.noResponseReceived;

      int botIndex = messages.indexOf(botMessage);

      if (botIndex != -1) {
        setState(() {
          messages[botIndex] = ChatMessage(
            user: geminiUser,
            createdAt: botMessage.createdAt,
            text: reply,
          );
        });
      }
    } catch (e) {
      int botIndex = messages.indexOf(botMessage);
      if (botIndex != -1) {
        setState(() {
          messages[botIndex] = ChatMessage(
            user: geminiUser,
            createdAt: botMessage.createdAt,
            text: loc.errorFetchingResponse,
          );
        });
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<String?> _fetchGeminiResponse(
      String prompt, File? imageFile) async {

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

    final modifiedPrompt =
        "Respond strictly in $languageName language.\n\n$prompt";

    final uri = Uri.parse("$apiUrl?key=$apiKey");

    Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": modifiedPrompt}
          ]
        }
      ]
    };

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      requestBody["contents"][0]["parts"].add({
        "inlineData": {
          "mimeType": "image/jpeg",
          "data": base64Image
        }
      });
    }

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"]?[0]["content"]["parts"]?[0]["text"];
    } else {
      return null;
    }
  }
}
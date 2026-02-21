
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // ✅ NEW: Import for Markdown rendering
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  static const String apiKey = "AIzaSyBBzqoE5Mf48a2OSqUvE1eLKHhFaZ7LDI8";
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Annada Assistance"),
        backgroundColor: Colors.green,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    List<String> faqs = [
      "What is the best fertilizer for tomatoes?",
      "How to prevent pest attacks on crops?",
      "What crops are suitable for summer season?",
      "How to conserve water in farming?",
      "What is the ideal soil pH for rice cultivation?",
    ];

    return Column(
      children: [
        // FAQ Section
        Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
          child: const Text(
            "💬 Farmer FAQs:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Center(
                    child: Text(
                      faqs[index],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // WhatsApp Style Preview
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
                      ),
                    ),
                  )
                      : Image.file(
                    selectedImage!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Close Button
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
            messageOptions: MessageOptions( // ✅ NEW: Add messageOptions for Markdown
              messageTextBuilder: (ChatMessage msg, ChatMessage? prev, ChatMessage? next) {
                return MarkdownBody(
                  data: msg.text,
                  selectable: true, // Optional: Allow text selection
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Pick Image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        _imageLoading = true;
        _loadingText = "Uploading";
      });

      // Start animation timer
      _loadingTimer?.cancel();
      _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          if (_loadingText == "Uploading...") {
            _loadingText = "Uploading";
          } else {
            _loadingText += ".";
          }
        });
      });

      // Precache the image to ensure it's loaded
      try {
        await precacheImage(FileImage(selectedImage!), context);
      } catch (e) {
        // Handle error: optionally show a snackbar or remove the image
        setState(() {
          selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load image: $e")),
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

    setState(() {
      _isSending = true;
    });

    // Move selectedImage to a temp variable and clear preview immediately
    File? imageToSend = selectedImage;
    setState(() {
      selectedImage = null;
      _imageLoading = false; // Just in case
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
          ? "Analyzing image..."
          : "Thinking...",
    );

    setState(() {
      messages.insert(0, botMessage);
    });

    try {
      final response =
      await _fetchGeminiResponse(chatMessage.text, imageToSend);

      String reply = response ?? "⚠️ No response received.";

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
            text: "⚠️ Error fetching response.",
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
    final uri = Uri.parse("$apiUrl?key=$apiKey");

    Map<String, dynamic> requestBody;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      };
    } else {
      requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      };
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
      try {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['error']?['message'] ?? "Unknown error";
        return "⚠️ Error: ${response.statusCode} - $errorMessage";
      } catch (_) {
        return "⚠️ Error: ${response.statusCode}";
      }
    }
  }
}
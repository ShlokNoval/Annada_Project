import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");

  static const String apiKey = "AIzaSyCrn-feXL3CmjbI3bMhLoANEfvu8CH229Q"; // Replace with actual API key
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Annada Assistance"),
        backgroundColor: Colors.green.shade700,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Center(
                    child: Text(
                      faqs[index],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: DashChat(
            inputOptions: InputOptions(),
            currentUser: currentUser,
            onSend: _sendMessage,
            messages: messages,
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages.insert(0, chatMessage);
    });

    ChatMessage botMessage = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: "Thinking...",
    );

    setState(() {
      messages.insert(0, botMessage);
    });

    try {
      final response = await _fetchGeminiResponse(chatMessage.text);
      String reply = response ?? "⚠️ No response received.";

      setState(() {
        int botMessageIndex = messages.indexOf(botMessage);
        if (botMessageIndex != -1) {
          messages[botMessageIndex] = ChatMessage(
            user: geminiUser,
            createdAt: botMessage.createdAt,
            text: reply,
          );
        }
      });
    } catch (e) {
      debugPrint("❌ Error: $e");
      setState(() {
        int botMessageIndex = messages.indexOf(botMessage);
        if (botMessageIndex != -1) {
          messages[botMessageIndex] = ChatMessage(
            user: geminiUser,
            createdAt: botMessage.createdAt,
            text: "⚠️ Error fetching response. Please check API key and internet connection.",
          );
        }
      });
    }
  }

  Future<String?> _fetchGeminiResponse(String prompt) async {
    final uri = Uri.parse("$apiUrl?key=$apiKey");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "contents": [
        {"parts": [{"text": prompt}]}
      ]
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"]?[0]["content"]["parts"]?[0]["text"];
    } else {
      debugPrint("❌ Error ${response.statusCode}: ${response.body}");
      return "⚠️ Error: ${response.statusCode} - ${response.reasonPhrase}";
    }
  }
}

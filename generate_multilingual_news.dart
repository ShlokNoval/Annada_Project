import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const languages = {
  "hi": "Hindi",
  "mr": "Marathi",
  "ta": "Tamil",
  "te": "Telugu",
  "bn": "Bengali",
  "gu": "Gujarati",
  "kn": "Kannada",
  "ml": "Malayalam",
  "pa": "Punjabi",
  "or": "Odia",
  "as": "Assamese",
  "ur": "Urdu"
};

Future<Map<String, dynamic>> translateNewsItem(
    Map<String, dynamic> newsItem, String language) async {

  final apiKey = dotenv.env['GEMINI_API_KEY']!;

  final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey");

  final prompt = jsonEncode({
    "title": newsItem["title"],
    "subtitle": newsItem["subtitle"],
    "content": newsItem["content"],
  });

  final body = jsonEncode({
    "contents": [
      {
        "parts": [
          {
            "text":
            "Translate the following JSON news item into $language. Return only JSON in this exact format:\n\n$prompt"
          }
        ]
      }
    ]
  });

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  if (response.statusCode != 200) {
    stderr.writeln(
        "❌ Gemini API Error for language $language: ${response.statusCode}");
    stderr.writeln(response.body);
    throw Exception("Gemini API failed");
  }

  final data = jsonDecode(response.body);

  if (data["candidates"] == null ||
      data["candidates"].isEmpty ||
      data["candidates"][0]["content"] == null) {
    stderr.writeln("❌ Unexpected Gemini response for $language:");
    stderr.writeln(response.body);
    throw Exception("Invalid Gemini response");
  }

  final translatedJsonString =
  data["candidates"][0]["content"]["parts"][0]["text"];

  String cleaned = translatedJsonString.trim();

  if (cleaned.startsWith("```")) {
    cleaned = cleaned.replaceAll(RegExp(r"```json"), "");
    cleaned = cleaned.replaceAll("```", "");
    cleaned = cleaned.trim();
  }

  try {
    return jsonDecode(cleaned);
  } catch (e) {
    stderr.writeln("❌ JSON Parse Error after cleaning:");
    stderr.writeln(cleaned);
    throw Exception("Invalid JSON from Gemini");
  }
}

Future<void> main() async {

  await dotenv.load(fileName: ".env");

  final file = File("news.json");

  if (!await file.exists()) {
    stderr.writeln("⚠ news.json not found in current directory!");
    exit(1);
  }

  final englishJson = jsonDecode(await file.readAsString());

  final Map<String, dynamic> output = {};

  for (var crop in englishJson.keys) {
    stderr.writeln("➡ Translating crop: $crop");
    final List<dynamic> originalList = englishJson[crop];

    output[crop] = {"en": originalList};

    for (var langCode in languages.keys) {
      stderr.writeln("  🔁 Translating to: $langCode");
      output[crop][langCode] = [];

      for (var item in originalList) {
        final Map<String, dynamic> translatedItem =
        await translateNewsItem(item, languages[langCode]!);
        output[crop][langCode].add(translatedItem);
      }
    }
  }

  final finalJson = JsonEncoder.withIndent("  ").convert(output);

  stdout.writeln(finalJson);

  await File("news_multilingual.json").writeAsString(finalJson);

  stderr.writeln("✅ Translation complete! Output saved to news_multilingual.json");
}
import 'package:flutter/material.dart';
import 'package:annadaauth1/models/circle_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DataScreen extends StatefulWidget {
  final CircleData circle;

  const DataScreen({super.key, required this.circle});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  List<Map<String, String>> newsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final String jsonString =
      await rootBundle.loadString('assets/news_multilingual.json');

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final locale = Localizations.localeOf(context).languageCode;

      final dynamic circleData = jsonData[widget.circle.name];

      List<dynamic> rawNews = [];

      if (circleData is Map<String, dynamic>) {
        final localizedNews =
            circleData[locale] ?? circleData['en'];

        if (localizedNews is List) {
          rawNews = localizedNews;
        }
      }

      final List<Map<String, String>> parsedNews = [];

      for (var item in rawNews) {
        if (item is Map<String, dynamic>) {
          parsedNews.add({
            "title": item["title"]?.toString() ?? "",
            "subtitle": item["subtitle"]?.toString() ?? "",
            "content": item["content"]?.toString() ?? "",
          });
        }
      }

      if (mounted) {
        setState(() {
          newsList = parsedNews;
        });
      }
    } catch (e) {
      debugPrint("Error loading local news: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.circle.name)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Hero(
                tag: 'hero-${widget.circle.name}',
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          widget.circle.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.circle.description ??
                              local.noDescriptionAvailable,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        if (widget.circle.imageUrl.isNotEmpty)
                          Image.asset(
                            widget.circle.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 20),
                        const Divider(),
                        Text(
                          local.latestNews,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        isLoading
                            ? const CircularProgressIndicator()
                            : newsList.isEmpty
                            ? Text(local.noNewsAvailable)
                            : Column(
                          children: newsList.map((news) {
                            return ListTile(
                              leading: const Icon(
                                  Icons.article_outlined),
                              title: Text(
                                  news['title'] ??
                                      local.noTitle),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    news['subtitle'] ??
                                        local.noSubtitle,
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.w500),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    news['content'] ??
                                        local.noContentAvailable,
                                    style: const TextStyle(
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
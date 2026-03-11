import 'dart:convert';

import 'package:http/http.dart' as http;


import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {

  final String _apiKey = dotenv.env['NEWS_API_KEY']!;

  static const String _baseUrl = "https://newsapi.org/v2/everything";



  Future<List<Map<String, dynamic>>> fetchFarmingNews() async {

    try {

      final response = await http.get(

        Uri.parse(

          "$_baseUrl?q=farming OR agriculture OR crops OR irrigation&language=en&sortBy=publishedAt&pageSize=10&apiKey=$_apiKey",

        ),

      );



      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        List<Map<String, dynamic>> articles = [];



        for (var article in data['articles']) {

          if (article['urlToImage'] != null && article['title'] != null) {

            articles.add({

              'title': article['title'],

              'description': article['description'] ?? '',

              'imageUrl': article['urlToImage'],

              'publishedAt': article['publishedAt'],

              'url': article['url'],

            });

          }

        }

        return articles;

      }

    } catch (e) {

      print('Error fetching news: $e');

    }



    // Fallback dummy data if API fails

    return [

      {

        'title': 'Latest Farming Techniques Boost Crop Yield',

        'description': 'New irrigation methods show promising results...',

        'imageUrl': 'https://via.placeholder.com/300x200?text=Farming+News',

        'publishedAt': DateTime.now().toIso8601String(),

        'url': '#',

      },

      {

        'title': 'Weather Alert: Monsoon Updates for Farmers',

        'description': 'Stay updated with latest weather predictions...',

        'imageUrl': 'https://via.placeholder.com/300x200?text=Weather+Update',

        'publishedAt': DateTime.now().toIso8601String(),

        'url': '#',

      },

    ];

  }

}
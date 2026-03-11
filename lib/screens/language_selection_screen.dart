import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {

  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Title
            Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Dropdown
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English (English)')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi (हिंदी)')),
                DropdownMenuItem(value: 'mr', child: Text('Marathi (मराठी)')),
                DropdownMenuItem(value: 'gu', child: Text('Gujarati (ગુજરાતી)')),
                DropdownMenuItem(value: 'pa', child: Text('Punjabi (ਪੰਜਾਬੀ)')),
                DropdownMenuItem(value: 'bn', child: Text('Bengali (বাংলা)')),
                DropdownMenuItem(value: 'ta', child: Text('Tamil (தமிழ்)')),
                DropdownMenuItem(value: 'te', child: Text('Telugu (తెలుగు)')),
                DropdownMenuItem(value: 'kn', child: Text('Kannada (ಕನ್ನಡ)')),
                DropdownMenuItem(value: 'ml', child: Text('Malayalam (മലയാളം)')),
                DropdownMenuItem(value: 'or', child: Text('Odia (ଓଡ଼ିଆ)')),
                DropdownMenuItem(value: 'as', child: Text('Assamese (অসমীয়া)')),
                DropdownMenuItem(value: 'ur', child: Text('Urdu (اردو)')),
                DropdownMenuItem(value: 'sa', child: Text('Sanskrit (संस्कृतम्)')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
            ),

            const SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                      'selected_language', selectedLanguage);

                  // Update app locale instantly
                  MyApp.of(context)!.setLocale(selectedLanguage);

                  // Navigate to AuthWrapper
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthWrapper(),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.continueButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
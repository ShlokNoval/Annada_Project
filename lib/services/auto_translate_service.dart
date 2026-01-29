import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoTranslateService {
  static final GoogleTranslator _translator = GoogleTranslator();
  static String? _cachedLanguageCode;
  static final Map<String, String> _translationCache = {};

  static Future<String> _getLanguageCode() async {
    if (_cachedLanguageCode != null) return _cachedLanguageCode!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _cachedLanguageCode = prefs.getString('languageCode') ?? 'en';
    return _cachedLanguageCode!;
  }

  static void clearCache() {
    _cachedLanguageCode = null;
    _translationCache.clear();
  }

  // Translate any English text to user's language
  static Future<String> t(String text) async {
    String languageCode = await _getLanguageCode();
    if (languageCode == 'en' || text.isEmpty) return text;

    String cacheKey = '${languageCode}_$text';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      var translation = await _translator.translate(text, from: 'en', to: languageCode);
      _translationCache[cacheKey] = translation.text;
      return translation.text;
    } catch (e) {
      return text;
    }
  }

  // Add language instruction to AI prompts
  static Future<String> aiPrompt(String text) async {
    String languageCode = await _getLanguageCode();
    String instruction = '';

    switch (languageCode) {
      case 'hi':
        instruction = 'कृपया हिंदी में जवाब दें। ';
        break;
      case 'mr':
        instruction = 'कृपया मराठीत उत्तर द्या। ';
        break;
    }

    return instruction + text;
  }

  // Get language code for API calls
  static Future<String> getApiLanguage() async {
    String code = await _getLanguageCode();
    if (code == 'mr') return 'hi'; // Fallback for unsupported languages
    return code;
  }
}

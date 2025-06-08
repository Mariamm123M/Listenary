import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<String>> fetchDefinition(String word,
    {String wordLang = "en"}) async {
  String cleanedWord = word.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), '');
  print("Fetching definition for $cleanedWord in $wordLang");
  try {
    var response = await http
        .post(
          Uri.parse('http://192.168.1.4:5004/define'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "word": cleanedWord,
            "wordLang": wordLang,
          }),
        )
        .timeout(Duration(seconds: 10)); // قللنا التايم آوت هنا

    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List definitions = data['definitions'];
      return definitions.take(3).map((e) => e.toString()).toList();
    } else {
      // Show error indicator
      return wordLang == 'ar'
          ? ["تعذر جلب التعريف للكلمة '$word'"]
          : ["Could not fetch definition for '$word'"];
    }
  } catch (e) {
    return wordLang == 'ar'
        ? ["لا يوجد تعريف في الويكيبديا: $e"]
        : ["An error occurred while fetching the definition: $e"];
  }
}

String isArabic(String text) {
  final arabicRegExp = RegExp(r'[\u0600-\u06FF]');
  return arabicRegExp.hasMatch(text) ? "ar" : "en";
}
 String detectLanguage(String text) {
    // Check for Arabic characters (includes Arabic, Persian, Urdu, etc.)
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    // Check for English letters
    final englishRegex = RegExp(r'[a-zA-Z]');

    bool hasArabic = arabicRegex.hasMatch(text);
    bool hasEnglish = englishRegex.hasMatch(text);

    if (hasArabic && !hasEnglish) {
      return 'ar'; // Arabic text
    } else if (hasEnglish && !hasArabic) {
      return 'en'; // English text
    } else if (hasArabic && hasEnglish) {
      // Count characters to determine dominant language
      int arabicCount =
          text.split('').where((c) => arabicRegex.hasMatch(c)).length;
      int englishCount =
          text.split('').where((c) => englishRegex.hasMatch(c)).length;
      return arabicCount > englishCount ? 'ar' : 'en';
    } else {
      return 'en'; // Default to English if no letters detected
    }
  }

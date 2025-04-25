import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<String>> fetchDefinition(String word,
    {String selectedLang = "en"}) async {
 
  String cleanedWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
  print("Fetching definition for $cleanedWord in $selectedLang");
  try {
    var response = await http
        .post(
          Uri.parse('http://192.168.39.48:5004/define'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "word": cleanedWord,
            "lang": selectedLang,
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
      return selectedLang == 'ar'
          ? ["تعذر جلب التعريف للكلمة '$word'"]
          : ["Could not fetch definition for '$word'"];
    }
  } catch (e) {
    return selectedLang == 'ar'
        ? ["حدث خطأ أثناء جلب التعريف: $e"]
        : ["An error occurred while fetching the definition: $e"];
  }
}

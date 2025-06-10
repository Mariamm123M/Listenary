import 'package:get/get.dart';
import 'en_translations.dart';
import 'ar_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': enTranslations,
    'ar': arTranslations,
  };
}

import 'package:get/get.dart';

class HighlightController extends GetxController {
  final RxString _highlightedWord = ''.obs;
  RxBool highlightFromSearchOnly = false.obs;

  String get highlightedWord => _highlightedWord.value;

  void updateHighlight(String word) {
    _highlightedWord.value = word;
  }

  void clearHighlight() {
    _highlightedWord.value = '';
  }
}

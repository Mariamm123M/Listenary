import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:listenary/controller/highlightedController.dart';

class MySearchController extends GetxController {
  RxBool isSearching = false.obs;
  RxString searchTerm = ''.obs;
  RxList<int> matchIndexes = <int>[].obs;
  RxInt currentMatchIndex = 0.obs;
  final highlightController = Get.find<HighlightController>();
late ScrollController scrollController;
  final TextEditingController textController = TextEditingController();

  // Store all words and their positions
  List<String> allWords = [];
  List<Offset> wordPositions = [];

  void initializeSearch(List<String> sentences) {
    allWords = sentences.expand((sentence) => sentence.split(' ')).toList();
  }
void attachToScrollController(ScrollController controller) {
  scrollController = controller;
}
  void updateSearchTerm(String term) {
    searchTerm.value = term;
    textController.text = term;
    currentMatchIndex.value = 0;

    matchIndexes.clear();
    for (int i = 0; i < allWords.length; i++) {
      if (allWords[i].toLowerCase().contains(term.toLowerCase())) {
        matchIndexes.add(i);
      }
    }

   if (matchIndexes.isNotEmpty) {
  highlightController.highlightFromSearchOnly.value = true;
  highlightController.updateHighlight(allWords[matchIndexes.first]);

  // Scroll بعد frame الجاي عشان نتأكد الـ ScrollController اتحط
  Future.delayed(Duration(milliseconds: 100), () {
    if (scrollController.hasClients) {
      _scrollToMatch(matchIndexes.first);
    }
  });
}

  }

  void nextMatch() {
    if (matchIndexes.isNotEmpty) {
      currentMatchIndex.value =
          (currentMatchIndex.value + 1) % matchIndexes.length;
      _scrollToMatch(matchIndexes[currentMatchIndex.value]);
    }
  }

  void previousMatch() {
    if (matchIndexes.isNotEmpty) {
      currentMatchIndex.value =
          (currentMatchIndex.value - 1 + matchIndexes.length) %
              matchIndexes.length;
      _scrollToMatch(matchIndexes[currentMatchIndex.value]);
    }
  }

  void _scrollToMatch(int wordIndex) {
    highlightController.updateHighlight(allWords[wordIndex]);

    // Calculate scroll position (adjust based on your layout)
    double scrollOffset = wordIndex * 30.0; // Approximate height per word
    scrollController.animateTo(
      scrollOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void close() {
    searchTerm.value = '';
    highlightController.highlightFromSearchOnly .value = false;
    textController.clear();
    highlightController.updateHighlight("");
    matchIndexes.clear();
    isSearching.value = false;
    currentMatchIndex.value = 0;
  }
}


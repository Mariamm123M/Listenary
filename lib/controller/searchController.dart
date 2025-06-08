import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:listenary/controller/highlightedController.dart';

class MySearchController extends GetxController {
  RxBool isSearching = false.obs;
  RxString searchTerm = ''.obs;
  RxList<TextMatch> matchIndexes = <TextMatch>[].obs;
  RxInt currentMatchIndex = 0.obs;
  final highlightController = Get.find<HighlightController>();
  late ScrollController scrollController;
  final TextEditingController textController = TextEditingController();
  late List<String> sentences;
  
  // Store sentence positions and heights
  final Map<int, double> sentencePositions = {};
  final Map<int, double> sentenceHeights = {};
  
  // Store the full text for more accurate search
  String fullText = '';
  List<int> sentenceStartPositions = [];
  
  // Fixed height of the bottom box that might obscure text
  final double bottomBoxHeight = 400;
  
  void initializeSearch(List<String> newSentences) {
    sentences = newSentences;
    // Clear previous data
    sentencePositions.clear();
    sentenceHeights.clear();
    sentenceStartPositions.clear();
    
    // Calculate character positions for each sentence
    fullText = '';
    for (int i = 0; i < sentences.length; i++) {
      sentenceStartPositions.add(fullText.length);
      fullText += sentences[i];
      // Add space between sentences if needed
      if (i < sentences.length - 1) {
        fullText += ' ';
      }
    }
    
    // Calculate approximate positions and heights
    double currentPosition = 0;
    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i];
      final lineCount = (sentence.length / 50).ceil(); // Approximate lines
      final height = lineCount * 24.0; // Approximate line height

      sentencePositions[i] = currentPosition;
      sentenceHeights[i] = height;
      currentPosition += height + 8; // Add some padding
    }
  }

  void attachToScrollController(ScrollController controller) {
    scrollController = controller;
  }

  void updateSearchTerm(String term) {
    searchTerm.value = term;
    textController.text = term;
    currentMatchIndex.value = 0;
    matchIndexes.clear();

    if (term.isEmpty) {
      highlightController.highlightFromSearchOnly.value = false;
      highlightController.clearHighlight();
      return;
    }

    // Search by actual character position in the full text
    String searchTermLower = term.toLowerCase();
    String fullTextLower = fullText.toLowerCase();
    
    int startIndex = 0;
    while (true) {
      int foundIndex = fullTextLower.indexOf(searchTermLower, startIndex);
      if (foundIndex == -1) break;
      
      // Find which sentence this match belongs to
      int sentenceIndex = _findSentenceForPosition(foundIndex);
      if (sentenceIndex != -1) {
        // Calculate relative position within the sentence for better scrolling
        int relativePos = foundIndex - sentenceStartPositions[sentenceIndex];
        matchIndexes.add(TextMatch(
          sentenceIndex: sentenceIndex,
          startPos: relativePos,
          endPos: relativePos + term.length,
          absolutePos: foundIndex
        ));
      }
      
      startIndex = foundIndex + 1; // Move to search for next occurrence
    }

    if (matchIndexes.isNotEmpty) {
      highlightController.highlightFromSearchOnly.value = true;
      highlightController.updateHighlight(term);

      Future.delayed(Duration(milliseconds: 50), () {
        if (scrollController.hasClients) {
          _scrollToMatch(matchIndexes.first);
        }
      });
    } else {
      highlightController.highlightFromSearchOnly.value = false;
      highlightController.updateHighlight("");
    }
  }
  
  // Find which sentence contains the given character position
  int _findSentenceForPosition(int pos) {
    for (int i = 0; i < sentenceStartPositions.length; i++) {
      int startPos = sentenceStartPositions[i];
      int endPos = i < sentenceStartPositions.length - 1 
          ? sentenceStartPositions[i + 1] - 1 
          : fullText.length;
          
      if (pos >= startPos && pos <= endPos) {
        return i;
      }
    }
    return -1;
  }

  bool isTextMatch(int sentenceIndex, String text, int position) {
    if (searchTerm.value.isEmpty) return false;
    
    for (var match in matchIndexes) {
      if (match.sentenceIndex == sentenceIndex) {
        String lowerText = text.toLowerCase();
        String lowerTerm = searchTerm.value.toLowerCase();
        
        int foundPos = lowerText.indexOf(lowerTerm, position);
        if (foundPos != -1 && 
            foundPos <= position && 
            position < foundPos + lowerTerm.length) {
          return true;
        }
      }
    }
    return false;
  }

  bool isCurrentMatch(int sentenceIndex, int position) {
    if (matchIndexes.isEmpty) return false;
    
    final match = matchIndexes[currentMatchIndex.value];
    if (match.sentenceIndex != sentenceIndex) return false;
    
    return position >= match.startPos && position < match.endPos;
  }

  void nextMatch() {
    if (matchIndexes.isEmpty) return;
    currentMatchIndex.value = (currentMatchIndex.value + 1) % matchIndexes.length;
    _scrollToMatch(matchIndexes[currentMatchIndex.value]);
  }

  void previousMatch() {
    if (matchIndexes.isEmpty) return;
    currentMatchIndex.value = (currentMatchIndex.value - 1 + matchIndexes.length) % matchIndexes.length;
    _scrollToMatch(matchIndexes[currentMatchIndex.value]);
  }

  void _scrollToMatch(TextMatch match) {
    if (!sentencePositions.containsKey(match.sentenceIndex)) return;

    // Update the highlight - ensure correct match is highlighted
    highlightController.updateHighlight(searchTerm.value);
    
    // Calculate approximate position within sentence based on character position
    final sentencePos = sentencePositions[match.sentenceIndex]!;
    final sentenceHeight = sentenceHeights[match.sentenceIndex]!;
    
    // Calculate more accurate position within the sentence
    final sentence = sentences[match.sentenceIndex];
    
    // Estimate line number within the sentence
    final charsPerLine = 50; // Same as used in height calculation
    final lineNumber = (match.startPos / charsPerLine).floor();
    final lineHeight = 24.0; // Same as used in height calculation
    
    // Calculate more accurate position of the match
    final matchPosition = sentencePos + (lineNumber * lineHeight);
    
    // Calculate height of the match (might span multiple lines)
    final matchLength = match.endPos - match.startPos;
    final matchLineCount = (matchLength / charsPerLine).ceil();
    final matchHeight = matchLineCount * lineHeight;
    
    if (scrollController.hasClients) {
      final viewportHeight = scrollController.position.viewportDimension;
      
      // Calculate the safe area of the viewport (excluding bottom box)
      final safeViewportHeight = viewportHeight - bottomBoxHeight;
      final safeAreaBottom = safeViewportHeight;
      
      // Calculate where we need to position the scroll to ensure visibility
      double targetPosition;
      
      // Add a safety margin for better visibility
      final safetyMargin = 20.0;
      
      // Calculate position to ensure match is fully visible and not behind the bottom box
      targetPosition = matchPosition - (safeViewportHeight / 2);
      
      // Special case: if the match is near the end of the document
      if (matchPosition + matchHeight + safetyMargin > scrollController.position.maxScrollExtent) {
        // Position so that it's as visible as possible
        targetPosition = scrollController.position.maxScrollExtent - safeViewportHeight + safetyMargin;
      }
      
      // Ensure matched text is never placed at the bottom where it would be hidden
      // If the match would end up in bottom box territory, shift it up
      final projectedMatchBottomPosition = matchPosition + matchHeight - targetPosition;
      if (projectedMatchBottomPosition > safeAreaBottom - safetyMargin) {
        // Reposition to ensure match is above the bottom box
        targetPosition = matchPosition + matchHeight - safeAreaBottom + safetyMargin * 2;
      }
      
      // Ensure we don't scroll past document boundaries
      targetPosition = targetPosition.clamp(
        0.0,
        scrollController.position.maxScrollExtent,
      );
      
      // Smooth scroll animation
      scrollController.animateTo(
        targetPosition,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void close() {
    searchTerm.value = '';
    highlightController.highlightFromSearchOnly.value = false;
    textController.clear();
    highlightController.updateHighlight("");
    matchIndexes.clear();
    isSearching.value = false;
    currentMatchIndex.value = 0;
  }
}

class TextMatch {
  final int sentenceIndex;
  final int startPos; // Start position within sentence
  final int endPos;   // End position within sentence
  final int absolutePos; // Position in the full text
  
  TextMatch({
    required this.sentenceIndex, 
    required this.startPos, 
    required this.endPos,
    required this.absolutePos,
  });
}
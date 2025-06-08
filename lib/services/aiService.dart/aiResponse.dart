import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/highlightedController.dart';
import 'package:listenary/controller/notesController.dart';
import 'package:listenary/controller/searchController.dart' as my_search;
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/SummaryDialog.dart';
import 'package:listenary/view/components/TranslateDialog.dart';
import 'package:listenary/view/components/definition_overlay.dart';
import 'package:listenary/view/components/executions.dart';
import 'package:listenary/view/components/myNotes.dart';

class AiResponse {
  final String? command;
  final String? argument;
  final String? predefinedResponse;
  final bool isCommand;
  //final String lang = "en";
  final DefinitionOverlayController overlayController =
      DefinitionOverlayController();
  final highlightController = Get.find<HighlightController>();
  final searchController = Get.find<my_search.MySearchController>();
  final mynoteController = Get.find<NoteController>();

  AiResponse({
    required this.command,
    required this.argument,
    required this.predefinedResponse,
    required this.isCommand,
  });

  static const Map<String, List<String>> targetWords = {
    "en-US": [
      "define",
      "find",
      "show",
      "translate",
      "summarize",
    ],
    "ar-AR": ["اعرض", "ترجم", "عرف", "لخص", "ابحث"]
  };

  static Map<String, Map<String, String>> predefinedResponses = {
    "en-US": {
      "define": " i got it let's find the definition",
      "find": "i got it let's find it",
      "show": "i got it let's find your notes",
      "translate": "Starting translation",
      "summarize": "Summarizing the content",
    },
    "ar-AR": {
      "عرف": "جارٍ تعريف الكلمة",
      "ترجم": "جارٍ بدء الترجمة",
      "لخص": "جارٍ تلخيص المحتوى",
      "اعرض": "جارٍ عرض ملاحظاتك",
      "ابحث": "سيتم البحث اللآن"
    }
  };

  factory AiResponse.process(String speech, String lang) {
    final List<String>? commands = targetWords[lang];

    if (commands != null) {
      for (var cmd in commands) {
        if (speech.toLowerCase().startsWith(cmd.toLowerCase())) {
          final argument = speech.substring(cmd.length).trim();
          final predefined = predefinedResponses[lang]?[cmd];
          return AiResponse(
            command: cmd,
            argument: argument.isNotEmpty ? argument : null,
            predefinedResponse: predefined,
            isCommand: true,
          );
        }
      }
    }

    return AiResponse(
      command: null,
      argument: null,
      predefinedResponse: null,
      isCommand: false,
    );
  }
  Future<void> executeCommand({
    required BuildContext context,
    required Offset tapPosition,
    required double screenHeight,
    required double screenWidth,
    required void Function(bool) setLoading,
    required List<String> sentences,
    required int currentSentenceIndex,
    Book? book,
  }) async {
    switch (command) {
      case "define" || "عرف":
        setLoading(true);
        overlayController.show(
          context: context,
          isLoading: true,
          position: tapPosition,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          cleanedWord: argument!,
          definitions: [],
          selectedFontFamily: "Inter",
          wordLang: isArabic(argument!),
          onDismiss: () {
            setLoading(false);
          },
        );

        final fetchedDefinitions =
            await fetchDefinition(argument!, wordLang: isArabic(argument!));
        setLoading(false);
        overlayController.dismiss();

        overlayController.show(
          wordLang: isArabic(argument!),
          context: context,
          isLoading: false,
          position: tapPosition,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          cleanedWord: argument!,
          definitions: fetchedDefinitions,
          selectedFontFamily: "Inter",
          onDismiss: () {},
        );
        break;
      case "find" || "ابحث":
        Get.back();
        if (searchController.isSearching.value) searchController.close();
        searchController.isSearching.value = true;
        searchController.initializeSearch(sentences);
        searchController.updateSearchTerm(argument!);
        highlightController.updateHighlight(argument!);
        print("search for {$argument}");
        break;
      case "show" || "اعرض":
        Get.dialog(
          NotesDialog(book: book, screenWidth: screenWidth),
        );
        break;
      case "summarize" || "لخص":
        Get.dialog(SummaryDialog(
          isDarkMode: true,
          initial: sentences[1],
        ));
        break;
      case "translate" || "ترجم":
        Get.dialog(
          TranslateDialog(
            isDarkMode: true,
            initial: sentences[currentSentenceIndex],
            fromLanguage: detectLanguage(sentences[currentSentenceIndex]) == "en"? "English" : "Arabic",
            toLanguage: detectLanguage(sentences[currentSentenceIndex]) == "en"? "Arabic" : "English",
          ),
          barrierDismissible: true,
        );
        break;
      default:
        print("Unknown or unsupported command");
        Get.back();
    }
  }
}

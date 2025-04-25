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
  final String lang = "en";
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
    "ar-AR": [
      "توقف",
      "استأنف",
      "ترجم",
      "لخص",
      "إيقاف",
      "زِد السرعة",
      "أبطئ",
      "احفظ علامة",
      "عرف"
    ]
  };

  static Map<String, Map<String, String>> predefinedResponses = {
    "en-US": {
      "define": " i got it let's find the definition",
      "find": "i got it let's find it",
      "show": "i got it let's find your notes",
      "pause": "Pausing the playback",
      "resume": "Resuming the playback",
      "translate": "Starting translation",
      "summarize": "Summarizing the content",
      "stop": "Stopping the playback",
      "increase speed": "Increasing playback speed",
      "slow down": "Slowing down playback speed.",
      "bookmark": "Bookmark added",
    },
    "ar-AR": {
      "توقف": "تم إيقاف التشغيل",
      "استأنف": "تم استئناف التشغيل",
      "ترجم": "جارٍ بدء الترجمة",
      "لخص": "جارٍ تلخيص المحتوى",
      "إيقاف": "تم إيقاف التشغيل",
      "زِد السرعة": "جارٍ زيادة سرعة التشغيل.",
      "أبطئ": "جارٍ تخفيض سرعة التشغيل",
      "احفظ علامة": "تمت إضافة علامة مرجعية"
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
    required String selectedLang,
    required void Function(bool) setLoading,
    required List<String> sentences,
    required int currentSentenceIndex,
    Book? book,
  }) async {
    switch (command) {
      case "define":
        if (argument == null || argument!.isEmpty) {
          predefinedResponses["en-US"]?["define"] = "Sorry i can't get it";
          print("Sorry i can't get it");
          return;
        }
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
          selectedLang: selectedLang,
          onDismiss: () {
            setLoading(false);
          },
        );

        final fetchedDefinitions =
            await fetchDefinition(argument!, selectedLang: selectedLang);
        setLoading(false);
        overlayController.dismiss();

        overlayController.show(
          context: context,
          isLoading: false,
          position: tapPosition,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          cleanedWord: argument!,
          definitions: fetchedDefinitions,
          selectedFontFamily: "Inter",
          selectedLang: selectedLang,
          onDismiss: () {},
        );
      case "find":
        if (argument == null || argument!.isEmpty) {
          predefinedResponses["en-US"]?["find"] = "Sorry i can't get it";
          print("Sorry i can't get it");
          return;
        }
        Get.back();
        searchController.isSearching.value = true;
        searchController.initializeSearch(sentences);
        searchController.updateSearchTerm(argument!);
        highlightController.updateHighlight(argument!);

        print("search for {$argument}");
        break;
      case "show":
        Get.dialog(
          NotesDialog(book: book, screenWidth: screenWidth),
        );
        print(mynoteController.temporaryNotes);
        case "summarize":
        Get.dialog(
          SummaryDialog(isDarkMode: true,initial: sentences[1],)
        );
        case "translate":
        Get.dialog(
          TranslateDialog(isDarkMode: true,initial: sentences[currentSentenceIndex],),
          barrierDismissible: true,
        );
      default:
        print("Unknown or unsupported command");
        Get.back();
    }
  }
}

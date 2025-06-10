import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/highlightedController.dart';
import 'package:listenary/controller/notesController.dart';
import 'package:listenary/controller/searchController.dart' as my_search;
import 'package:listenary/model/book_model.dart';
import 'package:listenary/model/noteModel.dart';
import 'package:listenary/view/components/definition_overlay.dart';
import 'package:listenary/view/components/executions.dart';

class TextDisplay extends StatefulWidget {
  bool isDarkMode;
  final int currentSentenceIndex;
  final List<String> sentences;
  String selectedFontFamily = 'Inter';
  FontWeight selectedFontWeight = FontWeight.w700;
  TextDecoration selectedFontDecoration = TextDecoration.none;
  FontStyle selectedFontStyle = FontStyle.normal;
  final double screenWidth;
  final double screenHeight;
  final ScrollController scrollController;
  final double scaleFactor;
  final String? highlightedWord;
  final Book? book;
  TextDisplay({
    super.key,
    this.book,
    required this.isDarkMode,
    required this.scaleFactor,
    required this.scrollController,
    required this.screenHeight,
    required this.screenWidth,
    required this.currentSentenceIndex,
    required this.sentences,
    required this.selectedFontDecoration,
    required this.selectedFontFamily,
    required this.selectedFontStyle,
    required this.selectedFontWeight,
    this.highlightedWord,
  });

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  //String selectedLang = "en";

  String cleanedWord = "";

  List<String> definitions = [];

  bool isLoading = false;
  final Map<int, Note> notesMap = {}; // <sentenceIndex, Note> //temporary

  final DefinitionOverlayController overlayController =
      DefinitionOverlayController();

  final highlightController = Get.find<HighlightController>();
  final mynoteController = Get.find<NoteController>();
  final searchController = Get.find<my_search.MySearchController>();
  Color selectedColor = Colors.blue; // اللون اللي يختاره المستخدم
  @override
  late final StreamSubscription _notesSubscription;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    searchController.initializeSearch(widget.sentences);
    searchController.attachToScrollController(widget.scrollController);

    // استماع لتغييرات temporaryNotes
    _notesSubscription = mynoteController.temporaryNotes.listen((_) {
      setState(() => _loadNotes());
    });

    // إذا كان هناك كتاب، نستمع لتغييراته أيضًا
    if (widget.book != null) {
      ever(widget.book!.notes, (_) {
        setState(() => _loadNotes());
      });
    }
  } //book
  //uploaded

  @override
  void dispose() {
    _notesSubscription.cancel(); // تنظيف الـ listener
    super.dispose();
  }

  void _loadNotes() {
    notesMap.clear();

    // Load notes from the book
    if (widget.book != null) {
      for (var note in widget.book!.notes) {
        notesMap[note.sentenceIndex] = note;
      }
    }

    // Load temporary notes
    for (var note in mynoteController.temporaryNotes) {
      notesMap[note.sentenceIndex] = note;
    }
  }

  void _saveNote(Note note) {
    setState(() {
      if (widget.book != null) {
        widget.book!.notes
            .removeWhere((n) => n.sentenceIndex == note.sentenceIndex);
        widget.book!.notes.add(note); // سيعمل لأن notes أصبحت RxList
      } else {
        mynoteController.saveNote(note);
      }
      notesMap[note.sentenceIndex] = note; //temporary
    });
  }

  // These methods should be inside your widget class

// Helper method to check if a word position contains a search match
  bool _isInMatchRange(int sentenceIndex, int wordStartPos, int wordEndPos) {
    if (!searchController.isSearching.value ||
        searchController.searchTerm.value.isEmpty) {
      return false;
    }
    String currentWord = searchController.sentences[sentenceIndex]
        .substring(
            wordStartPos.clamp(
                0, searchController.sentences[sentenceIndex].length),
            wordEndPos.clamp(
                0, searchController.sentences[sentenceIndex].length))
        .toLowerCase();

    String searchTermLower = searchController.searchTerm.value.toLowerCase();

    // Check if this word or part of it matches the search term
    return currentWord.contains(searchTermLower) ||
        searchTermLower.contains(currentWord);
  }

// Helper method to check if a position is in the current match
  bool _isInCurrentMatch(int sentenceIndex, int wordStartPos, int wordEndPos) {
    if (searchController.matchIndexes.isEmpty) return false;

    final currentMatch =
        searchController.matchIndexes[searchController.currentMatchIndex.value];
    if (currentMatch.sentenceIndex != sentenceIndex) return false;

    // Check if there's any overlap between the word and current match
    return (wordStartPos <= currentMatch.endPos &&
        wordEndPos >= currentMatch.startPos);
  }

  Color _getWordColor(String word, int sentenceIndex, int wordPosition) {
    // Track the position of this word
    int wordStartPos = wordPosition;
    int wordEndPos = wordPosition + word.length;

    if (searchController.isSearching.value &&
        _isInMatchRange(sentenceIndex, wordStartPos, wordEndPos) &&
        sentenceIndex == widget.currentSentenceIndex) {
      return Colors.blue;
    }

    if (word.toLowerCase() == widget.highlightedWord?.toLowerCase()) {
      return Colors.blue;
    } else if (sentenceIndex == widget.currentSentenceIndex) {
      return const Color(0xffFEC838);
    } else if (searchController.isSearching.value &&
        _isInMatchRange(sentenceIndex, wordStartPos, wordEndPos)) {
      return Colors.blue;
    }

    return Colors.grey.shade600;
  }

  Color? _getWordBackground(String word, int sentenceIndex, int wordPosition) {
    // Track the position of this word
    int wordStartPos = wordPosition;
    int wordEndPos = wordPosition + word.length;

    if (searchController.isSearching.value &&
        _isInCurrentMatch(sentenceIndex, wordStartPos, wordEndPos)) {
      return Colors.blue[200];
    }

    return null;
  }

  Future<void> _showNoteDialog({
    required BuildContext context,
    required int sentenceIndex,
    required Function(String noteText, Color pinColor) onSave,
    String? initialValue,
  }) async {
    TextEditingController noteController = TextEditingController(
      text: initialValue?.isNotEmpty == true ? initialValue : '',
    );
// Get the existing note's color if it exists
    Color initialColor = notesMap[sentenceIndex]?.color ?? Colors.blue;
    await showDialog(
      context: context,
      builder: (context) {
        Color localSelectedColor = selectedColor;

        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.grey[700],
                    size: widget.screenWidth * 0.05,
                  ),
                  onPressed: () {
                    setState(() {
                      if (widget.book != null) {
                        widget.book?.notes.removeWhere(
                            (note) => note.sentenceIndex == sentenceIndex);
                      } else {
                        mynoteController.deleteNote(sentenceIndex);
                      }
                      notesMap.remove(sentenceIndex);
                    });
                    Get.back();
                  },
                ),
              ],
            ),
            backgroundColor: Colors.white,
            title: Text(
              "Add a Note",
              style: TextStyle(fontSize: widget.screenWidth * 0.04),
            ),
            actionsPadding:
                EdgeInsets.symmetric(vertical: widget.screenHeight * 0.015),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Color(0xff212E54)),
                    hintText: notesMap.containsKey(sentenceIndex)
                        ? null
                        : "Write your note here",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.grey, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.grey, width: 2)),
                  ),
                ),
                SizedBox(height: widget.screenHeight * 0.03),
                Row(
                  children: [
                    Text(
                      "Note color: ",
                      style: TextStyle(
                          fontSize: widget.screenWidth * 0.025,
                          fontWeight: FontWeight.bold),
                    ),
                    ...[
                      Colors.blue,
                      Colors.red,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.amber,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            localSelectedColor = color;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: widget.screenWidth * 0.052,
                          height: widget.screenWidth * 0.052,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: localSelectedColor == color
                                  ? Colors.grey
                                  : Colors.transparent,
                              width: 3.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                          horizontal: widget.screenWidth * 0.03,
                          vertical: widget.screenHeight * 0.012)),
                      backgroundColor: const WidgetStatePropertyAll(
                        Colors.grey,
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: widget.screenWidth * 0.025),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                          horizontal: widget.screenWidth * 0.035,
                          vertical: widget.screenHeight * 0.012)),
                    ),
                    onPressed: () {
                      if (noteController.text.trim().isNotEmpty) {
                        onSave(noteController.text.trim(), localSelectedColor);
                      }
                      Get.back();
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: widget.screenWidth * 0.025),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (searchController.isSearching.value) {
          searchController.close();
          return;
        }
        Get.back();
      },
      child: Obx(() {
        return CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            if (searchController.isSearching.value)
              SliverAppBar(
                leadingWidth: widget.screenWidth * 0.5,
                titleSpacing: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: Container(
                    color:
                        widget.isDarkMode ? Color(0xFF212E54) : Colors.white),
                forceElevated: true,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: Row(
                  children: [
                    IconButton(
                      iconSize: widget.screenWidth * 0.038,
                      color:
                          widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                      icon: Icon(Icons.arrow_back),
                      onPressed: searchController.previousMatch,
                    ),
                    Obx(
                      () => Text(
                        '${searchController.currentMatchIndex.value + 1} of ${searchController.matchIndexes.length}',
                        style: TextStyle(
                            fontSize: widget.screenWidth * 0.038,
                            color: widget.isDarkMode
                                ? Colors.white
                                : Color(0xFF212E54)),
                      ),
                    ),
                    IconButton(
                      iconSize: widget.screenWidth * 0.038,
                      icon: Icon(Icons.arrow_forward),
                      color:
                          widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                      onPressed: searchController.nextMatch,
                    ),
                  ],
                ),
                title: Container(
                  width: widget.screenWidth * 0.5,
                  color: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController.textController,
                    onChanged: (value) {
                      searchController.updateSearchTerm(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Color(0xFF212E54)),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    iconSize: widget.screenWidth * 0.045,
                    color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                    onPressed: searchController.close,
                  )
                ],
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, sentenceIndex) {
                  String sentence = widget.sentences[sentenceIndex];
                  List<String> words = sentence.split(' ');
                  bool isRTLText = isRTL(sentence);
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.screenWidth * 0.0095,
                        vertical: widget.screenHeight * 0.003),
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection:
                            isRTLText ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          // For RTL, put the pin first
                          if (isRTLText && notesMap.containsKey(sentenceIndex))
                            IconButton(
                              icon: SvgPicture.asset(
                                "assets/Icons/pin.svg",
                                color: notesMap[sentenceIndex]!.color,
                                height: widget.screenWidth * 0.07,
                                width: widget.screenWidth * 0.07,
                              ),
                              onPressed: () => _showNoteDialog(
                                initialValue:
                                    notesMap[sentenceIndex]?.noteContent,
                                context: context,
                                sentenceIndex: sentenceIndex,
                                onSave: (noteText, pinColor) {
                                  final newNote = Note(
                                    booktitle: widget.book?.booktitle ??
                                        'Temporary Note',
                                    noteContent: noteText,
                                    color: pinColor,
                                    sentenceIndex: sentenceIndex,
                                  );
                                  _saveNote(newNote);
                                },
                              ),
                            ),
                          Flexible(
                            child: Obx(
                              () => RichText(
                                // Add textDirection here
                                textDirection: isRTLText
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                text: TextSpan(
                                  children:
                                      _buildTextSpans(sentence, sentenceIndex),
                                ),
                              ),
                            ),
                          ),
                          // For LTR, put the pin after
                          if (!isRTLText && notesMap.containsKey(sentenceIndex))
                            IconButton(
                              icon: SvgPicture.asset(
                                "assets/Icons/pin.svg",
                                color: notesMap[sentenceIndex]!.color,
                                height: widget.screenWidth * 0.07,
                                width: widget.screenWidth * 0.07,
                              ),
                              onPressed: () => _showNoteDialog(
                                initialValue:
                                    notesMap[sentenceIndex]?.noteContent,
                                context: context,
                                sentenceIndex: sentenceIndex,
                                onSave: (noteText, pinColor) {
                                  final newNote = Note(
                                    booktitle: widget.book?.booktitle ??
                                        'Temporary Note',
                                    noteContent: noteText,
                                    color: pinColor,
                                    sentenceIndex: sentenceIndex,
                                  );
                                  _saveNote(newNote);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: widget.sentences.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: widget.screenHeight * 0.5),
            ),
          ],
        );
      }),
    );
  }

  List<InlineSpan> _buildTextSpans(String sentence, int sentenceIndex) {
    List<InlineSpan> spans = [];
    List<String> words = sentence.split(' ');

    // Keep track of character position within the sentence
    int currentPosition = 0;

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      // Store the start position of this word
      int wordPosition = currentPosition;

      // Add the word with appropriate styling
      spans.add(
        TextSpan(
          text: "$word",
          style: TextStyle(
              fontSize: widget.screenWidth * 0.05 * widget.scaleFactor,
              fontFamily: widget.selectedFontFamily,
              fontStyle: widget.selectedFontStyle,
              fontWeight: widget.selectedFontWeight,
              decoration: widget.selectedFontDecoration,
              backgroundColor:
                  _getWordBackground(word, sentenceIndex, wordPosition),
              color: _getWordColor(word, sentenceIndex, wordPosition)),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) async {
              // Your existing tap handler code here
              final tapPosition = details.globalPosition;
              final selectedOption = await showMenu<String>(
                // Your existing showMenu code
                context: context,
                position: RelativeRect.fromLTRB(
                  tapPosition.dx,
                  tapPosition.dy,
                  tapPosition.dx,
                  tapPosition.dy,
                ),
                items: [
                  PopupMenuItem(
                    value: 'define',
                    child: Text(
                      'Define "${word.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), '')}"',
                      style: TextStyle(
                          fontSize: widget.screenWidth * 0.038,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'note',
                    child: Text(
                      'Leave a note',
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.038,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );

              // Your existing option handling code
              if (selectedOption == 'define') {
                // Definition handling code
                if (overlayController.isShowing) return;
                overlayController.show(
                  context: context,
                  isLoading: true,
                  position: tapPosition,
                  screenHeight: widget.screenHeight,
                  screenWidth: widget.screenWidth,
                  cleanedWord:
                      word.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), ''),
                  definitions: [],
                  selectedFontFamily: widget.selectedFontFamily,
                  wordLang: isArabic(word),
                  onDismiss: () {
                    isLoading = false;
                  },
                );
                definitions =
                    await fetchDefinition(word, wordLang: isArabic(word));
                overlayController.dismiss();
                overlayController.show(
                  context: context,
                  isLoading: false,
                  position: tapPosition,
                  screenHeight: widget.screenHeight,
                  screenWidth: widget.screenWidth,
                  cleanedWord:
                      word.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), ''),
                  definitions: definitions,
                  selectedFontFamily: widget.selectedFontFamily,
                  wordLang: isArabic(word),
                  onDismiss: () {},
                );
              } else if (selectedOption == 'note') {
                // Note handling code
                _showNoteDialog(
                  initialValue: notesMap[sentenceIndex]?.noteContent,
                  context: context,
                  sentenceIndex: sentenceIndex,
                  onSave: (noteText, pinColor) {
                    final newNote = Note(
                      booktitle: widget.book?.booktitle ?? 'Temporary Note',
                      noteContent: noteText,
                      color: pinColor,
                      sentenceIndex: sentenceIndex,
                    );
                    _saveNote(newNote);
                  },
                );
              }
            },
        ),
      );

      // Update position for the next word
      currentPosition += word.length;

      // Add a space after each word (except the last one)
      if (i < words.length - 1) {
        spans.add(TextSpan(
          text: " ",
          style: TextStyle(
            fontSize: widget.screenWidth * 0.05 * widget.scaleFactor,
            fontFamily: widget.selectedFontFamily,
            fontStyle: widget.selectedFontStyle,
            fontWeight: widget.selectedFontWeight,
            decoration: widget.selectedFontDecoration,
          ),
        ));
        currentPosition += 1; // Account for the space
      }
    }

    return spans;
  }
}

bool isRTL(String text) {
  // Check if text contains Arabic characters
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}

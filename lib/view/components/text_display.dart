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
  String selectedLang = "ar";

  String cleanedWord = "";

  List<String> definitions = [];

  bool isLoading = false;
  final Map<int, Note> notesMap = {}; // <sentenceIndex, Note>

  final DefinitionOverlayController overlayController =
      DefinitionOverlayController();

  final highlightController = Get.find<HighlightController>();
  final mynoteController = Get.find<NoteController>();
  final searchController = Get.find<my_search.MySearchController>();
  Color selectedColor = Colors.blue; // اللون اللي يختاره المستخدم
  @override
  @override
late final StreamSubscription _notesSubscription;

@override
void initState() {
  super.initState();
  _loadNotes();

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
}

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
      widget.book!.notes.removeWhere((n) => n.sentenceIndex == note.sentenceIndex);
      widget.book!.notes.add(note); // سيعمل لأن notes أصبحت RxList
    } else {
      mynoteController.saveNote(note);
    }
    notesMap[note.sentenceIndex] = note;
  });
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
                    size: widget.screenWidth * 0.04,
                  ),
                  onPressed: () {
  setState(() {
    if (widget.book != null) {
      widget.book?.notes.removeWhere(
        (note) => note.sentenceIndex == sentenceIndex
      );
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
            title: Text("Add a Note"),
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
                      style: TextStyle(fontSize: widget.screenWidth * 0.02),
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
                          width: 40,
                          height: 40,
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
                leadingWidth: widget.screenWidth * 0.25,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: Container(color: Colors.white),
                forceElevated: true,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: Row(
                  children: [
                    IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.arrow_back),
                      onPressed: searchController.previousMatch,
                    ),
                    Obx(
                      () => Text(
                        '${searchController.currentMatchIndex.value + 1} of ${searchController.matchIndexes.length}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.arrow_forward),
                      onPressed: searchController.nextMatch,
                    ),
                  ],
                ),
                title: Container(
                  width: widget.screenWidth * 0.5,
                  color: Colors.white,
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController.textController,
                    onChanged: (value) =>
                        searchController.updateSearchTerm(value),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: searchController.close,
                  )
                ],
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, sentenceIndex) {
                  String sentence = widget.sentences[sentenceIndex];
                  List<String> words = sentence.split(' ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: words.map((word) {
                                  return TextSpan(
                                    text: "$word ",
                                    style: TextStyle(
                                      fontSize: 16 * widget.scaleFactor,
                                      fontFamily: widget.selectedFontFamily,
                                      fontStyle: widget.selectedFontStyle,
                                      fontWeight: widget.selectedFontWeight,
                                      decoration: widget.selectedFontDecoration,
                                      color: word.toLowerCase() ==
                                              widget.highlightedWord
                                                  ?.toLowerCase()
                                          ? Colors.blue
                                          : sentenceIndex ==
                                                  widget.currentSentenceIndex
                                              ? const Color(0xffFEC838)
                                              : Colors.grey,
                                      backgroundColor: word.toLowerCase() ==
                                                  widget.highlightedWord
                                                      ?.toLowerCase() &&
                                              highlightController
                                                  .highlightFromSearchOnly.value
                                          ? Colors.blue.withOpacity(0.2)
                                          : null,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTapDown = (details) async {
                                        final tapPosition =
                                            details.globalPosition;
                                        final selectedOption =
                                            await showMenu<String>(
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
                                                'Define "$word"',
                                                style: TextStyle(
                                                    fontSize:
                                                        widget.screenWidth *
                                                            0.02,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'note',
                                              child: Text(
                                                'Leave a note',
                                                style: TextStyle(
                                                  fontSize:
                                                      widget.screenWidth * 0.02,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        );

                                        if (selectedOption == 'define') {
                                          if (overlayController.isShowing)
                                            return;
                                          overlayController.show(
                                            context: context,
                                            isLoading: true,
                                            position: tapPosition,
                                            screenHeight: widget.screenHeight,
                                            screenWidth: widget.screenWidth,
                                            cleanedWord: word,
                                            definitions: [],
                                            selectedFontFamily:
                                                widget.selectedFontFamily,
                                            selectedLang: selectedLang,
                                            onDismiss: () {
                                              isLoading = false;
                                            },
                                          );
                                          definitions = await fetchDefinition(
                                              word,
                                              selectedLang: selectedLang);
                                          overlayController.dismiss();
                                          overlayController.show(
                                            context: context,
                                            isLoading: false,
                                            position: tapPosition,
                                            screenHeight: widget.screenHeight,
                                            screenWidth: widget.screenWidth,
                                            cleanedWord: word,
                                            definitions: definitions,
                                            selectedFontFamily:
                                                widget.selectedFontFamily,
                                            selectedLang: selectedLang,
                                            onDismiss: () {},
                                          );
                                        } else if (selectedOption == 'note') {
                                          _showNoteDialog(
                                            initialValue:
                                                notesMap[sentenceIndex]
                                                    ?.noteContent,
                                            context: context,
                                            sentenceIndex: sentenceIndex,
                                            onSave: (noteText, pinColor) {
                                              final newNote = Note(
                                                booktitle:
                                                    widget.book?.booktitle ??
                                                        'Temporary Note',
                                                noteContent: noteText,
                                                color: pinColor,
                                                sentenceIndex: sentenceIndex,
                                              );
                                              _saveNote(newNote);
                                            },
                                          );
                                        }
                                      },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          if (notesMap.containsKey(sentenceIndex))
                            IconButton(
                              icon: SvgPicture.asset(
                                "assets/Icons/pin.svg",
                                color: notesMap[sentenceIndex]!.color,
                                height: 30,
                                width: 30,
                              ),
                              onPressed: () {
                                _showNoteDialog(
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
                                );
                              },
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/highlightedController.dart';
import 'package:listenary/controller/searchController.dart' as my_search;
import 'package:listenary/model/book_model.dart';
import 'package:listenary/services/tts/tts_service.dart';
import 'package:listenary/view/components/SummaryDialog.dart';
import 'package:listenary/view/components/TranslateDialog.dart';
import 'package:listenary/view/components/comamnds.dart';
import 'package:listenary/view/components/executions.dart';
import 'package:listenary/view/components/myappbar.dart';
import 'package:listenary/view/components/slider.dart';
import 'package:listenary/view/components/font_menu.dart';
import 'package:listenary/view/components/text_display.dart';
import 'package:listenary/view/components/audio_box.dart';
import 'package:listenary/view/components/ai_assistant.dart';
import 'package:translator/translator.dart';

class ReadingPage extends StatefulWidget {
  final Book? book;
  final String? documnetText;

  ReadingPage({this.book, this.documnetText});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  bool _isDarkMode = false;
  bool isSearching = false;
  String lang = "";
  String summarizedText = '';
  String originalText = '';
  String cleanedText = "";
  bool isSummarized = false;
  final TTSService _ttsService = TTSService();
  List<String> _sentences = [];
  double _sliderValue = 0.0;
  double scaleFactor = 1.0;
  //bool _isFullScreen = false;
  late ScrollController sharedScrollController;
  final searchController = Get.find<my_search.MySearchController>();
  final translator = GoogleTranslator();
  final highlightController = Get.find<HighlightController>();
  bool _isLoading = false;
  bool _isPlaying = false;

  @override
  @override
  void initState() {
    super.initState();
    sharedScrollController = ScrollController();

    // Link TTS and Search to the same controller
    _ttsService.scrollController = sharedScrollController;
    searchController.attachToScrollController(sharedScrollController);

    // Initialize text content
    originalText = widget.book?.bookcontent ??
        widget.documnetText ??
        'No content available';
    _sentences = originalText.split(RegExp(r'(?<=[.!?])\s*'));
    cleanedText = originalText.replaceAll(
        RegExp(r'[^a-zA-Z0-9\u0621-\u064A\s.,:?!]'), ' ');
    lang = detectLanguage(cleanedText); //en or ar
    print(lang);

    // Load voice preference
    _ttsService.loadVoicePreference().then((_) {
      setState(() {
        // Update UI after voice preference is loaded
      });
    });

    // Add loading state listener
    _ttsService.onLoadingStateChanged = (isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    };

    // Initialize the TTS service position listener
    _ttsService.onPositionChanged = (Duration position, int sentenceIndex) {
      setState(() {
        _sliderValue = position.inMilliseconds /
            (_ttsService.totalDuration.inMilliseconds > 0
                ? _ttsService.totalDuration.inMilliseconds
                : 1);
      });
    };

    // Listen for audio completion
    _ttsService.onPlayerComplete = () {
      setState(() {
        _sliderValue = 0.0;
        _isPlaying = false;
      });
    };
  }

// Add a method to restart playback
  Future<void> _restartPlayback() async {
    try {
      await _ttsService.restart();
      setState(() {
        _isPlaying = _ttsService.isPlaying;
      });
    } catch (e) {
      print("Error restarting playback: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error restarting playback. Please try again.")),
      );
    }
  }

  // Handle play/pause with proper reuse of generated audio
  Future<void> _handlePlayPause() async {
    try {
      // If there's text to play
      if (originalText.isNotEmpty) {
        if (_ttsService.lastAudioFilePath.isEmpty ||
            !_ttsService.isPlaying && !_ttsService.isPaused) {
          // First play or need to regenerate
          setState(() {
            _isLoading = true;
          });

          await _ttsService.startTTS(originalText,
              context: context,
              style: selectedFontStyle,
              maxWidth: MediaQuery.of(context).size.width);
        } else {
          // Toggle between play and pause
          await _ttsService.playPauseAudio();
        }

        setState(() {
          _isPlaying = _ttsService.isPlaying;
        });
      }
    } catch (e) {
      print("Error playing audio: $e");
      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });
    }
  }

  void toggleSummary() {
    setState(() {
      if (isSummarized) {
        summarizedText = '';
      } else {
        summarizedText = summarizeText(originalText);
      }
      isSummarized = !isSummarized;
    });
  }

  String summarizeText(String text) {
    if (text.isEmpty) return 'No text available to summarize.';

    List<String> sentences =
        text.split('.').where((s) => s.trim().isNotEmpty).toList();

    Map<String, int> wordFrequency = {};
    List<String> words = text
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((w) => w.isNotEmpty)
        .toList();

    for (String word in words) {
      wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
    }

    Map<String, int> sentenceScores = {};
    for (String sentence in sentences) {
      int score = 0;
      List<String> sentenceWords = sentence.toLowerCase().split(RegExp(r'\W+'));
      for (String word in sentenceWords) {
        score += wordFrequency[word] ?? 0;
      }
      sentenceScores[sentence.trim()] = score;
    }
    var sortedSentences = sentenceScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int numberOfSentences = (sentences.length * 0.3).ceil();
    List<String> importantSentences = sortedSentences
        .take(numberOfSentences)
        .map((entry) => entry.key)
        .toList();

    return importantSentences.join('. ') + '.';
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  void toggleVoice() {
    _ttsService.toggleVoice(context, selectedFontStyle);
  }

  String selectedFontFamily = 'Inter';
  FontWeight selectedFontWeight = FontWeight.w700;
  TextDecoration selectedFontDecoration = TextDecoration.none;
  FontStyle selectedFontStyle = FontStyle.normal;

  void _translateWholePage(String targetLang) async {
    try {
      final translation =
          await translator.translate(originalText, to: targetLang);
      setState(() {
        summarizedText = ''; // نفضي ملخص لو في
        isSummarized = false;
        originalText = translation.text;
        cleanedText = translation.text;
        _sentences = cleanedText.split(RegExp(r'(?<=[.!?])\s*'));
      });
    } catch (e) {
      print("Translation failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Translation failed, try again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isDarkMode ? Color(0xFF212E54) : Colors.white;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: MyAppBar(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        title:
            widget.book == null ? "Unknown Document" : widget.book!.booktitle,
        isDarkMode: _isDarkMode,
        isSearching: searchController.isSearching.value,
        changeMode: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
        formatText: () {
          showFontMenu(context, (value) {
            setState(() {
              if (value == 'Bold') {
                selectedFontWeight = (selectedFontWeight == FontWeight.bold)
                    ? FontWeight.normal
                    : FontWeight.bold;
              } else if (value == 'Underline') {
                selectedFontDecoration =
                    (selectedFontDecoration == TextDecoration.underline)
                        ? TextDecoration.none
                        : TextDecoration.underline;
              } else if (value == 'Italic') {
                selectedFontStyle = (selectedFontStyle == FontStyle.italic)
                    ? FontStyle.normal
                    : FontStyle.italic;
              }
              else if (value == 'Back to normal') {
                selectedFontStyle =  FontStyle.normal;
                selectedFontWeight = FontWeight.w700;
                selectedFontDecoration = TextDecoration.none;
                selectedFontFamily = "Inter";
              } else {
                selectedFontFamily = value ?? selectedFontFamily;
              }
            });
          });
        },
        searchText: () {
          setState(() {
            isSearching = !isSearching;
          });
          if (isSearching) {
            searchController.isSearching.value = true;
            searchController.initializeSearch(_sentences);
            searchController.updateSearchTerm("");
            highlightController.updateHighlight("");
          } else {
            searchController.isSearching.value = false;
          }
        },
        summarize: () {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
            items: [
              PopupMenuItem(
                child: Text('Select Text'.tr),
                    value: 'select_text',
                  ),
                  PopupMenuItem(
                    child: Text(
                      isSummarized
                          ? 'Reset to original content'.tr
                          : 'Summarize the whole page'.tr,
                  style: TextStyle(
                    color: isSummarized ? Colors.blueAccent : Colors.black,
                  ),
                ),
                value: 'summarizeText',
              ),
            ],
          ).then((value) {
            if (value == 'select_text') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SummaryDialog(isDarkMode: _isDarkMode);
                },
              );
            } else if (value == 'summarizeText') {
              setState(() {
                if (isSummarized) {
                  summarizedText = '';
                } else {
                  summarizedText = summarizeText(originalText);
                }
                isSummarized = !isSummarized;
              });
            }
          });
        },
        translateText: () {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
            items: [
              PopupMenuItem(
                child: Text('Select Text'.tr),
                value: 'select_text',
              ),
              PopupMenuItem(
                 child: Text('Translate the whole page'.tr),
                value: 'translateText',
              ),
            ],
          ).then((value) {
            if (value == 'select_text') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TranslateDialog(isDarkMode: _isDarkMode);
                },
              );
            } else if (value == 'translateText') {
              showDialog(
                context: context,
                builder: (context) {
                  String? selectedLangCode;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                       title: Text("Select a language".tr),
                            content: DropdownButton<String>(
                              value: selectedLangCode,
                              hint: Text("Choose language".tr),
                              items: [
                                DropdownMenuItem(value: 'en', child: Text("English".tr)),
                                DropdownMenuItem(value: 'ar', child: Text("Arabic".tr)),
                                DropdownMenuItem(value: 'fr', child: Text("French".tr)),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedLangCode = value!;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (selectedLangCode != null) {
                                Get.back();
                                _translateWholePage(selectedLangCode!);
                              }
                            },
                            child: Text("Translate".tr),
                          )
                        ],
                      );
                    },
                  );
                },
              );
            }
          });
        },
        zoomIn: () {
          setState(() {
            scaleFactor += 0.1; // تكبير النص
          });
        },
        zoomOut: () {
          setState(() {
            scaleFactor -= 0.1; // تصغير النص
          });
        },
      ),
      body: Directionality(
        textDirection: lang == "en" ? TextDirection.ltr : TextDirection.rtl,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) async {
            // Check if the user swipes from right to left
            if (details.delta.dx < -10) {
              await Get.dialog(CommandsHelpDialog());
              await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AiAssistant(
                        bookLang: lang,
                        currentSentenceIndex: _ttsService.currentSentenceIndex,
                        book: widget.book,
                        sentences: _sentences,
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ));
            }
          },
          onScaleUpdate: (details) {
            setState(() {
              scaleFactor =
                  details.scale.clamp(0.5, 3.0); // نحدد مدى التصغير والتكبير
            });
          },
          child: Stack(
            children: [
              Container(
                color: _isDarkMode ? Color(0xFF212E54) : Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextDisplay(
                    isDarkMode: _isDarkMode,
                    book: widget.book,
                    scaleFactor: scaleFactor,
                    scrollController: sharedScrollController,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    currentSentenceIndex: _ttsService.currentSentenceIndex,
                    sentences: isSummarized
                        ? summarizedText.split(RegExp(r'(?<=[.!?])\s*'))
                        : _sentences,
                    selectedFontDecoration: selectedFontDecoration,
                    selectedFontFamily: selectedFontFamily,
                    selectedFontStyle: selectedFontStyle,
                    selectedFontWeight: selectedFontWeight,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: 1,
                  child: PlayerControllers(
                    onRestart: _restartPlayback,
                    isLoading: _isLoading,
                    isDarkMode: _isDarkMode,
                    isPlaying: _ttsService.isPlaying,
                    onPlayPause: _handlePlayPause,
                    onSkipBackward: _ttsService.skipBackward,
                    onSkipForward: _ttsService.skipForward,
                    onChangeSpeed: _ttsService.changeSpeed,
                    onToggleVoice: toggleVoice,
                    imagePath: _ttsService.imagePath,
                    playbackSpeed: _ttsService.playbackSpeed,
                    slider: SliderAndTime(
                      isDarkMode: _isDarkMode,
                      sliderValue: _sliderValue,
                      currentPosition: _ttsService.currentPosition,
                      totalDuration: _ttsService.totalDuration,
                      onSliderChanged: (value) async {
                        int newPosition =
                            (value * _ttsService.totalDuration.inMilliseconds)
                                .toInt();
                        await _ttsService.seekToPosition(newPosition);
                      },
                      screenWidth: screenWidth,
                    ),
                    isSwitchingVoice: _ttsService.isSwitchingVoice,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

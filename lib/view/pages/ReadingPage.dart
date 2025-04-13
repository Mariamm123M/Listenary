import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/services/tts/tts_service.dart';
import 'package:listenary/view/components/SummaryDialog.dart';
import 'package:listenary/view/components/TranslateDialog.dart';
import 'package:listenary/view/components/slider.dart';
import 'package:listenary/view/components/font_menu.dart';
import 'package:listenary/view/components/text_display.dart';
import 'package:listenary/view/components/audio_box.dart';
import 'package:listenary/view/components/ai_assistant.dart';

class ReadingPage extends StatefulWidget {
  final Book? book;
  final String? documnetText;

  ReadingPage({this.book, this.documnetText});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  bool _isDarkMode = false;
  String lang = "";
  String summarizedText = '';
  String originalText = '';
  String cleanedText = "";
  bool isSummarized = false;
  final TTSService _ttsService = TTSService();
  List<String> _sentences = [];
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _ttsService.loadVoicePreference(); // Load voice preference
    // Initialize text content
    originalText = widget.book?.bookcontent ??
        widget.documnetText ??
        'No content available';
    _sentences = originalText.split(RegExp(r'(?<=[.!?])\s*'));
    cleanedText = originalText.replaceAll(
        RegExp(r'[^a-zA-Z0-9\u0621-\u064A\s.,:?!]'), ' ');
    lang = detectLanguage(cleanedText);
    print(lang);
    // Initialize the TTS service listeners
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
      });
    };
  }
  String detectLanguage(String text) {
    // Check for Arabic characters (includes Arabic, Persian, Urdu, etc.)
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    // Check for English letters
    final englishRegex = RegExp(r'[a-zA-Z]');

    bool hasArabic = arabicRegex.hasMatch(text);
    bool hasEnglish = englishRegex.hasMatch(text);

    if (hasArabic && !hasEnglish) {
      return 'ar'; // Arabic text
    } else if (hasEnglish && !hasArabic) {
      return 'en'; // English text
    } else if (hasArabic && hasEnglish) {
      // Count characters to determine dominant language
      int arabicCount = text.split('').where((c) => arabicRegex.hasMatch(c)).length;
      int englishCount = text.split('').where((c) => englishRegex.hasMatch(c)).length;
      return arabicCount > englishCount ? 'ar' : 'en';
    } else {
      return 'en'; // Default to English if no letters detected
    }
  }
  void _handlePlayPause() async {
    if (!_ttsService.isPlaying && _ttsService.totalDuration == Duration.zero) {
      // First time play - initialize TTS with the text
      await _ttsService.startTTS(cleanedText);
    } else {
      // Regular play/pause
      await _ttsService.playPauseAudio();
    }
    setState(() {});
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

  String selectedFontFamily = 'Inter';
  FontWeight selectedFontWeight = FontWeight.w700;
  TextDecoration selectedFontDecoration = TextDecoration.none;
  FontStyle selectedFontStyle = FontStyle.normal;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isDarkMode ? Color(0xFF212E54) : Colors.white;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Color(0xFF212E54) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: _isDarkMode ? Colors.white : Color(0xFF212E54),
            size: 24,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          (widget.book == null || widget.book!.booktitle.isEmpty)
              ? "Unknown Document"
              : widget.book!.booktitle,
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Color(0xFF212E54),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset("assets/Icons/night.svg",
                color: _isDarkMode ? Color(0xff949494) : Color(0xffFEC838),
                width: 28,
                height: 28),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/Icons/summarize.svg',
              width: 30,
              height: 30,
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
                items: [
                  PopupMenuItem(
                    child: Text('Select Text'),
                    value: 'select_text',
                  ),
                  PopupMenuItem(
                    child: Text(
                      isSummarized
                          ? 'Reset to original content'
                          : 'Summarize the whole page',
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
          ),
          IconButton(
            icon: SvgPicture.asset('assets/Icons/Note.svg',
                width: 24, height: 24),
            onPressed: () {
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
                  } else {
                    selectedFontFamily = value ?? selectedFontFamily;
                  }
                });
              });
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/Icons/translate.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
                items: [
                  PopupMenuItem(
                    child: Text('Select Text'),
                    value: 'select_text',
                  ),
                  PopupMenuItem(
                    child: Text('Translate the whole page'),
                    value: 'translate_page',
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
                } else if (value == 'translate_page') {
                  /*Get.to(()=>TranslatedPage(
                                                bookContent: widget.book.bookcontent,
                                                isDarkMode: false,
                                            ),);*/
                }
              });
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: lang == "en" ?TextDirection.ltr : TextDirection.rtl,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) async {
            // Check if the user swipes from right to left
            if (details.delta.dx < -10) {
              await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AiAssistant(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ));
            }
          },
          child: Stack(
            children: [
              Container(
                color: _isDarkMode ? Color(0xFF212E54) : Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextDisplay(
                    scrollController: _ttsService.scrollController,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    currentSentenceIndex: _ttsService.currentSentenceIndex,
                    sentences: _sentences,
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
                    isDarkMode: _isDarkMode,
                    isPlaying: _ttsService.isPlaying,
                    onPlayPause: _handlePlayPause,
                    onSkipBackward: _ttsService.skipBackward,
                    onSkipForward: _ttsService.skipForward,
                    onChangeSpeed: _ttsService.changeSpeed,
                    onToggleVoice: _ttsService.toggleVoice,
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
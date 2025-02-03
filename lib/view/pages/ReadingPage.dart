import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/SummaryDialog.dart';
import 'package:listenary/view/components/TranslateDialog.dart';

import 'package:audioplayers/audioplayers.dart';

class ReadingPage extends StatefulWidget {
  final Book book;

  ReadingPage({required this.book, required String filePath});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  bool _isDarkMode = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  double playbackSpeed = 1.0;
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Timer? _progressTimer;
  String selectedGender = 'Male';
  String summarizedText = '';
  String originalText = '';
  bool isSummarized = false;

  void initState() {
    super.initState();
    originalText = widget.book.bookcontent;

    // Listen to audio player events
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
        _progress = _currentPosition.inSeconds /
            (_totalDuration.inSeconds == 0 ? 1 : _totalDuration.inSeconds);
      });
    });
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

  void updateProgress() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    final duration = await _audioPlayer.getDuration();
    if (currentPosition != null && duration != null) {
      setState(() {
        _progress = currentPosition.inSeconds / duration.inSeconds;
      });
    }
  }

  String summarizeText(String text) {
    if (text.isEmpty) return 'No text available to summarize.';

    List<String> sentences = text.split('.').where((s) => s.trim().isNotEmpty).toList();

    Map<String, int> wordFrequency = {};
    List<String> words = text.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();

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
  void playPauseAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      _progressTimer?.cancel();
    } else {
      await _audioPlayer.play(AssetSource("audio/AmrDiab.mp3"));
      _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        updateProgress();
      });
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void onSliderChanged(double value) async {
    final duration = await _audioPlayer.getDuration();
    if (duration != null) {
      final newPosition = (value * duration.inSeconds).toInt();
      await _audioPlayer.seek(Duration(seconds: newPosition));
      setState(() {
        _progress = value;
      });
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _progressTimer?.cancel();
    super.dispose();
  }

  List<double> speeds = [1.0, 1.25, 1.5, 2.0];
  int currentSpeedIndex = 0; // لتتبع السرعة الحالية

  void changeSpeed() {
    setState(() {
      currentSpeedIndex = (currentSpeedIndex + 1) % speeds.length;
      playbackSpeed = speeds[currentSpeedIndex]; // تعيين السرعة الحالية
      _audioPlayer.setPlaybackRate(playbackSpeed); // تطبيق السرعة على المشغل
    });
  }

  void skipForward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    if (currentPosition != null) {
      final newPosition = currentPosition.inSeconds + 10;
      await _audioPlayer.seek(Duration(seconds: newPosition));
    }
  }

  void skipBackward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    if (currentPosition != null) {
      final newPosition = currentPosition.inSeconds - 10;
      if (newPosition < 0) {
        await _audioPlayer.seek(Duration(seconds: 0));
      } else {
        await _audioPlayer.seek(Duration(seconds: newPosition));
      }
    }
  }

  String selectedFontFamily = 'Inter';
  FontWeight selectedFontWeight = FontWeight.w700;
  TextDecoration selectedFontDecoration = TextDecoration.none;
  FontStyle selectedFontStyle = FontStyle.normal;
  void _showFontMenu(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
      items: [
        PopupMenuItem<String>(
          value: 'Inter',
          child: Text('Inter', style: TextStyle(fontFamily: 'Inter')),
        ),
        PopupMenuItem<String>(
          value: 'Lobster',
          child: Text('Lobster', style: TextStyle(fontFamily: 'Lobster')),
        ),
        PopupMenuItem<String>(
          value: 'Pacifico',
          child: Text('Pacifico', style: TextStyle(fontFamily: 'Pacifico')),
        ),
        PopupMenuItem<String>(
          value: 'PlayfairDisplay',
          child: Text('PlayfairDisplay',
              style: TextStyle(fontFamily: 'PlayfairDisplay')),
        ),
        PopupMenuItem<String>(
          enabled: false,
          child: Divider(),
        ),
        PopupMenuItem<String>(
          value: 'Bold',
          child: Text('Bold', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        PopupMenuItem<String>(
          value: 'Underline',
          child: Text('Underline',
              style: TextStyle(decoration: TextDecoration.underline)),
        ),
        PopupMenuItem<String>(
          value: 'Italic',
          child: Text('Italic', style: TextStyle(fontStyle: FontStyle.italic)),
        ),
      ],
      color: isDarkMode ? Colors.blue : Colors.white,
    ).then((value) {
      if (value != null) {
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
            selectedFontFamily = value;
          }
        });
      }
    });
  }

  String imagePath = 'assets/Images/male.png';
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isDarkMode ? Color(0xFF212E54) : Colors.white;
    double screenWidth = MediaQuery.of(context).size.width;
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
          widget.book.booktitle,
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
            icon: Image.asset(
              'assets/Icons/summarize.png',
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
            icon: Image.asset('assets/Icons/notes.png', width: 24, height: 24),
            onPressed: () {
              _showFontMenu(context);
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/Icons/translate.png',
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
      body: GestureDetector(
          child: Stack(
        children: [
          Container(
            color: _isDarkMode ? Color(0xFF212E54) : Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: SelectableText(
                  summarizedText.isEmpty
                      ? widget.book.bookcontent
                      : summarizedText,
                  style: TextStyle(
                    fontFamily: selectedFontFamily,
                    fontWeight: selectedFontWeight,
                    decoration: selectedFontDecoration,
                    fontStyle: selectedFontStyle,
                    fontSize: 18,
                    color: Colors.grey,
                    height: 22.4 / 16,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 1,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 210,
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.white : Color(0xFF212E54),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.replay_10),
                              onPressed: skipBackward,
                              iconSize: 30,
                              color: _isDarkMode
                                  ? Color(0xFF212E54)
                                  : Colors.white,
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _isDarkMode
                                    ? Color(0xFF212E54)
                                    : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow),
                                onPressed: playPauseAudio,
                                iconSize: 30,
                                color:
                                    _isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.forward_10),
                              onPressed: skipForward,
                              iconSize: 30,
                              color: _isDarkMode
                                  ? Color(0xFF212E54)
                                  : Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 0, right: 20),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll(Colors.white),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(35),
                                        ),
                                      ),
                                    ),
                                    onPressed: changeSpeed,
                                    child: Text(
                                      "Speed: ${playbackSpeed}x",
                                      style:
                                          TextStyle(color: Color(0xFF212E54)),
                                    )))),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 55,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (imagePath == 'assets/Images/male.png') {
                            imagePath = 'assets/Images/female.png';
                          } else {
                            imagePath = 'assets/Images/male.png';
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                          ),
                        ),
                        child: Opacity(
                          opacity: 1,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Slider(
                          value: _progress,
                          onChanged: onSliderChanged,
                          min: 0.0,
                          max: 1.0,
                          activeColor:
                              _isDarkMode ? Colors.blue : Colors.yellow,
                          inactiveColor: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDuration(_currentPosition),
                                style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                    color: _isDarkMode
                                        ? Color(0xFF212E54)
                                        : Colors.white,
                                    fontWeight:
                                        FontWeight.w600), // Time in white color
                              ),
                              Text(
                                formatDuration(_totalDuration),
                                style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                    color: _isDarkMode
                                        ? Color(0xFF212E54)
                                        : Colors.white,
                                    fontWeight:
                                        FontWeight.w600), // Time in white color
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}

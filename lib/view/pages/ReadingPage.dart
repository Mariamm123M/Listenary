import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/SummaryDialog.dart';
import 'package:listenary/view/components/TranslateDialog.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:listenary/view/components/slider.dart';
import 'package:listenary/view/components/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:listenary/view/components/font_menu.dart';
import 'package:listenary/view/components/text_display.dart';
import 'package:listenary/view/components/audio_box.dart';



class ReadingPage extends StatefulWidget {
  final Book book;

  ReadingPage({required this.book, required String filePath});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  bool _isDarkMode = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String summarizedText = '';
  String originalText = '';
  bool isSummarized = false;

bool isPlaying = false;
  bool isPaused = false;
  double playbackSpeed = 1.0;
  double _progress = 0.0;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Timer? _progressTimer;
  int _currentSentenceIndex = 0;
  List<String> _sentences = [];
  double _highlightSpeedFactor = 1; // Speed factor for faster highlighting
  bool isMale = true;
  String imagePath = 'assets/Images/male.jpg';
  bool isSwitchingVoice = false;
  List<double> speeds = [1.0, 1.25, 1.5, 2.0];
  int currentSpeedIndex = 0;
  double _sliderValue = 0.0; // Separate variable for slider value


  void initState() {
    super.initState();
    loadVoicePreference();
    // Split the book content into sentences
    _sentences = widget.book.bookcontent.split(RegExp(r'(?<=[.!?])\s*'));

    // Initialize the audio player listeners
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
        _sliderValue = position.inMilliseconds / _totalDuration.inMilliseconds;
        _currentSentenceIndex = _getCurrentSentenceIndex(position);
      });
    });

    // Listen for audio completion
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        isPaused = false;
        _currentPosition = Duration.zero;
        _sliderValue = 0.0;
        _currentSentenceIndex = 0;
      });

      // Reset the audio player to the beginning
      _audioPlayer.seek(Duration.zero);
    });
  }
   Future<void> loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMale = prefs.getBool('isMaleVoice') ?? true; // Default to male
      imagePath = isMale
          ? 'assets/Images/male.jpg'
          : 'assets/Images/female.jpeg'; // Update image path
    });
  }

  void toggleVoice() async {
    print('Toggling voice...');
    //print('Current Position: $_currentPosition');
    //print('Total Duration: $_totalDuration');

    // Stop and release the current audio player
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
    }
    await _audioPlayer.release(); // Release resources
    setState(() {
      isSwitchingVoice = true; // Toggle the voice
    });
    // Toggle the voice and update the image
    setState(() {
      isMale = !isMale;
      imagePath = isMale
          ? 'assets/Images/male.jpg'
          : 'assets/Images/female.jpeg'; // Update image path
    });

    await saveVoicePreference(isMale); // Save the new preference

    // Get the remaining text from where the last speaker stopped
    String remainingText = cleanText(_getRemainingTextFromCurrentPosition());
    print('Remaining Text: $remainingText');

    // Restart TTS with the remaining text, starting from the current position
    await startTTS(remainingText, fromPosition: _currentPosition);
    setState(() {
      isSwitchingVoice = false; // Hide loading indicator
    });
  }

  String _getRemainingTextFromCurrentPosition() {
    // Ensure _currentSentenceIndex is within bounds
    if (_currentSentenceIndex < 0 ||
        _currentSentenceIndex >= _sentences.length) {
      // If the index is out of bounds, return the entire text
      print('Current Sentence Index is out of bounds. Returning entire text.');
      return _sentences.join(' ');
    } else {
      // Return the remaining text from the current position
      String remainingText =
          _sentences.sublist(_currentSentenceIndex).join(' ');
      //print('Current Sentence Index: $_currentSentenceIndex');
      //print('Remaining Text: $remainingText');
      return remainingText;
    }
  }

  Future<void> saveVoicePreference(bool isMale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMaleVoice', isMale); // Save the voice preference
    print('Voice preference saved: ${isMale ? "Male" : "Female"}');
  }

  Future<void> startTTS(String text,
      {Duration fromPosition = Duration.zero}) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await loadVoicePreference();
        // Clear previous sentences
        _sentences.clear();

        // Split the text into sentences for display
        _sentences = widget.book.bookcontent.split(RegExp(r'(?<=[.!?])\s*'));

        // Generate a unique filename based on the text
        var textHash =
            text.hashCode; // You can use a more robust hash function if needed
        var tempDir = await getTemporaryDirectory();
        File file = File('${tempDir.path}/speech_$textHash.mp3');

        // Always regenerate the audio file for the new text
        var response = await http
            .post(
              Uri.parse('http://192.168.1.7:5002/tts'),
              headers: {'Content-Type': 'application/json'},
              body:
                  '{"text": "$text", "gender": "${isMale ? "male" : "female"}"}',
            )
            .timeout(Duration(seconds: 60));

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);

          // Load the audio file
          await _audioPlayer.setSource(UrlSource(file.path));

          // Wait for the audio file to be ready
          final duration = await _audioPlayer.getDuration();
          if (duration != null) {
            setState(() {
              _totalDuration = duration;
            });

            // Ensure fromPosition does not exceed the total duration
            if (fromPosition > _totalDuration) {
              fromPosition = _totalDuration;
            }

            // Seek to the position where the last speaker stopped
            await _audioPlayer
                .seek(fromPosition)
                .timeout(Duration(seconds: 10)); // Increase timeout

            // Play the audio file
            await _audioPlayer.play(UrlSource(file.path));

            // Listen for position changes to update the highlighted sentence
            _audioPlayer.onPositionChanged.listen((Duration position) {
              setState(() {
                _currentPosition = position;
                _sliderValue =
                    position.inMilliseconds / _totalDuration.inMilliseconds;
                _currentSentenceIndex = _getCurrentSentenceIndex(position);
                print('Current Position: $_currentPosition');
                print('Current Sentence Index: $_currentSentenceIndex');
              });
            });

            setState(() {
              isPlaying = true;
            });
          }
        } else {
          print(
              'Failed to generate speech. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          return; // Exit early if the request failed
        }
        break; // Exit the loop if successful
      } on TimeoutException {
        print("Timeout: Audio playback took too long.");
        retryCount++;
        if (retryCount >= maxRetries) {
          print("Max retries reached. Giving up.");
          break;
        }
      } catch (e) {
        print('Error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          print("Max retries reached. Giving up.");
          break;
        }
      }
    }
  }

  int _getCurrentSentenceIndex(Duration position) {
    if (_sentences.isEmpty || _totalDuration == Duration.zero) return 0;

    double progress =
        (position.inMilliseconds / _totalDuration.inMilliseconds) *
            _highlightSpeedFactor;
    int sentenceIndex = (progress * _sentences.length).floor();

    // Clamp sentence index to prevent going out of bounds
    return sentenceIndex.clamp(0, _sentences.length - 1);
  }

  void playPauseAudio() async {
    try {
      if (isPlaying) {
        // Pause the audio if it's currently playing
        await _audioPlayer
            .pause()
            .timeout(Duration(seconds: 8)); // Add timeout for safety
        setState(() {
          isPlaying = false;
          isPaused = true;
        });
        _progressTimer?.cancel(); // Stop updating progress
      } else {
        if (isPaused) {
          // Resume from where it was paused
          await _audioPlayer
              .resume()
              .timeout(Duration(seconds: 8)); // Add timeout
        } else {
          if (_currentPosition == Duration.zero ||
              _currentPosition >= _totalDuration) {
            // If the current position is at the start or has finished, restart the book
            _currentPosition = Duration.zero;

            // Clean the content to avoid encoding issues
            String cleanedContent = cleanText(widget.book.bookcontent);

            // Ensure the audio player stops completely before starting a new session
            await _audioPlayer.stop();
            await startTTS(
                cleanedContent); // Start TTS after stopping previous playback
          } else {
            // If not paused but position is valid, start TTS and play
            String cleanedContent = cleanText(widget.book.bookcontent);
            await startTTS(cleanedContent, fromPosition: _currentPosition);
          }
        }
        // Update the state to reflect that audio is playing
        setState(() {
          isPlaying = true;
          isPaused = false;
        });
        // Start updating progress only when playing
        startUpdatingProgress();
      }
    } on TimeoutException {
      print("Timeout: Audio operation took too long.");
      setState(() {
        isPlaying = false;
        isPaused = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isPlaying = false;
        isPaused = false;
      });
    }
  }
  void startUpdatingProgress() {
    _progressTimer?.cancel(); // Cancel any existing timer
    _progressTimer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      Duration? currentPosition = await _audioPlayer.getCurrentPosition();
      if (currentPosition != null) {
        setState(() {
          _currentPosition = currentPosition;
        });
      }
    });
  }

  void updateProgress() async {
    // Get current position of audio
    Duration? position = await _audioPlayer.getCurrentPosition();
    if (position != null && isPlaying) {
      setState(() {
        _currentPosition = position;
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
  @override
  void dispose() {
    _audioPlayer.stop();
    _progressTimer?.cancel();
    super.dispose();
  }
Future<void> seekToPosition(int position) async {
    try {
      await _audioPlayer.seek(Duration(milliseconds: position));
    } on TimeoutException {
      print("Seek operation timed out. Retrying...");
      await Future.delayed(Duration(seconds: 1));
      await _audioPlayer.seek(Duration(milliseconds: position));
    } catch (e) {
      print("Error during seek: $e");
    }
  }

  void onSliderChanged(double value) async {
    setState(() {
      _sliderValue = value;
    });

    if (_totalDuration == Duration.zero) {
      print("Audio not ready yet.");
      return;
    }

    try {
      int newPosition = (value * _totalDuration.inMilliseconds).toInt();
      await seekToPosition(newPosition); // Use the retry mechanism here

      setState(() {
        _currentPosition = Duration(milliseconds: newPosition);
        _currentSentenceIndex =
            _getCurrentSentenceIndex(Duration(milliseconds: newPosition));
      });
    } catch (e) {
      print("Error during seek: $e");
    }
  }

  void changeSpeed() {
    setState(() {
      // Update the playback speed and the speed index
      currentSpeedIndex = (currentSpeedIndex + 1) % speeds.length;
      playbackSpeed = speeds[currentSpeedIndex];
      _audioPlayer.setPlaybackRate(playbackSpeed);

      // Adjust the highlight speed factor based on the playback speed
      _highlightSpeedFactor = playbackSpeed -
          0.2; // Set highlight speed proportional to playback speed
    });
  }

  void skipForward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    final duration = await _audioPlayer.getDuration();
    if (currentPosition != null && duration != null) {
      // Calculate the new position (skip forward by 10 seconds)
      int newPosition =
          (currentPosition + Duration(seconds: 10)).inMilliseconds;
      newPosition = newPosition.clamp(0, duration.inMilliseconds);

      // Seek to the new position
      await _audioPlayer.seek(Duration(milliseconds: newPosition));
      setState(() {
        _currentPosition = Duration(milliseconds: newPosition);
        _sliderValue = newPosition / duration.inMilliseconds;
        _currentSentenceIndex =
            _getCurrentSentenceIndex(Duration(milliseconds: newPosition));
      });
    }
  }
  void skipBackward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    if (currentPosition != null) {
      // Calculate the new position (skip backward by 10 seconds)
      int newPosition =
          (currentPosition - Duration(seconds: 10)).inMilliseconds;
      newPosition = newPosition.clamp(0, _totalDuration.inMilliseconds);

      // Seek to the new position
      await _audioPlayer.seek(Duration(milliseconds: newPosition));
      setState(() {
        _currentPosition = Duration(milliseconds: newPosition);
        _sliderValue = newPosition / _totalDuration.inMilliseconds;
        _currentSentenceIndex =
            _getCurrentSentenceIndex(Duration(milliseconds: newPosition));
      });
    }
  }


  String selectedFontFamily = 'Inter';
  FontWeight selectedFontWeight = FontWeight.w700;
  TextDecoration selectedFontDecoration = TextDecoration.none;
  FontStyle selectedFontStyle = FontStyle.normal;
  
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
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: TextDisplay(
              currentSentenceIndex: _currentSentenceIndex,
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
                    isPlaying: isPlaying,
                    onPlayPause: playPauseAudio,
                    onSkipBackward: skipBackward,
                    onSkipForward: skipForward,
                    onChangeSpeed: changeSpeed,
                    onToggleVoice: toggleVoice,
                    imagePath: imagePath,
                    playbackSpeed: playbackSpeed,
                    slider: SliderAndTime(
                      isDarkMode: _isDarkMode,
                      sliderValue: _sliderValue,
                      currentPosition: _currentPosition,
                      totalDuration: _totalDuration,
                      onSliderChanged: onSliderChanged,
                      screenWidth: screenWidth,
                    ), isSwitchingVoice: isSwitchingVoice,
                  ),
            ),
          )
        ],
      )),
    );
  }
}

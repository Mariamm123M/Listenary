import 'dart:async';
import 'package:flutter/material.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/services/aiService.dart/aiResponse.dart';
import 'package:listenary/view/components/definition_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:listenary/view/components/animation.dart';
import 'package:listenary/services/tts/flutter_tts.dart';
import 'package:listenary/services/permissions/microphone_permission.dart';

class AiAssistant extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final List<String> sentences;
  final Book? book;
  final int currentSentenceIndex;
  
  const AiAssistant(
      {super.key, required this.screenHeight, required this.screenWidth, required this.sentences,this.book, required this.currentSentenceIndex});

  @override
  _AiAssistantState createState() => _AiAssistantState();
}

class _AiAssistantState extends State<AiAssistant>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  bool isRecording = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _text = '';
  bool _isListening = false;
  String _aiResponse = '';
  String _detectedCommand = '';
  String lang = "en-US";
  String selectedLang = "en";
  List<Color> colors = [
    Color(0xff5356FF),
    Color(0xff3572EF),
    Color(0xff3ABEF9),
    Color(0xffA7E6FF)
  ];
  List<int> duration = [700, 500, 400, 600, 300];
  final FTTSService _fttsService = FTTSService();
  bool _showResponse = false;
  bool _showCommand = false;
  bool isLoading = false;
  Timer? _hideTimer;
  late Offset tapPosition;
  final DefinitionOverlayController overlayController =
      DefinitionOverlayController();

  @override
  void initState() {
    super.initState();
    tapPosition = Offset(widget.screenWidth / 2, widget.screenHeight / 2);

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
    );
    _fttsService.onStartSpeaking = (_) {
      if (mounted) {
        setState(() {
          _showResponse = true; // Show response when TTS starts
        });
      }
    };
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    _fttsService.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> sendToAi() async {
    final result = AiResponse.process(_text, lang); // استخدم AiResponse مباشرة

    if (result.isCommand) {
      _detectedCommand = result.command ?? "No command detected";
      _aiResponse = result.predefinedResponse ?? "No response generated";
      _showResponse = true; // إظهار الرد فورًا بعد جلبه
      await Future.delayed(Duration(seconds: 1));

      print("Command: ${result.command}");
      print("Argument: ${result.argument}");
      print("Predefined Response: ${result.predefinedResponse}");

      // تقريه بالـ TTS
      _fttsService.speak(_aiResponse);
      await Future.delayed(Duration(seconds: 2));
      await result.executeCommand(
        currentSentenceIndex: widget.currentSentenceIndex,
        book: widget.book,
        context: context,
        sentences: widget.sentences,
        tapPosition: tapPosition,
        screenHeight: widget.screenHeight,
        screenWidth: widget.screenWidth,
        selectedLang: selectedLang,
        setLoading: (val) {
          setState(() {
            isLoading = val;
          });
        },
      );
      await Future.delayed(Duration(seconds: 3));

      setState(() {
        isRecording = false;
        _isListening = false;
      });
    } else {
      print("No command detected");

      _aiResponse = "Sorry, I couldn't detect any command in your speech.";
      _showResponse = true;
      _fttsService.speak(_aiResponse);

      await Future.delayed(Duration(seconds: 3));

      setState(() {
        isRecording = false;
        _isListening = false;
      });
    }
  }

  Future<void> listen() async {
    if (await checkMicrophonePermission()) {
      if (!isRecording) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() {
            isRecording = true;
            _isListening = true;
            _text = '';
            _aiResponse = '';
            _detectedCommand = '';
            _showResponse = false;
            _showCommand = false;
          });

          // Auto stop after 5 seconds if no speech detected
          Timer(Duration(seconds: 5), () {
            if (_text.isEmpty && mounted) {
              _speech.stop();
              setState(() {
                isRecording = false;
                _isListening = false;
              });
            }
          });

          _speech.listen(
            onResult: (val) {
              if (val.finalResult) {
                setState(() {
                  _text = val.recognizedWords;
                });

                if (_text.isNotEmpty) {
                  List<String> words = _text.split(' ');
                  if (words.length == 1 && words[0].toLowerCase() == "translate") {
                  setState(() {
                    _text = "translate"; // تأكيد الأمر
                  });
                  sendToAi(); // تنفيذ الأمر مباشرة
                } 
                if (words.length == 1 && words[0].toLowerCase() == "summarize") {
                  setState(() {
                    _text = "summarize"; // تأكيد الأمر
                  });
                  sendToAi(); // تنفيذ الأمر مباشرة
                } 
                  else if (words.length <= 3) {
                    sendToAi(); // ✅ Execute once, only when result is final
                  } else {
                    // Display message when more than 2 words are detected
                    setState(() {
                      _aiResponse =
                          "Please speak only 2 words or fewer, not ${words.length} words.";
                      _fttsService.speak(_aiResponse);
                      _showResponse = true;
                    });
                    Future.delayed(Duration(seconds: 5), () {
                      setState(() {
                        _aiResponse = "";
                        // Clear message after a while
                        isRecording = false;
                        _isListening = false;
                      });
                    });
                  }
                }
              }
            },
            localeId: lang,
          );
        } else {
          setState(() {
            _aiResponse = "Speech recognition not available.";
            isRecording = false;
            _isListening = false;
            _showResponse = true;
          });
        }
      } else {
        // If already recording, stop it
        setState(() {
          isRecording = false;
          _isListening = false;
        });
        _speech.stop();
      }
    } else {
      setState(() {
        isRecording = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.screenHeight * 0.73,
      padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.07,
          vertical: widget.screenHeight * 0.05),
      decoration: BoxDecoration(
        color: Color(0xFF212E54),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "How can I help you?",
            style: TextStyle(
                fontSize: widget.screenWidth * 0.053,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: child,
              );
            },
            child: Lottie.asset(
              'assets/Images/ai.json',
              width: 260,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
          isRecording
              ? Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.screenWidth * 0.025),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isListening = !_isListening;
                                isRecording = !isRecording;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                  10,
                                  (index) => VisualComponent(
                                      width: 10,
                                      duration: duration[index % 5],
                                      color: colors[index % 3])),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: widget.screenHeight * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.screenWidth * 0.04),
                      child: Text(
                        _text.isEmpty ? "Listening..." : _text,
                        style: TextStyle(
                            fontSize: widget.screenWidth * 0.04,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: widget.screenHeight * 0.02),
                    if (_showCommand && _detectedCommand.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.screenWidth * 0.04),
                        child: Text(
                          "Command: $_detectedCommand",
                          style: TextStyle(
                              fontSize: widget.screenWidth * 0.04,
                              color: Colors.greenAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_showResponse && _aiResponse.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.screenWidth * 0.04),
                        child: Text(
                          _aiResponse,
                          style: TextStyle(
                              fontSize: widget.screenWidth * 0.04,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                )
              : Column(
                  children: [
                    ElevatedButton(
                      onPressed: listen,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.screenWidth * 0.03,
                              vertical: widget.screenHeight * 0.009),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Color(0xFF212E54),
                            size: widget.screenWidth * 0.04,
                          ),
                          SizedBox(width: widget.screenWidth * 0.01),
                          Text(
                            "Start Listening",
                            style: TextStyle(
                                color: Color(0xFF212E54),
                                fontSize: widget.screenWidth * 0.04),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: widget.screenHeight * 0.06),
                    Text(
                      "I'm in development, learning new skills every day!",
                      style: TextStyle(
                          color: Colors.black38,
                          fontSize: widget.screenWidth * 0.04),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
          SizedBox(height: widget.screenHeight * 0.02),
        ],
      ),
    );
  }
}

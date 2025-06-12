import 'dart:async';
import 'package:flutter/material.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/services/aiService.dart/aiResponse.dart';
import 'package:listenary/view/components/definition_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:get/get.dart'; // Added for .tr functionality

import 'package:listenary/view/components/animation.dart';
import 'package:listenary/services/tts/flutter_tts.dart';
import 'package:listenary/services/permissions/microphone_permission.dart';

class AiAssistant extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final List<String> sentences;
  final Book? book;
  final int currentSentenceIndex;
  final String bookLang;

  const AiAssistant(
      {super.key,
      required this.bookLang,
      required this.screenHeight,
      required this.screenWidth,
      required this.sentences,
      this.book,
      required this.currentSentenceIndex});

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
          _showResponse = true;
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
    final result =
        AiResponse.process(_text, widget.bookLang == "en"? "en-US" : "ar-AR");
    if (result.isCommand) {
      _detectedCommand = result.command ?? 'no_command_detected'.tr;
      _aiResponse = result.predefinedResponse ?? 'no_response_generated'.tr;
      _showResponse = true;
      await Future.delayed(Duration(seconds: 1));

      print("Command: ${result.command}");
      print("Argument: ${result.argument}");
      print("Predefined Response: ${result.predefinedResponse}");

      await _fttsService.setLanguage(widget.bookLang);
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

      _aiResponse = widget.bookLang == "en"? "Sorry, I couldn't detect any command in your speech.":"لم يتم الكشف عن أي أمر.";
      _showResponse = true;
      await _fttsService.setLanguage(widget.bookLang);
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
                  if (words.length == 1 &&
                      (words[0].toLowerCase() == "translate" ||
                          words[0].toLowerCase() == "ترجم")) {
                    sendToAi();
                  } else if (words.length == 1 &&
                      (words[0].toLowerCase() == "summarize" ||
                          words[0].toLowerCase() == "لخص")) {
                    sendToAi();
                  } else if (words.length == 1 &&
                      (words[0].toLowerCase() == "define" ||
                          words[0].toLowerCase() == "عرف" ||
                          words[0].toLowerCase() == "show" ||
                          words[0].toLowerCase() == "اعرض" ||
                          words[0].toLowerCase() == "find" ||
                          words[0].toLowerCase() == "ابحث")) {
                    _aiResponse = widget.bookLang == "en"
                        ? "Unfinished command, i need more information."
                        : "أمر غير مكتمل، أحتاج معلومات أخرى.";
                    _fttsService.setLanguage(widget.bookLang);
                    _fttsService.speak(_aiResponse);
                    _showResponse = true;
                    Future.delayed(Duration(seconds: 5), () {
                      setState(() {
                        _aiResponse = "";
                        isRecording = false;
                        _isListening = false;
                      });
                    });
                  } else if (words.length <= 3) {
                    sendToAi();
                  } else {
                    setState(() async {
                      _aiResponse = widget.bookLang == "en"
                          ? 'please_speak_fewer_words'.tr
                          : "  كلمات .${words.length} أرجوك تحدث كلمتين أو أقل وليس ";
                      await _fttsService.setLanguage(widget.bookLang);
                      _fttsService.speak(_aiResponse);
                      _showResponse = true;
                    });
                    Future.delayed(Duration(seconds: 5), () {
                      setState(() {
                        _aiResponse = "";
                        isRecording = false;
                        _isListening = false;
                      });
                    });
                  }
                }
              }
            },
            localeId: widget.bookLang == "en" ? "en-US" : "ar-AR",
          );
        } else {
          setState(() {
            _aiResponse = widget.bookLang == "en"
                ? 'speech_recognition_not_available'.tr
                : ".التعرف الصوتي غير متاح حاليا ";
            isRecording = false;
            _isListening = false;
            _showResponse = true;
          });
        }
      } else {
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
            'how_can_i_help'.tr,
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
                        _text.isEmpty ? 'listening'.tr : _text,
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
                          "${'command'.tr}: $_detectedCommand",
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
                            'start_listening'.tr,
                            style: TextStyle(
                                color: Color(0xFF212E54),
                                fontSize: widget.screenWidth * 0.04),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: widget.screenHeight * 0.06),
                    Text(
                      'in_development'.tr,
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
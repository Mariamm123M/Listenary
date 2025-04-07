import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'package:listenary/view/components/animation.dart';
import 'package:listenary/services/tts/flutter_tts.dart';
import 'package:listenary/services/permissions/microphone_permission.dart';

class AiAssistant extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  const AiAssistant(
      {super.key, required this.screenHeight, required this.screenWidth});

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
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
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

  Future<void> sendToAi(String userInput) async {
  final url = Uri.parse('http://192.168.1.6:5000/process_speech');

  try {
    _hideTimer?.cancel();

    setState(() {
      _showResponse = false;
      _showCommand = false;
      _aiResponse = '';
      _detectedCommand = '';
    });

    final response = await http
        .post(
          url,
          body: json.encode({'speech': userInput, "lang": lang}),
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _detectedCommand = data['command'] ?? "No command detected";
        _aiResponse = data['response'] ?? "No response generated";
        _showResponse = true; // إظهار الرد فورًا بعد جلبه
      });

      if (_detectedCommand.isNotEmpty &&
          _detectedCommand != "No command detected") {
        _executeCommand(_detectedCommand);
      }

      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          isRecording = false;
          _isListening = false;
        });
      }

      // تشغيل الصوت وانتظار انتهاءه
      if (_aiResponse.isNotEmpty) {
        try {
          await _fttsService.speak(_aiResponse); // انتظار انتهاء تشغيل الصوت

          // بعد انتهاء الصوت، أغلق المودال بعد 3 ثوانٍ
          if (mounted) {
            _hideTimer = Timer(Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showResponse = false;
                });
                Get.back();
              }
            });
          }
        } catch (e) {
          print("TTS Error: $e");
        }
      }
    }
  } on TimeoutException {
    setState(() {
      _aiResponse = 'Error: Request timed out';
      _showResponse = true;
    });
  } on SocketException {
    setState(() {
      _aiResponse = 'Error: No internet connection';
      _showResponse = true;
    });
  } catch (e) {
    setState(() {
      _aiResponse = 'Error: ${e.toString()}';
      _showResponse = true;
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

          Timer(Duration(seconds: 3), () {
            if (_text.isEmpty && mounted) {
              _speech.stop();
              setState(() {
                isRecording = false;
                _isListening = false;
              });
            }
          });

          _speech.listen(
            onResult: (val) => setState(() {
              _text = val.recognizedWords;
              if (_text.isNotEmpty) {
                if (_text.split(' ').length <= 3) {
                  sendToAi(_text.toLowerCase());
                } else {
                  setState(() {
                    _aiResponse = "Please speak only 3 words or fewer.";
                    isRecording = false;
                    _isListening = false;
                    _showResponse = true;
                  });
                }
              }
            }),
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

  void _executeCommand(String command) async {
    Get.back();
    print("Executing command: $command");
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
                          Icon(Icons.mic, color: Color(0xFF212E54)),
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

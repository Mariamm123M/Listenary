import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class FTTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  Completer<void>? _speechCompleter;
  Function(String)? onStartSpeaking;

  Future<void> initialize() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      if (onStartSpeaking != null) {
        onStartSpeaking!("started"); // Notify when speech starts
      }
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _speechCompleter?.complete();
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      _isSpeaking = false;
      _speechCompleter?.completeError(msg);
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    print("Speaking: $text");
    _speechCompleter = Completer<void>();
    
    try {
      await _flutterTts.speak(text);
      await _speechCompleter!.future;
    } catch (e) {
      print("TTS Error: $e");
      rethrow;
    } finally {
      _speechCompleter = null;
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _speechCompleter?.complete();
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
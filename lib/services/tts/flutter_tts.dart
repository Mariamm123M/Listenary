import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class FTTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  Completer<void>? _speechCompleter;
  Function(String)? onStartSpeaking;
  String lang = "en"; // اللغة الافتراضية


  Future<void> setLanguage(String languageCode) async {
    if (languageCode == "ar") {
      lang = "ar-EG"; // العربية - السعودية
    } else if (languageCode == "en") {
      lang = "en-US"; // الإنجليزية - الأمريكية
    } else {
      lang = languageCode; // يمكنك إضافة لغات أخرى لاحقاً
    }
    
    await _flutterTts.setLanguage(lang);
  }

  Future<void> initialize() async {
    List<dynamic> availableLanguages = await _flutterTts.getLanguages;
    print("TTS Supported Languages: $availableLanguages");

    // حاول تعيين اللغة إن كانت مدعومة
    if (availableLanguages.contains(lang)) {
      await _flutterTts.setLanguage(lang);
    } else {
      // إذا لم تكن اللغة المطلوبة مدعومة، جرب الإنجليزية
      if (lang.startsWith("ar") && availableLanguages.contains("en-US")) {
        lang = "en-US";
        await _flutterTts.setLanguage(lang);
        print("تم استخدام الإنجليزية بدلاً من العربية");
      } else {
        print("اللغة $lang غير مدعومة في هذا الجهاز");
      }
    }

    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      onStartSpeaking?.call("started");
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

    print("Speaking ($lang): $text");
    _speechCompleter = Completer<void>();

    try {
      await _flutterTts.speak(text);
      await _speechCompleter!.future;
    } catch (e) {
      print("TTS Error during speak: $e");
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
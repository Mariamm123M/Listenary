import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSService {
  bool isMale = true;

  Future<void> toggleVoice(Function updateVoice) async {
    await loadVoicePreference();
    isMale = !isMale;
    await saveVoicePreference(isMale);
    updateVoice(isMale);
  }

  Future<void> loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isMale = prefs.getBool('isMaleVoice') ?? true;
  }

  Future<void> saveVoicePreference(bool isMale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMaleVoice', isMale);
  }

  Future<File> generateTTSFile(String text) async {
    var textHash = text.hashCode;
    var tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/speech_$textHash.mp3');

    var response = await http.post(
      Uri.parse('http://10.0.2.2:5000/tts'),
      headers: {'Content-Type': 'application/json'},
      body: '{"text": "$text", "gender": "${isMale ? "male" : "female"}"}',
    );

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to generate TTS audio');
    }
    return file;
  }
}

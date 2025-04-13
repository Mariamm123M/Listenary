import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isMale = true;
  List<String> _sentences = [];
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  double _sliderValue = 0.0;
  int _currentSentenceIndex = 0;
  bool isPlaying = false;
  bool isPaused = false;
  bool _isSeeking = false;
  double highlightSpeedFactor = 0.95;
  Timer? _progressTimer;
  List<double> speeds = [1.0, 1.25, 1.5, 2.0];
  int currentSpeedIndex = 0;
  double playbackSpeed = 1.0;
  String imagePath = 'assets/Images/male.jpg';
  bool isSwitchingVoice = false;
  List<Duration> _sentenceDurations = [];
  List<Duration> _sentenceEndTimes = [];
  ScrollController scrollController = ScrollController();
  static const int highlightOffsetMs = 100; // Adjust as needed
  static const int highlightLeadMs =  500; // Start highlighting slightly before sentence starts
  static const int sentenceEndBufferMs = 50; // Buffer at the end of the sentence
  static const double wordsPerSecond = 3.0; // Average speaking rate
  static const double punctuationPauseSeconds = 0.4; // Pause after punctuation
  static const double sentenceEndPauseSeconds = 0.6; // Longer pause at sentence ends
  static const double _baseWordsPerSecond = 2.2; // Average speaking rate
  static const double _punctuationPause = 0.2; // Seconds added for punctuation
  static const double _sentenceEndPause = 0.3;
  static const int _highlightLeadMs = 800; // Start highlighting slightly before audio
  Function(Duration position, int sentenceIndex)? onPositionChanged;
  Function()? onPlayerComplete;

  int get currentSentenceIndex => _currentSentenceIndex;
  Duration get totalDuration => _totalDuration;
  Duration get currentPosition => _currentPosition;

  TTSService() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _handlePlaybackComplete();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _handlePositionChange(position);
    });
  }

  void _handlePlaybackComplete() {
    isPlaying = false;
    isPaused = false;
    _currentPosition = Duration.zero;
    _sliderValue = 0.0;
    _currentSentenceIndex = 0;
    onPlayerComplete?.call();
  }

  void _handlePositionChange(Duration position) {
    _currentPosition = position;
    _sliderValue = position.inMilliseconds / _totalDuration.inMilliseconds;

    final newIndex = _calculateCurrentSentenceIndex(position);
    if (newIndex != _currentSentenceIndex) {
      _currentSentenceIndex = newIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToCurrentSentence();
      });
    }

    onPositionChanged?.call(position, _currentSentenceIndex);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    playbackSpeed = speed;
    await _audioPlayer.setPlaybackRate(playbackSpeed);
  }

  int _calculateCurrentSentenceIndex(Duration position) {
    if (_sentenceEndTimes.isEmpty) return 0;

    final adjustedPosition = position + Duration(
      milliseconds: (_highlightLeadMs / playbackSpeed).round(),
    );

    int low = 0;
    int high = _sentenceEndTimes.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (adjustedPosition < _sentenceEndTimes[mid]) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    return low.clamp(0, _sentenceEndTimes.length - 1);
  }

  Future<void> startTTS(String text, {Duration fromPosition = Duration.zero}) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        _sentences = text
            .split(RegExp(r'(?<=[.!?])\s+'))
            .where((s) => s.trim().isNotEmpty)
            .toList();
        print('Sentence count: ${_sentences.length}');

        var textHash = text.hashCode;
        var tempDir = await getTemporaryDirectory();
        File file = File('${tempDir.path}/speech_$textHash.mp3');

        var response = await http
            .post(
              Uri.parse('http://192.168.1.4:5002/tts'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "text": text,
                "gender": isMale ? "male" : "female",
              }),
            )
            .timeout(Duration(seconds: 60));

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          await _audioPlayer.setSource(UrlSource(file.path));

          final duration = await _audioPlayer.getDuration();
          if (duration != null) {
            _totalDuration = duration;
            await _estimateDurationsWithRetry();

            final seekPosition =
                fromPosition > _totalDuration ? _totalDuration : fromPosition;
            await _audioPlayer.seek(seekPosition);
            await _audioPlayer.resume();
            isPlaying = true;
            isPaused = false;

            _currentSentenceIndex =
                _calculateCurrentSentenceIndex(seekPosition);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollToCurrentSentence();
            });
          }
        } else {
          print('Failed to generate speech. Status code: ${response.statusCode}');
        }
        break;
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

  Future<void> _estimateDurationsWithRetry() async {
    int retry = 0;
    while (retry < 3) {
      try {
        _estimateDurations();
        break;
      } catch (e) {
        retry++;
        if (retry >= 3) rethrow;
        await Future.delayed(Duration(milliseconds: 100 * retry));
      }
    }
  }

  void _estimateDurations() {
    if (_sentences.isEmpty || _totalDuration == Duration.zero) return;

    final rawDurations = _sentences.map((sentence) {
      final words = sentence.split(' ').length;
      final punctuation = sentence.replaceAll(RegExp(r'[^.!?,]'), '').length;
      final durationSec = (words / _baseWordsPerSecond) + 
                         (punctuation * _punctuationPause) +
                         _sentenceEndPause;
      return durationSec * 1000;
    }).toList();

    final totalRawMs = rawDurations.reduce((a, b) => a + b);

    final scaleFactor = _totalDuration.inMilliseconds / totalRawMs;

    _sentenceDurations = rawDurations.map((ms) => 
      Duration(milliseconds: (ms * scaleFactor).round())
    ).toList();

    _sentenceEndTimes = [];
    Duration runningTotal = Duration.zero;
    for (int i = 0; i < _sentenceDurations.length; i++) {
      final duration = _sentenceDurations[i];
      final bufferMs = (duration.inMilliseconds * (0.05 + 0.10 * (i / _sentenceDurations.length))).round();
      runningTotal += duration;
      _sentenceEndTimes.add(runningTotal - Duration(milliseconds: bufferMs));
    }

    _debugPrintDurations();
  }

  void _debugPrintDurations() {
    print("===== Audio-Text Alignment Debug =====");
    print("Total Audio Duration: ${_totalDuration.inMilliseconds}ms");
    print("Total Calculated Duration: ${_sentenceEndTimes.last.inMilliseconds}ms");
    
    for (int i = 0; i < _sentences.length; i++) {
      final start = i == 0 ? Duration.zero : _sentenceEndTimes[i-1];
      final end = _sentenceEndTimes[i];
      final duration = _sentenceDurations[i];
      
      print("""
Sentence ${i+1} [${_sentences[i].split(' ').length} words]:
   "${_sentences[i]}"
   Start: ${start.inMilliseconds}ms
   End: ${end.inMilliseconds}ms
   Duration: ${duration.inMilliseconds}ms
   Buffer: ${duration.inMilliseconds - (end - start).inMilliseconds}ms
""");
    }
  }

  void scrollToCurrentSentence() {
    if (!scrollController.hasClients || _sentences.isEmpty) return;

    final double estimatedSentenceHeight = 100.0;
    final double padding = 20.0;
    final double targetOffset =
        (_currentSentenceIndex * estimatedSentenceHeight) - padding;

    scrollController.animateTo(
      targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void goToNextSentence() async {
    if (_currentSentenceIndex >= _sentences.length - 1) return;

    _isSeeking = true;
    try {
      _currentSentenceIndex++;
      final nextStart = getSentenceStartTime(_currentSentenceIndex);
      await _audioPlayer.seek(nextStart);
      scrollToCurrentSentence();
    } finally {
      _isSeeking = false;
    }
  }

  void goToPreviousSentence() async {
    if (_currentSentenceIndex <= 0) return;

    _isSeeking = true;
    try {
      _currentSentenceIndex--;
      final prevStart = getSentenceStartTime(_currentSentenceIndex);
      await _audioPlayer.seek(prevStart);
      scrollToCurrentSentence();
    } finally {
      _isSeeking = false;
    }
  }

  Duration getSentenceStartTime(int index) {
    if (index <= 0) return Duration.zero;
    if (index >= _sentenceEndTimes.length) return _totalDuration;
    return _sentenceEndTimes[index - 1] +
        Duration(milliseconds: sentenceEndBufferMs);
  }

  int getCurrentSentenceIndex(Duration position) {
    final adjustedPosition =
        position + Duration(milliseconds: highlightOffsetMs);

    for (int i = 0; i < _sentenceEndTimes.length; i++) {
      if (adjustedPosition < _sentenceEndTimes[i]) {
        return i;
      }
    }
    return _sentenceEndTimes.length - 1;
  }
  Future<void> playPauseAudio() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
        isPlaying = false;
        isPaused = true;
        _progressTimer?.cancel();
      } else {
        if (isPaused) {
          await _audioPlayer.resume();
        } else {
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer
              .play(UrlSource((_audioPlayer.source as UrlSource).url));
        }
        isPlaying = true;
        isPaused = false;
        startUpdatingProgress();
      }
    } catch (e) {
      print("Error in playPause: $e");
    }
  }

  void startUpdatingProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      final position = await _audioPlayer.getCurrentPosition();
      if (position != null) {
        _handlePositionChange(position);
      }
    });
  }

  Future<void> seekToPosition(int position) async {
    try {
      await _audioPlayer.seek(Duration(milliseconds: position));
      _currentPosition = Duration(milliseconds: position);
      _sliderValue =
          _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
      onPositionChanged?.call(
          _currentPosition, getCurrentSentenceIndex(_currentPosition));
    } catch (e) {
      print("Error during seek: $e");
    }
  }

  void changeSpeed() {
    currentSpeedIndex = (currentSpeedIndex + 1) % speeds.length;
    playbackSpeed = speeds[currentSpeedIndex];
    _audioPlayer.setPlaybackRate(playbackSpeed);
    highlightSpeedFactor = playbackSpeed - 0.2;
  }

  Future<void> skipForward() async {
    final current = await _audioPlayer.getCurrentPosition();
    if (current != null) {
      await seekToPosition((current + Duration(seconds: 10)).inMilliseconds);
    }
  }

  Future<void> skipBackward() async {
    final current = await _audioPlayer.getCurrentPosition();
    if (current != null) {
      await seekToPosition((current - Duration(seconds: 10)).inMilliseconds);
    }
  }

  Future<void> loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isMale = prefs.getBool('isMaleVoice') ?? true;
    imagePath = isMale ? 'assets/Images/male.jpg' : 'assets/Images/female.jpeg';
  }

  Future<void> saveVoicePreference(bool isMale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMaleVoice', isMale);
  }

  Future<void> toggleVoice() async {
    if (isPlaying) await playPauseAudio();

    isSwitchingVoice = true;
    isMale = !isMale;
    imagePath = isMale ? 'assets/Images/male.jpg' : 'assets/Images/female.jpeg';
    await saveVoicePreference(isMale);

    final remainingText = _getRemainingTextFromCurrentPosition();
    await startTTS(remainingText, fromPosition: _currentPosition);

    isSwitchingVoice = false;
  }

  String _getRemainingTextFromCurrentPosition() {
    if (_currentSentenceIndex < 0 ||
        _currentSentenceIndex >= _sentences.length) {
      return _sentences.join(' ');
    }
    return _sentences.sublist(_currentSentenceIndex).join(' ');
  }

  void dispose() {
    _audioPlayer.dispose();
    _progressTimer?.cancel();
    scrollController.dispose();
  }
}

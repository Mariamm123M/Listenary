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
  Duration totalDuration = Duration.zero;
  Duration _originalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  double _sliderValue = 0.0;
  int currentSentenceIndex = 0;
  bool isPlaying = false;
  bool isPaused = false;
  double highlightSpeedFactor = 0.95;
  Timer? _progressTimer;
  List<double> speeds = [1.0, 1.25, 1.5, 2.0];
  int currentSpeedIndex = 0;
  double playbackSpeed = 1.0;
  String imagePath = 'assets/Images/male.jpg';
  bool isSwitchingVoice = false;
  List<Duration> _sentenceDurations = [];
  List<Duration> _sentenceStartTimes = [];
  bool _isScrolling = false;
  Timer? _scrollEndTimer;
  String? _currentAudioFile;

  // Callbacks
  Function(Duration position, int sentenceIndex)? onPositionChanged;
  Function()? onPlayerComplete;
  ScrollController scrollController = ScrollController();

  TTSService() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _handlePlaybackComplete();
    });

    scrollController.addListener(_handleScroll);
  }

  void _handlePlaybackComplete() {
    isPlaying = false;
    isPaused = false;
    currentPosition = Duration.zero;
    _sliderValue = 0.0;
    currentSentenceIndex = 0;
    onPlayerComplete?.call();
  }

  void _handleScroll() {
    if (!isPlaying) return;

    final scrollOffset = scrollController.offset;
    final sentenceHeight = 50.0;
    final topSentenceIndex = (scrollOffset / sentenceHeight).floor().clamp(0, _sentences.length - 1);

    if (topSentenceIndex != currentSentenceIndex) {
      _handleScrollToNewSentence(topSentenceIndex);
    }
  }

  void _handleScrollToNewSentence(int newIndex) {
    _scrollEndTimer?.cancel();
    _isScrolling = true;
    
    // Store current duration state
    Duration previousDuration = totalDuration;
    
    currentSentenceIndex = newIndex;
    onPositionChanged?.call(currentPosition, currentSentenceIndex);
    
    _scrollEndTimer = Timer(const Duration(milliseconds: 300), () {
      _isScrolling = false;
      _seekToSentence(newIndex);
      // Restore original duration if modified
      if (totalDuration != previousDuration) {
        totalDuration = previousDuration;
      }
    });
  }

  Future<void> _seekToSentence(int sentenceIndex) async {
    if (sentenceIndex < 0 || sentenceIndex >= _sentenceStartTimes.length) return;

    final targetPosition = _sentenceStartTimes[sentenceIndex];
    if ((targetPosition - currentPosition).abs() < Duration(milliseconds: 200)) {
      return;
    }

    try {
      await _audioPlayer.seek(targetPosition);
      currentPosition = targetPosition;
      _sliderValue = currentPosition.inMilliseconds / _originalDuration.inMilliseconds;
      currentSentenceIndex = sentenceIndex;
      onPositionChanged?.call(currentPosition, currentSentenceIndex);
    } catch (e) {
      print("Error seeking to sentence: $e");
    }
  }

  Future<void> startTTS(String text, {Duration fromPosition = Duration.zero}) async {
    int retryCount = 0;
    const int maxRetries = 3;

    var textHash = text.hashCode;
    var tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/speech_$textHash.mp3');
    _currentAudioFile = file.path;

    if (await file.exists() && file.lengthSync() > 0) {
      await _playExistingAudio(file, text, fromPosition);
      return;
    }

    while (retryCount < maxRetries) {
      try {
        _sentences = text.split(RegExp(r'(?<=[.!?])\s*'));

        var response = await http.post(
          Uri.parse('http://192.168.1.4:5002/tts'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "text": text,
            "gender": isMale ? "male" : "female",
          }),
        ).timeout(Duration(seconds: 60));

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          await _playExistingAudio(file, text, fromPosition);
          break;
        } else {
          print('Failed to generate speech. Status code: ${response.statusCode}');
          retryCount++;
        }
      } on TimeoutException {
        print("Timeout: Audio generation took too long.");
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

  Future<void> _playExistingAudio(File file, String text, Duration fromPosition) async {
    try {
      _sentences = text.split(RegExp(r'(?<=[.!?])\s*'));
      
      await _audioPlayer.setSource(UrlSource(file.path));
      final duration = await _audioPlayer.getDuration();
      
      if (duration != null) {
        totalDuration = duration;
        _originalDuration = duration; // Store original duration
        _calculateSentenceTimings();
        
        fromPosition = fromPosition > totalDuration ? totalDuration : fromPosition;
        currentSentenceIndex = _getSentenceIndexForPosition(fromPosition);
        
        await _audioPlayer.seek(fromPosition);
        await _audioPlayer.play(UrlSource(file.path));
        
        _audioPlayer.onPositionChanged.listen((Duration position) {
          if (_isScrolling) return;
          
          currentPosition = position;
          _sliderValue = position.inMilliseconds / _originalDuration.inMilliseconds;
          
          final newIndex = _getSentenceIndexForPosition(position);
          if (newIndex != currentSentenceIndex) {
            currentSentenceIndex = newIndex;
            _scrollToCurrentSentence();
          }
          
          onPositionChanged?.call(position, currentSentenceIndex);
        });

        isPlaying = true;
      }
    } catch (e) {
      print('Error playing existing audio: $e');
    }
  }

  void _calculateSentenceTimings() {
    _sentenceStartTimes.clear();
    _sentenceDurations.clear();
    
    if (_sentences.isEmpty || _originalDuration == Duration.zero) return;
    
    int totalChars = _sentences.fold(0, (sum, sentence) => sum + sentence.length);
    if (totalChars == 0) return;
    
    Duration currentStart = Duration.zero;
    
    for (String sentence in _sentences) {
      _sentenceStartTimes.add(currentStart);
      
      double ratio = sentence.length / totalChars;
      Duration sentenceDuration = Duration(
        milliseconds: (_originalDuration.inMilliseconds * ratio).round()
      );
      
      _sentenceDurations.add(sentenceDuration);
      currentStart += sentenceDuration;
    }
  }

  int _getSentenceIndexForPosition(Duration position) {
    for (int i = 0; i < _sentenceStartTimes.length; i++) {
      if (i == _sentenceStartTimes.length - 1 || 
          position < _sentenceStartTimes[i + 1]) {
        return i;
      }
    }
    return 0;
  }

  void _scrollToCurrentSentence() {
    if (!scrollController.hasClients) return;
    
    double targetOffset = currentSentenceIndex * 50.0;
    double currentOffset = scrollController.offset;
    
    if ((currentOffset - targetOffset).abs() > 1.0) {
      scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
        } else if (_currentAudioFile != null) {
          await _audioPlayer.play(UrlSource(_currentAudioFile!));
        }
        isPlaying = true;
        isPaused = false;
        _startProgressUpdates();
      }
    } catch (e) {
      print("Error in playPause: $e");
    }
  }

  void _startProgressUpdates() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (!isPlaying || _isScrolling) return;
      
      Duration? position = await _audioPlayer.getCurrentPosition();
      if (position != null) {
        currentPosition = position;
        _sliderValue = currentPosition.inMilliseconds / _originalDuration.inMilliseconds;
        onPositionChanged?.call(position, _getSentenceIndexForPosition(position));
      }
    });
  }

  Future<void> seekToPosition(int position) async {
    try {
      await _audioPlayer.seek(Duration(milliseconds: position));
      currentPosition = Duration(milliseconds: position);
      _sliderValue = currentPosition.inMilliseconds / _originalDuration.inMilliseconds;
      onPositionChanged?.call(currentPosition, _getSentenceIndexForPosition(currentPosition));
    } catch (e) {
      print("Error seeking: $e");
    }
  }

  void changeSpeed() {
    currentSpeedIndex = (currentSpeedIndex + 1) % speeds.length;
    playbackSpeed = speeds[currentSpeedIndex];
    _audioPlayer.setPlaybackRate(playbackSpeed);
    highlightSpeedFactor = playbackSpeed - 0.2;
  }

  void skipForward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    if (currentPosition != null) {
      int newPosition = (currentPosition + Duration(seconds: 10)).inMilliseconds;
      newPosition = newPosition.clamp(0, _originalDuration.inMilliseconds);
      await seekToPosition(newPosition);
    }
  }

  void skipBackward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    if (currentPosition != null) {
      int newPosition = (currentPosition - Duration(seconds: 10)).inMilliseconds;
      newPosition = newPosition.clamp(0, _originalDuration.inMilliseconds);
      await seekToPosition(newPosition);
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

  void toggleVoice() async {
    if (isPlaying) {
      await playPauseAudio();
    }

    // Store current state
    Duration previousPosition = currentPosition;
    
    isSwitchingVoice = true;
    isMale = !isMale;
    imagePath = isMale ? 'assets/Images/male.jpg' : 'assets/Images/female.jpeg';
    await saveVoicePreference(isMale);

    String remainingText = _getRemainingTextFromCurrentPosition();
    await startTTS(remainingText, fromPosition: previousPosition);
    
    // Restore original duration
    totalDuration = _originalDuration;
    isSwitchingVoice = false;
  }

  String _getRemainingTextFromCurrentPosition() {
    if (currentSentenceIndex < 0 || currentSentenceIndex >= _sentences.length) {
      return _sentences.join(' ');
    }
    return _sentences.sublist(currentSentenceIndex).join(' ');
  }

  void dispose() {
    _audioPlayer.dispose();
    _progressTimer?.cancel();
    _scrollEndTimer?.cancel();
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
  }
}
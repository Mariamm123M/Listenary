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
  bool isMale = true; // Default gender for TTS
  List<String> _sentences = [];
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  double _sliderValue = 0.0;
  int _currentSentenceIndex = 0;
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

  // Callbacks for real-time updates
  Function(Duration position, int sentenceIndex)? onPositionChanged;
  Function()? onPlayerComplete;
  ScrollController scrollController = ScrollController();

  // Getters
  int get currentSentenceIndex => _currentSentenceIndex;
  Duration get totalDuration => _totalDuration;
  Duration get currentPosition => _currentPosition;

  TTSService() {
    _audioPlayer.onPlayerComplete.listen((event) {
      isPlaying = false;
      isPaused = false;
      _currentPosition = Duration.zero;
      _sliderValue = 0.0;
      _currentSentenceIndex = 0;
      onPlayerComplete?.call();
    });

    scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!isPlaying) return; // Only respond to scroll when audio is playing
    
    // Calculate which sentence is at the top of the viewport
    final scrollOffset = scrollController.offset;
    final sentenceHeight = 50.0; // Adjust based on your UI
    final topSentenceIndex = (scrollOffset / sentenceHeight).floor();
    
    // If user scrolled to a different sentence
    if (topSentenceIndex != _currentSentenceIndex && 
        topSentenceIndex >= 0 && 
        topSentenceIndex < _sentences.length) {
      _seekToSentence(topSentenceIndex);
    }
  }

  Future<void> _seekToSentence(int sentenceIndex) async {
    if (sentenceIndex < 0 || sentenceIndex >= _sentenceStartTimes.length) return;
    
    // Get the start time of the target sentence
    final targetPosition = _sentenceStartTimes[sentenceIndex];
    
    // Seek to the position
    await _audioPlayer.seek(targetPosition);
    
    // Update current position and index
    _currentPosition = targetPosition;
    _currentSentenceIndex = sentenceIndex;
    _sliderValue = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
    
    // Notify listeners
    onPositionChanged?.call(_currentPosition, _currentSentenceIndex);
  }

  Future<void> startTTS(String text,
      {Duration fromPosition = Duration.zero}) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // Clear previous sentences
        _sentences.clear();

        // Split the text into sentences for display
        _sentences = text.split(RegExp(r'(?<=[.!?])\s*'));

        // Generate a unique filename based on the text
        var textHash = text.hashCode;
        var tempDir = await getTemporaryDirectory();
        File file = File('${tempDir.path}/speech_$textHash.mp3');

        // Send the text to the TTS server
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

          // Debug: Print file path and size
          print('Audio file saved at: ${file.path}');
          print('File size: ${file.lengthSync()} bytes');

          // Load the audio file
          await _audioPlayer.setSource(UrlSource(file.path));

          // Wait for the audio file to be ready
          final duration = await _audioPlayer.getDuration();
          if (duration != null) {
            _totalDuration = duration;
            _calculateSentenceTimings();

            // Ensure fromPosition does not exceed the total duration
            if (fromPosition > _totalDuration) {
              fromPosition = _totalDuration;
            }

            // Find the sentence index for the starting position
            _currentSentenceIndex = _getSentenceIndexForPosition(fromPosition);
            
            // Scroll to the current sentence
            _scrollToCurrentSentence();

            // Seek to the position where the last speaker stopped
            await _audioPlayer.seek(fromPosition);

            // Play the audio file
            await _audioPlayer.play(UrlSource(file.path));

            // Listen for position changes to update the highlighted sentence
            _audioPlayer.onPositionChanged.listen((Duration position) {
              _currentPosition = position;
              _sliderValue = position.inMilliseconds / _totalDuration.inMilliseconds;
              
              // Update current sentence index
              final newIndex = _getSentenceIndexForPosition(position);
              if (newIndex != _currentSentenceIndex) {
                _currentSentenceIndex = newIndex;
                _scrollToCurrentSentence();
              }
              
              // Notify listeners of position changes
              onPositionChanged?.call(position, _currentSentenceIndex);
            });

            isPlaying = true;
          }
        } else {
          print('Failed to generate speech. Status code: ${response.statusCode}');
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

  void _calculateSentenceTimings() {
    _sentenceStartTimes.clear();
    _sentenceDurations.clear();
    
    if (_sentences.isEmpty || _totalDuration == Duration.zero) return;
    
    int totalChars = _sentences.fold(0, (sum, sentence) => sum + sentence.length);
    if (totalChars == 0) return;
    
    Duration currentStart = Duration.zero;
    
    for (String sentence in _sentences) {
      _sentenceStartTimes.add(currentStart);
      
      double ratio = sentence.length / totalChars;
      Duration sentenceDuration = Duration(
        milliseconds: (_totalDuration.inMilliseconds * ratio).round()
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
    
    // Calculate the position to scroll to (keeping the sentence at the top)
    double targetOffset = _currentSentenceIndex * 50.0; // Adjust based on your UI
    
    // Only scroll if the target is not already visible at the top
    if ((scrollController.offset - targetOffset).abs() > 1.0) {
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
        // Pause the audio if it's currently playing
        await _audioPlayer.pause().timeout(Duration(seconds: 15));
        isPlaying = false;
        isPaused = true;
        _progressTimer?.cancel(); // Stop updating progress
      } else {
        if (isPaused) {
          // Resume from where it was paused
          await _audioPlayer.resume().timeout(Duration(seconds: 15));
        } else {
          // If not paused, start from the beginning
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer
              .play(UrlSource((_audioPlayer.source as UrlSource).url))
              .timeout(Duration(seconds: 15));
        }
        isPlaying = true;
        isPaused = false;
        startUpdatingProgress();
      }
    } on TimeoutException {
      print("Timeout: Audio operation took too long.");
      if (onPlayerComplete != null) {
        onPlayerComplete!();
      }
    } catch (e) {
      print("Error: $e");
      if (onPlayerComplete != null) {
        onPlayerComplete!();
      }
    }
  }

  void startUpdatingProgress() {
    _progressTimer?.cancel(); // Cancel any existing timer
    _progressTimer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      Duration? currentPosition = await _audioPlayer.getCurrentPosition();
      if (currentPosition != null) {
        _currentPosition = currentPosition;
        if (onPositionChanged != null) {
          onPositionChanged!(
              currentPosition, _getSentenceIndexForPosition(currentPosition));
        }
      }
    });
  }

  Future<void> seekToPosition(int position) async {
    try {
      await _audioPlayer.seek(Duration(milliseconds: position));
      // Update the current position only after seek is successful
      _currentPosition = Duration(milliseconds: position);
      _sliderValue =
          _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
      if (onPositionChanged != null) {
        onPositionChanged!(
            _currentPosition, _getSentenceIndexForPosition(_currentPosition));
      }
    } on TimeoutException {
      print("Seek operation timed out. Retrying...");
      await Future.delayed(Duration(seconds: 1));
      await _audioPlayer.seek(Duration(milliseconds: position));
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

  void skipForward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    final duration = await _audioPlayer.getDuration();
    if (currentPosition != null && duration != null) {
      int newPosition =
          (currentPosition + Duration(seconds: 10)).inMilliseconds;
      newPosition = newPosition.clamp(0, duration.inMilliseconds);
      await seekToPosition(newPosition);
    }
  }

  void skipBackward() async {
    final currentPosition = await _audioPlayer.getCurrentPosition();
    if (currentPosition != null) {
      int newPosition =
          (currentPosition - Duration(seconds: 10)).inMilliseconds;
      newPosition = newPosition.clamp(0, _totalDuration.inMilliseconds);
      await seekToPosition(newPosition);
    }
  }

  Future<void> loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isMale = prefs.getBool('isMaleVoice') ?? true; // Default to male
    imagePath = isMale ? 'assets/Images/male.jpg' : 'assets/Images/female.jpeg';
  }

  Future<void> saveVoicePreference(bool isMale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMaleVoice', isMale); // Save the voice preference
  }

  void toggleVoice() async {
    print('Toggling voice...');
    print('Current Position: $_currentPosition');
    print('Total Duration: $_totalDuration');

    // Stop and release the current audio player
    if (isPlaying) {
      await playPauseAudio();
    }

    isSwitchingVoice = true; // Toggle the voice

    // Toggle the voice and update the image
    isMale = !isMale;
    imagePath = isMale ? 'assets/Images/male.jpg' : 'assets/Images/female.jpeg';

    await saveVoicePreference(isMale); // Save the new preference

    // Get the remaining text from where the last speaker stopped
    String remainingText = _getRemainingTextFromCurrentPosition();
    print('Remaining Text: $remainingText');

    // Calculate the remaining duration
    Duration remainingDuration = _totalDuration - _currentPosition;

    // Restart TTS with the remaining text, starting from the current position
    await startTTS(remainingText, fromPosition: _currentPosition);

    // Update the total duration to reflect the remaining duration
    _totalDuration = remainingDuration;

    isSwitchingVoice = false; // Hide loading indicator
  }

  String _getRemainingTextFromCurrentPosition() {
    // Ensure _currentSentenceIndex is within bounds
    if (_currentSentenceIndex < 0 || _currentSentenceIndex >= _sentences.length) {
      // If the index is out of bounds, return the entire text
      print('Current Sentence Index is out of bounds. Returning entire text.');
      return _sentences.join(' ');
    } else {
      // Return the remaining text from the current position
      String remainingText = _sentences.sublist(_currentSentenceIndex).join(' ');
      return remainingText;
    }
  }

  void dispose() {
    _audioPlayer.dispose(); // Dispose of the audio player
    _progressTimer?.cancel(); // Cancel the progress timer
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
  }
}
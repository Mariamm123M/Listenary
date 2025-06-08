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
  bool isLoading = false;
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
  String _lastGeneratedText = '';
  String _lastGeneratedGender = '';
  String lastAudioFilePath = ''; // Made public for better access

  static const String apiUrl =
      'http://192.168.1.4:5002/tts'; // Extracted as constant
  static const int highlightOffsetMs = 50;
  static const int highlightLeadMs = 300;
  static const int sentenceEndBufferMs = 30;
  static const double wordsPerSecond = 3.0;
  static const double punctuationPauseSeconds = 0.3;
  static const double sentenceEndPauseSeconds = 0.5;
  static const double _baseWordsPerSecond = 2.5;
  static const double _punctuationPause = 0.15;
  static const double _sentenceEndPause = 0.25;
  static const int _highlightLeadMs = 400;

  Function(Duration position, int sentenceIndex)? onPositionChanged;
  Function()? onPlayerComplete;
  Function(bool isLoading)? onLoadingStateChanged;

  int get currentSentenceIndex => _currentSentenceIndex;
  Duration get totalDuration => _totalDuration;
  Duration get currentPosition => _currentPosition;

  TTSService() {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _handlePlaybackComplete();
    });
    _audioPlayer.onPositionChanged.listen((position) {
      _handlePositionChange(position);
    });
    // Configure AudioPlayer for better performance
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void _handlePlaybackComplete() {
    isPlaying = false;
    isPaused = false;
    _currentPosition = Duration.zero;
    _sliderValue = 0.0;
    _currentSentenceIndex = 0;
    _progressTimer?.cancel();
    onPlayerComplete?.call();
  }
  void debugScrollInfo() {
  print('===== SCROLL DEBUG INFO =====');
  print('hasClients: ${scrollController.hasClients}');
  print('_sentences.length: ${_sentences.length}');
  print('_currentSentenceIndex: $_currentSentenceIndex');
  if (scrollController.hasClients) {
    print('Current offset: ${scrollController.offset}');
    print('Max extent: ${scrollController.position.maxScrollExtent}');
    print('Viewport height: ${scrollController.position.viewportDimension}');
  }
  print('================================');
}

  void _handlePositionChange(Duration position) {
    _currentPosition = position;
    // Prevent division by zero
    if (_totalDuration.inMilliseconds > 0) {
      _sliderValue = position.inMilliseconds / _totalDuration.inMilliseconds;
    } else {
      _sliderValue = 0.0;
    }
    final newIndex = _calculateCurrentSentenceIndex(position);
    if (newIndex != _currentSentenceIndex) {
      _currentSentenceIndex = newIndex;
      debugScrollInfo();
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

    // Adjust the position to account for the highlight lead
    // Scale the lead time based on playback speed
    final adjustedPosition = position +
        Duration(
          milliseconds: (_highlightLeadMs / playbackSpeed).round(),
        );
    // Binary search for efficiency
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

  // Check if we already have a generated audio file for this text and gender
  Future<String?> _checkForExistingAudio(String text, bool isMale) async {
    try {
      var textHash = '${text.hashCode}_${isMale ? "male" : "female"}';
      var tempDir = await getTemporaryDirectory();
      File file = File('${tempDir.path}/speech_$textHash.mp3');
      if (file.existsSync() && await file.length() > 0) {
        print('Found existing audio file: ${file.path}');
        return file.path;
      }
    } catch (e) {
      print('Error checking for existing audio: $e');
    }
    return null;
  }

  // Main function to start TTS
  Future<void> startTTS(String text,
      {Duration fromPosition = Duration.zero,
      required BuildContext context,
      required FontStyle style,
      required double maxWidth}) async {
    if (text.isEmpty) {
      print('Empty text provided to TTS');
      return;
    }
    // Set loading state
    _setLoading(true);
    try {
      _sentences = text
          .split(RegExp(r'(?<=[.!?])\s+'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (_sentences.isEmpty) {
        _sentences = [text]; // Ensure we have at least one sentence
      }
      print('Sentence count: ${_sentences.length}');
      await calculateSentenceHeights(context, style, maxWidth);
      // Get audio file path (either existing or new)
      final filePath = await _getAudioFilePath(text);
      // Play the audio file
      await _playAudioFromFile(filePath, fromPosition);
    } catch (e) {
      print('TTSService error: $e');
      isPlaying = false;
      isPaused = false;
      // Show error to user
      throw Exception('Failed to play audio: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper to get audio file path (either existing or newly generated)
  Future<String> _getAudioFilePath(String text) async {
    int retryCount = 0;
    const int maxRetries = 3;
    var textHash = '${text.hashCode}_${isMale ? "male" : "female"}';
    var tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/speech_$textHash.mp3');
    String filePath = file.path;
    // Check for reuse conditions
    if (_lastGeneratedText == text &&
        _lastGeneratedGender == (isMale ? "male" : "female") &&
        lastAudioFilePath.isNotEmpty) {
      // Reuse in-memory path
      return lastAudioFilePath;
    }
    // Check for file on disk
    final existingPath = await _checkForExistingAudio(text, isMale);
    if (existingPath != null) {
      // Store path for future reuse
      lastAudioFilePath = existingPath;
      _lastGeneratedText = text;
      _lastGeneratedGender = isMale ? "male" : "female";
      return existingPath;
    }
    // Need to generate new audio
    while (retryCount < maxRetries) {
      try {
        print('Generating new audio file. Attempt ${retryCount + 1}...');

        final response = await http
            .post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "text": text,
                "gender": isMale ? "male" : "female",
              }),
            )
            .timeout(Duration(seconds: 60));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          lastAudioFilePath = filePath;
          _lastGeneratedText = text;
          _lastGeneratedGender = isMale ? "male" : "female";
          print('Successfully generated audio file: $filePath');
          return filePath;
        } else {
          print(
              'Failed to generate speech. Status code: ${response.statusCode}');
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception(
                'Failed to generate speech after $maxRetries attempts. Server returned ${response.statusCode}');
          }
          await Future.delayed(Duration(milliseconds: 500));
        }
      } on TimeoutException {
        print("Timeout: Audio generation took too long.");
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception(
              "Timeout: Audio generation failed after $maxRetries attempts");
        }
        await Future.delayed(Duration(milliseconds: 1000));
      } catch (e) {
        print('Error generating audio: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception(
              'Error generating audio after $maxRetries attempts: $e');
        }
        await Future.delayed(Duration(milliseconds: 1000));
      }
    }
    // Should not reach here if maxRetries is reached, but just in case
    throw Exception('Failed to generate speech after multiple attempts');
  }
  // Helper to play audio from file path
  Future<void> _playAudioFromFile(
      String filePath, Duration fromPosition) async {
    try {
      await _audioPlayer.setSource(UrlSource(filePath));
      final duration = await _audioPlayer.getDuration();
      if (duration != null) {
        _totalDuration = duration;
        print('Audio duration: ${_totalDuration.inMilliseconds}ms');
        // Calculate sentence durations
        await _estimateDurationsWithRetry();
        // Seek to position and play
        final seekPosition =
            fromPosition > _totalDuration ? _totalDuration : fromPosition;
        await _audioPlayer.seek(seekPosition);
        await _audioPlayer.setPlaybackRate(playbackSpeed);
        await _audioPlayer.resume();
        isPlaying = true;
        isPaused = false;
        startUpdatingProgress();
        _currentSentenceIndex = _calculateCurrentSentenceIndex(seekPosition);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToCurrentSentence();
        });
      } else {
        throw Exception('Could not determine audio duration');
      }
    } catch (e) {
      print('Error playing audio: $e');
      throw Exception('Error playing audio: $e');
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
    // First, estimate raw duration in milliseconds for each sentence
    final rawDurations = _sentences.map((sentence) {
      final words = sentence.split(' ').length;
      final punctuation = sentence.replaceAll(RegExp(r'[^.!?,;:]'), '').length;
      // More precise calculation taking into account words, punctuation, and sentence end
      final durationSec = (words / _baseWordsPerSecond) +
          (punctuation * _punctuationPause) +
          _sentenceEndPause;
      return durationSec * 1000;
    }).toList();
    // Calculate total raw duration
    final totalRawMs = rawDurations.reduce((a, b) => a + b);
    // Scale durations to match actual audio duration
    final scaleFactor = _totalDuration.inMilliseconds / totalRawMs;
    // Apply scale factor to each sentence duration
    _sentenceDurations = rawDurations
        .map((ms) => Duration(milliseconds: (ms * scaleFactor).round()))
        .toList();
    // Calculate endpoint timestamps for each sentence
    _sentenceEndTimes = [];
    Duration runningTotal = Duration.zero;
    // Adaptive buffer calculation that gets smaller towards the end
    for (int i = 0; i < _sentenceDurations.length; i++) {
      final duration = _sentenceDurations[i];
      // Progressively reduce buffer for later sentences
      final progressFactor = (i / _sentenceDurations.length); // 0 to 1
      final bufferMs =
          (duration.inMilliseconds * (0.04 + 0.08 * (1 - progressFactor)))
              .round();
      runningTotal += duration;
      _sentenceEndTimes.add(runningTotal - Duration(milliseconds: bufferMs));
    }
    _debugPrintDurations();
  }

  void _debugPrintDurations() {
    print("===== Audio-Text Alignment Debug =====");
    print("Total Audio Duration: ${_totalDuration.inMilliseconds}ms");
    print(
        "Total Calculated Duration: ${_sentenceEndTimes.last.inMilliseconds}ms");
    for (int i = 0; i < _sentences.length; i++) {
      final start = i == 0 ? Duration.zero : _sentenceEndTimes[i - 1];
      final end = _sentenceEndTimes[i];
      final duration = _sentenceDurations[i];
      print("""
Sentence ${i + 1} [${_sentences[i].split(' ').length} words]:
   "${_sentences[i]}"
   Start: ${start.inMilliseconds}ms
   End: ${end.inMilliseconds}ms
   Duration: ${duration.inMilliseconds}ms
   Buffer: ${duration.inMilliseconds - (end - start).inMilliseconds}ms
""");
    }
  }

  void _setLoading(bool loading) {
    isLoading = loading;
    onLoadingStateChanged?.call(loading);
  }

// Add these fields to your TTSService class
  List<double> _sentenceHeights = [];
  List<double> _sentencePositions = []; // Cumulative positions

  Future<void> calculateSentenceHeights(
      BuildContext context, FontStyle style, double maxWidth) async {
    if (_sentences.isEmpty) return;

    // Calculate individual heights
    _sentenceHeights = _sentences.map((sentence) {
      final textPainter = TextPainter(
        text: TextSpan(text: sentence, style: TextStyle(fontStyle: style)),
        maxLines: null,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth - 40); // Account for padding
      return textPainter.height + 22.0; // Add some vertical spacing
    }).toList();
    // Calculate cumulative positions (where each sentence starts)
    _sentencePositions = [];
    double runningTotal = 0.0;
    for (final height in _sentenceHeights) {
      _sentencePositions.add(runningTotal);
      runningTotal += height;
    }
    print('Calculated heights for ${_sentenceHeights.length} sentences');
    print('Total content height: $runningTotal');
  }
void scrollToCurrentSentence() {
  // Early return if conditions aren't met
  if (!scrollController.hasClients ||
      _sentences.isEmpty ||
      _currentSentenceIndex >= _sentences.length ||
      _sentencePositions.isEmpty) {
    print('Cannot scroll: missing prerequisites');
    return;
  }
  try {
    // Get viewport dimensions
    final viewportHeight = scrollController.position.viewportDimension;
    final controllerBoxHeight = 800.0; // Adjust as needed
    final bufferSpace = 120.0; // Increased buffer space for better visibility
    // Calculate the safe visible area (above the controller box)
    final safeAreaHeight = viewportHeight - controllerBoxHeight - bufferSpace;
    // Get the position and height of the current sentence
    final sentenceTop = _sentencePositions[_currentSentenceIndex];
    final sentenceHeight = _sentenceHeights[_currentSentenceIndex];
    final sentenceBottom = sentenceTop + sentenceHeight;
    // Current scroll position
    final currentScrollOffset = scrollController.offset;
    // Special handling for first few sentences - don't force scroll if already at top
    if (_currentSentenceIndex < 2 && currentScrollOffset <= 0) {
      print('Early sentence and already at top - no need to scroll');
      return;
    }
    // Calculate the visible boundaries of the scroll view
    final visibleTop = currentScrollOffset;
    final visibleBottom = currentScrollOffset + safeAreaHeight;
    // Check if the sentence is already fully visible (but not for sentences near the end)
    final isFullyVisible = sentenceTop >= visibleTop &&
                          sentenceBottom <= visibleBottom &&
                          _currentSentenceIndex < _sentences.length - 2; // Don't apply this rule for last few sentences
    if (isFullyVisible && _currentSentenceIndex < (_sentences.length * 0.5)) {
      print('Sentence is already visible - no scroll needed');
      return;
    }
    // Calculate how far we are through the content (0.0 to 1.0)
    final progressRatio = _currentSentenceIndex / (_sentences.length - 1);
    // Calculate target offset - this is the key part to fix
    double targetOffset;
    // Adjusted positioning logic for better centering
    if (progressRatio > 0.5) {
      // Last half - maintain center positioning but with slight adjustment
      // This positions the text in the middle of the available space
      targetOffset = sentenceTop - (safeAreaHeight * 0.5);
      print('Later half of content - positioned for consistent visibility');
    } else {
      // First half - normal centering
      targetOffset = sentenceTop - (safeAreaHeight / 2) + (sentenceHeight / 2);
      print('Standard centering for first half of content');
    }
    // Keep early sentences at the top instead of centering
    if (targetOffset < 0) {
      targetOffset = 0;
      print('Keeping view at top for early sentence');
    }
    // Reduce the extra offset for higher sentences
    if (progressRatio > 0.6) {
      // Add a smaller, more controlled extra offset
      final extraOffset = (progressRatio - 0.6) * 50.0; // Reduced from 100.0
      targetOffset -= extraOffset;
      print('Adding controlled extra offset: $extraOffset pixels');
    }
    // Ensure we don't scroll beyond content bounds
    targetOffset = targetOffset.clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent
    );
    // Debug info
    print('Sentence $_currentSentenceIndex (progress: ${(progressRatio * 100).toStringAsFixed(1)}%)');
    print('Position: top=$sentenceTop, bottom=$sentenceBottom, height=$sentenceHeight');
    print('Viewport: height=$viewportHeight, safeArea=$safeAreaHeight');
    print('Target scroll position: $targetOffset (current: $currentScrollOffset)');
    // Only scroll if needed (target is different from current)
    if ((targetOffset - currentScrollOffset).abs() > 10) {
      scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 450),
        curve: Curves.easeOutQuart,
      );
    } else {
      print('Current position is close to target - no scroll needed');
    }
  } catch (e) {
    print('Error in scrollToCurrentSentence: $e');
  }
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

  // Improved play/pause logic
  Future<void> playPauseAudio() async {
    try {
      if (isLoading) {
        print("Can't play/pause while loading");
        return;
      }
      if (isPlaying) {
        await _audioPlayer.pause();
        isPlaying = false;
        isPaused = true;
        _progressTimer?.cancel();
      } else {
        if (isPaused) {
          await _audioPlayer.resume();
        } else {
          // If audio completed or not started
          if (lastAudioFilePath.isNotEmpty) {
            // Audio exists but completed or not started
            await _audioPlayer.seek(Duration.zero);
            await _audioPlayer.resume();
          } else {
            // No audio file available
            return; // Let caller handle the need to generate audio
          }
        }
        isPlaying = true;
        isPaused = false;
        startUpdatingProgress();
      }
    } catch (e) {
      print("Error in playPause: $e");
      throw Exception("Error controlling playback: $e");
    }
  }

  void startUpdatingProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (!isPlaying) {
        timer.cancel();
        return;
      }
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
      // Prevent division by zero
      if (_totalDuration.inMilliseconds > 0) {
        _sliderValue =
            _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
      } else {
        _sliderValue = 0.0;
      }
      final sentenceIndex = getCurrentSentenceIndex(_currentPosition);
      _currentSentenceIndex = sentenceIndex;
      onPositionChanged?.call(_currentPosition, sentenceIndex);
      scrollToCurrentSentence();
    } catch (e) {
      print("Error during seek: $e");
      throw Exception("Error seeking to position: $e");
    }
  }

  void changeSpeed() {
    currentSpeedIndex = (currentSpeedIndex + 1) % speeds.length;
    playbackSpeed = speeds[currentSpeedIndex];
    _audioPlayer.setPlaybackRate(playbackSpeed);
    // Adjust highlight timing based on speed
    highlightSpeedFactor = 0.9 + (playbackSpeed / 10);
  }

  Future<void> loadVoicePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isMale = prefs.getBool('isMaleVoice') ?? true;
      imagePath =
          isMale ? 'assets/Images/male.jpg' : 'assets/Images/female.jpeg';
    } catch (e) {
      print("Error loading voice preference: $e");
      // Default to male voice if there's an error
      isMale = true;
      imagePath = 'assets/Images/male.jpg';
    }
  }

  Future<void> saveVoicePreference(bool isMale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMaleVoice', isMale);
    } catch (e) {
      print("Error saving voice preference: $e");
    }
  }

  Future<void> toggleVoice(BuildContext context, FontStyle style) async {
    if (isLoading) return;
    // Store current position and state before switching
    final wasPaused = isPaused;
    final wasPlaying = isPlaying;
    final currentPos = _currentPosition;
    if (isPlaying) await _audioPlayer.pause();
    _setLoading(true);
    isSwitchingVoice = true;
    try {
      // Toggle voice
      isMale = !isMale;
      imagePath =
          isMale ? 'assets/Images/male.jpg' : 'assets/Images/female.jpeg';
      await saveVoicePreference(isMale);
      // Get the full text, not just from current position
      final fullText = _sentences.join(' ');
      // Toggle voice with the full text but from current position
      if (fullText.isNotEmpty) {
        await startTTS(fullText, fromPosition: currentPos, context:context, style: style,maxWidth: MediaQuery.of(context).size.width );
      }
      // If we were paused before, pause again after switching
      if (wasPaused && !wasPlaying) {
        await _audioPlayer.pause();
        isPlaying = false;
        isPaused = true;
      }
    } catch (e) {
      print("Error toggling voice: $e");
      throw Exception("Error changing voice: $e");
    } finally {
      isSwitchingVoice = false;
      _setLoading(false);
    }
  }

  String getFullText() {
    return _sentences.join(' ');
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    isPlaying = false;
    isPaused = false;
    _currentPosition = Duration.zero;
    _sliderValue = 0.0;
    _currentSentenceIndex = 0;
    _progressTimer?.cancel();
    scrollToCurrentSentence();
  }

  Future<void> restart() async {
    if (lastAudioFilePath.isEmpty) return;
    if (isPlaying) {
      await _audioPlayer.pause();
    }
    _currentPosition = Duration.zero;
    _sliderValue = 0.0;
    _currentSentenceIndex = 0;
    await _audioPlayer.seek(Duration.zero);
    await _audioPlayer.resume();
    isPlaying = true;
    isPaused = false;
    startUpdatingProgress();
    scrollToCurrentSentence();
  }

  void dispose() {
    _audioPlayer.dispose();
    _progressTimer?.cancel();
    scrollController.dispose();
  }
}

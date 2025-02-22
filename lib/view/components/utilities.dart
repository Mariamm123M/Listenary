String cleanText(String text) {
  return text.replaceAll(RegExp(r'[^\w\s]+'), '');
}

List<String> splitTextIntoSentences(String text) {
  return text.split(RegExp(r'(?<=[.!?])\s*'));
}
String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

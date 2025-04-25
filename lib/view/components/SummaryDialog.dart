import 'package:flutter/material.dart';

class SummaryDialog extends StatefulWidget {
  final bool isDarkMode;
  final String? initial;

  SummaryDialog({required this.isDarkMode, this.initial});

  @override
  _SummaryDialogState createState() => _SummaryDialogState();
}

class _SummaryDialogState extends State<SummaryDialog> {
  final TextEditingController _textController = TextEditingController();
  String _summarizedText = '';

  String summarizeText(String text) {
  if (text.isEmpty) return 'No text available to summarize.';

  List<String> sentences = text.split('.').where((s) => s.trim().isNotEmpty).toList();

  Map<String, int> wordFrequency = {};
  List<String> words = text.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();

  for (String word in words) {
    wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
  }

  Map<String, int> sentenceScores = {};
  for (String sentence in sentences) {
    int score = 0;
    List<String> sentenceWords = sentence.toLowerCase().split(RegExp(r'\W+'));
    for (String word in sentenceWords) {
      score += wordFrequency[word] ?? 0;
    }
    sentenceScores[sentence.trim()] = score;
  }

  var sortedSentences = sentenceScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  int numberOfSentences = (sentences.length * 0.3).ceil();
  List<String> importantSentences = sortedSentences
      .take(numberOfSentences)
      .map((entry) => entry.key)
      .toList();

  return importantSentences.join('. ') + '.';
}
@override
void initState() {
  super.initState();
  if (widget.initial != null && widget.initial!.isNotEmpty) {
    _textController.text = widget.initial!;
    _summarizedText = summarizeText(widget.initial!);
  }
}
@override
void dispose() {
  _textController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
      title: Text(
        'Summary',
        style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter text to summarize...',
                hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black)),
              ),
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontSize: screenWidth * 0.03),
            ),SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _summarizedText = summarizeText(_textController.text);
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: widget.isDarkMode ? Colors.yellow : Color(0xFF212E54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: Text(
                'Summarize',
                style: TextStyle(color: widget.isDarkMode ? Colors.black : Colors.white),
              ),
            ),
            SizedBox(height: 20),if (_summarizedText.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _summarizedText,
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontSize: screenWidth * 0.03),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
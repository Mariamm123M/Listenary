import 'package:flutter/material.dart';

class TextDisplay extends StatelessWidget {
  final int currentSentenceIndex;
  final List<String> sentences;
  String selectedFontFamily = 'Inter';
  FontWeight selectedFontWeight = FontWeight.w700;
  TextDecoration selectedFontDecoration = TextDecoration.none;
  FontStyle selectedFontStyle = FontStyle.normal;
  
  TextDisplay({super.key, required this.currentSentenceIndex, required this.sentences, required this.selectedFontDecoration, required this.selectedFontFamily, required this.selectedFontStyle, required this.selectedFontWeight});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        RichText(
          text: TextSpan(
            children: sentences.asMap().entries.map((entry) {
              int index = entry.key;
              String sentence = entry.value;
              return TextSpan(
                text: "$sentence ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: index == currentSentenceIndex
                      ? Colors.blue
                      : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

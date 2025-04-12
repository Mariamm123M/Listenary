import 'package:flutter/material.dart';

class TextDisplay extends StatelessWidget {
  final int currentSentenceIndex;
  final List<String> sentences;
  String selectedFontFamily = 'Inter';
  FontWeight selectedFontWeight = FontWeight.w700;
  TextDecoration selectedFontDecoration = TextDecoration.none;
  FontStyle selectedFontStyle = FontStyle.normal;
  final double screenWidth;
  final double screenHeight;
  final ScrollController scrollController;

  
  TextDisplay({super.key, required this.scrollController,required this.screenHeight,required this.screenWidth,required this.currentSentenceIndex, required this.sentences, required this.selectedFontDecoration, required this.selectedFontFamily, required this.selectedFontStyle, required this.selectedFontWeight});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [
         SizedBox(height: screenHeight * 0.007),
        RichText(
          text: TextSpan(
            children: sentences.asMap().entries.map((entry) {
              int index = entry.key;
              String sentence = entry.value;
              return TextSpan(
                text: "$sentence ",
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontFamily: selectedFontFamily,
                  fontStyle: selectedFontStyle,
                  fontWeight: selectedFontWeight,
                  color: index == currentSentenceIndex
                      ? Color(0xffFEC838)
                      : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: screenHeight * 0.5),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/gestures.dart';
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
  OverlayEntry? _overlayEntry;
  final double scaleFactor;

  TextDisplay(
      {super.key,
      required this.scaleFactor,
      required this.scrollController,
      required this.screenHeight,
      required this.screenWidth,
      required this.currentSentenceIndex,
      required this.sentences,
      required this.selectedFontDecoration,
      required this.selectedFontFamily,
      required this.selectedFontStyle,
      required this.selectedFontWeight});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
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
                    decoration: selectedFontDecoration,
                    color: index == currentSentenceIndex
                        ? Color(0xffFEC838)
                        : Colors.grey,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTapDown = (details) {
                      final tapPosition = details.globalPosition;
                      showDefinitionOverlay(
                          context, tapPosition, "شرح: $sentence");
                    },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: screenHeight * 0.5),
        ],
      ),
    );
  }

  void showDefinitionOverlay(BuildContext context, Offset position, String definition) {
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;

  // نحسب حجم البوكس بتاع التعريف
  double tooltipMaxWidth = screenWidth * 0.9;
  const double verticalOffset = 20;

  // نحدد الاتجاه: فوق ولا تحت الكلمة؟
  double top = position.dy + verticalOffset;
  if (position.dy + verticalOffset + 80 > screenSize.height) {
    top = position.dy - verticalOffset - 80; // اطلع فوق الكلمة
  }

  double left = position.dx;
  if (left + tooltipMaxWidth > screenSize.width) {
    left = screenSize.width - tooltipMaxWidth - 16; // padding من اليمين
  }

  _overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // Blur background + dismiss on tap
        GestureDetector(
          onTap: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),

        // Tooltip
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: tooltipMaxWidth),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Text(
                definition,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(_overlayEntry!);
}
}

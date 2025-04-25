import 'dart:ui';
import 'package:flutter/material.dart';

class DefinitionOverlayController {
  OverlayEntry? _overlayEntry;

  void show({
    required BuildContext context,
    required bool isLoading,
    required Offset position,
    required double screenWidth,
    required double screenHeight,
    required String cleanedWord,
    required List<String> definitions,
    required String selectedLang,
    required String selectedFontFamily,
    required VoidCallback onDismiss,
  }) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;

    double tooltipMaxWidth = screenWidth * 0.9;
    const double verticalOffset = 20;

    double top = position.dy + verticalOffset;
    if (position.dy + verticalOffset + 80 > screenSize.height) {
      top = position.dy - verticalOffset - 80;
    }

    double left = position.dx;
    if (left + tooltipMaxWidth > screenSize.width) {
      left = screenSize.width - tooltipMaxWidth - 16;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                dismiss();
                onDismiss(); // دا بيمسح isLoading وغيره برّة
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
          ),
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
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$cleanedWord :",
                      style: TextStyle(
                        fontFamily: selectedFontFamily,
                        fontSize: screenHeight * 0.023,
                        color: Color(0xffFEC838),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : Column(
                            children: definitions
                                .map((def) => Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        textDirection: selectedLang == "en"
                                            ? TextDirection.ltr
                                            : TextDirection.rtl,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("• ", style: TextStyle(fontSize: screenWidth * 0.023, fontFamily: selectedFontFamily, fontWeight: FontWeight.bold)),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              def,
                                              textAlign: selectedLang == "en"
                                                  ? TextAlign.left
                                                  : TextAlign.right,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.023,
                                                fontFamily: selectedFontFamily,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool get isShowing => _overlayEntry != null;
}

import 'package:flutter/material.dart';

class SliderAndTime extends StatelessWidget {
  final double sliderValue;
  final Duration currentPosition;
  final Duration totalDuration;
  final ValueChanged<double> onSliderChanged;
  final double screenWidth;
  final bool isDarkMode;

  const SliderAndTime({
    required this.isDarkMode,
    required this.sliderValue,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSliderChanged,
    required this.screenWidth,
  });

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Slider(
            value: sliderValue,
            onChanged: onSliderChanged,
            //min: 0.0,
            //max: 1.0,
            activeColor: isDarkMode ? Colors.blue : Colors.yellow,
            inactiveColor: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(currentPosition),
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color:  isDarkMode
                                        ? Color(0xFF212E54)
                                        : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatDuration(totalDuration),
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color:  isDarkMode
                                        ? Color(0xFF212E54)
                                        : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

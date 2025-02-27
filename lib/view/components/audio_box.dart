import 'package:flutter/material.dart';

class PlayerControllers extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipBackward;
  final VoidCallback onSkipForward;
  final VoidCallback onChangeSpeed;
  final VoidCallback onToggleVoice;
  final String imagePath;
  final double playbackSpeed;
  final Widget slider;
  final bool isSwitchingVoice;
  final bool isDarkMode;

  const PlayerControllers({
    required this.isDarkMode,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipBackward,
    required this.onSkipForward,
    required this.onChangeSpeed,
    required this.onToggleVoice,
    required this.imagePath,
    required this.playbackSpeed,
    required this.slider,
    required this.isSwitchingVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white : Color(0xFF212E54),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.replay_10),
                    onPressed: onSkipBackward,
                    iconSize: 30,
                    color:  isDarkMode
                                  ? Color(0xFF212E54)
                                  : Colors.white,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:isDarkMode
                                    ? Color(0xFF212E54)
                                    : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: onPlayPause,
                      iconSize: 30,
                      color:  isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.forward_10),
                    onPressed: onSkipForward,
                    iconSize: 30,
                    color:  isDarkMode
                                  ? Color(0xFF212E54)
                                  : Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0, right: 20),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                    ),
                    onPressed: onChangeSpeed,
                    child: Text(
                      "Speed: ${playbackSpeed}x",
                      style: TextStyle(color: Color(0xFF212E54)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 55,
          left: 10,
          child: GestureDetector(
            onTap: onToggleVoice,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Opacity(
                opacity: 1,
                child: isSwitchingVoice
                    ? CircularProgressIndicator()
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        slider,
      ],
    );
  }
}

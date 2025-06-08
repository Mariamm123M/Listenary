import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class CommandsHelpDialog extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts();

  final Map<String, String> commandsWithDescription = {
    "define [word]": "Get the definition of a word.",
    "find [keyword]": "Search for a word in the current text.",
    "show notes": "Display your saved notes.",
    "summarize": "Summarize the current sentence you're listening to.",
    "translate": "Translate the current sentence to another language.",
  };
  final FlutterTts _flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.06),
        constraints: BoxConstraints(maxHeight: screenHeight * 1.5, maxWidth: screenWidth * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Voice Commands You Can Use",
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: Color(0xff212E54),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: ListView.separated(
                itemCount: commandsWithDescription.length,
                separatorBuilder: (_, __) => Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  final key = commandsWithDescription.keys.elementAt(index);
                  final value = commandsWithDescription[key]!;
                  return ListTile(
                    title: Text(
                      key,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      value,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey[700],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        color: Colors.blue,
                        size: screenWidth * 0.07
                      ),
                      onPressed: () async {
                        await _flutterTts.speak(key);
                        await _flutterTts.awaitSpeakCompletion(true);
                        await _flutterTts.speak(value);
                      },
                    ),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Close",
                  style: TextStyle(
                      fontSize: screenWidth * 0.03, color: Colors.amber, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

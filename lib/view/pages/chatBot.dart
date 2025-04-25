import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List<String> messages = [];
  bool isRobotVisible = true;
  TextEditingController _controller = TextEditingController();
  bool _isDarkMode = false;

  void _sendMessage() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        messages.add(_controller.text);
        _controller.clear();
        isRobotVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: _isDarkMode ? Color(0xffFEC838)  :Color(0xFF212E54),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Chat Bot',
            style: TextStyle(
              color: _isDarkMode
                  ? Colors.white
                  : Color(0xFF212E54),
            ),
          ),
          backgroundColor: _isDarkMode ? Color(0xFF212E54) : Colors.white,
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                "assets/Icons/night.svg",
                color: _isDarkMode ? Color(0xffFEC838) : Color(0xff949494),
                width: 28,
                height: 28,
              ),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
          ],
        ),

        body: Container(
          color: _isDarkMode ? Color(0xFF212E54) : Colors.white,
          child: Column(
            children: [
              if (isRobotVisible) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 0.0),
                    child: Lottie.asset(
                      'assets/Images/robot.json',
                      width: 500,
                      height: 260,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Text(
                    "I'm here to help you find information about any book you're interested in.",
                    style: TextStyle(
                      fontSize: 14,
                      color: _isDarkMode ? Colors.white70 : Color(0xFF212E54),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _isDarkMode ? Color(0xFF4A80F0) : Color(0xFF4A80F0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                          ),
                          child: Text(
                            messages[index],
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask anything..',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: _isDarkMode ? Color(0xffFEC838) : Color(0xFF212E54)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: _isDarkMode ? Color(0xffFEC838) : Color(0xFF212E54)),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
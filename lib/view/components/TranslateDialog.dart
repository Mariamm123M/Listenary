import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TranslateDialog extends StatefulWidget {
  final bool isDarkMode;
  final String? initial;
  String? fromLanguage = 'English';
  String? toLanguage = 'Arabic';


  TranslateDialog({Key? key, required this.isDarkMode, this.initial, this.fromLanguage = 'English', 
  this.toLanguage = 'Arabic'}) : super(key: key);

  @override
  _TranslateDialogState createState() => _TranslateDialogState();
}

class _TranslateDialogState extends State<TranslateDialog> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();

  final Map<String, String> _languages = {
    'English': 'en',
    'Arabic': 'ar',
    'French': 'fr',
    'Spanish': 'es',
    'German': 'de',
    'Italian': 'it',
    'Russian': 'ru',
    'Chinese': 'zh',
    'Japanese': 'ja',
    'Hindi': 'hi',
  };

 
  Future<void> _translateText() async {
    if (_textController.text.isNotEmpty) {
      try {
        final fromLang = _languages[widget.fromLanguage]!;
        final toLang = _languages[widget.toLanguage]!;

        final translation = await _translator.translate(
          _textController.text,
          from: fromLang,
          to: toLang,
        );

        setState(() {
          _translatedController.text = translation.text;
        });
      } catch (e) {
        print("Error during translation: $e");
      }
    }
  }
@override
void initState() {
  super.initState();
  if (widget.initial != null && widget.initial!.isNotEmpty) {
    _textController.text = widget.initial!;
    _translateText();
  }
}
@override
void dispose() {
  _textController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
      title: Text(
        'Translate',
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),fontFamily: 'Inter'
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'From Language',
      style: TextStyle(
        color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),fontFamily: 'Inter'
      ),
    ),
    Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white, // Background color for dropdown items
      ),
      child: DropdownButton<String>(
        value: widget.fromLanguage,
        onChanged: (String? newValue) {
          setState(() {
            widget.fromLanguage = newValue;
          });
          _translateText();
        },
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Color(0xFF212E54), fontFamily: 'Inter'// Selected item color
        ),
        dropdownColor: widget.isDarkMode ? Color(0xFF212E54) : Colors.white, // Dropdown items background color
        iconEnabledColor: widget.isDarkMode ? Colors.white : Color(0xFF212E54), // Dropdown icon color
        items: _languages.keys.map<DropdownMenuItem<String>>(
          (String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
              ),
            );
          },
        ).toList(),
      ),
    ),
  ],
)

),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To Language',
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white
                              : Color(0xFF212E54),
                        ),
                      ),
                      DropdownButton<String>(
                        value: widget.toLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            widget.toLanguage = newValue;
                          });
                          _translateText();
                        },
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Color(0xFF212E54), fontFamily: 'Inter'
                        ),
                        dropdownColor: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
                                iconEnabledColor: widget.isDarkMode ? Colors.white : Color(0xFF212E54), // Dropdown icon color

                        items: _languages.keys.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter text to translate...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,fontFamily: 'Inter'
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                  ),
                ),
              ),
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
              ),
              onChanged: (text) {
                _translateText();
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _translatedController,
              maxLines: 5,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Translated text will appear here...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                  ),
                ),
              ),
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.yellow : Color(0xFF212E54),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(
                color: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

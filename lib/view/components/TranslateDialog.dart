import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';

class TranslateDialog extends StatefulWidget {
  final bool isDarkMode;
  final String? initial;
  String? fromLanguage = 'english'.tr;
  String? toLanguage = 'arabic'.tr;

  TranslateDialog({
    Key? key, 
    required this.isDarkMode, 
    this.initial, 
    this.fromLanguage,
    this.toLanguage,
  }) : super(key: key) {
    fromLanguage ??= 'english'.tr;
    toLanguage ??= 'arabic'.tr;
  }

  @override
  _TranslateDialogState createState() => _TranslateDialogState();
}

class _TranslateDialogState extends State<TranslateDialog> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();

  final Map<String, String> _languages = {
    'english': 'en',
    'arabic': 'ar',
    'french': 'fr',
    'spanish': 'es',
    'german': 'de',
    'italian': 'it',
    'russian': 'ru',
    'chinese': 'zh',
    'japanese': 'ja',
    'hindi': 'hi',
  };

  Future<void> _translateText() async {
    if (_textController.text.isNotEmpty) {
      try {
        final fromLang = _languages[widget.fromLanguage!.toLowerCase()]!;
        final toLang = _languages[widget.toLanguage!.toLowerCase()]!;

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
        'translate'.tr,
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
          fontFamily: 'Inter'
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
                        'from_language'.tr,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                          fontFamily: 'Inter'
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
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
                            color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                            fontFamily: 'Inter'
                          ),
                          dropdownColor: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
                          iconEnabledColor: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                          items: _languages.keys.map<DropdownMenuItem<String>>(
                            (String key) {
                              return DropdownMenuItem<String>(
                                value: key.tr,
                                child: Text(key.tr),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'to_language'.tr,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                          fontFamily: 'Inter'
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
                          color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                          fontFamily: 'Inter'
                        ),
                        dropdownColor: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
                        iconEnabledColor: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                        items: _languages.keys.map<DropdownMenuItem<String>>(
                          (String key) {
                            return DropdownMenuItem<String>(
                              value: key.tr,
                              child: Text(key.tr),
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
                hintText: 'enter_text_to_translate'.tr,
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  fontFamily: 'Inter'
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
                hintText: 'translated_text_will_appear_here'.tr,
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
              Get.back();
            },
            child: Text(
              'close'.tr,
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
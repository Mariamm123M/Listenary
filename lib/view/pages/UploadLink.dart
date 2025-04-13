import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'ReadingPage.dart';

class UploadLink extends StatelessWidget {
  final textKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Color(0xff212E54),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.02),
          child: Form(
              key: textKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Input or paste Link to extract text",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    validator: validateLink,
                    controller: textController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: "Enter Link",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 1, color: Color(0xff949494)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 15),
                      GestureDetector(
                        child: SvgPicture.asset(
                          "assets/Icons/copy.svg",
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.08,
                          color: Color(0XFF212E54),
                        ),
                        onTap: () {
                          copyLink(textController, context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (textKey.currentState!.validate()) {
                            final link = textController.text;
                            final response = await http.post(
                              Uri.parse('http://192.168.1.7:5000/process-link'),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({'link': link}),
                            );

                            if (response.statusCode == 200) {
                              final result = jsonDecode(response.body);
                              final extractedText = result['text'];

                              Get.to(() => ReadingPage(documnetText: extractedText));
                            } else {

                              final error = jsonDecode(response.body)['error'];
                              Get.snackbar("Error", error);
                            }
                          }
                        },
                        child: Text("Upload Link"),
                      ),
                    ],
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}
Future<void> copyLink(
    TextEditingController text, BuildContext context) async {
  if (text.text.isNotEmpty) {
    await FlutterClipboard.copy(text.text);
    Get.snackbar(
      "",
      "Link copied to clipboard",
      backgroundColor: Color(0xff212E54),
      messageText: Text(
        "Link copied to clipboard",
        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
      ),
    );
  }
}
String? validateLink(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a link';
  }

  // Regular expression for URL validation
  final urlRegex = RegExp(
      r'^(https?:\/\/)?' // http:// or https://
      r'([\da-z\.-]+)\.' // domain name
      r'([a-z\.]{2,6})' // .com, .org, etc
      r'([\/\w \.-]*)*\/?$' // path
  );

  if (!urlRegex.hasMatch(value)) {
    return 'Please enter a valid URL (e.g. https://example.com)';
  }

  // Additional check for at least one dot in the domain
  if (!value.contains('.') || value.split('.').last.length < 2) {
    return 'Invalid domain format';
  }

  return null; // Return null if valid
}
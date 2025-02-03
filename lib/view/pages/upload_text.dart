import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class UploadText extends StatelessWidget {
  UploadText({super.key});

  var textKey = GlobalKey<FormState>();
  TextEditingController text = TextEditingController();

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
            )),
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
                  "Input or paste text to listen",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter text";
                    }
                    return null;
                  },
                  controller: text,
                  maxLines: 10,
                  style: TextStyle(
                    color: Colors.black, 
                    fontSize: 18.0, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'Inter'
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter Text",
                    hintStyle: TextStyle(
                        color: Color(0xff9B9B9B),
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                    errorStyle:
                        TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide:
                            BorderSide(width: 1, color: Color(0xff949494))),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.red)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide:
                            BorderSide(width: 2, color: Color(0xff949494))),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.red)),
                  ),
                ),
                SizedBox(
                  height: screenWidth * 0.02,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      child: SvgPicture.asset(
                        "assets/Icons/copy.svg",
                        height: screenHeight * 0.05,
                        width: screenWidth * 0.08,
                        color: Color(0XFF212E54),
                      ),
                      onTap: () {
                        copyText(text, context);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: screenWidth * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if (textKey.currentState!.validate()) {
                            Get.toNamed("home");
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              "Next",
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            )
                          ],
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> copyText(
      TextEditingController text, BuildContext context) async {
    if (text.text.isNotEmpty) {
      await FlutterClipboard.copy(text.text);
      Get.snackbar(
        "",
        "Text cppied to clipboard",
        backgroundColor: Color(0xff212E54),
        messageText: Text(
          "Text cppied to clipboard",
          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
        ),
      );
    }
  }
}

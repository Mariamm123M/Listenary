import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';
import 'package:lottie/lottie.dart';
import '../pages/ReadingPage.dart';
import '../pages/charcter_screen.dart';

class CharctersDialog extends StatelessWidget {
  final Book book;

  CharctersDialog({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            color: Color(0xFFFEC838),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 200,
                  child: Lottie.asset('assets/Images/members.json'),
                ),
                SizedBox(height: 5),
                Text(
                  'intro_message'.tr,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => ReadingPage(book: book));
                      },
                      child: Text('skip'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        print(book.bookcontent);
                        Get.off(() => CharacterScreen(
                              storyText: book.bookcontent,
                            ));
                      },
                      child: Text('ok'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF212E54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

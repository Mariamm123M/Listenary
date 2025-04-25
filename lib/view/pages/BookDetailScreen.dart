import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/pages/ReadingPage.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  BookDetailScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF212E54),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 24.0),
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0, top: 6.0),
            child: SvgPicture.asset(
              'assets/Images/volume.svg',
              color: Colors.white,
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFF212E54),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 180,
                      height: 268.8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(book.bookimageURL),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      book.booktitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 24.2 / 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDetailColumn('Rating', book.rating.toString()),
                      _buildDivider(),
                      _buildDetailColumn('Pages', book.pages.toString()),
                      _buildDivider(),
                      _buildDetailColumn('Language', book.language),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.2,
                            vertical: screenHeight * 0.015)),
                        backgroundColor:
                        WidgetStatePropertyAll(Color(0xffFEC838)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45)))),
                    onPressed: () {
                      Get.to(() => ReadingPage(
                        book: book,
                      ));
                    },
                    child: Text(
                      "Play Now",
                      style: TextStyle(
                          color: Color(0xff212E54),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter'),
                    )),
                GestureDetector(
                  child: SvgPicture.asset("assets/Icons/Headphones.svg",
                      height: 45, width: 45, fit: BoxFit.fill),
                  onTap: () {
                    Get.to(() => ReadingPage(
                      book: book,
                    ));
                  },
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.035, top: screenHeight * 0.05),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Color(0xFFFEC838),
                    width: 2,
                  ),
                ),
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212E54),
                    height: 14.52 / 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Container(
                height: 400,
                child: SingleChildScrollView(
                  child: Text(book.description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 15 / 10,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: null,
                      overflow: TextOverflow.visible),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFFBAABAB),
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFFBAABAB),
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Color(0xFFBAABAB),
    );
  }
}
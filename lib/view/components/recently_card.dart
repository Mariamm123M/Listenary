import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/awesome_dialog.dart';
import 'package:listenary/view/pages/BookDetailScreen.dart';
import 'package:listenary/view/pages/ReadingPage.dart';

class RecentlyCard extends StatelessWidget {
  final Book book;
  final RecentBooksController controller = Get.find();

  RecentlyCard({required this.book, super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return InkWell(
      onTap: () {
        controller.addBookToRecent(book);
        Get.to(() => BookDetailScreen(book: book));
      },
      onLongPress: () {
        showDeleteDialog(
            context: context,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            okText: "Delete",
            title: "Delete Book From Recents",
            desc: "Are you sure you want to delete the book from recents?",
            onDelete: () {
              Get.back();
              controller.removeBookFromRecent(book);
            });
      },
      child: Container(
        width: screenWidth * 0.66,
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025, vertical: screenHeight * 0.02),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          children: [
            Image(
              image: book.bookimage,
              height: screenWidth * 0.3,
              width: screenWidth * 0.2,
              fit: BoxFit
                  .cover, // Ensures the image is contained within the size
            ),
            SizedBox(width: screenWidth * 0.015),
            Expanded(
              // This will ensure the child widget takes up available space and handles overflow
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book title
                    Text(
                      book.booktitle,
                      maxLines: 1,
                      overflow: TextOverflow
                          .ellipsis, // Truncate the text with an ellipsis
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter'),
                    ),
                    SizedBox(height: screenWidth * 0.0025),
                    // Book author
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.57),
                          fontSize: screenWidth * 0.022,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter'),
                    ),
                    const Spacer(),
                    // Play button and label
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ReadingPage(
                              book: book,
                            ));
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/Icons/Headphones.svg",
                            height: 20, // Make sure icons scale well
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                            child: Text(
                              "Play Now",
                              style: TextStyle(
                                  color: Color(0xff212E54),
                                  fontSize: screenWidth * 0.023,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Inter'),
                              maxLines: 1, // Avoid text overflow here as well
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

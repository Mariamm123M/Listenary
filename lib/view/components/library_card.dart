import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/favorites_books_controller.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/pages/BookDetailScreen.dart';

class LibraryCard extends StatefulWidget {
  final Book book;
  const LibraryCard({super.key, required this.book});

  @override
  State<LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<LibraryCard> {
  bool isSaved = false;
  RecentBooksController recentController = Get.find();
  FavoriteBooksController favoriteController = Get.find();

void initState() {
    super.initState();
    // Initialize isSaved based on whether the book is in the favorites list
    isSaved = favoriteController.isBookInFavorite(widget.book);
  }
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return GestureDetector(
      onTap: () {
        // Add the book to recent books list and navigate to details page
        recentController.addBookToRecent(widget.book);
        Get.to(() => BookDetailScreen(book: widget.book));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff212E54).withOpacity(0.1), // Shadow color
              spreadRadius: 0, // Spread radius
              blurRadius: 12,   // Blur radius
              offset: const Offset(0, 1), // Offset: x, y
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.012),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book image
          widget.book.bookimageURL.startsWith('http')
              ? Image.network(
            widget.book.bookimageURL, // Fetch image from URL
            height: screenHeight * 0.23,
            width: screenWidth * 0.7,
            fit: BoxFit.fill,
          )

              : Image.asset(
            widget.book.bookimageURL, // Fetch image from local assets
            height: screenHeight * 0.23,
            width: screenWidth * 0.7,
            fit: BoxFit.fill,
          ),

              SizedBox(height: screenHeight * 0.002), // Add some space between image and text
              // Book title and bookmark in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Use Flexible to handle long text overflow
                  Flexible(
                    child: Text(
                      widget.book.booktitle,
                      maxLines: 1, // Restrict title to one line
                      overflow: TextOverflow.ellipsis, // Show ellipsis if title is too long
                      style: TextStyle(
                        color: Color(0xff212E54),
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter'
                      ),
                    ),
                  ),
                  // Bookmark icon
                  GetX<FavoriteBooksController>(
                    builder: (controller){
                      return IconButton(
                    padding: EdgeInsets.zero, // Remove default padding
                    onPressed: () {
                      setState(() {
                      isSaved = !isSaved;
                        if (isSaved) {
                          favoriteController.addBookToFavorite(widget.book);
                        } else {
                          favoriteController.removeBookFromFavorite(widget.book);
                        } });
                    },
                    icon: SvgPicture.asset(
                      "assets/Icons/BookMark.svg",
                      color: favoriteController.isBookInFavorite(widget.book)? const Color(0xff212E54) : null,
                    ),
                  );
                    }
                  )
                ],
              ),
              // Book author
              Text(
                widget.book.author,
                style: TextStyle(
                  color: Color(0xff9B9B9B),
                  fontSize: screenWidth * 0.022,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/favorites_books_controller.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/pages/BookDetailScreen.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

FavoriteBooksController controller = Get.find();

class _BookListScreenState extends State<BookListScreen> {
  Book? deletedBook;
  int? deletedBookIndex;

  void _deleteBook(int index) {
    // Save the deleted book and its index
    deletedBook = controller.favoriteBooks[index];
    deletedBookIndex = index;
    setState(() {
      controller.removeBookFromFavorite(controller.favoriteBooks[index]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Book deleted"),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (deletedBook != null && deletedBookIndex != null) {
              setState(() {
                controller.addBookToFavorite(deletedBook!, deletedBookIndex);
              });
            }
          },
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(bottom: height * 0.01),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: width * 0.06, top: height * 0.05),
                  child: Text(
                    'My Books',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF212E54),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: width * 0.06, top: height * 0.05),
                  child: SvgPicture.asset(
                    'assets/Icons/library2.svg',
                    width: width * 0.08,
                    height: width * 0.08,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            Expanded(
                child: (controller.favoriteBooks.isEmpty)
                    ? Center(
                        child: Padding(
                        padding: EdgeInsets.only(left: width * 0.025),
                        child: Text(
                          "No saved books, Start saving one!",
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.32),
                              fontSize: width * 0.041,
                              fontWeight: FontWeight.w600),
                        ),
                      ))
                    : GetX<FavoriteBooksController>(builder: (controller) {
                        return ListView.builder(
                          itemCount: controller.favoriteBooks.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => BookDetailScreen(
                                    book: controller.favoriteBooks[index],
                                  ),
                                );
                              },
                              child: Container(
                                width: 375,
                                height: 120,
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Color(0xFF25252552)),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 4,
                                      left: 8,
                                      child: Image(
                                        image: controller
                                            .favoriteBooks[index].bookimage,
                                        width: 75,
                                        height: 112,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 9,
                                      left: 100,
                                      child: SizedBox(
                                        width: 200,
                                        height: 24,
                                        child: Text(
                                          controller
                                              .favoriteBooks[index].booktitle,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF212E54),
                                          ),
                                          overflow: TextOverflow.visible,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 33,
                                      left: 104,
                                      child: SizedBox(
                                        width: 117,
                                        height: 15,
                                        child: Text(
                                          controller
                                              .favoriteBooks[index].author,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: width * 0.03,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0x91000000),
                                          ),
                                          overflow: TextOverflow.visible,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Positioned(
                                      top: 45,
                                      left: 100,
                                      child: Container(
                                        width: 108,
                                        height: 64,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5.33, 4, 6.67, 4),
                                              child: Image.asset(
                                                'assets/Icons/Headphones.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0),
                                              child: SizedBox(
                                                width: 54,
                                                height: 15,
                                                child: Text(
                                                  "Play Now",
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: width * 0.03,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color: const Color(
                                                        0xFF212E54),
                                                  ),
                                                  overflow:
                                                      TextOverflow.visible,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 54,
                                      left: 288,
                                      child: GestureDetector(
                                        onTap: () => _deleteBook(index),
                                        child: SvgPicture.asset(
                                          'assets/Icons/delete.svg',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      })),
          ],
        ),
      ),
    );
  }
}

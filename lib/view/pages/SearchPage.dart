import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/pages/BookDetailScreen.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Book> books = []; // List to hold books fetched from API
  List<Book> searchResults = [];
  List<Book> visitedBooks = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    fetchBooks(); // Fetch books when the page loads
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse('http://192.168.1.7:5000/get_books')); // Replace with your Flask API URL

    if (response.statusCode == 200) {
      List<dynamic> booksData = json.decode(response.body);
      setState(() {
        books = booksData.map((bookData) => Book.fromJson(bookData)).toList();
      });
    } else {
      throw Exception('Failed to load books'.tr);
    }
  }

  void _searchBooks(String query) {
    final results = books.where((book) {
      return book.booktitle.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      this.query = query;
      searchResults = results;
    });
  }

  void _addToHistory(Book book) {
    if (!visitedBooks.contains(book)) {
      setState(() {
        visitedBooks.add(book);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF212E54);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_outlined, color: Colors.white)),
        title: Text(
          'Search Books'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) => _searchBooks(query),
              decoration: InputDecoration(
                hintText: 'Search for a book...'.tr,
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: themeColor.withAlpha(25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: query.isEmpty
                  ? _buildHistorySection()
                  : searchResults.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 100, color: Colors.white70),
                    SizedBox(height: 10),
                    Text(
                      "No results found.".tr,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              )
                  : GridView.builder(
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final book = searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      _addToHistory(book);
                      Get.to(() => BookDetailScreen(book: book));
                    },
                    child: Card(
                      color: themeColor.withAlpha(25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: book.bookimageURL != null
                                  ? Image.network(
                                book.bookimageURL,
                                fit: BoxFit.cover,
                              )
                                  : Placeholder(), // Placeholder for missing images
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.booktitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  book.author,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      book.rating.toString(),
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return visitedBooks.isEmpty
        ? Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "No Books yet".tr,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.menu_book_sharp,
            color: Colors.white70,
            size: 20,
          ),
        ],
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recently Viewed".tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  visitedBooks.clear();
                });
              },
              child: Text(
                "Clear".tr,
                style: TextStyle(
                  color: Color(0xFFFEC838),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: visitedBooks.map((book) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailScreen(book: book),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          book.bookimageURL ?? "", // If the image URL is null, display an empty string
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        book.booktitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
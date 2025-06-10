
import 'package:get/get_rx/get_rx.dart';
import 'package:listenary/model/noteModel.dart';

class Book {
  final int bookId;
  final String booktitle;
  final String author;
  final String bookimageURL;
  final double rating;
  final int pages;
  final String language;
  final String description;
  final String? audioFilePath;
  final String bookcontent;
  final String category;
  RxList<Note> notes = <Note>[].obs;    // ده زيادة محتاج يتهندل ف الباك ايند
//book userid note
  Book({
    required this.bookId,
    required this.booktitle,
    required this.author,
    required this.bookimageURL,
    required this.rating,
    required this.pages,
    required this.language,
    required this.description,
    this.audioFilePath,
    required this.bookcontent,
    required this.category,
  });

  // ✅ FIXED: updated the mapping to match MySQL attributes
  factory Book.fromJson(Map<String, dynamic> json) {
  return Book(
    bookId: json['BookID'] ?? 0,
    booktitle: json['Title'] ?? '',
    author: json['Author'] ?? '',
    bookimageURL: json['bookImageUrl'] ?? '',  // ✅ FIXED here
    rating: (json['Rating'] ?? 0).toDouble(),
    pages: json['Pages'] ?? 0,
    language: json['Language'] ?? '',
    description: json['Description'] ?? '',
    bookcontent: json['Content'] ?? '',
    audioFilePath: json['audioFilePath'],
    category: json['Category'] ?? '',
  );
}

}
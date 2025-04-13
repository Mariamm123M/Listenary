import 'package:flutter/material.dart';

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
  });

  // ✅ FIXED: updated the mapping to match MySQL attributes
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['BookID'] ?? 0,  // Assuming BookID is an integer in the response
      booktitle: json['Title'] ?? '',
      author: json['Author'] ?? '',
      bookimageURL: json['image_url'] ?? '',  // Assuming this is part of the response from the backend
      rating: (json['Rating'] ?? 0).toDouble(),
      pages: json['Pages'] ?? 0,
      language: json['Language'] ?? '',
      description: json['Description'] ?? '',
      bookcontent: json['Content'] ?? '',  // Assuming 'Content' is part of the response for book content
      audioFilePath: json['audioFilePath'],  // optional, based on backend response
    );
  }
}
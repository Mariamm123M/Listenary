import 'package:flutter/material.dart';

class Book {
  final String booktitle;
  final String author;
  final ImageProvider bookimage;
  final double rating;
  final int pages;
  final String language;
  final String description;
  final String? audioFilePath;
  final String bookcontent;

  Book({
    required this.booktitle,
    required this.author,
    required this.bookimage,
    required this.rating, 
    required this.pages,
    required this.language,
    required this.description,
    this.audioFilePath,
    required this.bookcontent,
  });
}
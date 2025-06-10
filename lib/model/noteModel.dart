import 'package:flutter/material.dart';

class Note {
  final String userId;           // ✅ Add this line
  final String bookId;
  final String booktitle;
  final int sentenceIndex;
  final String noteContent;
  final Color color;
  final bool isPinned;

  Note({
    required this.userId,       // ✅ Add this line
    required this.bookId,
    required this.booktitle,
    required this.sentenceIndex,
    required this.noteContent,
    required this.color,
    required this.isPinned,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      userId: json["userId"] ?? "",                        // ✅ Parse from JSON
      bookId: json["bookId"],
      booktitle: json["booktitle"] ?? "",
      sentenceIndex: json["sentenceIndex"],
      noteContent: json["noteContent"],
      color: Color(int.parse(json["color"], radix: 16)),
      isPinned: json["isPinned"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,                                     // ✅ Include in toJson
      "bookId": bookId,
      "booktitle": booktitle,
      "sentenceIndex": sentenceIndex,
      "noteContent": noteContent,
      "color": color.value.toRadixString(16),
      "isPinned": isPinned,
    };
  }
}

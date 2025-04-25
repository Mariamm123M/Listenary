import 'dart:ui';

class Note {
  final String booktitle;
  final String noteContent;
  final Color color;

  /// رقم الجملة اللي الملاحظة مرتبطة بيها
  final int sentenceIndex;

  /// هل الملاحظة دي مثبّتة (مفعّل فيها pin)؟
  final bool isPinned;

  Note({
    required this.booktitle,
    required this.noteContent,
    required this.color,
    required this.sentenceIndex,
    this.isPinned = false,
  });

  Note copyWith({
    String? booktitle,
    String? noteContent,
    Color? color,
    int? sentenceIndex,
    bool? isPinned,
  }) {
    return Note(
      booktitle: booktitle ?? this.booktitle,
      noteContent: noteContent ?? this.noteContent,
      color: color ?? this.color,
      sentenceIndex: sentenceIndex ?? this.sentenceIndex,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

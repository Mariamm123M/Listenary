import 'package:get/get.dart';
import 'package:listenary/model/noteModel.dart';

class NoteController extends GetxController {
  // قائمة الملاحظات المؤقتة
  RxList<Note> temporaryNotes = <Note>[].obs;
  
  // إضافة أو تحديث ملاحظة
  void saveNote(Note note) {
    final existingIndex = temporaryNotes.indexWhere(
      (n) => n.sentenceIndex == note.sentenceIndex
    );
    
    if (existingIndex != -1) {
      temporaryNotes[existingIndex] = note;
    } else {
      temporaryNotes.add(note);
    }
  }
  
  // حذف ملاحظة
  void deleteNote(int sentenceIndex) {
    temporaryNotes.removeWhere((note) => note.sentenceIndex == sentenceIndex);
  }
  
  // الحصول على ملاحظة محددة
  Note? getNote(int sentenceIndex) {
    try {
      return temporaryNotes.firstWhere(
        (note) => note.sentenceIndex == sentenceIndex
      );
    } catch (e) {
      return null;
    }
  }
  
  // حذف جميع الملاحظات
  void clearAllNotes() {
    temporaryNotes.clear();
  }
}
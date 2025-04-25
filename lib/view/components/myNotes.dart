import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/notesController.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/model/noteModel.dart';

class NotesDialog extends StatefulWidget {
  final double screenWidth;
  final Book? book;
  const NotesDialog({
    Key? key,
    this.book,
    required this.screenWidth,
  }) : super(key: key);

  @override
  _NotesDialogState createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  final noteController = Get.find<NoteController>();

  // الحصول على الملاحظات بناءً على وجود الكتاب أو لا
  List<Note> get _notes {
    return widget.book != null 
        ? widget.book!.notes 
        : noteController.temporaryNotes;
  }

 void _deleteNote(Note note) {
  if (widget.book != null) {
    // لحذف الملاحظة من الكتاب
      widget.book!.notes.removeWhere((n) => n.sentenceIndex == note.sentenceIndex);
    // إرسال إشارة تحديث للملاحظات المؤقتة (إذا كانت متصلة)
    noteController.deleteNote(note.sentenceIndex);
  } else {
    // لحذف الملاحظة المؤقتة
    noteController.deleteNote(note.sentenceIndex);
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(8.0),
      content: SizedBox(
        width: widget.screenWidth * 0.9,
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            SizedBox(height:20),
            Text("Your Notes", style: TextStyle(fontSize: widget.screenWidth * 0.025, fontWeight: FontWeight.bold)),
            Expanded(
              child: Obx(() =>ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return ListTile(
                    leading: SvgPicture.asset(
                      "assets/Icons/pin.svg",
                      color: note.color,
                      height: 40,
                      width: 40,
                    ),
                    title: Text(note.noteContent, style:TextStyle(fontSize: widget.screenWidth * 0.025, fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.grey[700],
                        size: widget.screenWidth * 0.04,
                      ),
                      onPressed: () => _deleteNote(note),
                    ),
                  );
                },
              ),)
            )
          ],
        ),
      ),
    );
  }
}
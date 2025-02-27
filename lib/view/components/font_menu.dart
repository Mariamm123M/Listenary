import 'package:flutter/material.dart';

void showFontMenu(BuildContext context, Function(String?) onSelected) {
  showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
    items: [
      PopupMenuItem<String>(
        value: 'Inter',
        child: Text('Inter', style: TextStyle(fontFamily: 'Inter')),
      ),
      PopupMenuItem<String>(
        value: 'Lobster',
        child: Text('Lobster', style: TextStyle(fontFamily: 'Lobster')),
      ),
      PopupMenuItem<String>(
        value: 'Pacifico',
        child: Text('Pacifico', style: TextStyle(fontFamily: 'Pacifico')),
      ),
      PopupMenuItem<String>(
        value: 'PlayfairDisplay',
        child: Text('PlayfairDisplay',
            style: TextStyle(fontFamily: 'PlayfairDisplay')),
      ),
      PopupMenuItem<String>(
        enabled: false,
        child: Divider(),
      ),
      PopupMenuItem<String>(
        value: 'Bold',
        child: Text('Bold', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      PopupMenuItem<String>(
        value: 'Underline',
        child: Text('Underline',
            style: TextStyle(decoration: TextDecoration.underline)),
      ),
      PopupMenuItem<String>(
        value: 'Italic',
        child: Text('Italic', style: TextStyle(fontStyle: FontStyle.italic)),
      ),
    ],
  ).then((value) {
    onSelected(value); // نمرر القيمة المختارة من هنا
  });
}
